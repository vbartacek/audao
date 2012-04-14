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

    private static final String PATTERN_DATETIME = "yyyy-MM-dd HH:mm:ss";
    private static final String PATTERN_DATE = "yyyy-MM-dd";
    private static final String PATTERN_TIME = "HH:mm:ss";

    // Unfortunately GAE now sets UTC timezone to the Calendar,
    // but if we create our parsers sooner than GAE, then the tests will fail
    private static SimpleDateFormat FMT_DATETIME = null;
    private static SimpleDateFormat FMT_DATE = null;
    private static SimpleDateFormat FMT_TIME = null;

    protected Logger log = Logger.getLogger( getClass());


    public void setUp() {
    }


    public void tearDown() {
    }


    protected static java.sql.Date sqlDate( String s ) {
        return new java.sql.Date( parsedate( s, getFmtDate()).getTime());
    }

    protected static java.sql.Date sqlDate( java.util.Date date ) {
        return date != null ? new java.sql.Date( date.getTime()) : null;
    }


    protected static java.sql.Timestamp sqlTimestamp( String s ) {
        return new java.sql.Timestamp( parsedate( s, getFmtDateTime()).getTime());
    }

    protected static Date date( String s ) {
        return parsedate( s, getFmtDate());
    }


    protected static Date datetime( String s ) {
        return parsedate( s, getFmtDateTime());
    }


    protected static Date time( String s ) {
        return parsedate( s, getFmtTime());
    }


    protected static Date parsedate( String s, SimpleDateFormat fmt ) {
        try {
            return fmt.parse( s );
        }
        catch (ParseException e) {
            throw new RuntimeException( e );
        }
    }


    protected static void resetDateFormatters() {
        FMT_DATE = FMT_DATETIME = FMT_TIME = null;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private static SimpleDateFormat getFmtDate() {
        if (FMT_DATE == null) FMT_DATE = new SimpleDateFormat( PATTERN_DATE );

        return FMT_DATE;
    }


    private static SimpleDateFormat getFmtDateTime() {
        if (FMT_DATETIME == null) FMT_DATETIME = new SimpleDateFormat( PATTERN_DATETIME );

        return FMT_DATETIME;
    }


    private static SimpleDateFormat getFmtTime() {
        if (FMT_TIME == null) FMT_TIME = new SimpleDateFormat( PATTERN_TIME );

        return FMT_TIME;
    }

}
