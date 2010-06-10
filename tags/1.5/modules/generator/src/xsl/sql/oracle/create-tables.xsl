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

	<xsl:import href="..@DIR_SEP@create-tables.xsl"/>

	<xsl:param name="db_user"/>

	<xsl:template name="db-prolog">
		<xsl:text>-- ======================== Oracle P R O L O G ====================
-- manually: DROP USER </xsl:text>
		<xsl:value-of select="$db_user"/>
		<xsl:text>;
-- manually: CREATE user </xsl:text>
		<xsl:value-of select="$db_user"/>
		<xsl:text> IDENTIFIED BY your_password;
-- manually: GRANT CONNECT, RESOURCE, CREATE VIEW TO </xsl:text>
		<xsl:value-of select="$db_user"/>
		<xsl:text>;

		</xsl:text>
	</xsl:template>


	<xsl:template name="db-epilog">
		<xsl:text>-- ======================== Oracle E P I L O G ====================

</xsl:text>
	</xsl:template>

	<xsl:template name="db-table-after">
		<xsl:call-template name="primary-key"/>
		<xsl:call-template name="indexes"/>
		<xsl:call-template name="sequences"/>
	</xsl:template>


	<xsl:template name="primary-key">
		<xsl:if test="db:columns/db:column[db:pk]">
			<xsl:call-template name="add-constraint"/>
			<xsl:text>pk_</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text> PRIMARY KEY (</xsl:text>
			<xsl:for-each select="db:columns/db:column[db:pk]">
				<xsl:call-template name="comma-if-next"/>
				<xsl:text>
	</xsl:text>
				<xsl:value-of select="@name"/>
			</xsl:for-each>
			<xsl:text>
);

</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="indexes">
		<xsl:for-each select="db:indexes/db:index">
			<xsl:text>CREATE </xsl:text>
			<xsl:if test="db:unique">
				<xsl:text>UNIQUE </xsl:text>
			</xsl:if>
			<xsl:text>INDEX </xsl:text>
			<xsl:call-template name="schema-prefix">
				<xsl:with-param name="ctx" select="../.."/>
			</xsl:call-template>
			<xsl:value-of select="@name"/>
			<xsl:text> ON </xsl:text>
			<xsl:call-template name="db-name">
				<xsl:with-param name="ctx" select="../.."/>
			</xsl:call-template>
			<xsl:text> (</xsl:text>
			<xsl:for-each select="db:columns/db:column">
				<xsl:call-template name="comma-if-next"/>
				<xsl:text>
	</xsl:text>
				<xsl:value-of select="@name"/>
			</xsl:for-each>
			<xsl:text>
);

</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="db-foreign-key">
		<xsl:param name="ctx"/>
		<xsl:param name="tname"/>
		<xsl:param name="fk"/>
		<xsl:call-template name="check-ref-index">
			<xsl:with-param name="ctx" select="$ctx"/>
			<xsl:with-param name="tname" select="$tname"/>
		</xsl:call-template>
		<xsl:call-template name="add-constraint">
			<xsl:with-param name="tname">
				<xsl:call-template name="db-name">
					<xsl:with-param name="ctx" select="$ctx/../.."/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$fk"/>
		<xsl:text> FOREIGN KEY (
	</xsl:text>
		<xsl:value-of select="$ctx/@name"/>
		<xsl:text>
)
REFERENCES </xsl:text>
		<xsl:value-of select="$tname"/>
		<xsl:text> (
	</xsl:text>
		<xsl:value-of select="$ctx/db:ref/@column"/>
		<xsl:text>
);

</xsl:text>
	</xsl:template>


	<xsl:template name="check-ref-index">
		<xsl:param name="ctx"/>
		<xsl:param name="tname"/>
		<xsl:variable name="cname" select="$ctx/db:ref/@column"/>
		<xsl:variable name="table" select="$ctx/../../../db:table[@name=$tname]"/>
		<xsl:choose>
			<xsl:when test="$table/db:columns/db:column[db:pk][1][@name = $cname]">
			</xsl:when>
			<xsl:when test="$table/db:indexes/db:index/db:columns/db:column[1][@name = $cname]">
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>No index created for foreign key '<xsl:value-of select="concat($ctx/../../@name, concat('::',$ctx/@name))"/>' on referenced table '<xsl:value-of select="$tname"/>'. Performance problems are expected.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="sequences">
		<xsl:for-each select="db:columns/db:column[db:auto][db:type='short' or db:type='int' or db:type='long']">
			<xsl:text>CREATE SEQUENCE </xsl:text>
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
			<xsl:choose>
				<xsl:when test="db:auto/@start">
					<xsl:text> START WITH </xsl:text>
					<xsl:value-of select="db:auto/@start"/>
				</xsl:when>
				<xsl:when test="../../db:data/db:row">
					<xsl:text> START WITH </xsl:text>
					<xsl:value-of select="count(../../db:data/db:row) + 1"/>
				</xsl:when>
			</xsl:choose>
			<xsl:text>;

</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="db-type">
		<xsl:choose>
			<xsl:when test="db:type = 'boolean'">
				<xsl:text>number(1)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'short'">
				<xsl:text>number(6)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'int'">
				<xsl:text>number(11)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'long'">
				<xsl:text>number(19)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'double'">
				<xsl:text>float</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'String'">
				<xsl:if test="db:type/@i18n='true'">
					<xsl:text>n</xsl:text>
				</xsl:if>
				<xsl:text>varchar2(</xsl:text>
				<xsl:value-of select="db:type/@max-length"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'Date'">
				<xsl:text>date</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'Timestamp'">
				<xsl:text>date</xsl:text>
			</xsl:when>
			<xsl:when test="(db:type = 'byte[]' or db:type='Serializable') and db:type/@max-length &lt; 2001">
				<xsl:text>raw(</xsl:text>
				<xsl:value-of select="db:type/@max-length"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'byte[]' or db:type='Serializable'">
				<xsl:text>long raw</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>The type '<xsl:value-of select="db:type"/>' is not supported 'db-data-column'</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-data-column">
		<xsl:param name="type"/>
		<xsl:param name="val"/>

		<xsl:choose>
			<xsl:when test="$type = 'boolean'">
				<xsl:choose>
					<xsl:when test="$val = 'true'">
						<xsl:text>1</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'short'">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:when test="$type = 'int'">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:when test="$type = 'long'">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:when test="$type = 'String'">
				<xsl:text>'</xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>'</xsl:text>
			</xsl:when>
			<xsl:when test="$type = 'Date'">
				<xsl:text>to_date('</xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>','YYYY-MM-DD')</xsl:text>
			</xsl:when>
			<xsl:when test="$type = 'Timestamp'">
				<xsl:text>to_date('</xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>','YYYY-MM-DD HH24:MI:SS')</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>The type '<xsl:value-of select="$type"/>' is not supported 'db-data-column'</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
