/*
 * Copyright 2013 Spolecne s.r.o. (www.spoledge.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.spoledge.audao.maven;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.logging.Log;

import org.apache.maven.plugins.annotations.Component;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.plugins.annotations.ResolutionScope;

import org.apache.maven.project.MavenProject;

import java.io.File;
import java.io.InputStreamReader;
import java.io.FileInputStream;

import java.util.List;

import com.spoledge.audao.generator.*;


/**
 * Goal which generates Java source files.
 */
@Mojo( name = "generate", defaultPhase = LifecyclePhase.GENERATE_SOURCES )
public class GeneratorMojo extends AbstractMojo {

    @Component
    private MavenProject project;

    @Parameter( required = true )
    private String dbType;

    @Parameter( defaultValue="${project.groupId}", required = true )
    private String pkg;

    @Parameter( defaultValue="${basedir}/src/main/audao/${project.artifactId}.xml", required = true )
    private File src;

    @Parameter( defaultValue = "${project.build.directory}/generated-sources/audao", required = true )
    private File dest;

    @Parameter( property = "debug" )
    private boolean debug;

    @Parameter
    private boolean generateDtoGwtSerializer;

    @Parameter( property = "generateTypes" )
    private String[] generateTypes;

    private ResourceType[] enableResources;


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    public void setGenerateTypes( String[] vals ) {
        this.generateTypes = vals;

        if (vals == null || vals.length == 0) return;

        enableResources = new ResourceType[ vals.length ];
        for (int i=0; i < vals.length; i++) {
            enableResources[i] = ResourceType.valueOf(vals[i].toUpperCase());
        }
    }


    @Override
    public void execute() throws MojoExecutionException {
        Log log = getLog();

        // Check if something was changed:
        File touch = new File( dest, "audao.txt" );

        if (!touch.exists() || touch.lastModified() < src.lastModified()) generate();
        else log.info( "Skipping AuDAO generator task - sources are up-to-date." );

        try {
            touch.delete();
            touch.createNewFile();
        }
        catch (Exception e) {}

        project.addCompileSourceRoot( dest.getAbsolutePath());
        log.info( "Added source directory: " + dest );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private void generate() throws MojoExecutionException {
        Log log = getLog();

        String targetName = dbType.toUpperCase();

        log.info( "AuDAO Generating from '" + src + "', to '" + dest + "', target '" + targetName + "'" );

        try {
            Target target = Target.valueOf( targetName );
            InputStreamReader xmlReader = new InputStreamReader( new FileInputStream( src ), "UTF-8");

            Output output = dest.getName().endsWith(".zip") ?
                                new ZipFileOutput( dest ) : new FileOutput( dest );

            Generator g = new Generator( target );
            g.setIsDebugEnabled( debug );
            g.validate( xmlReader );

            xmlReader = new InputStreamReader( new FileInputStream( src ), "UTF-8");

            if (enableResources != null) {
                for (ResourceType res : enableResources) {
                    g.setResourceEnabled( res, true );
                }

                if (generateDtoGwtSerializer) {
                    g.setResourceEnabled( ResourceType.DTO_GWT_SERIALIZER, generateDtoGwtSerializer );
                }
            }
            else {
                g.setAllResourcesEnabled( true );
                g.setResourceEnabled( ResourceType.DTO_GWT_SERIALIZER, generateDtoGwtSerializer );
            }

            g.generate( pkg, xmlReader, output );

            output.finish();
        }
        catch (GeneratorException e) {
            if (e.isWarningOnly()) {
                log.warn( e.toString());
            }
            else {
                List<? extends Exception> exceptions = e.getExceptions();
                List<GeneratorException.Type> types = e.getTypes();

                for (int i=0; i < exceptions.size(); i++) {
                    switch (types.get(i)) {
                        case WARNING:
                            log.warn( exceptions.get(i).toString());
                            break;

                        case ERROR:
                            log.error( "Error: ", exceptions.get(i));
                            break;

                        default:
                            log.error( "Fatal error:", exceptions.get(i));
                            break;

                    }
                }

                throw new MojoExecutionException( "Error (" + exceptions.size() + " nested errors)", e );
            }
        }
        catch (Exception e) {
            throw new MojoExecutionException( "Error", e );
        }
    }

}

