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

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.GeoPt;
import com.google.appengine.api.datastore.Key;

import com.google.appengine.api.users.User;


public class GaeTypes {

    /**
     * Comparator not available - cannot compare.
     */
    public static final int N_A = -10;

    public enum Type { NULL, BOOL, LONG, DOUBLE, STRING, DATE, KEY, GEOPT, USER, OTHER }

    /**
     * Compares all single values.
     * @return -1,0,1 (less tan, equals, greater than) or N_A (-10) which means cannot compare
     */
    public static int compare( Object o1, Object o2 ) {
        if (o1 == null) return o2 == null ? 0 : -1;
        if (o2 == null) return 1;

        Type type1 = getType( o1 );
        Type type2 = getType( o2 );

        if (type1 != type2) return type1.ordinal() - type2.ordinal();

        switch (type1) {
            case BOOL: return ((Boolean)o1).compareTo((Boolean)o2);
            case LONG: return ((Long)o1).compareTo((Long)o2);
            case DOUBLE: return ((Double)o1).compareTo((Double)o2);
            case STRING: return ((String)o1).compareTo((String)o2);
            case DATE: return ((java.util.Date)o1).compareTo((java.util.Date)o2);
            case KEY: return ((Key)o1).compareTo((Key)o2);
            case GEOPT: return ((GeoPt)o1).compareTo((GeoPt)o2);
            case USER: return ((User)o1).compareTo((User)o2);
            default:
                return N_A;
        }
    }


    public static Type getType( Object o ) {
        if (o == null) return Type.NULL;
        if (o instanceof String) return Type.STRING;
        if (o instanceof Long) return Type.LONG;
        if (o instanceof Double) return Type.DOUBLE;
        if (o instanceof Boolean) return Type.BOOL;
        if (o instanceof Key) return Type.KEY;
        if (o instanceof GeoPt) return Type.GEOPT;
        if (o instanceof User) return Type.USER;

        return Type.OTHER;
    }
}

