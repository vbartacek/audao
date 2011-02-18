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

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Query;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;


public class GqlDynamicTest extends AbstractSelectDynamicTest {

    private GqlDynamic gqld;


    @Before
    public void setUp() {
        super.setUp();
        gqld = new GqlDynamic();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGParserGeneral03() {
        test( 1, "SELECT * FROM 'Employee' WHERE fullName = 'Vaclav Bartacek'" );
        test( 1, "SELECT * FROM com.foo.Employee" );
        test( 0, "SELECT * FROM 'Order'" );
        test( 0, "SELECT * FROM 'Order' WHERE 'limit'=1" );
        test( 1, "SELECT * FROM Employee WHERE 'limit'=1" );
        test( 1, "SELECT * FROM Employee WHERE 'com.foo'=true" );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Iterable<Entity> executeQuery( String gql, Object... params) {
        Query q = gqld.parseQuery( gql, params );

        return ds.prepare( q ).asIterable( gqld.getFetchOptions());
    }

}
