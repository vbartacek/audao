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
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ref="http://www.spoledge.com/audao/doc/xsdref"
	exclude-result-prefixes="xs"
>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
	/>


	<xsl:template match="xs:schema">
		<ref:refs>
			<xsl:apply-templates select="*[local-name()='complexType' or local-name()='simpleType']"/>
		</ref:refs>
	</xsl:template>


	<xsl:template match="node()">
	</xsl:template>


	<xsl:template match="*[local-name()='complexType' or local-name()='simpleType']">
		<xsl:call-template name="link"/>
	</xsl:template>


	<xsl:template name="link">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="label" select="$ctx/@name"/>
		<ref:ref>
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="generate-id($ctx)"/>
			</xsl:attribute>
			<xsl:attribute name="name">
				<xsl:value-of select="$label"/>
			</xsl:attribute>
		</ref:ref>
	</xsl:template>

</xsl:stylesheet>

