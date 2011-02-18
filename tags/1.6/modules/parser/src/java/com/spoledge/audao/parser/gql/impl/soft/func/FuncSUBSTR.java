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

import static com.spoledge.audao.parser.gql.impl.ParserUtils.*;


/**
 * SUBSTR( text, start [, count ]) .<br/>
 *
 * start: 1,2,3... (1 = first char)
 *        if negative, then counts backwards (-1 = last char)
 *        if 0, then starting at the first char.<br/>
 *
 * count: optional number of characters.
 */
public class FuncSUBSTR extends Func {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValueImpl( List<Object> args ) {
        String s = argString( args.get( 0 ));
        if (s == null) return null;

        int index = argInt( args.get( 1 ));
        if (index < 0 ) {
            index = s.length() + index;
            if (index < 0) index = 0;
        }
        else if (index > 0 ) index--;

        if (index >= s.length()) return "";

        if (args.size() > 2) {
            int count = argInt( args.get( 2 ));
            if (count + index < s.length()) {
                return s.substring( index, index + count );
            }
        }

        return s.substring( index );
    }


    protected void checkNumOfParams( List<Object> args ) {
        checkNumOfParams( 2, 3, args );
    }

}

