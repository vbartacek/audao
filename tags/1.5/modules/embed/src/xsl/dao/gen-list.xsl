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
	xmlns:db="http://www.spoledge.com/audao"
	>

	<xsl:import href="db-utils.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>


	<xsl:template match="db:database">
		<xsl:apply-templates select="db:tables/db:table"/>
		<xsl:apply-templates select="db:views/db:view"/>
	</xsl:template>


	<xsl:template match="db:table|db:view">
		<xsl:value-of select="@name"/>
		<xsl:text>=</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:if test="@use-dto and @use-dto != @name">
			<xsl:text>|NO-DTO</xsl:text>
		</xsl:if>
		<xsl:text>
</xsl:text>
	</xsl:template>

</xsl:stylesheet>
