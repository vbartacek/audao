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

}
