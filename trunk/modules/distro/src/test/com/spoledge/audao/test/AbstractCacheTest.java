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

import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.db.dao.DaoException;

import com.spoledge.audao.test.cache.dao.*;
import com.spoledge.audao.test.cache.dto.*;


public class AbstractCacheTest extends AbstractTest {

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Default Cache
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testDefaultCacheInsertFind() throws DaoException {
        CacheDefaultDao dao1 = DaoFactory.createCacheDefaultDao();
        CacheDefaultDao dao2 = DaoFactory.createCacheDefaultDao();

        CacheDefault dto1 = new CacheDefault();
        dto1.setName( "AAA" );
        dao1.insert( dto1 );

        assertEquals( "dto", dto1, dao2.findByPrimaryKey( dto1.getId()));
        assertNull( "null", dao2.findByPrimaryKey( dto1.getId() + 1));
    }


    @Test 
    public void testDefaultCacheUpdate() throws DaoException {
        CacheDefaultDao dao1 = DaoFactory.createCacheDefaultDao();
        CacheDefaultDao dao2 = DaoFactory.createCacheDefaultDao();

        CacheDefault dto1 = new CacheDefault();
        dto1.setName( "Update" );
        dao1.insert( dto1 );

        CacheDefault dto2 = new CacheDefault();
        dto2.setValue( 123 );
        dao2.update( dto1.getId(), dto2);

        assertEquals( "dto", dto2.getValue(), dao2.findByPrimaryKey( dto1.getId()).getValue());
    }


    @Test 
    public void testDefaultCacheUpdateColumn() throws DaoException {
        CacheDefaultColumnDao dao1 = DaoFactory.createCacheDefaultColumnDao();
        CacheDefaultColumnDao dao2 = DaoFactory.createCacheDefaultColumnDao();

        CacheDefaultColumn dto1 = new CacheDefaultColumn();
        dto1.setName( "UpdateColumn" );
        dao1.insert( dto1 );

        dao2.updateValue( dto1.getId(), 123 );

        assertEquals( "dto", new Integer(123), dao2.findByPrimaryKey( dto1.getId()).getValue());
    }


    @Test 
    public void testDefaultCacheDelete() throws DaoException {
        CacheDefaultDao dao1 = DaoFactory.createCacheDefaultDao();
        CacheDefaultDao dao2 = DaoFactory.createCacheDefaultDao();

        CacheDefault dto1 = new CacheDefault();
        dto1.setName( "Delete" );
        dao1.insert( dto1 );

        assertEquals( "dto", dto1, dao2.findByPrimaryKey( dto1.getId()));

        dao1.deleteByPrimaryKey( dto1.getId());
        assertNull( "null", dao2.findByPrimaryKey( dto1.getId()));
    }

}

