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
		method="xml"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="db_type"/>
	<xsl:param name="has_own_dto"/>
	<xsl:param name="has_own_dto_impl"/>
	<xsl:param name="has_own_dao"/>
	<xsl:param name="has_own_dao_impl"/>
	<xsl:param name="has_own_factory"/>
	<xsl:param name="has_own_factory_impl"/>

	<xsl:variable name="pkg_dao" select="concat($pkg_db,'.dao')"/>
	<xsl:variable name="pkg_dao_impl" select="concat(concat($pkg_dao,'.'),$db_type)"/>
	<xsl:variable name="pkg_dto" select="concat($pkg_db,'.dto')"/>
	<xsl:variable name="pkg_dto_impl" select="concat(concat($pkg_dto,'.'),$db_type)"/>

	<xsl:variable name="dir_dao" select="translate($pkg_dao, '.', '/')"/>
	<xsl:variable name="dir_dao_impl" select="translate($pkg_dao_impl, '.', '/')"/>
	<xsl:variable name="dir_dto" select="translate($pkg_dto, '.', '/')"/>
	<xsl:variable name="dir_dto_impl" select="translate($pkg_dto_impl, '.', '/')"/>

	<xsl:template match="db:database">
		<xsl:element name="project">
			<xsl:attribute name="name">dao</xsl:attribute>
			<xsl:attribute name="basedir">../..</xsl:attribute>
			<xsl:attribute name="default">dist</xsl:attribute>
			<xsl:element name="target">
				<xsl:attribute name="name">dist</xsl:attribute>
				<xsl:attribute name="description">Generates DAO</xsl:attribute>

				<xsl:element name="mkdir">
					<xsl:attribute name="dir">
						<xsl:text>${build.dao.dir}/</xsl:text>
						<xsl:value-of select="$dir_dao"/>
					</xsl:attribute>
				</xsl:element>

				<xsl:element name="mkdir">
					<xsl:attribute name="dir">
						<xsl:text>${build.dao.dir}/</xsl:text>
						<xsl:value-of select="$dir_dao_impl"/>
					</xsl:attribute>
				</xsl:element>

				<xsl:element name="mkdir">
					<xsl:attribute name="dir">
						<xsl:text>${build.dao.dir}/</xsl:text>
						<xsl:value-of select="$dir_dto"/>
					</xsl:attribute>
				</xsl:element>

				<xsl:element name="xslt">
					<xsl:attribute name="style">
						<xsl:call-template name="has-own-template">
							<xsl:with-param name="name" select="'factory'"/>
							<xsl:with-param name="istrue" select="$has_own_factory"/>
						</xsl:call-template>
					</xsl:attribute>
					<xsl:attribute name="in">${build.db.xml}</xsl:attribute>
					<xsl:attribute name="out">
						<xsl:text>${build.dao.dir}/</xsl:text>
						<xsl:value-of select="$dir_dao"/>
						<xsl:text>/DaoFactory.java</xsl:text>
					</xsl:attribute>
					<xsl:element name="param">
						<xsl:attribute name="name">pkg_db</xsl:attribute>
						<xsl:attribute name="expression">
							<xsl:value-of select="$pkg_db"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="param">
						<xsl:attribute name="name">db_type</xsl:attribute>
						<xsl:attribute name="expression">
							<xsl:value-of select="$db_type"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>

				<xsl:element name="xslt">
					<xsl:attribute name="style">
						<xsl:call-template name="has-own-template">
							<xsl:with-param name="name" select="'factory-impl'"/>
							<xsl:with-param name="istrue" select="$has_own_factory_impl"/>
						</xsl:call-template>
					</xsl:attribute>
					<xsl:attribute name="in">${build.db.xml}</xsl:attribute>
					<xsl:attribute name="out">
						<xsl:text>${build.dao.dir}/</xsl:text>
						<xsl:value-of select="$dir_dao_impl"/>
						<xsl:text>/DaoFactoryImpl.java</xsl:text>
					</xsl:attribute>
					<xsl:element name="param">
						<xsl:attribute name="name">pkg_db</xsl:attribute>
						<xsl:attribute name="expression">
							<xsl:value-of select="$pkg_db"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="param">
						<xsl:attribute name="name">db_type</xsl:attribute>
						<xsl:attribute name="expression">
							<xsl:value-of select="$db_type"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>

				<xsl:apply-templates select="db:tables/db:table"/>
				<xsl:apply-templates select="db:views/db:view"/>

			</xsl:element>
		</xsl:element>
	</xsl:template>


	<xsl:template match="db:table|db:view">
		<xsl:variable name="dtoname">
			<xsl:call-template name="java-Name"/>
		</xsl:variable>
		<xsl:variable name="daoname" select="concat($dtoname,'Dao')"/>
		<xsl:variable name="daoimpl" select="concat($daoname,'Impl')"/>

		<xsl:element name="xslt">
			<xsl:attribute name="style">
				<xsl:call-template name="has-own-template">
					<xsl:with-param name="name" select="'dao'"/>
					<xsl:with-param name="istrue" select="$has_own_dao"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="in">${build.db.xml}</xsl:attribute>
			<xsl:attribute name="out">
				<xsl:text>${build.dao.dir}/</xsl:text>
				<xsl:value-of select="$dir_dao"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$daoname"/>
				<xsl:text>.java</xsl:text>
			</xsl:attribute>
			<xsl:element name="param">
				<xsl:attribute name="name">pkg_db</xsl:attribute>
				<xsl:attribute name="expression">
					<xsl:value-of select="$pkg_db"/>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="param">
				<xsl:attribute name="name">table_name</xsl:attribute>
				<xsl:attribute name="expression">
					<xsl:value-of select="@name"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>

		<xsl:if test="not(@use-dto) or @use-dto = @name">

			<xsl:element name="xslt">
				<xsl:attribute name="style">
					<xsl:call-template name="has-own-template">
						<xsl:with-param name="name" select="'dto'"/>
						<xsl:with-param name="istrue" select="$has_own_dto"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="in">${build.db.xml}</xsl:attribute>
				<xsl:attribute name="out">
					<xsl:text>${build.dao.dir}/</xsl:text>
					<xsl:value-of select="$dir_dto"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$dtoname"/>
					<xsl:text>.java</xsl:text>
				</xsl:attribute>
				<xsl:element name="param">
					<xsl:attribute name="name">pkg_db</xsl:attribute>
					<xsl:attribute name="expression">
						<xsl:value-of select="$pkg_db"/>
					</xsl:attribute>
				</xsl:element>
				<xsl:element name="param">
					<xsl:attribute name="name">table_name</xsl:attribute>
					<xsl:attribute name="expression">
						<xsl:value-of select="@name"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:element>

			<xsl:if test="$has_own_dto_impl='true'">
				<xsl:element name="xslt">
					<xsl:attribute name="style">
						<xsl:call-template name="has-own-template">
							<xsl:with-param name="name" select="'dto-impl'"/>
							<xsl:with-param name="istrue" select="$has_own_dto_impl"/>
						</xsl:call-template>
					</xsl:attribute>
					<xsl:attribute name="in">${build.db.xml}</xsl:attribute>
					<xsl:attribute name="out">
						<xsl:text>${build.dao.dir}/</xsl:text>
						<xsl:value-of select="$dir_dto_impl"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$dtoname"/>
						<xsl:text>Impl.java</xsl:text>
					</xsl:attribute>
					<xsl:element name="param">
						<xsl:attribute name="name">pkg_db</xsl:attribute>
						<xsl:attribute name="expression">
							<xsl:value-of select="$pkg_db"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="param">
						<xsl:attribute name="name">table_name</xsl:attribute>
						<xsl:attribute name="expression">
							<xsl:value-of select="@name"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>
			</xsl:if>

		</xsl:if>

		<xsl:element name="xslt">
			<xsl:attribute name="style">
				<xsl:call-template name="has-own-template">
					<xsl:with-param name="name" select="'dao-impl'"/>
					<xsl:with-param name="istrue" select="$has_own_dao_impl"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="in">${build.db.xml}</xsl:attribute>
			<xsl:attribute name="out">
				<xsl:text>${build.dao.dir}/</xsl:text>
				<xsl:value-of select="$dir_dao_impl"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$daoimpl"/>
				<xsl:text>.java</xsl:text>
			</xsl:attribute>
			<xsl:element name="param">
				<xsl:attribute name="name">pkg_db</xsl:attribute>
				<xsl:attribute name="expression">
					<xsl:value-of select="$pkg_db"/>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="param">
				<xsl:attribute name="name">db_type</xsl:attribute>
				<xsl:attribute name="expression">
					<xsl:value-of select="$db_type"/>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="param">
				<xsl:attribute name="name">table_name</xsl:attribute>
				<xsl:attribute name="expression">
					<xsl:value-of select="@name"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>

	</xsl:template>


	<xsl:template name="has-own-template">
		<xsl:param name="name"/>
		<xsl:param name="istrue"/>
		<xsl:text>${build.xsl.dao.dir}/</xsl:text>
		<xsl:if test="$istrue = 'true'">
			<xsl:text>${db.type}/</xsl:text>
		</xsl:if>
		<xsl:value-of select="$name"/>
		<xsl:text>.xsl</xsl:text>
	</xsl:template>

</xsl:stylesheet>
