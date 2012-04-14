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

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>


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
			<xsl:otherwise>
				<xsl:call-template name="column-val-otherwise">
					<xsl:with-param name="ctx" select="$ctx"/>
					<xsl:with-param name="colname" select="$colname"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>

