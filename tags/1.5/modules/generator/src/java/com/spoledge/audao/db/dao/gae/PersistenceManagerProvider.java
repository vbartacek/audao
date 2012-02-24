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

import javax.jdo.PersistenceManager;


/**
 * This is a PersistenceManager Provider which is used in DaoFactories.
 * The provider typically associates connections with threads.
 */
public interface PersistenceManagerProvider {

    /**
     * Returns the connection.
     * It's up to the provider implementation if it returns
     * an existing PersistenceManager or creates a new one.
     */
    public PersistenceManager getPersistenceManager();

}