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

import javax.xml.parsers.SAXParser;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;


/**
 * A simple XML validator.
 *
 * @author <a href="mailto:vaclav.bartacek@spolecne.cz">Vaclav Bartacek</a>
 */
public class XMLValidatorInstance extends DefaultHandler {

    public static final String DEFAULT_ENCODING = "UTF-8";

    protected Locator locator;
    protected String encoding;
    protected Exception parseException;

    /**
     * The doc type (root element).
     */
    protected String rootElement;

    protected String lastStartElement;
    protected String lastEndElement;

    private SAXParser saxParser;
    private InputSource is;

    private Log log = LogFactory.getLog(getClass());


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public XMLValidatorInstance( SAXParser saxParser ) {
        this.saxParser = saxParser;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Validates the document.
     */
    public void validate( File file ) {
        try {
            saxParser.parse( file, this );
        }
        catch (Exception e) {
            handle( e );
        }
    }


    /**
     * Validates the document.
     */
    public void validate( InputSource src ) {
        try {
            saxParser.parse( src, this );
        }
        catch (Exception e) {
            handle( e );
        }
    }


    /**
     * Returns the root element.
     */
    public String getRootElement() {
        return rootElement;
    }


    /**
     * Returns true iff this XML is valid.
     */
    public boolean isValid() {
        return parseException == null;
    }

    /**
     * Returns false iff this file is invalid.
     */
    public boolean isInvalid() {
        return parseException != null;
    }


    /**
     * Returns the exception thrown during parse() method.
     */
    public Exception getParseException() {
        return parseException;
    }


    ////////////////////////////////////////////////////////////////////////////
    // ContentHandler - Parsing XML
    ////////////////////////////////////////////////////////////////////////////

    /**
     * XML parser method.
     */
    public void startElement(String uri, String lName, String qName, Attributes attributes) throws SAXException {

        if (rootElement == null) rootElement = lName;

        lastStartElement = lName;
    }


    /**
     * XML parser method.
     */
    public void endElement(String uri, String lName, String qName) throws SAXException {
        lastEndElement = lName;
        if (lName != null && lName.equals( lastStartElement )) {
            lastStartElement = null;
        }
    }


    /**
     * XML parser method.
     */
    public void characters(char[] chars, int start, int length) throws SAXException {
    }


    public void setDocumentLocator(Locator l) {
        this.locator = l;
    }


    ////////////////////////////////////////////////////////////////////////////
    // ErrorHandler - Parsing XML
    ////////////////////////////////////////////////////////////////////////////

    /**
     * XML parser method.
     */
    public void warning(SAXParseException e) throws SAXException {
        if (log.isWarnEnabled()) {
            log.warn("warning(): " + e );
        }
    }


    /**
     * XML parser method.
     */
    public void error(SAXParseException e) throws SAXException {
        throw new SAXParseException( "line " + locator.getLineNumber()
            + " column " + locator.getColumnNumber()
            + (lastStartElement != null ? " in '" + lastStartElement + "'" :
                (lastEndElement != null ? " after '" + lastEndElement + "'": ""))
            + ": " + e.getMessage(), locator );
    }


    /**
     * XML parser method.
     */
    public void fatalError(SAXParseException e) throws SAXException {
        throw new SAXParseException( "line " + locator.getLineNumber()
            + " column " + locator.getColumnNumber()
            + (lastStartElement != null ? " in '" + lastStartElement + "'" :
                (lastEndElement != null ? " after '" + lastEndElement + "'": ""))
            + ": " + e.getMessage(), locator );
    }


    ////////////////////////////////////////////////////////////////////////////
    // EntityHandler - Parsing XML
    ////////////////////////////////////////////////////////////////////////////

    /**
     * XML parser method.
     */
    public InputSource resolveEntity( String publicId, String systemId ) {
        if (log.isDebugEnabled()) {
            log.debug( "resolveEntity(): publicId=" + publicId + ", systemId=" + systemId);
        }

        return null;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Parses the input.
     */
    private void handle( Exception e ) {
        if (e instanceof SAXParseException) {
            parseException = e;
        }
        else if (e instanceof SAXException) {
            Exception ee = ((SAXException)e).getException();

            if ((ee != null) && (ee instanceof Exception)) {
                parseException = (Exception) ee;
            }
            else {
                if (ee != null) log.error("parse():", ee);
                else log.error("parse():", e);

                parseException = new Exception( "Error when parsing" );
            }
        }
        else {
            log.error("parse():", e );
            parseException = new Exception( "Internal Error when parsing" );
        }
    }

}
