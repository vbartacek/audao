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
package com.spoledge.audao.parser.gql;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.PreparedQuery;

import com.spoledge.audao.parser.gql.impl.GqlExtTree;


/**
 * Prepared GQL query.
 */
public class PreparedGql {

    /**
     * The query type enumeration.
     */
    public enum QueryType {
        SELECT( false ),
        INSERT( true ),
        UPDATE( true ),
        DELETE( true );

        private boolean isUpdate;

        QueryType( boolean isUpdate ) {
            this.isUpdate = isUpdate;
        }

        public boolean isUpdate() {
            return isUpdate;
        }
    }


    /**
     * The logger.
     */
    private Log log = LogFactory.getLog( getClass());

    private DatastoreService ds;
    private String gql;
    private QueryType queryType;
    private CommonTree tree;
    private TokenStream tokenStream;
    private String[] columnNames;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    PreparedGql( DatastoreService ds, String gql, QueryType queryType,
                 CommonTree tree, TokenStream tokenStream ) {
        this.ds = ds;
        this.gql = gql;
        this.queryType = queryType;
        this.tree = tree;
        this.tokenStream = tokenStream;
    }


    ////////////////////////////////////////////////////////////////////////////
    // GQLDynamicQuery
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Returns the type of the query.
     */
    public QueryType getQueryType() {
        return queryType;
    }


    /**
     * Returns the known column names or null.
     * This method can be called after the executeQuery(..) method only.
     */
    public String[] getColumnNames() {
        return columnNames;
    }


    /**
     * Executes GQL query.
     *
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     * @return the numebr of processed records.
     */
    public Iterable<Entity> executeQuery( Object... params ) {
        if (queryType.isUpdate())
            throw new IllegalStateException("Mismatched query type - use executeUpdate() instead");

        GqlExtTree treeParser = execute( params );
        columnNames = treeParser.getColumnNames();

        return treeParser.getEntityIterable();
    }


    /**
     * Executes GQL update statement.
     *
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     * @return the numebr of processed records.
     */
    public int executeUpdate( Object... params ) {
        if (!queryType.isUpdate())
            throw new IllegalStateException("Mismatched query type - use executeQuery() instead");

        return execute( params ).getRecordCounter();
    }


    /**
     * Executes GQL statement.
     * This is a general method which does not distinguish SELECT / UPDATE / DELETE statements.
     *
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public GqlExtTree execute( Object... params ) {
        try {
            CommonTreeNodeStream nodes = new CommonTreeNodeStream( tree );
            nodes.setTokenStream( tokenStream );

            GqlExtTree treeParser = new GqlExtTree( nodes );
            treeParser.gqlext( ds, params );

            return treeParser;
        }
        catch (RecognitionException e) {
            log.error("execute(): " + formatError( gql, e ), e);

            throw new RuntimeException("Internal error while parsing tree", e);
        }
        catch (RuntimeException e) {
            log.error("execute(): " + formatError( gql, e ), e);

            throw e;
        }
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Formats error message.
     */
    protected String formatError( String gql, Throwable t ) {
        return "GQL{" + gql + "} - " + t;
    }
}


