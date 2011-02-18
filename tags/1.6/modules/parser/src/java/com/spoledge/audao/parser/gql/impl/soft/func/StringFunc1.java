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

import static com.spoledge.audao.parser.gql.impl.ParserUtils.argString;


/**
 * The parent of all string 1-argument functions.
 */
public abstract class StringFunc1 extends Func1 {

    private boolean acceptsNull;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    protected StringFunc1() {
        this( false );
    }


    protected StringFunc1( boolean acceptsNull ) {
        this.acceptsNull = acceptsNull;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValue( Object arg ) {
        String s = argString( arg );

        if (!acceptsNull && s == null) return null;

        return getFunctionValue( s );
    }


    protected abstract Object getFunctionValue( String arg );
}

