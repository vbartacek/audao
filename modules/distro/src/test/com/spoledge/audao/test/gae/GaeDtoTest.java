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
package com.spoledge.audao.test.gae;

import java.util.Arrays;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;

import com.spoledge.audao.test.AbstractTest;

import com.spoledge.audao.test.gae.dto.*;


public class GaeDtoTest extends AbstractTest {

    private GaeUtil gae = new GaeUtil();

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
    // Tests - General
    ////////////////////////////////////////////////////////////////////////////

    @Test
    public void testGeneralKeyIncomplete() {
        assertFalse( "simple keyIncomplete != keyIncomplete",
            new Entity( "MyEntity" ).getKey().equals( new Entity( "MyEntity" ).getKey()));
    }

    @Test
    public void testGeneralKeyIncompleteIdentity() {
        Key key = new Entity( "MyEntity" ).getKey();
        assertEquals( "simple identity keyIncomplete == keyIncomplete", key, key );
    }

    @Test
    public void testGeneralKeyComplete() {
        assertEquals( "simple keyComplete == keyComplete",
            KeyFactory.createKey( "MyEntity", 101L ),
            KeyFactory.createKey( "MyEntity", 101L ));
    }

    @Test
    public void testGeneralUserNoGmailNoUserid() {
        assertEquals( "no-gmail no-userid",
            new User( "audao@spoledge.com", "spoledge.com" ),
            new User( "audao@spoledge.com", "spoledge.com" ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Equals Lists
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEqualsListString() {
        GaeGqlList a = new GaeGqlList();
        a.setStringType( Arrays.asList( "0", "1", "2" ));

        GaeGqlList a2 = new GaeGqlList();
        a2.setStringType( Arrays.asList( "0", "1", "2" ));

        GaeGqlList b = new GaeGqlList();
        b.setStringType( Arrays.asList( "0", "2", "1" ));

        GaeGqlList b2 = new GaeGqlList();
        b2.setStringType( Arrays.asList( "0", "2", "1" ));

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new GaeGqlList()));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - hashCode
    ////////////////////////////////////////////////////////////////////////////

    @Test
    public void testHashCode() {
        assertTrue( "empty == empty", new GaeGqlList().hashCode() == new GaeGqlList().hashCode());
    }

}
