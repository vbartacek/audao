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

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import org.apache.commons.logging.LogFactory;

import com.google.appengine.api.datastore.Entity;

import com.spoledge.audao.parser.gql.impl.GqlExtExprTree;


public class SoftColumnExpr extends SoftColumn {
    private CommonTree tree;

    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Special constructor for evaluating expressions only - used in soft conditions.
     */
    public SoftColumnExpr( CommonTree tree ) {
        this( tree, null, false, false );
    }


    public SoftColumnExpr( CommonTree tree, SoftColumn sc ) {
        this( tree, sc.getColumnName(), sc.isUnindexed(), sc.isEmpty());
    }


    public SoftColumnExpr( CommonTree tree, String columnName, boolean isUnindexed, boolean isEmpty ) {
        super( columnName, isUnindexed, isEmpty );

        this.tree = tree;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    @Override
    public Object getValue( Object[] args, Entity ent ) {
        // walk the subtree

        GqlExtExprTree parser = new GqlExtExprTree( new CommonTreeNodeStream( tree ));

        try {
            return parser.expr( args, ent );
        }
        catch (RecognitionException e) {
            LogFactory.getLog( getClass()).error("getValue(): " + e + ", tree=" + tree.toStringTree());

            throw new RuntimeException( e );
        }
        catch (RuntimeException e) {
            LogFactory.getLog( getClass()).error("getValue(): tree=" + tree.toStringTree(), e);

            throw e;
        }
    }
}
