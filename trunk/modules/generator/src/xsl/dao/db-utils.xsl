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
	xmlns:set="http://exslt.org/sets"
	extension-element-prefixes="set"
>

	<xsl:import href="..@DIR_SEP@string-utils.xsl"/>
	<xsl:import href="..@DIR_SEP@messages.xsl"/>

	<xsl:variable name="pkg_dao" select="concat($pkg_db,'.dao')"/>
	<xsl:variable name="pkg_dto" select="concat($pkg_db,'.dto')"/>
	<xsl:variable name="db_conf" select="/db:database/db:config"/>

	<xsl:template name="file-header">
		<xsl:text>/*
 * This file was generated - do not edit it directly !!
 * Generated by AuDAO tool, a product of Spolecne s.r.o.
 * For more information please visit http://www.spoledge.com
 */
</xsl:text>
	</xsl:template>

	<xsl:template name="java-Name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-name">
			<xsl:with-param name="ctx" select="$ctx"/>
			<xsl:with-param name="capital" select="1"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="java-name">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="capital" select="0"/>
		<xsl:choose>
			<xsl:when test="$ctx/@java and $capital=1">
				<xsl:call-template name="uc-first">
					<xsl:with-param name="name" select="$ctx/@java"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$ctx/@java">
				<xsl:value-of select="$ctx/@java"/>
			</xsl:when>
			<xsl:when test="local-name($ctx)='table' or local-name($ctx)='view'">
				<xsl:call-template name="camel-name-trim-es">
					<xsl:with-param name="name" select="$ctx/@name"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="camel-name">
					<xsl:with-param name="name" select="$ctx/@name"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- This is used only for DAO* classes, not DTO ones -->
	<xsl:template name="extends-java-Name">
		<xsl:variable name="extname" select="@extends"/>
		<xsl:variable name="parent" select="../db:table[@name=$extname]"/>
		<xsl:if test="not($parent)">
			<xsl:message terminate="yes">
				The parent table name "<xsl:value-of select="$extname"/>" does not exist.
				In the definition of the table "<xsl:value-of select="@name"/>>".
			</xsl:message>
		</xsl:if>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$parent"/>
		</xsl:call-template>
	</xsl:template>


	<!-- DTO classes are not generated for all tables -->
	<xsl:template name="parent-dto">
		<xsl:param name="ctx" select="."/>
		<xsl:variable name="parent" select="//db:table[@name=$ctx/@extends]"/>
		<xsl:choose>
			<xsl:when test="not($parent/@use-dto)">
				<xsl:value-of select="$parent/@name"/>
			</xsl:when>
			<xsl:when test="$parent/@use-dto = $parent/@name">
				<xsl:value-of select="$parent/@name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="parent-dto">
					<xsl:with-param name="ctx" select="$parent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="schema-prefix">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
		<xsl:value-of select="$ctx/@name"/>
	</xsl:template>


	<xsl:template name="schema-prefix">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="$ctx/@schema">
				<xsl:value-of select="$ctx/@schema"/>
				<xsl:text>.</xsl:text>
			</xsl:when>
			<xsl:when test="/db:database/@schema">
				<xsl:value-of select="/db:database/@schema"/>
				<xsl:text>.</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="is-pk-auto">
		<xsl:param name="ctx" select="."/>
		<xsl:value-of select="count($ctx/db:columns/db:column[db:auto and db:pk])"/>
	</xsl:template>

	<xsl:template name="pk-type">
		<xsl:param name="ctx" select="."/>
		<xsl:value-of select="$ctx/db:columns/db:column[db:pk][1]/db:type"/>
	</xsl:template>

	<xsl:template name="pk-type-ucfirst">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="uc-first">
			<xsl:with-param name="name" select="$ctx/db:columns/db:column[db:pk]/db:type"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="pk-name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="camel-name">
			<xsl:with-param name="name" select="$ctx/db:columns/db:column[db:pk][1]/@name"/>
			<xsl:with-param name="capital" select="0"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="pk-Name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$ctx/db:columns/db:column[db:pk][1]"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="column-val">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="capital" select="0"/>
		<xsl:param name="colname">
			<xsl:call-template name="column-name">
				<xsl:with-param name="ctx" select="$ctx"/>
				<xsl:with-param name="capital" select="$capital"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="notnull"/>
		<xsl:param name="set"/>
		<xsl:choose>
			<xsl:when test="$ctx/db:enum and ($notnull or $ctx/db:not-null or $ctx/db:pk)">
				<xsl:value-of select="$colname"/>
				<xsl:call-template name="column-val-enum-suffix">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$ctx/db:enum">
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:text> != null ? </xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:call-template name="column-val-enum-suffix">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
				<xsl:text> : null)</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx/db:type='boolean' and ($notnull or $ctx/db:not-null or $ctx/db:pk)">
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:text> ? ((byte)1) : ((byte)0))</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx/db:type='boolean'">
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:text> == null ? null : (</xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:text> ? ((byte)1) : ((byte)0)))</xsl:text>
			</xsl:when>
			<xsl:when test="$set=1 and ($ctx/db:type='Serializable' or $ctx/db:type='byte[]')">
				<xsl:call-template name="check-Length">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="getter" select="$colname"/>
					<xsl:with-param name="isexpr" select="1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$ctx/db:type='Serializable'">
				<xsl:text>serialize( </xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:text> )</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="column-val-otherwise">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="colname" select="$colname"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="column-val-otherwise">
		<xsl:param name="colname"/>
		<xsl:value-of select="$colname"/>
	</xsl:template>


	<xsl:template name="column-val-enum-suffix">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="$ctx/db:enum/db:value[@id or @db]">
				<xsl:text>.getId()</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx/db:type = 'String'">
				<xsl:text>.name()</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>.ordinal() + 1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="column-name-ucfirst">
		<xsl:call-template name="uc-first">
			<xsl:with-param name="name">
				<xsl:call-template name="column-name"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="column-name">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="capital" select="0"/>
		<xsl:call-template name="java-name">
			<xsl:with-param name="ctx" select="$ctx"/>
			<xsl:with-param name="capital" select="$capital"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="column-Name-ucfirst">
		<xsl:call-template name="uc-first">
			<xsl:with-param name="name">
				<xsl:call-template name="column-Name"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="column-Name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="column-Type">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="uc-first">
			<xsl:with-param name="name" select="$ctx/db:type"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="column-ObjectType">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="islist" select="1"/>
		<xsl:choose>
			<xsl:when test="$ctx/db:enum">
				<xsl:call-template name="column-EnumType">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="column-ObjectType-raw">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="islist" select="$islist"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="column-ObjectType-raw">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="islist" select="1"/>
		<xsl:call-template name="objectType-raw">
			<xsl:with-param name="ctx" select="$ctx/db:type"/>
			<xsl:with-param name="pctx" select="$ctx"/>
			<xsl:with-param name="islist" select="$islist"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="objectType-raw">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="cls" select="$ctx/@class"/>
		<xsl:param name="islist" select="1"/>
		<xsl:choose>
			<xsl:when test="$ctx = 'boolean'">
				<xsl:text>Boolean</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'short'">
				<xsl:text>Short</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'int'">
				<xsl:text>Integer</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'long'">
				<xsl:text>Long</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'double'">
				<xsl:text>Double</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'Serializable' and $cls='java.util.List' and $islist=1">
				<xsl:text>java.util.List</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'Serializable' and $cls='java.util.List'">
				<xsl:text>Object</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx = 'Serializable'">
				<xsl:call-template name="objectType-Class">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="cls" select="$cls"/>
					<xsl:with-param name="deftype" select="'Serializable'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$ctx = 'List'">
				<xsl:call-template name="objectType-List">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="cls" select="$cls"/>
					<xsl:with-param name="islist" select="$islist"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$ctx"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="objectType-List">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="cls" select="$ctx/@class"/>
		<xsl:param name="islist" select="1"/>
		<xsl:choose>
			<xsl:when test="$islist=1 and not($cls)">
				<xsl:text>List</xsl:text>
			</xsl:when>
			<xsl:when test="$islist=1">
				<xsl:text>List&lt;</xsl:text>
				<xsl:call-template name="objectType-Class">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="cls" select="$cls"/>
				</xsl:call-template>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="objectType-Class">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="cls" select="$cls"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="objectType-Class">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="cls" select="$ctx/@class"/>
		<xsl:param name="deftype" select="'Object'"/>
		<xsl:choose>
			<xsl:when test="not($cls)">
				<xsl:value-of select="$deftype"/>
			</xsl:when>
			<xsl:when test="starts-with($cls,'table:')">
				<xsl:call-template name="objectType-ClassRef">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="cls" select="$cls"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($cls,':')">
				<xsl:value-of select="substring-after($cls,':')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$cls"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="objectType-ClassRef">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="cls" select="$ctx/@class"/>
		<xsl:variable name="tname" select="substring-after($cls, 'table:')"/>
		<xsl:variable name="table" select="/db:database/db:tables/db:table[@name=$tname]"/>
		<xsl:if test="not($table)">
			<xsl:call-template name="error">
				<xsl:with-param name="errcode" select="'REFERENCE_NOT_FOUND'"/>
				<xsl:with-param name="table" select="$ctx/../../.."/>
				<xsl:with-param name="col" select="$ctx/.."/>
				<xsl:with-param name="detail" select="$tname"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$table"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="column-EnumType-short">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="column-Name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="column-EnumType-dto">
		<xsl:choose>
			<xsl:when test="db:enum[@orig-table]">
				<xsl:variable name="tname" select="db:enum/@orig-table"/>
				<xsl:variable name="tctx" select="//db:table[@name=$tname]"/>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="$tctx"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="../.."/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="column-EnumType">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="$ctx/db:enum[@orig-table]">
				<xsl:variable name="tname" select="$ctx/db:enum/@orig-table"/>
				<xsl:variable name="cname" select="$ctx/db:enum/@orig-column"/>
				<xsl:variable name="tctx" select="//db:table[@name=$tname]"/>
				<xsl:variable name="cctx" select="$tctx/db:columns/db:column[@name=$cname]"/>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="$tctx"/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:call-template name="column-EnumType-short">
					<xsl:with-param name="ctx" select="$cctx"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="$ctx/../.."/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:call-template name="column-EnumType-short">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="param-name">
		<xsl:variable name="capital">
			<xsl:choose>
				<xsl:when test="local-name(../..)='set'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$capital=1">
			<xsl:text>new</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@java">
				<xsl:call-template name="java-name">
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="local-name()='column'">
				<xsl:variable name="name" select="@name"/>
				<xsl:call-template name="column-name">
					<xsl:with-param name="ctx" select="../../../../../db:columns/db:column[@name=$name]"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="camel-name">
					<xsl:with-param name="name" select="@name"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="param-val">
		<xsl:variable name="paramname">
			<xsl:call-template name="param-name"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="local-name()='column'">
				<xsl:variable name="name" select="@name"/>
				<xsl:call-template name="column-val">
					<xsl:with-param name="ctx" select="../../../../../db:columns/db:column[@name=$name]"/>
					<xsl:with-param name="colname" select="$paramname"/>
					<xsl:with-param name="set">
						<xsl:choose>
							<xsl:when test="local-name(../..)='set'">1</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$paramname"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="param-ObjectType">
		<xsl:param name="ctx" select="."/>
		<xsl:variable name="islist" select="count($ctx[@list='true'])"/>
		<xsl:choose>
			<xsl:when test="local-name($ctx)='column'">
				<xsl:variable name="name" select="$ctx/@name"/>
				<xsl:variable name="cctx" select="$ctx/../../../../../db:columns/db:column[@name=$name]"/>
				<xsl:if test="not($cctx)">
					<xsl:message terminate="yes">
						The referenced column name '<xsl:value-of select="$name"/>' does not exist.
						In table '<xsl:value-of select="$ctx/../../../../../@name"/>' method '<xsl:value-of select="local-name($ctx/../../..)"/>' with name '<xsl:value-of select="$ctx/../../../@name"/>'.
					</xsl:message>
				</xsl:if>
				<xsl:variable name="isanonlist" select="count($cctx[db:type='List' and not(db:type/@class) or db:type='Serializable' and db:type/@class='java.util.List'])"/>
				<xsl:if test="$islist=1 and $isanonlist!=1">
					<xsl:text>List&lt;</xsl:text>
				</xsl:if>
				<xsl:call-template name="column-ObjectType">
					<xsl:with-param name="ctx" select="$cctx"/>
					<xsl:with-param name="islist" select="$isanonlist*$islist"/>
				</xsl:call-template>
				<xsl:if test="$islist=1 and $isanonlist!=1">
					<xsl:text>&gt;</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="isanonlist" select="count($ctx[@type='List' and not(@class) or @type='Serializable' and @class='java.util.List'])"/>
				<xsl:if test="$islist=1 and $isanonlist!=1">
					<xsl:text>List&lt;</xsl:text>
				</xsl:if>
				<xsl:call-template name="objectType-raw">
					<xsl:with-param name="ctx" select="$ctx/@type"/>
					<xsl:with-param name="cls" select="$ctx/@class"/>
					<xsl:with-param name="islist" select="$isanonlist*$islist"/>
				</xsl:call-template>
				<xsl:if test="$islist=1 and $isanonlist!=1">
					<xsl:text>&gt;</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="index-column-type">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="islist"/>
		<xsl:choose>
			<xsl:when test="$ctx/db:enum">
				<xsl:call-template name="column-EnumType">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$ctx/db:type='Serializable' and $ctx/db:type/@class='java.util.List' and $islist!=1">
				<xsl:text>Object</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx/db:type='Serializable'">
				<xsl:call-template name="objectType-Class">
					<xsl:with-param name="ctx" select="$ctx/db:type"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$ctx/db:type='List'">
				<xsl:call-template name="objectType-List">
					<xsl:with-param name="ctx" select="$ctx/db:type"/>
					<xsl:with-param name="islist" select="$islist"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$islist!=1 and ($ctx/db:not-null or $ctx/db:pk)">
				<xsl:value-of select="$ctx/db:type"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="column-ObjectType">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="islist" select="0"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="dbutil-imports-embed">
		<xsl:variable name="cls" select="set:distinct(db:columns/db:column[(db:type = 'Serializable' or db:type='List') and starts-with(db:type/@class, 'table:')]/db:type/@class)"/>
		<xsl:for-each select="$cls">
			<xsl:text>import </xsl:text>
			<xsl:value-of select="$pkg_dto"/>
			<xsl:text>.</xsl:text>
			<xsl:call-template name="objectType-ClassRef">
				<xsl:with-param name="ctx" select=".."/>
			</xsl:call-template>
			<xsl:text>;
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="dbutil-imports-gae-types">
		<xsl:variable name="cls" select="set:distinct(db:columns/db:column[(db:type = 'Serializable' or db:type='List') and starts-with(db:type/@class, 'gae:')]/db:type/@class)"/>
		<xsl:if test="$cls">
			<xsl:for-each select="$cls">
				<xsl:text>import com.google.appengine.api.</xsl:text>
				<xsl:choose>
					<xsl:when test=".='gae:User'">
						<xsl:text>users.User;
