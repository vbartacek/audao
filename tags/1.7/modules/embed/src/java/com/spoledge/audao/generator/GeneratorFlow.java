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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Reader;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.LinkedHashSet;
import java.util.Properties;
import java.util.Set;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.Result;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import com.spoledge.util.xslt.TemplatesCache;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * This is actualy the worker.
 */
public class GeneratorFlow implements ErrorListener {

    private Generator generator;
    private String pkgName;
    private String dirName;
    private Reader xmlReader;
    private Output output;

    private String xmlPreprocessed;
    private Properties listProps;
    private Set<String> tableNames;

    private byte[] buffer;

    private ArrayList<TransformerException> exceptions;
    private ArrayList<GeneratorException.Type> exceptionTypes;
    private boolean isFatalError = false;

    private Log log = LogFactory.getLog(getClass());


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public GeneratorFlow( Generator generator, String pkgName, Reader xmlReader, Output output ) {
        this.generator = generator;
        this.pkgName = pkgName;
        this.xmlReader = xmlReader;
        this.output = output;

        dirName = "dao/" + pkgName.replace( '.', '/' ) + '/';
    }


    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////

    public void generate( ResourceType type ) throws IOException, TransformerException {
        switch ( type ) {
            case DTO: generateDtos(); break;
            case DTO_IMPL: generateDtoImpls(); break;
            case DTO_GWT_SERIALIZER: generateDtoGwtSerializers(); break;
            case DAO: generateDaos(); break;
            case DAO_IMPL: generateDaoImpls(); break;
            case FACTORY: generateFactory(); break;
            case FACTORY_IMPL: generateFactoryImpl(); break;
            case SQL_CREATE: generateSqlCreate(); break;
            case SQL_DROP: generateSqlDrop(); break;
            case AUDAO_JAVA: generateAudaoJava(); break;
            default:
                log.warn("generate(): unknown resource type " + type);
        }
    }


    public void generateDtos() throws IOException, TransformerException {
        Transformer transformer = getTransformer( ResourceType.DTO );
        String path = dirName + "dto/";

        for (String tableName : getTableNames()) {
            if (hasDto( tableName )) {
                transformer.setParameter( "table_name", tableName);
                transformer.transform( getSource(), output.addResult( file( path, tableName, "" )));
            }
        }
    }


    public void generateDtoGwtSerializers() throws IOException, TransformerException {
        Transformer transformer = getTransformer( ResourceType.DTO_GWT_SERIALIZER );
        String path = dirName + "dto/";

        for (String tableName : getTableNames()) {
            if (hasDto( tableName )) {
                transformer.setParameter( "table_name", tableName);
                transformer.transform( getSource(), output.addResult( file( path, tableName, "_CustomFieldSerializer" )));
            }
        }
    }


    public void generateDtoImpls() throws IOException, TransformerException {
        Transformer transformer = getTransformer( ResourceType.DTO_IMPL );

        if (transformer == null) return;

        String path = dirName + "dto/" + generator.getTarget().getIdentifier() + '/';

        for (String tableName : getTableNames()) {
            if (hasDto( tableName )) {
                transformer.setParameter( "table_name", tableName);
                transformer.transform( getSource(), output.addResult( file( path, tableName, "Impl" )));
            }
        }
    }


    public void generateDaos() throws IOException, TransformerException {
        Transformer transformer = getTransformer( ResourceType.DAO );
        String path = dirName + "dao/";

        for (String tableName : getTableNames()) {
            transformer.setParameter( "table_name", tableName);
            transformer.transform( getSource(), output.addResult( file( path, tableName, "Dao" )));
        }
    }


    public void generateDaoImpls() throws IOException, TransformerException {
        Transformer transformer = getTransformer( ResourceType.DAO_IMPL );
        setDbType( transformer );

        String path = dirName + "dao/" + generator.getTarget().getIdentifier() + '/';

        for (String tableName : getTableNames()) {
            transformer.setParameter( "table_name", tableName);
            transformer.transform( getSource(), output.addResult( file( path, tableName, "DaoImpl" )));
        }
    }


