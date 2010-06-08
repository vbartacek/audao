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

	<xsl:template match="db:database">
		<xsl:call-template name="file-header"/>
		<xsl:text>package </xsl:text>
		<xsl:value-of select="$pkg_dao"/>
		<xsl:text>;

</xsl:text>

		<xsl:variable name="fc" select="db:config/db:factory/db:create-params"/>

		<xsl:if test="$fc">
			<xsl:variable name="paramclass">
				<xsl:call-template name="resource-class"/>
			</xsl:variable>

			<xsl:if test="$fc/@connection = 'true' or $fc/@direct = 'true' and $paramclass = 'Connection'">
				<xsl:text>import java.sql.Connection;
</xsl:text>
			</xsl:if>

			<xsl:if test="$fc/@pm = 'true' or $fc/@direct = 'true' and $paramclass = 'PersistenceManager'">
				<xsl:text>import javax.jdo.PersistenceManager;
</xsl:text>
			</xsl:if>
		</xsl:if>

		<xsl:text>

/**
 * This is the main class for obtaining DAO objects.
 * It looks for the system property called "</xsl:text>
 		<xsl:value-of select="$pkg_dao"/>
		<xsl:text>.DB_TYPE"
 * and its value is used as the DAO implementation subpackage name.
 * The default value is "</xsl:text>
 		<xsl:value-of select="$db_type"/>
		<xsl:text>".
 * The name of the Factory class is assumed to be "DaoFactoryImpl"
 * and it must have the default constructor defined.
 *
 * @author generated
 */
public class DaoFactory {
</xsl:text>
		<xsl:call-template name="static-block"/>
		<xsl:call-template name="static-methods"/>
		<xsl:call-template name="factory-class"/>
		<xsl:text>
}
</xsl:text>
	</xsl:template>


	<xsl:template name="static-block">
		<xsl:text>
    private static Factory factory;

    static {
        String pkgDao = DaoFactory.class.getPackage().getName();
        String pkgImpl = pkgDao + '.' + System.getProperty( pkgDao + ".DB_TYPE", "</xsl:text>
		<xsl:value-of select="$db_type"/>
		<xsl:text><![CDATA[" );
        try {
            Class<?> aclazz = Class.forName( pkgImpl + ".DaoFactoryImpl" );
            Class<? extends Factory> clazz = aclazz.asSubclass( Factory.class );
            factory = clazz.newInstance();
        }
        catch (Exception e) {
            throw new Error("A problem occurred when resolving DAO factory class", e);
        }
    }
]]></xsl:text>
	</xsl:template>


	<xsl:template name="static-methods">
		<xsl:text>

    ////////////////////////////////////////////////////////////////////////////
    // Static methods
    ////////////////////////////////////////////////////////////////////////////</xsl:text>

		<xsl:apply-templates select="db:tables/db:table[not(@abstract='true')]"/>
		<xsl:apply-templates select="db:views/db:view"/>
	</xsl:template>


	<xsl:template match="db:table|db:view">
		<xsl:variable name="dtoname">
			<xsl:call-template name="java-Name"/>
		</xsl:variable>
		<xsl:variable name="daoname" select="concat($dtoname,'Dao')"/>

		<xsl:variable name="fc" select="/db:database/db:config/db:factory/db:create-params"/>

		<xsl:if test="not($fc) or not($fc/@default = 'false')">
			<xsl:call-template name="method-create-dao">
				<xsl:with-param name="daoname" select="$daoname"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="paramclass">
			<xsl:call-template name="resource-class"/>
		</xsl:variable>

		<xsl:if test="$fc/@connection = 'true' or $fc/@direct = 'true' and $paramclass = 'Connection'">
			<xsl:call-template name="method-create-dao">
				<xsl:with-param name="daoname" select="$daoname"/>
				<xsl:with-param name="paramclass" select="'Connection'"/>
				<xsl:with-param name="paramname" select="'conn'"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$fc/@pm = 'true' or $fc/@direct = 'true' and $paramclass = 'PersistenceManager'">
			<xsl:call-template name="method-create-dao">
				<xsl:with-param name="daoname" select="$daoname"/>
				<xsl:with-param name="paramclass" select="'PersistenceManager'"/>
				<xsl:with-param name="paramname" select="'pm'"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>


	<xsl:template name="resource-class">
		<xsl:text>Connection</xsl:text>
	</xsl:template>


	<xsl:template name="method-create-dao">
		<xsl:param name="daoname"/>
		<xsl:param name="paramclass"/>
		<xsl:param name="paramname"/>

		<xsl:text>

    public static </xsl:text>
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
        return factory.create</xsl:text>
		<xsl:value-of select="$daoname"/>
		<xsl:text>(</xsl:text>
		<xsl:if test="$paramclass">
			<xsl:text> </xsl:text>
			<xsl:value-of select="$paramname"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>);
    }</xsl:text>
	</xsl:template>


	<xsl:template name="factory-class">
		<xsl:text>


    ////////////////////////////////////////////////////////////////////////////
    // Inner classes
    ////////////////////////////////////////////////////////////////////////////

    public static abstract class Factory {
</xsl:text>
		<xsl:variable name="fc" select="db:config/db:factory/db:create-params"/>

		<xsl:for-each select="db:tables/db:table[not(@abstract='true')]|db:views/db:view">
			<xsl:variable name="dtoname">
				<xsl:call-template name="java-Name"/>
			</xsl:variable>
			<xsl:variable name="daoname" select="concat($dtoname,'Dao')"/>

			<xsl:if test="not($fc) or not($fc/@default = 'false')">
				<xsl:call-template name="method-create-dao-impl">
					<xsl:with-param name="daoname" select="$daoname"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:variable name="paramclass">
				<xsl:call-template name="resource-class"/>
			</xsl:variable>

			<xsl:if test="$fc/@connection = 'true' or $fc/@direct = 'true' and $paramclass = 'Connection'">
				<xsl:call-template name="method-create-dao-impl">
					<xsl:with-param name="daoname" select="$daoname"/>
					<xsl:with-param name="paramclass" select="'Connection'"/>
					<xsl:with-param name="paramname" select="'conn'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$fc/@pm = 'true' or $fc/@direct = 'true' and $paramclass = 'PersistenceManager'">
				<xsl:call-template name="method-create-dao-impl">
					<xsl:with-param name="daoname" select="$daoname"/>
					<xsl:with-param name="paramclass" select="'PersistenceManager'"/>
					<xsl:with-param name="paramname" select="'pm'"/>
				</xsl:call-template>
			</xsl:if>

		</xsl:for-each>
		<xsl:text>
    }</xsl:text>
	</xsl:template>


	<xsl:template name="method-create-dao-impl">
		<xsl:param name="daoname"/>
		<xsl:param name="paramclass"/>
		<xsl:param name="paramname"/>

		<xsl:text>
        public abstract </xsl:text>
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
		<xsl:text>);
</xsl:text>
	</xsl:template>


</xsl:stylesheet>
