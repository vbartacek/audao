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
package com.spoledge.audao.generator;

import java.util.ArrayList;

import javax.xml.transform.TransformerException;


/**
 * This exception encapsulates all warnings and errors got while generating.
 */
public class GeneratorException extends Exception {

    public enum Type {
        WARNING, ERROR, FATAL_ERROR;
    }


    private ArrayList<TransformerException> exceptions;
    private ArrayList<Type> types;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a FATAL_ERROR exception.
     */
    public GeneratorException( TransformerException e ) {
        this( new ArrayList<TransformerException>(), new ArrayList<Type>());

        exceptions.add( e );
        types.add( Type.FATAL_ERROR );
    }


    /**
     * Creates a new exception by asking GeneratorFlow.
     */
    public GeneratorException( GeneratorFlow gf ) {
        this( gf.getExceptions(), gf.getExceptionTypes());
    }


    /**
     * Creates a new exception.
     */
    public GeneratorException( ArrayList<TransformerException> exceptions, ArrayList<Type> types) {
        this.exceptions = exceptions;
        this.types = types;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    public ArrayList<TransformerException> getExceptions() {
        return exceptions;
    }


    public ArrayList<Type> getTypes() {
        return types;
    }


    public boolean isWarningOnly() {
        if (types == null) return false;

        for (Type type : types) {
            if (type != Type.WARNING) return false;
        }

        return true;
    }


    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();

        append( sb, 0 );

        for (int i=1; i < exceptions.size(); i++) {
            append( sb.append("\n"), i );
        }

        return sb.toString();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private void append( StringBuilder sb, int i ) {
        sb.append( " >> " ).append( types.get( i )).append(": ").append( exceptions.get( i ).getMessage());
    }
}