    public void generateFactory() throws IOException, TransformerException {
        String path = dirName + "dao/DaoFactory.java";
        Transformer transformer = getTransformer( ResourceType.FACTORY );
        setDbType( transformer );
        transformer.transform( getSource(), output.addResult( path ));
    }


    public void generateFactoryImpl() throws IOException, TransformerException {
        String path = dirName + "dao/" + generator.getTarget().getIdentifier() + "/DaoFactoryImpl.java";
        Transformer transformer = getTransformer( ResourceType.FACTORY_IMPL );
        setDbType( transformer );
        transformer.transform( getSource(), output.addResult( path ));
    }


    public void generateSqlCreate() throws IOException, TransformerException {
        generateSql( ResourceType.SQL_CREATE, "sql/create-tables.sql" );
    }


    public void generateSqlDrop() throws IOException, TransformerException {
        generateSql( ResourceType.SQL_DROP, "sql/drop-tables.sql" );
    }


    public void generateAudaoJava() throws IOException {
        for (String resourceKey : generator.getJavaResourceKeys()) {
            copy( Generator.JAVA_RESOURCES + '/' + resourceKey, "dao/" + resourceKey );
        }
    }


    /**
     * Returns true if it caught at least error or warning.
     */
    public boolean hasExceptions() {
        return exceptions != null;
    }


    /**
     * Returns all caught exceptions.
     * @return the array or null
     */
    public ArrayList<TransformerException> getExceptions() {
        return exceptions;
    }


    /**
     * Returns all caught exception types.
     * @return the array or null
     */
    public ArrayList<GeneratorException.Type> getExceptionTypes() {
        return exceptionTypes;
    }


    ////////////////////////////////////////////////////////////////////////////
    // ErrorListener
    ////////////////////////////////////////////////////////////////////////////

    public void warning( TransformerException e ) throws TransformerException {
        if (log.isDebugEnabled()) {
            log.debug("warning(): " + e.getMessage());
        }

        storeException( e, GeneratorException.Type.WARNING );
    }


    public void error( TransformerException e ) throws TransformerException {
        if (log.isDebugEnabled()) {
            log.debug("error(): " + e.getMessage());
        }

        storeException( e, GeneratorException.Type.ERROR );
    }


