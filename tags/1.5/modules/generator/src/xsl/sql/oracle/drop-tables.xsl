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

	<xsl:import href="..@DIR_SEP@drop-tables.xsl"/>

	<xsl:template name="db-epilog">
		<xsl:text>
-- ======================== Oracle E P I L O G ====================

</xsl:text>
        <xsl:call-template name="sequences"/>
	</xsl:template>


	<xsl:template name="sequences">
		<xsl:for-each select="db:tables/db:table/db:columns/db:column[db:auto][db:type='short' or db:type='int' or db:type='long']">
			<xsl:text>DROP SEQUENCE </xsl:text>
			<xsl:choose>
				<xsl:when test="db:auto/@sequence">
					<xsl:value-of select="db:auto/@sequence"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="schema-prefix">
						<xsl:with-param name="ctx" select="../.."/>
					</xsl:call-template>
					<xsl:text>seq_</xsl:text>
					<xsl:value-of select="../../@name"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>;
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="drop-table-options">
		<xsl:text> CASCADE CONSTRAINTS</xsl:text>
	</xsl:template>

</xsl:stylesheet>
