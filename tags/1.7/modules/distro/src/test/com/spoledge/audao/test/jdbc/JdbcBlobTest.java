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
package com.spoledge.audao.test.jdbc;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.db.dao.DaoException;

import com.spoledge.audao.test.AbstractBlobTest;

import com.spoledge.audao.test.blob.dao.*;
import com.spoledge.audao.test.blob.dto.*;


public class JdbcBlobTest extends AbstractBlobTest {

    private JdbcUtil jdbc = new JdbcUtil();

    public JdbcBlobTest() {
        try {
            com.spoledge.audao.test.blob.dao.mysql.DaoFactoryImpl
                .setConnectionProvider( jdbc.getConnectionProvider() );
        }
        catch (Throwable e) {}

        try {
            com.spoledge.audao.test.blob.dao.oracle.DaoFactoryImpl
                .setConnectionProvider( jdbc.getConnectionProvider() );
        }
        catch (Throwable e) {}

        try {
            com.spoledge.audao.test.blob.dao.hsqldb.DaoFactoryImpl
                .setConnectionProvider( jdbc.getConnectionProvider() );
        }
        catch (Throwable e) {}
    }


    @Before
    public void setUp() {
        super.setUp();
        jdbc.setUp();
    }


    @After
    public void tearDown() {
        jdbc.tearDown();
        super.tearDown();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testArrayBatchUpdate01() throws DaoException {
        BlobArray dto = new BlobArray();
        dto.setName( "test-01" );

        dto.setTinyArray( bytes("Hello") );
        dto.setShortArray( bytes("Hello World") );
        dto.setNormalArray( bytes("Hello World...") );

        BlobArrayDao dao = DaoFactory.createBlobArrayDao();

        dao.insert( dto );

        BlobArray dto2 = new BlobArray();
        dto2.setTinyArray( bytes("Hello2") );
        dto2.setShortArray( bytes("Hello World2") );

        dao.updateAll( dto2.getTinyArray(), dto2.getShortArray());

        BlobArray dbDto = dao.findByName( "test-01" );
        assertTrue( "tiny", equals( dto2.getTinyArray(), dbDto.getTinyArray()));
        assertTrue( "short", equals( dto2.getShortArray(), dbDto.getShortArray()));
        assertTrue( "normal", equals( dto.getNormalArray(), dbDto.getNormalArray()));

        BlobArray dto3 = new BlobArray();
        dto3.setTinyArray( null );
        dto3.setShortArray( bytes("Hello World3") );

        dao.updateAll( dto3.getTinyArray(), dto3.getShortArray());

        dbDto = dao.findByName( "test-01" );
        assertTrue( "tiny", equals( dto3.getTinyArray(), dbDto.getTinyArray()));
        assertTrue( "short", equals( dto3.getShortArray(), dbDto.getShortArray()));
        assertTrue( "normal", equals( dto.getNormalArray(), dbDto.getNormalArray()));
    }


    /**
     * Tests DAO check for max-length.
     */
    @Test( expected = DaoException.class )
    public void testArrayBatchUpdate02() throws DaoException {
        BlobArray dto = new BlobArray();
        dto.setName( "test-02" );
        dto.setShortArray( bytes("Hello World") );

        BlobArrayDao dao = DaoFactory.createBlobArrayDao();

        dao.insert( dto );

        dao.updateAll( new byte[1], new byte[ 65537 ]);
    }

}
