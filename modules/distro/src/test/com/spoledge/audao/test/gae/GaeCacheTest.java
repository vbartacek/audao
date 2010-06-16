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

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Transaction;

import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

import com.spoledge.audao.db.dao.DaoException;
import com.spoledge.audao.db.dao.gae.MemcacheDtoCacheImpl;

import com.spoledge.audao.test.AbstractCacheTest;
import com.spoledge.audao.test.AbstractTest;

import com.spoledge.audao.test.cache.dao.*;
import com.spoledge.audao.test.cache.dto.*;


public class GaeCacheTest extends AbstractCacheTest {

    private GaeUtil gae = new GaeUtil();

    public GaeCacheTest() {
        com.spoledge.audao.test.cache.dao.gae.DaoFactoryImpl
            .setDatastoreServiceProvider( gae.getDatastoreServiceProvider());
    }


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
    // Tests - Memcache
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testMemcacheService() throws DaoException {
        CacheDefaultDao dao1 = DaoFactory.createCacheDefaultDao();
        CacheDefaultDao dao2 = DaoFactory.createCacheDefaultDao();

        CacheDefault dto1 = new CacheDefault();
        dto1.setName( "AAA" );
        dao1.insert( dto1 );

        assertEquals( "dto", dto1, dao2.findByPrimaryKey( dto1.getId()));
        assertNull( "null", dao2.findByPrimaryKey( dto1.getId() + 1));

        MemcacheService ms = MemcacheServiceFactory.getMemcacheService();
        assertNull( "memcached none", ms.get( dto1.getId()) );

        MemcacheService ms2 = MemcacheServiceFactory.getMemcacheService( MemcacheDtoCacheImpl.DEFAULT_NAMESPACE_PREFIX + "CacheDefault" );

        assertEquals( "memcached dto", dto1, ms2.get( dto1.getId()));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Transactions
    ////////////////////////////////////////////////////////////////////////////

    /*
    */
    @Test 
    public void testTxEntityCacheInstance() throws DaoException, EntityNotFoundException {
        CacheDefaultDao dao = DaoFactory.createCacheDefaultDao();
        CacheDefault dto1 = new CacheDefault();
        dto1.setName( "TxEntity" );
        dao.insert( dto1 );

        // emulate modification by other process:
        Key key = KeyFactory.createKey( "CacheDefault", dto1.getId());
        Entity ent = gae.ds.get( key );
        ent.setProperty( "name", "TxEntityModified" );
        gae.ds.put( ent );

        Transaction tx = gae.ds.beginTransaction();
        CacheDefault dto2 = new CacheDefault();
        dto2.setValue( 10 );
        dao.update( dto1.getId(), dto2 );
        tx.commit();

        assertEquals( "name", "TxEntityModified", dao.findByPrimaryKey( dto1.getId()).getName());
    }

    @Test 
    public void testTxEntityCacheReused() throws DaoException, EntityNotFoundException {
        Transaction tx = gae.ds.beginTransaction();

        CacheDefaultDao dao = DaoFactory.createCacheDefaultDao();
        CacheDefault dto1 = new CacheDefault();
        dto1.setName( "TxEntity2" );
        dao.insert( dto1 );

        // change directly via API - entity is not in DS yet - we cannot fetch it:
        Key key = KeyFactory.createKey( "CacheDefault", dto1.getId());
        // Entity ent = gae.ds.get( key );
        Entity ent = new Entity( key );
        ent.setProperty( "name", "TxEntity2Modified" );
        gae.ds.put( ent );

        CacheDefault dto2 = new CacheDefault();
        dto2.setValue( 10 );
        dao.update( dto1.getId(), dto2 );
        tx.commit();

        assertEquals( "name", "TxEntity2", dao.findByPrimaryKey( dto1.getId()).getName());
    }

}

