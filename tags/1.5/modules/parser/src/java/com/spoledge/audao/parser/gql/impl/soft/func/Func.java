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

import com.spoledge.audao.parser.gql.impl.soft.SoftFunction;


/**
 * The parent of all functions.
 */
public abstract class Func implements SoftFunction {

    ////////////////////////////////////////////////////////////////////////////
    // SoftFunction
    ////////////////////////////////////////////////////////////////////////////

    public final Object getFunctionValue( List<Object> args ) {
        checkNumOfParams( args );

        try {
            return getFunctionValueImpl( args );
        }
        catch (RuntimeException e) {
            throw new RuntimeException("Cannot evaluate function: " + getFunctionWithParams( args ), e);
        }
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected abstract Object getFunctionValueImpl( List<Object> args );

    protected abstract void checkNumOfParams( List<Object> args );


    protected final void checkNumOfParams( int expectedCount, List<Object> args ) {
        int realCount = args != null ? args.size() : 0;

        if (expectedCount != realCount)
            throw new RuntimeException(
                "Expected " + expectedCount + " parameters, but got " + realCount
                + " in function: " + getFunctionWithParams( args ));
    }


    protected final void checkNumOfParams( int minCount, int maxCount, List<Object> args ) {
        int realCount = args != null ? args.size() : 0;

        if (minCount > 0 && minCount > realCount)
            throw new RuntimeException(
                "Expected at least " + minCount + " parameters, but got only " + realCount
                + " in function: " + getFunctionWithParams( args ));

        if (maxCount > 0 && maxCount < realCount)
            throw new RuntimeException(
                "Expected at most " + maxCount + " parameters, but got " + realCount
                + " in function: " + getFunctionWithParams( args ));
    }


    protected String getFunctionName() {
        String ret = getClass().getName();
        
        return ret.substring( ret.lastIndexOf( '.' ) + 5 );
    }


    protected final String getFunctionWithParams( List<Object> args) {
        StringBuilder sb = new StringBuilder();
        sb.append( getFunctionName());
        sb.append( '(' );

        if (args != null) {
            for (int i=0; i < args.size(); i++) {
                Object arg = args.get(i);

                if (i != 0) sb.append( ", " );

                if (arg != null) {
                    if (arg instanceof Number) sb.append( arg );
                    else {
                        sb.append( "'" );
                        sb.append( arg );
                        sb.append( "'" );
                    }
                }
                else sb.append( "null" );
            }
        }

        sb.append( ')' );
        
        return sb.toString();
    }

}

