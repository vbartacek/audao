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
grammar GqlStatic;

import GqlLexer;

@lexer::header {package com.spoledge.audao.parser.gql.impl;}
@header {
package com.spoledge.audao.parser.gql.impl;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.HashMap;
}

@members {
    private static final SimpleDateFormat FMT_DATETIME = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat FMT_DATE = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat FMT_TIME = new SimpleDateFormat("HH:mm:ss");

    private static final HashMap<String, String> OPERANDS = new HashMap<String, String>();
    
    static {
        OPERANDS.put( "=", "EQUAL");
        OPERANDS.put( ">", "GREATER_THAN");        
        OPERANDS.put( ">=", "GREATER_THAN_OR_EQUAL");
        OPERANDS.put( "<", "LESS_THAN");
        OPERANDS.put( "<=", "LESS_THAN_OR_EQUAL");
        OPERANDS.put( "!=", "NOT_EQUAL");
    }
    
    private StringBuilder sb = new StringBuilder();
    private String[] args;
    private String[] targs;
    private String indent;
    private String queryName;
    private String lastTarg;
    private String lastTargClass;
    private boolean wasLastListForced;
    private RecognitionException firstError;

    private StringBuilder indent() {
        return sb.append( indent );
    }

    private StringBuilder indent( int n ) {
        sb.append( indent );
        while (--n > 0) sb.append( "    " );

        return sb;
    }

    private String arg(int pos) {
        return args[pos-1];
    }

    private String targ(int pos) {
        return targs[pos-1];
    }

    private String string( String s ) {
        return string( s, true );
    }

    private String string( String s, boolean quotes ) {
        if (s == null) return "null";
        
        s = s.substring( 1, s.length()-1 );
        s = s.replace( "''", "'" );

        if (quotes) {
            s = "\"" + s + '"';
        }

        return s;
    }

    private String date( String s ) {
        return parsedate( s, FMT_DATE);
    }

    private String datetime( String s ) {
        return parsedate( s, FMT_DATETIME );
    }

    private String time( String s ) {
        return parsedate( s, FMT_TIME );
    }

    private String parsedate( String s, SimpleDateFormat fmt ) {
        try {
            return "new java.util.Date(" + fmt.parse( s ).getTime() + "l)";
        }
        catch (ParseException e) {
            throw new RuntimeException( e );
        }
    }

    private String varArg( String targ, String arg ) {
        if ("Date".equals( targ ) || "Timestamp".equals( targ )) {
            return "date( " + arg + " )";
        }
        else if (targ.startsWith( "EnumId" )) {
            return "( " + arg + " != null ? " + arg + ".getId() : null )";
        }
        else if (targ.startsWith( "Enum" )) {
            return "( " + arg + " != null ? " + arg + ".ordinal() + 1 : null )";
        }
        else if ("ShortBlob".equals( targ )) {
            return "shortBlob( " + arg + " )";
        }
        else if ("ShortBlobOfByteArray".equals( targ )) {
            return "shortBlob( " + arg + " )";
        }
        else {
            return arg;
        }
    }

    private String varArgList( String targ, String arg ) {
        if ("Date".equals( targ )) {
            return "datesOfDate( " + arg + " )";
        }
        if ("Timestamp".equals( targ )) {
            return "datesOfTimestamp( " + arg + " )";
        }
        else if (targ.startsWith( "EnumId" )) {
            return "_list" + arg;
        }
        else if (targ.startsWith( "Enum" )) {
            return "ordinals( " + arg + " )";
        }
        else if ("ShortBlob".equals( targ )) {
            return "shortBlobs( " + arg + " )";
        }
        else if ("ShortBlobOfByteArray".equals( targ )) {
            return "shortBlobsOfByteArray( " + arg + " )";
        }
        else {
            return arg;
        }
    }

    private boolean needsConversion( String targ, String arg ) {
        return !arg.equals( varArg( targ, arg ));
    }

    private void addFilter( int ind, String prop, String oper, String val ) {
        indent( ind ).append(queryName).append(".addFilter(\"").append( prop ).append("\", ");
        sb.append("Query.FilterOperator.").append( OPERANDS.get( oper )).append(", ");
        sb.append( val ).append(");\n");
    }

    @Override
    public void reportError(RecognitionException e) {
        if (firstError == null) firstError = e;
        super.reportError( e );
    }

}


