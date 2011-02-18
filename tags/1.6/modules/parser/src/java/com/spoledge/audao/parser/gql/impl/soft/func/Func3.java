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

import java.util.List;


/**
 * The parent of all 3-argument functions.
 */
public abstract class Func3 extends Func {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValueImpl( List<Object> args ) {
        return getFunctionValue( args.get( 0 ), args.get( 1 ), args.get( 2 ));
    }


    protected void checkNumOfParams( List<Object> args ) {
        checkNumOfParams( 3, args );
    }


    protected abstract Object getFunctionValue( Object arg1, Object arg2, Object arg3 );

}

