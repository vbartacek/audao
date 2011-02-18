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


public class SoftCondIn implements SoftCondition {

    private SoftColumnExpr exprLeft;
    private SoftColumnExpr exprRight;
    private Object objRight;
    private Iterable iterableRight;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public SoftCondIn( SoftColumnExpr exprLeft, Object objRight ) {
        this.exprLeft = exprLeft;
        this.objRight = objRight;
    }


    public SoftCondIn( SoftColumnExpr exprLeft, Iterable iterableRight ) {
        this.exprLeft = exprLeft;
        this.iterableRight = iterableRight;
    }


    public SoftCondIn( SoftColumnExpr exprLeft, SoftColumnExpr exprRight ) {
        this.exprLeft = exprLeft;
        this.exprRight = exprRight;
    }


    ////////////////////////////////////////////////////////////////////////////
    // SoftCondition
    ////////////////////////////////////////////////////////////////////////////

    public boolean getConditionValue( Object[] args, Entity ent ) {
        Object o1 = exprLeft.getValue( args, ent );

        if (iterableRight != null) return isIn( o1, iterableRight);

        Object o2 = exprRight != null ? exprRight.getValue( args, ent ) : objRight;

        if (o2 == null) return false;

        if (o2 instanceof Iterable) return isIn( o1, (Iterable) o2);
        
        return GaeTypes.compare( o1, o2 ) == 0;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private boolean isIn( Object o1, Iterable iterable ) {
        for (Object oo : iterable) {
            if ( GaeTypes.compare( o1, oo ) == 0 ) return true;
        }

        return false;
    }

}