gql[String indent, String queryName, String[\] args, String[\] targs] returns[String value]
@init{
    if (queryName == null) queryName = "query";
    sb.setLength(0);
    this.indent = indent;
    this.queryName = queryName;
    this.args = args;
    this.targs = targs;
    firstError = null;
}
    :
    SELECT ('*'|iskey='__key__') FROM kind
        {
            sb.append(indent).append("Query ").append(queryName).append(" = new Query(\"").append( $kind.value ).append("\")");
            if (iskey != null) sb.append(".setKeysOnly()");
            sb.append(";\n");
        }
    where? orderby? limit? offset?
        { $gql.value = sb.toString();}
    ;
    finally {
        if (getNumberOfSyntaxErrors() != 0) throw firstError;
    }


gqlcond[String indent, String queryName, String[\] args, String[\] targs] returns[String value]
@init{
    if (queryName == null) queryName = "query";
    sb.setLength(0);
    this.indent = indent;
    this.queryName = queryName;
    this.args = args;
    this.targs = targs;
    firstError = null;
}
    :
    conditions orderby? {
        $gqlcond.value = sb.toString();
    }
    ;
    finally {
        if (getNumberOfSyntaxErrors() != 0) throw firstError;
    }


where: WHERE conditions;


conditions: condition (AND condition)*;


condition: cond | condkey | condancestor | condin | condinkey;


cond:
    property oper vov=valorvarobj {
        if ($vov.isList) {
            if (wasLastListForced) {
                throw new IllegalArgumentException( "List param not allowed for non-list property: " + $vov.value );
            }

            sb.append( indent ).append( "if ( ").append( $vov.value );
            sb.append( " != null && ").append( $vov.value ).append( ".size() != 0 ) {\n");
            indent( 2 ).append( "for ( ").append( lastTargClass );
            sb.append(" _o : ").append( $vov.value ).append( " ) {\n" );

            addFilter( 3, $property.value, $oper.value, varArg( lastTarg, "_o" ));

            indent( 2 ).append( "}\n" );
            sb.append( indent ).append( "}\n" );
            sb.append( indent ).append( "else {\n" );

            addFilter( 2, $property.value, $oper.value, "null" );

            sb.append( indent ).append( "}\n" );
        }
        else {
            addFilter( 1, $property.value, $oper.value, $vov.value );
        }
    }
    ;


condkey:
    KEYPROP oper key {
        sb.append( indent ).append(queryName).append(".addFilter(\"").append($KEYPROP.text).append("\", ");
        sb.append("Query.FilterOperator.").append( OPERANDS.get($oper.value)).append(", ");
        sb.append( $key.value ).append(");\n");
    }
    ;


condancestor:
    ANCESTOR IS key {
        sb.append( indent ).append(queryName).append(".setAncestor(").append( $key.value ).append(");\n");
    }
    ;


