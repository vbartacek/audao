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
>

	<xsl:param name="xsdrefs_xml"/>
	<xsl:param name="prefix"/>
	<xsl:param name="extension"/>

	<xsl:variable name="xsdrefs" select="document($xsdrefs_xml)/ref:refs"/>

	<xsl:template name="a-href">
		<xsl:copy>
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="starts-with(@href,'[xsd:')">
						<xsl:call-template name="xsd-href"/>
					</xsl:when>
					<xsl:when test="starts-with(@href,'[api:')">
						<xsl:call-template name="api-href"/>
					</xsl:when>
					<xsl:when test="contains(@href,'[')">
						<xsl:value-of select="$prefix"/>
						<xsl:value-of select="substring-before(substring-after(@href,'['), ']')"/>
						<xsl:value-of select="$extension"/>
						<xsl:value-of select="substring-after(@href,']')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@href"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="text()|node()"/>
			<xsl:choose>
				<xsl:when test="starts-with(@href,'[api:')">
					<xsl:text> (API)</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>


	<xsl:template name="xsd-href">
		<xsl:param name="name" select="substring-before(substring-after(@href,'[xsd:'),']')"/>
		<xsl:variable name="ref" select="$xsdrefs/ref:ref[@name=$name]"/>

		<xsl:if test="not($ref)">
			<xsl:message terminate="yes">
				Cannot resolve XSD link '<xsl:value-of select="@href"/>'.
			</xsl:message>
		</xsl:if>

		<xsl:text>audao.html</xsl:text>
		<xsl:value-of select="$ref/@href"/>
	</xsl:template>


	<xsl:template name="api-href">
		<xsl:param name="name" select="substring-before(substring-after(@href,'[api:'),']')"/>

		<xsl:text>examples/javadoc/audao/com/spoledge/audao/</xsl:text>

		<xsl:choose>
			<xsl:when test="contains($name,'::')">
				<xsl:variable name="pkg" select="substring-before($name, '::')"/>
				<xsl:variable name="class" select="substring-after($name, '::')"/>
				<xsl:value-of select="$pkg"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$class"/>
				<xsl:if test="string-length($class) = 0">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($name,':')">
				<xsl:variable name="type" select="substring-before($name, ':')"/>
				<xsl:variable name="class" select="substring-after($name, ':')"/>
				<xsl:text>db/</xsl:text>
				<xsl:value-of select="$type"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$class"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>db/</xsl:text>
				<xsl:value-of select="$name"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text>.html</xsl:text>
	</xsl:template>


	<xsl:template name="date-format">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="substring-before($date,'-')"/>
		<xsl:variable name="md" select="substring-after($date,'-')"/>
		<xsl:variable name="month" select="0 + number(substring-before($md,'-'))"/>
		<xsl:variable name="day" select="0 + number(substring-after($md,'-'))"/>
		<xsl:choose>
			<xsl:when test="$month = 1">January</xsl:when>
			<xsl:when test="$month = 2">February</xsl:when>
			<xsl:when test="$month = 3">March</xsl:when>
			<xsl:when test="$month = 4">April</xsl:when>
			<xsl:when test="$month = 5">May</xsl:when>
			<xsl:when test="$month = 6">June</xsl:when>
			<xsl:when test="$month = 7">July</xsl:when>
			<xsl:when test="$month = 8">August</xsl:when>
			<xsl:when test="$month = 9">September</xsl:when>
			<xsl:when test="$month = 10">October</xsl:when>
			<xsl:when test="$month = 11">November</xsl:when>
			<xsl:when test="$month = 12">December</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$month"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$day"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="$year"/>
	</xsl:template>

</xsl:stylesheet>

