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
	xmlns:ref="http://www.spoledge.com/audao/doc/xsdref"
	xmlns:frg="http://www.spoledge.com/audao/doc/fragments"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ref frg html"
>

	<xsl:import href="commons.xsl"/>

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

	<xsl:param name="xsdrefs_xml"/>
	<xsl:param name="fragments_xml"/>
	<xsl:param name="prefix"/>
	<xsl:param name="extension"/>
	<xsl:param name="nocontents"/>

	<xsl:template match="/">
		<xsl:variable name="index">
			<xsl:choose>
				<xsl:when test="$extension">
					<xsl:value-of select="$prefix"/>
					<xsl:text>index.html</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'doc.jsp'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<html:div>

			<xsl:variable name="fragments" select="document($fragments_xml)/frg:fragments"/>
			<xsl:param name="ctx" select="/div"/>
			<xsl:param name="fragment" select="$ctx/a[@name]/@name"/>

			<xsl:choose>
				<xsl:when test="$fragments/frg:fragment[@name=$fragment]">
					<xsl:call-template name="navigation">
						<xsl:with-param name="pos" select="'top'"/>
						<xsl:with-param name="index" select="$index"/>
						<xsl:with-param name="fragments" select="$fragments"/>
					</xsl:call-template>

					<xsl:apply-templates select="div[@class='chapter']"/>

					<xsl:call-template name="navigation">
						<xsl:with-param name="pos" select="'top'"/>
						<xsl:with-param name="index" select="$index"/>
						<xsl:with-param name="fragments" select="$fragments"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- news -->
					<xsl:for-each select="$ctx">
						<xsl:call-template name="reccopy">
							<xsl:with-param name="no" select=""/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

		</html:div>
	</xsl:template>


	<xsl:template match="div[@class='chapter']">
		<xsl:call-template name="reccopy">
			<xsl:with-param name="no">
				<xsl:call-template name="no"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="div[@class='section']">
	</xsl:template>

	<xsl:template match="div[@class='subsection']">
	</xsl:template>

	<xsl:template match="div[@class='subsubsection']">
	</xsl:template>

	<xsl:template match="h1|h2|h3|h4">
	</xsl:template>

	<xsl:template match="a[@name]">
	</xsl:template>

	<xsl:template match="a[@href]">
		<xsl:call-template name="a-href"/>
	</xsl:template>

	<xsl:template match="p[@class='chapter-abstract']">
	</xsl:template>

	<xsl:template match="p[@class='modified']">
		<html:p>
			<xsl:attribute name="class">
				<xsl:text>modified</xsl:text>
			</xsl:attribute>
			<xsl:text>(last modified on </xsl:text>
			<xsl:call-template name="date-format">
				<xsl:with-param name="date" select="../a[@name and @class='date']/@name"/>
			</xsl:call-template>
			<xsl:text> </xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>)</xsl:text>
		</html:p>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template name="reccopy">
		<xsl:param name="no"/>

		<xsl:variable name="class" select="@class"/>

		<xsl:variable name="contents">
			<xsl:choose>
				<xsl:when test="not($nocontents) and $class='chapter'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="subclass">
			<xsl:call-template name="subclass">
				<xsl:with-param name="class" select="$class"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="a[@name]"/>
			<xsl:call-template name="header">
				<xsl:with-param name="no" select="$no"/>
				<xsl:with-param name="class" select="$class"/>
			</xsl:call-template>

			<xsl:copy-of select="p[@class='chapter-abstract']"/>

			<xsl:if test="$contents='1' and div[@class=$subclass]">
				<xsl:call-template name="contents">
					<xsl:with-param name="no" select="$no"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:apply-templates select="*"/>

			<xsl:for-each select="div[@class=$subclass]">
				<xsl:call-template name="reccopy">
					<xsl:with-param name="no">
						<xsl:call-template name="nno">
							<xsl:with-param name="no" select="$no"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>


	<xsl:template name="header">
		<xsl:param name="no"/>
		<xsl:param name="class"/>

		<xsl:for-each select="h1|h2|h3|h4">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:if test="$no">
					<xsl:value-of select="$no"/>
					<xsl:text> </xsl:text>
				</xsl:if>

				<xsl:value-of select="."/>
				<xsl:if test="../a[@name and @class='date'] and not(../p[@class='modified'])">
					<xsl:text> - </xsl:text>
					<xsl:call-template name="date-format">
						<xsl:with-param name="date" select="../a[@name and @class='date']/@name"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="contents">
		<xsl:param name="no"/>
		<html:div>
			<xsl:attribute name="class">doc-contents</xsl:attribute>
			<xsl:call-template name="reccontents">
				<xsl:with-param name="no" select="$no"/>
			</xsl:call-template>
		</html:div>
	</xsl:template>


	<xsl:template name="reccontents">
		<xsl:param name="no"/>
		<xsl:param name="class" select="'section'"/>
		<xsl:param name="prefix"/>

		<xsl:variable name="subclass">
			<xsl:call-template name="subclass">
				<xsl:with-param name="class" select="$class"/>
			</xsl:call-template>
		</xsl:variable>

		<html:ol>
			<xsl:for-each select="div[@class=$class]">
				<xsl:variable name="nno">
					<xsl:call-template name="nno">
						<xsl:with-param name="no" select="$no"/>
					</xsl:call-template>
				</xsl:variable>
				<html:li>

					<xsl:call-template name="contents-value">
						<xsl:with-param name="no" select="$nno"/>
						<xsl:with-param name="prefix" select="$prefix"/>
					</xsl:call-template>

					<xsl:if test="div[@class=$subclass]">
						<xsl:call-template name="reccontents">
							<xsl:with-param name="no" select="$nno"/>
							<xsl:with-param name="class" select="$subclass"/>
							<xsl:with-param name="prefix" select="$prefix"/>
						</xsl:call-template>
					</xsl:if>
				</html:li>
			</xsl:for-each>
		</html:ol>

	</xsl:template>


	<xsl:template name="contents-value">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="prefix"/>
		<xsl:param name="no"/>

		<xsl:if test="$no">
			<xsl:value-of select="$no"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<html:a>
			<xsl:attribute name="href">
				<xsl:value-of select="$prefix"/>
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$ctx/a[@name]/@name"/>
			</xsl:attribute>
			<xsl:value-of select="$ctx/h1|$ctx/h2|$ctx/h3|$ctx/h4"/>
			<xsl:if test="$ctx/a[@name and @class='date'] and not($ctx/p[@class='modified'])">
				<xsl:text> - </xsl:text>
				<xsl:call-template name="date-format">
					<xsl:with-param name="date" select="$ctx/a[@name and @class='date']/@name"/>
				</xsl:call-template>
			</xsl:if>

		</html:a>
	</xsl:template>


	<xsl:template name="navigation">
		<xsl:param name="pos"/>
		<xsl:param name="index"/>
		<xsl:param name="fragments"/>

		<xsl:variable name="no">
			<xsl:call-template name="no"/>
		</xsl:variable>

		<xsl:variable name="prev">
			<xsl:if test="$no != 1">
				<xsl:value-of select="$prefix"/>
				<xsl:value-of select="$fragments/frg:fragment[position() = $no - 1]/@name"/>
				<xsl:value-of select="$extension"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:if test="$fragments/frg:fragment[position() = $no + 1]">
				<xsl:value-of select="$prefix"/>
				<xsl:value-of select="$fragments/frg:fragment[position() = $no + 1]/@name"/>
				<xsl:value-of select="$extension"/>
			</xsl:if>
		</xsl:variable>

		<xsl:call-template name="navigation-impl">
			<xsl:with-param name="pos" select="$pos"/>
			<xsl:with-param name="prev" select="$prev"/>
			<xsl:with-param name="index" select="$index"/>
			<xsl:with-param name="next" select="$next"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="navigation-impl">
		<xsl:param name="pos"/>
		<xsl:param name="prev"/>
		<xsl:param name="index"/>
		<xsl:param name="next"/>

		<html:table>
			<xsl:attribute name="width">100%</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:text>doc-navig doc-navig-</xsl:text>
				<xsl:value-of select="$pos"/>
			</xsl:attribute>
			<html:tr>
				<xsl:call-template name="navig-item">
					<xsl:with-param name="link" select="$prev"/>
					<xsl:with-param name="label" select="'Previous'"/>
					<xsl:with-param name="align" select="'left'"/>
				</xsl:call-template>
				<xsl:call-template name="navig-item">
					<xsl:with-param name="link" select="$index"/>
					<xsl:with-param name="label" select="'Index'"/>
					<xsl:with-param name="width" select="'34%'"/>
					<xsl:with-param name="align" select="'center'"/>
				</xsl:call-template>
				<xsl:call-template name="navig-item">
					<xsl:with-param name="link" select="$next"/>
					<xsl:with-param name="label" select="'Next'"/>
					<xsl:with-param name="align" select="'right'"/>
				</xsl:call-template>
			</html:tr>
		</html:table>
	</xsl:template>


	<xsl:template name="navig-item">
		<xsl:param name="link"/>
		<xsl:param name="label"/>
		<xsl:param name="width" select="'33%'"/>
		<xsl:param name="align"/>

		<html:td>
			<xsl:attribute name="width">
				<xsl:value-of select="$width"/>
			</xsl:attribute>
			<xsl:attribute name="align">
				<xsl:value-of select="$align"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$link">
					<html:a>
						<xsl:attribute name="href">
							<xsl:value-of select="$link"/>
						</xsl:attribute>
						<xsl:value-of select="$label"/>
					</html:a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$label"/>
				</xsl:otherwise>
			</xsl:choose>
		</html:td>
	</xsl:template>



	<xsl:template name="subclass">
		<xsl:param name="class"/>
		<xsl:choose>
			<xsl:when test="$class='chapter'">
				<xsl:text>section</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('sub',$class)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="no">
		<xsl:param name="ctx" select="/div"/>
		<xsl:param name="fragment" select="$ctx/a[@name]/@name"/>

		<xsl:variable name="fragments" select="document($fragments_xml)/frg:fragments"/>
		<xsl:if test="not($fragments/frg:fragment[@name=$fragment])">
			<xsl:message terminate="yes">
				<xsl:text>Cannot find fragment name '</xsl:text>
				<xsl:value-of select="$fragment"/>
				<xsl:text>' in the fragments.xml</xsl:text>
			</xsl:message>
		</xsl:if>
		<xsl:for-each select="$fragments/frg:fragment">
			<xsl:if test="@name=$fragment">
				<xsl:value-of select="position()"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="nno">
		<xsl:param name="no"/>
		<xsl:choose>
			<xsl:when test="$no">
				<xsl:value-of select="concat($no, concat('.', position()))"/>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
