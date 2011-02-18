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

	<xsl:import href="..@DIR_SEP@string-utils.xsl"/>
	<xsl:import href="sql-utils.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="db_type"/>

	<xsl:template match="db:database">
		<xsl:call-template name="db-header"/>
		<xsl:call-template name="db-prolog"/>
		<xsl:text>
</xsl:text>
		<xsl:apply-templates select="db:tables/db:table[not(@abstract)]"/>
		<xsl:apply-templates select="db:views/db:view"/>
		<xsl:text>
</xsl:text>
		<xsl:call-template name="db-foreign-keys"/>
		<xsl:call-template name="db-data"/>
		<xsl:call-template name="db-epilog"/>
	</xsl:template>

	<xsl:template name="db-prolog">
		<xsl:text>-- ======================== P R O L O G ====================
</xsl:text>
	</xsl:template>


	<xsl:template name="db-data">
		<xsl:text>-- ======================== D A T A ========================
</xsl:text>
		<xsl:for-each select="//db:table[db:data]">
			<xsl:text>
-- Data for table </xsl:text>
			<xsl:call-template name="db-name"/>
			<xsl:text>
</xsl:text>
			<xsl:call-template name="db-table-data"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="db-epilog">
		<xsl:text>-- ======================== E P I L O G ====================
</xsl:text>
	</xsl:template>


	<xsl:template match="db:table">
		<xsl:text>

-- ======================== TABLE </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> ====================
</xsl:text>
		<xsl:text>CREATE TABLE </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> (
</xsl:text>
		<xsl:apply-templates select="db:columns/db:column"/>
		<xsl:call-template name="db-columns-epilog"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="db-table-epilog"/>
		<xsl:text>;

</xsl:text>
		<xsl:call-template name="db-table-after"/>
	</xsl:template>

	<xsl:template match="db:column">
		<xsl:text>	</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> </xsl:text>
		<xsl:call-template name="db-type"/>
		<xsl:if test="db:not-null or db:pk">
			<xsl:text> NOT NULL</xsl:text>
		</xsl:if>
		<xsl:call-template name="db-column-epilog"/>
		<xsl:if test="position() != last()">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:text>
</xsl:text>
	</xsl:template>

	<xsl:template name="db-column-epilog">
	</xsl:template>

	<xsl:template name="db-columns-epilog">
	</xsl:template>

	<xsl:template name="db-table-epilog">
	</xsl:template>

	<xsl:template name="db-table-after">
	</xsl:template>

	<xsl:template name="db-type">
		<xsl:message>The 'db-type' template must be overridden !!</xsl:message>
	</xsl:template>

	<xsl:template name="db-data-column">
		<xsl:param name="type"/>
		<xsl:param name="val"/>
		<xsl:message>The 'db-data-column' template must be overridden !!</xsl:message>
	</xsl:template>

	<xsl:template name="db-table-data">
		<xsl:variable name="sql">
			<xsl:call-template name="db-sql-insert-columns"/>
		</xsl:variable>
		<xsl:variable name="cols" select="db:columns"/>
		<xsl:for-each select="db:data/db:row">
			<xsl:value-of select="$sql"/>
			<xsl:for-each select="db:c">
				<xsl:call-template name="comma-if-next"/>
				<xsl:variable name="pos" select="position()"/>
				<xsl:variable name="type" select="$cols/db:column[$pos]/db:type"/>
				<xsl:call-template name="db-data-column">
					<xsl:with-param name="type" select="$type"/>
					<xsl:with-param name="val" select="."/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:text> );
</xsl:text>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="db-sql-insert-columns">
		<xsl:text>INSERT INTO </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> ( </xsl:text>
		<xsl:for-each select="db:columns/db:column">
			<xsl:call-template name="comma-if-next"/>
			<xsl:value-of select="@name"/>
		</xsl:for-each>
		<xsl:text>)
	VALUES ( </xsl:text>
	</xsl:template>


	<xsl:template match="db:view">
		<xsl:text>

-- ======================== VIEW </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> ====================
CREATE VIEW </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> AS
    </xsl:text>
		<xsl:choose>
			<xsl:when test="db:sql/db:query">
				<xsl:value-of select="db:sql/db:query"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="view-generate"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;
</xsl:text>
	</xsl:template>


	<xsl:template name="view-generate">
		<xsl:text>SELECT </xsl:text>
		<xsl:choose>
			<xsl:when test="db:sql/db:columns[@dbtype=$db_type]">
				<xsl:value-of select="db:sql/db:columns[@dbtype=$db_type]"/>
			</xsl:when>
			<xsl:when test="db:sql/db:columns[not(@dbtype)]">
				<xsl:value-of select="db:sql/db:columns[not(@dbtype)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="db:columns/db:column">
					<xsl:call-template name="comma-if-next"/>
					<xsl:value-of select="db:ref/@alias"/>
					<xsl:text>.</xsl:text>
					<xsl:variable name="cname">
						<xsl:choose>
							<xsl:when test="db:ref/@view-column">
								<xsl:value-of select="db:ref/@view-column"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="db:ref/@column"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of select="$cname"/>
					<xsl:if test="$cname != @name">
						<xsl:text> </xsl:text>
						<xsl:value-of select="@name"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>
        FROM </xsl:text>
		<xsl:choose>
			<xsl:when test="db:sql/db:from[@dbtype=$db_type]">
				<xsl:value-of select="db:sql/db:from[@dbtype=$db_type]"/>
			</xsl:when>
			<xsl:when test="db:sql/db:from[not(@dbtype)]">
				<xsl:value-of select="db:sql/db:from[not(@dbtype)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="db:tables/db:ref">
					<xsl:call-template name="comma-if-next"/>
					<xsl:value-of select="@table"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="@alias"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="db:sql/db:where">
			<xsl:text>
        WHERE </xsl:text>
			<xsl:choose>
				<xsl:when test="db:sql/db:where[@dbtype=$db_type]">
					<xsl:value-of select="db:sql/db:where[@dbtype=$db_type]"/>
				</xsl:when>
				<xsl:when test="db:sql/db:where[not(@dbtype)]">
					<xsl:value-of select="db:sql/db:where[not(@dbtype)]"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	<xsl:template name="add-constraint">
		<xsl:param name="tname">
			<xsl:call-template name="db-name"/>
		</xsl:param>
		<xsl:text>ALTER TABLE </xsl:text>
		<xsl:value-of select="$tname"/>
		<xsl:text> ADD CONSTRAINT </xsl:text>
	</xsl:template>

</xsl:stylesheet>