condin:
    property IN
    (
        (
            '(' {
                indent().append(queryName).append(".addFilter(\"").append($property.text).append("\", ");
                sb.append("Query.FilterOperator.IN, ").append( "\n" );
                indent( 2 ).append( "java.util.Arrays.asList( " );
            }
            listitem (',' {
                sb.append(", ");
            }
            listitem)* ')' {
                sb.append( " ));\n" );
            }
        )
        | var {
            if ( !$var.isList ) {
                throw new IllegalArgumentException("Passing non-list parameter to 'IN :1' condition");
            }

            if ( lastTarg.startsWith( "EnumId" )) {
                String etype = lastTarg.substring( 7 );

                indent().append( "if ( ").append( $var.value ).append( " == null || ");
                sb.append( $var.value ).append( ".size() == 0 ) {\n" );
                indent( 2 ).append( "throw new NullPointerException(\"The list parameter for GQL IN condition cannot be null nor empty: '");
                sb.append( $var.value ).append( "'\" );\n");
                indent().append( "}\n\n" );

                indent().append( "ArrayList<" ).append( etype ).append( "> _list" ).append( $var.value );
                sb.append( " = new ArrayList<" ).append( etype ).append( ">( " ).append( $var.value ).append( ".size());\n" );

                indent().append( "for ( " ).append( lastTargClass ).append( " _o : " );
                sb.append( $var.value ).append( " ) {\n" );

                indent( 2 ).append( "_list" ).append( $var.value ).append( ".add( _o != null ? _o.getId() : null );\n" );

                indent().append( "}\n\n" );
            }

            indent().append(queryName).append(".addFilter(\"").append($property.text).append("\", ");
            sb.append("Query.FilterOperator.IN, ").append( varArgList( lastTarg, $var.value )).append( " );\n" );
        }
    )
    ;


condinkey:
    KEYPROP IN {
        sb.append( indent ).append(queryName).append(".addFilter(\"").append($KEYPROP.text).append("\", ");
        sb.append("Query.FilterOperator.IN, ");
    }
    (
        (
            '(' {
                sb.append( "\n" ).append( indent ).append( "    java.util.Arrays.asList( " );
            }
            listitemkey (',' { sb.append(", "); } listitemkey)* ')' {
                sb.append(" )");
            }
        )
        | var {
            sb.append( $var.value );
        }
    ) {
        sb.append( " );\n" );
    }
    ;


oper returns[String value]:
    EQ { $value = $EQ.text; }
    | OPER { $value = $OPER.text; };


listitem:
    valorvarobj {
        sb.append( $valorvarobj.value );
    }
    ;


listitemkey:
    key {
        sb.append( $key.value );
    }
    ;


key returns[String value]:
    STRING {
        $value = "KeyFactory.stringToKey(" + string($STRING.text) + ')';
    }
    | var {
        if ("String".equals( lastTargClass )) {
            $value = "KeyFactory.stringToKey(" + $var.value + ')';
        }
        else {
            $value = $var.value;
        }
    }
    | keyfunc {
        $value = $keyfunc.value;
    }
    ;


keyfunc returns[String value]:
    KEY '('
    (
        vov=stringorvar {
            $value = "KeyFactory.stringToKey(" + $vov.value + ')';
        }
        | kp=keypath {
            $value = $kp.value;
        }
    )
    ')'
    ;


keypath returns[String value]:
    kin=STRING ',' vov=intstringorvar {
        $value = "new KeyFactory.Builder(" + string($kin.text) + ", " + $vov.value + ')';
    }
    kp=keypathchild ?
    {
        if (kp != null) $value += $kp.value;
        $value += ".getKey()";
    }
    ;


keypathchild returns[String value]:
    ',' kin=STRING ',' vov=intstringorvar
    { $value = ".addChild(" + string( $kin.text ) + ", " + $vov.value +')';}
    kp=keypathchild ?
    { if (kp != null) $value += $kp.value;}
    ;


orderby: ORDER BY orderbyitem (',' orderbyitem)*;


orderbyitem:
    ( property | KEYPROP ) {
        sb.append( indent ).append(queryName).append(".addSort(\"")
            .append( $property.value != null ? $property.value : $KEYPROP.text )
            .append('"');
    }
    (
        ASC { sb.append(", Query.SortDirection.ASCENDING");}
        | DESC { sb.append(", Query.SortDirection.DESCENDING");}
    )?
    { sb.append(" );\n");}
    ;


limit: LIMIT (INT ',')? INT;


offset: OFFSET INT;


