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

import com.spoledge.audao.parser.gql.impl.GqlExtLexer;
import com.spoledge.audao.parser.gql.impl.GqlExtParser;
import com.spoledge.audao.parser.gql.impl.GqlExtTree;


/**
 * Parses GQL queries to low-level GAE API calls.
 * This class is not thread safe. Synchronization must be done externally.
 */
public class GqlExtDynamic {

    /**
     * The logger.
     */
    protected Log log = LogFactory.getLog( getClass());

    protected DatastoreService ds;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public GqlExtDynamic() {
    }


    public GqlExtDynamic( DatastoreService ds ) {
        setDatastoreService( ds );
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
     * Prepares (parses) GQL query.
     *
     * @param gql the GQL query - the parameters to the GQL are referenced by :1, :2, ...
     */
    public PreparedGql prepare( String gql ) {
        try {
            GqlExtLexer lexer = new GqlExtLexer( new ANTLRStringStream( gql ));
            GqlExtParser parser = new GqlExtParser( new CommonTokenStream( lexer ));
            GqlExtParser.gqlext_return parserResult = parser.gqlext();

            if (parser.getNumberOfSyntaxErrors() != 0) {
                for (String err : parser.getErrors()) {
                    log.error("prepare(): " + err + " - in GQL: " + gql);
                }

                throw new RuntimeException( parser.getErrors().get(0));
            }

            CommonTree tree = (CommonTree) parserResult.getTree();

            if (log.isDebugEnabled()) {
                log.debug("prepare(): gql=" + gql + ", tree=" + tree.toStringTree());
            }

            PreparedGql.QueryType qt = PreparedGql.QueryType.valueOf( parser.getQueryType().name());

            return new PreparedGql( ds, gql, qt, tree, parser.getTokenStream());
        }
        catch (RecognitionException e) {
            log.error("prepare(): " + formatError( gql, e ), e);

            throw new RuntimeException( "Cannot parse GQL: " + e.getMessage() + " in GQL: " + gql, e );
        }
        catch (RuntimeException e) {
            throw new RuntimeException( "Cannot parse GQL: " + e.getMessage() + " in GQL: " + gql, e );
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

