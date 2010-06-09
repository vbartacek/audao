/*
 * Copyright 2010 Spolecne s.r.o. (www.spoledge.com)
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
package com.spoledge.audao.generator;

import java.io.InputStreamReader;
import java.io.FileInputStream;


/**
 * This is a wrapper for Apache Ant.
 */
public class GeneratorTask extends org.apache.tools.ant.Task {
    private String targetName;
    private String pkgName;
    private String srcName;
    private String destName;
    private boolean debug;
    private boolean isDtoGwtSerializer;
    private ResourceType[] enableResources;


    public void setDbType( String target ) {
        this.targetName = target.toUpperCase();
    }


    public void setPkg( String pkgName ) {
        this.pkgName = pkgName;
    }


    public void setSrc( String srcName ) {
        this.srcName = srcName;
    }


    public void setDest( String destName ) {
        this.destName = destName;
    }


    public void setDebug( boolean debug ) {
        this.debug = debug;
    }


    public void setGenerateDtoGwtSerializer( boolean val ) {
        this.isDtoGwtSerializer = val;
    }


    public void setGenerate( String val ) {
        if (val == null | val.length() == 0) return;
        String[] sress = val.split("\\s*,\\s*");

        enableResources = new ResourceType[ sress.length ];
        for (int i=0; i < sress.length; i++) {
            enableResources[i] = ResourceType.valueOf(sress[i].toUpperCase());
        }

    }


    @Override
    public void execute() throws org.apache.tools.ant.BuildException {
        System.out.println("Generating from '" + srcName + "', to '" + destName + "', target '" + targetName + "'");

        try {
            Target target = Target.valueOf( targetName );
            InputStreamReader xmlReader = new InputStreamReader( new FileInputStream( srcName ), "UTF-8");

            Output output = destName.endsWith(".zip") ?
                                new ZipFileOutput( destName ) : new FileOutput( destName );

            Generator g = new Generator( target );
            g.setIsDebugEnabled( debug );
            g.validate( xmlReader );

            xmlReader = new InputStreamReader( new FileInputStream( srcName ), "UTF-8");

            if (enableResources != null) {
                for (ResourceType res : enableResources) {
                    g.setResourceEnabled( res, true );
                }

                if (isDtoGwtSerializer) {
                    g.setResourceEnabled( ResourceType.DTO_GWT_SERIALIZER, isDtoGwtSerializer );
                }
            }
            else {
                g.setAllResourcesEnabled( true );
                g.setResourceEnabled( ResourceType.DTO_GWT_SERIALIZER, isDtoGwtSerializer );
            }

            g.generate( pkgName, xmlReader, output );

            output.finish();
        }
        catch (GeneratorException e) {
            if (e.isWarningOnly()) {
                System.out.println( e );
            }
            else throw new org.apache.tools.ant.BuildException( e );
        }
        catch (Exception e) {
            throw new org.apache.tools.ant.BuildException( e );
        }
    }
}

