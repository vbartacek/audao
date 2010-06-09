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
package com.google.appengine.api.datastore;

import java.io.Serializable;


/**
 * This is a GWT emulation class.
 * It is ONLY used on the client side - JavaScript.
 *
 * This class is intended to use with custom DTO serializers
 * generated by AuDAO.
 *
 * This is only used to construct incomplete keys.
 */
public class Entity implements Serializable {

    static final long serialVersionUID = -836647825120453511L;

    private Key key;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    @SuppressWarnings("unused")
    private Entity() {
    }


    public Entity( String kind ) {
        this( new Key( kind, null, 0, null ));
    }


    public Entity( String kind, Key parent ) {
        this( new Key( kind, parent, 0, null ));
    }


    public Entity( String kind, String keyName ) {
        this( new Key( kind, null, 0, keyName ));
    }


    public Entity( String kind, String keyName, Key parent ) {
        this( new Key( kind, parent, 0, keyName ));
    }


    public Entity( Key key ) {
        if (key == null) throw new IllegalArgumentException("Key cannot be empty");

        this.key = key;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    public Key getKey() {
        return key;
    }


    public String getKind() {
        return key.getKind();
    }


    public Key getParent() {
        return key.getParent();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Misc
    ////////////////////////////////////////////////////////////////////////////

    public boolean equals( Object o ) {
        if (this == o) return true;
        if (o == null || (!(o instanceof Entity))) return false;

        return key.equals( ((Entity)o).key );
    }

}