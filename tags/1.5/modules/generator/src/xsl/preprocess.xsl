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
	xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="exsl"
>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
	/>

	<!--
	<xsl:namespace-alias
		stylesheet-prefix="db"
		result-prefix="#default"
	/>
	-->


	<xsl:template match="db:table[not(@extends)]">
		<xsl:copy>
			<xsl:call-template name="generic-attribute"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="db:table[@extends]">
		<xsl:variable name="extname" select="@extends"/>
		<xsl:if test="not(/db:database/db:tables/db:table[@name=$extname])">
			<xsl:message terminate="yes">
				The parent table name "<xsl:value-of select="$extname"/>" does not exist.
				In the definition of the table "<xsl:value-of select="@name"/>".
			</xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:attribute name="use-dto">
				<xsl:call-template name="use-dto"/>
			</xsl:attribute>
			<xsl:call-template name="generic-attribute"/>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
			<xsl:if test="not(db:columns)">
				<xsl:call-template name="columns"/>
			</xsl:if>
			<xsl:if test="not(db:indexes) and not(@abstract)">
				<xsl:element name="indexes" namespace="http://www.spoledge.com/audao">
					<xsl:call-template name="indexes"/>
				</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="db:columns[../@extends]">
		<xsl:call-template name="columns">
			<xsl:with-param name="tablename" select="../@name"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="db:indexes">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name="indexes">
				<xsl:with-param name="table" select=".."/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="db:column[db:ref]">
		<xsl:variable name="deftablecolumn">
			<xsl:call-template name="ref-deftable"/>
		</xsl:variable>
		<xsl:variable name="rtname" select="substring-before($deftablecolumn, '|')"/>
		<xsl:variable name="rcname" select="substring-after($deftablecolumn, '|')"/>
		<xsl:variable name="rcctx" select="//db:table[@name=$rtname]/db:columns/db:column[@name=$rcname]"/>
		<xsl:copy>
			<xsl:attribute name="orig-table">
				<xsl:value-of select="$rtname"/>
			</xsl:attribute>
			<xsl:attribute name="orig-column">
				<xsl:value-of select="$rcname"/>
			</xsl:attribute>

			<xsl:apply-templates select="@*"/>

			<xsl:element name="type" namespace="http://www.spoledge.com/audao">
				<xsl:attribute name="orig-table">
					<xsl:value-of select="$rtname"/>
				</xsl:attribute>
				<xsl:attribute name="orig-column">
					<xsl:value-of select="$rcname"/>
				</xsl:attribute>
				<xsl:apply-templates select="$rcctx/db:type/@*"/>
				<xsl:value-of select="$rcctx/db:type"/>
			</xsl:element>

			<xsl:element name="ref" namespace="http://www.spoledge.com/audao">
				<xsl:attribute name="table">
					<xsl:value-of select="$rtname"/>
				</xsl:attribute>
				<xsl:attribute name="column">
					<xsl:value-of select="$rcname"/>
				</xsl:attribute>
				<xsl:if test="db:ref/@gae-parent">
					<xsl:attribute name="gae-parent">
						<xsl:value-of select="db:ref/@gae-parent"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="db:ref/@fk">
					<xsl:attribute name="fk">
						<xsl:value-of select="db:ref/@fk"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="../../../db:view">
					<xsl:if test="db:ref/@column and db:ref/@column != $rcname">
						<xsl:attribute name="view-column">
							<xsl:value-of select="db:ref/@column"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="db:ref/@alias">
							<xsl:apply-templates select="db:ref/@alias"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="tname" select="db:ref/@table"/>
							<xsl:attribute name="alias">
								<xsl:value-of select="../../db:tables/db:ref[@table=$tname]/@alias"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:element>

			<xsl:if test="$rcctx/db:enum">
				<xsl:element name="enum" namespace="http://www.spoledge.com/audao">
					<xsl:attribute name="orig-table">
						<xsl:value-of select="$rtname"/>
					</xsl:attribute>
					<xsl:attribute name="orig-column">
						<xsl:value-of select="$rcname"/>
					</xsl:attribute>
					<xsl:apply-templates select="$rcctx/db:enum/@*"/>
					<xsl:apply-templates select="$rcctx/db:enum/*"/>
				</xsl:element>
			</xsl:if>

			<xsl:apply-templates select="*[local-name() != 'ref']"/>

			<xsl:if test="../../../db:view">
				<xsl:if test="not(db:null) and ($rcctx/db:not-null or $rcctx/db:pk)">
					<xsl:element name="not-null" namespace="http://www.spoledge.com/audao"/>
				</xsl:if>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="db:type[not(@max-length) and .='String']">
		<xsl:message terminate="yes">
			The String column '<xsl:value-of select="../@name"/>' in table '<xsl:value-of select="../../../@name"/>'
			has missing 'max-length' attribute.
		</xsl:message>
	</xsl:template>

	<xsl:template match="db:type[not(@max-length) and .='byte[]']">
		<xsl:message terminate="yes">
			The Blob column '<xsl:value-of select="../@name"/>' in table '<xsl:value-of select="../../../@name"/>'
			has missing 'max-length' attribute.
		</xsl:message>
	</xsl:template>

	<xsl:template match="db:type[(.='Serializable' or .='List') and contains(@class,':') and not(starts-with(@class,'table:')) and not(starts-with(@class,'gae:'))]">
		<xsl:message terminate="yes">
			The <xsl:value-of select="db:type"/> column '<xsl:value-of select="../@name"/>' in table '<xsl:value-of select="../../../@name"/>'
			has unknown qualificator '<xsl:value-of select="substring-before(@class,':')"/>:' in the 'class' attribute.
		</xsl:message>
	</xsl:template>

	<xsl:template match="@*|node()" priority="-10">
		<xsl:if test="local-name() != 'prefix-index'">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>


	<xsl:template name="use-dto">
		<xsl:param name="tablename" select="@name"/>
		<xsl:variable name="table" select="/db:database/db:tables/db:table[@name=$tablename]"/>
		<xsl:choose>
			<xsl:when test="not($table/@extends) or $table/@force-dto='true'">
				<xsl:value-of select="$tablename"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="columns">
					<xsl:call-template name="columns">
						<xsl:with-param name="tablename" select="$tablename"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="exsl:node-set($columns)/columns/column[not(@defined-by)]">
						<xsl:value-of select="$tablename"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="use-dto">
							<xsl:with-param name="tablename" select="$table/@extends"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="indexes">
		<xsl:param name="table" select="."/>
		<xsl:param name="prefix" select="$table/@prefix-index"/>
		<xsl:param name="inherited" select="0"/>

		<xsl:if test="$table/@extends">
			<xsl:variable name="name" select="$table/@extends"/>
			<xsl:call-template name="indexes">
				<xsl:with-param name="table" select="//db:table[@name=$name]"/>
				<xsl:with-param name="prefix" select="$prefix"/>
				<xsl:with-param name="inherited" select="1"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:for-each select="$table/db:indexes/db:index">
			<xsl:copy>
				<xsl:attribute name="name">
					<xsl:value-of select="$prefix"/>
					<xsl:value-of select="@name"/>
				</xsl:attribute>
				<xsl:if test="$inherited=1">
					<xsl:attribute name="inherited-from">
						<xsl:value-of select="$table/@name"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="node()"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="columns">
		<xsl:param name="tablename" select="@name"/>
		<xsl:param name="deep"/>
		<xsl:variable name="table" select="/db:database/db:tables/db:table[@name=$tablename]"/>

		<xsl:variable name="supercolumns">
			<xsl:choose>
				<xsl:when test="$table/@extends">
					<xsl:call-template name="columns">
						<xsl:with-param name="tablename" select="$table/@extends"/>
						<xsl:with-param name="deep" select="'true'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<columns/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="columns" namespace="http://www.spoledge.com/audao">
			<xsl:apply-templates select="$table/db:columns/@*"/>
			<xsl:for-each select="exsl:node-set($supercolumns)/columns/*">
				<xsl:variable name="cname" select="@name"/>
				<xsl:variable name="col" select="$table/db:columns/db:column[@name=$cname]"/>
				<xsl:copy>
					<xsl:choose>
						<xsl:when test="not($deep) and $col">
							<xsl:attribute name="overriden">true</xsl:attribute>
							<xsl:copy-of select="@defined-by"/>
							<xsl:copy-of select="$col/@*|$col/*"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="@*|node()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:copy>
			</xsl:for-each>

			<xsl:for-each select="$table/db:columns/db:column">
				<xsl:variable name="cname" select="@name"/>
				<xsl:if test="not(exsl:node-set($supercolumns)/columns/db:column[@name=$cname])">
					<xsl:copy>
						<xsl:if test="$deep">
							<xsl:attribute name="defined-by">
								<xsl:value-of select="$table/@name"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:copy-of select="@*|node()"/>
					</xsl:copy>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>

	</xsl:template>


	<xsl:template name="generic-attribute">
		<xsl:variable name="hasgenpar">
			<xsl:call-template name="has-generic-parent"/>
		</xsl:variable>
		<xsl:if test="@abstract and not(@force-dto) and $hasgenpar">
			<xsl:attribute name="generic">true</xsl:attribute>
		</xsl:if>
	</xsl:template>


	<xsl:template name="has-generic-parent">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="not($ctx/@extends)">true</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pname" select="$ctx/@extends"/>
				<xsl:variable name="parent" select="//db:table[@name=$pname]"/>
				<xsl:choose>
					<xsl:when test="not($parent/@abstract)"/>
					<xsl:when test="$parent/@force-dto"/>
					<xsl:otherwise>
						<xsl:call-template name="has-generic-parent">
							<xsl:with-param name="ctx" select="$parent"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="ref-deftable">
		<xsl:param name="ctx" select="."/>
		<xsl:variable name="rtname">
			<xsl:choose>
				<xsl:when test="$ctx/db:ref/@alias">
					<xsl:variable name="al" select="$ctx/db:ref/@alias"/>
					<xsl:variable name="ret" select="$ctx/../../db:tables/db:ref[@alias=$al]/@table"/>
					<xsl:if test="not($ret)">
						<xsl:message terminate="yes">
							Invalid alias '<xsl:value-of select="$al"/>' in view '<xsl:value-of select="$ctx/../../@name"/>'
							column '<xsl:value-of select="$ctx/@name"/>'.
						</xsl:message>
					</xsl:if>
					<xsl:value-of select="$ret"/>
				</xsl:when>
				<xsl:when test="$ctx/db:ref/@table">
					<xsl:value-of select="$ctx/db:ref/@table"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ctx/../../@name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="rtctx" select="//db:table[@name=$rtname]|//db:view[@name=$rtname]"/>
		<xsl:if test="not($rtctx)">
			<xsl:message terminate="yes">
				Invalid reference in table '<xsl:value-of select="$ctx/../../@name"/>' column '<xsl:value-of select="$ctx/@name"/>'
				to non-existing table '<xsl:value-of select="$rtname"/>'.
			</xsl:message>
		</xsl:if>
		<xsl:variable name="rcname">
			<xsl:choose>
				<xsl:when test="$ctx/db:ref/@column">
					<xsl:value-of select="$ctx/db:ref/@column"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ctx/@name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="rcctx" select="$rtctx/db:columns/db:column[@name=$rcname]"/>
		<xsl:if test="not($rcctx)">
			<xsl:message terminate="yes">
				Invalid reference in table '<xsl:value-of select="$ctx/../../@name"/>' column '<xsl:value-of select="$ctx/@name"/>'
				to non-existing column '<xsl:value-of select="$rcname"/>' of existing table '<xsl:value-of select="$rtname"/>'.
			</xsl:message>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$rcctx/db:ref">
				<xsl:call-template name="ref-deftable">
					<xsl:with-param name="ctx" select="$rcctx"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$rtname"/>
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$rcname"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
