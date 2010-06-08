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
package com.spoledge.util.xslt;

import java.io.InputStream;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * This is a simple URI resolver which resolves the URIs
 * against the resources included in the jar file.
 *
 * If the TemplatesCache is set, then it first looks into 
 * it and if not found then it creates it and put it into the cache.
 * Otherwise it creates a new Source.
 */
public class ResourceURIResolver implements URIResolver {

    private String root;
    private TemplatesCache templatesCache;

    private Log log = LogFactory.getLog(getClass());


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates an empty resolver with root "/".
     */
    public ResourceURIResolver() {
        this( "" );
    }


    /**
     * Creates an empty resolver with specified root.
     * @param root the root directory of the Jar where all the resources must reside; use slashes "/"
     */
    public ResourceURIResolver( String root ) {
        this( root, null );
    }

    /**
     * Creates an empty resolver with specified root.
     * @param root the root directory of the Jar where all the resources must reside; use slashes "/"
     */
    public ResourceURIResolver( String root, TemplatesCache cache ) {
        if (root == null) root = "";
        else if (root.endsWith("/")) root = root.length() == 1 ? "" : root.substring( 0, root.length()-1);

        this.root = root;
        this.templatesCache = cache;
    }


    ////////////////////////////////////////////////////////////////////////////
    // URIResolver
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Called by the processor when it encounters an xsl:include, xsl:import, or document() function.
     */
    public Source resolve( String href, String base ) throws TransformerException {
        if (log.isDebugEnabled()) {
            log.debug("resolve(): " + base + " -> " + href);
        }

        String key = root;

        if (base != null) {
            // fix Windows paths - dir separator
            base = base.replace( '\\', '/' );

            if (base.startsWith( "file://")) base = base.substring( 7 );
            else if (base.startsWith( "file:")) base = base.substring( 5 );

            // fix Windows paths - prefix "C:"
            if (base.length() > 2 && base.charAt(2) == ':') {
                base = base.substring( 3 );
            }
            else if (base.length() > 1 && base.charAt(1) == ':') {
                base = base.substring( 2 );
            }

            // crop the last element
            key = base.substring( 0, base.lastIndexOf( '/' ));
        }

        while (href.startsWith( "../" )) {
            int index = key.lastIndexOf( '/' );
            key = key.substring( 0, index );
            href = href.substring( 3 );
        }

        if (!href.startsWith( "/" )) href = "/" + href;

        key += href;

        if (log.isDebugEnabled()) {
            log.debug("resolve(): key=" + key);
        }

        return getSource( key );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////

    private Source getSource( String path ) {
        InputStream is = getClass().getResourceAsStream( path );

        if (is == null) {
            log.warn("getSource(): cannot find resource '" + path + "'");
        }

        return new StreamSource( is, path );
    }
}
