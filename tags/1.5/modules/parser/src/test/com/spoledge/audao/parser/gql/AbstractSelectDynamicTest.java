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

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.GeoPt;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;

import com.google.appengine.api.users.User;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;
import static com.google.appengine.api.datastore.FetchOptions.Builder.*;


public abstract class AbstractSelectDynamicTest extends AbstractDynamicTest {
    private static final SimpleDateFormat FMT_DATETIME = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat FMT_DATE = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat FMT_TIME = new SimpleDateFormat("HH:mm:ss");


    @Before
    public void setUp() {
        super.setUp();
        establishEntities();
    }


    @After
    public void tearDown() {
        super.tearDown();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGeneral01() {
        Entity ent = test( 3, "SELECT * FROM Employee" ).iterator().next();
        assertNotNull( "keys only", ent.getProperty("fullName"));
    }

    @Test 
    public void testGeneral02() {
        Entity ent = test( 3, "SELECT __key__ FROM Employee" ).iterator().next();
        assertNull( "keys only", ent.getProperty("fullName"));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions - Simple Equality
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondEquality01() {
        test( 0, "SELECT * FROM Employee WHERE fullName = 'Vaclav'" );
        test( 1, "SELECT * FROM Employee WHERE fullName = 'Vaclav Bartacek'" );
        test( 0, "SELECT * FROM Employee WHERE fullName = :1", "Vaclav" );
        test( 1, "SELECT * FROM Employee WHERE fullName = :1", "Vaclav Bartacek" );
    }

    @Test 
    public void testCondEquality02() {
        test( 0, "SELECT * FROM Employee WHERE employeeNumber = 0" );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = 1" );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = 2" );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = 3" );
        test( 0, "SELECT * FROM Employee WHERE employeeNumber = :1", 0 );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = :1", 1 );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = :1", 2 );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = :1", 3 );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = :1", 1L );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = :1", 2L );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber = :1", 3L );
    }

    @Test 
    public void testCondEquality03() {
        test( 0, "SELECT * FROM Employee WHERE coef = 0" );
        test( 0, "SELECT * FROM Employee WHERE coef = 0.1" );
        test( 1, "SELECT * FROM Employee WHERE coef = 0.9" );
        test( 1, "SELECT * FROM Employee WHERE coef = 0.95" );
        test( 1, "SELECT * FROM Employee WHERE coef = 1.0" );
        test( 0, "SELECT * FROM Employee WHERE coef = :1", 0.1 );
        test( 1, "SELECT * FROM Employee WHERE coef = :1", 0.9 );
        test( 1, "SELECT * FROM Employee WHERE coef = :1", 0.95 );
        test( 1, "SELECT * FROM Employee WHERE coef = :1", 1.0 );
    }

    @Test 
    public void testCondEquality04() {
        test( 0, "SELECT * FROM Employee WHERE signedDeclaration = 'true'" );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration = true" );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration = false" );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration = null" );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration = :1", true );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration = :1", false );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration = :1", null );
    }

    @Test 
    public void testCondEquality05() {
        test( 0, "SELECT * FROM Employee WHERE signedDate = DATE(2010, 1, 24)" );
        test( 1, "SELECT * FROM Employee WHERE signedDate = DATE(2010, 1, 25)" );
        test( 1, "SELECT * FROM Employee WHERE signedDate = DATE(2010, 1, 26)" );
        test( 0, "SELECT * FROM Employee WHERE signedDate = DATE(:1, :2, :3)", 2010, 1, 24 );
        test( 1, "SELECT * FROM Employee WHERE signedDate = DATE(:1, :2, :3)", 2010, 1, 25 );
        test( 1, "SELECT * FROM Employee WHERE signedDate = DATE(:1, :2, :3)", 2010, 1, 26 );
        test( 0, "SELECT * FROM Employee WHERE signedDate = :1", date("2010-01-24"));
        test( 1, "SELECT * FROM Employee WHERE signedDate = :1", date("2010-01-25"));
        test( 1, "SELECT * FROM Employee WHERE signedDate = :1", date("2010-01-26"));
    }

    @Test 
    public void testCondEquality06() {
        test( 0, "SELECT * FROM Employee WHERE lastModified = DATETIME(2010, 1, 27, 8, 30, 0)" );
        test( 1, "SELECT * FROM Employee WHERE lastModified = DATETIME(2010, 1, 27, 8, 30, 1)" );
        test( 1, "SELECT * FROM Employee WHERE lastModified = DATETIME(2010, 1, 27, 8, 30, 2)" );
        test( 1, "SELECT * FROM Employee WHERE lastModified = DATETIME(2010, 1, 27, 8, 30, 3)" );
        test( 0, "SELECT * FROM Employee WHERE lastModified = DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 0 );
        test( 1, "SELECT * FROM Employee WHERE lastModified = DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 1 );
        test( 1, "SELECT * FROM Employee WHERE lastModified = DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 2 );
        test( 1, "SELECT * FROM Employee WHERE lastModified = DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 3 );
        test( 0, "SELECT * FROM Employee WHERE lastModified = :1", datetime("2010-01-27 08:30:00"));
        test( 1, "SELECT * FROM Employee WHERE lastModified = :1", datetime("2010-01-27 08:30:01"));
        test( 1, "SELECT * FROM Employee WHERE lastModified = :1", datetime("2010-01-27 08:30:02"));
        test( 1, "SELECT * FROM Employee WHERE lastModified = :1", datetime("2010-01-27 08:30:03"));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions - Simple Inequality
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondInequality01() {
        test( 3, "SELECT * FROM Employee WHERE fullName != 'Vaclav'" );
        test( 2, "SELECT * FROM Employee WHERE fullName != 'Vaclav Bartacek'" );
        test( 3, "SELECT * FROM Employee WHERE fullName != null" );
        test( 3, "SELECT * FROM Employee WHERE fullName != :1", "Vaclav" );
        test( 2, "SELECT * FROM Employee WHERE fullName != :1", "Vaclav Bartacek" );
        test( 3, "SELECT * FROM Employee WHERE fullName != :1", null );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions - Simple
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondSimple01() {
        test( 0, "SELECT * FROM Employee WHERE fullName > 'Vaclav Bartacek'" );
        test( 2, "SELECT * FROM Employee WHERE fullName < 'Vaclav Bartacek'" );
        test( 1, "SELECT * FROM Employee WHERE fullName >= 'Vaclav Bartacek'" );
        test( 3, "SELECT * FROM Employee WHERE fullName <= 'Vaclav Bartacek'" );
        test( 0, "SELECT * FROM Employee WHERE fullName > :1", "Vaclav Bartacek" );
        test( 2, "SELECT * FROM Employee WHERE fullName < :1", "Vaclav Bartacek" );
        test( 1, "SELECT * FROM Employee WHERE fullName >= :1", "Vaclav Bartacek" );
        test( 3, "SELECT * FROM Employee WHERE fullName <= :1", "Vaclav Bartacek" );
    }

    @Test 
    public void testCondSimple02() {
        test( 0, "SELECT * FROM Employee WHERE employeeNumber > 3" );
        test( 2, "SELECT * FROM Employee WHERE employeeNumber < 3" );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber >= 3" );
        test( 3, "SELECT * FROM Employee WHERE employeeNumber <= 3" );
        test( 0, "SELECT * FROM Employee WHERE employeeNumber > :1", 3 );
        test( 2, "SELECT * FROM Employee WHERE employeeNumber < :1", 3 );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber >= :1", 3 );
        test( 3, "SELECT * FROM Employee WHERE employeeNumber <= :1", 3 );
    }

    @Test 
    public void testCondSimple03() {
        test( 0, "SELECT * FROM Employee WHERE coef > 1.0" );
        test( 2, "SELECT * FROM Employee WHERE coef < 1.0" );
        test( 1, "SELECT * FROM Employee WHERE coef >= 1.0" );
        test( 3, "SELECT * FROM Employee WHERE coef <= 1.0" );
        test( 0, "SELECT * FROM Employee WHERE coef > :1", 1.0 );
        test( 2, "SELECT * FROM Employee WHERE coef < :1", 1.0 );
        test( 1, "SELECT * FROM Employee WHERE coef >= :1", 1.0 );
        test( 3, "SELECT * FROM Employee WHERE coef <= :1", 1.0 );
    }

    @Test 
    public void testCondSimple04() {
        test( 0, "SELECT * FROM Employee WHERE signedDeclaration > true" );
        test( 2, "SELECT * FROM Employee WHERE signedDeclaration < true" );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration >= true" );
        test( 3, "SELECT * FROM Employee WHERE signedDeclaration <= true" );
        test( 0, "SELECT * FROM Employee WHERE signedDeclaration > :1", true );
        test( 2, "SELECT * FROM Employee WHERE signedDeclaration < :1", true );
        test( 1, "SELECT * FROM Employee WHERE signedDeclaration >= :1", true );
        test( 3, "SELECT * FROM Employee WHERE signedDeclaration <= :1", true );
    }

    @Test 
    public void testCondSimple05() {
        test( 0, "SELECT * FROM Employee WHERE signedDate > DATE(2010, 1, 26)" );
        test( 2, "SELECT * FROM Employee WHERE signedDate < DATE(2010, 1, 26)" );
        test( 1, "SELECT * FROM Employee WHERE signedDate >= DATE(2010, 1, 26)" );
        test( 3, "SELECT * FROM Employee WHERE signedDate <= DATE(2010, 1, 26)" );
        test( 0, "SELECT * FROM Employee WHERE signedDate > DATE(:1, :2, :3)", 2010, 1, 26 );
        test( 2, "SELECT * FROM Employee WHERE signedDate < DATE(:1, :2, :3)", 2010, 1, 26 );
        test( 1, "SELECT * FROM Employee WHERE signedDate >= DATE(:1, :2, :3)", 2010, 1, 26 );
        test( 3, "SELECT * FROM Employee WHERE signedDate <= DATE(:1, :2, :3)", 2010, 1, 26 );
        test( 0, "SELECT * FROM Employee WHERE signedDate > :1", date("2010-01-26"));
        test( 2, "SELECT * FROM Employee WHERE signedDate < :1", date("2010-01-26"));
        test( 1, "SELECT * FROM Employee WHERE signedDate >= :1", date("2010-01-26"));
        test( 3, "SELECT * FROM Employee WHERE signedDate <= :1", date("2010-01-26"));
    }

    @Test 
    public void testCondSimple06() {
        test( 0, "SELECT * FROM Employee WHERE lastModified > DATETIME(2010, 1, 27, 8, 30, 3)" );
        test( 2, "SELECT * FROM Employee WHERE lastModified < DATETIME(2010, 1, 27, 8, 30, 3)" );
        test( 1, "SELECT * FROM Employee WHERE lastModified >= DATETIME(2010, 1, 27, 8, 30, 3)" );
        test( 3, "SELECT * FROM Employee WHERE lastModified <= DATETIME(2010, 1, 27, 8, 30, 3)" );
        test( 0, "SELECT * FROM Employee WHERE lastModified > DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 3 );
        test( 2, "SELECT * FROM Employee WHERE lastModified < DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 3 );
        test( 1, "SELECT * FROM Employee WHERE lastModified >= DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 3 );
        test( 3, "SELECT * FROM Employee WHERE lastModified <= DATETIME(:1, :2, :3, :4, :5, :6)", 2010, 1, 27, 8, 30, 3 );
        test( 0, "SELECT * FROM Employee WHERE lastModified > :1", datetime("2010-01-27 08:30:03"));
        test( 2, "SELECT * FROM Employee WHERE lastModified < :1", datetime("2010-01-27 08:30:03"));
        test( 1, "SELECT * FROM Employee WHERE lastModified >= :1", datetime("2010-01-27 08:30:03"));
        test( 3, "SELECT * FROM Employee WHERE lastModified <= :1", datetime("2010-01-27 08:30:03"));
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions on keys
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondKey01() {
        String keyJ = KeyFactory.createKeyString( "Employee", "john" );
        String key = KeyFactory.createKeyString( "Employee", "vaclav" );

        test( 0, "SELECT * FROM Employee WHERE __key__ = '" + keyJ + "'" );
        test( 1, "SELECT * FROM Employee WHERE __key__ = '" + key + "'" );
        test( 0, "SELECT * FROM Employee WHERE __key__ = :1", keyJ );
        test( 1, "SELECT * FROM Employee WHERE __key__ = :1", key );
        test( 0, "SELECT * FROM Employee WHERE __key__ = :1", KeyFactory.createKey("Employee", "john" ));
        test( 1, "SELECT * FROM Employee WHERE __key__ = :1", KeyFactory.createKey("Employee", "vaclav" ));
    }

    @Test 
    public void testCondKey02() {
        String keyJ = KeyFactory.createKeyString( "Employee", "john" );
        String key = KeyFactory.createKeyString( "Employee", "vaclav" );

        test( 0, "SELECT * FROM Employee WHERE __key__ = KEY('" + keyJ + "')" );
        test( 1, "SELECT * FROM Employee WHERE __key__ = KEY('" + key + "')" );
        test( 0, "SELECT * FROM Employee WHERE __key__ = KEY(:1)", keyJ );
        test( 1, "SELECT * FROM Employee WHERE __key__ = KEY(:1)", key );
    }

    @Test 
    public void testCondKey03() {
        test( 0, "SELECT * FROM Employee WHERE __key__ = KEY('Employee', 'john')" );
        test( 1, "SELECT * FROM Employee WHERE __key__ = KEY('Employee', 'vaclav')" );
        test( 0, "SELECT * FROM Employee WHERE __key__ = KEY('Employee', :1)", "john" );
        test( 1, "SELECT * FROM Employee WHERE __key__ = KEY('Employee', :1)", "vaclav" );
    }

    @Test 
    public void testCondKey04() {
        test( 0, "SELECT * FROM Preference WHERE __key__ = KEY('Employee', 'john', 'Preference', 1)" );
        test( 0, "SELECT * FROM Preference WHERE __key__ = KEY('Employee', 'vaclav', 'Preference', 4)" );
        test( 1, "SELECT * FROM Preference WHERE __key__ = KEY('Employee', 'vaclav', 'Preference', 1)" );
        test( 0, "SELECT * FROM Preference WHERE __key__ = KEY('Employee', :1, 'Preference', :2)", "john", 1);
        test( 0, "SELECT * FROM Preference WHERE __key__ = KEY('Employee', :1, 'Preference', :2)", "vaclav", 4);
        test( 1, "SELECT * FROM Preference WHERE __key__ = KEY('Employee', :1, 'Preference', :2)", "vaclav", 1);
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions on ancestors
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondAncestor01() {
        test( 0, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', 'john')" );
        test( 3, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', 'vaclav')" );
        test( 0, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', :1)", "john" );
        test( 3, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', :1)", "vaclav" );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions lists
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondList01() {
        test( 1, "SELECT * FROM Employee WHERE pets=null");
        test( 2, "SELECT * FROM Employee WHERE pets='cat'");
        test( 1, "SELECT * FROM Employee WHERE pets='cat' AND pets='mouse'");

        test( 1, "SELECT * FROM Employee WHERE pets=:1", null);
        test( 2, "SELECT * FROM Employee WHERE pets=:1", "cat");
        test( 1, "SELECT * FROM Employee WHERE pets=:1 AND pets=:2", "cat", "mouse");
    }


    @Test 
    public void testCondList02() {
        test( 1, "SELECT * FROM Employee WHERE pets=:1", new ArrayList());
        test( 2, "SELECT * FROM Employee WHERE pets=:1", Arrays.asList("cat"));
        test( 2, "SELECT * FROM Employee WHERE pets=:1", Arrays.asList("cat","dog"));
        test( 1, "SELECT * FROM Employee WHERE pets=:1", Arrays.asList("cat","mouse"));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Conditions - IN
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondOperIN01() {
        test( 0, "SELECT * FROM Employee WHERE fullName IN ('Vaclav')" );
        test( 1, "SELECT * FROM Employee WHERE fullName IN ('Vaclav Bartacek')" );
        test( 2, "SELECT * FROM Employee WHERE fullName IN ('Vaclav Bartacek','Vaclav Balcar')" );
        test( 0, "SELECT * FROM Employee WHERE fullName IN (:1)", "Vaclav" );
        test( 1, "SELECT * FROM Employee WHERE fullName IN (:1)", "Vaclav Bartacek" );
        test( 2, "SELECT * FROM Employee WHERE fullName IN (:1, :2)", "Vaclav Bartacek", "Vaclav Balcar" );
    }


    @Test 
    public void testCondOperIN02() {
        test( 0, "SELECT * FROM Employee WHERE fullName IN :1", Arrays.asList("Vaclav") );
        test( 1, "SELECT * FROM Employee WHERE fullName IN :1", Arrays.asList("Vaclav Bartacek") );
        test( 2, "SELECT * FROM Employee WHERE fullName IN :1", Arrays.asList("Vaclav Bartacek", "Vaclav Balcar") );
    }


    @Test 
    public void testCondOperIN03() {
        String key = KeyFactory.createKeyString( "Employee", "vaclav" );
        String keyJ = KeyFactory.createKeyString( "Employee", "john" );

        test( 1, "SELECT * FROM Employee WHERE __key__ IN ('" + key + "')");
        test( 0, "SELECT * FROM Employee WHERE __key__ IN ('" + keyJ + "')");

        test( 1, "SELECT * FROM Employee WHERE __key__ IN (KEY('Employee', :1))", "vaclav" );
        test( 0, "SELECT * FROM Employee WHERE __key__ IN (KEY('Employee', :1))", "john" );

        test( 2, "SELECT * FROM Employee WHERE __key__ IN (KEY('Employee', :1),KEY('Employee', :2))", "vaclav", "vasek" );

        test( 2, "SELECT * FROM Employee WHERE __key__ IN :1", Arrays.asList( KeyFactory.createKey("Employee", "vaclav"), KeyFactory.createKey("Employee", "vasek")));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Complex Conditions
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCondComplex01() {
        test( 0, "SELECT * FROM Employee WHERE employeeNumber=1 AND signedDeclaration=true AND coef > 1.0" );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber=1 AND signedDeclaration=true AND coef < 1.0" );
        test( 0, "SELECT * FROM Employee WHERE employeeNumber=:1 AND signedDeclaration=:2 AND coef > :3", 1, true, 1.0 );
        test( 1, "SELECT * FROM Employee WHERE employeeNumber=:1 AND signedDeclaration=:2 AND coef < :3", 1, true, 1.0 );
    }

    @Test 
    public void testCondComplex02() {
        test( 0, "SELECT * FROM Preference WHERE name='background' AND ANCESTOR IS KEY('Employee', 'vaclav')" );
        test( 1, "SELECT * FROM Preference WHERE name='color' AND ANCESTOR IS KEY('Employee', 'vaclav')" );
        test( 1, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', 'vaclav') AND name='color'" );
        test( 0, "SELECT * FROM Preference WHERE name=:1 AND ANCESTOR IS KEY('Employee', :2)", "background", "vaclav" );
        test( 1, "SELECT * FROM Preference WHERE name=:1 AND ANCESTOR IS KEY('Employee', :2)", "color", "vaclav" );
        test( 1, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', 'vaclav') AND name='color'" );
        test( 1, "SELECT * FROM Preference WHERE ANCESTOR IS KEY('Employee', :1) AND name=:2", "vaclav", "color" );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Order By
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testOrderBy01() {
        Entity ent = test( 3, "SELECT * FROM Employee ORDER BY employeeNumber" ).iterator().next();
        assertEquals( "first employee", 1L, ent.getProperty("employeeNumber"));
    }

    @Test 
    public void testOrderBy02() {
        Entity ent = test( 3, "SELECT * FROM Employee ORDER BY employeeNumber ASC" ).iterator().next();
        assertEquals( "first employee", 1L, ent.getProperty("employeeNumber"));
    }

    @Test 
    public void testOrderBy03() {
        Entity ent = test( 3, "SELECT * FROM Employee ORDER BY employeeNumber DESC" ).iterator().next();
        assertEquals( "last employee", 3L, ent.getProperty("employeeNumber"));
    }

    @Test 
    public void testOrderBy04() {
        Entity ent = test( 6, "SELECT * FROM Preference ORDER BY name, value" ).iterator().next();
        assertEquals( "first pref", "blue", ent.getProperty("value"));
    }

    @Test 
    public void testOrderBy05() {
        Entity ent = test( 6, "SELECT * FROM Preference ORDER BY name DESC, value ASC" ).iterator().next();
        assertEquals( "last pref type first val", date("2009-12-01"), ent.getProperty("value"));
    }

    @Test 
    public void testOrderBy06() {
        Entity ent = test( 6, "SELECT * FROM Preference ORDER BY __key__" ).iterator().next();
        assertEquals( "first pref by key", "blue", ent.getProperty("value"));

        ent = test( 6, "SELECT * FROM Preference ORDER BY __key__ DESC" ).iterator().next();
        assertEquals( "last pref by key", date("2009-12-01"), ent.getProperty("value"));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Offset, Limit
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testOffsetLimit01() {
        test( 3, "SELECT * FROM Employee OFFSET 0" );
        test( 2, "SELECT * FROM Employee OFFSET 1" );
        test( 1, "SELECT * FROM Employee OFFSET 2" );
        test( 0, "SELECT * FROM Employee OFFSET 3" );
    }

    @Test 
    public void testOffsetLimit02() {
        test( 3, "SELECT * FROM Employee LIMIT 4" );
        test( 3, "SELECT * FROM Employee LIMIT 3" );
        test( 2, "SELECT * FROM Employee LIMIT 2" );
        test( 1, "SELECT * FROM Employee LIMIT 1" );
    }

    @Test 
    public void testOffsetLimit03() {
        test( 2, "SELECT * FROM Employee LIMIT 1, 3" );
        test( 2, "SELECT * FROM Employee LIMIT 1, 2" );
        test( 1, "SELECT * FROM Employee LIMIT 1, 1" );
        test( 1, "SELECT * FROM Employee LIMIT 2, 2" );
        test( 1, "SELECT * FROM Employee LIMIT 2, 1" );
        test( 0, "SELECT * FROM Employee LIMIT 3, 3" );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Google specific classes
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGoogle01() {
        test( 0, "SELECT * FROM Employee WHERE gaeUser = USER('john@foo.cz')" );
        test( 1, "SELECT * FROM Employee WHERE gaeUser = USER('vaclav@foo.cz')" );
        test( 0, "SELECT * FROM Employee WHERE gaeUser = USER(:1)", "john@foo.cz" );
        test( 1, "SELECT * FROM Employee WHERE gaeUser = USER(:1)", "vaclav@foo.cz" );
    }

    @Test 
    public void testGoogle02() {
        test( 0, "SELECT * FROM Employee WHERE location = GEOPT(50, 15.0)" );
        test( 1, "SELECT * FROM Employee WHERE location = GEOPT(50, 15.1)" );
        test( 3, "SELECT * FROM Employee WHERE location >= GEOPT(50, 15.1)" );
        test( 0, "SELECT * FROM Employee WHERE location = GEOPT(:1, :2)", 50f, 15.0f);
        test( 1, "SELECT * FROM Employee WHERE location = GEOPT(:1, :2)", 50f, 15.1f);
        test( 3, "SELECT * FROM Employee WHERE location >= GEOPT(:1, :2)", 50f, 15.1f);
        test( 0, "SELECT * FROM Employee WHERE location = GEOPT(:1, :2)", 50, 15.0);
        test( 1, "SELECT * FROM Employee WHERE location = GEOPT(:1, :2)", 50, 15.1);
        test( 3, "SELECT * FROM Employee WHERE location >= GEOPT(:1, :2)", 50, 15.1);
    }

    @Test 
    public void testGoogle03() {
        test( 1, "SELECT * FROM Employee WHERE location IN (GEOPT(50, 15.1))" );
        test( 1, "SELECT * FROM Employee WHERE gaeUser IN (USER(:1))", "vaclav@foo.cz" );
    }


    @Test 
    public void testGoogle04() {
        test( 0, "SELECT * FROM Employee WHERE managerKey = KEY('Employee', 'vaclav')" );
        test( 2, "SELECT * FROM Employee WHERE managerKey = KEY('Employee', 'vasek')" );
        test( 2, "SELECT * FROM Employee WHERE managerKey IN (KEY('Employee', 'vasek'), KEY('Employee', 'john'))" );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected abstract Iterable<Entity> executeQuery( String gql, Object... params);


    protected Iterable<Entity> test( int expectedCount, String gql, Object... params) {
        log.debug("TEST " + gql);

        Iterable<Entity> ret = null;

        try {
            ret = executeQuery( gql, params );
        }
        catch (RuntimeException e) {
            log.error("test(): gql=" + gql, e );
            throw e;
        }

        int count = 0;
        for (Entity ent : ret) count++;

        assertEquals( gql, expectedCount, count );

        return ret;
    }


    protected void establishEntities() {
        Entity ent = new Entity( KeyFactory.createKey( "com.foo.Employee", "john"));
        ds.put( ent );

        ent = new Entity( KeyFactory.createKey( "Employee", "vasek"));
        ent.setProperty("fullName", "Vaclav Balcar");
        ent.setProperty("position", "developer");
        ent.setProperty("employeeNumber", 1);
        ent.setProperty("coef", 0.9 );
        ent.setProperty("signedDeclaration", true );
        ent.setProperty("signedDate", date("2010-01-25"));
        ent.setProperty("lastModified", datetime("2010-01-27 08:30:01"));
        ent.setProperty("managerKey", null );
        ent.setProperty("gaeUser", new User("vasek@foo.cz", "gmail.com"));
        ent.setProperty("location", new GeoPt( 50f, 15.1f));
        ent.setProperty("pets", Arrays.asList("mouse", "cat", "dog"));
        ent.setProperty("limit", 1 );
        ent.setProperty("com.foo", true );

        ds.put( ent );
        Key keyVasek = ent.getKey();

        ent = new Entity( KeyFactory.createKey( "Employee", "tomas"));
        ent.setProperty("fullName", "Tomas Straka");
        ent.setProperty("position", "developer");
        ent.setProperty("employeeNumber", new Integer(2));
        ent.setProperty("coef", 0.95 );
        ent.setProperty("signedDeclaration", false );
        ent.setProperty("signedDate", date("2010-01-26"));
        ent.setProperty("lastModified", datetime("2010-01-27 08:30:02"));
        ent.setProperty("managerKey", keyVasek );
        ent.setProperty("gaeUser", new User("tomas@foo.cz", "gmail.com"));
        ent.setProperty("location", new GeoPt( 50f, 15.2f));
        ent.setProperty("pets", null );

        ds.put( ent );
        Key keyTomas = ent.getKey();

        ent = new Entity( KeyFactory.createKey( "Employee", "vaclav"));
        ent.setProperty("fullName", "Vaclav Bartacek");
        ent.setProperty("position", "developer");
        ent.setProperty("employeeNumber", new Long(3));
        ent.setProperty("coef", 1d );
        ent.setProperty("signedDeclaration", null );
        ent.setProperty("signedDate", null );
        ent.setProperty("lastModified", datetime("2010-01-27 08:30:03"));
        ent.setProperty("gaeUser", new User("vaclav@foo.cz", "gmail.com"));
        ent.setProperty("managerKey", keyVasek );
        ent.setProperty("location", new GeoPt( 50f, 15.3f));
        ent.setProperty("pets", Arrays.asList("cat", "dog"));

        ds.put( ent );
        Key keyVaclav = ent.getKey();

        ent = new Entity( KeyFactory.createKey( keyVasek, "Preference", 1 ));
        ent.setProperty( "name", "color" );
        ent.setProperty( "value", "blue" );

        ds.put( ent );

        ent = new Entity( KeyFactory.createKey( keyVasek, "Preference", 2 ));
        ent.setProperty( "name", "limit" );
        ent.setProperty( "value", 10 );

        ds.put( ent );

        ent = new Entity( KeyFactory.createKey( keyVasek, "Preference", 3 ));
        ent.setProperty( "name", "minDate" );
        ent.setProperty( "value", date("2009-12-01"));

        ds.put( ent );


        ent = new Entity( KeyFactory.createKey( keyVaclav, "Preference", 1 ));
        ent.setProperty( "name", "color" );
        ent.setProperty( "value", "blue" );

        ds.put( ent );

        ent = new Entity( KeyFactory.createKey( keyVaclav, "Preference", 2 ));
        ent.setProperty( "name", "limit" );
        ent.setProperty( "value", 5 );

        ds.put( ent );

        ent = new Entity( KeyFactory.createKey( keyVaclav, "Preference", 3 ));
        ent.setProperty( "name", "minDate" );
        ent.setProperty( "value", date("2010-01-01"));

        ds.put( ent );
    }


    protected Date date( String s ) {
        return parsedate( s, FMT_DATE);
    }

    protected Date datetime( String s ) {
        return parsedate( s, FMT_DATETIME );
    }

    protected Date time( String s ) {
        return parsedate( s, FMT_TIME );
    }

    protected Date parsedate( String s, SimpleDateFormat fmt ) {
        try {
            return fmt.parse( s );
        }
        catch (ParseException e) {
            throw new RuntimeException( e );
        }
    }

}

