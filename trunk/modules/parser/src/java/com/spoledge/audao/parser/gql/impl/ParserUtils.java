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
package com.spoledge.audao.parser.gql.impl;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Calendar;
import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Static utility methods.
 */
public class ParserUtils {

    private static final SimpleDateFormat FMT_DATETIME = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat FMT_DATE = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat FMT_TIME = new SimpleDateFormat("HH:mm:ss");

    private static final int LEN_FMT_DATETIME = 19;
    private static final int LEN_FMT_DATE = 10;
    private static final int LEN_FMT_TIME = 8;

    private static Log slog;


    ////////////////////////////////////////////////////////////////////////////
    // Public - logging methods
    ////////////////////////////////////////////////////////////////////////////

    public static boolean isLogDebugEnabled() {
        return getLogger().isDebugEnabled();
    }

    public static void logDebug(String msg) {
        getLogger().debug( msg );
    }

    public static void logDebug(String msg, Throwable t) {
        getLogger().debug( msg, t );
    }

    public static void logInfo(String msg) {
        getLogger().info( msg );
    }

    public static void logInfo(String msg, Throwable t) {
        getLogger().info( msg, t );
    }

    public static void logWarn(String msg) {
        getLogger().warn( msg );
    }

    public static void logWarn(String msg, Throwable t) {
        getLogger().warn( msg, t );
    }

    public static void logError(String msg) {
        getLogger().error( msg );
    }

    public static void logError(String msg, Throwable t) {
        getLogger().error( msg, t );
    }

    ////////////////////////////////////////////////////////////////////////////
    // Public - conversion methods
    ////////////////////////////////////////////////////////////////////////////

    public static String argString( Object o ) {
        if (o == null) return null;
        if (o instanceof String) return (String) o;

        return o.toString();
    }


    public static Integer argInt( Object o ) {
        if (o == null) return null;
        if (o instanceof Integer) return (Integer) o;
        if (o instanceof Number) return new Integer(((Number) o).intValue());

        return new Integer( o.toString());
    }


    public static Long argLong( Object o ) {
        if (o == null) return null;
        if (o instanceof Long) return (Long) o;
        if (o instanceof Number) return new Long(((Number) o).longValue());

        return new Long( o.toString());
    }


    public static Float argFloat( Object o ) {
        if (o == null) return null;
        if (o instanceof Float) return (Float) o;
        if (o instanceof Number) return new Float(((Number) o).floatValue());

        return new Float( o.toString());
    }


    public static Double argDouble( Object o ) {
        if (o == null) return null;
        if (o instanceof Double) return (Double) o;
        if (o instanceof Number) return new Double(((Number) o).floatValue());

        return new Double( o.toString());
    }


    public static Date argDate( Object o ) {
        if (o == null) return null;
        if (o instanceof Date) return (Date) o;
        if (o instanceof Number) return new Date(((Number) o).longValue());

        String s = o.toString();
        switch (s.length()) {
            case LEN_FMT_DATETIME: return datetime( s );
            case LEN_FMT_DATE: return date( s );
            case LEN_FMT_TIME: return time( s );
        }

        throw new RuntimeException( "Cannot convert to date: " + s );
    }


    /**
     * Removes quotes and unescapes the parsed string.
     */
    public static String string( String s ) {
        if (s == null) return null;
        
        s = s.substring( 1, s.length()-1 );
        s = s.replace( "''", "'" );

        return s;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public - Date functions
    ////////////////////////////////////////////////////////////////////////////

    public static Date date( String s ) {
        return parsedate( s, FMT_DATE);
    }


    public static Date datetime( String s ) {
        return parsedate( s, FMT_DATETIME );
    }


    public static Date time( String s ) {
        return parsedate( s, FMT_TIME );
    }


    public static Date date( int year, int month, int day ) {
        Calendar cal = Calendar.getInstance();
        cal.clear();
        cal.set( Calendar.YEAR, year );
        cal.set( Calendar.MONTH, month-1 );
        cal.set( Calendar.DAY_OF_MONTH, day );

        return cal.getTime();
    }


    public static Date datetime( int year, int month, int day, int hour, int minute, int second ) {
        Calendar cal = Calendar.getInstance();
        cal.clear();
        cal.set( Calendar.YEAR, year );
        cal.set( Calendar.MONTH, month-1 );
        cal.set( Calendar.DAY_OF_MONTH, day );
        cal.set( Calendar.HOUR_OF_DAY, hour );
        cal.set( Calendar.MINUTE, minute );
        cal.set( Calendar.SECOND, second );

        return cal.getTime();
    }


    public static Date time( int hour, int minute, int second ) {
        Calendar cal = Calendar.getInstance();
        cal.clear();
        cal.set( Calendar.HOUR_OF_DAY, hour );
        cal.set( Calendar.MINUTE, minute );
        cal.set( Calendar.SECOND, second );

        return cal.getTime();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private static Date parsedate( String s, SimpleDateFormat fmt ) {
        // SimpleDateFormat is not thread safe:
        synchronized (fmt) {
            try {
                return fmt.parse( s );
            }
            catch (ParseException e) {
                throw new RuntimeException( e );
            }
        }
    }

    private static Log getLogger() {
        if (slog == null) {
            slog = LogFactory.getLog( ParserUtils.class );
        }

        return slog;
    }
}
