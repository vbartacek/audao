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

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;


/**
 * This is output as a zipped stream.
 */
public class ZipStreamOutput implements Output {

    private ZipOutputStream zipOutputStream;
    private ZipEntry zipEntry;
    private OutputStreamWriter streamWriter;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public ZipStreamOutput( OutputStream os ) throws IOException {
        this( new ZipOutputStream( os ));
    }

    public ZipStreamOutput( ZipOutputStream zos ) throws IOException {
        this.zipOutputStream = zos;
        this.streamWriter = new OutputStreamWriter( zos, "UTF-8");
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////


    /**
     * Adds a XSLT result.
     */
    public Result addResult( String resultName ) throws IOException {
        newEntry( resultName );

        return new StreamResult( streamWriter );
    }


    /**
     * Adds a plain stream.
     */
    public OutputStream addStream( String resultName ) throws IOException {
        newEntry( resultName );

        return zipOutputStream;
    }


    /**
     * Finishes output.
     */
    public void finish() throws IOException {
        if (zipEntry != null) {
            streamWriter.flush();
            zipOutputStream.closeEntry();
        }

        zipOutputStream.finish();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private void newEntry( String resultName ) throws IOException {
        if (zipEntry != null) {
            streamWriter.flush();
            zipOutputStream.closeEntry();
        }

        zipEntry = new ZipEntry( resultName );
        zipOutputStream.putNextEntry( zipEntry );
    }

}