</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>datastore.</xsl:text>
						<xsl:value-of select="substring-after(.,'gae:')"/>
						<xsl:text>;
</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>


	<xsl:template name="key-name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="key-Name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
	</xsl:template>

	<!-- this is implemented in dao-impl-->
	<xsl:template name="check-Length">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="getter"/>
		<xsl:param name="isexpr"/>
	</xsl:template>


	<xsl:template name="comment-class">
		<xsl:param name="def"/>
		<xsl:text>
/**
 * </xsl:text>
		<xsl:call-template name="comment-body">
			<xsl:with-param name="def" select="$def"/>
		</xsl:call-template>
		<xsl:text> *
 * @author generated
 */
</xsl:text>
	</xsl:template>


	<xsl:template name="comment-method">
		<xsl:call-template name="comment-method-start"/>
		<xsl:call-template name="comment-body">
			<xsl:with-param name="indent" select="'    '"/>
		</xsl:call-template>
		<xsl:call-template name="comment-method-end"/>
	</xsl:template>


	<xsl:template name="comment-method-start">
		<xsl:text>
    /**
     * </xsl:text>
	</xsl:template>

	<xsl:template name="comment-method-end">
		<xsl:text>     */
</xsl:text>
	</xsl:template>


	<xsl:template name="comment-body">
		<xsl:param name="indent"/>
		<xsl:param name="def"/>
		<xsl:choose>
			<xsl:when test="db:comment">
				<xsl:for-each select="db:comment">
					<xsl:if test="position()!=1">
						<xsl:value-of select="$indent"/>
						<xsl:text> * </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
				<xsl:text>
