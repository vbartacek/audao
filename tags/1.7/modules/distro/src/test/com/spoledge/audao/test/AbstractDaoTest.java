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

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import static org.junit.Assert.*;

import com.spoledge.audao.db.dao.DaoException;

import com.spoledge.audao.test.db.dao.*;
import com.spoledge.audao.test.db.dto.*;


public class AbstractDaoTest extends AbstractTest {

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Index Finders - Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testFinderIndexNull01() throws DaoException {
        DaoFinderIndexNullDao dao = DaoFactory.createDaoFinderIndexNullDao();

        DaoFinderIndexNull dto = new DaoFinderIndexNull();
        dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );
        java.sql.Date date3 = sqlDate( "2010-02-24" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );
        java.sql.Timestamp ts3 = sqlTimestamp( "2010-02-23 12:53:01" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];
        byte[] sblob3 = new byte[30];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();
        DaoDto gdto3 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );
        gdto3.setPropA( "test3" );

        dto = new DaoFinderIndexNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoFinderIndexNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoFinderIndexNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoFinderIndexNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoFinderIndexNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        dao.insert( dto );

        dto = new DaoFinderIndexNull();
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( DaoFinderIndexNull.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( DaoFinderIndexNull.EnumTypeCustom.TYPE_C );
        dto.setEnumTypeString( DaoFinderIndexNull.EnumTypeString.TYPE_D );
        dto.setEnumTypeStringDb( DaoFinderIndexNull.EnumTypeStringDb.TYPE_E );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        dao.insert( dto );

        assertEquals( "boolean true", 1, dao.findByBooleanType( true ).length); 
        assertEquals( "boolean false", 1, dao.findByBooleanType( false ).length); 
        assertEquals( "short 1", 1, dao.findByShortType( (short)1).length); 
        assertEquals( "short 10", 1, dao.findByShortType( (short)10 ).length); 
        assertEquals( "short 3", 0, dao.findByShortType( (short)3).length); 
        assertEquals( "int 2", 1, dao.findByIntType( 2 ).length); 
        assertEquals( "int 20", 1, dao.findByIntType( 20 ).length); 
        assertEquals( "int 3", 0, dao.findByIntType( 3 ).length); 
        assertEquals( "long 3", 1, dao.findByLongType( 3L ).length); 
        assertEquals( "long 30", 1, dao.findByLongType( 30L ).length); 
        assertEquals( "long 2", 0, dao.findByLongType( 2L ).length); 
        assertEquals( "double 4.1", 1, dao.findByDoubleType( 4.1 ).length); 
        assertEquals( "double 40.1", 1, dao.findByDoubleType( 40.1 ).length); 
        assertEquals( "double 40.2", 0, dao.findByDoubleType( 40.0 ).length); 

        assertEquals( "enum plain A", 1, dao.findByEnumTypePlain(
            DaoFinderIndexNull.EnumTypePlain.TYPE_A ).length); 
        assertEquals( "enum plain B", 1, dao.findByEnumTypePlain(
            DaoFinderIndexNull.EnumTypePlain.TYPE_B ).length); 
        assertEquals( "enum plain C", 0, dao.findByEnumTypePlain(
            DaoFinderIndexNull.EnumTypePlain.TYPE_C ).length); 

        assertEquals( "enum custom B", 1, dao.findByEnumTypeCustom(
            DaoFinderIndexNull.EnumTypeCustom.TYPE_B ).length); 
        assertEquals( "enum custom C", 1, dao.findByEnumTypeCustom(
            DaoFinderIndexNull.EnumTypeCustom.TYPE_C ).length); 
        assertEquals( "enum custom A", 0, dao.findByEnumTypeCustom(
            DaoFinderIndexNull.EnumTypeCustom.TYPE_A ).length); 

        assertEquals( "enum string C", 1, dao.findByEnumTypeString(
            DaoFinderIndexNull.EnumTypeString.TYPE_C ).length); 
        assertEquals( "enum string D", 1, dao.findByEnumTypeString(
            DaoFinderIndexNull.EnumTypeString.TYPE_D ).length); 
        assertEquals( "enum string E", 0, dao.findByEnumTypeString(
            DaoFinderIndexNull.EnumTypeString.TYPE_E ).length); 

        assertEquals( "enum string D", 1, dao.findByEnumTypeStringDb(
            DaoFinderIndexNull.EnumTypeStringDb.TYPE_D ).length); 
        assertEquals( "enum string E", 1, dao.findByEnumTypeStringDb(
            DaoFinderIndexNull.EnumTypeStringDb.TYPE_E ).length); 
        assertEquals( "enum string C", 0, dao.findByEnumTypeStringDb(
            DaoFinderIndexNull.EnumTypeStringDb.TYPE_C ).length); 

        assertEquals( "string 'test'", 1, dao.findByStringType( "test" ).length); 
        assertEquals( "string 'test2'", 1, dao.findByStringType( "test2" ).length); 
        assertEquals( "string 'test3'", 0, dao.findByStringType( "test3" ).length); 

        assertEquals( "date 1", 1, dao.findByDateType( date1 ).length); 
        assertEquals( "date 2", 1, dao.findByDateType( date2 ).length); 
        assertEquals( "date 3", 0, dao.findByDateType( date3 ).length); 
        assertEquals( "timestamp 1", 1, dao.findByTimestampType( ts1 ).length); 
        assertEquals( "timestamp 2", 1, dao.findByTimestampType( ts2 ).length); 
        assertEquals( "timestamp 3", 0, dao.findByTimestampType( ts3 ).length); 

        assertEquals( "sblob 1", 1, dao.findBySblobType( sblob1 ).length); 
        assertEquals( "sblob 2", 1, dao.findBySblobType( sblob2 ).length); 
        assertEquals( "sblob 3", 0, dao.findBySblobType( sblob3 ).length); 

        assertEquals( "serializable 1", 1, dao.findBySerializableType( "ser1" ).length); 
        assertEquals( "serializable 2", 1, dao.findBySerializableType( "ser2" ).length); 
        assertEquals( "serializable 3", 0, dao.findBySerializableType( "ser3" ).length); 

        assertEquals( "dto 1", 1, dao.findByDtoType( gdto1 ).length); 
        assertEquals( "dto 2", 1, dao.findByDtoType( gdto2 ).length); 
        assertEquals( "dto 3", 0, dao.findByDtoType( gdto3 ).length); 
    }


    @Test 
    public void testFinderIndexNull02() throws DaoException {
        DaoFinderIndexNullDao dao = DaoFactory.createDaoFinderIndexNullDao();

        assertEquals( "boolean null before", 0, dao.findByBooleanType( null ).length); 
        assertEquals( "short null before", 0, dao.findByShortType( null ).length); 
        assertEquals( "int null before", 0, dao.findByIntType( null ).length); 
        assertEquals( "long null before", 0, dao.findByLongType( null ).length); 
        assertEquals( "double null before", 0, dao.findByDoubleType( null ).length); 
        assertEquals( "enum plain null before", 0, dao.findByEnumTypePlain( null ).length); 
        assertEquals( "enum custom null before", 0, dao.findByEnumTypeCustom( null ).length); 
        assertEquals( "enum string null before", 0, dao.findByEnumTypeString( null ).length); 
        assertEquals( "enum stringdb null before", 0, dao.findByEnumTypeStringDb( null ).length); 
        assertEquals( "string null before", 0, dao.findByStringType( null ).length); 
        assertEquals( "date null before", 0, dao.findByDateType( null ).length); 
        assertEquals( "timestamp null before", 0, dao.findByTimestampType( null ).length); 
        assertEquals( "sblob null before", 0, dao.findBySblobType( null ).length); 
        assertEquals( "serializable null before", 0, dao.findBySerializableType( null ).length); 
        assertEquals( "dto null before", 0, dao.findByDtoType( null ).length); 

        DaoFinderIndexNull dto = new DaoFinderIndexNull();
        dao.insert( dto );

        assertEquals( "boolean null", 1, dao.findByBooleanType( null ).length); 
        assertEquals( "short null", 1, dao.findByShortType( null ).length); 
        assertEquals( "int null", 1, dao.findByIntType( null ).length); 
        assertEquals( "long null", 1, dao.findByLongType( null ).length); 
        assertEquals( "double null", 1, dao.findByDoubleType( null ).length); 
        assertEquals( "enum plain null", 1, dao.findByEnumTypePlain( null ).length); 
        assertEquals( "enum custom null", 1, dao.findByEnumTypeCustom( null ).length); 
        assertEquals( "enum string null", 1, dao.findByEnumTypeString( null ).length); 
        assertEquals( "enum stringdb null", 1, dao.findByEnumTypeStringDb( null ).length); 
        assertEquals( "string null", 1, dao.findByStringType( null ).length); 
        assertEquals( "date null", 1, dao.findByDateType( null ).length); 
        assertEquals( "timestamp null", 1, dao.findByTimestampType( null ).length); 
        assertEquals( "sblob null", 1, dao.findBySblobType( null ).length); 
        assertEquals( "serializable null", 1, dao.findBySerializableType( null ).length); 
        assertEquals( "dto null", 1, dao.findByDtoType( null ).length); 

    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Index Finders - Not Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testFinderIndexNotNull() throws DaoException {
        DaoFinderIndexNotNullDao dao = DaoFactory.createDaoFinderIndexNotNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );
        java.sql.Date date3 = sqlDate( "2010-02-24" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );
        java.sql.Timestamp ts3 = sqlTimestamp( "2010-02-23 12:53:01" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];
        byte[] sblob3 = new byte[30];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();
        DaoDto gdto3 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );
        gdto3.setPropA( "test3" );

        DaoFinderIndexNotNull dto = new DaoFinderIndexNotNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoFinderIndexNotNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoFinderIndexNotNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoFinderIndexNotNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoFinderIndexNotNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        dao.insert( dto );

        dto = new DaoFinderIndexNotNull();
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( DaoFinderIndexNotNull.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( DaoFinderIndexNotNull.EnumTypeCustom.TYPE_C );
        dto.setEnumTypeString( DaoFinderIndexNotNull.EnumTypeString.TYPE_D );
        dto.setEnumTypeStringDb( DaoFinderIndexNotNull.EnumTypeStringDb.TYPE_E );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        dao.insert( dto );

        assertEquals( "boolean true", 1, dao.findByBooleanType( true ).length); 
        assertEquals( "boolean false", 1, dao.findByBooleanType( false ).length); 
        assertEquals( "short 1", 1, dao.findByShortType( (short)1).length); 
        assertEquals( "short 10", 1, dao.findByShortType( (short)10 ).length); 
        assertEquals( "short 3", 0, dao.findByShortType( (short)3).length); 
        assertEquals( "int 2", 1, dao.findByIntType( 2 ).length); 
        assertEquals( "int 20", 1, dao.findByIntType( 20 ).length); 
        assertEquals( "int 3", 0, dao.findByIntType( 3 ).length); 
        assertEquals( "long 3", 1, dao.findByLongType( 3 ).length); 
        assertEquals( "long 30", 1, dao.findByLongType( 30 ).length); 
        assertEquals( "long 2", 0, dao.findByLongType( 2 ).length); 
        assertEquals( "double 4.1", 1, dao.findByDoubleType( 4.1 ).length); 
        assertEquals( "double 40.1", 1, dao.findByDoubleType( 40.1 ).length); 
        assertEquals( "double 40.2", 0, dao.findByDoubleType( 40.0 ).length); 

        assertEquals( "enum plain A", 1, dao.findByEnumTypePlain(
            DaoFinderIndexNotNull.EnumTypePlain.TYPE_A ).length); 
        assertEquals( "enum plain B", 1, dao.findByEnumTypePlain(
            DaoFinderIndexNotNull.EnumTypePlain.TYPE_B ).length); 
        assertEquals( "enum plain C", 0, dao.findByEnumTypePlain(
            DaoFinderIndexNotNull.EnumTypePlain.TYPE_C ).length); 

        assertEquals( "enum custom B", 1, dao.findByEnumTypeCustom(
            DaoFinderIndexNotNull.EnumTypeCustom.TYPE_B ).length); 
        assertEquals( "enum custom C", 1, dao.findByEnumTypeCustom(
            DaoFinderIndexNotNull.EnumTypeCustom.TYPE_C ).length); 
        assertEquals( "enum custom A", 0, dao.findByEnumTypeCustom(
            DaoFinderIndexNotNull.EnumTypeCustom.TYPE_A ).length); 

        assertEquals( "enum string C", 1, dao.findByEnumTypeString(
            DaoFinderIndexNotNull.EnumTypeString.TYPE_C ).length); 
        assertEquals( "enum string D", 1, dao.findByEnumTypeString(
            DaoFinderIndexNotNull.EnumTypeString.TYPE_D ).length); 
        assertEquals( "enum string E", 0, dao.findByEnumTypeString(
            DaoFinderIndexNotNull.EnumTypeString.TYPE_E ).length); 

        assertEquals( "enum stringdb D", 1, dao.findByEnumTypeStringDb(
            DaoFinderIndexNotNull.EnumTypeStringDb.TYPE_D ).length); 
        assertEquals( "enum stringdb E", 1, dao.findByEnumTypeStringDb(
            DaoFinderIndexNotNull.EnumTypeStringDb.TYPE_E ).length); 
        assertEquals( "enum stringdb A", 0, dao.findByEnumTypeStringDb(
            DaoFinderIndexNotNull.EnumTypeStringDb.TYPE_A ).length); 

        assertEquals( "string 'test'", 1, dao.findByStringType( "test" ).length); 
        assertEquals( "string 'test2'", 1, dao.findByStringType( "test2" ).length); 
        assertEquals( "string 'test3'", 0, dao.findByStringType( "test3" ).length); 

        assertEquals( "date 1", 1, dao.findByDateType( date1 ).length); 
        assertEquals( "date 2", 1, dao.findByDateType( date2 ).length); 
        assertEquals( "date 3", 0, dao.findByDateType( date3 ).length); 
        assertEquals( "timestamp 1", 1, dao.findByTimestampType( ts1 ).length); 
        assertEquals( "timestamp 2", 1, dao.findByTimestampType( ts2 ).length); 
        assertEquals( "timestamp 3", 0, dao.findByTimestampType( ts3 ).length); 

        assertEquals( "sblob 1", 1, dao.findBySblobType( sblob1 ).length); 
        assertEquals( "sblob 2", 1, dao.findBySblobType( sblob2 ).length); 
        assertEquals( "sblob 3", 0, dao.findBySblobType( sblob3 ).length); 

        assertEquals( "serializable 1", 1, dao.findBySerializableType( "ser1" ).length); 
        assertEquals( "serializable 2", 1, dao.findBySerializableType( "ser2" ).length); 
        assertEquals( "serializable 3", 0, dao.findBySerializableType( "ser3" ).length); 

        assertEquals( "dto 1", 1, dao.findByDtoType( gdto1 ).length); 
        assertEquals( "dto 2", 1, dao.findByDtoType( gdto2 ).length); 
        assertEquals( "dto 3", 0, dao.findByDtoType( gdto3 ).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Index Finders - Result List - Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testListFinderIndexNull01() throws DaoException {
        DaoLFinderIndexNullDao dao = DaoFactory.createDaoLFinderIndexNullDao();

        DaoLFinderIndexNull dto = new DaoLFinderIndexNull();
        dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );
        java.sql.Date date3 = sqlDate( "2010-02-24" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );
        java.sql.Timestamp ts3 = sqlTimestamp( "2010-02-23 12:53:01" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];
        byte[] sblob3 = new byte[30];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();
        DaoDto gdto3 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );
        gdto3.setPropA( "test3" );

        dto = new DaoLFinderIndexNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoLFinderIndexNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoLFinderIndexNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoLFinderIndexNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoLFinderIndexNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        dao.insert( dto );

        dto = new DaoLFinderIndexNull();
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( DaoLFinderIndexNull.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( DaoLFinderIndexNull.EnumTypeCustom.TYPE_C );
        dto.setEnumTypeString( DaoLFinderIndexNull.EnumTypeString.TYPE_D );
        dto.setEnumTypeStringDb( DaoLFinderIndexNull.EnumTypeStringDb.TYPE_E );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        dao.insert( dto );

        assertEquals( "boolean true", 1, dao.findByBooleanType( true ).size()); 
        assertEquals( "boolean false", 1, dao.findByBooleanType( false ).size()); 
        assertEquals( "short 1", 1, dao.findByShortType( (short)1).size()); 
        assertEquals( "short 10", 1, dao.findByShortType( (short)10 ).size()); 
        assertEquals( "short 3", 0, dao.findByShortType( (short)3).size()); 
        assertEquals( "int 2", 1, dao.findByIntType( 2 ).size()); 
        assertEquals( "int 20", 1, dao.findByIntType( 20 ).size()); 
        assertEquals( "int 3", 0, dao.findByIntType( 3 ).size()); 
        assertEquals( "long 3", 1, dao.findByLongType( 3L ).size()); 
        assertEquals( "long 30", 1, dao.findByLongType( 30L ).size()); 
        assertEquals( "long 2", 0, dao.findByLongType( 2L ).size()); 
        assertEquals( "double 4.1", 1, dao.findByDoubleType( 4.1 ).size()); 
        assertEquals( "double 40.1", 1, dao.findByDoubleType( 40.1 ).size()); 
        assertEquals( "double 40.2", 0, dao.findByDoubleType( 40.0 ).size()); 

        assertEquals( "enum plain A", 1, dao.findByEnumTypePlain(
            DaoLFinderIndexNull.EnumTypePlain.TYPE_A ).size()); 
        assertEquals( "enum plain B", 1, dao.findByEnumTypePlain(
            DaoLFinderIndexNull.EnumTypePlain.TYPE_B ).size()); 
        assertEquals( "enum plain C", 0, dao.findByEnumTypePlain(
            DaoLFinderIndexNull.EnumTypePlain.TYPE_C ).size()); 

        assertEquals( "enum custom B", 1, dao.findByEnumTypeCustom(
            DaoLFinderIndexNull.EnumTypeCustom.TYPE_B ).size()); 
        assertEquals( "enum custom C", 1, dao.findByEnumTypeCustom(
            DaoLFinderIndexNull.EnumTypeCustom.TYPE_C ).size()); 
        assertEquals( "enum custom A", 0, dao.findByEnumTypeCustom(
            DaoLFinderIndexNull.EnumTypeCustom.TYPE_A ).size()); 

        assertEquals( "enum string C", 1, dao.findByEnumTypeString(
            DaoLFinderIndexNull.EnumTypeString.TYPE_C ).size()); 
        assertEquals( "enum string D", 1, dao.findByEnumTypeString(
            DaoLFinderIndexNull.EnumTypeString.TYPE_D ).size()); 
        assertEquals( "enum string E", 0, dao.findByEnumTypeString(
            DaoLFinderIndexNull.EnumTypeString.TYPE_E ).size()); 

        assertEquals( "enum string D", 1, dao.findByEnumTypeStringDb(
            DaoLFinderIndexNull.EnumTypeStringDb.TYPE_D ).size()); 
        assertEquals( "enum string E", 1, dao.findByEnumTypeStringDb(
            DaoLFinderIndexNull.EnumTypeStringDb.TYPE_E ).size()); 
        assertEquals( "enum string C", 0, dao.findByEnumTypeStringDb(
            DaoLFinderIndexNull.EnumTypeStringDb.TYPE_C ).size()); 

        assertEquals( "string 'test'", 1, dao.findByStringType( "test" ).size()); 
        assertEquals( "string 'test2'", 1, dao.findByStringType( "test2" ).size()); 
        assertEquals( "string 'test3'", 0, dao.findByStringType( "test3" ).size()); 

        assertEquals( "date 1", 1, dao.findByDateType( date1 ).size()); 
        assertEquals( "date 2", 1, dao.findByDateType( date2 ).size()); 
        assertEquals( "date 3", 0, dao.findByDateType( date3 ).size()); 
        assertEquals( "timestamp 1", 1, dao.findByTimestampType( ts1 ).size()); 
        assertEquals( "timestamp 2", 1, dao.findByTimestampType( ts2 ).size()); 
        assertEquals( "timestamp 3", 0, dao.findByTimestampType( ts3 ).size()); 

        assertEquals( "sblob 1", 1, dao.findBySblobType( sblob1 ).size()); 
        assertEquals( "sblob 2", 1, dao.findBySblobType( sblob2 ).size()); 
        assertEquals( "sblob 3", 0, dao.findBySblobType( sblob3 ).size()); 

        assertEquals( "serializable 1", 1, dao.findBySerializableType( "ser1" ).size()); 
        assertEquals( "serializable 2", 1, dao.findBySerializableType( "ser2" ).size()); 
        assertEquals( "serializable 3", 0, dao.findBySerializableType( "ser3" ).size()); 

        assertEquals( "dto 1", 1, dao.findByDtoType( gdto1 ).size()); 
        assertEquals( "dto 2", 1, dao.findByDtoType( gdto2 ).size()); 
        assertEquals( "dto 3", 0, dao.findByDtoType( gdto3 ).size()); 
    }


    @Test 
    public void testListFinderIndexNull02() throws DaoException {
        DaoLFinderIndexNullDao dao = DaoFactory.createDaoLFinderIndexNullDao();

        assertEquals( "boolean null before", 0, dao.findByBooleanType( null ).size()); 
        assertEquals( "short null before", 0, dao.findByShortType( null ).size()); 
        assertEquals( "int null before", 0, dao.findByIntType( null ).size()); 
        assertEquals( "long null before", 0, dao.findByLongType( null ).size()); 
        assertEquals( "double null before", 0, dao.findByDoubleType( null ).size()); 
        assertEquals( "enum plain null before", 0, dao.findByEnumTypePlain( null ).size()); 
        assertEquals( "enum custom null before", 0, dao.findByEnumTypeCustom( null ).size()); 
        assertEquals( "enum string null before", 0, dao.findByEnumTypeString( null ).size()); 
        assertEquals( "enum stringdb null before", 0, dao.findByEnumTypeStringDb( null ).size()); 
        assertEquals( "string null before", 0, dao.findByStringType( null ).size()); 
        assertEquals( "date null before", 0, dao.findByDateType( null ).size()); 
        assertEquals( "timestamp null before", 0, dao.findByTimestampType( null ).size()); 
        assertEquals( "sblob null before", 0, dao.findBySblobType( null ).size()); 
        assertEquals( "serializable null before", 0, dao.findBySerializableType( null ).size()); 
        assertEquals( "dto null before", 0, dao.findByDtoType( null ).size()); 

        DaoLFinderIndexNull dto = new DaoLFinderIndexNull();
        dao.insert( dto );

        assertEquals( "boolean null", 1, dao.findByBooleanType( null ).size()); 
        assertEquals( "short null", 1, dao.findByShortType( null ).size()); 
        assertEquals( "int null", 1, dao.findByIntType( null ).size()); 
        assertEquals( "long null", 1, dao.findByLongType( null ).size()); 
        assertEquals( "double null", 1, dao.findByDoubleType( null ).size()); 
        assertEquals( "enum plain null", 1, dao.findByEnumTypePlain( null ).size()); 
        assertEquals( "enum custom null", 1, dao.findByEnumTypeCustom( null ).size()); 
        assertEquals( "enum string null", 1, dao.findByEnumTypeString( null ).size()); 
        assertEquals( "enum stringdb null", 1, dao.findByEnumTypeStringDb( null ).size()); 
        assertEquals( "string null", 1, dao.findByStringType( null ).size()); 
        assertEquals( "date null", 1, dao.findByDateType( null ).size()); 
        assertEquals( "timestamp null", 1, dao.findByTimestampType( null ).size()); 
        assertEquals( "sblob null", 1, dao.findBySblobType( null ).size()); 
        assertEquals( "serializable null", 1, dao.findBySerializableType( null ).size()); 
        assertEquals( "dto null", 1, dao.findByDtoType( null ).size()); 

    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Index Finders - Result List - Not Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testListFinderIndexNotNull() throws DaoException {
        DaoLFinderIndexNotNullDao dao = DaoFactory.createDaoLFinderIndexNotNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );
        java.sql.Date date3 = sqlDate( "2010-02-24" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );
        java.sql.Timestamp ts3 = sqlTimestamp( "2010-02-23 12:53:01" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];
        byte[] sblob3 = new byte[30];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();
        DaoDto gdto3 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );
        gdto3.setPropA( "test3" );

        DaoLFinderIndexNotNull dto = new DaoLFinderIndexNotNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoLFinderIndexNotNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoLFinderIndexNotNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoLFinderIndexNotNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoLFinderIndexNotNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        dao.insert( dto );

        dto = new DaoLFinderIndexNotNull();
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( DaoLFinderIndexNotNull.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( DaoLFinderIndexNotNull.EnumTypeCustom.TYPE_C );
        dto.setEnumTypeString( DaoLFinderIndexNotNull.EnumTypeString.TYPE_D );
        dto.setEnumTypeStringDb( DaoLFinderIndexNotNull.EnumTypeStringDb.TYPE_E );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        dao.insert( dto );

        assertEquals( "boolean true", 1, dao.findByBooleanType( true ).size()); 
        assertEquals( "boolean false", 1, dao.findByBooleanType( false ).size()); 
        assertEquals( "short 1", 1, dao.findByShortType( (short)1).size()); 
        assertEquals( "short 10", 1, dao.findByShortType( (short)10 ).size()); 
        assertEquals( "short 3", 0, dao.findByShortType( (short)3).size()); 
        assertEquals( "int 2", 1, dao.findByIntType( 2 ).size()); 
        assertEquals( "int 20", 1, dao.findByIntType( 20 ).size()); 
        assertEquals( "int 3", 0, dao.findByIntType( 3 ).size()); 
        assertEquals( "long 3", 1, dao.findByLongType( 3 ).size()); 
        assertEquals( "long 30", 1, dao.findByLongType( 30 ).size()); 
        assertEquals( "long 2", 0, dao.findByLongType( 2 ).size()); 
        assertEquals( "double 4.1", 1, dao.findByDoubleType( 4.1 ).size()); 
        assertEquals( "double 40.1", 1, dao.findByDoubleType( 40.1 ).size()); 
        assertEquals( "double 40.2", 0, dao.findByDoubleType( 40.0 ).size()); 

        assertEquals( "enum plain A", 1, dao.findByEnumTypePlain(
            DaoLFinderIndexNotNull.EnumTypePlain.TYPE_A ).size()); 
        assertEquals( "enum plain B", 1, dao.findByEnumTypePlain(
            DaoLFinderIndexNotNull.EnumTypePlain.TYPE_B ).size()); 
        assertEquals( "enum plain C", 0, dao.findByEnumTypePlain(
            DaoLFinderIndexNotNull.EnumTypePlain.TYPE_C ).size()); 

        assertEquals( "enum custom B", 1, dao.findByEnumTypeCustom(
            DaoLFinderIndexNotNull.EnumTypeCustom.TYPE_B ).size()); 
        assertEquals( "enum custom C", 1, dao.findByEnumTypeCustom(
            DaoLFinderIndexNotNull.EnumTypeCustom.TYPE_C ).size()); 
        assertEquals( "enum custom A", 0, dao.findByEnumTypeCustom(
            DaoLFinderIndexNotNull.EnumTypeCustom.TYPE_A ).size()); 

        assertEquals( "enum string C", 1, dao.findByEnumTypeString(
            DaoLFinderIndexNotNull.EnumTypeString.TYPE_C ).size()); 
        assertEquals( "enum string D", 1, dao.findByEnumTypeString(
            DaoLFinderIndexNotNull.EnumTypeString.TYPE_D ).size()); 
        assertEquals( "enum string E", 0, dao.findByEnumTypeString(
            DaoLFinderIndexNotNull.EnumTypeString.TYPE_E ).size()); 

        assertEquals( "enum stringdb D", 1, dao.findByEnumTypeStringDb(
            DaoLFinderIndexNotNull.EnumTypeStringDb.TYPE_D ).size()); 
        assertEquals( "enum stringdb E", 1, dao.findByEnumTypeStringDb(
            DaoLFinderIndexNotNull.EnumTypeStringDb.TYPE_E ).size()); 
        assertEquals( "enum stringdb A", 0, dao.findByEnumTypeStringDb(
            DaoLFinderIndexNotNull.EnumTypeStringDb.TYPE_A ).size()); 

        assertEquals( "string 'test'", 1, dao.findByStringType( "test" ).size()); 
        assertEquals( "string 'test2'", 1, dao.findByStringType( "test2" ).size()); 
        assertEquals( "string 'test3'", 0, dao.findByStringType( "test3" ).size()); 

        assertEquals( "date 1", 1, dao.findByDateType( date1 ).size()); 
        assertEquals( "date 2", 1, dao.findByDateType( date2 ).size()); 
        assertEquals( "date 3", 0, dao.findByDateType( date3 ).size()); 
        assertEquals( "timestamp 1", 1, dao.findByTimestampType( ts1 ).size()); 
        assertEquals( "timestamp 2", 1, dao.findByTimestampType( ts2 ).size()); 
        assertEquals( "timestamp 3", 0, dao.findByTimestampType( ts3 ).size()); 

        assertEquals( "sblob 1", 1, dao.findBySblobType( sblob1 ).size()); 
        assertEquals( "sblob 2", 1, dao.findBySblobType( sblob2 ).size()); 
        assertEquals( "sblob 3", 0, dao.findBySblobType( sblob3 ).size()); 

        assertEquals( "serializable 1", 1, dao.findBySerializableType( "ser1" ).size()); 
        assertEquals( "serializable 2", 1, dao.findBySerializableType( "ser2" ).size()); 
        assertEquals( "serializable 3", 0, dao.findBySerializableType( "ser3" ).size()); 

        assertEquals( "dto 1", 1, dao.findByDtoType( gdto1 ).size()); 
        assertEquals( "dto 2", 1, dao.findByDtoType( gdto2 ).size()); 
        assertEquals( "dto 3", 0, dao.findByDtoType( gdto3 ).size()); 
    }



    ////////////////////////////////////////////////////////////////////////////
    // Tests - Update - Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testUpdateNull01() throws DaoException {
        DaoUpdateNullDao dao = DaoFactory.createDaoUpdateNullDao();

        DaoUpdateNull dto = new DaoUpdateNull();
        long id = dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        byte[] sblob1 = new byte[10];
        DaoDto gdto1 = new DaoDto();
        gdto1.setPropA( "test1" );

        DaoUpdateNull exp = new DaoUpdateNull();
        exp.setId( id );

        dto = new DaoUpdateNull();
        dto.setBooleanType( true );
        exp.setBooleanType( true );
        assertTrue( dao.update( id, dto ));
        assertEquals( "boolean", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setShortType( 1 );
        exp.setShortType( 1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "short", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setIntType( 2 );
        exp.setIntType( 2 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "int", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setLongType( 3L );
        exp.setLongType( 3L );
        assertTrue( dao.update( id, dto ));
        assertEquals( "long", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setDoubleType( 4.1 );
        exp.setDoubleType( 4.1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "double", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setEnumTypePlain( DaoUpdateNull.EnumTypePlain.TYPE_A );
        exp.setEnumTypePlain( DaoUpdateNull.EnumTypePlain.TYPE_A );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum plain", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setEnumTypeCustom( DaoUpdateNull.EnumTypeCustom.TYPE_B );
        exp.setEnumTypeCustom( DaoUpdateNull.EnumTypeCustom.TYPE_B );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum custom", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setEnumTypeString( DaoUpdateNull.EnumTypeString.TYPE_C );
        exp.setEnumTypeString( DaoUpdateNull.EnumTypeString.TYPE_C );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum string", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setEnumTypeStringDb( DaoUpdateNull.EnumTypeStringDb.TYPE_D );
        exp.setEnumTypeStringDb( DaoUpdateNull.EnumTypeStringDb.TYPE_D );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum stringdb", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setStringType( "test" );
        exp.setStringType( "test" );
        assertTrue( dao.update( id, dto ));
        assertEquals( "string", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setDateType( date1 );
        exp.setDateType( date1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "date", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setTimestampType( ts1 );
        exp.setTimestampType( ts1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "timestamp", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setSblobType( sblob1 );
        exp.setSblobType( sblob1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "sblob", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setSerializableType( "ser1" );
        exp.setSerializableType( "ser1" );
        assertTrue( dao.update( id, dto ));
        assertEquals( "serializable", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNull();
        dto.setDtoType( gdto1 );
        exp.setDtoType( gdto1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "dto", exp, dao.findByPrimaryKey( id ));

        // Test false:
        assertFalse( "empty update", dao.update( id, new DaoUpdateNull()));
        assertFalse( "invalid id", dao.update( id + 1, exp ));
    }


    @Test 
    public void testUpdateNull02() throws DaoException {
        DaoUpdateNullDao dao = DaoFactory.createDaoUpdateNullDao();

        DaoUpdateNull dto = new DaoUpdateNull();
        long id = dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        byte[] sblob1 = new byte[10];
        DaoDto gdto1 = new DaoDto();
        gdto1.setPropA( "test1" );

        dto = new DaoUpdateNull();
        dto.setId( id ); // just for testing of equality in the assertEquals - below:
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoUpdateNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoUpdateNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoUpdateNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoUpdateNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test1" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        assertTrue( dao.update( id, dto ));
        assertEquals( "full update", dto, dao.findByPrimaryKey( id ));
    }


    @Test 
    public void testUpdateNull03() throws DaoException {
        DaoUpdateNullDao dao = DaoFactory.createDaoUpdateNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        byte[] sblob1 = new byte[10];
        DaoDto gdto1 = new DaoDto();
        gdto1.setPropA( "test1" );

        DaoUpdateNull dto = new DaoUpdateNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoUpdateNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoUpdateNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoUpdateNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoUpdateNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test1" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        long id = dao.insert( dto );

        assertEquals( "insert", dto, dao.findByPrimaryKey( id ));

        dto.setBooleanType( null );
        dto.setShortType( null );
        dto.setIntType( null );
        dto.setLongType( null );
        dto.setDoubleType( null );
        dto.setEnumTypePlain( null );
        dto.setEnumTypeCustom( null );
        dto.setEnumTypeString( null );
        dto.setEnumTypeStringDb( null );
        dto.setStringType( null );
        dto.setDateType( null );
        dto.setTimestampType( null );
        dto.setSblobType( null );
        dto.setSerializableType( null );
        dto.setDtoType( null );

        assertTrue( dao.update( id, dto ));

        dto = new DaoUpdateNull();
        dto.setId( id );
        assertEquals( "update", dto, dao.findByPrimaryKey( id ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Update - Not Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testUpdateNotNull01() throws DaoException {
        DaoUpdateNotNullDao dao = DaoFactory.createDaoUpdateNotNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );

        DaoUpdateNotNull dto = new DaoUpdateNotNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoUpdateNotNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoUpdateNotNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoUpdateNotNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoUpdateNotNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        long id = dao.insert( dto );

        DaoUpdateNotNull exp = dto;

        dto = new DaoUpdateNotNull();
        dto.setBooleanType( false );
        exp.setBooleanType( false );
        assertTrue( dao.update( id, dto ));
        assertEquals( "boolean", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setShortType( 10 );
        exp.setShortType( 10 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "short", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setIntType( 20 );
        exp.setIntType( 20 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "int", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setLongType( 30L );
        exp.setLongType( 30L );
        assertTrue( dao.update( id, dto ));
        assertEquals( "long", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setDoubleType( 40.1 );
        exp.setDoubleType( 40.1 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "double", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setEnumTypePlain( DaoUpdateNotNull.EnumTypePlain.TYPE_B );
        exp.setEnumTypePlain( DaoUpdateNotNull.EnumTypePlain.TYPE_B );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum plain", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setEnumTypeCustom( DaoUpdateNotNull.EnumTypeCustom.TYPE_C );
        exp.setEnumTypeCustom( DaoUpdateNotNull.EnumTypeCustom.TYPE_C );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum custom", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setEnumTypeString( DaoUpdateNotNull.EnumTypeString.TYPE_D );
        exp.setEnumTypeString( DaoUpdateNotNull.EnumTypeString.TYPE_D );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum string", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setEnumTypeStringDb( DaoUpdateNotNull.EnumTypeStringDb.TYPE_E );
        exp.setEnumTypeStringDb( DaoUpdateNotNull.EnumTypeStringDb.TYPE_E );
        assertTrue( dao.update( id, dto ));
        assertEquals( "enum stringdb", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setStringType( "test2" );
        exp.setStringType( "test2" );
        assertTrue( dao.update( id, dto ));
        assertEquals( "string", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setDateType( date2 );
        exp.setDateType( date2 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "date", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setTimestampType( ts2 );
        exp.setTimestampType( ts2 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "timestamp", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setSblobType( sblob2 );
        exp.setSblobType( sblob2 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "sblob", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setSerializableType( "ser2" );
        exp.setSerializableType( "ser2" );
        assertTrue( dao.update( id, dto ));
        assertEquals( "serializable", exp, dao.findByPrimaryKey( id ));

        dto = new DaoUpdateNotNull();
        dto.setDtoType( gdto2 );
        exp.setDtoType( gdto2 );
        assertTrue( dao.update( id, dto ));
        assertEquals( "dto", exp, dao.findByPrimaryKey( id ));

        // Test false:
        assertFalse( "empty update", dao.update( id, new DaoUpdateNotNull()));
        assertFalse( "invalid id", dao.update( id + 1, exp ));
    }


    @Test 
    public void testUpdateNotNull02() throws DaoException {
        DaoUpdateNotNullDao dao = DaoFactory.createDaoUpdateNotNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );

        DaoUpdateNotNull dto = new DaoUpdateNotNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoUpdateNotNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoUpdateNotNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoUpdateNotNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoUpdateNotNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        long id = dao.insert( dto );

        dto = new DaoUpdateNotNull();
        dto.setId( id );
        dto.setBooleanType( false );
        dto.setShortType( 10 );
        dto.setIntType( 20 );
        dto.setLongType( 30L );
        dto.setDoubleType( 40.1 );
        dto.setEnumTypePlain( DaoUpdateNotNull.EnumTypePlain.TYPE_B );
        dto.setEnumTypeCustom( DaoUpdateNotNull.EnumTypeCustom.TYPE_C );
        dto.setEnumTypeString( DaoUpdateNotNull.EnumTypeString.TYPE_D );
        dto.setEnumTypeStringDb( DaoUpdateNotNull.EnumTypeStringDb.TYPE_E );
        dto.setStringType( "test2" );
        dto.setDateType( date2 );
        dto.setTimestampType( ts2 );
        dto.setSblobType( sblob2 );
        dto.setSerializableType( "ser2" );
        dto.setDtoType( gdto2 );

        assertTrue( dao.update( id, dto ));
        assertEquals( "full update", dto, dao.findByPrimaryKey( id ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Update Column - Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testUpdateColumnNull01() throws DaoException {
        DaoUpdateColumnNullDao dao = DaoFactory.createDaoUpdateColumnNullDao();

        DaoUpdateColumnNull dto = new DaoUpdateColumnNull();
        long id = dao.insert( dto );

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        byte[] sblob1 = new byte[10];
        DaoDto gdto1 = new DaoDto();
        gdto1.setPropA( "test1" );

        DaoUpdateColumnNull exp = new DaoUpdateColumnNull();
        exp.setId( id );

        exp.setBooleanType( true );
        assertTrue( dao.updateBooleanType( id, true ));
        assertEquals( "boolean", exp, dao.findByPrimaryKey( id ));

        exp.setShortType( 1 );
        assertTrue( dao.updateShortType( id, (short) 1 ));
        assertEquals( "short", exp, dao.findByPrimaryKey( id ));

        exp.setIntType( 2 );
        assertTrue( dao.updateIntType( id, 2 ));
        assertEquals( "int", exp, dao.findByPrimaryKey( id ));

        exp.setLongType( 3L );
        assertTrue( dao.updateLongType( id, 3L ));
        assertEquals( "long", exp, dao.findByPrimaryKey( id ));

        exp.setDoubleType( 4.1 );
        assertTrue( dao.updateDoubleType( id, 4.1 ));
        assertEquals( "double", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypePlain( DaoUpdateColumnNull.EnumTypePlain.TYPE_A );
        assertTrue( dao.updateEnumTypePlain( id, DaoUpdateColumnNull.EnumTypePlain.TYPE_A ));
        assertEquals( "enum plain", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeCustom( DaoUpdateColumnNull.EnumTypeCustom.TYPE_B );
        assertTrue( dao.updateEnumTypeCustom( id, DaoUpdateColumnNull.EnumTypeCustom.TYPE_B ));
        assertEquals( "enum custom", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeString( DaoUpdateColumnNull.EnumTypeString.TYPE_C );
        assertTrue( dao.updateEnumTypeString( id, DaoUpdateColumnNull.EnumTypeString.TYPE_C ));
        assertEquals( "enum string", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeStringDb( DaoUpdateColumnNull.EnumTypeStringDb.TYPE_D );
        assertTrue( dao.updateEnumTypeStringDb( id, DaoUpdateColumnNull.EnumTypeStringDb.TYPE_D ));
        assertEquals( "enum stringdb", exp, dao.findByPrimaryKey( id ));

        exp.setStringType( "test" );
        assertTrue( dao.updateStringType( id, "test" ));
        assertEquals( "string", exp, dao.findByPrimaryKey( id ));

        exp.setDateType( date1 );
        assertTrue( dao.updateDateType( id, date1 ));
        assertEquals( "date", exp, dao.findByPrimaryKey( id ));

        exp.setTimestampType( ts1 );
        assertTrue( dao.updateTimestampType( id, ts1 ));
        assertEquals( "timestamp", exp, dao.findByPrimaryKey( id ));

        exp.setSblobType( sblob1 );
        assertTrue( dao.updateSblobType( id, sblob1 ));
        assertEquals( "sblob", exp, dao.findByPrimaryKey( id ));

        exp.setSerializableType( "ser1" );
        assertTrue( dao.updateSerializableType( id, "ser1" ));
        assertEquals( "serializable", exp, dao.findByPrimaryKey( id ));

        exp.setDtoType( gdto1 );
        assertTrue( dao.updateDtoType( id, gdto1 ));
        assertEquals( "dto", exp, dao.findByPrimaryKey( id ));
    }


    @Test 
    public void testUpdateColumnNull02() throws DaoException {
        DaoUpdateColumnNullDao dao = DaoFactory.createDaoUpdateColumnNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        byte[] sblob1 = new byte[10];
        DaoDto gdto1 = new DaoDto();
        gdto1.setPropA( "test1" );

        DaoUpdateColumnNull dto = new DaoUpdateColumnNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoUpdateColumnNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoUpdateColumnNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoUpdateColumnNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoUpdateColumnNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        long id = dao.insert( dto );

        DaoUpdateColumnNull exp = dto;

        exp.setBooleanType( null );
        assertTrue( dao.updateBooleanType( id, null ));
        assertEquals( "boolean", exp, dao.findByPrimaryKey( id ));

        exp.setShortType( null );
        assertTrue( dao.updateShortType( id, null ));
        assertEquals( "short", exp, dao.findByPrimaryKey( id ));

        exp.setIntType( null );
        assertTrue( dao.updateIntType( id, null ));
        assertEquals( "int", exp, dao.findByPrimaryKey( id ));

        exp.setLongType( null );
        assertTrue( dao.updateLongType( id, null ));
        assertEquals( "long", exp, dao.findByPrimaryKey( id ));

        exp.setDoubleType( null );
        assertTrue( dao.updateDoubleType( id, null ));
        assertEquals( "double", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypePlain( null );
        assertTrue( dao.updateEnumTypePlain( id, null ));
        assertEquals( "enum plain", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeCustom( null );
        assertTrue( dao.updateEnumTypeCustom( id, null ));
        assertEquals( "enum custom", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeString( null );
        assertTrue( dao.updateEnumTypeString( id, null ));
        assertEquals( "enum string", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeStringDb( null );
        assertTrue( dao.updateEnumTypeStringDb( id, null ));
        assertEquals( "enum stringdb", exp, dao.findByPrimaryKey( id ));

        exp.setStringType( null );
        assertTrue( dao.updateStringType( id, null ));
        assertEquals( "string", exp, dao.findByPrimaryKey( id ));

        exp.setDateType( null );
        assertTrue( dao.updateDateType( id, null ));
        assertEquals( "date", exp, dao.findByPrimaryKey( id ));

        exp.setTimestampType( null );
        assertTrue( dao.updateTimestampType( id, null ));
        assertEquals( "timestamp", exp, dao.findByPrimaryKey( id ));

        exp.setSblobType( null );
        assertTrue( dao.updateSblobType( id, null ));
        assertEquals( "sblob", exp, dao.findByPrimaryKey( id ));

        exp.setSerializableType( null );
        assertTrue( dao.updateSerializableType( id, null ));
        assertEquals( "serializable", exp, dao.findByPrimaryKey( id ));

        exp.setDtoType( null );
        assertTrue( dao.updateDtoType( id, null ));
        assertEquals( "dto", exp, dao.findByPrimaryKey( id ));
    }


    @Test 
    public void testUpdateColumnNull03() throws DaoException {
        DaoUpdateColumnNullDao dao = DaoFactory.createDaoUpdateColumnNullDao();

        long id = 123456; // non-existent id

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        byte[] sblob1 = new byte[10];
        DaoDto gdto1 = new DaoDto();
        gdto1.setPropA( "test1" );

        assertFalse( dao.updateBooleanType( id, true ));
        assertFalse( dao.updateShortType( id, (short) 1 ));
        assertFalse( dao.updateIntType( id, 2 ));
        assertFalse( dao.updateLongType( id, 3L ));
        assertFalse( dao.updateDoubleType( id, 4.1 ));
        assertFalse( dao.updateEnumTypePlain( id, DaoUpdateColumnNull.EnumTypePlain.TYPE_A ));
        assertFalse( dao.updateEnumTypeCustom( id, DaoUpdateColumnNull.EnumTypeCustom.TYPE_B ));
        assertFalse( dao.updateEnumTypeString( id, DaoUpdateColumnNull.EnumTypeString.TYPE_C ));
        assertFalse( dao.updateEnumTypeStringDb( id, DaoUpdateColumnNull.EnumTypeStringDb.TYPE_D ));
        assertFalse( dao.updateStringType( id, "test" ));
        assertFalse( dao.updateDateType( id, date1 ));
        assertFalse( dao.updateTimestampType( id, ts1 ));
        assertFalse( dao.updateSblobType( id, sblob1 ));
        assertFalse( dao.updateSerializableType( id, "ser1" ));
        assertFalse( dao.updateDtoType( id, gdto1 ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Update Column -  Not Null
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testUpdateColumnNotNull01() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();

        java.sql.Date date1 = sqlDate( "2010-02-22" );
        java.sql.Date date2 = sqlDate( "2010-02-23" );

        java.sql.Timestamp ts1 = sqlTimestamp( "2010-02-22 12:53:01" );
        java.sql.Timestamp ts2 = sqlTimestamp( "2010-02-22 12:53:02" );

        byte[] sblob1 = new byte[10];
        byte[] sblob2 = new byte[20];

        DaoDto gdto1 = new DaoDto();
        DaoDto gdto2 = new DaoDto();

        gdto1.setPropA( "test1" );
        gdto2.setPropA( "test2" );

        DaoUpdateColumnNotNull dto = new DaoUpdateColumnNotNull();
        dto.setBooleanType( true );
        dto.setShortType( 1 );
        dto.setIntType( 2 );
        dto.setLongType( 3L );
        dto.setDoubleType( 4.1 );
        dto.setEnumTypePlain( DaoUpdateColumnNotNull.EnumTypePlain.TYPE_A );
        dto.setEnumTypeCustom( DaoUpdateColumnNotNull.EnumTypeCustom.TYPE_B );
        dto.setEnumTypeString( DaoUpdateColumnNotNull.EnumTypeString.TYPE_C );
        dto.setEnumTypeStringDb( DaoUpdateColumnNotNull.EnumTypeStringDb.TYPE_D );
        dto.setStringType( "test" );
        dto.setDateType( date1 );
        dto.setTimestampType( ts1 );
        dto.setSblobType( sblob1 );
        dto.setSerializableType( "ser1" );
        dto.setDtoType( gdto1 );

        long id = dao.insert( dto );

        DaoUpdateColumnNotNull exp = dto;

        exp.setBooleanType( false );
        assertTrue( dao.updateBooleanType( id, false ));
        assertEquals( "boolean", exp, dao.findByPrimaryKey( id ));

        exp.setShortType( 10 );
        assertTrue( dao.updateShortType( id, (short) 10 ));
        assertEquals( "short", exp, dao.findByPrimaryKey( id ));

        exp.setIntType( 20 );
        assertTrue( dao.updateIntType( id, 20 ));
        assertEquals( "int", exp, dao.findByPrimaryKey( id ));

        exp.setLongType( 30L );
        assertTrue( dao.updateLongType( id, 30L ));
        assertEquals( "long", exp, dao.findByPrimaryKey( id ));

        exp.setDoubleType( 40.1 );
        assertTrue( dao.updateDoubleType( id, 40.1 ));
        assertEquals( "double", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypePlain( DaoUpdateColumnNotNull.EnumTypePlain.TYPE_B );
        assertTrue( dao.updateEnumTypePlain( id, DaoUpdateColumnNotNull.EnumTypePlain.TYPE_B ));
        assertEquals( "enum plain", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeCustom( DaoUpdateColumnNotNull.EnumTypeCustom.TYPE_C );
        assertTrue( dao.updateEnumTypeCustom( id, DaoUpdateColumnNotNull.EnumTypeCustom.TYPE_C ));
        assertEquals( "enum custom", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeString( DaoUpdateColumnNotNull.EnumTypeString.TYPE_D );
        assertTrue( dao.updateEnumTypeString( id, DaoUpdateColumnNotNull.EnumTypeString.TYPE_D ));
        assertEquals( "enum string", exp, dao.findByPrimaryKey( id ));

        exp.setEnumTypeStringDb( DaoUpdateColumnNotNull.EnumTypeStringDb.TYPE_E );
        assertTrue( dao.updateEnumTypeStringDb( id, DaoUpdateColumnNotNull.EnumTypeStringDb.TYPE_E ));
        assertEquals( "enum stringdb", exp, dao.findByPrimaryKey( id ));

        exp.setStringType( "test2" );
        assertTrue( dao.updateStringType( id, "test2" ));
        assertEquals( "string", exp, dao.findByPrimaryKey( id ));

        exp.setDateType( date2 );
        assertTrue( dao.updateDateType( id, date2 ));
        assertEquals( "date", exp, dao.findByPrimaryKey( id ));

        exp.setTimestampType( ts2 );
        assertTrue( dao.updateTimestampType( id, ts2 ));
        assertEquals( "timestamp", exp, dao.findByPrimaryKey( id ));

        exp.setSblobType( sblob2 );
        assertTrue( dao.updateSblobType( id, sblob2 ));
        assertEquals( "sblob", exp, dao.findByPrimaryKey( id ));

        exp.setSerializableType( "ser2" );
        assertTrue( dao.updateSerializableType( id, "ser2" ));
        assertEquals( "serializable", exp, dao.findByPrimaryKey( id ));

        exp.setDtoType( gdto2 );
        assertTrue( dao.updateDtoType( id, gdto2 ));
        assertEquals( "dto", exp, dao.findByPrimaryKey( id ));
    }


    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull12() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateEnumTypePlain( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull13() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateEnumTypeCustom( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull14() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateEnumTypeString( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull15() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateEnumTypeStringDb( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull16() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateStringType( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull17() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateDateType( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull18() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateTimestampType( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull19() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateSblobType( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull20() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateSerializableType( 123456, null );
    }

    @Test( expected = DaoException.class )
    public void testUpdateColumnNotNull21() throws DaoException {
        DaoUpdateColumnNotNullDao dao = DaoFactory.createDaoUpdateColumnNotNullDao();
        dao.updateDtoType( 123456, null );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - croping time for Date types
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testCropTimeInsert() throws DaoException {
        DaoFinderIndexNullDao dao = DaoFactory.createDaoFinderIndexNullDao();

        DaoFinderIndexNull dto = new DaoFinderIndexNull();
        dto.setDateType( datetime("2010-04-23 08:44:21"));
        dao.insert( dto );

        assertEquals( "date", 1, dao.findByDateType( sqlDate("2010-04-23")).length); 
    }


    @Test 
    public void testCropTimeFind() throws DaoException {
        DaoFinderIndexNullDao dao = DaoFactory.createDaoFinderIndexNullDao();

        DaoFinderIndexNull dto = new DaoFinderIndexNull();
        dto.setDateType( date("2010-04-23"));
        dao.insert( dto );

        assertEquals( "date", 1,
            dao.findByDateType(
                new java.sql.Date(
                    datetime("2010-04-23 09:38:02").getTime())).length); 
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Default Values
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testDefaultValue() throws DaoException {
        DaoDefaultValueDao dao = DaoFactory.createDaoDefaultValueDao();
        DaoDefaultValue dto = new DaoDefaultValue();
        dto.setBooleanType( false );
        dto.setStringType( "test" );

        dao.insert( dto );

        assertTrue( "dto boolean", dto.getDefBooleanType());
        assertEquals( "dto string", "STRING", dto.getDefStringType());

        DaoDefaultValue dto2 = dao.findByPrimaryKey( dto.getId());

        assertTrue( "dao boolean", dto2.getDefBooleanType());
        assertEquals( "dao string", "STRING", dto2.getDefStringType());
    }


    @Test 
    public void testDefaultValueNull() throws DaoException {
        DaoDefaultValueNullDao dao = DaoFactory.createDaoDefaultValueNullDao();
        DaoDefaultValueNull dto = new DaoDefaultValueNull();

        dao.insert( dto );

        assertTrue( "dto boolean", dto.getDefBooleanType());
        assertEquals( "dto string", "STRING", dto.getDefStringType());

        DaoDefaultValueNull dto2 = dao.findByPrimaryKey( dto.getId());

        assertTrue( "dao boolean", dto2.getDefBooleanType());
        assertEquals( "dao string", "STRING", dto2.getDefStringType());
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Method InsertAll
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testInsertAllAuto() throws DaoException {
        DaoMethodInsertAllAutoDao dao = DaoFactory.createDaoMethodInsertAllAutoDao();
        ArrayList<DaoMethodInsertAllAuto> dtos = new ArrayList<DaoMethodInsertAllAuto>();
        for (int i=0; i < 5; i++) {
            DaoMethodInsertAllAuto dto = new DaoMethodInsertAllAuto();
            dto.setValue("test" + i );
            dtos.add( dto );
        }

        dao.insertAll( dtos );

        DaoMethodInsertAllAuto[] dbDtos = dao.findAll();

        assertEquals( "size", dtos.size(), dbDtos.length );

        for (int i=0; i < dtos.size(); i++) {
            assertEquals( dbDtos[i].getId(), dtos.get(i).getId());
            assertEquals( dtos.get(i).getValue(), dbDtos[i].getValue());
        }
    }

}
