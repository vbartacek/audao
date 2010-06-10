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
package com.spoledge.audao.test;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.db.dao.DaoException;

import com.spoledge.audao.test.blob.dao.*;
import com.spoledge.audao.test.blob.dto.*;


public class AbstractBlobTest extends AbstractTest {

    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testBlobArray01() throws DaoException {
        BlobArray dto = new BlobArray();
        dto.setName( "test-01" );

        dto.setTinyArray( bytes("Hello") );
        dto.setShortArray( bytes("Hello World") );
        dto.setNormalArray( bytes("Hello World...") );

        BlobArrayDao dao = DaoFactory.createBlobArrayDao();

        dao.insert( dto );

        BlobArray dbDto = dao.findByName( "test-01" );
        assertTrue( "tiny", equals( dto.getTinyArray(), dbDto.getTinyArray()));
        assertTrue( "short", equals( dto.getShortArray(), dbDto.getShortArray()));
        assertTrue( "normal", equals( dto.getNormalArray(), dbDto.getNormalArray()));

        assertEquals( "Index shortArray = Hello World", 1, dao.findByShortArray( dto.getShortArray()).length); 
        assertEquals( "Index shortArray = bla", 0, dao.findByShortArray( bytes("bla")).length); 
        assertEquals( "Cond shortArray = Hello World", 1, dao.findByShortArrayCond( dto.getShortArray()).length); 
        assertEquals( "Cond shortArray = bla", 0, dao.findByShortArrayCond( bytes("bla")).length); 

        log.debug("DB object=" + dbDto);
    }


    /**
     * Tests Medium array separately - Oracle can have one LONG column at most.
     */
    @Test 
    public void testBlobArray02() throws DaoException {
        BlobArrayMedium dto = new BlobArrayMedium();
        dto.setName( "test-02" );

        byte[] arr = new byte[ 65536 ];
        for (int i=0; i < arr.length; i++) arr[i] = (byte)i;

        dto.setMediumArray( arr );

        BlobArrayMediumDao dao = DaoFactory.createBlobArrayMediumDao();

        dao.insert( dto );

        BlobArrayMedium dbDto = dao.findByName( "test-02" );
        assertTrue( "medium", equals( dto.getMediumArray(), dbDto.getMediumArray()));
        assertNotSame( "medium", dto.getMediumArray(), dbDto.getMediumArray());

        log.debug("DB object=" + dbDto);
    }


    /**
     * Tests DAO check for max-length.
     */
    @Test( expected = DaoException.class )
    public void testBlobArray03() throws DaoException {
        BlobArrayMedium dto = new BlobArrayMedium();
        dto.setName( "test-03" );

        byte[] arr = new byte[ 65537 ];
        dto.setMediumArray( arr );

        BlobArrayMediumDao dao = DaoFactory.createBlobArrayMediumDao();

        dao.insert( dto );
    }


    /**
     * Tests update.
     */
    @Test 
    public void testBlobArray04() throws DaoException {
        BlobArray dto = new BlobArray();
        dto.setName( "test-04" );

        dto.setTinyArray( bytes("Hello") );
        dto.setShortArray( bytes("Hello World") );
        dto.setNormalArray( bytes("Hello World...") );

        BlobArrayDao dao = DaoFactory.createBlobArrayDao();

        dao.insert( dto );

        BlobArray dto2 = new BlobArray();
        dto2.setTinyArray( bytes("Hello2") );
        dto2.setNormalArray( bytes("Hello World...2") );

        dao.update( dto.getBlobArrId(), dto2 );

        BlobArray dbDto = dao.findByName( "test-04" );
        assertTrue( "tiny", equals( dto2.getTinyArray(), dbDto.getTinyArray()));
        assertTrue( "short", equals( dto.getShortArray(), dbDto.getShortArray()));
        assertTrue( "normal", equals( dto2.getNormalArray(), dbDto.getNormalArray()));

        BlobArray dto3 = new BlobArray();
        dto3.setTinyArray( null );

        dao.update( dto.getBlobArrId(), dto3 );

        dbDto = dao.findByName( "test-04" );
        assertTrue( "tiny", equals( dto3.getTinyArray(), dbDto.getTinyArray()));
        assertTrue( "short", equals( dto.getShortArray(), dbDto.getShortArray()));
        assertTrue( "normal", equals( dto2.getNormalArray(), dbDto.getNormalArray()));
    }


