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

import com.google.appengine.api.datastore.GeoPt;


/**
 * The parent of all GeoPt 1-argument functions.
 */
public abstract class GeoPtFunc1 extends Func1 {

    private boolean acceptsNull;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    protected GeoPtFunc1() {
        this( false );
    }


    protected GeoPtFunc1( boolean acceptsNull ) {
        this.acceptsNull = acceptsNull;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValue( Object arg ) {
        if (!acceptsNull && arg == null) return null;

        if (!(arg instanceof GeoPt)) {
            throw new RuntimeException( "Expected GeoPt as argument" );
        }

        return getFunctionValue( (GeoPt) arg );
    }


    protected abstract Object getFunctionValue( GeoPt arg );
}


