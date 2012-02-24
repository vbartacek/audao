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

	<xsl:template name="db-header">
		<xsl:text>--
-- Generated by AuDAO 2009 tool, a product of Spolecne s.r.o.
-- For more information please visit http://www.spoledge.com
--

</xsl:text>
	</xsl:template>


	<xsl:template name="db-foreign-keys">
		<xsl:text>-- ==================== F O R E I G N   K E Y S  ====================
</xsl:text>
		<xsl:call-template name="db-foreign-keys-impl"/>
	</xsl:template>


	<xsl:template name="db-foreign-key">
	</xsl:template>


	<xsl:template name="db-foreign-keys-impl">
		<xsl:param name="cols" select="//db:table/db:columns/db:column[db:ref[not(@fk = 'false')]]"/>
		<xsl:param name="pos" select="1"/>
		<xsl:param name="all" select="'|'"/>

		<xsl:variable name="ctx" select="$cols[$pos]"/>
		<xsl:if test="$ctx">
			<xsl:variable name="tname">
				<xsl:choose>
					<xsl:when test="$ctx/db:ref/@table">
						<xsl:value-of select="$ctx/db:ref/@table"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$ctx/../../@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="fkname">
				<xsl:call-template name="db-foreign-key-name">
					<xsl:with-param name="name">
						<xsl:text>fk_</xsl:text>
						<xsl:value-of select="$ctx/../../@name"/>
						<xsl:text>_</xsl:text>
						<xsl:value-of select="$ctx/@name"/>
					</xsl:with-param>
					<xsl:with-param name="all" select="$all"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:if test="//db:table[@name=$tname and not(@abstract='true')]">
				<xsl:call-template name="db-foreign-key">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="tname" select="$tname"/>
					<xsl:with-param name="fk" select="$fkname"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:call-template name="db-foreign-keys-impl">
				<xsl:with-param name="cols" select="$cols"/>
				<xsl:with-param name="pos" select="$pos + 1"/>
				<xsl:with-param name="all" select="concat($all, concat( $fkname, '|'))"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>



	<xsl:template name="db-foreign-key-name">
		<xsl:param name="name"/>
		<xsl:param name="all"/>
		<xsl:param name="pos" select="0"/>

		<xsl:choose>
			<xsl:when test="string-length($name) &gt; 30"> <!-- max length in Oracle -->
				<xsl:call-template name="db-foreign-key-name">
					<xsl:with-param name="name" select="substring($name,1,30)"/>
					<xsl:with-param name="all" select="$all"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$pos != 0">
				<xsl:variable name="ret" select="concat(substring($name,1,30 - string-length(string($pos))),$pos)"/>
				<xsl:choose>
					<xsl:when test="contains($all, concat('|',concat($ret,'|')))">
						<xsl:call-template name="db-foreign-key-name">
							<xsl:with-param name="name" select="$name"/>
							<xsl:with-param name="all" select="$all"/>
							<xsl:with-param name="pos" select="$pos + 1"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$ret"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($all, concat('|',concat($name,'|')))">
				<xsl:call-template name="db-foreign-key-name">
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="all" select="$all"/>
					<xsl:with-param name="pos" select="1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
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


</xsl:stylesheet>
