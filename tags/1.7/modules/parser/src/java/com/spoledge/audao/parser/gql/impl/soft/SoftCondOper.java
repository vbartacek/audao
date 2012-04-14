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


public class SoftCondOper implements SoftCondition {

    private enum Oper { EQ, LT, LTE, GT, GTE, NE }

    private SoftColumnExpr exprLeft;
    private SoftColumnExpr exprRight;
    private Oper oper;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public SoftCondOper( SoftColumnExpr exprLeft, SoftColumnExpr exprRight, String soper ) {
        this.exprLeft = exprLeft;
        this.exprRight = exprRight;

        if (soper != null) {
            if ("=".equals( soper )) oper = Oper.EQ;
            else if ("!=".equals( soper )) oper = Oper.NE;
            else if ("<".equals( soper )) oper = Oper.LT;
            else if (">".equals( soper )) oper = Oper.GT;
            else if ("<=".equals( soper )) oper = Oper.LTE;
            else if (">=".equals( soper )) oper = Oper.GTE;
            else throw new Error("Internal error");
        }
    }


    ////////////////////////////////////////////////////////////////////////////
    // SoftCondition
    ////////////////////////////////////////////////////////////////////////////

    public boolean getConditionValue( Object[] args, Entity ent ) {
        Object o1 = exprLeft.getValue( args, ent );
        Object o2 = exprRight.getValue( args, ent );

        if (!(o2 instanceof List)) return isTrue( GaeTypes.compare( o1, o2 ));

        List<?> list = (List<?>) o2;

        for (Object oo : list) {
            if (isTrue( GaeTypes.compare( o1, oo ))) return true;
        }

        return false;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private boolean isTrue( int comp ) {
        switch (oper) {
            case EQ: return comp == 0;
            case LT: return comp < 0;
            case LTE: return comp <= 0;
            case GT: return comp > 0;
            case GTE: return comp >= 0;
            case NE: return comp != 0;
            default: throw new Error("Internal error");
        }
    }
}

