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

import com.spoledge.audao.db.dao.DtoCache;
import com.spoledge.audao.db.dao.DtoCacheFactory;


/**
 * This is a DtoCacheFactory which uses MemcacheService caches.
 */
public class MemcacheDtoCacheFactoryImpl<K,V> implements DtoCacheFactory<K,V> {

    private String name;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a new factory.
     */
    public MemcacheDtoCacheFactoryImpl( String name ) {
        this.name = name;
    }


    ////////////////////////////////////////////////////////////////////////////
    // DtoCacheFactory
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a cache with no expiration policy.
     */
    public DtoCache<K,V> createDtoCache( int maxSize ) {
        return new MemcacheDtoCacheImpl<K,V>( name );
    }


    /**
     * Creates a cache with expiration policy.
     */
    public DtoCache<K,V> createDtoCache( long expireMillis, int maxSize ) {
        return new ExpiringMemcacheDtoCacheImpl<K,V>( expireMillis, name );
    }

}