valorvarobj returns[String value, boolean isList]:
    t_long { $value = "new Long(" + $t_long.value + ')';}
    | t_double { $value = "new Double(" + $t_double.value + ')';}
    | TRUE { $value = "Boolean.TRUE";}
    | FALSE { $value = "Boolean.FALSE";}
    | NULL { $value = "null"; }
    | datetime { $value = $datetime.value;}
    | keyfunc { $value = $keyfunc.value;}
    | geopt { $value = $geopt.value;}
    | user { $value = $user.value;}
    | stringorvar { $value = $stringorvar.value; $isList = $stringorvar.isList; }
    ;


datetime returns[String value]:
    DATE '(' sval=STRING ')' { $value = date( string($sval.text, false)); }
    | DATETIME '(' sval=STRING ')' { $value = datetime( string($sval.text, false)); }
    | TIME '(' sval=STRING ')' { $value = time( string($sval.text, false)); }
    | DATE '(' year=intorvar ',' month=intorvar ',' day=intorvar ')'
        { $value = "date( " + $year.value + ", " + $month.value + ", " + $day.value + " )"; }
    | DATETIME '(' year=intorvar ',' month=intorvar ',' day=intorvar ',' hour=intorvar ',' minute=intorvar ',' second=intorvar ')'
        { $value = "datetime( " + $year.value + ", " + $month.value + ", " + $day.value + ", " + $hour.value + ", " + $minute.value + ", " + $second.value +  " )"; }
    | TIME '(' hour=intorvar ',' minute=intorvar ',' second=intorvar ')'
        { $value = "time( " + $hour.value + ", " + $minute.value + ", " + $second.value +  " )"; }
    ;


geopt returns[String value]:
    GEOPT '(' lat=numberorvar ',' lon=numberorvar ')' {
        $value = "geopt(" + $lat.value + ", " + $lon.value + ')' ;
    }
    ;


user returns[String value]:
    USER '(' email=stringorvar ')' {
        $value = "user( " + $email.value + " )";
    }
    ;


intstringorvar returns[String value]:
    INT { $value = $INT.text;}
    | stringorvar { $value = $stringorvar.value;}
    ;


intorvar returns[String value]:
    INT { $value = $INT.text;}
    | var { $value = $var.value;}
    ;


numberorvar returns[String value]:
    t_long { $value = $t_long.value;}
    | t_double { $value = $t_double.value;}
    | var { $value = $var.value;}
    ;


stringorvar returns[String value, boolean isList]:
    STRING { $value = string( $STRING.text );}
    | var { $value = $var.value; $isList = $var.isList; }
    ;


t_long returns[String value]:
    PLUS? INT {
        $value = $INT.text;
    }
    | MINUS INT {
        $value = "-" + $INT.text;
    };


t_double returns[String value]:
    PLUS? FLOAT {
        $value = $FLOAT.text;
    }
    | MINUS FLOAT {
        $value = "-" + $FLOAT.text;
    };


var returns[String value, boolean isList]:
    VARID {
        int pos = Integer.parseInt( $VARID.text.substring(1));
        String arg = arg( pos );
        String targ = targ( pos );

        if ( targ.startsWith( "List" )) {
            $value = arg;
            $isList = true;
            int liop = targ.lastIndexOf('|');
            lastTargClass = targ.substring( 5, liop );
            lastTarg = targ.substring( liop+1 );
            wasLastListForced = false;
        }
        else if ( targ.startsWith( "ForcedList" )) {
            $value = arg;
            $isList = true;
            int liop = targ.lastIndexOf('|');
            lastTargClass = targ.substring( 11, liop );
            lastTarg = targ.substring( liop+1 );
            wasLastListForced = true;
        }
        else {
            $value = varArg( targ, arg );
            $isList = false;
            lastTargClass = lastTarg = targ;
        }
    }
    | VARNAME {
        $value = $VARNAME.text.substring(1);
    }
    ;


property returns[String value]:
    ID {
        $value = $ID.text;
    }
    | STRING {
        $value = string( $STRING.text, false );
    }
    ;


kind returns[String value]:
    (
        id=ID {
            $value = $id.text;
        }
        (
            '.' id2=ID {
                $value += '.' + $id2.text;
            }
        )*
    )
    | STRING {
        $value = string( $STRING.text, false );
    }
    ;

