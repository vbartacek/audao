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
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:frg="http://www.spoledge.com/audao/doc/fragments"
>

	<xsl:import href="htmlfrag.xsl"/>

	<xsl:output
		method="html"
		indent="yes"
		encoding="utf-8"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
	/>


	<xsl:param name="version"/>
	<xsl:param name="skeleton_path"/>
	<xsl:param name="isindex"/>
	<xsl:param name="release_notes_short"/>
	<xsl:param name="news_short"/>

	<xsl:variable name="fragment" select="/"/>


	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="html:html">
				<xsl:apply-templates select="html:html"/>
			</xsl:when>
			<xsl:when test="ul">
				<xsl:apply-templates select="ul"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="document($skeleton_path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="html:td[@id='tleft']">
		<xsl:if test="$isindex = 1">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>


	<xsl:template match="html:td[@id='tright']">
		<xsl:if test="$isindex = 1">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>


	<xsl:template match="html:div[@id='release_notes_short']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="document($release_notes_short)"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="html:div[@id='news_short']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="document($news_short)"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="html:div[@id='article']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="$fragment/*"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="html:p[@id='version']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:value-of select="$version"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>
