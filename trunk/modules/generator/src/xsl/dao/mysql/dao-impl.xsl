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


	<xsl:template name="attr-sql-insert">
		<xsl:text>
    private static final String SQL_INSERT = "INSERT INTO </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> (</xsl:text>
		<xsl:for-each select="db:columns/db:column[not(db:auto) or db:type='Date' or db:type='Timestamp']">
			<xsl:if test="position() != 1">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:value-of select="@name"/>
		</xsl:for-each>
		<xsl:text>) VALUES (</xsl:text>
		<xsl:for-each select="db:columns/db:column[not(db:auto) or db:type='Date' or db:type='Timestamp']">
			<xsl:if test="position() != 1">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:text>?</xsl:text>
		</xsl:for-each>
		<xsl:text>)";
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-insert">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="ispkauto">
			<xsl:call-template name="is-pk-auto"/>
		</xsl:variable>
		<xsl:variable name="isauto" select="db:columns/db:column[db:auto][db:type='short' or db:type='int' or db:type='long']"/>
		<xsl:text>        PreparedStatement stmt = null;
</xsl:text>
		<xsl:if test="$isauto">
			<xsl:text>        ResultSet rs = null;
</xsl:text>
		</xsl:if>
		<xsl:text>
        debugSql( SQL_INSERT, dto );

        try {
            stmt = conn.prepareStatement( SQL_INSERT</xsl:text>
		<xsl:if test="$isauto">
			<xsl:text>, PreparedStatement.RETURN_GENERATED_KEYS</xsl:text>
		</xsl:if>
		<xsl:text> );
</xsl:text>
		<xsl:for-each select="db:columns/db:column[not(db:auto) or db:type='Date' or db:type='Timestamp']">
			<xsl:call-template name="set-column-insert"/>
		</xsl:for-each>
		<xsl:text>
            int n = stmt.executeUpdate();
</xsl:text>
		<xsl:if test="$isauto">
			<xsl:text>
            rs = stmt.getGeneratedKeys();
            rs.next();

</xsl:text>
			<xsl:for-each select="db:columns/db:column[db:auto][db:type='short' or db:type='int' or db:type='long']">
				<xsl:text>            dto.set</xsl:text>
				<xsl:call-template name="column-Name-ucfirst"/>
				<xsl:text>( rs.get</xsl:text>
				<xsl:call-template name="uc-first">
					<xsl:with-param name="name" select="db:type"/>
				</xsl:call-template>
				<xsl:text>( </xsl:text>
				<xsl:value-of select="position()"/>
				<xsl:text> ));
</xsl:text>
			</xsl:for-each>

		</xsl:if>
		<xsl:if test="$ispkauto=1">
			<xsl:text>
            return dto.get</xsl:text>
			<xsl:call-template name="pk-Name-ucfirst"/>
			<xsl:text>();
</xsl:text>
		</xsl:if>
		<xsl:call-template name="catch-sqlexception-write">
			<xsl:with-param name="sql">SQL_INSERT</xsl:with-param>
			<xsl:with-param name="params">dto</xsl:with-param>
		</xsl:call-template>
		<xsl:text>        finally {
</xsl:text>
		<xsl:if test="$isauto">
			<xsl:text>            if (rs != null) try { rs.close(); } catch (SQLException e) {}
</xsl:text>
		</xsl:if>
		<xsl:text>            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        }
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>

</xsl:stylesheet>
