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

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;


/**
 * This is standard output into filesystem.
 * The directories are automatically created if not exist.
 */
public class FileOutput implements Output {
    
    private File root;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public FileOutput() {
        this( new File("."));
    }

    public FileOutput( String root ) {
        this( new File( root ));
    }

    public FileOutput( File root ) {
        this.root = root;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////


    /**
     * Adds a XSLT result.
     */
    public Result addResult( String resultName ) throws IOException {
        OutputStreamWriter osw = new OutputStreamWriter( addStream( resultName ), "UTF-8");

        return new StreamResult( osw );
    }


    /**
     * Adds a plain stream.
     */
    public OutputStream addStream( String resultName ) throws IOException {
        File file = new File( root, resultName );

        if (!file.exists()) {
            File parent = file.getParentFile();

            if (!parent.exists()) parent.mkdirs();
        }

        return new FileOutputStream( file );
    }


    /**
     * Finishes output.
     */
    public void finish() throws IOException {
    }

}

