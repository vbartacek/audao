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

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import com.spoledge.audao.db.dao.ConnectionProvider;


public class JdbcUtil {

    private String url;
    private String login;
    private String password;

    private Connection connection;
    protected ConnectionProvider connectionProvider;


    public JdbcUtil() {
        String driver = System.getProperty("jdbc.driver");
        url = System.getProperty("jdbc.url");
        login = System.getProperty("jdbc.username");
        password = System.getProperty("jdbc.password");

        try {
            Class.forName( driver );
        }
        catch (Exception e) {
            throw new RuntimeException( e );
        }

        connectionProvider = new ConnectionProvider() {
            public Connection getConnection() {
                if (connection == null) {

                    try {
                        connection =  DriverManager.getConnection( url, login, password );
                        connection.setAutoCommit( false ); 
                    }
                    catch (SQLException e) {
                        throw new RuntimeException( e );
                    }
                }

                return connection;
            }
        };
    }


    public void setUp() {
    }


    public void tearDown() {
        if (connection != null) {
            try {
                connection.rollback();
            }
            catch (SQLException e) {
                e.printStackTrace();
            }

            connection = null;
        }
    }


    public ConnectionProvider getConnectionProvider() {
        return connectionProvider;
    }
}
