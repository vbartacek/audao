<?xml version="1.0" encoding="utf-8"?>
<!--
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
 *-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:db="http://www.spoledge.com/audao"
	>

	<xsl:import href="..@DIR_SEP@dto.xsl"/>
	<xsl:import href="common.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="table_name"/>

	<xsl:template name="imports-java">
		<xsl:text>
import javax.jdo.annotations.Extension;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

import com.spoledge.audao.db.dto.gae.GaeJdoAbstractDtoImpl;

import </xsl:text>
		<xsl:value-of select="$pkg_dto"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text>;
</xsl:text>
		<xsl:call-template name="enums-import"/>
	</xsl:template>


	<xsl:template name="package-name">
		<xsl:value-of select="$pkg_dto"/>
		<xsl:text>.gae</xsl:text>
	</xsl:template>


	<xsl:template name="imports-java-dates">
		<xsl:if test="db:columns/db:column[db:type = 'Date' or db:type = 'Timestamp']">
			<xsl:text>
import java.util.Date;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="extends">
		<xsl:text> extends </xsl:text>

		<xsl:choose>
			<xsl:when test="@extends">
				<xsl:call-template name="parent-class"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="abstract-dto"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="abstract-dto">
		<xsl:text>GaeJdoAbstractDtoImpl</xsl:text>
	</xsl:template>


	<xsl:template name="parent-class">
		<xsl:variable name="parent">
			<xsl:call-template name="parent-dto"/>
		</xsl:variable>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="//db:table[@name=$parent]"/>
		</xsl:call-template>
		<xsl:text>Impl</xsl:text>
	</xsl:template>


	<xsl:template name="annotation-class">
		<xsl:text>@PersistenceCapable(identityType = IdentityType.APPLICATION)
</xsl:text>
	</xsl:template>


	<xsl:template name="annotation-attribute-persistent">
		<xsl:if test="position()!=1">
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="db:pk">
				<xsl:if test="db:type != 'long' and db:type != 'String'">
					<xsl:message terminate="yes">
Unsupported GAE primary key type: <xsl:value-of select="db:type"/>
in table <xsl:value-of select="../../@name"/>.
					</xsl:message>
				</xsl:if>
				<xsl:text>    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
</xsl:text>
			</xsl:when>
			<xsl:when test="db:ref[@gae-parent='true']">
				<xsl:text>    @Persistent
    @Extension(vendorName="datanucleus", key="gae.parent-pk", value="true")
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    @Persistent
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="class-name">
		<xsl:value-of select="$dtoname"/>
		<xsl:text>Impl</xsl:text>
	</xsl:template>


	<xsl:template name="enums-def">
		<xsl:call-template name="enums-mapping"/>
	</xsl:template>


	<xsl:template name="attributes">
		<xsl:if test="$own-columns">
			<xsl:text>
    ////////////////////////////////////////////////////////////////////////////
    // Attributes
    ////////////////////////////////////////////////////////////////////////////

</xsl:text>
		</xsl:if>
		<xsl:if test="count(db:columns/db:column/db:ref[@gae-parent='true']) &gt; 1">
			<xsl:message terminate="yes">
				Key references to more than one entity are not supported by AUDAO/GAE.
				Table <xsl:value-of select="@name"/>.
			</xsl:message>
		</xsl:if>
		<xsl:for-each select="$own-columns">
			<xsl:call-template name="annotation-attribute-persistent"/>
			<xsl:text>    private </xsl:text>
			<xsl:choose>
				<xsl:when test="db:pk or db:ref[@gae-parent='true']">
					<xsl:text>Key</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="column-ObjectType-raw"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text> </xsl:text>
			<xsl:call-template name="column-name"/>
			<xsl:text>;
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="attributes-modified">
	</xsl:template>


	<xsl:template name="constants">
	</xsl:template>



	<xsl:template name="constructor-copy">
	</xsl:template>


	<xsl:template name="methods">
		<xsl:call-template name="getsetters"/>
		<xsl:call-template name="method-getdto"/>
		<xsl:call-template name="method-copyto"/>
		<xsl:call-template name="methods-protected"/>
	</xsl:template>


	<xsl:template name="method-getdto">
		<xsl:text>
    /**
     * Returns the DTO mirror.
     */
    public </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> _getDto() {
        </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> _dto = new </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text>();
        _copyTo( _dto );

        return _dto;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-copyto">
		<xsl:text>
    /**
     * Copies this DTOImpl into the DTO mirror.
     */
    public void _copyTo( </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> _dto ) {
</xsl:text>
		<xsl:if test="@extends">
			<xsl:text>        super._copyTo( _dto );

</xsl:text>
		</xsl:if>

		<xsl:for-each select="$own-columns">
			<xsl:text>        _dto.set</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>( get</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>()</xsl:text>
			<xsl:choose>

				<xsl:when test="db:pk or db:ref[@gae-parent='true']">
					<xsl:choose>
						<xsl:when test="db:type = 'long'">
							<xsl:text>.getId()</xsl:text>
						</xsl:when>
						<xsl:when test="db:type = 'String'">
							<xsl:text>.getName()</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:when>

				<xsl:when test="db:enum">
					<xsl:text> != null ? </xsl:text>
					<xsl:call-template name="enum-get-by-id">
						<xsl:with-param name="id">
							<xsl:text>get</xsl:text>
							<xsl:call-template name="java-Name"/>
							<xsl:text>()</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> : null</xsl:text>
				</xsl:when>

			</xsl:choose>

			<xsl:text>);
</xsl:text>
		</xsl:for-each>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-append">
	</xsl:template>


	<xsl:template name="setter-date">
		<xsl:if test="db:type = 'Date' or db:type = 'Timestamp'">
			<xsl:text>
    public void set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( java.sql.</xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text> _val ) {
        set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( _val != null ? new Date( _val.getTime()) : null );
    }
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="is-modified">
	</xsl:template>


	<xsl:template name="dto-column-type">
		<xsl:call-template name="column-ObjectType-raw"/>
	</xsl:template>


</xsl:stylesheet>
