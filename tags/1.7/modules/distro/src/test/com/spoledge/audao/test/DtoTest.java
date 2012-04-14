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

import com.spoledge.audao.test.dto.dto.*;
import com.spoledge.audao.test.dtoident.dto.*;
import com.spoledge.audao.test.dtopk.dto.*;


public class DtoTest extends AbstractTest {

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Equals
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testEqualsSimpleCases() {
        Dto dto = new Dto();

        assertEquals( "same", dto, dto );
        assertEquals( "empty", dto, new Dto());
        assertFalse( "null", dto.equals( null ));
    }

    @Test 
    public void testEqualsBoolean() {
        Dto a = new Dto();
        a.setBooleanType( true );

        Dto a2 = new Dto();
        a2.setBooleanType( true );

        Dto b = new Dto();
        b.setBooleanType( false );

        Dto b2 = new Dto();
        b2.setBooleanType( false );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsShort() {
        Dto a = new Dto();
        a.setShortType( (short)0 );

        Dto a2 = new Dto();
        a2.setShortType( (short)0 );

        Dto b = new Dto();
        b.setShortType( (short)1 );

        Dto b2 = new Dto();
        b2.setShortType( (short)1 );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsInt() {
        Dto a = new Dto();
        a.setIntType( 0 );

        Dto a2 = new Dto();
        a2.setIntType( 0 );

        Dto b = new Dto();
        b.setIntType( 1 );

        Dto b2 = new Dto();
        b2.setIntType( 1 );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsLong() {
        Dto a = new Dto();
        a.setLongType( 0L );

        Dto a2 = new Dto();
        a2.setLongType( 0L );

        Dto b = new Dto();
        b.setLongType( 1L );

        Dto b2 = new Dto();
        b2.setLongType( 1L );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsDouble() {
        Dto a = new Dto();
        a.setDoubleType( 0d );

        Dto a2 = new Dto();
        a2.setDoubleType( 0d );

        Dto b = new Dto();
        b.setDoubleType( 1.1d );

        Dto b2 = new Dto();
        b2.setDoubleType( 1.1d );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsEnumTypePlain() {
        Dto a = new Dto();
        a.setEnumTypePlain( Dto.EnumTypePlain.TYPE_A );

        Dto a2 = new Dto();
        a2.setEnumTypePlain( Dto.EnumTypePlain.TYPE_A );

        Dto b = new Dto();
        b.setEnumTypePlain( Dto.EnumTypePlain.TYPE_B );

        Dto b2 = new Dto();
        b2.setEnumTypePlain( Dto.EnumTypePlain.TYPE_B );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsEnumTypeCustom() {
        Dto a = new Dto();
        a.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_A );

        Dto a2 = new Dto();
        a2.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_A );

        Dto b = new Dto();
        b.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_B );

        Dto b2 = new Dto();
        b2.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_B );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsEnumTypeString() {
        Dto a = new Dto();
        a.setEnumTypeString( Dto.EnumTypeString.TYPE_A );

        Dto a2 = new Dto();
        a2.setEnumTypeString( Dto.EnumTypeString.TYPE_A );

        Dto b = new Dto();
        b.setEnumTypeString( Dto.EnumTypeString.TYPE_B );

        Dto b2 = new Dto();
        b2.setEnumTypeString( Dto.EnumTypeString.TYPE_B );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsEnumTypeStringDb() {
        Dto a = new Dto();
        a.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_A );

        Dto a2 = new Dto();
        a2.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_A );

        Dto b = new Dto();
        b.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_B );

        Dto b2 = new Dto();
        b2.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_B );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsString() {
        Dto a = new Dto();
        a.setStringType( "0" );

        Dto a2 = new Dto();
        a2.setStringType( "0" );

        Dto b = new Dto();
        b.setStringType( "1" );

        Dto b2 = new Dto();
        b2.setStringType( "1" );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsDate() {
        Dto a = new Dto();
        a.setDateType( sqlDate( "2010-03-18" ));

        Dto a2 = new Dto();
        a2.setDateType( sqlDate( "2010-03-18" ));

        Dto b = new Dto();
        b.setDateType( sqlDate( "2010-03-19" ));

        Dto b2 = new Dto();
        b2.setDateType( sqlDate( "2010-03-19" ));

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsTimestamp() {
        Dto a = new Dto();
        a.setTimestampType( sqlTimestamp( "2010-03-18 15:53:04" ));

        Dto a2 = new Dto();
        a2.setTimestampType( sqlTimestamp( "2010-03-18 15:53:04" ));

        Dto b = new Dto();
        b.setTimestampType( sqlTimestamp( "2010-03-18 15:53:14" ));

        Dto b2 = new Dto();
        b2.setTimestampType( sqlTimestamp( "2010-03-18 15:53:14" ));

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsSblob() {
        Dto a = new Dto();
        a.setSblobType( new byte[]{ (byte)0, (byte)1 });

        Dto a2 = new Dto();
        a2.setSblobType( new byte[]{ (byte)0, (byte)1 });

        Dto b = new Dto();
        b.setSblobType( new byte[]{ (byte)0, (byte)2 });

        Dto b2 = new Dto();
        b2.setSblobType( new byte[]{ (byte)0, (byte)2 });

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsSerializable() {
        Dto a = new Dto();
        a.setSerializableType( "0" );

        Dto a2 = new Dto();
        a2.setSerializableType( "0" );

        Dto b = new Dto();
        b.setSerializableType( new Long(1) );

        Dto b2 = new Dto();
        b2.setSerializableType( new Long(1) );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsDto() {
        Dto a = new Dto();
        a.setDtoType( new DtoDto());

        Dto a2 = new Dto();
        a2.setDtoType( new DtoDto());

        DtoDto dd_b = new DtoDto();
        dd_b.setPropA( "1" );

        Dto b = new Dto();
        b.setDtoType( dd_b );

        Dto b2 = new Dto();
        b2.setDtoType( dd_b );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    @Test 
    public void testEqualsComplex() {
        Dto a = new Dto();
        a.setBooleanType( true );
        a.setShortType( (short)0 );
        a.setIntType( 0 );
        a.setLongType( 0L );
        a.setDoubleType( 0d );
        a.setEnumTypePlain( Dto.EnumTypePlain.TYPE_A );
        a.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_A );
        a.setEnumTypeString( Dto.EnumTypeString.TYPE_A );
        a.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_A );
        a.setStringType( "0" );
        a.setDateType( sqlDate( "2010-03-18" ));
        a.setTimestampType( sqlTimestamp( "2010-03-18 15:53:04" ));
        a.setSblobType( new byte[]{ (byte)0, (byte)1 });
        a.setSerializableType( "0" );
        a.setDtoType( new DtoDto());

        Dto a2 = new Dto();
        a2.setBooleanType( true );
        a2.setShortType( (short)0 );
        a2.setIntType( 0 );
        a2.setLongType( 0L );
        a2.setDoubleType( 0d );
        a2.setEnumTypePlain( Dto.EnumTypePlain.TYPE_A );
        a2.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_A );
        a2.setEnumTypeString( Dto.EnumTypeString.TYPE_A );
        a2.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_A );
        a2.setStringType( "0" );
        a2.setDateType( sqlDate( "2010-03-18" ));
        a2.setTimestampType( sqlTimestamp( "2010-03-18 15:53:04" ));
        a2.setSblobType( new byte[]{ (byte)0, (byte)1 });
        a2.setSerializableType( "0" );
        a2.setDtoType( new DtoDto());

        DtoDto dd_b = new DtoDto();
        dd_b.setPropA( "1" );

        Dto b = new Dto();
        b.setBooleanType( false );
        b.setShortType( (short)1 );
        b.setIntType( 1 );
        b.setLongType( 1L );
        b.setDoubleType( 1.1 );
        b.setEnumTypePlain( Dto.EnumTypePlain.TYPE_B );
        b.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_B );
        b.setEnumTypeString( Dto.EnumTypeString.TYPE_B );
        b.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_B );
        b.setStringType( "1" );
        b.setDateType( sqlDate( "2010-03-19" ));
        b.setTimestampType( sqlTimestamp( "2010-03-18 15:53:14" ));
        b.setSblobType( new byte[]{ (byte)0, (byte)2 });
        b.setSerializableType( "1" );
        b.setDtoType( dd_b );

        Dto b2 = new Dto();
        b2.setBooleanType( false );
        b2.setShortType( (short)1 );
        b2.setIntType( 1 );
        b2.setLongType( 1L );
        b2.setDoubleType( 1.1 );
        b2.setEnumTypePlain( Dto.EnumTypePlain.TYPE_B );
        b2.setEnumTypeCustom( Dto.EnumTypeCustom.TYPE_B );
        b2.setEnumTypeString( Dto.EnumTypeString.TYPE_B );
        b2.setEnumTypeStringDb( Dto.EnumTypeStringDb.TYPE_B );
        b2.setStringType( "1" );
        b2.setDateType( sqlDate( "2010-03-19" ));
        b2.setTimestampType( sqlTimestamp( "2010-03-18 15:53:14" ));
        b2.setSblobType( new byte[]{ (byte)0, (byte)2 });
        b2.setSerializableType( "1" );
        b2.setDtoType( dd_b );

        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new Dto()));
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests - Equals Identity
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testIdentEquals() {
        DtoIdent a = new DtoIdent();
        a.setBooleanType( true );
        a.setShortType( (short)0 );
        a.setIntType( 0 );
        a.setLongType( 0L );
        a.setDoubleType( 0d );
        a.setEnumTypePlain( DtoIdent.EnumTypePlain.TYPE_A );
        a.setEnumTypeCustom( DtoIdent.EnumTypeCustom.TYPE_A );
        a.setEnumTypeString( DtoIdent.EnumTypeString.TYPE_A );
        a.setEnumTypeStringDb( DtoIdent.EnumTypeStringDb.TYPE_A );
        a.setStringType( "0" );
        a.setDateType( sqlDate( "2010-03-18" ));
        a.setTimestampType( sqlTimestamp( "2010-03-18 15:53:04" ));
        a.setSblobType( new byte[]{ (byte)0, (byte)1 });
        a.setSerializableType( "0" );
        a.setDtoType( new DtoIdentDto());

        DtoIdent a2 = new DtoIdent();
        a2.setBooleanType( true );
        a2.setShortType( (short)0 );
        a2.setIntType( 0 );
        a2.setLongType( 0L );
        a2.setDoubleType( 0d );
        a2.setEnumTypePlain( DtoIdent.EnumTypePlain.TYPE_A );
        a2.setEnumTypeCustom( DtoIdent.EnumTypeCustom.TYPE_A );
        a2.setEnumTypeString( DtoIdent.EnumTypeString.TYPE_A );
        a2.setEnumTypeStringDb( DtoIdent.EnumTypeStringDb.TYPE_A );
        a2.setStringType( "0" );
        a2.setDateType( sqlDate( "2010-03-18" ));
        a2.setTimestampType( sqlTimestamp( "2010-03-18 15:53:04" ));
        a2.setSblobType( new byte[]{ (byte)0, (byte)1 });
        a2.setSerializableType( "0" );
        a2.setDtoType( new DtoIdentDto());

        DtoIdentDto dd_b = new DtoIdentDto();
        dd_b.setPropA( "1" );

        DtoIdent b = new DtoIdent();
        b.setBooleanType( false );
        b.setShortType( (short)1 );
        b.setIntType( 1 );
        b.setLongType( 1L );
        b.setDoubleType( 1.1 );
        b.setEnumTypePlain( DtoIdent.EnumTypePlain.TYPE_B );
        b.setEnumTypeCustom( DtoIdent.EnumTypeCustom.TYPE_B );
        b.setEnumTypeString( DtoIdent.EnumTypeString.TYPE_B );
        b.setEnumTypeStringDb( DtoIdent.EnumTypeStringDb.TYPE_B );
        b.setStringType( "1" );
        b.setDateType( sqlDate( "2010-03-19" ));
        b.setTimestampType( sqlTimestamp( "2010-03-18 15:53:14" ));
        b.setSblobType( new byte[]{ (byte)0, (byte)2 });
        b.setSerializableType( "1" );
        b.setDtoType( dd_b );

        DtoIdent b2 = new DtoIdent();
        b2.setBooleanType( false );
        b2.setShortType( (short)1 );
        b2.setIntType( 1 );
        b2.setLongType( 1L );
        b2.setDoubleType( 1.1 );
        b2.setEnumTypePlain( DtoIdent.EnumTypePlain.TYPE_B );
        b2.setEnumTypeCustom( DtoIdent.EnumTypeCustom.TYPE_B );
        b2.setEnumTypeString( DtoIdent.EnumTypeString.TYPE_B );
        b2.setEnumTypeStringDb( DtoIdent.EnumTypeStringDb.TYPE_B );
        b2.setStringType( "1" );
        b2.setDateType( sqlDate( "2010-03-19" ));
        b2.setTimestampType( sqlTimestamp( "2010-03-18 15:53:14" ));
        b2.setSblobType( new byte[]{ (byte)0, (byte)2 });
        b2.setSerializableType( "1" );
        b2.setDtoType( dd_b );

        assertEquals( "a == a", a, a );
        assertEquals( "b == b", b, b );
        assertFalse( "a != a2", a.equals( b ));
        assertFalse( "b != b2", a.equals( b ));
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new DtoIdent()));
        assertFalse( "empty != empty", new DtoIdent().equals( new DtoIdent()));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - Equals - PK
    ////////////////////////////////////////////////////////////////////////////

    @Test 
    public void testPkEquals() {
        DtoPk a = new DtoPk();
        a.setId( 1L );
        a.setBooleanType( true );

        DtoPk a2 = new DtoPk();
        a2.setId( 1L );
        a2.setBooleanType( false );

        DtoPk b = new DtoPk();
        b.setBooleanType( true );
        b.setIntType( 1 );

        DtoPk b2 = new DtoPk();
        b2.setBooleanType( false );
        b2.setIntType( 1 );

        assertEquals( "a == a", a, a );
        assertEquals( "b == b", b, b );
        assertEquals( "a == a2", a, a2 );
        assertEquals( "b == b2", b, b2 );
        assertFalse( "a != b", a.equals( b ));
        assertFalse( "a2 != b2", a2.equals( b2 ));
        assertFalse( "a != empty", a2.equals( new DtoPk()));
        assertEquals( "empty == empty", new DtoPk(), new DtoPk());
    }


    ////////////////////////////////////////////////////////////////////////////
    // Tests - hashCode
    ////////////////////////////////////////////////////////////////////////////

    @Test
    public void testHashCode() {
        assertTrue( "empty == empty", new DtoPk().hashCode() == new DtoPk().hashCode());
    }

}
