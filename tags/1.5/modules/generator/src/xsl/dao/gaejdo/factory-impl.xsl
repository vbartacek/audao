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

	<xsl:import href="..@DIR_SEP@factory-impl.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="db_type"/>

	<xsl:template name="imports-java">
		<xsl:text>
import javax.jdo.PersistenceManager;
import javax.jdo.PersistenceManagerFactory;
</xsl:text>

		<xsl:if test="$db_cp/@connection = 'true'">
			<xsl:text>import java.sql.Connection;
</xsl:text>
		</xsl:if>

		<xsl:if test="$db_cp/@gaeds = 'true'">
			<xsl:text>
import com.google.appengine.api.datastore.DatastoreService;
</xsl:text>
		</xsl:if>

		<xsl:if test="$db_cp/@connection = 'true' or $db_cp/@gaeds = 'true' or not($db_cp/@default = 'false')">
			<xsl:text>
import com.spoledge.audao.db.dao.gae.PersistenceManagerProvider;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="dao-factory-impl">
		<xsl:if test="$db_cp/@connection = 'true' or $db_cp/@gaeds = 'true' or not($db_cp/@default = 'false')">
			<xsl:text>
    private static PersistenceManagerProvider persistenceManagerProvider;

    public static PersistenceManager getPersistenceManager() {
        return persistenceManagerProvider.getPersistenceManager();
    }

    public static void setPersistenceManagerProvider( PersistenceManagerProvider persistenceManagerProvider ) {
        DaoFactoryImpl.persistenceManagerProvider = persistenceManagerProvider;
    }
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="mbody-create-impl">
		<xsl:param name="daoname"/>
		<xsl:param name="paramclass"/>
		<xsl:param name="paramname"/>

		<xsl:text>        return new </xsl:text>
		<xsl:value-of select="$daoname"/>
		<xsl:text>Impl( </xsl:text>
		<xsl:choose>
			<xsl:when test="$paramclass = 'PersistenceManager'">
				<xsl:value-of select="$paramname"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>getPersistenceManager()</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> );
</xsl:text>
	</xsl:template>


	<xsl:template name="resource-class">
		<xsl:text>PersistenceManager</xsl:text>
	</xsl:template>

</xsl:stylesheet>

