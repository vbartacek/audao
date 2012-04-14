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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.PreparedQuery;

import com.spoledge.audao.db.dao.gae.GQLDynamicQuery;
import com.spoledge.audao.parser.gql.impl.GqlDynamicLexer;
import com.spoledge.audao.parser.gql.impl.GqlDynamicParser;


/**
 * Parses GQL queries to low-level GAE API calls.
 * This class is not thread safe. Synchronization must be done externally.
 */
public class GqlDynamic implements GQLDynamicQuery {

    /**
     * The logger.
     */
    protected Log log = LogFactory.getLog( getClass());

    protected DatastoreService ds;
    protected FetchOptions fo;
    protected boolean multipleQueries;
    protected boolean keysOnly;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public GqlDynamic() {
    }


    ////////////////////////////////////////////////////////////////////////////
    // GQLDynamicQuery
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Sets the DatastoreService which is needed for multiple queries.
     */
    public void setDatastoreService( DatastoreService ds ) {
        this.ds = ds;
    }



    /**
     * Parses GQL query.
     * The result is a "raw" query.
     *
     * @param gql the GQL query
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public Query parseQuery( String gql, Object... params) {
        fo = null;

        try {
            GqlDynamicLexer lexer = new GqlDynamicLexer( new ANTLRStringStream( gql ));
            GqlDynamicParser parser = new GqlDynamicParser( new CommonTokenStream( lexer ));

            Query ret = parser.gql( params );

            fo = FetchOptions.Builder.withOffset( parser.getOffset() != null ? parser.getOffset() : 0);

            if (parser.getLimit() != null) {
                fo = fo.limit( parser.getLimit());
            }

            multipleQueries = parser.wasMultipleQueries();
            keysOnly = parser.wasKeysOnly();

            return ret;
        }
        catch (RecognitionException e) {
            log.error("parseQuery(): " + formatError( gql, e ));

            throw new RuntimeException( e );
        }
        catch (RuntimeException e) {
            log.error("parseQuery(): " + formatError( gql, e ));

            throw e;
        }
    }


    /**
     * Prepares a GQL query.
     * Currently it prepares the "raw" query.
     *
     * @param gql the GQL query
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public PreparedQuery prepareQuery( String gql, Object... params) {
        Query query = parseQuery( gql, params );

        if (multipleQueries) {
            return prepareMultipleQueries( query, keysOnly );
        }
        else {
            return ds.prepare( ds.getCurrentTransaction( null ), query );
        }
    }


    /**
     * Parses GQL query condition.
     * This method parses "raw" queries.
     *
     * @param query the initial query
     * @param gql the GQL query
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public Query parseQueryCond( Query query, String gql, Object... params) {
        fo = null;

        try {
            GqlDynamicLexer lexer = new GqlDynamicLexer( new ANTLRStringStream( gql ));
            GqlDynamicParser parser = new GqlDynamicParser( new CommonTokenStream( lexer ));

            Query ret = parser.gqlcond( query, params );

            fo = FetchOptions.Builder.withOffset( 0 );

            multipleQueries = parser.wasMultipleQueries();

            return ret;
        }
        catch (RecognitionException e) {
            log.error("parseQueryCond(): " + formatError( gql, e ));

            throw new RuntimeException( e );
        }
        catch (RuntimeException e) {
            log.error("parseQueryCond(): " + formatError( gql, e ));

            throw e;
        }
    }


    /**
     * Prepares a GQL query.
     */
    public PreparedQuery prepareMultipleQueries( Query query, boolean keysOnly ) {
        log.warn("prepareMultipleQueries(): NOT IMPLEMENTED YET");

        if (keysOnly) query.setKeysOnly();

        return ds.prepare( ds.getCurrentTransaction( null ), query );
    }


    /**
     * Returns true iff the last query was a multiple query.
     * The "multipleQueries" flag has currently no effect,
     * it is reserved for future.
     */
    public boolean wasMultipleQueries() {
        return multipleQueries;
    }


    /**
     * Returns the FetchOptions of the last query.
     * @return always not-null if the query was syntactically ok
     */
    public FetchOptions getFetchOptions() {
        return fo;
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
