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
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs"
>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
	/>

	<xsl:namespace-alias
		stylesheet-prefix="html"
		result-prefix="#default"
	/>

	<xsl:param name="schema"/>


	<xsl:template match="xs:schema">
		<html:html>
			<html:head>
				<html:title>
					<xsl:text>Schema </xsl:text>
					<xsl:value-of select="$schema"/>
					<xsl:text> Documentation</xsl:text>
				</html:title>
				<html:link rel="stylesheet" type="text/css" media="projection,screen" href="xsd-doc.css"/>
			</html:head>
			<html:body>
				<html:div id="page_wrapper">
					<html:div id="page_content">
						<html:h1>
							<xsl:text>Schema </xsl:text>
							<xsl:value-of select="$schema"/>
							<xsl:text> Documentation</xsl:text>
						</html:h1>
						<xsl:call-template name="schema"/>
						<xsl:call-template name="top-elements"/>
						<xsl:call-template name="types"/>
						<!--
						<xsl:call-template name="elements"/>
						-->
						<xsl:call-template name="definitions"/>
					</html:div>
					<html:div id="page_footer">
						<xsl:text>Copyright (C) 2009 Spolecne s.r.o, </xsl:text>	
						<html:a>
							<xsl:attribute name="href">http://www.spoledge.com</xsl:attribute>
							<xsl:text>www.spoledge.com</xsl:text>
						</html:a>
					</html:div>
				</html:div>
			</html:body>
		</html:html>
	</xsl:template>


	<xsl:template name="schema">
		<html:div class="section">
			<html:table>
				<html:tr>
					<html:th>
						<xsl:text>Schema Name</xsl:text>
					</html:th>
					<html:td>
						<xsl:value-of select="$schema"/>
					</html:td>
				</html:tr>
				<html:tr>
					<html:th>
						<xsl:text>Target Namespace</xsl:text>
					</html:th>
					<html:td>
						<xsl:value-of select="@targetNamespace"/>
					</html:td>
				</html:tr>
				<html:tr>
					<html:th>
						<xsl:text>Default Element Form</xsl:text>
					</html:th>
					<html:td>
						<xsl:value-of select="@elementFormDefault"/>
					</html:td>
				</html:tr>
				<html:tr>
					<html:th>
						<xsl:text>Default Attribute Form</xsl:text>
					</html:th>
					<html:td>
						<xsl:value-of select="@attributeFormDefault"/>
					</html:td>
				</html:tr>
			</html:table>
		</html:div>
	</xsl:template>


	<xsl:template name="top-elements">
		<html:div class="section">
			<html:h2>Top Level Elements</html:h2>
			<html:ul>
				<xsl:for-each select="xs:element">
					<html:li>
						<xsl:call-template name="link"/>
					</html:li>
				</xsl:for-each>
			</html:ul>
		</html:div>
	</xsl:template>


	<xsl:template name="types">
		<html:div class="section">
			<html:h2>Types</html:h2>
			<html:ul>
				<xsl:for-each select="*[local-name()='complexType' or local-name()='simpleType']">
					<xsl:sort select="@name"/>
					<html:li>
						<xsl:call-template name="link"/>
					</html:li>
				</xsl:for-each>
			</html:ul>
		</html:div>
	</xsl:template>


	<xsl:template name="elements">
		<html:div class="section">
			<html:h2>Elements</html:h2>
			<html:ul>
				<xsl:for-each select="//*[local-name()='element']">
					<xsl:sort select="@name"/>
					<html:li>
						<xsl:call-template name="link"/>
					</html:li>
				</xsl:for-each>
			</html:ul>
		</html:div>
	</xsl:template>


	<xsl:template name="definitions">
		<html:div class="section">
			<html:h2>Definitions</html:h2>
			<xsl:apply-templates/>
			<xsl:apply-templates select="//xs:complexType[local-name(..)!='schema']"/>
			<xsl:apply-templates select="//xs:simpleType[local-name(..)!='schema']"/>
		</html:div>
	</xsl:template>


	<xsl:template match="xs:element">
		<xsl:call-template name="def-start">
			<xsl:with-param name="label" select="'Element'"/>
		</xsl:call-template>
		<html:p>
			<html:b>Type: </html:b>
			<xsl:call-template name="link-type"/>
			<html:br/>
			<html:b>Cardinality: </html:b>
			<xsl:call-template name="cardinality"/>
		</html:p>
		<xsl:call-template name="def-dump"/>
	</xsl:template>


	<xsl:template match="xs:complexType">
		<xsl:call-template name="def-start">
			<xsl:with-param name="label" select="'Complex Type'"/>
		</xsl:call-template>
		<xsl:call-template name="def-used-by"/>
		<xsl:if test="xs:sequence">
			<html:p>
				<html:b>Sequence: </html:b>
				<xsl:call-template name="sequence-choice">
					<xsl:with-param name="ctx" select="xs:sequence"/>
					<xsl:with-param name="sep" select="', '"/>
				</xsl:call-template>
			</html:p>
		</xsl:if>
		<xsl:if test="xs:choice">
			<html:p>
				<html:b>Choice: </html:b>
				<xsl:call-template name="sequence-choice">
					<xsl:with-param name="ctx" select="xs:choice"/>
					<xsl:with-param name="sep" select="' | '"/>
				</xsl:call-template>
			</html:p>
		</xsl:if>
		<xsl:if test="xs:attribute">
			<html:p>
				<html:b>Attributes: </html:b>
				<xsl:call-template name="def-attributes"/>
			</html:p>
		</xsl:if>
		<xsl:if test="*//xs:element">
			<html:p>
				<html:b>Elements: </html:b>
				<xsl:call-template name="def-elements"/>
			</html:p>
		</xsl:if>
		<xsl:apply-templates select="*/xs:extension"/>
		<xsl:call-template name="def-dump"/>
	</xsl:template>


	<xsl:template match="xs:simpleType">
		<xsl:call-template name="def-start">
			<xsl:with-param name="label" select="'Simple Type'"/>
		</xsl:call-template>
		<xsl:call-template name="def-used-by"/>
		<xsl:if test="xs:restriction">
			<html:p>
				<html:b>Restricted </html:b>
				<xsl:text>type </xsl:text>
				<xsl:call-template name="link-type">
					<xsl:with-param name="type" select="xs:restriction/@base"/>
				</xsl:call-template>
				<xsl:if test="xs:restriction/xs:enumeration">
					- enumeration:
					<xsl:call-template name="def-enumeration"/>
				</xsl:if>
			</html:p>
		</xsl:if>
		<xsl:apply-templates select="xs:extension"/>
		<xsl:call-template name="def-dump"/>
	</xsl:template>


	<xsl:template match="xs:extension">
		<html:p>
			<html:b>Extended </html:b>
			<xsl:text>type </xsl:text>
			<xsl:call-template name="link-type">
				<xsl:with-param name="type" select="@base"/>
			</xsl:call-template>
		</html:p>
		<xsl:if test="xs:attribute">
			<html:p>
				<html:b>Attributes: </html:b>
				<xsl:call-template name="def-attributes"/>
			</html:p>
		</xsl:if>
		<xsl:if test="*/xs:element">
			<html:p>
				<html:b>Elements: </html:b>
				<xsl:call-template name="def-elements"/>
			</html:p>
		</xsl:if>
	</xsl:template>


	<xsl:template name="sequence-choice">
		<xsl:param name="ctx"/>
		<xsl:param name="sep"/>
		<xsl:text>( </xsl:text>
		<xsl:for-each select="$ctx/*">
			<xsl:call-template name="comma-if-next">
				<xsl:with-param name="comma" select="$sep"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="local-name()='element'">
					<xsl:call-template name="link-type">
						<xsl:with-param name="label" select="@name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="local-name()='sequence'">
					<xsl:call-template name="sequence-choice">
						<xsl:with-param name="ctx" select="."/>
						<xsl:with-param name="sep" select="', '"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="local-name()='choice'">
					<xsl:call-template name="sequence-choice">
						<xsl:with-param name="ctx" select="."/>
						<xsl:with-param name="sep" select="' | '"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:call-template name="sequence-choice-card"/>
		</xsl:for-each>
		<xsl:text> )</xsl:text>
	</xsl:template>


	<xsl:template name="sequence-choice-card">
		<xsl:choose>
			<xsl:when test="@minOccurs=0 and (not(@maxOccurs) or @maxOccurs=1)">?</xsl:when>
			<xsl:when test="@minOccurs=0 and @maxOccurs='unbounded'">*</xsl:when>
			<xsl:when test="(not(@minOccurs) or @minOccurs=1) and @maxOccurs='unbounded'">+</xsl:when>
			<xsl:when test="(not(@minOccurs) or @minOccurs=1) and (not(@maxOccurs) or @maxOccurs=1)"></xsl:when>
			<xsl:otherwise>
				<xsl:text>{</xsl:text>
				<xsl:choose>
					<xsl:when test="@minOccurs">
						<xsl:value-of select="@minOccurs"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
				<xsl:text>, </xsl:text>
				<xsl:choose>
					<xsl:when test="@maxOccurs='unbounded'"></xsl:when>
					<xsl:when test="@maxOccurs">
						<xsl:value-of select="@maxOccurs"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="def-attributes">
		<html:table>
			<html:tr>
				<html:th>Name</html:th>
				<html:th>Required</html:th>
				<html:th>Type</html:th>
				<html:th>Default Value</html:th>
				<html:th>Fixed Value</html:th>
				<html:th>Description</html:th>
			</html:tr>
			<xsl:for-each select="xs:attribute">
				<html:tr>
					<html:td>
						<xsl:value-of select="@name"/>
					</html:td>
					<html:td>
						<xsl:choose>
							<xsl:when test="@use='required'">yes</xsl:when>
							<xsl:otherwise>no</xsl:otherwise>
						</xsl:choose>
					</html:td>
					<html:td>
						<xsl:call-template name="link-type"/>
					</html:td>
					<html:td>
						<xsl:value-of select="@default"/>
					</html:td>
					<html:td>
						<xsl:value-of select="@fixed"/>
					</html:td>
					<html:td>
						<xsl:value-of select="xs:annotation/xs:documentation"/>
					</html:td>
				</html:tr>
			</xsl:for-each>
		</html:table>
	</xsl:template>


	<xsl:template name="def-elements">
		<html:table>
			<html:tr>
				<html:th>Name</html:th>
				<html:th>Card</html:th>
				<html:th>Type</html:th>
				<html:th>Description</html:th>
			</html:tr>
			<xsl:call-template name="def-element"/>
		</html:table>
	</xsl:template>


	<xsl:template name="def-element">
		<xsl:param name="ctx" select="xs:sequence|xs:choice"/>

		<xsl:for-each select="$ctx/*">
			<xsl:choose>
				<xsl:when test="local-name()='element'">
					<html:tr>
						<html:td>
							<xsl:value-of select="@name"/>
						</html:td>
						<html:td>
							<xsl:call-template name="cardinality"/>
						</html:td>
						<html:td>
							<xsl:call-template name="link-type"/>
						</html:td>
						<html:td>
							<xsl:value-of select="xs:annotation/xs:documentation"/>
						</html:td>
					</html:tr>
				</xsl:when>
				<xsl:when test="local-name()='sequence'">
					<xsl:call-template name="def-element">
						<xsl:with-param name="ctx" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="local-name()='choice'">
					<xsl:call-template name="def-element">
						<xsl:with-param name="ctx" select="."/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="def-enumeration">
		<html:table>
			<html:tr>
				<html:th>Value</html:th>
				<html:th>Description</html:th>
			</html:tr>
			<xsl:for-each select="xs:restriction/xs:enumeration">
				<html:tr>
					<html:td>
						<xsl:value-of select="@value"/>
					</html:td>
					<html:td>
						<xsl:value-of select="xs:annotation/xs:documentation"/>
					</html:td>
				</html:tr>
			</xsl:for-each>
		</html:table>
	</xsl:template>


	<xsl:template name="def-start">
		<xsl:param name="label"/>
		<xsl:call-template name="anchor"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:value-of select="@name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="anonymous-name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<html:h3>
			<xsl:value-of select="$label"/>
			<xsl:text> "</xsl:text>
			<xsl:value-of select="$name"/>
			<xsl:text>"</xsl:text>
		</html:h3>
		<xsl:if test="xs:annotation/xs:documentation">
			<html:p>
				<xsl:value-of select="xs:annotation/xs:documentation"/>
			</html:p>
		</xsl:if>
	</xsl:template>


	<xsl:template name="def-dump">
		<html:p>
			<html:b>XSD:</html:b>
			<html:pre>
				<xsl:call-template name="dump"/>
			</html:pre>
		</html:p>
	</xsl:template>


	<xsl:template name="dump">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="indent" select="'  '"/>

		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;xs:</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:text>="</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:variable name="children" select="*[local-name()!='annotation']"/>
		<xsl:if test="not($children)">
			<xsl:text>/</xsl:text>
		</xsl:if>
		<xsl:text>&gt;
</xsl:text>

		<xsl:if test="$children">
			<xsl:for-each select="$children">
				<xsl:call-template name="dump">
					<xsl:with-param name="indent" select="concat($indent,'  ')"/>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:value-of select="$indent"/>
			<xsl:text>&lt;xs:</xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:text>&gt;
</xsl:text>
		</xsl:if>

	</xsl:template>


	<xsl:template name="def-used-by">
		<html:p>
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:variable name="name" select="@name"/>
					<xsl:variable name="usedby" select="//*[(local-name()='element' or local-name()='attribute') and @type=$name]"/>
					<xsl:choose>
						<xsl:when test="$usedby">
							<xsl:call-template name="used-by">
								<xsl:with-param name="usedby" select="$usedby"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<!-- TODO - xs:restriction and xs:extension @base attributes -->
							<html:b>Not used by any object in this file.</html:b>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>

					<xsl:variable name="nameda">
						<xsl:call-template name="named-ancestor"/>
					</xsl:variable>
					<xsl:variable name="what" select="substring-before($nameda, '|')"/>
					<xsl:variable name="name" select="substring-after($nameda, '|')"/>
					<html:b>Defined by <xsl:value-of select="$what"/> </html:b>
					<xsl:choose>
						<xsl:when test="$what='type'">
							<xsl:call-template name="link-type">
								<xsl:with-param name="type" select="$name"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="link">
								<xsl:with-param name="ctx" select="//*[local-name()=$what and @name=$name]"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:otherwise>
			</xsl:choose>
		</html:p>
	</xsl:template>


	<xsl:template name="used-by">
		<xsl:param name="usedby"/>
		<html:b>Used by </html:b>
		<xsl:for-each select="$usedby">
			<xsl:call-template name="comma-if-next"/>

			<xsl:variable name="nameda">
				<xsl:call-template name="named-ancestor">
					<xsl:with-param name="ctx" select="."/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="what" select="substring-before($nameda, '|')"/>
			<xsl:variable name="name" select="substring-after($nameda, '|')"/>
			<xsl:value-of select="$what"/>
			<xsl:text> </xsl:text>
			<xsl:choose>
				<xsl:when test="$what='type'">
					<xsl:call-template name="link-type">
						<xsl:with-param name="type" select="$name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="link">
						<xsl:with-param name="ctx" select="//*[local-name()=$what and @name=$name]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:for-each>
	</xsl:template>


	<xsl:template name="named-ancestor">
		<xsl:param name="ctx" select=".."/>
		<xsl:choose>
			<xsl:when test="not($ctx)">
				<xsl:message>NOT CTX !</xsl:message>
			</xsl:when>
			<xsl:when test="local-name($ctx)='element' and $ctx/@name and local-name($ctx/..)='schema'">
				<xsl:text>element|</xsl:text>
				<xsl:value-of select="$ctx/@name"/>
			</xsl:when>
			<xsl:when test="(local-name($ctx)='simpleType' or local-name($ctx)='complexType') and $ctx/@name">
				<xsl:text>type|</xsl:text>
				<xsl:value-of select="$ctx/@name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="named-ancestor">
					<xsl:with-param name="ctx" select="$ctx/.."/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="cardinality">
		<xsl:variable name="min">
			<xsl:choose>
				<xsl:when test="@minOccurs">
					<xsl:value-of select="@minOccurs"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="max">
			<xsl:choose>
				<xsl:when test="@maxOccurs">
					<xsl:value-of select="@maxOccurs"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$min=$max">
				<xsl:value-of select="$min"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$min"/>
				<xsl:text> - </xsl:text>
				<xsl:value-of select="$max"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="link-type">
		<xsl:param name="type" select="@type"/>
		<xsl:param name="label" select="$type"/>

		<xsl:choose>
			<xsl:when test="$type">
				<xsl:variable name="ctx" select="/xs:schema/*[(local-name()='simpleType' or local-name()='complexType') and @name=$type]"/>
				<xsl:choose>
					<xsl:when test="$ctx">
						<xsl:call-template name="link">
							<xsl:with-param name="ctx" select="$ctx"/>
							<xsl:with-param name="label" select="$label"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$label"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="xs:simpleType">
				<xsl:call-template name="link">
					<xsl:with-param name="ctx" select="xs:simpleType"/>
					<xsl:with-param name="label" select="$label"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="xs:complexType">
				<xsl:call-template name="link">
					<xsl:with-param name="ctx" select="xs:complexType"/>
					<xsl:with-param name="label" select="$label"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$label">
				<xsl:value-of select="$label"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template name="link">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="label"/>
		<html:a>
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="generate-id($ctx)"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$label">
					<xsl:if test="$ctx/@name">
						<xsl:attribute name="title">
							<xsl:value-of select="$ctx/@name"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$label"/>
				</xsl:when>
				<xsl:when test="$ctx/@name">
					<xsl:value-of select="$ctx/@name"/>
				</xsl:when>
				<xsl:otherwise>
					<html:i>
						<xsl:call-template name="anonymous-name">
							<xsl:with-param name="ctx" select="$ctx"/>
						</xsl:call-template>
					</html:i>
				</xsl:otherwise>
			</xsl:choose>
		</html:a>
	</xsl:template>


	<xsl:template name="anchor">
		<xsl:param name="ctx" select="."/>
		<html:a>
			<xsl:attribute name="name">
				<xsl:value-of select="generate-id($ctx)"/>
			</xsl:attribute>
			<xsl:text> </xsl:text>
		</html:a>
	</xsl:template>


	<xsl:template name="anonymous-name">
		<xsl:param name="ctx" select="."/>
		<xs:text>anonymous </xs:text>
		<xsl:value-of select="$ctx/../@name"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="generate-id($ctx)"/>
	</xsl:template>


	<xsl:template name="comma-if-next">
		<xsl:param name="comma" select="', '"/>
		<xsl:if test="position()!=1">
			<xsl:value-of select="$comma"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
