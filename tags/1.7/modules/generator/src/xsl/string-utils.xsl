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
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="camel-name-trim-es">
		<xsl:param name="name"/>
		<xsl:param name="capital"/>
		<xsl:call-template name="trim-es">
			<xsl:with-param name="name">
				<xsl:call-template name="camel-name">
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="camel-name">
		<xsl:param name="name"/>
		<xsl:param name="capital"/>
		<xsl:choose>
			<xsl:when test="string-length($name)=0">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="string-length(substring-before($name,'_'))=0">
				<xsl:call-template name="capital-first">
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="before">
					<xsl:call-template name="camel-name">
						<xsl:with-param name="name" select="substring-before($name,'_')"/>
						<xsl:with-param name="capital" select="$capital"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="after">
					<xsl:call-template name="camel-name">
						<xsl:with-param name="name" select="substring-after($name,'_')"/>
						<xsl:with-param name="capital" select="1"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($before, $after)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="trim-es">
		<xsl:param name="name"/>
		<xsl:variable name="end" select="substring($name, string-length($name)-2)"/>
		<xsl:choose>
			<xsl:when test="$end = 'ses' or $end = 'hes'">
				<xsl:value-of select="substring($name,0, string-length($name)-1)"/>
			</xsl:when>
			<xsl:when test="substring($name, string-length($name)) = 's'">
				<xsl:value-of select="substring($name,0, string-length($name))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="capital-first">
		<xsl:param name="name"/>
		<xsl:param name="capital"/>
		<xsl:choose>
			<xsl:when test="$capital=1">
				<xsl:call-template name="uc-first">
					<xsl:with-param name="name" select="$name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="lc-first">
					<xsl:with-param name="name" select="$name"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="uc-first">
		<xsl:param name="name"/>
		<xsl:call-template name="uc">
			<xsl:with-param name="name" select="substring($name,1,1)"/>
		</xsl:call-template>
		<xsl:value-of select="substring($name,2)"/>
	</xsl:template>

	<xsl:template name="lc-first">
		<xsl:param name="name"/>
		<xsl:call-template name="lc">
			<xsl:with-param name="name" select="substring($name,1,1)"/>
		</xsl:call-template>
		<xsl:value-of select="substring($name,2)"/>
	</xsl:template>

	<xsl:template name="uc">
		<xsl:param name="name"/>
		<xsl:value-of select="translate($name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
	</xsl:template>

	<xsl:template name="lc">
		<xsl:param name="name"/>
		<xsl:value-of select="translate($name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
	</xsl:template>

	<xsl:template name="comma-if-next">
		<xsl:if test="position() != 1">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
