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
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/2005/Atom"
	exclude-result-prefixes="atom html"
>

	<xsl:import href="commons.xsl"/>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
	/>


	<xsl:namespace-alias
		stylesheet-prefix="atom"
		result-prefix="#default"
	/>

	<xsl:param name="page"/>
	<xsl:param name="prefix"/>
	<xsl:param name="extension"/>

	<xsl:variable name="maxnews" select="20"/>
	<xsl:variable name="audao" select="'http://audao.spoledge.com'"/>

	<xsl:template match="/">
		<feed>
			<atom:title>
				<xsl:value-of select="div/h1"/>
			</atom:title>
			<atom:subtitle>
				<xsl:value-of select="div/h2"/>
			</atom:subtitle>
			<atom:link>
				<xsl:attribute name="href">
					<xsl:value-of select="$audao"/>
				</xsl:attribute>
			</atom:link>
			<atom:link>
				<xsl:attribute name="rel">
					<xsl:text>self</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="href">
					<xsl:value-of select="$audao"/>
					<xsl:text>/feed.jsp</xsl:text>
				</xsl:attribute>
			</atom:link>
			<atom:updated>
				<xsl:text>2010-02-11T16:12:02+01:00</xsl:text>
			</atom:updated>
			<atom:author>
				<atom:name>
					<xsl:text>Vaclav Bartacek</xsl:text>
				</atom:name>
				<atom:uri>
					<xsl:text>http://cz.linkedin.com/in/vaclavbartacek</xsl:text>
				</atom:uri>
			</atom:author>
			<atom:id>
				<xsl:value-of select="$audao"/>
				<xsl:text>/</xsl:text>
			</atom:id>
			<atom:generator>
				<xsl:attribute name="version">
					<xsl:text>1.0</xsl:text>
				</xsl:attribute>
				<xsl:text>AuDAO XSL FeedGenerator</xsl:text>
			</atom:generator>
			<atom:rights>
				<xsl:attribute name="type">
					<xsl:text>xhtml</xsl:text>
				</xsl:attribute>
				<div xmlns="http://www.w3.org/1999/xhtml">
					(C) 2010 <a href="http://www.spoledge.com">Spolecne s.r.o.</a>
				</div>
			</atom:rights>
			<atom:logo>/images/audao-logo.png</atom:logo>

			<xsl:for-each select="div/div">
				<xsl:if test="position() &lt; $maxnews + 1">
				<atom:entry>
					<xsl:call-template name="entry"/>
				</atom:entry>
				</xsl:if>
			</xsl:for-each>

		</feed>
	</xsl:template>


	<xsl:template name="entry">
		<xsl:variable name="date" select="a[@name and @class = 'date']/@name"/>
		<xsl:variable name="time" select="p[@class='modified']"/>
		<xsl:variable name="link">
			<xsl:text>/doc-news.html#</xsl:text>
			<xsl:value-of select="$date"/>
		</xsl:variable>
		<atom:id>
			<xsl:value-of select="$audao"/>
			<xsl:value-of select="$link"/>
		</atom:id>
		<atom:title>
			<xsl:value-of select="h2"/>
		</atom:title>
		<atom:updated>
			<xsl:value-of select="$date"/>
			<xsl:text>T</xsl:text>
			<xsl:value-of select="$time"/>
			<xsl:text>+01:00</xsl:text>
		</atom:updated>
		<atom:link>
			<xsl:attribute name="href">
				<xsl:value-of select="$link"/>
			</xsl:attribute>
		</atom:link>
		<atom:content>
			<xsl:attribute name="type">
				<xsl:text>xhtml</xsl:text>
			</xsl:attribute>
			<div xmlns="http://www.w3.org/1999/xhtml">
				<xsl:apply-templates/>
			</div>
		</atom:content>
	</xsl:template>


	<xsl:template match="h2">
	</xsl:template>

	<xsl:template match="span[@class='modified']">
	</xsl:template>

	<xsl:template match="a[@class='date']">
	</xsl:template>

	<xsl:template match="a[@href]">
		<xsl:call-template name="a-href"/>
	</xsl:template>

	<xsl:template match="p[@class='modified']">
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>
