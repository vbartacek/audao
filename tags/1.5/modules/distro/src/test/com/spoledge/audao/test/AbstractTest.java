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
package com.spoledge.audao.test;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Date;

import org.apache.log4j.Logger;


public class AbstractTest {
    private static final SimpleDateFormat FMT_DATETIME = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat FMT_DATE = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat FMT_TIME = new SimpleDateFormat("HH:mm:ss");

    protected Logger log = Logger.getLogger( getClass());


    public void setUp() {
    }


    public void tearDown() {
    }


    protected static java.sql.Date sqlDate( String s ) {
        return new java.sql.Date( parsedate( s, FMT_DATE).getTime());
    }

    protected static java.sql.Date sqlDate( java.util.Date date ) {
        return date != null ? new java.sql.Date( date.getTime()) : null;
    }


    protected static java.sql.Timestamp sqlTimestamp( String s ) {
        return new java.sql.Timestamp( parsedate( s, FMT_DATETIME ).getTime());
    }

    protected static Date date( String s ) {
        return parsedate( s, FMT_DATE);
    }


    protected static Date datetime( String s ) {
        return parsedate( s, FMT_DATETIME );
    }


    protected static Date time( String s ) {
        return parsedate( s, FMT_TIME );
    }


    protected static Date parsedate( String s, SimpleDateFormat fmt ) {
        try {
            return fmt.parse( s );
        }
        catch (ParseException e) {
            throw new RuntimeException( e );
        }
    }


}
