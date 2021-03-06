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

import org.junit.After;
import org.junit.Before;

import static org.junit.Assert.*;

import com.spoledge.audao.test.AbstractDaoTest;


public class GaeDaoTest extends AbstractDaoTest {

    private GaeUtil gae = new GaeUtil();

    public GaeDaoTest() {
        com.spoledge.audao.test.db.dao.gae.DaoFactoryImpl
            .setDatastoreServiceProvider( gae.getDatastoreServiceProvider());
    }


    @Before
    public void setUp() {
        super.setUp();
        gae.setUp();
        resetDateFormatters();
    }


    @After
    public void tearDown() {
        gae.tearDown();
        super.tearDown();
    }

}
