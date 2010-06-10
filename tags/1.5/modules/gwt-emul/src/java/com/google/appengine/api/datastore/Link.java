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
 * Method hashCode() may differ from the original one.
 */
public class Link implements Serializable, Comparable<Link> {

    public static final long serialVersionUID = 731239796613544443L;

    private String link;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public Link( String link ) {
        this.link = link;
    }


    @SuppressWarnings("unused")
    private Link() {
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    public String getValue() {
        return link;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Comparable
    ////////////////////////////////////////////////////////////////////////////

    public int compareTo( Link o ) {
        return link.compareTo( o.link );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Misc
    ////////////////////////////////////////////////////////////////////////////

    public boolean equals( Object o ) {
        if (this == o) return true;
        if (o == null || (!(o instanceof Link))) return false;

        return compareTo( (Link) o) == 0;
    }


    public int hashCode() {
        return link.hashCode();
    }


    public String toString() {
        return link;
    }
}

