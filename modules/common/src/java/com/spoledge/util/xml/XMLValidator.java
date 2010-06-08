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
package com.spoledge.util.xml;

import java.io.File;
import java.io.Reader;

import java.net.URL;

import javax.xml.XMLConstants;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;


/**
 * A simple XML validator.
 *
 * @author <a href="mailto:vaclav.bartacek@spolecne.cz">Vaclav Bartacek</a>
 */
public class XMLValidator {

    private SAXParserFactory spf;

    private Log log = LogFactory.getLog(getClass());


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public XMLValidator( File schema ) throws SAXException {
        SchemaFactory sf = SchemaFactory.newInstance( XMLConstants.W3C_XML_SCHEMA_NS_URI );
        init( sf.newSchema( schema ));
    }


    public XMLValidator( URL schema ) throws SAXException {
        SchemaFactory sf = SchemaFactory.newInstance( XMLConstants.W3C_XML_SCHEMA_NS_URI );
        init( sf.newSchema( schema ));
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Validates the document.
     */
    public XMLValidatorInstance validate( File xml ) {
        XMLValidatorInstance ret = new XMLValidatorInstance( getNewSAXParser());

        ret.validate( xml );

        return ret;
    }


    /**
     * Validates the document.
     */
    public XMLValidatorInstance validate( Reader xml ) {
        return validate( new InputSource( xml ));
    }


    /**
     * Validates the document.
     */
    public XMLValidatorInstance validate( InputSource xml ) {
        XMLValidatorInstance ret = new XMLValidatorInstance( getNewSAXParser());

        ret.validate( xml );

        return ret;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private void init( Schema schema ) {
        spf = SAXParserFactory.newInstance();
        spf.setNamespaceAware( true );
        spf.setSchema( schema );
    }


    private synchronized SAXParser getNewSAXParser() {
        try {
            return spf.newSAXParser();
        }
        catch (Exception e) {
            log.error("getNewSAXParser():" + e);

            return null;
        }
    }


    ////////////////////////////////////////////////////////////////////////////
    // MAIN
    ////////////////////////////////////////////////////////////////////////////


    public static void main(String[] args) {
        if (args.length != 2 ) {
            System.out.println("usgage: XML XSD");
        }
        else {
            try {
                XMLValidator xv = new XMLValidator( new File( args[1]));
                XMLValidatorInstance xvi = xv.validate( new File( args[0]));
                if (xvi.isInvalid()) throw xvi.getParseException();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
