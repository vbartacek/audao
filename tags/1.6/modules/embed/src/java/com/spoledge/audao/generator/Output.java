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

import javax.xml.transform.Result;


/**
 * This is a general interface to hide implementation of specific output.
 */
public interface Output {

    /**
     * Adds a XSLT result.
     */
    public Result addResult( String resultName ) throws IOException;


    /**
     * Adds a plain stream.
     */
    public OutputStream addStream( String resultName ) throws IOException;


    /**
     * Finishes output.
     */
    public void finish() throws IOException;

}