    /**
     * Tests DAO check for max-length - in update.
     */
    @Test( expected = DaoException.class )
    public void testBlobArray05() throws DaoException {
        BlobArrayMedium dto = new BlobArrayMedium();
        dto.setName( "test-05" );

        BlobArrayMediumDao dao = DaoFactory.createBlobArrayMediumDao();

        dao.insert( dto );

        BlobArrayMedium dto2 = new BlobArrayMedium();
        dto2.setMediumArray( new byte[ 65537 ]);

        dao.update( dto.getBlobArrId(), dto2 );
    }


    /**
     * Tests update - by column.
     */
    @Test 
    public void testBlobArray06() throws DaoException {
        BlobArrayCol dto = new BlobArrayCol();
        dto.setName( "test-06" );

        dto.setTinyArray( bytes("Hello") );
        dto.setShortArray( bytes("Hello World") );
        dto.setNormalArray( bytes("Hello World...") );

        BlobArrayColDao dao = DaoFactory.createBlobArrayColDao();

        dao.insert( dto );

        BlobArrayCol dto2 = new BlobArrayCol();
        dto2.setTinyArray( bytes("Hello2") );
        dto2.setShortArray( bytes("Hello World...2") );

        dao.updateTinyArray( dto.getBlobArrId(), dto2.getTinyArray());
        dao.updateShortArray( dto.getBlobArrId(), dto2.getShortArray());
        dao.updateNormalArray( dto.getBlobArrId(), dto2.getNormalArray());

        BlobArrayCol dbDto = dao.findByName( "test-06" );
        assertTrue( "tiny", equals( dto2.getTinyArray(), dbDto.getTinyArray()));
        assertTrue( "short", equals( dto2.getShortArray(), dbDto.getShortArray()));
        assertTrue( "normal", equals( dto2.getNormalArray(), dbDto.getNormalArray()));
    }


    /**
     * Tests DAO check for max-length - in update by column.
     */
    @Test( expected = DaoException.class )
    public void testBlobArray07() throws DaoException {
        BlobArrayCol dto = new BlobArrayCol();
        dto.setName( "test-07" );
        dto.setShortArray( new byte[100] );

        BlobArrayColDao dao = DaoFactory.createBlobArrayColDao();

        dao.insert( dto );

        dao.updateNormalArray( dto.getBlobArrId(), new byte[ 65537 ]);
    }