</xsl:text>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$def"/>
				<xsl:text>
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-conf-attr">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="type"/>
		<xsl:param name="attr"/>
		<xsl:param name="def"/>
		<xsl:variable name="p" select="$ctx/db:config/*[local-name()=$type]/@*[local-name()=$attr]"/>
		<xsl:choose>
			<xsl:when test="$p">
				<xsl:value-of select="$p"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pp" select="$db_conf/*[local-name()=$type]/@*[local-name()=$attr]"/>
				<xsl:choose>
					<xsl:when test="$pp">
						<xsl:value-of select="$pp"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$def"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-conf-elem">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="type"/>
		<xsl:param name="elem"/>
		<xsl:param name="def"/>
		<xsl:variable name="p" select="$ctx/db:config/*[local-name()=$type]/*[local-name()=$elem]"/>
		<xsl:choose>
			<xsl:when test="$p">
				<xsl:value-of select="$p"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pp" select="$db_conf/*[local-name()=$type]/*[local-name()=$elem]"/>
				<xsl:choose>
					<xsl:when test="$pp">
						<xsl:value-of select="$pp"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$def"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-conf-node">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="type"/>
		<xsl:param name="elem"/>
		<xsl:param name="def"/>
		<xsl:variable name="p" select="$ctx/db:config/*[local-name()=$type]/*[local-name()=$elem]"/>
		<xsl:choose>
			<xsl:when test="$p">
				<xsl:call-template name="copy">
					<xsl:with-param name="ctx" select="$p"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pp" select="$db_conf/*[local-name()=$type]/*[local-name()=$elem]"/>
				<xsl:choose>
					<xsl:when test="$pp">
						<xsl:call-template name="copy">
							<xsl:with-param name="ctx" select="$pp"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$def">
						<xsl:call-template name="copy">
							<xsl:with-param name="ctx" select="$def"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="copy">
		<xsl:param name="ctx" select="."/>
		<xsl:for-each select="$ctx">
			<xsl:copy>
				<xsl:for-each select="$ctx/@*">
					<xsl:copy/>
					<xsl:for-each select="$ctx/*">
						<xsl:call-template name="copy"/>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
