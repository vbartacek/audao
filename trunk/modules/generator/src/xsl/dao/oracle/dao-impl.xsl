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

	<xsl:import href="..@DIR_SEP@dao-impl.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="table_name"/>


	<xsl:template name="mbody-get-order-expr">
		<xsl:call-template name="open-mbody"/>
		<xsl:choose>
			<xsl:when test="not(db:columns/db:column[db:type[@i18n='true']])">
				<xsl:text>        return col.columnName();
</xsl:text>
			</xsl:when>
			<xsl:when test="count(db:columns/db:column[db:type[@i18n='true']])=1">
				<xsl:text>        if (col == </xsl:text>
				<xsl:call-template name="dao-name"/>
				<xsl:text>.Column.</xsl:text>
				<xsl:call-template name="uc">
					<xsl:with-param name="name" select="db:columns/db:column[db:type[@i18n='true']]/@name"/>
				</xsl:call-template>
				<xsl:text>) {
            return "</xsl:text>
				<xsl:call-template name="get-order-expr">
					<xsl:with-param name="ctx" select="db:columns/db:column[db:type[@i18n='true']]"/>
				</xsl:call-template>
				<xsl:text>";
        }
        else {
            return col.columnName();
        }
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>        switch (col) {
</xsl:text>
				<xsl:for-each select="db:columns/db:column[db:type[@i18n='true']]">
					<xsl:text>            case </xsl:text>
					<xsl:call-template name="uc">
						<xsl:with-param name="name" select="@name"/>
					</xsl:call-template>
					<xsl:text>:</xsl:text>
					<xsl:choose>
						<xsl:when test="position()=last()">
							<xsl:text> return "NLSSORT( " + col.columnName() + ", 'NLS_SORT=generic_m')";</xsl:text>
						</xsl:when>
					</xsl:choose>
					<xsl:text>
</xsl:text>
				</xsl:for-each>
				<xsl:text>            default: return col.columnName();
        }
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-insert">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="ispkauto">
			<xsl:call-template name="is-pk-auto"/>
		</xsl:variable>
		<xsl:text>        PreparedStatement stmt = null;
        debugSql( SQL_INSERT, dto );

        try {
            stmt = conn.prepareStatement( SQL_INSERT );
</xsl:text>
		<xsl:for-each select="db:columns/db:column[db:auto][db:type='short' or db:type='int' or db:type='long']">
			<xsl:text>            dto.set</xsl:text>
			<xsl:call-template name="column-Name-ucfirst"/>
			<xsl:text>( select</xsl:text>
			<xsl:call-template name="column-Type"/>
			<xsl:text>( "SELECT </xsl:text>
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
			<xsl:text>.nextval FROM DUAL" ));
</xsl:text>
		</xsl:for-each>
		<xsl:for-each select="db:columns/db:column">
			<xsl:call-template name="set-column-insert"/>
		</xsl:for-each>
		<xsl:text>
            int n = stmt.executeUpdate();
</xsl:text>
		<xsl:if test="$ispkauto=1">
			<xsl:text>
            return dto.get</xsl:text>
			<xsl:call-template name="pk-Name"/>
			<xsl:text>();
</xsl:text>
		</xsl:if>
		<xsl:call-template name="catch-sqlexception-write">
			<xsl:with-param name="sql">SQL_INSERT</xsl:with-param>
			<xsl:with-param name="params">dto</xsl:with-param>
		</xsl:call-template>
		<xsl:text>        finally {
</xsl:text>
		<xsl:text>            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        }
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="get-order-expr">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="$ctx/db:type[@i18n='true']">
				<xsl:text>NLSSORT( </xsl:text>
				<xsl:value-of select="$ctx/@name"/>
				<xsl:text>, 'NLS_SORT=generic_m')</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$ctx/@name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="null-column-condition">
		<xsl:param name="getter"/>
		<xsl:text>
            if ( </xsl:text>
		<xsl:value-of select="$getter"/>
		<xsl:text> == null</xsl:text>
		<xsl:if test="db:type = 'String'">
			<xsl:text> || </xsl:text>
			<xsl:value-of select="$getter"/>
			<xsl:text>.length() == 0</xsl:text>
		</xsl:if>
		<xsl:text> ) {
                </xsl:text>
	</xsl:template>


</xsl:stylesheet>
