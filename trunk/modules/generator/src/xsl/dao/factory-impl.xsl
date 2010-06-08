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
	<xsl:param name="db_type"/>

	<xsl:variable name="pkg_dao" select="concat($pkg_db,'.dao')"/>
	<xsl:variable name="pkg_dao_impl" select="concat(concat($pkg_dao,'.'),$db_type)"/>

	<xsl:variable name="db_fact" select="$db_conf/db:factory"/>
	<xsl:variable name="db_cp" select="$db_fact/db:create-params"/>


	<xsl:template match="db:database">
		<xsl:call-template name="file-header"/>
		<xsl:text>package </xsl:text>
		<xsl:value-of select="$pkg_dao_impl"/>
		<xsl:text>;

</xsl:text>
		<xsl:call-template name="imports-java"/>
		<xsl:text>
import </xsl:text>
		<xsl:value-of select="$pkg_dao"/>
		<xsl:text>.*;


/**
 * This is the main implementation class for obtaining DAO objects.
 * @author generated
 */
public class DaoFactoryImpl extends DaoFactory.Factory {</xsl:text>
		<xsl:call-template name="dao-factory-impl"/>
		<xsl:apply-templates select="db:tables/db:table[not(@abstract='true')]"/>
		<xsl:apply-templates select="db:views/db:view"/>
		<xsl:text>
}
</xsl:text>
	</xsl:template>


	<xsl:template name="imports-java">
		<xsl:text>import java.sql.Connection;
</xsl:text>

		<xsl:if test="$db_cp/@pm = 'true'">
			<xsl:text>
import javax.jdo.PersistenceManager;
</xsl:text>
		</xsl:if>

		<xsl:if test="$db_cp/@gaeds = 'true'">
			<xsl:text>
import com.google.appengine.api.datastore.DatastoreService;
</xsl:text>
		</xsl:if>

		<xsl:if test="$db_cp/@pm = 'true' or $db_cp/@gaeds = 'true' or not($db_cp/@default = 'false')">
			<xsl:text>
import com.spoledge.audao.db.dao.ConnectionProvider;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="dao-factory-impl">
		<xsl:if test="$db_cp/@pm = 'true' or $db_cp/@gaeds = 'true' or not($db_cp/@default = 'false')">
			<xsl:text>
    private static ConnectionProvider connectionProvider;

    public static Connection getConnection() {
        return connectionProvider.getConnection();
    }

    public static void setConnectionProvider( ConnectionProvider connectionProvider ) {
        DaoFactoryImpl.connectionProvider = connectionProvider;
    }
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="db:table|db:view">
		<xsl:variable name="dtoname">
			<xsl:call-template name="java-Name"/>
		</xsl:variable>
		<xsl:variable name="daoname" select="concat($dtoname,'Dao')"/>

		<xsl:if test="not($db_cp) or not($db_cp/@default = 'false')">
			<xsl:call-template name="method-create-impl">
				<xsl:with-param name="daoname" select="$daoname"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="paramclass">
			<xsl:call-template name="resource-class"/>
		</xsl:variable>

		<xsl:if test="$db_cp/@connection = 'true' or $db_cp/@direct = 'true' and $paramclass = 'Connection'">
			<xsl:call-template name="method-create-impl">
				<xsl:with-param name="daoname" select="$daoname"/>
				<xsl:with-param name="paramclass" select="'Connection'"/>
				<xsl:with-param name="paramname" select="'conn'"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$db_cp/@pm = 'true' or $db_cp/@direct = 'true' and $paramclass = 'PersistenceManager'">
			<xsl:call-template name="method-create-impl">
				<xsl:with-param name="daoname" select="$daoname"/>
				<xsl:with-param name="paramclass" select="'PersistenceManager'"/>
				<xsl:with-param name="paramname" select="'pm'"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$db_cp/@gaeds = 'true' or $db_cp/@direct = 'true' and $paramclass = 'DatastoreService'">
			<xsl:call-template name="method-create-impl">
				<xsl:with-param name="daoname" select="$daoname"/>
				<xsl:with-param name="paramclass" select="'DatastoreService'"/>
				<xsl:with-param name="paramname" select="'ds'"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>


	<xsl:template name="method-create-impl">
		<xsl:param name="daoname"/>
		<xsl:param name="paramclass"/>
		<xsl:param name="paramname"/>

		<xsl:text>
    public </xsl:text>
		<xsl:value-of select="$daoname"/>
		<xsl:text> create</xsl:text>
		<xsl:value-of select="$daoname"/>
		<xsl:text>(</xsl:text>
		<xsl:if test="$paramclass">
			<xsl:text> </xsl:text>
			<xsl:value-of select="$paramclass"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$paramname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>) {
</xsl:text>
		<xsl:call-template name="mbody-create-impl">
			<xsl:with-param name="daoname" select="$daoname"/>
			<xsl:with-param name="paramclass" select="$paramclass"/>
			<xsl:with-param name="paramname" select="$paramname"/>
		</xsl:call-template>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-create-impl">
		<xsl:param name="daoname"/>
		<xsl:param name="paramclass"/>
		<xsl:param name="paramname"/>
		<xsl:text>        return new </xsl:text>
		<xsl:value-of select="$daoname"/>
		<xsl:text>Impl( </xsl:text>
		<xsl:choose>
			<xsl:when test="$paramclass = 'Connection'">
				<xsl:value-of select="$paramname"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>getConnection()</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> );
</xsl:text>
	</xsl:template>

	<xsl:template name="resource-class">
		<xsl:text>Connection</xsl:text>
	</xsl:template>

</xsl:stylesheet>
