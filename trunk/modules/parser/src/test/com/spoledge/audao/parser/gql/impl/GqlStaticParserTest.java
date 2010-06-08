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

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

import org.antlr.runtime.*;

import org.apache.log4j.Logger;


public class GqlStaticParserTest {
    private Logger log;

    @Before
    public void setUp() {
        log = Logger.getLogger( getClass());
    }

    @Test 
    public void testGql() throws RecognitionException {
        test("userName = :1 AND countFoo > 2 AND bar = 'bleble' and bla != :bla anD cha = true AND che = null ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test( expected = MismatchedTokenException.class )
    public void testGqlBad01() throws RecognitionException {
        testFull("SLECT * FROM User WHERE userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test( expected = NoViableAltException.class )
    public void testGqlBad02() throws RecognitionException {
        testFull("SELECT * FROM User WHERE userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }


    @Test( expected = NoViableAltException.class )
    public void testKeywords01() throws RecognitionException {
        testFull("SELECT * FROM Order", null, null );
    }

    @Test
    public void testKeywords02() throws RecognitionException {
        testFull("SELECT * FROM 'Order'", null, null );
    }

    @Test( expected = NoViableAltException.class )
    public void testKeywords03() throws RecognitionException {
        testFull("SELECT * FROM 'Order' WHERE limit=1", null, null );
    }

    @Test
    public void testKeywords04() throws RecognitionException {
        testFull("SELECT * FROM 'Order' WHERE 'limit'=1", null, null );
    }


    @Test 
    public void testKey01() throws RecognitionException {
        test("ANCESTOR IS 'qwerty' AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testKey02() throws RecognitionException {
        test("ANCESTOR IS :key AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argKey", "argUserName" },
            new String[]{ "Key", "String" });
    }

    @Test 
    public void testKey03() throws RecognitionException {
        test("ANCESTOR IS KEY('qwerty') AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testKey04() throws RecognitionException {
        test("ANCESTOR IS KEY(:key) AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argKey", "argUserName" },
            new String[]{ "Key", "String" });
    }

    @Test 
    public void testKey05() throws RecognitionException {
        test("ANCESTOR IS KEY('kind1', 1) AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testKey06() throws RecognitionException {
        test("ANCESTOR IS KEY('kind1', 1, 'kind2', 'qwerty') AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testKey07() throws RecognitionException {
        test("ANCESTOR IS KEY('kind1', 1, 'kind2', :key) AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argKey", "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testKey08() throws RecognitionException {
        test("ANCESTOR IS KEY('kind1', 1, 'kind2', :key, 'kind3', 3) AND userName = :user AND countFoo > 2 AND bar = 'bleble' ORDER BY userId",
            new String[]{ "argKey", "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testKey09() throws RecognitionException {
        test("__key__ = 'hchkrdtn'", new String[]{}, new String[]{});
    }


    @Test 
    public void testDate01() throws RecognitionException {
        test("userName = :user AND created > DATE('2001-01-01')",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testDate02() throws RecognitionException {
        test("userName = :user AND created > DATE( :year, 1, 1)",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testDate03() throws RecognitionException {
        test("userName = :user AND created > DATETIME('2001-01-01 13:00:00')",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testDate04() throws RecognitionException {
        test("userName = :user AND created > DATETIME( :year, 1, 1, :hour, 0, 0)",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testDate05() throws RecognitionException {
        test("userName = :user AND created > TIME('13:00:00')",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testDate06() throws RecognitionException {
        test("userName = :user AND created > TIME( :hour, 0, 0)",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }


    @Test 
    public void testGqlFull01() throws RecognitionException {
        testFull("SELECT * FROM MyEntity WHERE userName = :1 AND countFoo > 2 AND bar = 'bleble' and bla != :bla anD cha = true AND che = null ORDER BY userId LIMIT 10 OFFSET 20",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testGqlFull02() throws RecognitionException {
        testFull("SELECT __key__ FROM MyEntity WHERE userName = :1 AND countFoo > 2 AND bar = 'bleble' and bla != :bla anD cha = true AND che = null ORDER BY userId LIMIT 20, 10",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testGqlFull03() throws RecognitionException {
        testFull("SELECT * FROM MyEntity WHERE userName = :1 AND countFoo > 2 AND bar = 'bleble' and bla != :bla anD cha = true AND che = null AND cho IN (1,2,3,:four) ORDER BY userId LIMIT 10 OFFSET 20",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testGqlFull05() throws RecognitionException {
        testFull("SELECT * FROM MyEntity WHERE userName = :1 AND countFoo > 2 AND bar = 'bleble' and bla != :bla anD cha = true AND che = null AND cho IN (1,2,3,:four) ORDER BY __key__ LIMIT 10 OFFSET 20",
            new String[]{ "argUserName" },
            new String[]{ "String" });
    }

    @Test 
    public void testGqlFull04() throws RecognitionException {
        testFull("SELECT * FROM MyEntity", new String[]{}, new String[]{});
    }


    private void test(String gql, String[] args, String[] targs) throws RecognitionException {
        GqlStaticLexer lexer = new GqlStaticLexer( new ANTLRStringStream( gql ));
        GqlStaticParser parser = new GqlStaticParser( new CommonTokenStream( lexer ));

        String ret = parser.gqlcond( "", null, args, targs );

        log.debug("|" + gql + "| ->\n" + ret );
    }


    private void testFull(String gql, String[] args, String[] targs) throws RecognitionException {
        GqlStaticLexer lexer = new GqlStaticLexer( new ANTLRStringStream( gql ));
        GqlStaticParser parser = new GqlStaticParser( new CommonTokenStream( lexer ));

        String ret = parser.gql( "", null, args, targs );

        log.debug("|" + gql + "| ->\n" + ret );
    }

}
