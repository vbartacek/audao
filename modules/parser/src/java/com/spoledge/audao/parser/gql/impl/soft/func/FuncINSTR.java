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
 * INSTR( text, substring [, start [, occurrence ]) .<br/>
 *
 * Searches for substring in the text.
 * Returns the position fo the substring found or 0 if not found. <br/>
 *
 * start: optional 1,2,3... (1 = first char)
 *        if negative, then searches backwards (-1 = last char)
 *        if 0, then starting at the first char.<br/>
 *
 * occurrence: optional number 1,2,...
 */
public class FuncINSTR extends Func {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValueImpl( List<Object> args ) {
        String text = argString( args.get( 0 ));
        if (text == null) return null;

        String s = argString( args.get( 1 ));
        if (s == null) return 0L;

        int index = args.size() > 2 ? argInt( args.get( 2 )) : 1;
        boolean isReverse = false;

        if (index < 0 ) {
            index = -index;
            isReverse = true;

            text = new StringBuilder(text).reverse().toString();
            s = new StringBuilder(s).reverse().toString();
        }

        if (index > 0 ) index--;
        if (index + s.length() > text.length()) return 0L;

        int occur = args.size() > 3 ? argInt( args.get( 3 )) : 1;

        index--;

        do {
            index = text.indexOf( s, index+1 );
        } while (index != -1 && --occur > 0 && index + s.length() + 1 < text.length());

        if (index != -1 && occur == 0) {
            if (isReverse) index = text.length() - index - s.length();
            index++;
        }
        else index = 0;

        return (long) index;
    }


    protected void checkNumOfParams( List<Object> args ) {
        checkNumOfParams( 2, 4, args );
    }

}


