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

import java.util.Iterator;

import com.google.appengine.api.datastore.Entity;


public abstract class SoftIterator<T> implements Iterator<T> {
    private Iterator<Entity> iter;
    private SoftCondition softCondition;
    private Integer offset;
    private Integer limit;
    private Entity ent = null;

    protected Object[] args;

    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    protected SoftIterator( Iterator<Entity> iter, SoftCondition softCondition,
                            Integer offset, Integer limit, Object[] args ) {
        this.iter = iter;
        this.softCondition = softCondition;
        this.offset = offset;
        this.limit = limit;
        this.args = args;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Iterator
    ////////////////////////////////////////////////////////////////////////////

    public boolean hasNext() {
        if (ent != null) return true;
        else if (offset != null) {
            int off = offset;

            if (softCondition == null) {
                while (iter.hasNext() && off-- > 0) iter.next();
            }
            else {
                while (iter.hasNext() && off > 0) {
                    if (softCondition.getConditionValue( args, iter.next())) off--;
                }
            }

            offset = null;
        }

        while ((limit == null || limit-- > 0) && iter.hasNext()) {
            ent = iter.next();
            if (softCondition == null || softCondition.getConditionValue( args, ent )) return true;
        }

        ent = null;
        return false;
    }

    public T next() {
        if (ent == null && !hasNext()) throw new java.util.NoSuchElementException();

        T ret = transform( ent );
        ent = null;

        return  ret;
    }

    public void remove() {
        iter.remove();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected abstract T transform( Entity ent ); 
}

