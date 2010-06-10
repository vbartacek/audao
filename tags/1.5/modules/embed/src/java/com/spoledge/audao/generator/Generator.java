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

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Properties;

import javax.xml.transform.TransformerException;

import com.spoledge.util.xml.XMLValidator;
import com.spoledge.util.xml.XMLValidatorInstance;

import com.spoledge.util.xslt.ResourceURIResolver;
import com.spoledge.util.xslt.TemplatesCache;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * This is the main Generator class.
 * This class is thread safe.
 *
 * <pre>
 *  Generator g = new Generato( Generator.Target.ORACLE );
 *  g.generate( xml, new FileOutput());
 * </pre>
 */
public class Generator {

    /**
     * The global resources located in the JAR.
     */
    public static final String RESOURCES = "/resources";


    /**
     * The global XSD resources located in the JAR.
     */
    public static final String XSD_RESOURCES = RESOURCES + "/xsd";


    /**
     * The global XSL resources located in the JAR.
     */
    public static final String XSL_RESOURCES = RESOURCES + "/xsl";


    /**
     * The global XSL resources located in the JAR.
     */
    public static final String JAVA_RESOURCES = RESOURCES + "/java";


    /**
     * If no specific cache is provided, then all Generators
     * share the same global cache.
     */
    private static TemplatesCache globalTemplatesCache;


    /**
     * Precomputed set of AUDAO Java resource names for each Target.
     * This structure is lazy.
     */
    private static HashMap<Target, String[]> javaResourceKeys = new HashMap<Target, String[]>();


    /**
     * The AuDAO XML precompiled validator.
     */
    private static XMLValidator xmlValidator;


    ////////////////////////////////////////////////////////////////////////////
    // Attributes
    ////////////////////////////////////////////////////////////////////////////

    private Target target;
    private TemplatesCache templatesCache;
    private ResourceURIResolver resourceURIResolver = new ResourceURIResolver( XSL_RESOURCES );
    private String[] resourceKeys = new String[ 10 ];
    private boolean[] resourcesEnabled = new boolean[ 10 ];
    private boolean isDebugEnabled = false;

