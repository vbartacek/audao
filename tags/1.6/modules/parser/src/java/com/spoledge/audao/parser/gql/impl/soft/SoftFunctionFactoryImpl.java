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

import java.util.HashMap;


/**
 * The implementation of the SoftFunctionFactory.
 */
public class SoftFunctionFactoryImpl extends SoftFunctionFactory {

    private String classNamePrefix;
    private String classNameSuffix;
    private HashMap<String, SoftFunction> softFunctions = new HashMap<String, SoftFunction>();


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public SoftFunctionFactoryImpl( String packageName, String classNamePrefix, String classNameSuffix ) {
        this.classNamePrefix = (packageName != null ? packageName + '.' : "")
                                + (classNamePrefix != null ? classNamePrefix : "");
        this.classNameSuffix = classNameSuffix != null ? classNameSuffix : "";
    }


    ////////////////////////////////////////////////////////////////////////////
    // SoftFunctionFactory
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Returns the associated function.
     */
    public synchronized SoftFunction getSoftFunction( String name ) {
        SoftFunction ret = softFunctions.get( name );

        if (ret == null) {
            String classname = classNamePrefix + name + classNameSuffix;

            try {
                Class<?> aclazz = Class.forName( classname );
                Class<? extends SoftFunction> clazz = aclazz.asSubclass( SoftFunction.class );

                ret = clazz.newInstance();
            }
            catch (ClassNotFoundException e) {
                throw new RuntimeException( e );
            }
            catch (InstantiationException e) {
                throw new RuntimeException( e );
            }
            catch (IllegalAccessException e) {
                throw new RuntimeException( e );
            }

            softFunctions.put( name, ret );
        }

        return ret;
    }

    /**
     * Defines a new function.
     * It a function with the same name already exists, then it should throw an exception.
     * This is an optional operation.
     * @exception UnsupportedOperationException when this operation is not supported by the implementation
     */
    public synchronized void defineSoftFunction( String name, SoftFunction func ) {
        if (name == null || func == null) throw new NullPointerException();

        if (softFunctions.containsKey( name )) throw new RuntimeException("Function with name '" + name + "' already exists");

        softFunctions.put( name, func );
    }

}
