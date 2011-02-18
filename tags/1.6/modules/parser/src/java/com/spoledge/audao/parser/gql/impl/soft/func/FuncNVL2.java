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


/**
 * NVL2( expr, value1, value2 )
 * 
 * If expr is not null, then returns value1, otherwise value2.
 * Same as Oracle's NVL2 function.
 */
public class FuncNVL2 extends Func3 {

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected Object getFunctionValue( Object o1, Object o2, Object o3 ) {
        return o1 != null ? o2 : o3;
    }

}

