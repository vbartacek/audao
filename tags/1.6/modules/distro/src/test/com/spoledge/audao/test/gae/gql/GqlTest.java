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
package com.spoledge.audao.test.gae.gql;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.parser.gql.GqlDynamic;

import com.spoledge.audao.test.AbstractTest;
import com.spoledge.audao.test.gae.GaeUtilRaw;


public class GqlTest extends AbstractTest {

    private GaeUtilRaw gae = new GaeUtilRaw();


    @Before
    public void setUp() {
        super.setUp();
        gae.setUp();
    }


    @After
    public void tearDown() {
        gae.tearDown();
        super.tearDown();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - reference tests - everything you would like to know about GAE API
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Just test that the classpath contains all needed classes.
     */
    @Test 
    public void testGql() throws Exception {
        new GqlDynamic().parseQuery( "SELECT * FROM Test WHERE test = 'test' LIMIT 1" );
    }

}
