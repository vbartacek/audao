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

import java.util.HashMap;

import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * This is a utility class which caches compiled XSL templates.
 * Using this class instead of direct instantiating XSLT improves
 * the application's performance.
 * The caching mechanism is working with the SystemID identifier, so
 * be sure to use it correctly.
 */
public class TemplatesCache {

    private TransformerFactory transformerFactory;
    private Provider provider;

    private Log log = LogFactory.getLog(getClass());


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a new cache using MemoryProvider.
     */
    public TemplatesCache() {
        this( new MemoryProvider());
    }


    /**
     * Creates a new cache using a specific provider.
     */
    public TemplatesCache( Provider provider ) {
        if (provider == null) throw new NullPointerException("Provider cannot be null");

        this.provider = provider;
    }


    /**
     * Clears the cache, releases resource.
     */
    public void clear() {
        provider.clear();
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Returns a templates cache entry for the specified key.
     * @return the templates found in the cache or null
     */
    public synchronized Templates getTemplates( String key ) throws TransformerConfigurationException {
        return provider.get( key );
    }


    /**
     * Returns a templates cache entry for the specified system ID.
     * @return the templates found in the cache or a new one
     */
    public Templates getTemplates( Source source ) throws TransformerConfigurationException {
        return getTemplates( source.getSystemId(), source );
    }


    /**
     * Returns a templates cache entry for the specified system ID.
     * @return the templates found in the cache or a new one
     */
    public synchronized Templates getTemplates( String key, Source source ) throws TransformerConfigurationException {
        Templates ret = provider.get( key );

        if (log.isDebugEnabled()) {
            log.debug("getTemplates(): key=" + key + (ret == null ? " not" : "") + " found");
        }

        if (ret == null) {
            if (log.isDebugEnabled()) {
                log.debug("getTemplates(): creating new templates for key=" + key);
            }

            ret = getTransformerFactory().newTemplates( source );
            provider.put( key, ret );
        }

        return ret;
    }


    /**
     * Returns the transformer factory.
     */
    public synchronized TransformerFactory getTransformerFactory() {
        if (transformerFactory == null) {
            transformerFactory = TransformerFactory.newInstance();
            if (log.isDebugEnabled()) {
                log.debug("getTransformerFactory(): " + transformerFactory + ", class=" + transformerFactory.getClass());
            }
        }

        return transformerFactory;
    }


    /**
     * Sets the transformer factory.
     */
    public synchronized void setTransformerFactory( TransformerFactory tf ) {
        transformerFactory = tf;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////
    // Inner
    ////////////////////////////////////////////////////////////////////////////

    /**
     * A provider of the cached items.
     * This approach allows us to implement specific caches
     * like cache for Google App Engine.
     */
    public static class Provider {

        /**
         * Returns cached item or null.
         */
        public Templates get( String key ) {
            throw new Error("NOT-OVERRIDEN");
        }


        /**
         * Puts the Templates into the cache.
         */
        public void put( String key, Templates tpls ) {
            throw new Error("NOT-OVERRIDEN");
        }


        /**
         * Clears the cache, releases resource.
         */
        public void clear() {
            throw new Error("NOT-OVERRIDEN");
        }

    }


    /**
     * The simplest provider which caches the templates in memory.
     */
    public static class MemoryProvider extends Provider {
        private HashMap<String, Templates> cache = new HashMap<String, Templates>();

        /**
         * Returns cached item or null.
         */
        public Templates get( String key ) {
            return cache.get( key );
        }


        /**
         * Puts the Templates into the cache.
         */
        public void put( String key, Templates tpls ) {
            cache.put( key, tpls );
        }


        /**
         * Clears the cache, releases resource.
         */
        public void clear() {
            cache.clear();
        }

    }

}