    private Log log = LogFactory.getLog(getClass());


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public Generator( Target target ) {
        if (target == null) throw new NullPointerException("Target cannost be null");
        this.target = target;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Returns the target of this generator.
     */
    public final Target getTarget() {
        return target;
    }


    /**
     * Enables/disables generating type of resource.
     */
    public void setResourceEnabled( ResourceType type, boolean enabled ) {
        resourcesEnabled[ type.ordinal()] = enabled;
    }


    /**
     * Enables/disables generating all types of resources.
     * NOTE: this method does NOT force generating inapplicable resources
     * for given Target (e.g. DTO_IMPL for "mysql")
     */
    public void setAllResourcesEnabled( boolean enabled ) {
        for (int i=0; i < resourcesEnabled.length; i++) {
            resourcesEnabled[ i ] = enabled;
        }
    }


    /**
     * Returns true if a debug mode is enabled.
     */
    public boolean getIsDebugEnabled() {
        return isDebugEnabled;
    }


    /**
     * Sets the debug mode flag.
     */
    public void setIsDebugEnabled( boolean enabled ) {
        this.isDebugEnabled = enabled;;
    }


    /**
     * Returns the resource key.
     * It detects whether the implementation file is present
     * (e.g. "dao/mysql/dto.xsl") and returns that or returns
     * general version ("dao/dto.xsl").
     *
     * @return the resource key or null if not applicable (e.g. SQL_CREATE for GAE)
     */
    public String getResourceKey( ResourceType type ) {
        int index = type.ordinal();
        String ret = resourceKeys[ index ];

        if (ret == null) {
            ret = getXslName( type, true );

            if (getClass().getResource( ret ) == null) {
                ret = type.getIsOptional() ? "" : getXslName( type, false );
            }

            resourceKeys[ index ] = ret;
        }

        return ret.length() != 0 ? ret : null;
    }


    /**
     * Validates source XML.
     */
    public void validate( String xml ) throws Exception {
        validate( new StringReader( xml ));
    }


    /**
     * Validates source XML.
     */
    public void validate( Reader reader ) throws Exception {
        XMLValidator xv = getXMLValidator();
        XMLValidatorInstance xvi = xv.validate( reader );

        if (xvi.isInvalid()) throw xvi.getParseException();
    }


    /**
     * Generates the result files.
     */
    public void generate( String pkgName, String xml, Output output ) throws IOException, GeneratorException {
        generate( pkgName, new StringReader( xml ), output );
    }


    /**
     * Generates the result files.
     */
    public void generate( String pkgName, Reader reader, Output output ) throws IOException, GeneratorException {
        GeneratorFlow gf = new GeneratorFlow( this, pkgName, reader, output );
        boolean generated = false;

        try {
            for (ResourceType type : ResourceType.values()) {
                if (resourcesEnabled[ type.ordinal()]) {
                    gf.generate( type );
                    generated = true;
                }
            }

            if (gf.hasExceptions()) throw new GeneratorException( gf );
        }
        catch (TransformerException e) {
            if (gf.hasExceptions()) throw new GeneratorException( gf );
            else throw  new GeneratorException( e );
        }

        if (gf.hasExceptions()) throw new GeneratorException( gf );

        if (!generated) {
            log.warn("generate(): nothing generated since no resource type enabled in the Generator");
        }
    }


    /**
     * Sets a templates cache to use.
     * By default Generator uses default MemoryCache same for all instances.
     */
    public void setTemplatesCache( TemplatesCache tc ) {
        tc.getTransformerFactory().setURIResolver( resourceURIResolver );
        this.templatesCache = tc;
    }


    /**
     * Returns the cache of XSL templates.
     */
    public synchronized TemplatesCache getTemplatesCache() {
        if (templatesCache == null) {
            synchronized (Generator.class) {
                if (globalTemplatesCache == null) {
                    globalTemplatesCache = new TemplatesCache();
                    globalTemplatesCache.getTransformerFactory().setURIResolver( resourceURIResolver );
                }
            }

            templatesCache = globalTemplatesCache;
        }

        return templatesCache;
    }


    /**
     * Returns the ResourceURIResolver.
     */
    public ResourceURIResolver getResourceURIResolver() {
        return resourceURIResolver;
    }


    /**
     * Returns the resource keys of the AUDAO Java source files.
     */
    public String[] getJavaResourceKeys() {
        synchronized (javaResourceKeys) {
            String[] ret = javaResourceKeys.get( target );

            if (ret == null) {
                ret = createJavaResourceKeys();
                javaResourceKeys.put( target, ret );
            }

            return ret;
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////


    private String getXslName( ResourceType type, boolean isSpec ) {
        return XSL_RESOURCES + '/' + type.getDir() + '/'
                + (isSpec ? getTarget().getIdentifier() + '/' : "") + type.getName();
    }


    private String[] createJavaResourceKeys() {
        ArrayList<String> list = new ArrayList<String>();

        Properties props = new Properties();

        try {
            props.load( getClass().getResourceAsStream( JAVA_RESOURCES + "/sources.properties" ));
        }
        catch (IOException e) {
            log.error("createJavaResourceKeys()", e);
        }

        // NOTE: JDK 1.5 compatibility - we cannot use stringPropertyNames():
        // for (String key : props.stringPropertyNames()) {
        for (Enumeration<?> en = props.propertyNames(); en.hasMoreElements();) {
            String key = (String) en.nextElement();
            String[] vals = props.getProperty( key ).split("\\|");

            if (vals.length == 1) {
                list.add( vals[0] );
            }
            else {
                String tname = target.getIdentifier().toLowerCase();
                for (int i=1; i < vals.length; i++) {
                    if (tname.equals( vals[i] )) {
                        list.add( vals[0] );
                        break;
                    }
                }
            }
        }

        String[] ret = new String[ list.size()];

        return list.toArray( ret );
    }


    private static XMLValidator getXMLValidator() {
        synchronized (Generator.class) {
            if (xmlValidator == null) {
                try {
                    xmlValidator = new XMLValidator( Generator.class.getResource( XSD_RESOURCES + "/audao.xsd" ));
                }
                catch (Exception e) {
                    LogFactory.getLog( Generator.class ).error("getXMLValidator(): ", e);
                }
            }

            return xmlValidator;
        }
    }
}

