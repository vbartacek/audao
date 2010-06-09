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

import com.spoledge.audao.db.dao.*;


public class DtoCacheTest extends AbstractTest {

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Equals
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testMemoryDtoCache() {
        DtoCache<String, String> cache = memImpl( 5 );

        cache.put( "A", "1" );
        assertEquals( "A", "1", cache.get( "A" ));

        cache.put( "B", "2" );
        assertEquals( "B", "2", cache.get( "B" ));

        cache.put( "C", "3" );
        assertEquals( "C", "3", cache.get( "C" ));

        cache.put( "D", "4" );
        assertEquals( "D", "4", cache.get( "D" ));

        cache.put( "E", "5" );
        assertEquals( "E", "5", cache.get( "E" ));

        cache.put( "F", "6" );
        assertEquals( "F", "6", cache.get( "F" ));
        assertNull( "sixth", cache.get( "A" ));
    }


    @Test 
    public void testExpiringMemoryDtoCache() {
        DtoCache<String, String> cache = memImpl( 5, 100L );

        cache.put( "A", "1" );
        assertEquals( "A", "1", cache.get( "A" ));
        try { Thread.sleep( 100 );} catch (InterruptedException e) {}
        assertNull( "expired", cache.get( "A" ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private MemoryDtoCacheImpl<String, String> memImpl( int maxSize ) {
        return new MemoryDtoCacheImpl<String, String>( maxSize );
    }

    private ExpiringMemoryDtoCacheImpl<String, String> memImpl( int maxSize, long millis ) {
        return new ExpiringMemoryDtoCacheImpl<String, String>( millis, maxSize );
    }

}
