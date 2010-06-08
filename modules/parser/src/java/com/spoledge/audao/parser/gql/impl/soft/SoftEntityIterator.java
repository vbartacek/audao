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

import java.util.ArrayList;
import java.util.Iterator;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;


public class SoftEntityIterator extends SoftIterator<Entity> {

    private boolean isAllColumns;
    private ArrayList<SoftColumn> softColumns;
    private SoftColumn softKeyColumn;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public SoftEntityIterator(  boolean isAllColumns,
                                SoftColumn softKeyColumn,
                                ArrayList<SoftColumn> softColumns,
                                Iterator<Entity> iter,
                                SoftCondition softCondition,
                                Integer offset,
                                Integer limit,
                                Object[] args ) {

        super( iter, softCondition, offset, limit, args );

        this.isAllColumns = isAllColumns;
        this.softKeyColumn = softKeyColumn;
        this.softColumns = softColumns;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Entity transform( Entity ent ) {
        if (softColumns == null && softKeyColumn == null) return ent;

        Entity ret = null;
        
        if (isAllColumns) ret = ent.clone();
        else if (softKeyColumn != null) {
            Key key = softKeyColumn.getValueKey( false, args, ent );
            ret = new Entity( key != null ? key : ent.getKey());
        }
        else ret = new Entity( ent.getKind());

        if (softColumns == null) return ret;

        for (SoftColumn sc : softColumns) {
            String columnName = sc.getColumnName();
            Object val = sc.getValue( args, ent );

            if (val == null) {
                if (sc.isEmpty() || sc.isUnindexed()) continue;
                ret.setProperty( columnName, null );
            }
            else if (sc.isUnindexed()) ret.setUnindexedProperty( columnName, val );
            else ret.setProperty( columnName, val );
        }

        return ret;
    }
}

