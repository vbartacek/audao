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

	<xsl:import href="sql-utils.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:template match="db:database">
		<xsl:call-template name="db-header"/>
		<xsl:call-template name="db-prolog"/>
		<xsl:call-template name="db-foreign-keys"/>
		<xsl:apply-templates select="db:views/db:view">
			<xsl:sort select="position()" data-type="number" order="descending"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="db:tables/db:table[not(@abstract)]">
			<xsl:sort select="position()" data-type="number" order="descending"/>
		</xsl:apply-templates>
		<xsl:call-template name="db-epilog"/>
	</xsl:template>


	<xsl:template name="db-prolog">
		<xsl:text>-- ======================== P R O L O G ====================
</xsl:text>
	</xsl:template>


	<xsl:template name="db-epilog">
		<xsl:text>
-- ======================== E P I L O G ====================
</xsl:text>
	</xsl:template>


	<xsl:template match="db:table">
		<xsl:text>drop table </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:call-template name="drop-table-options"/>
		<xsl:text>;
</xsl:text>
	</xsl:template>


	<xsl:template match="db:view">
		<xsl:text>drop view </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text>;
</xsl:text>
	</xsl:template>


	<xsl:template name="drop-table-options">
	</xsl:template>

</xsl:stylesheet>
