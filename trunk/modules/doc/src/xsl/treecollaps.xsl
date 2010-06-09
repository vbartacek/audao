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
	exclude-result-prefixes="html"
>

	<xsl:output
		method="xml"
		indent="no"
		encoding="utf-8"
		omit-xml-declaration="yes"
	/>

	<xsl:namespace-alias
		stylesheet-prefix="html"
		result-prefix="#default"
	/>

	<xsl:param name="open_tags" select="'database,tables'"/>

	<xsl:variable name="opentags" select="concat(',', concat($open_tags, ','))"/>


	<xsl:template match="/">
		<html:pre>
			<xsl:attribute name="class">prettyprint xml</xsl:attribute>
			<xsl:apply-templates/>
		</html:pre>
	</xsl:template>

	<xsl:template match="*" priority="-5">
		<xsl:message><xsl:value-of select="local-name()"/></xsl:message>

		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:text>="</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:if test="local-name()='database'">
			<xsl:text> xmlns="http://www.spoledge.com/audao"</xsl:text>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="*">
				<xsl:text>&gt;</xsl:text>
				<xsl:variable name="isopen" select="contains($opentags, concat(',', concat(local-name(),',')))"/>

				<html:span>
					<xsl:attribute name="class">treeitem</xsl:attribute>
					<xsl:attribute name="onclick">toggleXml(this)</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$isopen">
							<xsl:text>-</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>+</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</html:span>
				<html:span>
					<xsl:if test="not($isopen)">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="node()"/>

					<xsl:text>&lt;/</xsl:text>
					<xsl:value-of select="local-name()"/>
					<xsl:text>&gt;</xsl:text>
				</html:span>
			</xsl:when>
			<xsl:when test="text()">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="@*|node()" priority="-10">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<!--
  &lt;tables&gt;<span style="border:1px solid #a9f;color:#a9f" onclick="toggleXml(this)">-</span><span>
	-->

</xsl:stylesheet>
