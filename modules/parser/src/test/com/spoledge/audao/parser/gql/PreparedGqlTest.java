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

import java.util.Arrays;
import java.util.List;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

public class PreparedGqlTest extends AbstractDynamicTest {

    @Before
    public void setUp() {
        super.setUp();
    }

    @After
    public void tearDown() {
        super.tearDown();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testPrepared() {
        GqlExtDynamic gqlExt = new GqlExtDynamic( ds );
        PreparedGql pq = gqlExt.prepare( "SELECT cos(:1*3.1415/180) as 'cos' FROM dual");
        testProp( first( pq.executeQuery( 30 )), "cos", Math.cos( 30 * 3.1415/180 ));
        testProp( first( pq.executeQuery( 60 )), "cos", Math.cos( 60 * 3.1415/180 ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private Entity first( Iterable<Entity> iterable ) {
        return iterable.iterator().next();
    }


    private void testProp( Entity ent, String propName, Object expectedVal ) {
        assertEquals( "property " + propName, expectedVal, ent.getProperty( propName ));
    }

}
