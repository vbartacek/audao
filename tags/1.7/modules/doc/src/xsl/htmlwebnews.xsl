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
>

	<xsl:import href="commons.xsl"/>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
		omit-xml-declaration="yes"
	/>

	<xsl:param name="page"/>
	<xsl:param name="prefix"/>
	<xsl:param name="extension"/>
	<xsl:variable name="maxnews" select="3"/>

	<xsl:template match="/">
		<ul>
			<xsl:for-each select="div/div">
				<xsl:if test="position() &lt; $maxnews + 1">
				<li>
					<xsl:apply-templates select="."/>
				</li>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="count(div/div) &gt; $maxnews">
			<li>
				<xsl:call-template name="link">
					<xsl:with-param name="text">More...</xsl:with-param>
				</xsl:call-template>
			</li>
			</xsl:if>
		</ul>
	</xsl:template>


	<xsl:template match="div">
		<xsl:variable name="date" select="a[@name and @class = 'date']/@name"/>

		<xsl:call-template name="link">
			<xsl:with-param name="anchor" select="a[@name]/@name"/>
			<xsl:with-param name="text">
				<xsl:call-template name="strip">
					<xsl:with-param name="what" select="h2"/>
					<xsl:with-param name="len" select="30"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:if test="$date">
			<div style="margin-left: 5px; margin-top: 5px">
				<span class="date">
					<xsl:call-template name="date-format">
						<xsl:with-param name="date" select="a[@name and @class = 'date']/@name"/>
					</xsl:call-template>
				</span>
			</div>
		</xsl:if>

		<p>
			<xsl:call-template name="strip">
				<xsl:with-param name="what" select="p[not(@class='modified')][1]"/>
				<xsl:with-param name="len" select="100"/>
				<xsl:with-param name="more" select="count(p)"/>
			</xsl:call-template>
		</p>
	</xsl:template>


	<xsl:template match="@*|node()">
	</xsl:template>


	<xsl:template name="strip">
		<xsl:param name="what"/>
		<xsl:param name="len"/>
		<xsl:param name="more"/>

		<xsl:choose>
			<xsl:when test="string-length($what) &gt; $len">
				<xsl:value-of select="substring($what,1,$len)"/>
				<xsl:text>... </xsl:text>
				<xsl:if test="$more">
					<xsl:call-template name="link">
						<xsl:with-param name="anchor" select="a[@name]/@name"/>
						<xsl:with-param name="text">More</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$what"/>
				<xsl:if test="$more &gt; 1">
					<xsl:call-template name="link">
						<xsl:with-param name="anchor" select="a[@name]/@name"/>
						<xsl:with-param name="text">More</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="link">
		<xsl:param name="anchor"/>
		<xsl:param name="text"/>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="$prefix"/>
				<xsl:value-of select="$page"/>
				<xsl:value-of select="$extension"/>
				<xsl:if test="$anchor">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="$anchor"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:value-of select="$text"/>
		</a>
	</xsl:template>

</xsl:stylesheet>