    /**
     * Tests find by NULL.
     */
    @Test 
    public void testBlobArray08() throws DaoException {
        BlobArray dto = new BlobArray();
        dto.setName( "test-08" );

        dto.setShortArray( bytes("Hello World") );
        dto.setNormalArray( bytes("Hello World...") );

        BlobArrayDao dao = DaoFactory.createBlobArrayDao();

        dao.insert( dto );

        assertEquals( "Index tinyArray = null", 1, dao.findByTinyArray( null).length); 
        // not allowed - not-null column and index finder:
        // assertEquals( "Index shortArray = null", 0, dao.findByShortArray( null ).length); 
        // not supported - SQL '?' params cannot be null 
        // assertEquals( "Cond tinyArray = null", 1, dao.findByTinyArrayCond( null ).length); 
        // assertEquals( "Cond shortArray = null", 0, dao.findByShortArrayCond( null ).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Objects
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testBlobObject01() throws DaoException {
        BlobObject dto = new BlobObject();
        dto.setName( "test-01" );

        dto.setTinyObject( "Hello" );
        dto.setShortObject( "Hello World" );
        dto.setNormalObject( "Hello World..." );

        BlobObjectDao dao = DaoFactory.createBlobObjectDao();

        dao.insert( dto );

        BlobObject dbDto = dao.findByName( "test-01" );
        assertEquals( "tiny", dto.getTinyObject(), dbDto.getTinyObject());
        assertEquals( "short", dto.getShortObject(), dbDto.getShortObject());
        assertEquals( "normal", dto.getNormalObject(), dbDto.getNormalObject());

        assertEquals( "Index shortObject = Hello World", 1, dao.findByShortObject( dto.getShortObject()).length); 
        assertEquals( "Index shortObject = bla", 0, dao.findByShortObject( "bla" ).length); 
        assertEquals( "Cond shortObject = Hello World", 1, dao.findByShortObjectCond( dto.getShortObject()).length); 
        assertEquals( "Cond shortObject = bla", 0, dao.findByShortObjectCond( "bla" ).length); 

        log.debug("DB object=" + dbDto);
    }


    /**
     * Tests Medium object separately - Oracle can have one LONG column at most.
     */
    @Test 
    public void testBlobObject02() throws DaoException {
        BlobObjectMedium dto = new BlobObjectMedium();
        dto.setName( "test-02" );

        dto.setMediumObject( "Hello World................" );

        BlobObjectMediumDao dao = DaoFactory.createBlobObjectMediumDao();

        dao.insert( dto );

        BlobObjectMedium dbDto = dao.findByName( "test-02" );
        assertEquals( "medium", dto.getMediumObject(), dbDto.getMediumObject());

        log.debug("DB object=" + dbDto);
    }


    /**
     * Tests DAO check for max-length - in insert.
     */
    @Test( expected = DaoException.class )
    public void testBlobObject03() throws DaoException {
        BlobObjectMedium dto = new BlobObjectMedium();
        dto.setName( "test-03" );

        dto.setMediumObject( new String( new char[ 65537 ]));

        BlobObjectMediumDao dao = DaoFactory.createBlobObjectMediumDao();

        dao.insert( dto );
    }


    /**
     * Tests update.
     */
    @Test 
    public void testBlobObject04() throws DaoException {
        BlobObject dto = new BlobObject();
        dto.setName( "test-04" );

        dto.setTinyObject( "Hello" );
        dto.setShortObject( "Hello World" );
        dto.setNormalObject( "Hello World..." );

        BlobObjectDao dao = DaoFactory.createBlobObjectDao();

        dao.insert( dto );

        BlobObject dto2 = new BlobObject();
        dto2.setTinyObject( "Hello2" );
        dto2.setNormalObject( "Hello World...2" );

        dao.update( dto.getBlobObjId(), dto2 );

        BlobObject dbDto = dao.findByName( "test-04" );
        assertEquals( "tiny", dto2.getTinyObject(), dbDto.getTinyObject());
        assertEquals( "short", dto.getShortObject(), dbDto.getShortObject());
        assertEquals( "normal", dto2.getNormalObject(), dbDto.getNormalObject());

        BlobObject dto3 = new BlobObject();
        dto3.setTinyObject( null );

        dao.update( dto.getBlobObjId(), dto3 );

        dbDto = dao.findByName( "test-04" );
        assertEquals( "tiny", dto3.getTinyObject(), dbDto.getTinyObject());
        assertEquals( "short", dto.getShortObject(), dbDto.getShortObject());
        assertEquals( "normal", dto2.getNormalObject(), dbDto.getNormalObject());
    }


    /**
     * Tests DAO check for max-length - in update.
     */
    @Test( expected = DaoException.class )
    public void testBlobObject05() throws DaoException {
        BlobObjectMedium dto = new BlobObjectMedium();
        dto.setName( "test-05" );

        BlobObjectMediumDao dao = DaoFactory.createBlobObjectMediumDao();

        dao.insert( dto );

        BlobObjectMedium dto2 = new BlobObjectMedium();
        dto2.setMediumObject( new String( new char[ 65537 ]));

        dao.update( dto.getBlobObjId(), dto2 );
    }


    /**
     * Tests update - by column.
     */
    @Test 
    public void testBlobObject06() throws DaoException {
        BlobObjectCol dto = new BlobObjectCol();
        dto.setName( "test-06" );

        dto.setTinyObject( "Hello" );
        dto.setShortObject( "Hello World" );
        dto.setNormalObject( "Hello World..." );

        BlobObjectColDao dao = DaoFactory.createBlobObjectColDao();

        dao.insert( dto );

        BlobObjectCol dto2 = new BlobObjectCol();
        dto2.setTinyObject( "Hello2" );
        dto2.setShortObject( "Hello World...2" );

        dao.updateTinyObject( dto.getBlobObjId(), dto2.getTinyObject());
        dao.updateShortObject( dto.getBlobObjId(), dto2.getShortObject());
        dao.updateNormalObject( dto.getBlobObjId(), dto2.getNormalObject());

        BlobObjectCol dbDto = dao.findByName( "test-06" );
        assertEquals( "tiny", dto2.getTinyObject(), dbDto.getTinyObject());
        assertEquals( "short", dto2.getShortObject(), dbDto.getShortObject());
        assertEquals( "normal", dto2.getNormalObject(), dbDto.getNormalObject());
    }


    /**
     * Tests DAO check for max-length - in update by column.
     */
    @Test( expected = DaoException.class )
    public void testBlobObject07() throws DaoException {
        BlobObjectCol dto = new BlobObjectCol();
        dto.setName( "test-07" );
        dto.setShortObject( "Hello" );

        BlobObjectColDao dao = DaoFactory.createBlobObjectColDao();

        dao.insert( dto );

        dao.updateNormalObject( dto.getBlobObjId(), new String(new char[ 65537 ]));
    }



    ////////////////////////////////////////////////////////////////////////////
    // Tests - referenced tables as objects
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testBlobEmbed01() throws DaoException {
        BlobAddress address = new BlobAddress();
        address.setStreet( "V Celnici 10" );
        address.setCity( "Prague" );
        address.setZip( "11000" );
        address.setCountry( "Czech Republic" );

        BlobEmbed dto = new BlobEmbed();
        dto.setName( "test-01" );

        dto.setAddress( address );

        BlobEmbedDao dao = DaoFactory.createBlobEmbedDao();

        dao.insert( dto );

        BlobEmbed dbDto = dao.findByName( "test-01" );
        BlobAddress dbAddress = dbDto.getAddress();
        assertEquals( "street", address.getStreet(), dbAddress.getStreet());
        assertEquals( "city", address.getCity(), dbAddress.getCity());
        assertEquals( "zip", address.getZip(), dbAddress.getZip());
        assertEquals( "country", address.getCountry(), dbAddress.getCountry());

        assertEquals( "Index address = address", 1, dao.findByAddress( address ).length); 
        assertEquals( "Index address = bla", 0, dao.findByAddressCond( new BlobAddress()).length); 
        assertEquals( "Cond address = address", 1, dao.findByAddressCond( address ).length); 
        assertEquals( "Cond address = bla", 0, dao.findByAddressCond( new BlobAddress()).length); 

        log.debug("DB object=" + dbDto);
    }



    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected boolean equals( byte[] arr1, byte[] arr2) {
        if (arr1 == null || arr2 == null) return arr1 == arr2;
        if (arr1.length != arr2.length) return false;

        for (int i=0; i < arr1.length; i++) {
            if (arr1[i] != arr2[i]) return false;
        }

        return true;
    }


    protected byte[] bytes( String s ) {
        try {
            return s.getBytes( "UTF-8" );
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}




