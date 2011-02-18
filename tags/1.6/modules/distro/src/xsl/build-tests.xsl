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
	xmlns:ex="http://www.spoledge.com/audao/distro/tests"
	xmlns:ant="ant"
	exclude-result-prefixes="ex ant"
>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
		omit-xml-declaration="yes"
	/>

	<xsl:namespace-alias
		stylesheet-prefix="ant"
		result-prefix="#default"
	/>

	<xsl:template match="/">
		<ant:project name="tests" default="dist" basedir="..">
			<ant:import>
				<xsl:attribute name="file">${audao.home}/tools/build-audao-gae.xml</xsl:attribute>
			</ant:import>
			<xsl:call-template name="properties"/>
			<xsl:call-template name="paths"/>

			<ant:target name="dist">
				<xsl:apply-templates select="ex:tests/ex:test/ex:audao"/>
			</ant:target>

			<xsl:call-template name="target-audao"/>
		</ant:project>
	</xsl:template>


	<xsl:template match="ex:audao">
		<ant:antcall target="audao">
			<ant:param>
				<xsl:attribute name="name">audao-src-name</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="../@name"/>
				</xsl:attribute>
			</ant:param>
			<ant:param>
				<xsl:attribute name="name">audao-dbtype</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="@dbtype"/>
				</xsl:attribute>
			</ant:param>

			<ant:param>
				<xsl:attribute name="name">audao-package</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="@package"/>
				</xsl:attribute>
			</ant:param>

			<ant:param>
				<xsl:attribute name="name">audao-packagedir</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="translate(@package, '.', '/')"/>
				</xsl:attribute>
			</ant:param>

			<ant:param>
				<xsl:attribute name="name">audao-label</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="../ex:label"/>
				</xsl:attribute>
			</ant:param>
			<xsl:if test="@dto-gwt-ser='true'">
				<ant:param>
					<xsl:attribute name="name">audao-dto-gwt-serializer</xsl:attribute>
					<xsl:attribute name="value">true</xsl:attribute>
				</ant:param>
			</xsl:if>
		</ant:antcall>
	</xsl:template>


	<xsl:template name="properties">
		<ant:property name="src.dir" location="src"/>
		<ant:property>
			<xsl:attribute name="name">tests.dir</xsl:attribute>
			<xsl:attribute name="location">${src.dir}/db-test</xsl:attribute>
		</ant:property>

		<ant:property name="build.dir" location="build"/>
		<ant:property>
			<xsl:attribute name="name">build.tests.dir</xsl:attribute>
			<xsl:attribute name="location">${build.dir}/tests</xsl:attribute>
		</ant:property>
	</xsl:template>


	<xsl:template name="paths">
	</xsl:template>


	<xsl:template name="target-audao">
		<ant:target name="audao">

			<ant:property>
				<xsl:attribute name="name">audao-xml</xsl:attribute>
				<xsl:attribute name="location">
					<xsl:text>${tests.dir}/${audao-src-name}.xml</xsl:text>
				</xsl:attribute>
			</ant:property>

			<ant:property>
				<xsl:attribute name="name">audao-name</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:text>${audao-src-name}-${audao-dbtype}</xsl:text>
				</xsl:attribute>
			</ant:property>

			<ant:property>
				<xsl:attribute name="name">audao-jar</xsl:attribute>
				<xsl:attribute name="location">
					<xsl:text>${build.tests.dir}/${audao-name}/${audao-name}.jar</xsl:text>
				</xsl:attribute>
			</ant:property>

			<ant:property>
				<xsl:attribute name="name">audao-gen-dir</xsl:attribute>
				<xsl:attribute name="location">
					<xsl:text>${build.tests.dir}/${audao-name}</xsl:text>
				</xsl:attribute>
			</ant:property>

			<ant:antcall target="audao-jar"/>

		</ant:target>


	</xsl:template>

</xsl:stylesheet>

