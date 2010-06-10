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
package com.spoledge.audao.db.dao.gae;

import com.spoledge.audao.db.dao.ChainedDtoCache;
import com.spoledge.audao.db.dao.DtoCache;
import com.spoledge.audao.db.dao.DtoCacheFactory;
import com.spoledge.audao.db.dao.ExpiringMemoryDtoCacheImpl;
import com.spoledge.audao.db.dao.MemoryDtoCacheImpl;


/**
 * This is a DtoCacheFactory which uses MemcacheService caches.
 */
public class MemchainDtoCacheFactoryImpl<K,V> implements DtoCacheFactory<K,V> {

    private String name;
    private long l2ExpireMillis;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a new factory.
     */
    public MemchainDtoCacheFactoryImpl( String name ) {
        this( name, -1 );
    }


    /**
     * Creates a new factory.
     */
    public MemchainDtoCacheFactoryImpl( String name, long l2ExpireMillis ) {
        this.name = name;
        this.l2ExpireMillis = l2ExpireMillis;
    }


    ////////////////////////////////////////////////////////////////////////////
    // DtoCacheFactory
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a cache with no expiration policy.
     */
    public DtoCache<K,V> createDtoCache( int maxSize ) {
        return new ChainedDtoCache<K,V>(
                        new MemoryDtoCacheImpl<K,V>( maxSize ),
                        l2Cache());
    }


    /**
     * Creates a cache with expiration policy.
     */
    public DtoCache<K,V> createDtoCache( long expireMillis, int maxSize ) {
        return new ChainedDtoCache<K,V>(
                        new ExpiringMemoryDtoCacheImpl<K,V>( expireMillis, maxSize ),
                        l2Cache());
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private DtoCache<K,V> l2Cache() {
        if (l2ExpireMillis > 0) return new ExpiringMemcacheDtoCacheImpl<K,V>( l2ExpireMillis, name );
        else return new MemcacheDtoCacheImpl<K,V>( name );
    }
}
