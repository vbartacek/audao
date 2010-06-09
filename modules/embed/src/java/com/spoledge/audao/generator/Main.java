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

public class Main {

    public static void main(String[] args) throws Exception {
        if (args.length < 4) {
            usage();
            return;
        }

        try {
            int offset = 0;
            ResourceType[] enableResources = null;
            boolean isDtoGwtSerializer = false;

            while (args[offset].startsWith("-")) {
                String opt = args[offset];

                if ("-g".equals(opt) || "--generate".equals(opt)) {
                    String[] sress = args[offset+1].split( "\\s*,\\s*" );

                    enableResources = new ResourceType[ sress.length ];
                    for (int i=0; i < sress.length; i++) {
                        enableResources[i] = ResourceType.valueOf(sress[i].toUpperCase());
                    }

                    offset += 2;
                }
                else if ("-s".equals(opt) || "--generate-dto-gwt-serializer".equals(opt)) {
                    isDtoGwtSerializer = true;
                    offset++;
                }
                else {
                    System.out.println("Unknown option: " + opt );
                    usage();
                    return;
                }
            }

            if (args.length - offset < 4) {
                usage();
                return;
            }

            Target target = Target.valueOf( args[ offset+0 ].toUpperCase() );
            String pkg = args[ offset+1 ];
            InputStreamReader xmlReader = new InputStreamReader( new FileInputStream( args[offset+2] ), "UTF-8");

            String outname = args[offset+3];
            Output output = outname.endsWith(".zip") ? new ZipFileOutput( outname ) : new FileOutput( outname );

            System.out.println("Generating from '" + args[offset+2] + "', to '" + outname + "', target '" + target + "'");

            Generator g = new Generator( target );
            g.validate( xmlReader );

            xmlReader = new InputStreamReader( new FileInputStream( args[offset+2] ), "UTF-8");

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

            g.generate( pkg, xmlReader, output );

            output.finish();
        }
        catch (GeneratorException e) {
            if (e.isWarningOnly()) {
                System.out.println( e );
            }
            else throw e;
        }
    }


    private static final void usage() {
        System.out.println("usage: java " + Main.class + " [OPTIONS] {oracle|mysql|gae} PACKAGE INPUT_XML {OUTPUT_DIR|OUTPUT_ZIP_FILE.zip}");
        System.out.println("OPTIONS:");
        System.out.println("\t-g FILE_TYPES\tor --generate FILE_TYPES");
        System.out.println("\t\tgenerates only specified types");
        System.out.println("\t\tFILE_TYPES is a comma separated list of file types:");
        System.out.println("\t\t\tdto - the DTO files");
        System.out.println("\t\t\tdao - the DAO files");
        System.out.println("\t\t\tdao_impl - the DAO implementation files");
        System.out.println("\t\t\tfactory - the factory file");
        System.out.println("\t\t\tfactory_impl - the factory implementation file");
        System.out.println("\t\t\tsql_create - the SQL create file");
        System.out.println("\t\t\tsql_drop - the SQL drop file");
        System.out.println("\t\t\tdto_impl - the DTO implementation files (GAE only)");
        System.out.println("\t\t\tdto_gwt_serializer - the GWT custom serializer of DTOs files");
        System.out.println("\n\t-s \tor --generate-dto-gwt-serializer");
        System.out.println("\t\tgenerates GWT customs serialzier for DTOs");
    }
}