    public void fatalError( TransformerException e ) throws TransformerException {
        if (log.isDebugEnabled()) {
            log.debug("fatalError(): " + e.getMessage());
        }

        storeException( e, GeneratorException.Type.FATAL_ERROR );

        isFatalError = true;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Private
    ////////////////////////////////////////////////////////////////////////////


    private void generateSql( ResourceType type, String name ) throws IOException, TransformerException {
        Transformer transformer = getTransformer( type );

        if (transformer == null) return;
        
        setDbType( transformer );
        transformer.setParameter( "db_user", "__USERNAME__");

        transformer.transform( getSource(), output.addResult( name ));
    }


    private void generateOne( ResourceType type, String name ) throws IOException, TransformerException {
        Transformer transformer = getTransformer( type );

        if (transformer == null) return;

        transformer.transform( getSource(), output.addResult( name ));
    }


    private String file( String path, String tableName, String suffix ) {
        String javaName = listProps.getProperty( tableName );
        int index = javaName.indexOf('|');

        if (index != -1) javaName = javaName.substring( 0, index );

        String ret = path + javaName + suffix + ".java";

        if (log.isDebugEnabled()) {
            log.debug("file(): " + ret);
        }

        return ret;
    }


    private boolean hasDto( String tableName) {
        String javaName = listProps.getProperty( tableName );

        return javaName.indexOf("|NO-DTO") == -1;
    }


    private Set<String> getTableNames() throws IOException, TransformerException {
        if (tableNames != null) return tableNames;

        Transformer transformer = getTransformer( resourceKey( "dao/gen-list.xsl" ));

        StringWriter sw = new StringWriter();
        StreamSource source = new StreamSource( new StringReader( getXmlPreprocessed()));
        StreamResult result = new StreamResult( sw );

        transformer.transform( source, result );

        listProps = new Properties();

        // NOTE: JDK 1.5 compatibility - we cannot use load(Reader):
        // listProps.load( new StringReader( sw.toString()));
        listProps.load( new ByteArrayInputStream( sw.toString().getBytes("UTF-8")));

        // NOTE: JDK 1.5 compatibility - we cannot use stringPropertyNames():
        // tableNames = listProps.stringPropertyNames();
        tableNames = new LinkedHashSet<String>();

        for (Enumeration en = listProps.propertyNames(); en.hasMoreElements();) {
            tableNames.add( (String) en.nextElement());
        }

        return tableNames;
    }


    private StreamSource getSource() throws TransformerException {
        return new StreamSource( new StringReader( getXmlPreprocessed()));
    }


    private String getXmlPreprocessed() throws TransformerException {
        if (xmlPreprocessed != null) return xmlPreprocessed;

        Transformer transformer = getTransformer( resourceKey( "preprocess.xsl" ));

        StringWriter sw = new StringWriter();
        StreamSource source = new StreamSource( xmlReader );
        StreamResult result = new StreamResult( sw );

        transformer.transform( source, result );

        xmlPreprocessed = sw.toString();

        if (log.isDebugEnabled()) {
            log.debug("getXmlPreprocessed():\n" + xmlPreprocessed);
        }

        if (generator.getIsDebugEnabled()) {
            OutputStream os = null;

            try {
                os = output.addStream("preprocessed.xml");
                os.write( xmlPreprocessed.getBytes( "UTF-8" ));
                os.flush();
            }
            catch (Exception e) {
                log.error("getXmlPreprocessed():", e);
            }
            finally {
                if (os != null) try { os.close(); } catch (Exception ee) {}
            }
        }

        return xmlPreprocessed;
    }


    private Transformer getTransformer( ResourceType type ) {
        String resourceKey =  generator.getResourceKey( type );

        return resourceKey != null ? getTransformer( resourceKey ) : null;
    }


    private Transformer getTransformer( String resourceKey ) {
        try {
            TemplatesCache tc = generator.getTemplatesCache();
            Templates templates = tc.getTemplates( resourceKey );

            if (templates == null) {
                InputStream is = getClass().getResourceAsStream( resourceKey );
                templates = tc.getTemplates( resourceKey, new StreamSource( is, resourceKey ));
            }

            Transformer ret = templates.newTransformer();
            ret.setURIResolver( generator.getResourceURIResolver()); // not auto copied from TrFactory
            ret.setErrorListener( this );
            ret.setParameter( "pkg_db", pkgName );

            return ret;
        }
        catch (TransformerConfigurationException e) {
            throw new RuntimeException( e );
        }
    }


    private String resourceKey( String name ) {
        return Generator.XSL_RESOURCES + '/' + name;
    }


    private void copy( String resourceKey, String path ) throws IOException {
        InputStream is = getClass().getResourceAsStream( resourceKey );

        if (is == null) throw new IOException("Cannot find resource: " + path);

        OutputStream os = output.addStream( path );

        if (buffer == null) buffer = new byte[ 2048 ];

        int n;

        while ((n = is.read( buffer, 0, buffer.length)) != -1) {
            os.write( buffer, 0, n );
        }

        os.flush();
    }


    private void setDbType( Transformer transformer ) {
        transformer.setParameter( "db_type", generator.getTarget().getIdentifier());
    }


    private void storeException( TransformerException e, GeneratorException.Type type )
            throws TransformerException {

        // Xalan sends the error messages twice:
        if (isFatalError) return;

        if (exceptions == null) {
            exceptions = new ArrayList<TransformerException>();
            exceptionTypes = new ArrayList<GeneratorException.Type>();
        }

        exceptions.add( e );
        exceptionTypes.add( type );
    }
}

