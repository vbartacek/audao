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
package com.spoledge.audao.test.gwt;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

import com.google.appengine.api.datastore.*;
import com.google.appengine.api.users.User;

import com.google.gwt.user.client.rpc.SerializationException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.test.gae.dto.*;

import com.spoledge.audao.test.AbstractTest;
import com.spoledge.audao.test.gae.GaeUtil;


public class SerializationServerTest extends AbstractTest {

    private GWTSerializationEmulator emul = new GWTSerializationEmulator();
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
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testSimpleEmpty() throws SerializationException {
        GaeGeneralTest dto = new GaeGeneralTest();

        test( "empty", dto );
    }


    @Test 
    public void testSimpleTransient() throws SerializationException {
        GaeGeneralTest dto = new GaeGeneralTest();
        dto.setIsActive( true );
        dto.setIsCustom( false );
        dto.setFlags( 1 );
        dto.setNumber( 2 );

        GaeGeneralTest dtoAfter = new GaeGeneralTest();
        dtoAfter.setNumber( 2 );

        test( "transient", dto, dtoAfter );
    }


    @Test 
    public void testSimpleFull() throws SerializationException {
        GaeGqlSimple dto = new GaeGqlSimple();
        dto.setBooleanType( true );
        dto.setShortType( (short)1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1d );
        dto.setEnumTypePlain( GaeGqlSimple.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( GaeGqlSimple.EnumTypeCustom.TYPE_B );
        dto.setStringType( "Hello" );
        dto.setDateType( sqlDate( "2010-03-18" ));
        dto.setTimestampType( sqlTimestamp( "2010-03-18 17:25:45" ));
        dto.setSblobType( new byte[]{ (byte)0, (byte)2 });
        dto.setSerializableType( "Bye" );

        GaeDto dd = new GaeDto();
        dd.setPropA( "A" );
        dto.setDtoType( dd );

        test( "empty", dto );
    }


    @Test 
    public void testSimpleModifiedNull() throws SerializationException {
        GaeGeneralTest dto = new GaeGeneralTest();

        assertFalse( "not modified", dto.isDescriptionModified());
        dto.setDescription( null );
        assertTrue( "modified", dto.isDescriptionModified());

        GaeGeneralTest dto2 = test( "modified", dto );

        // sanity test - equality for "modified" attributes:
        assertTrue( "equality 'full'", dto2.isDescriptionModified());
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Google
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testGoogleString() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setStringType( "Hello" );

        test( "string", dto );
    }

    @Test 
    public void testGoogleCategory() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setCategoryType( new Category( "good" ));

        test( "category", dto );
    }

    @Test 
    public void testGoogleEmail() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setEmailType( new Email( "audao@spoledge.com" ));

