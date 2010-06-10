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
		<xsl:text>-- ======================== MySQL P R O L O G ====================
-- manually: DROP DATABASE IF EXISTS </xsl:text>
		<xsl:value-of select="$db_user"/>
		<xsl:text>;
-- manually: CREATE DATABASE your_db;
-- manually: GRANT ALL PRIVILEGES ON your_db.* TO </xsl:text>
		<xsl:value-of select="$db_user"/>
		<xsl:text>@localhost IDENTIFIED BY 'your_password';

-- not needed: USE your_db; 


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
</xsl:text>
	</xsl:template>

	<xsl:template name="db-epilog">
		<xsl:text>-- ======================== MySQL E P I L O G ====================

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
</xsl:text>
	</xsl:template>

	<xsl:template name="db-table-epilog">
		<xsl:text> ENGINE=InnoDB DEFAULT CHARSET=utf8</xsl:text>
	</xsl:template>

	<xsl:template name="db-columns-epilog">
		<xsl:if test="db:columns/db:column[db:pk]">
			<xsl:text>	, PRIMARY KEY(</xsl:text>
			<xsl:for-each select="db:columns/db:column[db:pk]">
				<xsl:call-template name="comma-if-next"/>
				<xsl:value-of select="@name"/>
			</xsl:for-each>
			<xsl:text> )
</xsl:text>
		</xsl:if>
		<xsl:variable name="cols" select="db:columns"/>
		<xsl:for-each select="db:indexes/db:index">
			<xsl:text>	, </xsl:text>
			<xsl:if test="db:unique">
				<xsl:text>UNIQUE </xsl:text>
			</xsl:if>
			<xsl:text>INDEX </xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>( </xsl:text>
			<xsl:for-each select="db:columns/db:column">
				<xsl:call-template name="comma-if-next"/>
				<xsl:value-of select="@name"/>
				<xsl:variable name="colname" select="@name"/>
				<xsl:if test="$cols/db:column[@name=$colname and (db:type='byte[]' or db:type='Serializable')]">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$cols/db:column[@name=$colname]/db:type/@max-length"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text> )
</xsl:text>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="db-column-epilog">
		<xsl:if test="db:auto and (db:type='short' or db:type='int' or db:type='long')">
			<xsl:text> auto_increment</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="db-type">
		<xsl:choose>
			<xsl:when test="db:type = 'boolean'">
				<xsl:text>tinyint</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'short'">
				<xsl:text>smallint</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'int'">
				<xsl:text>int</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'long'">
				<xsl:text>bigint</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'double'">
				<xsl:text>double</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'String'">
				<xsl:text>varchar(</xsl:text>
				<xsl:value-of select="db:type/@max-length"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'Date'">
				<xsl:text>date</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'Timestamp'">
				<!-- see mysql doc about differences:  DATETIME and TIMESTAMP -->
				<xsl:text>datetime</xsl:text>
			</xsl:when>
			<xsl:when test="(db:type = 'byte[]' or db:type='Serializable') and db:type/@max-length &lt; 256">
				<xsl:text>tinyblob</xsl:text>
			</xsl:when>
			<xsl:when test="(db:type = 'byte[]' or db:type='Serializable') and db:type/@max-length &lt; 65536">
				<xsl:text>blob</xsl:text>
			</xsl:when>
			<xsl:when test="(db:type = 'byte[]' or db:type='Serializable') and db:type/@max-length &lt; 16777216">
				<xsl:text>mediumblob</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'byte[]' or db:type='Serializable'">
				<xsl:text>longblob</xsl:text>
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
				<xsl:text>'</xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>'</xsl:text>
			</xsl:when>
			<xsl:when test="$type = 'Timestamp'">
				<xsl:text>'</xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>'</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>The type '<xsl:value-of select="$type"/>' is not supported 'db-data-column'</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-foreign-key">
		<xsl:param name="ctx"/>
		<xsl:param name="tname"/>
		<xsl:param name="fk"/>
		<!-- MySQL creates indexes automatically:
		<xsl:call-template name="check-ref-index">
			<xsl:with-param name="tname" select="$tname"/>
		</xsl:call-template>
		-->
		<xsl:call-template name="add-constraint">
			<xsl:with-param name="tname" select="$ctx/../../@name"/>
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


</xsl:stylesheet>
