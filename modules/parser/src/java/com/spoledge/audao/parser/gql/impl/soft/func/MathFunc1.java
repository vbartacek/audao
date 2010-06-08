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

import static com.spoledge.audao.parser.gql.impl.ParserUtils.argDouble;


/**
 * The parent of all mathematic 1-argument functions.
 */
public abstract class MathFunc1 extends Func1 {

    private boolean supportsLongs;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    protected MathFunc1() {
        this( false );
    }


    protected MathFunc1( boolean supportsLongs ) {
        this.supportsLongs = supportsLongs;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected final Object getFunctionValue( Object arg ) {
        if (arg == null) return null;

        if (supportsLongs && (arg instanceof Long)) {
            return getFunctionValue( ((Long)arg).longValue());
        }

        return getFunctionValue( argDouble( arg ).doubleValue());
    }


    protected Object getFunctionValue( long arg ) {
        throw new Error("Please override this method");
    }


    protected abstract Object getFunctionValue( double arg );

}


