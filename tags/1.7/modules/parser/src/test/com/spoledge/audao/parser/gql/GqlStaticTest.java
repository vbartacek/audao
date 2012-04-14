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
package com.spoledge.audao.parser.gql;

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import org.antlr.runtime.RecognitionException;

import org.apache.log4j.Logger;


public class GqlStaticTest {
    private Logger log;
    private GqlStatic parser;

    @Before
    public void setUp() {
        log = Logger.getLogger( getClass());
        parser = new GqlStatic();
    }

    @Test 
    public void testXalanParams() throws RecognitionException {
        test( "userName = :user AND countFoo > :foo AND bar = 'bleble' ORDER BY userId",
            ", argUserName, argFoo", ", String, String" );
    }

    @Test 
    public void testNonXalanParams() throws RecognitionException {
        test( "userName = :user AND countFoo > :foo AND bar = 'bleble' ORDER BY userId",
            "argUserName,argFoo", "String,String" );
    }


    private void test(String gql, String argnames, String argtypes) throws RecognitionException {
        String ret = parser.parse( "", gql, argnames, argtypes );

        log.debug("|" + gql + "| ->\n" + ret );
    }

}

