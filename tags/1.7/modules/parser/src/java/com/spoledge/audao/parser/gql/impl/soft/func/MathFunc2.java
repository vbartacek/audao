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
 * The parent of all mathematic 2-argument functions.
 */
public abstract class MathFunc2 extends Func2 {

    private boolean supportsLongs;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    protected MathFunc2() {
        this( false );
    }


    protected MathFunc2( boolean supportsLongs ) {
        this.supportsLongs = supportsLongs;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected final Object getFunctionValue( Object o1, Object o2 ) {
        if (o1 == null) return o2;
        if (o2 == null) return o1;

        if ((o1 instanceof Number) && (o2 instanceof Number)) {
            Number n1 = (Number) o1;
            Number n2 = (Number) o2;

            if (!supportsLongs || (n1 instanceof Double) || (n2 instanceof Double)) {
                return getFunctionValue( n1.doubleValue(), n2.doubleValue());
            }
            else return getFunctionValue( n1.longValue(), n2.longValue());
        }

        return getOtherValue( o1, o2 );
    }


    protected Object getFunctionValue( long arg1, long arg2 ) {
        throw new Error("Please override this method");
    }


    protected abstract Object getFunctionValue( double arg1, double arg2 );


    protected Object getOtherValue( Object o1, Object o2 ) {
        throw new RuntimeException("Illegal argument type");
    }

}



