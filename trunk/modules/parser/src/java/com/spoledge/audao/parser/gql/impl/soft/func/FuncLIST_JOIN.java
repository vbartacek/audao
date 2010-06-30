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
 * LIST_JOIN( string, list )
 *      joins a list into a string value.
 */
public class FuncLIST_JOIN extends Func2 {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValue( Object arg1, Object arg2 ) {
        if (arg2 == null) return null;
        if (!(arg2 instanceof List)) return arg2;

        String s = arg1 != null ? arg1.toString() : "";

        StringBuilder sb = new StringBuilder();
        List<?> list = (List<?>) arg2;

        for (Object o : list) {
            sb.append( o ).append( s );
        }

        if (sb.length() > 0) sb.setLength( sb.length() - s.length());

        return sb.toString();
    }

}

