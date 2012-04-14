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
package com.spoledge.audao.parser.gql.impl.soft.func;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.List;

import static com.spoledge.audao.parser.gql.impl.ParserUtils.*;


/**
 * TO_CHAR( date[, fmt ]) .<br/>
 * TO_CHAR( number[, fmt ]) .<br/>
 * TO_CHAR( whatever ) .<br/>
 *
 * fmt: optional format - uses java.text.SimpleDateFormat for dates and java.text.DecimalFormat for numbers
 *
 * Converts misc types to the String type.
 */
public class FuncTO_CHAR extends Func {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValueImpl( List<Object> args ) {
        Object o = args.get( 0 );
        if (o == null) return null;

        String fmt = args.size() == 1 ? null : argString( args.get( 1 ));

        if (o instanceof Date) {
            Date date = (Date) o;

            SimpleDateFormat df = new SimpleDateFormat( fmt != null ? fmt : "yyyy-MM-dd HH:mm:ss" );

            return df.format( date );
        }
        else if (o instanceof Number) {
            Number number = (Number) o;

            DecimalFormat df = new DecimalFormat( fmt != null ? fmt : "0.####" );

            return df.format( number );
        }
        else {
            return o.toString();
        }
    }


    protected void checkNumOfParams( List<Object> args ) {
        checkNumOfParams( 1, 2, args );
    }

}


