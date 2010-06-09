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
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.HashSet;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DataTypeTranslator;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityTranslator;
import com.google.appengine.api.datastore.GeoPt;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.ShortBlob;
import com.google.appengine.api.datastore.Text;

import com.google.appengine.api.users.User;

import com.google.storage.onestore.v3.OnestoreEntity.EntityProto;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.db.dao.DaoException;
import com.spoledge.audao.db.dao.gae.DatastoreServiceProvider;

import com.spoledge.audao.test.gae.dao.*;

import com.spoledge.audao.test.gae.dto.*;

import com.spoledge.audao.test.AbstractTest;


public class GaeTest extends AbstractTest {

    private GaeUtil gae = new GaeUtil();

    public GaeTest() {
        com.spoledge.audao.test.gae.dao.gae.DaoFactoryImpl
            .setDatastoreServiceProvider( gae.getDatastoreServiceProvider());
    }


    @Before
    public void setUp() {
        super.setUp();
        gae.setUp();
        establishEntities();
    }


    @After
    public void tearDown() {
        gae.tearDown();
        super.tearDown();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - reference tests - everything you would like to know about GAE API
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    @SuppressWarnings("unchecked")
    public void testAPINullList() throws Exception {
        ArrayList emptyList = new ArrayList();
        ArrayList hasNullList = new ArrayList();
        List<String> hasOneItemList = Arrays.asList( "the_only_item" );
        hasNullList.add( null );

        Entity ent = new Entity("Test");
        ent.setProperty("nullProp", null);
        ent.setProperty("emptyList", emptyList);
        ent.setProperty("hasNullList", hasNullList);
        ent.setProperty("hasOneItemList", hasOneItemList);

        log.debug("ENTITY - before: " + ent);

        Key key = gae.ds.put( ent );
        ent = gae.ds.get( key );

        log.debug("ENTITY - after: " + ent);

        log.debug("count(emptyList==null)="+
        gae.ds.prepare(new Query("Test").addFilter("emptyList", Query.FilterOperator.EQUAL, null)).countEntities());
        log.debug("count(hasNullList==null)="+
        gae.ds.prepare(new Query("Test").addFilter("hasNullList", Query.FilterOperator.EQUAL, null)).countEntities());

    }


    @Test 
    public void testAPISets() throws Exception {
        HashSet<String> set = new HashSet<String>();
        set.add("first");
        set.add("last");

        Entity ent = new Entity("Test");
        ent.setProperty("set", set);

        log.debug("ENTITY (set) - before: "  + ent.getProperty("set").getClass() + " - " + ent);

        Key key = gae.ds.put( ent );
        ent = gae.ds.get( key );

        log.debug("ENTITY (set) - after: "  + ent.getProperty("set").getClass() + " - " + ent);
    }


    @Test 
    public void testAPIIN() throws Exception {
        Entity ent = new Entity("Test");
        ent.setProperty("prop", "A");
        gae.ds.put( ent );

        ent = new Entity("Test");
        ent.setProperty("prop", "B");
        gae.ds.put( ent );

        log.debug("count(prop IN ('A')=" +
            gae.ds.prepare(new Query("Test").addFilter("prop",Query.FilterOperator.IN, Arrays.asList("A"))).countEntities());

        log.debug("count(prop IN ('A','B')=" +
            gae.ds.prepare(new Query("Test").addFilter("prop",Query.FilterOperator.IN, Arrays.asList("A","B"))).countEntities());

        // This will fail
        // log.debug("count(prop IN null=" +
        //    gae.ds.prepare(new Query("Test").addFilter("prop",Query.FilterOperator.IN, null)).countEntities());
        // This will also fail
        // log.debug("count(prop IN ()=" +
        //   gae.ds.prepare(new Query("Test").addFilter("prop",Query.FilterOperator.IN, new ArrayList())).countEntities());

    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGeneral01() throws DaoException {
        GaeGeneralTest dto = new GaeGeneralTest();
        dto.setName( "Vaclav" );
        dto.setIsActive( true );
        dto.setFlags( 3 );
        dto.setShortTypeCustom( GaeGeneralTest.ShortTypeCustom.EXTRA );
        dto.setNumberNotNull( 9 );

        dto.setDescription("This is a Vaclav");
        dto.setIsCustom( true );
        dto.setShortType( GaeGeneralTest.ShortType.NORMAL );
        dto.setNumber( 7 );

        GaeGeneralTestDao dao = DaoFactory.createGaeGeneralTestDao();

        dao.insert( dto );

        assertEquals( "number > 7", 0, dao.findDynamic( "number > :1", 0, -1, 7 ).length); 
        assertEquals( "number <= 7", 1, dao.findDynamic( "number <= :1", 0, -1, 7 ).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Index Finders - Simple
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testFinderIndexNullListByOne() throws DaoException {
        GaeFinderIndexNullListDao dao = DaoFactory.createGaeFinderIndexNullListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        Number n3 = 3;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        GaeFinderIndexNullList dto = new GaeFinderIndexNullList();

        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        dto = new GaeFinderIndexNullList();
        dto.setStringType( Arrays.asList( "test2" ));
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setStringSblobType( Arrays.asList( "stest2" ));
        dto.setSblobType( Arrays.asList( n2 ));
        dto.setDtoType( Arrays.asList( dto2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));
        dto.setNativeList( Arrays.asList( o2 ));
        dto.setAnonList( Arrays.asList( o2 ));

        dao.insert( dto );

        dto = new GaeFinderIndexNullList();
        dto.setStringType( Arrays.asList( "test11" ));
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setStringSblobType( Arrays.asList( "stest11" ));
        dto.setSblobType( Arrays.asList( n11 ));
        dto.setDtoType( Arrays.asList( dto11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));
        dto.setNativeList( Arrays.asList( o11 ));
        dto.setAnonList( Arrays.asList( o11 ));

        dao.insert( dto );

        assertEquals( "string bla", 0, dao.findByStringType( "bla" ).length); 
        assertEquals( "string test", 1, dao.findByStringType( "test" ).length); 
        assertEquals( "string test2", 1, dao.findByStringType( "test2" ).length); 
        assertEquals( "string test11", 2, dao.findByStringType( "test11" ).length); 

        assertEquals( "udate bla", 0, dao.findByUdateType( date3 ).length); 
        assertEquals( "udate 1", 1, dao.findByUdateType( date1 ).length); 
        assertEquals( "udate 2", 1, dao.findByUdateType( date2 ).length); 
        assertEquals( "udate 11", 2, dao.findByUdateType( date11 ).length); 

        assertEquals( "sblob bla", 0, dao.findByStringSblobType( "sbla" ).length); 
        assertEquals( "sblob test", 1, dao.findByStringSblobType( "stest" ).length); 
        assertEquals( "sblob test2", 1, dao.findByStringSblobType( "stest2" ).length); 
        assertEquals( "sblob test11", 2, dao.findByStringSblobType( "stest11" ).length); 

        assertEquals( "nblob bla", 0, dao.findBySblobType( n3 ).length); 
        assertEquals( "nblob 1", 1, dao.findBySblobType( n1 ).length); 
        assertEquals( "nblob 2", 1, dao.findBySblobType( n2 ).length); 
        assertEquals( "nblob 11", 2, dao.findBySblobType( n11 ).length); 

        assertEquals( "dto bla", 0, dao.findByDtoType( dto3 ).length); 
        assertEquals( "dto 1", 1, dao.findByDtoType( dto1 ).length); 
        assertEquals( "dto 2", 1, dao.findByDtoType( dto2 ).length); 
        assertEquals( "dto 11", 2, dao.findByDtoType( dto11 ).length); 

        assertEquals( "key bla", 0, dao.findByKeyType( key3 ).length); 
        assertEquals( "key 1", 1, dao.findByKeyType( key1 ).length); 
        assertEquals( "key 2", 1, dao.findByKeyType( key2 ).length); 
        assertEquals( "key 11", 2, dao.findByKeyType( key11 ).length); 

        assertEquals( "geopt bla", 0, dao.findByGeoptType( geopt3 ).length); 
        assertEquals( "geopt 1", 1, dao.findByGeoptType( geopt1 ).length); 
        assertEquals( "geopt 2", 1, dao.findByGeoptType( geopt2 ).length); 
        assertEquals( "geopt 11", 2, dao.findByGeoptType( geopt11 ).length); 

        assertEquals( "user bla", 0, dao.findByUserType( user3 ).length); 
        assertEquals( "user 1", 1, dao.findByUserType( user1 ).length); 
        assertEquals( "user 2", 1, dao.findByUserType( user2 ).length); 
        assertEquals( "user 11", 2, dao.findByUserType( user11 ).length); 

        assertEquals( "native bla", 0, dao.findByNativeList( o3 ).length); 
        assertEquals( "native 1", 1, dao.findByNativeList( o1 ).length); 
        assertEquals( "native 2", 1, dao.findByNativeList( o2 ).length); 
        assertEquals( "native 11", 2, dao.findByNativeList( o11 ).length); 

        assertEquals( "anon bla", 0, dao.findByAnonList( o3 ).length); 
        assertEquals( "anon 1", 1, dao.findByAnonList( o1 ).length); 
        assertEquals( "anon 2", 1, dao.findByAnonList( o2 ).length); 
        assertEquals( "anon 11", 2, dao.findByAnonList( o11 ).length); 
    }


    @Test 
    public void testFinderIndexNullListByAll01() throws DaoException {
        GaeFinderIndexNullListDao dao = DaoFactory.createGaeFinderIndexNullListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        Number n3 = 3;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        GaeFinderIndexNullList dto = new GaeFinderIndexNullList();

        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        dto = new GaeFinderIndexNullList();
        dto.setStringType( Arrays.asList( "test2" ));
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setStringSblobType( Arrays.asList( "stest2" ));
        dto.setSblobType( Arrays.asList( n2 ));
        dto.setDtoType( Arrays.asList( dto2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));
        dto.setNativeList( Arrays.asList( o2 ));
        dto.setAnonList( Arrays.asList( o2 ));

        dao.insert( dto );

        dto = new GaeFinderIndexNullList();
        dto.setStringType( Arrays.asList( "test11" ));
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setStringSblobType( Arrays.asList( "stest11" ));
        dto.setSblobType( Arrays.asList( n11 ));
        dto.setDtoType( Arrays.asList( dto11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));
        dto.setNativeList( Arrays.asList( o11 ));
        dto.setAnonList( Arrays.asList( o11 ));

        dao.insert( dto );

        assertEquals( "string 1", 1, dao.findByStringType( Arrays.asList( "test" )).length); 
        assertEquals( "string 11", 2, dao.findByStringType( Arrays.asList( "test11" )).length); 
        assertEquals( "string 1, 2", 0, dao.findByStringType( Arrays.asList( "test", "test2" )).length); 
        assertEquals( "string 11, 1", 1, dao.findByStringType( Arrays.asList( "test11", "test" )).length); 

        assertEquals( "udate 1", 1, dao.findByUdateType( Arrays.asList( date1 )).length); 
        assertEquals( "udate 11", 2, dao.findByUdateType( Arrays.asList( date11 )).length); 
        assertEquals( "udate 1, 2", 0, dao.findByUdateType( Arrays.asList( date1, date2 )).length); 
        assertEquals( "udate 11, 1", 1, dao.findByUdateType( Arrays.asList( date11, date1 )).length); 

        assertEquals( "sblob 1", 1, dao.findByStringSblobType( Arrays.asList( "stest" )).length); 
        assertEquals( "sblob 11", 2, dao.findByStringSblobType( Arrays.asList( "stest11" )).length); 
        assertEquals( "sblob 1, 2", 0, dao.findByStringSblobType( Arrays.asList( "stest", "stest2" )).length); 
        assertEquals( "sblob 11, 1", 1, dao.findByStringSblobType( Arrays.asList( "stest11", "stest" )).length); 

        assertEquals( "nblob 1", 1, dao.findBySblobType( Arrays.asList( n1 )).length); 
        assertEquals( "nblob 11", 2, dao.findBySblobType( Arrays.asList( n11 )).length); 
        assertEquals( "nblob 1, 2", 0, dao.findBySblobType( Arrays.asList( n1, n2 )).length); 
        assertEquals( "nblob 11, 1", 1, dao.findBySblobType( Arrays.asList( n11, n1 )).length); 

        assertEquals( "dto 1", 1, dao.findByDtoType( Arrays.asList( dto1 )).length); 
        assertEquals( "dto 11", 2, dao.findByDtoType( Arrays.asList( dto11 )).length); 
        assertEquals( "dto 1, 2", 0, dao.findByDtoType( Arrays.asList( dto1, dto2 )).length); 
        assertEquals( "dto 11, 1", 1, dao.findByDtoType( Arrays.asList( dto11, dto1 )).length); 

        assertEquals( "key 1", 1, dao.findByKeyType( Arrays.asList( key1 )).length); 
        assertEquals( "key 11", 2, dao.findByKeyType( Arrays.asList( key11 )).length); 
        assertEquals( "key 1, 2", 0, dao.findByKeyType( Arrays.asList( key1, key2 )).length); 
        assertEquals( "key 11, 1", 1, dao.findByKeyType( Arrays.asList( key11, key1 )).length); 

        assertEquals( "geopt 1", 1, dao.findByGeoptType( Arrays.asList( geopt1 )).length); 
        assertEquals( "geopt 11", 2, dao.findByGeoptType( Arrays.asList( geopt11 )).length); 
        assertEquals( "geopt 1, 2", 0, dao.findByGeoptType( Arrays.asList( geopt1, geopt2 )).length); 
        assertEquals( "geopt 11, 1", 1, dao.findByGeoptType( Arrays.asList( geopt11, geopt1 )).length); 

        assertEquals( "user 1", 1, dao.findByUserType( Arrays.asList( user1 )).length); 
        assertEquals( "user 11", 2, dao.findByUserType( Arrays.asList( user11 )).length); 
        assertEquals( "user 1, 2", 0, dao.findByUserType( Arrays.asList( user1, user2 )).length); 
        assertEquals( "user 11, 1", 1, dao.findByUserType( Arrays.asList( user11, user1 )).length); 

        assertEquals( "native 1", 1, dao.findByNativeList( Arrays.asList( o1 )).length); 
        assertEquals( "native 11", 2, dao.findByNativeList( Arrays.asList( o11 )).length); 
        assertEquals( "native 1, 2", 0, dao.findByNativeList( Arrays.asList( o1, o2 )).length); 
        assertEquals( "native 11, 1", 1, dao.findByNativeList( Arrays.asList( o11, o1 )).length); 

        assertEquals( "anon 1", 1, dao.findByAnonList( Arrays.asList( o1 )).length); 
        assertEquals( "anon 11", 2, dao.findByAnonList( Arrays.asList( o11 )).length); 
        assertEquals( "anon 1, 2", 0, dao.findByAnonList( Arrays.asList( o1, o2 )).length); 
        assertEquals( "anon 11, 1", 1, dao.findByAnonList( Arrays.asList( o11, o1 )).length); 
    }


    @Test 
    public void testFinderIndexNullListByAll02() throws DaoException {
        GaeFinderIndexNullListDao dao = DaoFactory.createGaeFinderIndexNullListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        Number n3 = 3;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        // insert one non-empty object
        GaeFinderIndexNullList dto = new GaeFinderIndexNullList();
        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        List<String> lString = null;
        List<java.util.Date> lDate = null;
        List<Number> lNumber = null;
        List<GaeDto> lDto = null;
        List<Key> lKey = null;
        List<User> lUser = null;
        List lAnon = null;

        assertEquals( "string null 0", 0, dao.findByStringType( lString ).length); 
        assertEquals( "udate null 0", 0, dao.findByUdateType( lDate ).length); 
        assertEquals( "sblob null 0", 0, dao.findByStringSblobType( lString ).length); 
        assertEquals( "nblob null 0", 0, dao.findBySblobType( lNumber ).length); 
        assertEquals( "dto null 0", 0, dao.findByDtoType( lDto ).length); 
        assertEquals( "key null 0", 0, dao.findByKeyType( lKey ).length); 
        assertEquals( "user null 0", 0, dao.findByUserType( lUser ).length); 
        assertEquals( "native null 0", 0, dao.findByNativeList( lAnon ).length); 
        assertEquals( "anon null 0", 0, dao.findByAnonList( lAnon ).length); 

        lString = new ArrayList<String>();
        lDate = new ArrayList<java.util.Date>();
        lNumber = new ArrayList<Number>();
        lDto = new ArrayList<GaeDto>();
        lKey = new ArrayList<Key>();
        lUser = new ArrayList<User>();
        lAnon = new ArrayList();

        assertEquals( "string empty 0", 0, dao.findByStringType( lString ).length); 
        assertEquals( "udate empty 0", 0, dao.findByUdateType( lDate ).length); 
        assertEquals( "sblob empty 0", 0, dao.findByStringSblobType( lString ).length); 
        assertEquals( "nblob empty 0", 0, dao.findBySblobType( lNumber ).length); 
        assertEquals( "dto empty 0", 0, dao.findByDtoType( lDto ).length); 
        assertEquals( "key empty 0", 0, dao.findByKeyType( lKey ).length); 
        assertEquals( "user empty 0", 0, dao.findByUserType( lUser ).length); 
        assertEquals( "native empty 0", 0, dao.findByNativeList( lAnon ).length); 
        assertEquals( "anon empty 0", 0, dao.findByAnonList( lAnon ).length); 

        dto = new GaeFinderIndexNullList();
        dao.insert( dto );

        assertEquals( "string empty 1", 1, dao.findByStringType( lString ).length); 
        assertEquals( "udate empty 1", 1, dao.findByUdateType( lDate ).length); 
        assertEquals( "sblob empty 1", 1, dao.findByStringSblobType( lString ).length); 
        assertEquals( "nblob empty 1", 1, dao.findBySblobType( lNumber ).length); 
        assertEquals( "dto empty 1", 1, dao.findByDtoType( lDto ).length); 
        assertEquals( "key empty 1", 1, dao.findByKeyType( lKey ).length); 
        assertEquals( "user empty 1", 1, dao.findByUserType( lUser ).length); 
        assertEquals( "native empty 1", 1, dao.findByNativeList( lAnon ).length); 
        assertEquals( "anon empty 1", 1, dao.findByAnonList( lAnon ).length); 

        lString = null;
        lDate = null;
        lNumber = null;
        lDto = null;
        lKey = null;
        lUser = null;
        lAnon = null;

        assertEquals( "string null 1", 1, dao.findByStringType( lString ).length); 
        assertEquals( "udate null 1", 1, dao.findByUdateType( lDate ).length); 
        assertEquals( "sblob null 1", 1, dao.findByStringSblobType( lString ).length); 
        assertEquals( "nblob null 1", 1, dao.findBySblobType( lNumber ).length); 
        assertEquals( "dto null 1", 1, dao.findByDtoType( lDto ).length); 
        assertEquals( "key null 1", 1, dao.findByKeyType( lKey ).length); 
        assertEquals( "user null 1", 1, dao.findByUserType( lUser ).length); 
        assertEquals( "native null 1", 1, dao.findByNativeList( lAnon ).length); 
        assertEquals( "anon null 1", 1, dao.findByAnonList( lAnon ).length); 
    }



    ////////////////////////////////////////////////////////////////////////////
    // Tests - GQL - Simple
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGqlSimpleFixed() throws DaoException {
        GaeGqlSimpleDao dao = DaoFactory.createGaeGqlSimpleDao();

        GaeGqlSimple dto = new GaeGqlSimple();
        dto.setDoubleType( 4d );

        dao.insert( dto );

        dto = new GaeGqlSimple();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setStringType( "test" );
        dto.setDateType( date( "2010-02-22" ));
        dto.setTimestampType( datetime( "2010-02-22 12:53:01" ));

        dao.insert( dto );

        assertEquals( "boolean true", 1, dao.findFixedBooleanTrue().length); 
        assertEquals( "boolean false", 0, dao.findFixedBooleanFalse().length); 
        assertEquals( "boolean null", 1, dao.findFixedBooleanNull().length); 
        assertEquals( "short 1", 1, dao.findFixedShort().length); 
        assertEquals( "int 2", 1, dao.findFixedInt().length); 
        assertEquals( "long 3", 1, dao.findFixedLong().length); 

        // 4 is stored as Double, but searching for Long:
        assertEquals( "double 4", 0, dao.findFixedDouble1().length); 
        assertEquals( "double 4.0", 1, dao.findFixedDouble2().length); 
        assertEquals( "double 4.1", 1, dao.findFixedDouble3().length); 

        assertEquals( "string 'test'", 1, dao.findFixedString().length); 

        assertEquals( "date 2010-02-22", 1, dao.findFixedDate().length); 
        assertEquals( "date 2010-02-22 12:53:01", 1, dao.findFixedTimestamp().length); 
    }



    @Test 
    public void testGqlSimpleInTypeOrType() throws DaoException {
        GaeGqlSimpleDao dao = DaoFactory.createGaeGqlSimpleDao();

        GaeGqlSimple dto = new GaeGqlSimple();
        dto.setDoubleType( 4d );

        dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );
        java.sql.Date date3 = sqlDate( "2010-02-24" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );
        java.sql.Timestamp ts3 = sqlTimestamp( "2010-02-23 12:53:01" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];
        byte[] sblob3 = new byte[30];

        GaeDto gdto1 = new GaeDto();
        GaeDto gdto2 = new GaeDto();
        GaeDto gdto3 = new GaeDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );
        gdto3.setPropA( "test3" );

        dto = new GaeGqlSimple();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( GaeGqlSimple.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( GaeGqlSimple.EnumTypeCustom.TYPE_B );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        dao.insert( dto );

        dto = new GaeGqlSimple();
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( GaeGqlSimple.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( GaeGqlSimple.EnumTypeCustom.TYPE_C );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        dao.insert( dto );

        assertEquals( "boolean true, true", 1, dao.findByBooleanOrBoolean( true, true ).length); 
        assertEquals( "boolean true, false", 2, dao.findByBooleanOrBoolean( true, false ).length); 
        assertEquals( "boolean true, null", 2, dao.findByBooleanOrBoolean( true, null ).length); 
        assertEquals( "short 1, 2", 1, dao.findByShortOrShort( (short)1, (short)2 ).length); 
        assertEquals( "short 1, 10", 2, dao.findByShortOrShort( (short)1, (short)10 ).length); 
        assertEquals( "int 2, 3", 1, dao.findByIntOrInt( 2, 3 ).length); 
        assertEquals( "int 2, 20", 2, dao.findByIntOrInt( 2, 20 ).length); 
        assertEquals( "long 3, 4", 1, dao.findByLongOrLong( 3L, 4L ).length); 
        assertEquals( "long 3, 30", 2, dao.findByLongOrLong( 3L, 30L ).length); 
        assertEquals( "double 4.1, 4.2", 1, dao.findByDoubleOrDouble( 4.1, 4.2 ).length); 
        assertEquals( "double 4.1, 40.1", 2, dao.findByDoubleOrDouble( 4.1, 40.1 ).length); 

        assertEquals( "enum plain A, C", 1, dao.findByEnumPlainOrEnumPlain(
            GaeGqlSimple.EnumTypePlain.TYPE_A, GaeGqlSimple.EnumTypePlain.TYPE_C ).length); 
        assertEquals( "enum plain A, B", 2, dao.findByEnumPlainOrEnumPlain(
            GaeGqlSimple.EnumTypePlain.TYPE_A, GaeGqlSimple.EnumTypePlain.TYPE_B ).length); 

        assertEquals( "enum custom A, B", 1, dao.findByEnumCustomOrEnumCustom(
            GaeGqlSimple.EnumTypeCustom.TYPE_A, GaeGqlSimple.EnumTypeCustom.TYPE_B ).length); 
        assertEquals( "enum plain B, C", 2, dao.findByEnumCustomOrEnumCustom(
            GaeGqlSimple.EnumTypeCustom.TYPE_B, GaeGqlSimple.EnumTypeCustom.TYPE_C ).length); 

        assertEquals( "string 'test', 'test3'", 1, dao.findByStringOrString( "test", "test3" ).length); 
        assertEquals( "string 'test', 'test2'", 2, dao.findByStringOrString( "test", "test2" ).length); 

        assertEquals( "date 1, 3'", 1, dao.findByDateOrDate( date1, date3 ).length); 
        assertEquals( "date 1, 2", 2, dao.findByDateOrDate( date1, date2 ).length); 
        assertEquals( "timestamp 1, 3'", 1, dao.findByTimestampOrTimestamp( ts1, ts3 ).length); 
        assertEquals( "timestamp 1, 2", 2, dao.findByTimestampOrTimestamp( ts1, ts2 ).length); 

        assertEquals( "sblob 1, 3", 1, dao.findBySblobOrSblob( sblob1, sblob3 ).length); 
        assertEquals( "sblob 1, 2", 2, dao.findBySblobOrSblob( sblob1, sblob2 ).length); 

        assertEquals( "serializable 1, 3", 1, dao.findBySerializableOrSerializable( "ser1", "ser3" ).length); 
        assertEquals( "serializable 1, 2", 2, dao.findBySerializableOrSerializable( "ser1", "ser2" ).length); 

        assertEquals( "dto 1, 3", 1, dao.findByDtoOrDto( gdto1, gdto3 ).length); 
        assertEquals( "dto 1, 2", 2, dao.findByDtoOrDto( gdto1, gdto2 ).length); 
    }


    @Test 
    public void testGqlCropTime() throws DaoException {
        GaeGqlSimpleDao dao = DaoFactory.createGaeGqlSimpleDao();

        GaeGqlSimple dto = new GaeGqlSimple();

        dao.insert( dto );

        dto = new GaeGqlSimple();
        dto.setDateType( date( "2010-04-23" ));

        dao.insert( dto );

        java.sql.Date date1 = new java.sql.Date( datetime("2010-04-23 09:50:03").getTime());
        java.sql.Date date2 = new java.sql.Date( datetime("2010-04-22 09:50:03").getTime());
        java.sql.Date date3 = new java.sql.Date( datetime("2010-04-21 09:50:03").getTime());

        assertEquals( "no date", 0, dao.findByDateOrDate( date2, date3 ).length); 
        assertEquals( "date 1", 1, dao.findByDateOrDate( date2, date1 ).length); 
        assertEquals( "date 1", 1, dao.findByDateOrDate( date2, null ).length); 
        assertEquals( "date 2", 2, dao.findByDateOrDate( null, date1 ).length); 
    }


    @Test 
    public void testGqlSimpleInAll() throws DaoException {
        GaeGqlSimpleDao dao = DaoFactory.createGaeGqlSimpleDao();

        GaeGqlSimple dto = new GaeGqlSimple();
        dto.setDoubleType( 4d );

        dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );
        java.sql.Date date3 = sqlDate( "2010-02-24" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );
        java.sql.Timestamp ts3 = sqlTimestamp( "2010-02-23 12:53:01" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];
        byte[] sblob3 = new byte[30];

        GaeDto gdto1 = new GaeDto();
        GaeDto gdto2 = new GaeDto();
        GaeDto gdto3 = new GaeDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );
        gdto3.setPropA( "test3" );

        dto = new GaeGqlSimple();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( GaeGqlSimple.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( GaeGqlSimple.EnumTypeCustom.TYPE_B );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        dao.insert( dto );

        dto = new GaeGqlSimple();
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( GaeGqlSimple.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( GaeGqlSimple.EnumTypeCustom.TYPE_C );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        dao.insert( dto );

        assertEquals( "boolean true", 1, dao.findAllBoolean( Arrays.asList( true )).length); 
        assertEquals( "boolean true, false", 2, dao.findAllBoolean( Arrays.asList( true, false )).length); 
        assertEquals( "boolean true, false, null", 3, dao.findAllBoolean( Arrays.asList( true, false, null )).length); 
        assertEquals( "short 1", 1, dao.findAllShort( Arrays.asList( (short)1 )).length); 
        assertEquals( "short 1, 10", 2, dao.findAllShort( Arrays.asList( (short)1, (short)10 )).length); 
        assertEquals( "int 2", 1, dao.findAllInt( Arrays.asList( 2 )).length); 
        assertEquals( "int 2, 20", 2, dao.findAllInt( Arrays.asList( 2, 20 )).length); 
        assertEquals( "long 3", 1, dao.findAllLong( Arrays.asList( 3L )).length); 
        assertEquals( "long 3, 30", 2, dao.findAllLong( Arrays.asList( 3L, 30L )).length); 
        assertEquals( "double 4.1", 1, dao.findAllDouble( Arrays.asList( 4.1 )).length); 
        assertEquals( "double 4.1, 40.1", 2, dao.findAllDouble( Arrays.asList( 4.1, 40.1 )).length); 

        assertEquals( "string 1", 1, dao.findAllString( Arrays.asList( "test" )).length); 
        assertEquals( "string 1, 2", 2, dao.findAllString( Arrays.asList( "test", "test2" )).length); 

        assertEquals( "date 1", 1, dao.findAllDate( Arrays.asList( date1 )).length); 
        assertEquals( "date 1, 2", 2, dao.findAllDate( Arrays.asList( date1, date2 )).length); 
        assertEquals( "timestamp 1", 1, dao.findAllTimestamp( Arrays.asList( ts1 )).length); 
        assertEquals( "timestamp 1, 2", 2, dao.findAllTimestamp( Arrays.asList( ts1, ts2 )).length); 

        assertEquals( "enum plain A", 1, dao.findAllEnumPlain( Arrays.asList(
            GaeGqlSimple.EnumTypePlain.TYPE_A )).length); 
        assertEquals( "enum plain A, B", 2, dao.findAllEnumPlain( Arrays.asList(
            GaeGqlSimple.EnumTypePlain.TYPE_A, GaeGqlSimple.EnumTypePlain.TYPE_B )).length); 

        assertEquals( "enum custom B", 1, dao.findAllEnumCustom( Arrays.asList(
            GaeGqlSimple.EnumTypeCustom.TYPE_B )).length); 
        assertEquals( "enum custom B, C", 2, dao.findAllEnumCustom( Arrays.asList(
            GaeGqlSimple.EnumTypeCustom.TYPE_B, GaeGqlSimple.EnumTypeCustom.TYPE_C )).length); 

        assertEquals( "sblob 1", 1, dao.findAllSblob( Arrays.asList( sblob1 )).length); 
        assertEquals( "sblob 1, 2", 2, dao.findAllSblob( Arrays.asList( sblob1, sblob2 )).length); 

        assertEquals( "serializable 1", 1, dao.findAllSerializable( Arrays.asList(
            (java.io.Serializable)"ser1" )).length); 
        assertEquals( "serializable 1, 2", 2, dao.findAllSerializable( Arrays.asList(
            (java.io.Serializable)"ser1", (java.io.Serializable)"ser2" )).length); 

        assertEquals( "dto 1", 1, dao.findAllDto( Arrays.asList( gdto1 )).length); 
        assertEquals( "dto 1, 2", 2, dao.findAllDto( Arrays.asList( gdto1, gdto2 )).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - GQL - Google
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGqlGoogleEntKey() throws DaoException {
        GaeGqlGoogleDao dao = DaoFactory.createGaeGqlGoogleDao();

        GaeGqlGoogle dto = new GaeGqlGoogle();
        dao.insert( dto );

        Key key1 = KeyFactory.createKey( "GaeGqlGoogle", dto.getId());

        dto = new GaeGqlGoogle();
        dao.insert( dto );

        Key key2 = KeyFactory.createKey( "GaeGqlGoogle", dto.getId());
        Key key3 = KeyFactory.createKey( "GaeGqlGoogle", "bla" );

        assertEquals( "id +1", 0, dao.findByEntKeyId( key1.getId() + key2.getId()).length); 
        assertEquals( "id", 1, dao.findByEntKeyId( key1.getId()).length); 
        assertEquals( "encoded1 bla", 0, dao.findByEntKeyEncoded1( KeyFactory.keyToString( key3 )).length); 
        assertEquals( "encoded1 1", 1, dao.findByEntKeyEncoded1( KeyFactory.keyToString( key1 )).length); 
        assertEquals( "encoded2 bla", 0, dao.findByEntKeyEncoded2( KeyFactory.keyToString( key3 )).length); 
        assertEquals( "encoded2 1", 1, dao.findByEntKeyEncoded2( KeyFactory.keyToString( key1 )).length); 
        assertEquals( "full1 bla", 0, dao.findByEntKeyFull1( key3 ).length); 
        assertEquals( "full1 1", 1, dao.findByEntKeyFull1( key1 ).length); 
        assertEquals( "full2 bla", 0, dao.findByEntKeyFull2( key3 ).length); 
        assertEquals( "full2 1", 1, dao.findByEntKeyFull2( key1 ).length); 
        assertEquals( "2 in 1: 1 3", 1, dao.findByEntKeyOrEntKey( key1.getId(), key3 ).length); 
        assertEquals( "2 in 1: 1 2", 2, dao.findByEntKeyOrEntKey( key1.getId(), key2 ).length); 
        assertEquals( "all1 1 3", 1, dao.findAllEntKey1( Arrays.asList( key1, key3 )).length); 
        assertEquals( "all1 1 2", 2, dao.findAllEntKey1( Arrays.asList( key1, key2 )).length); 
        assertEquals( "all1 2 3", 1, dao.findAllEntKey2( Arrays.asList( key1, key3 )).length); 
        assertEquals( "all1 2 2", 2, dao.findAllEntKey2( Arrays.asList( key1, key2 )).length); 
    }


    @Test 
    public void testGqlGoogleFixed() throws DaoException {
        GaeGqlGoogleDao dao = DaoFactory.createGaeGqlGoogleDao();

        assertEquals( "before string test", 0, dao.findFixedString().length); 
        assertEquals( "before key 1", 0, dao.findFixedKey1().length); 
        assertEquals( "before key 2", 0, dao.findFixedKey2().length); 
        assertEquals( "before geopt", 0, dao.findFixedGeopt().length); 
        assertEquals( "before user", 0, dao.findFixedUser().length); 

        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );

        GaeGqlGoogle dto = new GaeGqlGoogle();
        dto.setStringType( "test" );
        dto.setKeyType( KeyFactory.createKey("Test", 1));
        dto.setGeoptType( geopt1 );
        dto.setUserType( user1 );

        dao.insert( dto );

        dto = new GaeGqlGoogle();
        dto.setKeyType( KeyFactory.createKey("Test", "test"));

        dao.insert( dto );

        assertEquals( "string test", 1, dao.findFixedString().length); 
        assertEquals( "key 1", 1, dao.findFixedKey1().length); 
        assertEquals( "key 2", 1, dao.findFixedKey2().length); 
        assertEquals( "geopt", 1, dao.findFixedGeopt().length); 
        assertEquals( "user", 1, dao.findFixedUser().length); 
    }


    @Test 
    public void testGqlGoogleInTypeOrType01() throws DaoException {
        GaeGqlGoogleDao dao = DaoFactory.createGaeGqlGoogleDao();

        Key key1 = KeyFactory.createKey("Test", 1);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );

        GaeGqlGoogle dto = new GaeGqlGoogle();
        dto.setStringType( "test" );
        dto.setStringSblobType( "stest" );
        dto.setKeyType( key1 );
        dto.setGeoptType( geopt1 );
        dto.setUserType( user1 );

        dao.insert( dto );

        dto = new GaeGqlGoogle();
        dto.setStringType( "test2" );
        dto.setStringSblobType( "stest2" );
        dto.setKeyType( key2 );
        dto.setGeoptType( geopt2 );
        dto.setUserType( user2 );

        dao.insert( dto );

        assertEquals( "string test bla", 1, dao.findByStringOrString( "test", "bla").length); 
        assertEquals( "string test test2", 2, dao.findByStringOrString( "test", "test2").length); 
        assertEquals( "sblob test bla", 1, dao.findByStringSblobOrStringSblob( "stest", "bla").length); 
        assertEquals( "sblob test test2", 2, dao.findByStringSblobOrStringSblob( "stest", "stest2").length); 
        assertEquals( "key 1 3", 1, dao.findByKeyOrKey( key1, key3).length); 
        assertEquals( "key 1 2", 2, dao.findByKeyOrKey( key1, key2).length); 
        assertEquals( "geopt 1 3", 1, dao.findByGeoptOrGeopt( geopt1, geopt3).length); 
        assertEquals( "geopt 1 2", 2, dao.findByGeoptOrGeopt( geopt1, geopt2).length); 
        assertEquals( "user 1 3", 1, dao.findByUserOrUser( user1, user3).length); 
        assertEquals( "user 1 2", 2, dao.findByUserOrUser( user1, user2).length); 
    }


    @Test 
    public void testGqlGoogleInTypeOrType02() throws DaoException {
        GaeGqlGoogleDao dao = DaoFactory.createGaeGqlGoogleDao();

        Key key1 = KeyFactory.createKey("Test", 1);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );

        GaeGqlGoogle dto = new GaeGqlGoogle();
        dto.setKeyType( key1 );
        dto.setGeoptType( geopt1 );
        dto.setUserType( user1 );

        dao.insert( dto );

        dto = new GaeGqlGoogle();
        dto.setKeyType( key2 );
        dto.setGeoptType( geopt2 );
        dto.setUserType( user2 );

        dao.insert( dto );

        assertEquals( "key 1 3", 1, dao.findByKeyOrKey( KeyFactory.keyToString( key1 ), 3L).length); 
        assertEquals( "key 1 2", 2, dao.findByKeyOrKey( KeyFactory.keyToString( key1 ), 2L).length); 
        assertEquals( "geopt 1 3", 1, dao.findByGeoptOrGeopt( 1d, 1.1, 2d, 1.1).length); 
        assertEquals( "geopt 1 2", 2, dao.findByGeoptOrGeopt( 1d, 1.1, 1d, 1.2).length); 
        assertEquals( "user 1 3", 1, dao.findByUserOrUser( user1.getEmail(), user3.getEmail()).length); 
        assertEquals( "user 1 2", 2, dao.findByUserOrUser( user1.getEmail(), user2.getEmail()).length); 
    }


    @Test 
    public void testGqlGoogleInAll() throws DaoException {
        GaeGqlGoogleDao dao = DaoFactory.createGaeGqlGoogleDao();

        Key key1 = KeyFactory.createKey("Test", 1);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );

        GaeGqlGoogle dto = new GaeGqlGoogle();
        dto.setStringType( "test" );
        dto.setStringSblobType( "stest" );
        dto.setKeyType( key1 );
        dto.setGeoptType( geopt1 );
        dto.setUserType( user1 );

        dao.insert( dto );

        dto = new GaeGqlGoogle();
        dto.setStringType( "test2" );
        dto.setStringSblobType( "stest2" );
        dto.setKeyType( key2 );
        dto.setGeoptType( geopt2 );
        dto.setUserType( user2 );

        dao.insert( dto );

        assertEquals( "string 1", 1, dao.findAllString( Arrays.asList( "test" )).length); 
        assertEquals( "string 1, 2", 2, dao.findAllString( Arrays.asList( "test", "test2" )).length); 
        assertEquals( "sblob 1", 1, dao.findAllStringSblob( Arrays.asList( "stest" )).length); 
        assertEquals( "sblob 1, 2", 2, dao.findAllStringSblob( Arrays.asList( "stest", "stest2" )).length); 
        assertEquals( "key 1", 1, dao.findAllKey( Arrays.asList( key1 )).length); 
        assertEquals( "key 1, 2", 2, dao.findAllKey( Arrays.asList( key1, key2 )).length); 
        assertEquals( "geopt 1", 1, dao.findAllGeopt( Arrays.asList( geopt1 )).length); 
        assertEquals( "geopt 1, 2", 2, dao.findAllGeopt( Arrays.asList( geopt1, geopt2 )).length); 
        assertEquals( "user 1", 1, dao.findAllUser( Arrays.asList( user1 )).length); 
        assertEquals( "user 1, 2", 2, dao.findAllUser( Arrays.asList( user1, user2 )).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - GQL - Google List
    ////////////////////////////////////////////////////////////////////////////


    @Test 
    public void testGqlListByOne() throws DaoException {
        GaeGqlListDao dao = DaoFactory.createGaeGqlListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        Number n3 = 3;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        GaeGqlList dto = new GaeGqlList();

        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test2" ));
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setStringSblobType( Arrays.asList( "stest2" ));
        dto.setSblobType( Arrays.asList( n2 ));
        dto.setDtoType( Arrays.asList( dto2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));
        dto.setNativeList( Arrays.asList( o2 ));
        dto.setAnonList( Arrays.asList( o2 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test11" ));
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setStringSblobType( Arrays.asList( "stest11" ));
        dto.setSblobType( Arrays.asList( n11 ));
        dto.setDtoType( Arrays.asList( dto11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));
        dto.setNativeList( Arrays.asList( o11 ));
        dto.setAnonList( Arrays.asList( o11 ));

        dao.insert( dto );

        assertEquals( "string bla", 0, dao.findByString( "bla" ).length); 
        assertEquals( "string test", 1, dao.findByString( "test" ).length); 
        assertEquals( "string test2", 1, dao.findByString( "test2" ).length); 
        assertEquals( "string test11", 2, dao.findByString( "test11" ).length); 

        assertEquals( "udate bla", 0, dao.findByUdate( date3 ).length); 
        assertEquals( "udate 1", 1, dao.findByUdate( date1 ).length); 
        assertEquals( "udate 2", 1, dao.findByUdate( date2 ).length); 
        assertEquals( "udate 11", 2, dao.findByUdate( date11 ).length); 

        assertEquals( "sblob bla", 0, dao.findByStringSblob( "sbla" ).length); 
        assertEquals( "sblob test", 1, dao.findByStringSblob( "stest" ).length); 
        assertEquals( "sblob test2", 1, dao.findByStringSblob( "stest2" ).length); 
        assertEquals( "sblob test11", 2, dao.findByStringSblob( "stest11" ).length); 

        assertEquals( "nblob bla", 0, dao.findBySblob( n3 ).length); 
        assertEquals( "nblob 1", 1, dao.findBySblob( n1 ).length); 
        assertEquals( "nblob 2", 1, dao.findBySblob( n2 ).length); 
        assertEquals( "nblob 11", 2, dao.findBySblob( n11 ).length); 

        assertEquals( "dto bla", 0, dao.findByDto( dto3 ).length); 
        assertEquals( "dto 1", 1, dao.findByDto( dto1 ).length); 
        assertEquals( "dto 2", 1, dao.findByDto( dto2 ).length); 
        assertEquals( "dto 11", 2, dao.findByDto( dto11 ).length); 

        assertEquals( "key bla", 0, dao.findByKey( key3 ).length); 
        assertEquals( "key 1", 1, dao.findByKey( key1 ).length); 
        assertEquals( "key 2", 1, dao.findByKey( key2 ).length); 
        assertEquals( "key 11", 2, dao.findByKey( key11 ).length); 

        assertEquals( "geopt bla", 0, dao.findByGeopt( geopt3 ).length); 
        assertEquals( "geopt 1", 1, dao.findByGeopt( geopt1 ).length); 
        assertEquals( "geopt 2", 1, dao.findByGeopt( geopt2 ).length); 
        assertEquals( "geopt 11", 2, dao.findByGeopt( geopt11 ).length); 

        assertEquals( "user bla", 0, dao.findByUser( user3 ).length); 
        assertEquals( "user 1", 1, dao.findByUser( user1 ).length); 
        assertEquals( "user 2", 1, dao.findByUser( user2 ).length); 
        assertEquals( "user 11", 2, dao.findByUser( user11 ).length); 

        assertEquals( "native bla", 0, dao.findByNative( o3 ).length); 
        assertEquals( "native 1", 1, dao.findByNative( o1 ).length); 
        assertEquals( "native 2", 1, dao.findByNative( o2 ).length); 
        assertEquals( "native 11", 2, dao.findByNative( o11 ).length); 

        assertEquals( "anon bla", 0, dao.findByAnon( o3 ).length); 
        assertEquals( "anon 1", 1, dao.findByAnon( o1 ).length); 
        assertEquals( "anon 2", 1, dao.findByAnon( o2 ).length); 
        assertEquals( "anon 11", 2, dao.findByAnon( o11 ).length); 
    }


    @Test 
    public void testGqlListByAll01() throws DaoException {
        GaeGqlListDao dao = DaoFactory.createGaeGqlListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        Number n3 = 3;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        GaeGqlList dto = new GaeGqlList();

        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test2" ));
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setStringSblobType( Arrays.asList( "stest2" ));
        dto.setSblobType( Arrays.asList( n2 ));
        dto.setDtoType( Arrays.asList( dto2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));
        dto.setNativeList( Arrays.asList( o2 ));
        dto.setAnonList( Arrays.asList( o2 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test11" ));
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setStringSblobType( Arrays.asList( "stest11" ));
        dto.setSblobType( Arrays.asList( n11 ));
        dto.setDtoType( Arrays.asList( dto11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));
        dto.setNativeList( Arrays.asList( o11 ));
        dto.setAnonList( Arrays.asList( o11 ));

        dao.insert( dto );

        assertEquals( "string 1", 1, dao.findByString( Arrays.asList( "test" )).length); 
        assertEquals( "string 11", 2, dao.findByString( Arrays.asList( "test11" )).length); 
        assertEquals( "string 1, 2", 0, dao.findByString( Arrays.asList( "test", "test2" )).length); 
        assertEquals( "string 11, 1", 1, dao.findByString( Arrays.asList( "test11", "test" )).length); 

        assertEquals( "udate 1", 1, dao.findByUdate( Arrays.asList( date1 )).length); 
        assertEquals( "udate 11", 2, dao.findByUdate( Arrays.asList( date11 )).length); 
        assertEquals( "udate 1, 2", 0, dao.findByUdate( Arrays.asList( date1, date2 )).length); 
        assertEquals( "udate 11, 1", 1, dao.findByUdate( Arrays.asList( date11, date1 )).length); 

        assertEquals( "sblob 1", 1, dao.findByStringSblob( Arrays.asList( "stest" )).length); 
        assertEquals( "sblob 11", 2, dao.findByStringSblob( Arrays.asList( "stest11" )).length); 
        assertEquals( "sblob 1, 2", 0, dao.findByStringSblob( Arrays.asList( "stest", "stest2" )).length); 
        assertEquals( "sblob 11, 1", 1, dao.findByStringSblob( Arrays.asList( "stest11", "stest" )).length); 

        assertEquals( "nblob 1", 1, dao.findBySblob( Arrays.asList( n1 )).length); 
        assertEquals( "nblob 11", 2, dao.findBySblob( Arrays.asList( n11 )).length); 
        assertEquals( "nblob 1, 2", 0, dao.findBySblob( Arrays.asList( n1, n2 )).length); 
        assertEquals( "nblob 11, 1", 1, dao.findBySblob( Arrays.asList( n11, n1 )).length); 

        assertEquals( "dto 1", 1, dao.findByDto( Arrays.asList( dto1 )).length); 
        assertEquals( "dto 11", 2, dao.findByDto( Arrays.asList( dto11 )).length); 
        assertEquals( "dto 1, 2", 0, dao.findByDto( Arrays.asList( dto1, dto2 )).length); 
        assertEquals( "dto 11, 1", 1, dao.findByDto( Arrays.asList( dto11, dto1 )).length); 

        assertEquals( "key 1", 1, dao.findByKey( Arrays.asList( key1 )).length); 
        assertEquals( "key 11", 2, dao.findByKey( Arrays.asList( key11 )).length); 
        assertEquals( "key 1, 2", 0, dao.findByKey( Arrays.asList( key1, key2 )).length); 
        assertEquals( "key 11, 1", 1, dao.findByKey( Arrays.asList( key11, key1 )).length); 

        assertEquals( "geopt 1", 1, dao.findByGeopt( Arrays.asList( geopt1 )).length); 
        assertEquals( "geopt 11", 2, dao.findByGeopt( Arrays.asList( geopt11 )).length); 
        assertEquals( "geopt 1, 2", 0, dao.findByGeopt( Arrays.asList( geopt1, geopt2 )).length); 
        assertEquals( "geopt 11, 1", 1, dao.findByGeopt( Arrays.asList( geopt11, geopt1 )).length); 

        assertEquals( "user 1", 1, dao.findByUser( Arrays.asList( user1 )).length); 
        assertEquals( "user 11", 2, dao.findByUser( Arrays.asList( user11 )).length); 
        assertEquals( "user 1, 2", 0, dao.findByUser( Arrays.asList( user1, user2 )).length); 
        assertEquals( "user 11, 1", 1, dao.findByUser( Arrays.asList( user11, user1 )).length); 

        assertEquals( "native 1", 1, dao.findByNative( Arrays.asList( o1 )).length); 
        assertEquals( "native 11", 2, dao.findByNative( Arrays.asList( o11 )).length); 
        assertEquals( "native 1, 2", 0, dao.findByNative( Arrays.asList( o1, o2 )).length); 
        assertEquals( "native 11, 1", 1, dao.findByNative( Arrays.asList( o11, o1 )).length); 

        assertEquals( "anon 1", 1, dao.findByAnon( Arrays.asList( o1 )).length); 
        assertEquals( "anon 11", 2, dao.findByAnon( Arrays.asList( o11 )).length); 
        assertEquals( "anon 1, 2", 0, dao.findByAnon( Arrays.asList( o1, o2 )).length); 
        assertEquals( "anon 11, 1", 1, dao.findByAnon( Arrays.asList( o11, o1 )).length); 
    }


    @Test 
    public void testGqlListByAll02() throws DaoException {
        GaeGqlListDao dao = DaoFactory.createGaeGqlListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        Number n3 = 3;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        // insert one non-empty object
        GaeGqlList dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        List<String> lString = null;
        List<java.util.Date> lDate = null;
        List<Number> lNumber = null;
        List<GaeDto> lDto = null;
        List<Key> lKey = null;
        List<User> lUser = null;
        List lAnon = null;

        assertEquals( "string null 0", 0, dao.findByString( lString ).length); 
        assertEquals( "udate null 0", 0, dao.findByUdate( lDate ).length); 
        assertEquals( "sblob null 0", 0, dao.findByStringSblob( lString ).length); 
        assertEquals( "nblob null 0", 0, dao.findBySblob( lNumber ).length); 
        assertEquals( "dto null 0", 0, dao.findByDto( lDto ).length); 
        assertEquals( "key null 0", 0, dao.findByKey( lKey ).length); 
        assertEquals( "user null 0", 0, dao.findByUser( lUser ).length); 
        assertEquals( "native null 0", 0, dao.findByNative( lAnon ).length); 
        assertEquals( "anon null 0", 0, dao.findByAnon( lAnon ).length); 

        lString = new ArrayList<String>();
        lDate = new ArrayList<java.util.Date>();
        lNumber = new ArrayList<Number>();
        lDto = new ArrayList<GaeDto>();
        lKey = new ArrayList<Key>();
        lUser = new ArrayList<User>();
        lAnon = new ArrayList();

        assertEquals( "string empty 0", 0, dao.findByString( lString ).length); 
        assertEquals( "udate empty 0", 0, dao.findByUdate( lDate ).length); 
        assertEquals( "sblob empty 0", 0, dao.findByStringSblob( lString ).length); 
        assertEquals( "nblob empty 0", 0, dao.findBySblob( lNumber ).length); 
        assertEquals( "dto empty 0", 0, dao.findByDto( lDto ).length); 
        assertEquals( "key empty 0", 0, dao.findByKey( lKey ).length); 
        assertEquals( "user empty 0", 0, dao.findByUser( lUser ).length); 
        assertEquals( "native empty 0", 0, dao.findByNative( lAnon ).length); 
        assertEquals( "anon empty 0", 0, dao.findByAnon( lAnon ).length); 

        dto = new GaeGqlList();
        dao.insert( dto );

        assertEquals( "string empty 1", 1, dao.findByString( lString ).length); 
        assertEquals( "udate empty 1", 1, dao.findByUdate( lDate ).length); 
        assertEquals( "sblob empty 1", 1, dao.findByStringSblob( lString ).length); 
        assertEquals( "nblob empty 1", 1, dao.findBySblob( lNumber ).length); 
        assertEquals( "dto empty 1", 1, dao.findByDto( lDto ).length); 
        assertEquals( "key empty 1", 1, dao.findByKey( lKey ).length); 
        assertEquals( "user empty 1", 1, dao.findByUser( lUser ).length); 
        assertEquals( "native empty 1", 1, dao.findByNative( lAnon ).length); 
        assertEquals( "anon empty 1", 1, dao.findByAnon( lAnon ).length); 

        lString = null;
        lDate = null;
        lNumber = null;
        lDto = null;
        lKey = null;
        lUser = null;
        lAnon = null;

        assertEquals( "string null 1", 1, dao.findByString( lString ).length); 
        assertEquals( "udate null 1", 1, dao.findByUdate( lDate ).length); 
        assertEquals( "sblob null 1", 1, dao.findByStringSblob( lString ).length); 
        assertEquals( "nblob null 1", 1, dao.findBySblob( lNumber ).length); 
        assertEquals( "dto null 1", 1, dao.findByDto( lDto ).length); 
        assertEquals( "key null 1", 1, dao.findByKey( lKey ).length); 
        assertEquals( "user null 1", 1, dao.findByUser( lUser ).length); 
        assertEquals( "native null 1", 1, dao.findByNative( lAnon ).length); 
        assertEquals( "anon null 1", 1, dao.findByAnon( lAnon ).length); 

    }



    @Test 
    public void testGqlListInTypeOrType01() throws DaoException {
        GaeGqlListDao dao = DaoFactory.createGaeGqlListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        GaeGqlList dto = new GaeGqlList();

        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test2" ));
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setStringSblobType( Arrays.asList( "stest2" ));
        dto.setSblobType( Arrays.asList( n2 ));
        dto.setDtoType( Arrays.asList( dto2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));
        dto.setNativeList( Arrays.asList( o2 ));
        dto.setAnonList( Arrays.asList( o2 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test11" ));
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setStringSblobType( Arrays.asList( "stest11" ));
        dto.setSblobType( Arrays.asList( n11 ));
        dto.setDtoType( Arrays.asList( dto11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));
        dto.setNativeList( Arrays.asList( o11 ));
        dto.setAnonList( Arrays.asList( o11 ));

        dao.insert( dto );

        assertEquals( "string test bla", 1, dao.findByStringOrString( "test", "bla").length); 
        assertEquals( "string test test2", 2, dao.findByStringOrString( "test", "test2").length); 
        assertEquals( "string test test11", 2, dao.findByStringOrString( "test", "test11").length); 
        assertEquals( "string test2 test11", 3, dao.findByStringOrString( "test2", "test11").length); 

        assertEquals( "udate 1 bla", 1, dao.findByUdateOrUdate( date1, date3).length); 
        assertEquals( "udate 1 2", 2, dao.findByUdateOrUdate( date1, date2).length); 
        assertEquals( "udate 1 11", 2, dao.findByUdateOrUdate( date1, date11).length); 
        assertEquals( "udate 2 11", 3, dao.findByUdateOrUdate( date2, date11).length); 

        assertEquals( "sblob test bla", 1, dao.findByStringSblobOrStringSblob( "stest", "bla").length); 
        assertEquals( "sblob test test2", 2, dao.findByStringSblobOrStringSblob( "stest", "stest2").length); 
        assertEquals( "sblob test test11", 2, dao.findByStringSblobOrStringSblob( "stest", "stest11").length); 
        assertEquals( "sblob test2 test11", 3, dao.findByStringSblobOrStringSblob( "stest2", "stest11").length); 

        assertEquals( "nblob 1 bla", 1, dao.findBySblobOrSblob( n1, 1000).length); 
        assertEquals( "nblob 1 2", 2, dao.findBySblobOrSblob( n1, n2).length); 
        assertEquals( "nblob 1 11", 2, dao.findBySblobOrSblob( n1, n11).length); 
        assertEquals( "nblob 2 11", 3, dao.findBySblobOrSblob( n2, n11).length); 

        assertEquals( "dto 1 bla", 1, dao.findByDtoOrDto( dto1, dto3).length); 
        assertEquals( "dto 1 2", 2, dao.findByDtoOrDto( dto1, dto2).length); 
        assertEquals( "dto 1 11", 2, dao.findByDtoOrDto( dto1, dto11).length); 
        assertEquals( "dto 2 11", 3, dao.findByDtoOrDto( dto2, dto11).length); 

        assertEquals( "key 1 bla", 1, dao.findByKeyOrKey( key1, key3).length); 
        assertEquals( "key 1 2", 2, dao.findByKeyOrKey( key1, key2).length); 
        assertEquals( "key 1 11", 2, dao.findByKeyOrKey( key1, key11).length); 
        assertEquals( "key 2 11", 3, dao.findByKeyOrKey( key2, key11).length); 

        assertEquals( "geopt 1 bla", 1, dao.findByGeoptOrGeopt( geopt1, geopt3).length); 
        assertEquals( "geopt 1 2", 2, dao.findByGeoptOrGeopt( geopt1, geopt2).length); 
        assertEquals( "geopt 1 11", 2, dao.findByGeoptOrGeopt( geopt1, geopt11).length); 
        assertEquals( "geopt 2 11", 3, dao.findByGeoptOrGeopt( geopt2, geopt11).length); 

        assertEquals( "user 1 bla", 1, dao.findByUserOrUser( user1, user3).length); 
        assertEquals( "user 1 2", 2, dao.findByUserOrUser( user1, user2).length); 
        assertEquals( "user 1 11", 2, dao.findByUserOrUser( user1, user11).length); 
        assertEquals( "user 2 11", 3, dao.findByUserOrUser( user2, user11).length); 

        assertEquals( "native1 1 bla", 1, dao.findByNativeOrNative1( o1, o3).length); 
        assertEquals( "native1 1 2", 2, dao.findByNativeOrNative1( o1, o2).length); 
        assertEquals( "native1 1 11", 2, dao.findByNativeOrNative1( o1, o11).length); 
        assertEquals( "native1 2 11", 3, dao.findByNativeOrNative1( o2, o11).length); 

        assertEquals( "native2 1 bla", 1, dao.findByNativeOrNative2( o1, o3).length); 
        assertEquals( "native2 1 2", 2, dao.findByNativeOrNative2( o1, o2).length); 
        assertEquals( "native2 1 11", 2, dao.findByNativeOrNative2( o1, o11).length); 
        assertEquals( "native2 2 11", 3, dao.findByNativeOrNative2( o2, o11).length); 

        assertEquals( "anon1 1 bla", 1, dao.findByAnonOrAnon1( o1, o3).length); 
        assertEquals( "anon1 1 2", 2, dao.findByAnonOrAnon1( o1, o2).length); 
        assertEquals( "anon1 1 11", 2, dao.findByAnonOrAnon1( o1, o11).length); 
        assertEquals( "anon1 2 11", 3, dao.findByAnonOrAnon1( o2, o11).length); 

        assertEquals( "anon2 1 bla", 1, dao.findByAnonOrAnon2( o1, o3).length); 
        assertEquals( "anon2 1 2", 2, dao.findByAnonOrAnon2( o1, o2).length); 
        assertEquals( "anon2 1 11", 2, dao.findByAnonOrAnon2( o1, o11).length); 
        assertEquals( "anon2 2 11", 3, dao.findByAnonOrAnon2( o2, o11).length); 
    }


    @Test 
    public void testGqlListInTypeOrType02() throws DaoException {
        GaeGqlListDao dao = DaoFactory.createGaeGqlListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );

        String skey1 = KeyFactory.keyToString( key1 );
        String skey2 = KeyFactory.keyToString( key2 );

        GaeGqlList dto = new GaeGqlList();

        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));

        dao.insert( dto );


        assertEquals( "udate 1 bla", 1, dao.findByUdateOrUdate( 2010,2,25, 2010,2,27,0,0,0).length); 
        assertEquals( "udate 1 2", 2, dao.findByUdateOrUdate( 2010,2,25, 2010,2,26,0,0,0).length); 
        assertEquals( "udate 1 11", 2, dao.findByUdateOrUdate( 2010,2,25, 2010,2,25,11,12,13).length); 
        assertEquals( "udate 2 11", 3, dao.findByUdateOrUdate( 2010,2,26, 2010,2,25,11,12,13).length); 

        assertEquals( "key 1 bla", 1, dao.findByKeyOrKey( skey1, key3.getId()).length); 
        assertEquals( "key 1 2", 2, dao.findByKeyOrKey( skey1, key2.getId()).length); 
        assertEquals( "key 1 11", 2, dao.findByKeyOrKey( skey1, key11.getId()).length); 
        assertEquals( "key 2 11", 3, dao.findByKeyOrKey( skey2, key11.getId()).length); 

        assertEquals( "geopt 1 bla", 1, dao.findByGeoptOrGeopt(
            (double)geopt1.getLatitude(), (double)geopt1.getLongitude(),
            (double)geopt3.getLatitude(), (double)geopt3.getLongitude()).length); 

        assertEquals( "geopt 1 2", 2, dao.findByGeoptOrGeopt(
            (double)geopt1.getLatitude(), (double)geopt1.getLongitude(),
            (double)geopt2.getLatitude(), (double)geopt2.getLongitude()).length); 

        assertEquals( "geopt 1 11", 2, dao.findByGeoptOrGeopt(
            (double)geopt1.getLatitude(), (double)geopt1.getLongitude(),
            (double)geopt11.getLatitude(), (double)geopt11.getLongitude()).length); 

        assertEquals( "geopt 2 11", 3, dao.findByGeoptOrGeopt(
            (double)geopt2.getLatitude(), (double)geopt2.getLongitude(),
            (double)geopt11.getLatitude(), (double)geopt11.getLongitude()).length); 

        assertEquals( "user 1 bla", 1, dao.findByUserOrUser( user1.getEmail(), user3.getEmail()).length); 
        assertEquals( "user 1 2", 2, dao.findByUserOrUser( user1.getEmail(), user2.getEmail()).length); 
        assertEquals( "user 1 11", 2, dao.findByUserOrUser( user1.getEmail(), user11.getEmail()).length); 
        assertEquals( "user 2 11", 3, dao.findByUserOrUser( user2.getEmail(), user11.getEmail()).length); 
    }


    @Test 
    public void testGqlListInAll() throws DaoException {
        GaeGqlListDao dao = DaoFactory.createGaeGqlListDao();

        java.util.Date date1 = date("2010-02-25");
        java.util.Date date11 = datetime("2010-02-25 11:12:13");
        java.util.Date date2 = date("2010-02-26");
        java.util.Date date3 = date("2010-02-27");
        Number n1 = 1;
        Number n11 = 11L;
        Number n2 = 2.1;
        GaeDto dto1 = new GaeDto();
        GaeDto dto11 = new GaeDto(); dto11.setPropA( "11" );
        GaeDto dto2 = new GaeDto(); dto2.setPropA( "2" );
        GaeDto dto3 = new GaeDto(); dto3.setPropA( "3" );
        Key key1 = KeyFactory.createKey("Test", 1);
        Key key11 = KeyFactory.createKey("Test", 11);
        Key key2 = KeyFactory.createKey("Test", 2);
        Key key3 = KeyFactory.createKey("Test", 3);
        GeoPt geopt1 = new GeoPt( 1f, 1.1f );
        GeoPt geopt11 = new GeoPt( 1f, 1.11f );
        GeoPt geopt2 = new GeoPt( 1f, 1.2f );
        GeoPt geopt3 = new GeoPt( 2f, 1.1f );
        User user1 = new User( "user@foo.com", "gmail.com" );
        User user11 = new User( "user11@foo.com", "gmail.com" );
        User user2 = new User( "user2@foo.com", "gmail.com" );
        User user3 = new User( "user3@foo.com", "gmail.com" );
        Object o1 = "o1";
        Object o11 = 11;
        Object o2 = "o2";
        Object o3 = "o3";

        GaeGqlList dto = new GaeGqlList();

        dto.setStringType( Arrays.asList( "test", "test11" ));
        dto.setUdateType( Arrays.asList( date1, date11 ));
        dto.setStringSblobType( Arrays.asList( "stest", "stest11" ));
        dto.setSblobType( Arrays.asList( n1, n11 ));
        dto.setDtoType( Arrays.asList( dto1, dto11 ));
        dto.setKeyType( Arrays.asList( key1, key11 ));
        dto.setGeoptType( Arrays.asList( geopt1, geopt11 ));
        dto.setUserType( Arrays.asList( user1, user11 ));
        dto.setNativeList( Arrays.asList( o1, o11 ));
        dto.setAnonList( Arrays.asList( o1, o11 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test2" ));
        dto.setUdateType( Arrays.asList( date2 ));
        dto.setStringSblobType( Arrays.asList( "stest2" ));
        dto.setSblobType( Arrays.asList( n2 ));
        dto.setDtoType( Arrays.asList( dto2 ));
        dto.setKeyType( Arrays.asList( key2 ));
        dto.setGeoptType( Arrays.asList( geopt2 ));
        dto.setUserType( Arrays.asList( user2 ));
        dto.setNativeList( Arrays.asList( o2 ));
        dto.setAnonList( Arrays.asList( o2 ));

        dao.insert( dto );

        dto = new GaeGqlList();
        dto.setStringType( Arrays.asList( "test11" ));
        dto.setUdateType( Arrays.asList( date11 ));
        dto.setStringSblobType( Arrays.asList( "stest11" ));
        dto.setSblobType( Arrays.asList( n11 ));
        dto.setDtoType( Arrays.asList( dto11 ));
        dto.setKeyType( Arrays.asList( key11 ));
        dto.setGeoptType( Arrays.asList( geopt11 ));
        dto.setUserType( Arrays.asList( user11 ));
        dto.setNativeList( Arrays.asList( o11 ));
        dto.setAnonList( Arrays.asList( o11 ));

        dao.insert( dto );

        assertEquals( "string 1", 1, dao.findAllString( Arrays.asList( "test" )).length); 
        assertEquals( "string 11", 2, dao.findAllString( Arrays.asList( "test11" )).length); 
        assertEquals( "string 1, 2", 2, dao.findAllString( Arrays.asList( "test", "test2" )).length); 
        assertEquals( "string 11, 2", 3, dao.findAllString( Arrays.asList( "test11", "test2" )).length); 

        assertEquals( "udate 1", 1, dao.findAllUdate( Arrays.asList( date1 )).length); 
        assertEquals( "udate 11", 2, dao.findAllUdate( Arrays.asList( date11 )).length); 
        assertEquals( "udate 1, 2", 2, dao.findAllUdate( Arrays.asList( date1, date2 )).length); 
        assertEquals( "udate 11, 2", 3, dao.findAllUdate( Arrays.asList( date11, date2 )).length); 

        assertEquals( "sblob 1", 1, dao.findAllStringSblob( Arrays.asList( "stest" )).length); 
        assertEquals( "sblob 11", 2, dao.findAllStringSblob( Arrays.asList( "stest11" )).length); 
        assertEquals( "sblob 1, 2", 2, dao.findAllStringSblob( Arrays.asList( "stest", "stest2" )).length); 
        assertEquals( "sblob 11, 2", 3, dao.findAllStringSblob( Arrays.asList( "stest11", "stest2" )).length); 

        assertEquals( "nblob 1", 1, dao.findAllSblob( Arrays.asList( n1 )).length); 
        assertEquals( "nblob 11", 2, dao.findAllSblob( Arrays.asList( n11 )).length); 
        assertEquals( "nblob 1, 2", 2, dao.findAllSblob( Arrays.asList( n1, n2 )).length); 
        assertEquals( "nblob 11, 2", 3, dao.findAllSblob( Arrays.asList( n11, n2 )).length); 

        assertEquals( "dto 1", 1, dao.findAllDto( Arrays.asList( dto1 )).length); 
        assertEquals( "dto 11", 2, dao.findAllDto( Arrays.asList( dto11 )).length); 
        assertEquals( "dto 1, 2", 2, dao.findAllDto( Arrays.asList( dto1, dto2 )).length); 
        assertEquals( "dto 11, 2", 3, dao.findAllDto( Arrays.asList( dto11, dto2 )).length); 

        assertEquals( "key 1", 1, dao.findAllKey( Arrays.asList( key1 )).length); 
        assertEquals( "key 11", 2, dao.findAllKey( Arrays.asList( key11 )).length); 
        assertEquals( "key 1, 2", 2, dao.findAllKey( Arrays.asList( key1, key2 )).length); 
        assertEquals( "key 11, 2", 3, dao.findAllKey( Arrays.asList( key11, key2 )).length); 

        assertEquals( "geopt 1", 1, dao.findAllGeopt( Arrays.asList( geopt1 )).length); 
        assertEquals( "geopt 11", 2, dao.findAllGeopt( Arrays.asList( geopt11 )).length); 
        assertEquals( "geopt 1, 2", 2, dao.findAllGeopt( Arrays.asList( geopt1, geopt2 )).length); 
        assertEquals( "geopt 11, 2", 3, dao.findAllGeopt( Arrays.asList( geopt11, geopt2 )).length); 

        assertEquals( "user 1", 1, dao.findAllUser( Arrays.asList( user1 )).length); 
        assertEquals( "user 11", 2, dao.findAllUser( Arrays.asList( user11 )).length); 
        assertEquals( "user 1, 2", 2, dao.findAllUser( Arrays.asList( user1, user2 )).length); 
        assertEquals( "user 11, 2", 3, dao.findAllUser( Arrays.asList( user11, user2 )).length); 

        assertEquals( "native1 1", 1, dao.findAllNative1( Arrays.asList( o1 )).length); 
        assertEquals( "native1 11", 2, dao.findAllNative1( Arrays.asList( o11 )).length); 
        assertEquals( "native1 1, 2", 2, dao.findAllNative1( Arrays.asList( o1, o2 )).length); 
        assertEquals( "native1 11, 2", 3, dao.findAllNative1( Arrays.asList( o11, o2 )).length); 

        assertEquals( "native2 1", 1, dao.findAllNative2( Arrays.asList( o1 )).length); 
        assertEquals( "native2 11", 2, dao.findAllNative2( Arrays.asList( o11 )).length); 
        assertEquals( "native2 1, 2", 2, dao.findAllNative2( Arrays.asList( o1, o2 )).length); 
        assertEquals( "native2 11, 2", 3, dao.findAllNative2( Arrays.asList( o11, o2 )).length); 

        assertEquals( "anon1 1", 1, dao.findAllAnon1( Arrays.asList( o1 )).length); 
        assertEquals( "anon1 11", 2, dao.findAllAnon1( Arrays.asList( o11 )).length); 
        assertEquals( "anon1 1, 2", 2, dao.findAllAnon1( Arrays.asList( o1, o2 )).length); 
        assertEquals( "anon1 11, 2", 3, dao.findAllAnon1( Arrays.asList( o11, o2 )).length); 

        assertEquals( "anon2 1", 1, dao.findAllAnon2( Arrays.asList( o1 )).length); 
        assertEquals( "anon2 11", 2, dao.findAllAnon2( Arrays.asList( o11 )).length); 
        assertEquals( "anon2 1, 2", 2, dao.findAllAnon2( Arrays.asList( o1, o2 )).length); 
        assertEquals( "anon2 11, 2", 3, dao.findAllAnon2( Arrays.asList( o11, o2 )).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Props gae empty and unindexed - String
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEmptyUnindexedString() throws DaoException {
        String kind = "GaePropString";
        String[][] values = EMPTY_UNINDEXED_VALS_String;
        GaePropStringDao dao = DaoFactory.createGaePropStringDao();

        long id = dao.insert( setPropsString( values[0] ));
        testEmptyUnindexed( "insert full", kind, id, values[0] );

        dao.update( id, setPropsString( values[1] ));
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        dao.update( id, setPropsString( null ));
        testEmptyUnindexed( "update full->null", kind, id, null );

        dao.update( id, setPropsString( values[1] ));
        testEmptyUnindexed( "update null->full", kind, id, values[1] );

        id = dao.insert( setPropsString( values[2] ));
        testEmptyUnindexed( "insert null", kind, id, values[2] );
    }

    @Test 
    public void testEmptyUnindexedStringCol() throws DaoException {
        String kind = "GaePropStringCol";
        String[][] values = EMPTY_UNINDEXED_VALS_String;
        GaePropStringColDao dao = DaoFactory.createGaePropStringColDao();

        GaePropStringCol dto = new GaePropStringCol();
        dto.setNormalType( values[0][0]);
        dto.setUnindexedType( values[0][1]);
        dto.setNullNormalType( values[0][2]);
        dto.setNullEmptyType( values[0][3]);
        dto.setNullUnindexedType( values[0][4]);
        dto.setNullEmptyUnindexedType( values[0][5]);

        long id = dao.insert( dto ); // full
        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        updateProps( dao, id, null );
        testEmptyUnindexed( "update full->null", kind, id, null );

        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update null->full", kind, id, values[1] );
    }

    private static final String[][] EMPTY_UNINDEXED_VALS_String = {
        { "normal", "unindexed", "null normal", "null empty", "null unindexed", "null empty unindexed" },
        { "norm", "unindex", "null norm", "null emp", "null unindex", "null empty unindex" },
        { "norm", "unindex", null, null, null, null }
    };

    private GaePropString setPropsString( String[] vals ) {
        GaePropString dto = new GaePropString();

        dto.setNormalType( vals != null ? vals[0] : null );
        dto.setUnindexedType( vals != null ? vals[1] : null );
        dto.setNullNormalType( vals != null ? vals[2] : null );
        dto.setNullEmptyType( vals != null ? vals[3] : null );
        dto.setNullUnindexedType( vals != null ? vals[4] : null );
        dto.setNullEmptyUnindexedType( vals != null ? vals[5] : null );

        return dto;
    }

    private void updateProps( GaePropStringColDao dao, long id, String[] vals ) throws DaoException {
        if (vals != null) dao.updateNormalType( id, vals[ 0 ]);
        if (vals != null) dao.updateUnindexedType( id, vals[ 1 ]);
        dao.updateNullNormalType( id, vals != null ? vals[ 2 ] : null);
        dao.updateNullEmptyType( id, vals != null ? vals[ 3 ] : null);
        dao.updateNullUnindexedType( id, vals != null ? vals[ 4 ] : null);
        dao.updateNullEmptyUnindexedType( id, vals != null ? vals[ 5 ] : null);
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Props gae empty and unindexed - Long
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEmptyUnindexedLong() throws DaoException {
        String kind = "GaePropLong";
        Long[][] values = EMPTY_UNINDEXED_VALS_Long;
        GaePropLongDao dao = DaoFactory.createGaePropLongDao();

        long id = dao.insert( setPropsLong( values[0] ));
        testEmptyUnindexed( "insert full", kind, id, values[0] );

        dao.update( id, setPropsLong( values[1] ));
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        dao.update( id, setPropsLong( null ));
        testEmptyUnindexed( "update full->null", kind, id, null );

        dao.update( id, setPropsLong( values[1] ));
        testEmptyUnindexed( "update null->full", kind, id, values[1] );

        id = dao.insert( setPropsLong( values[2] ));
        testEmptyUnindexed( "insert null", kind, id, values[2] );
    }

    @Test 
    public void testEmptyUnindexedLongCol() throws DaoException {
        String kind = "GaePropLongCol";
        Long[][] values = EMPTY_UNINDEXED_VALS_Long;
        GaePropLongColDao dao = DaoFactory.createGaePropLongColDao();

        GaePropLongCol dto = new GaePropLongCol();
        dto.setNormalType( values[0][0]);
        dto.setUnindexedType( values[0][1]);
        dto.setNullNormalType( values[0][2]);
        dto.setNullEmptyType( values[0][3]);
        dto.setNullUnindexedType( values[0][4]);
        dto.setNullEmptyUnindexedType( values[0][5]);

        long id = dao.insert( dto ); // full
        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        updateProps( dao, id, null );
        testEmptyUnindexed( "update full->null", kind, id, null );

        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update null->full", kind, id, values[1] );
    }

    private static final Long[][] EMPTY_UNINDEXED_VALS_Long = {
        { 1L, 2L, 3L, 4L, 5L, 6L },
        { 10L, 20L, 30L, 40L, 50L, 60L},
        { 100L, 200L, null, null, null, null}
    };

    private GaePropLong setPropsLong( Long[] vals ) {
        GaePropLong dto = new GaePropLong();

        dto.setNormalType( vals != null ? vals[0] : null );
        dto.setUnindexedType( vals != null ? vals[1] : null );
        dto.setNullNormalType( vals != null ? vals[2] : null );
        dto.setNullEmptyType( vals != null ? vals[3] : null );
        dto.setNullUnindexedType( vals != null ? vals[4] : null );
        dto.setNullEmptyUnindexedType( vals != null ? vals[5] : null );

        return dto;
    }

    private void updateProps( GaePropLongColDao dao, long id, Long[] vals ) throws DaoException {
        if (vals != null) dao.updateNormalType( id, vals[ 0 ]);
        if (vals != null) dao.updateUnindexedType( id, vals[ 1 ]);
        dao.updateNullNormalType( id, vals != null ? vals[ 2 ] : null);
        dao.updateNullEmptyType( id, vals != null ? vals[ 3 ] : null);
        dao.updateNullUnindexedType( id, vals != null ? vals[ 4 ] : null);
        dao.updateNullEmptyUnindexedType( id, vals != null ? vals[ 5 ] : null);
    }



    ////////////////////////////////////////////////////////////////////////////
    // Tests - Props gae empty and unindexed - Enum
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEmptyUnindexedEnum() throws DaoException {
        String kind = "GaePropEnum";
        GaePropEnum.NormalType[][] values = EMPTY_UNINDEXED_VALS_Enum;
        GaePropEnumDao dao = DaoFactory.createGaePropEnumDao();

        long id = dao.insert( setPropsEnum( values[0] ));
        testEmptyUnindexed( "insert full", kind, id, values[0], false, true );

        dao.update( id, setPropsEnum( values[1] ));
        testEmptyUnindexed( "update full->full", kind, id, values[1], false, true );

        dao.update( id, setPropsEnum( null ));
        testEmptyUnindexed( "update full->null", kind, id, null, false, true );

        dao.update( id, setPropsEnum( values[1] ));
        testEmptyUnindexed( "update null->full", kind, id, values[1], false, true );

        id = dao.insert( setPropsEnum( values[2] ));
        testEmptyUnindexed( "insert null", kind, id, values[2], false, true );
    }

    @Test 
    public void testEmptyUnindexedEnumCol() throws DaoException {
        String kind = "GaePropEnumCol";
        GaePropEnum.NormalType[][] values = EMPTY_UNINDEXED_VALS_Enum;
        GaePropEnumColDao dao = DaoFactory.createGaePropEnumColDao();

        GaePropEnumCol dto = new GaePropEnumCol();
        dto.setNormalType( values[0][0]);
        dto.setUnindexedType( values[0][1]);
        dto.setNullNormalType( values[0][2]);
        dto.setNullEmptyType( values[0][3]);
        dto.setNullUnindexedType( values[0][4]);
        dto.setNullEmptyUnindexedType( values[0][5]);

        long id = dao.insert( dto ); // full
        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update full->full", kind, id, values[1], false, true );

        updateProps( dao, id, null );
        testEmptyUnindexed( "update full->null", kind, id, null, false, true );

        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update null->full", kind, id, values[1], false, true );
    }

    private static final GaePropEnum.NormalType[][] EMPTY_UNINDEXED_VALS_Enum = {
        { GaePropEnum.NormalType.A, GaePropEnum.NormalType.B, GaePropEnum.NormalType.C,
            GaePropEnum.NormalType.D, GaePropEnum.NormalType.E, GaePropEnum.NormalType.F },
        { GaePropEnum.NormalType.B, GaePropEnum.NormalType.C, GaePropEnum.NormalType.D,
            GaePropEnum.NormalType.E, GaePropEnum.NormalType.F, GaePropEnum.NormalType.A },
        { GaePropEnum.NormalType.B, GaePropEnum.NormalType.C, null, null, null, null }
    };

    private GaePropEnum setPropsEnum( GaePropEnum.NormalType[] vals ) {
        GaePropEnum dto = new GaePropEnum();

        dto.setNormalType( vals != null ? vals[0] : null );
        dto.setUnindexedType( vals != null ? vals[1] : null );
        dto.setNullNormalType( vals != null ? vals[2] : null );
        dto.setNullEmptyType( vals != null ? vals[3] : null );
        dto.setNullUnindexedType( vals != null ? vals[4] : null );
        dto.setNullEmptyUnindexedType( vals != null ? vals[5] : null );

        return dto;
    }

    private void updateProps( GaePropEnumColDao dao, long id, GaePropEnum.NormalType[] vals ) throws DaoException {
        if (vals != null) dao.updateNormalType( id, vals[ 0 ]);
        if (vals != null) dao.updateUnindexedType( id, vals[ 1 ]);
        dao.updateNullNormalType( id, vals != null ? vals[ 2 ] : null);
        dao.updateNullEmptyType( id, vals != null ? vals[ 3 ] : null);
        dao.updateNullUnindexedType( id, vals != null ? vals[ 4 ] : null);
        dao.updateNullEmptyUnindexedType( id, vals != null ? vals[ 5 ] : null);
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Props gae empty and unindexed - Date
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEmptyUnindexedDate() throws DaoException {
        String kind = "GaePropDate";
        java.util.Date[][] values = EMPTY_UNINDEXED_VALS_Date;
        GaePropDateDao dao = DaoFactory.createGaePropDateDao();

        long id = dao.insert( setPropsDate( values[0] ));
        testEmptyUnindexed( "insert full", kind, id, values[0] );

        dao.update( id, setPropsDate( values[1] ));
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        dao.update( id, setPropsDate( null ));
        testEmptyUnindexed( "update full->null", kind, id, null );

        dao.update( id, setPropsDate( values[1] ));
        testEmptyUnindexed( "update null->full", kind, id, values[1] );

        id = dao.insert( setPropsDate( values[2] ));
        testEmptyUnindexed( "insert null", kind, id, values[2] );
    }

    @Test 
    public void testEmptyUnindexedDateCol() throws DaoException {
        String kind = "GaePropDateCol";
        java.util.Date[][] values = EMPTY_UNINDEXED_VALS_Date;
        GaePropDateColDao dao = DaoFactory.createGaePropDateColDao();

        GaePropDateCol dto = new GaePropDateCol();
        dto.setNormalType( values[0][0]);
        dto.setUnindexedType( values[0][1]);
        dto.setNullNormalType( values[0][2]);
        dto.setNullEmptyType( values[0][3]);
        dto.setNullUnindexedType( values[0][4]);
        dto.setNullEmptyUnindexedType( values[0][5]);

        long id = dao.insert( dto ); // full
        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        updateProps( dao, id, null );
        testEmptyUnindexed( "update full->null", kind, id, null );

        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update null->full", kind, id, values[1] );
    }

    private static final java.util.Date[][] EMPTY_UNINDEXED_VALS_Date = {
        { date("2010-03-25"), date("2010-03-24"), date("2010-03-23"),
            date("2010-03-22"), date("2010-03-21"), date("2010-03-20") },
        { date("2010-02-25"), date("2010-02-24"), date("2010-02-23"),
            date("2010-02-22"), date("2010-02-21"), date("2010-02-20") },
        { date("2010-02-25"), date("2010-02-24"), null, null, null, null }
    };

    private GaePropDate setPropsDate( java.util.Date[] vals ) {
        GaePropDate dto = new GaePropDate();

        dto.setNormalType( vals != null ? vals[0] : null );
        dto.setUnindexedType( vals != null ? vals[1] : null );
        dto.setNullNormalType( vals != null ? vals[2] : null );
        dto.setNullEmptyType( vals != null ? vals[3] : null );
        dto.setNullUnindexedType( vals != null ? vals[4] : null );
        dto.setNullEmptyUnindexedType( vals != null ? vals[5] : null );

        return dto;
    }

    private void updateProps( GaePropDateColDao dao, long id, java.util.Date[] vals ) throws DaoException {
        if (vals != null) dao.updateNormalType( id, sqlDate( vals[ 0 ]));
        if (vals != null) dao.updateUnindexedType( id, sqlDate( vals[ 1 ]));
        dao.updateNullNormalType( id, vals != null ? sqlDate( vals[ 2 ]) : null);
        dao.updateNullEmptyType( id, vals != null ? sqlDate( vals[ 3 ]) : null);
        dao.updateNullUnindexedType( id, vals != null ? sqlDate( vals[ 4 ]) : null);
        dao.updateNullEmptyUnindexedType( id, vals != null ? sqlDate( vals[ 5 ]) : null);
    }



    ////////////////////////////////////////////////////////////////////////////
    // Tests - Props gae empty and unindexed - Text
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEmptyText() throws DaoException {
        String kind = "GaePropText";
        String[][] values = EMPTY_UNINDEXED_VALS_String;
        GaePropTextDao dao = DaoFactory.createGaePropTextDao();

        long id = dao.insert( setPropsText( values[0] ));
        testEmpty( "insert full", kind, id, values[0] );

        dao.update( id, setPropsText( values[1] ));
        testEmpty( "update full->full", kind, id, values[1] );

        dao.update( id, setPropsText( null ));
        testEmpty( "update full->null", kind, id, null );

        dao.update( id, setPropsText( values[1] ));
        testEmpty( "update null->full", kind, id, values[1] );

        id = dao.insert( setPropsText( values[2] ));
        testEmpty( "insert null", kind, id, values[2] );
    }

    @Test 
    public void testEmptyTextCol() throws DaoException {
        String kind = "GaePropTextCol";
        String[][] values = EMPTY_UNINDEXED_VALS_String;
        GaePropTextColDao dao = DaoFactory.createGaePropTextColDao();

        GaePropTextCol dto = new GaePropTextCol();
        dto.setNormalType( values[0][0]);
        dto.setUnindexedType( values[0][1]);
        dto.setNullNormalType( values[0][2]);
        dto.setNullEmptyType( values[0][3]);
        dto.setNullUnindexedType( values[0][4]);
        dto.setNullEmptyUnindexedType( values[0][5]);

        long id = dao.insert( dto ); // full
        updateProps( dao, id, values[1] );
        testEmpty( "update full->full", kind, id, values[1] );

        updateProps( dao, id, null );
        testEmpty( "update full->null", kind, id, null );

        updateProps( dao, id, values[1] );
        testEmpty( "update null->full", kind, id, values[1] );
    }

    private GaePropText setPropsText( String[] vals ) {
        GaePropText dto = new GaePropText();

        dto.setNormalType( vals != null ? vals[0] : null );
        dto.setUnindexedType( vals != null ? vals[1] : null );
        dto.setNullNormalType( vals != null ? vals[2] : null );
        dto.setNullEmptyType( vals != null ? vals[3] : null );
        dto.setNullUnindexedType( vals != null ? vals[4] : null );
        dto.setNullEmptyUnindexedType( vals != null ? vals[5] : null );

        return dto;
    }

    private void updateProps( GaePropTextColDao dao, long id, String[] vals ) throws DaoException {
        if (vals != null) dao.updateNormalType( id, vals[ 0 ]);
        if (vals != null) dao.updateUnindexedType( id, vals[ 1 ]);
        dao.updateNullNormalType( id, vals != null ? vals[ 2 ] : null);
        dao.updateNullEmptyType( id, vals != null ? vals[ 3 ] : null);
        dao.updateNullUnindexedType( id, vals != null ? vals[ 4 ] : null);
        dao.updateNullEmptyUnindexedType( id, vals != null ? vals[ 5 ] : null);
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Props gae empty and unindexed - Serializable - ShortBlob
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEmptyUnindexedSerializable() throws DaoException {
        String kind = "GaePropSerializable";
        String[][] values = EMPTY_UNINDEXED_VALS_String;
        GaePropSerializableDao dao = DaoFactory.createGaePropSerializableDao();

        long id = dao.insert( setPropsSerializable( values[0] ));
        testEmptyUnindexed( "insert full", kind, id, values[0] );

        dao.update( id, setPropsSerializable( values[1] ));
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        dao.update( id, setPropsSerializable( null ));
        testEmptyUnindexed( "update full->null", kind, id, null );

        dao.update( id, setPropsSerializable( values[1] ));
        testEmptyUnindexed( "update null->full", kind, id, values[1] );

        id = dao.insert( setPropsSerializable( values[2] ));
        testEmptyUnindexed( "insert null", kind, id, values[2] );
    }

    @Test 
    public void testEmptyUnindexedSerializableCol() throws DaoException {
        String kind = "GaePropSerializableCol";
        String[][] values = EMPTY_UNINDEXED_VALS_String;
        GaePropSerializableColDao dao = DaoFactory.createGaePropSerializableColDao();

        GaePropSerializableCol dto = new GaePropSerializableCol();
        dto.setNormalType( values[0][0]);
        dto.setUnindexedType( values[0][1]);
        dto.setNullNormalType( values[0][2]);
        dto.setNullEmptyType( values[0][3]);
        dto.setNullUnindexedType( values[0][4]);
        dto.setNullEmptyUnindexedType( values[0][5]);

        long id = dao.insert( dto ); // full
        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update full->full", kind, id, values[1] );

        updateProps( dao, id, null );
        testEmptyUnindexed( "update full->null", kind, id, null );

        updateProps( dao, id, values[1] );
        testEmptyUnindexed( "update null->full", kind, id, values[1] );
    }

    private GaePropSerializable setPropsSerializable( String[] vals ) {
        GaePropSerializable dto = new GaePropSerializable();

        dto.setNormalType( vals != null ? vals[0] : null );
        dto.setUnindexedType( vals != null ? vals[1] : null );
        dto.setNullNormalType( vals != null ? vals[2] : null );
        dto.setNullEmptyType( vals != null ? vals[3] : null );
        dto.setNullUnindexedType( vals != null ? vals[4] : null );
        dto.setNullEmptyUnindexedType( vals != null ? vals[5] : null );

        return dto;
    }

    private void updateProps( GaePropSerializableColDao dao, long id, String[] vals ) throws DaoException {
        if (vals != null) dao.updateNormalType( id, vals[ 0 ]);
        if (vals != null) dao.updateUnindexedType( id, vals[ 1 ]);
        dao.updateNullNormalType( id, vals != null ? vals[ 2 ] : null);
        dao.updateNullEmptyType( id, vals != null ? vals[ 3 ] : null);
        dao.updateNullUnindexedType( id, vals != null ? vals[ 4 ] : null);
        dao.updateNullEmptyUnindexedType( id, vals != null ? vals[ 5 ] : null);
    }



    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private static final String[] EMPTY_UNINDEXED_PROPS = {
        "normalType", "unindexedType", "nullNormalType", "nullEmptyType",
        "nullUnindexedType", "nullEmptyUnindexedType"
    };

    private HashMap<String,Object> indexedProps = new HashMap<String,Object>();

    private void testEmpty( String msg, String kind, long id, Object[] values) {
        testEmptyUnindexed( msg, kind, id, values, true, false );
    }

    private void testEmptyUnindexed( String msg, String kind, long id, Object[] values) {
        testEmptyUnindexed( msg, kind, id, values, true, true );
    }

    private void testEmptyUnindexed( String msg, String kind, long id, Object[] values,
                                     boolean testEquals, boolean testUnindexed) {
        indexedProps.clear();

        Entity ent = entityGet( kind, id );
        DataTypeTranslator.extractIndexedPropertiesFromPb(
            EntityTranslator.convertToPb( ent ), indexedProps );

        for (int i=0; i < EMPTY_UNINDEXED_PROPS.length; i++) {
            Object val = values != null ? values[ i ] : null;
            boolean shouldBeNull = val == null;
            if (shouldBeNull && i < 2) continue; // not-null after no update 

            String propName = EMPTY_UNINDEXED_PROPS[ i ];
            Object propVal = ent.getProperty( propName );

            boolean isEmpty = !ent.hasProperty( propName );
            boolean isNull = propVal == null;
            log.debug( "EMPTY " + propName + " " + val + " " + isEmpty );

            assertFalse( msg + " | null/full fail " + propName, shouldBeNull ^ isNull);
            assertFalse( msg + " | empty/filled fail " + propName,
                isEmpty ^ (shouldBeNull && (i > 2)));

            if (isEmpty) continue;

            if (propVal == null) {
            }
            else if (propVal instanceof Text) {
                propVal = ((Text)propVal).getValue();
            }
            else if (propVal instanceof ShortBlob) {
                propVal = deserialize(((ShortBlob)propVal).getBytes());
            }

            if (testEquals) assertEquals( msg + " | equals", val, propVal );

            if (testUnindexed) {
                boolean isIndexed = indexedProps.containsKey( propName );

                assertFalse( msg + " | (un)indexed fail " + propName, isIndexed ^ (i == 0 || i == 2 || i == 3));
                log.debug( "INDEXED " + propName + " " + isIndexed );
            }
        }
    }

    private Entity entityGet( String kind, long id ) {
        try {
            return gae.ds.get( KeyFactory.createKey( kind, id ));
        }
        catch (Exception e) {
            throw new RuntimeException( e );
        }
    }


    private void establishEntities() {
    }

    private Object deserialize( byte[] bytes ) {
        if (bytes == null) return null;

        try {
            java.io.ByteArrayInputStream bis = new java.io.ByteArrayInputStream( bytes );
            java.io.ObjectInputStream ois = new java.io.ObjectInputStream( bis );

            return ois.readObject();
        }
        catch (Exception e) {
            throw new RuntimeException( e );
        }
    }

}

