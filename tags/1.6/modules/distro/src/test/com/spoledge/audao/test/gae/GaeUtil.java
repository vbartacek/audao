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
package com.spoledge.audao.test.gae;

import com.google.appengine.api.datastore.DatastoreService;

import com.spoledge.audao.db.dao.gae.DatastoreServiceProvider;
import com.spoledge.audao.db.dao.gae.GaeAbstractDaoImpl;


public class GaeUtil extends GaeUtilRaw {


    public void tearDown() {
        GaeAbstractDaoImpl.clearEntityCache();

        super.tearDown();
    }


    public DatastoreServiceProvider getDatastoreServiceProvider() {
        return new DatastoreServiceProvider() {
            public DatastoreService getDatastoreService() {
                return ds;
            }
        };
    }
}
