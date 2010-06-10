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


/**
 * This is XSL resource type enumaration.
 */
public enum ResourceType {
    DTO( "dao", "dto.xsl", false ),
    DTO_IMPL( "dao", "dto-impl.xsl", true ),
    DTO_GWT_SERIALIZER( "dao", "dto-gwt-serializer.xsl", false ),
    DAO( "dao", "dao.xsl", false ),
    DAO_IMPL( "dao", "dao-impl.xsl", false ),
    FACTORY( "dao", "factory.xsl", false ),
    FACTORY_IMPL( "dao", "factory-impl.xsl", false ),
    SQL_CREATE( "sql", "create-tables.xsl", true ),
    SQL_DROP( "sql", "drop-tables.xsl", true ),
    AUDAO_JAVA( "java", "sources.properties", false );

    private String dir;
    private String name;
    private boolean isOptional;

    ResourceType( String dir, String name, boolean isOptional ) {
        this.dir = dir;
        this.name = name;
        this.isOptional = isOptional;
    }


    /**
     * Returns the directory name - e.g. "dao".
     */
    public String getDir() {
        return dir;
    }


    /**
     * Returns the XSL name - e.g. "dto.xsl".
     */
    public String getName() {
        return name;
    }


    /**
     * Returns true if this resource is optional,
     * e.g. "true" for DTO_IMPL.
     */
    public boolean getIsOptional() {
        return isOptional;
    }
}
