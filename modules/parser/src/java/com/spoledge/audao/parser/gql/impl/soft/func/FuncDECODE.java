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
 * DECODE( expr, search1, value1 [, search2, value2 ...] [, otherwise])
 *  - same as Oracle's DECODE function.
 */
public class FuncDECODE extends Func {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValueImpl( List<Object> args ) {
        boolean hasDef = args.size() % 2 == 0;
        Object def = hasDef ? args.get( args.size()-1 ) : null;
        Object expr = args.get( 0 );
        boolean isNull = expr == null;
        int max = hasDef ? args.size() - 1 : args.size();

        for (int i=1; i < max; i += 2) {
            Object search = args.get(i);

            if (isNull) {
                if (search == null) return args.get(i+1);
            }
            else if (expr.equals( search )) return args.get(i+1);
        }

        return def;
    }


    protected void checkNumOfParams( List<Object> args ) {
        checkNumOfParams( 3, -1, args );
    }

}

