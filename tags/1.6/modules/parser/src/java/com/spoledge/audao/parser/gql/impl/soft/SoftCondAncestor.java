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

import java.util.List;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;


public class SoftCondAncestor implements SoftCondition {

    private SoftColumnExpr expr;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public SoftCondAncestor( SoftColumnExpr expr ) {
        this.expr = expr;
    }


    ////////////////////////////////////////////////////////////////////////////
    // SoftCondition
    ////////////////////////////////////////////////////////////////////////////

    public boolean getConditionValue( Object[] args, Entity ent ) {
        Object o = expr.getValue( args, ent );

        Key parent = ent.getParent();

        return parent != null ? parent.equals( o ) : o == null;
    }

}
