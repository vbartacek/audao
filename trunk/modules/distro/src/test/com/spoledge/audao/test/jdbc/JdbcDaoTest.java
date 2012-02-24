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
package com.spoledge.audao.test.jdbc;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.db.dao.DaoException;

import com.spoledge.audao.test.AbstractDaoTest;

import com.spoledge.audao.test.db.dao.*;
import com.spoledge.audao.test.db.dto.*;


public class JdbcDaoTest extends AbstractDaoTest {

    private JdbcUtil jdbc = new JdbcUtil();

    public JdbcDaoTest() {
        try {
            com.spoledge.audao.test.db.dao.mysql.DaoFactoryImpl
                .setConnectionProvider( jdbc.getConnectionProvider() );
        }
        catch (Throwable e) {}

        try {
            com.spoledge.audao.test.db.dao.oracle.DaoFactoryImpl
                .setConnectionProvider( jdbc.getConnectionProvider() );
        }
        catch (Throwable e) {}

        try {
            com.spoledge.audao.test.db.dao.hsqldb.DaoFactoryImpl
                .setConnectionProvider( jdbc.getConnectionProvider() );
        }
        catch (Throwable e) {}
    }


    @Before
    public void setUp() {
        super.setUp();
        jdbc.setUp();
    }


    @After
    public void tearDown() {
        jdbc.tearDown();
        super.tearDown();
    }

}
