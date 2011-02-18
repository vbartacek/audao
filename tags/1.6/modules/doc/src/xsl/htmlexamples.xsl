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
	xmlns:ex="http://www.spoledge.com/audao/doc/examples"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ref frg ex html"
>

	<xsl:import href="htmlfrag.xsl"/>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
		omit-xml-declaration="yes"
	/>

	<xsl:namespace-alias
		stylesheet-prefix="html"
		result-prefix="#default"
	/>

	<xsl:param name="examples_xml"/>


	<xsl:template match="p[@class='examples']">
		<xsl:variable name="ctx" select="document($examples_xml)/ex:examples"/>
		<html:p>
			<html:ol>
				<xsl:apply-templates select="$ctx/ex:example"/>
			</html:ol>
		</html:p>
	</xsl:template>


	<xsl:template match="ex:example">
		<html:li>
			<html:a>
				<xsl:attribute name="href">
					<xsl:text>examples/xml/</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>.xml</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="ex:label"/>
				<xsl:text> (XML)</xsl:text>
			</html:a>

			<xsl:apply-templates select="ex:link"/>

			<xsl:if test="ex:description">
				<html:p style="margin-left: 25px;margin-top: 3px;">
					<xsl:value-of select="ex:description"/>
				</html:p>
			</xsl:if>

			<xsl:apply-templates select="ex:audao"/>
		</html:li>
	</xsl:template>


	<xsl:template match="ex:link">
		<xsl:text> - </xsl:text>
		<xsl:value-of select="ex:prefix"/>
		<html:a>
			<xsl:attribute name="href">
				<xsl:value-of select="@href"/>
			</xsl:attribute>
			<xsl:value-of select="ex:label"/>
		</html:a>
	</xsl:template>


	<xsl:template match="ex:audao">
		<html:p style="margin-left: 25px;margin-top: 3px;">
			<xsl:text> Example of AuDAO processing (</xsl:text>
			<html:b>
				<xsl:value-of select="@dbtype"/>
			</html:b>
			<xsl:text>): </xsl:text>
			<html:br/>
			<html:span style="margin-left: 64px"></html:span>

			<html:a>
				<xsl:attribute name="href">
					<xsl:text>examples/javadoc/</xsl:text>
					<xsl:value-of select="../@name"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="@dbtype"/>
					<xsl:text>/index.html</xsl:text>
				</xsl:attribute>
				<xsl:text>Browse Javadoc</xsl:text>
			</html:a>

			<xsl:text>, </xsl:text>

			<html:a>
				<xsl:attribute name="href">
					<xsl:text>examples/dao/</xsl:text>
					<xsl:value-of select="../@name"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="@dbtype"/>
					<xsl:text>.zip</xsl:text>
				</xsl:attribute>
				<xsl:text>DAO sources (zip)</xsl:text>
			</html:a>

			<xsl:text>, </xsl:text>

			<html:a>
				<xsl:attribute name="href">
					<xsl:text>examples/jar/</xsl:text>
					<xsl:value-of select="../@name"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="@dbtype"/>
					<xsl:text>.jar</xsl:text>
				</xsl:attribute>
				<xsl:text>DAO classes (jar)</xsl:text>
			</html:a>

			<xsl:if test="@dbtype != 'gae' and @dbtype != 'gaejdo'">
				<html:br/>
				<html:span style="margin-left: 64px"></html:span>

				<html:a>
					<xsl:attribute name="href">
						<xsl:text>examples/sql/</xsl:text>
						<xsl:value-of select="../@name"/>
						<xsl:text>-</xsl:text>
						<xsl:value-of select="@dbtype"/>
						<xsl:text>/create-tables.sql</xsl:text>
					</xsl:attribute>
					<xsl:text>SQL create (sql)</xsl:text>
				</html:a>

				<xsl:text>, </xsl:text>

				<html:a>
					<xsl:attribute name="href">
						<xsl:text>examples/sql/</xsl:text>
						<xsl:value-of select="../@name"/>
						<xsl:text>-</xsl:text>
						<xsl:value-of select="@dbtype"/>
						<xsl:text>/drop-tables.sql</xsl:text>
					</xsl:attribute>
					<xsl:text>SQL drop (sql)</xsl:text>
				</html:a>

			</xsl:if>


		</html:p>
	</xsl:template>


</xsl:stylesheet>
