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
package com.spoledge.audao.parser.gql.impl.soft;

/**
 * The factory.
 */
public abstract class SoftFunctionFactory {

    private static SoftFunctionFactory defaultFactory;


    ////////////////////////////////////////////////////////////////////////////
    // SoftFunctionFactory
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Returns the associated function.
     */
    public abstract SoftFunction getSoftFunction( String name );


    /**
     * Defines a new function.
     * It a function with the same name already exists, then it should throw an exception.
     * This is an optional operation.
     * @exception UnsupportedOperationException when this operation is not supported by the implementation
     */
    public void defineSoftFunction( String name, SoftFunction func ) {
        throw new UnsupportedOperationException();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Static
    ////////////////////////////////////////////////////////////////////////////

    public static synchronized SoftFunctionFactory getDefaultFactory() {
        if (defaultFactory == null) {
            defaultFactory = new SoftFunctionFactoryImpl(
                                    "com.spoledge.audao.parser.gql.impl.soft.func",
                                    "Func",
                                    null );
        }

        return defaultFactory;
    }


    /**
     * Sets the default factory.
     * Call this method if you want to use your own factory implementations.
     */
    public static synchronized void setDefaultFactory( SoftFunctionFactory factory ) {
        defaultFactory = factory;
    }

}

