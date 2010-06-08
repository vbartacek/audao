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

import java.util.Date;


/**
 * MINUS( x, y )
 *  - returns x minus y - either long or double.
 * The standard minus operator ('-') is mapped to this function.
 */
public class FuncMINUS extends MathFunc2 {

    private static final long DAY_MILLIS = 24L * 3600000L;

    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public FuncMINUS() {
        super( true );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    @Override
    protected Object getFunctionValue( long arg1, long arg2 ) {
        return arg1 - arg2;
    }


    protected Object getFunctionValue( double arg1, double arg2 ) {
        return arg1 - arg2;
    }


    @Override
    protected Object getOtherValue( Object o1, Object o2 ) {
        boolean isDate = o1 instanceof Date;

        if (isDate && (o2 instanceof Number)) {
            Date date = (Date) o1;
            Number n = (Number) o2;
            long millis = 0;

            if (n instanceof Long) millis = DAY_MILLIS * n.longValue();
            else millis = (long)(DAY_MILLIS * n.doubleValue());

            return new Date( date.getTime() - millis );
        }

        if (isDate && (o2 instanceof Date)) {
            Date date1 = (Date) o1;
            Date date2 = (Date) o2;

            return (date1.getTime() - date2.getTime()) / (double) DAY_MILLIS;
        }

        return super.getOtherValue( o1, o2 );
    }

}