        test( "email", dto );
    }

    @Test 
    public void testGoogleGeoPt() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setGeoptType( new GeoPt( -12.34f, 53.43f ));

        test( "geo", dto );
    }

    @Test 
    public void testGoogleIMHandle() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setImHandleType( new IMHandle( IMHandle.Scheme.xmpp, "login.icq.com" ));

        test( "imhandle", dto );
    }


    @Test 
    public void testGoogleKey() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setKeyType( KeyFactory.createKey( "MyEntity", "name" ));
        test( "simple name", dto );

        dto.setKeyType( KeyFactory.createKey( "MyEntity", 101L ));
        test( "simple id", dto );

        dto.setKeyType( new KeyFactory.Builder( "Ent1", 101L ).addChild( "Ent2", 201L).getKey());
        test( "duo id", dto );

        dto.setKeyType( new KeyFactory.Builder( "Ent1", 101L )
                            .addChild( "Ent2", 201L )
                            .addChild( "Ent3", 301L ).getKey());
        test( "trio id", dto );

        dto.setKeyType( new KeyFactory.Builder( "Ent1", "name1" ).addChild( "Ent2", "name2" ).getKey());
        test( "duo name", dto );

        dto.setKeyType( new KeyFactory.Builder( "Ent1", "name1" )
                            .addChild( "Ent2", "name2" )
                            .addChild( "Ent3", "name3" ).getKey());
        test( "trio name", dto );

        dto.setKeyType( new KeyFactory.Builder( "Ent1", 101L )
                            .addChild( "Ent2", "name2" )
                            .addChild( "Ent3", 301L ).getKey());
        test( "trio id/name", dto );

        dto.setKeyType( new Entity( "MyEntity" ).getKey());
        testKeyIncomplete( "simple incomplete", dto );

        dto.setKeyType( new Entity( "MyEntity", KeyFactory.createKey( "Parent", 101L )).getKey());
        testKeyIncomplete( "duo incomplete", dto );
    }


    @Test 
    public void testGoogleLink() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setLinkType( new Link( "http://audao.spoledge.com" ));

        test( "link", dto );
    }


    @Test 
    public void testGooglePhoneNumber() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setPhoneNumberType( new PhoneNumber( "+420123456789" ));

        test( "phone", dto );
    }

    @Test 
    public void testGooglePostalAddress() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setPostalAddressType( new PostalAddress( "good" ));

        test( "postal address", dto );
    }

    @Test 
    public void testGoogleRating() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setRatingType( new Rating( 11 ));

        test( "rating", dto );
    }


    @Test 
    public void testGoogleUser() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();

        dto.setUserType( new User( "audao@spoledge.com", "gmail.com" ));
        test( "gmail no-userid", dto );

        dto.setUserType( new User( "audao@spoledge.com", "gmail.com", "asdfghjkl" ));
        test( "gmail userid", dto );

        dto.setUserType( new User( "audao@spoledge.com", "spoledge.com" ));
        test( "spoledge no-userid", dto );

        dto.setUserType( new User( "audao@spoledge.com", "spoledge.com", "asdfghjkl" ));
        test( "`spoledge userid", dto );
    }


    @Test 
    public void testGoogleFull() throws SerializationException {
        GaeDtoGoogle dto = new GaeDtoGoogle();
        dto.setStringType( "Hello" );
        dto.setStringSblobType( "Hello Sblob" );
        dto.setCategoryType( new Category( "good" ));
        dto.setEmailType( new Email( "audao@spoledge.com" ));
        dto.setGeoptType( new GeoPt( 10f, 20f ));
        dto.setImHandleType( new IMHandle( IMHandle.Scheme.xmpp, "login.icq.com" ));
        dto.setKeyType( KeyFactory.createKey( "Foo", 1 )); // needs GAE environment
        dto.setLinkType( new Link( "http://audao.spoledge.com" ));
        dto.setPhoneNumberType( new PhoneNumber( "+420123456789" ));
        dto.setPostalAddressType( new PostalAddress( "good" ));
        dto.setRatingType( new Rating( 11 ));
        dto.setUserType( new User( "foo@bar.com", "gmail.com" ));

        test( "full", dto );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Lists - basic types
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testListBoolean() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setBooleanType( Arrays.asList( true, true, false, null ));
        test( "boolean", dto );
    }

    @Test 
    public void testListShort() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setShortType( Arrays.asList( (short) 1, (short) 2, (short) 3));
        test( "short", dto );
    }

    @Test 
    public void testListInt() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setIntType( Arrays.asList( null, 10, 20, 30, 40 ));
        test( "int", dto );
    }

    @Test 
    public void testListLong() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setLongType( Arrays.asList( 100L, 200L, 300L, null, 400L ));
        test( "long", dto );
    }

    @Test 
    public void testListDouble() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setDoubleType( Arrays.asList( 0.1, 0.2, null, 0.3, 0.4 ));
        test( "double", dto );
    }

    @Test 
    public void testListString() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setStringType( Arrays.asList( "Hello", "Mr", "Proper", "!" ));
        test( "string", dto );

        dto.setStringType( Arrays.asList( "Hello", "Mr", null, "!" ));
        test( "null", dto );
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Lists - google types
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testListCategory() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setCategoryType( Arrays.asList( new Category("google"), new Category("java")));

        test( "category", dto );
    }

    @Test 
    public void testListEmail() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setEmailType( Arrays.asList( new Email( "audao@spoledge.com" ), null ));

        test( "email", dto );
    }

    @Test 
    public void testListGeoPt() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setGeoptType( Arrays.asList( new GeoPt( -12.34f, 53.43f )));

        test( "geo", dto );
    }

    @Test 
    public void testListIMHandle() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setImHandleType( Arrays.asList( new IMHandle( IMHandle.Scheme.xmpp, "login.icq.com" )));

        test( "imhandle", dto );
    }


    @Test 
    public void testListKey() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setKeyType(
            Arrays.asList(
                KeyFactory.createKey( "MyEntity", "name" ),
                KeyFactory.createKey( "MyEntity", 101L ),
                new KeyFactory.Builder( "Ent1", 101L ).addChild( "Ent2", 201L).getKey(),
                new KeyFactory.Builder( "Ent1", 101L )
                            .addChild( "Ent2", 201L )
                            .addChild( "Ent3", 301L ).getKey(),
                new KeyFactory.Builder( "Ent1", "name1" ).addChild( "Ent2", "name2" ).getKey(),
                new KeyFactory.Builder( "Ent1", "name1" )
                            .addChild( "Ent2", "name2" )
                            .addChild( "Ent3", "name3" ).getKey(),
                new KeyFactory.Builder( "Ent1", 101L )
                            .addChild( "Ent2", "name2" )
                            .addChild( "Ent3", 301L ).getKey()));
        test( "keys", dto );

        dto.setKeyType(
            Arrays.asList(
                new Entity( "MyEntity" ).getKey(),
                new Entity( "MyEntity", KeyFactory.createKey( "Parent", 101L )).getKey()));
        testKeyIncomplete( "incomplete", dto );
    }


    @Test 
    public void testListLink() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setLinkType( Arrays.asList( new Link( "http://audao.spoledge.com" )));

        test( "link", dto );
    }


    @Test 
    public void testListPhoneNumber() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setPhoneNumberType( Arrays.asList( new PhoneNumber( "+420123456789" )));

        test( "phone", dto );
    }

    @Test 
    public void testListPostalAddress() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setPostalAddressType( Arrays.asList( new PostalAddress( "good" )));

        test( "postal address", dto );
    }

    @Test 
    public void testListRating() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setRatingType( Arrays.asList( new Rating( 11 )));

        test( "rating", dto );
    }


    @Test 
    public void testListUser() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();

        dto.setUserType(
            Arrays.asList(
                new User( "audao@spoledge.com", "gmail.com" ),
                new User( "audao@spoledge.com", "gmail.com", "asdfghjkl" ),
                new User( "audao@spoledge.com", "spoledge.com" ),
                new User( "audao@spoledge.com", "spoledge.com", "asdfghjkl" )));

        test( "spoledge userid", dto );
    }


    @Test 
    public void testListFull() throws SerializationException {
        GaeDtoList dto = new GaeDtoList();
        dto.setStringType( Arrays.asList( "Hello" ));
        dto.setStringSblobType( Arrays.asList( "Hello Sblob" ));
        dto.setCategoryType( Arrays.asList( new Category( "good" )));
        dto.setEmailType( Arrays.asList( new Email( "audao@spoledge.com" )));
        dto.setGeoptType( Arrays.asList( new GeoPt( 10f, 20f )));
        dto.setImHandleType( Arrays.asList( new IMHandle( IMHandle.Scheme.xmpp, "login.icq.com" )));
        dto.setKeyType( Arrays.asList( KeyFactory.createKey( "Foo", 1 ))); // needs GAE environment
        dto.setLinkType( Arrays.asList( new Link( "http://audao.spoledge.com" )));
        dto.setPhoneNumberType( Arrays.asList( new PhoneNumber( "+420123456789" )));
        dto.setPostalAddressType( Arrays.asList( new PostalAddress( "good" )));
        dto.setRatingType( Arrays.asList( new Rating( 11 )));
        dto.setUserType( Arrays.asList( new User( "foo@bar.com", "gmail.com" )));

        test( "full", dto );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Google Parent Keys
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testParentKey01() throws SerializationException {
        GaeKeyService dto = new GaeKeyService();
        dto.setUserId( 101L );
        dto.setProductId( 11L );
        dto.setServiceId( 1001L );

        test( "service", dto );
    }

    @Test 
    public void testParentKey02() throws SerializationException {
        GaeKeyAttr dto = new GaeKeyAttr();
        dto.setUserId( 101L );
        dto.setProductId( 11L );
        dto.setServiceId( 1001L );
        dto.setAttrId( 10001L );

        test( "attr", dto );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private <T> T test( String msg, T orig ) throws SerializationException {
        T o = emul.passThrough( orig );
        assertEquals( msg, orig, o );
        return o;
    }


    private <T> T test( String msg, T orig, T after ) throws SerializationException {
        T o = emul.passThrough( orig );
        assertEquals( msg, after, o );
        return o;
    }


    private void testKeyIncomplete( String msg, GaeDtoGoogle dto ) throws SerializationException {
        GaeDtoGoogle dto2 = emul.passThrough( dto );
        equals( msg, dto.getKeyType(), dto2.getKeyType());
    }


    private void testKeyIncomplete( String msg, GaeDtoList dto ) throws SerializationException {
        GaeDtoList dto2 = emul.passThrough( dto );
        List<Key> listOrig = dto.getKeyType();
        List<Key> list = dto2.getKeyType();

        assertTrue( msg, listOrig.size() == list.size());

        for (int i=0; i < listOrig.size(); i++) {
            equals( msg, listOrig.get( i ),  list.get( i ));
        }
    }


    private void equals( String msg, Key orig, Key o ) {
        Key parentOrig = orig.getParent();
        Key parentO = o.getParent();

        if (parentOrig != null) {
            assertEquals( msg, parentOrig, parentO );
        }
        else assertFalse( msg, parentOrig != null );

        if (orig.isComplete()) assertEquals( msg, orig, o );
        else assertTrue( msg, !o.isComplete() && orig.getKind().equals( o.getKind()));
    }

}
