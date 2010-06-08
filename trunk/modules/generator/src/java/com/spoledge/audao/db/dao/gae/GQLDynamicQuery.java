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
package com.spoledge.audao.db.dao.gae;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;


/**
 * This interface describes ability to dynamically parse GQL queries.
 */
public interface GQLDynamicQuery {

    /**
     * Sets the DatastoreService which is needed for multiple queries.
     */
    public void setDatastoreService( DatastoreService ds );


    /**
     * Parses GQL query.
     * This method parses "raw" queries (without "!=" and "IN" conditions).
     *
     * @param gql the GQL query
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public Query parseQuery( String gql, Object... params);


    /**
     * Prepares a GQL query.
     *
     * @param gql the GQL query
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public PreparedQuery prepareQuery( String gql, Object... params);



    /**
     * Parses GQL query condition.
     * This method parses "raw" queries (without "!=" and "IN" conditions).
     *
     * @param query the initial query
     * @param gql the GQL query
     * @param params the parameters to the GQL (referenced by :1, :2, ...)
     */
    public Query parseQueryCond( Query query, String gql, Object... params);


    /**
     * Prepares a GQL query.
     */
    public PreparedQuery prepareMultipleQueries( Query query, boolean keysOnly );


    /**
     * Returns true iff the last query was a multiple query ("!=" or "IN" operators).
     */
    public boolean wasMultipleQueries();


    /**
     * Returns the FetchOptions of the last query.
     * @return always not-null if the query was syntactically ok
     */
    public FetchOptions getFetchOptions();

}
