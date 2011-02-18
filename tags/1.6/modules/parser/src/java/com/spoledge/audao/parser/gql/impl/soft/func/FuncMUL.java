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


/**
 * MUL( x, y )
 *  - returns x multiply y - either long or double.
 * The standard mupliplication operator ('*') is mapped to this function.
 */
public class FuncMUL extends MathFunc2 {

    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public FuncMUL() {
        super( true );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    @Override
    protected Object getFunctionValue( long arg1, long arg2 ) {
        return arg1 * arg2;
    }


    protected Object getFunctionValue( double arg1, double arg2 ) {
        return arg1 * arg2;
    }


    @Override
    protected Object getOtherValue( Object o1, Object o2 ) {
        if ((o1 instanceof String) && (o2 instanceof Number)) {
            // Perl's string x count
            String s = (String) o1;
            long count = ((Number)o2).longValue();
            StringBuilder sb = new StringBuilder();
            while (count-- > 0) sb.append( s );

            return sb.toString();
        }

        return super.getOtherValue( o1, o2 );
    }
}

