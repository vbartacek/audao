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
package com.spoledge.audao.parser.gql.impl.soft;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

import static com.spoledge.audao.parser.gql.impl.soft.SoftConstants.__KEY__;

public class SoftColumn {
    private String columnName;
    private boolean isUnindexed;
    private boolean isEmpty;

    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public SoftColumn( String columnName ) {
        this( columnName, false, false );
    }


    public SoftColumn( String columnName, boolean isUnindexed, boolean isEmpty ) {
        this.columnName = columnName;
        this.isUnindexed = isUnindexed;
        this.isEmpty = isEmpty;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    public final Key getValueKey( boolean notNull, Object[] args, Entity ent ) {
        Object o = getValue( args, ent );

        if (o == null) {
            if (notNull) throw new RuntimeException("Key expr cannot be null");
            return null;
        }

        if (!(o instanceof Key)) {
            throw new RuntimeException("Expected Key expr, but got:" + o.getClass() + " - " + o );
        }

        return (Key) o;
    }


    public final Object getValue( Object[] args ) {
        return getValue( args, null );
    }


    public Object getValue( Object[] args, Entity ent ) {
        String srcName = getSourceColumnName();

        return __KEY__.equals( srcName ) ? ent.getKey() : ent.getProperty( srcName );
    }


    public final String getColumnName() {
        return columnName;
    }


    public final boolean isUnindexed() {
        return isUnindexed;
    }


    public final boolean isEmpty() {
        return isEmpty;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected String getSourceColumnName() {
        return columnName;
    }

}

