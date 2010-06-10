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
	xmlns:ex="http://www.spoledge.com/audao/doc/examples"
	xmlns:ant="ant"
	exclude-result-prefixes="ex ant"
>

	<xsl:import href="htmlfrag.xsl"/>

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

	<xsl:param name="examples_xml"/>

	<xsl:template match="/">
		<ant:project name="examples" default="dist" basedir="..">
			<ant:import file="../../distro/conf/build-audao-gae.xml"/>
			<xsl:call-template name="properties"/>
			<xsl:call-template name="paths"/>

			<ant:target name="dist">
				<ant:uptodate>
					<xsl:attribute name="property">javadoc-static.present</xsl:attribute>
					<xsl:attribute name="targetfile">${build.examples.dir}/javadoc/audao/index.html</xsl:attribute>
					<ant:srcfiles dir="../generator/src/java" includes="**/*.java"/>
					<ant:srcfiles dir="../parser/src/java" includes="**/*.java"/>
				</ant:uptodate>
				<ant:antcall target="javadoc-static"/>

				<xsl:apply-templates select="ex:examples/ex:example/ex:audao"/>
			</ant:target>

			<xsl:call-template name="target-audao"/>
		</ant:project>
	</xsl:template>


	<xsl:template match="ex:audao">
		<ant:antcall target="audao-example">
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
		</ant:antcall>
	</xsl:template>


	<xsl:template name="properties">
		<ant:property name="src.dir" location="src"/>
		<ant:property>
			<xsl:attribute name="name">examples.dir</xsl:attribute>
			<xsl:attribute name="location">${src.dir}/examples</xsl:attribute>
		</ant:property>

		<ant:property name="build.dir" location="build"/>
		<ant:property>
			<xsl:attribute name="name">build.examples.dir</xsl:attribute>
			<xsl:attribute name="location">${build.dir}/examples</xsl:attribute>
		</ant:property>

		<ant:property>
			<xsl:attribute name="name">build.tmp.dir</xsl:attribute>
			<xsl:attribute name="location">${build.dir}/tmp</xsl:attribute>
		</ant:property>

		<ant:property>
			<xsl:attribute name="name">build.tmp.examples.dir</xsl:attribute>
			<xsl:attribute name="location">${build.tmp.dir}/examples</xsl:attribute>
		</ant:property>
	</xsl:template>


	<xsl:template name="paths">
	</xsl:template>


	<xsl:template name="target-audao">
		<ant:target name="audao-example">

			<ant:property>
				<xsl:attribute name="name">audao-xml</xsl:attribute>
				<xsl:attribute name="location">
					<xsl:text>${examples.dir}/${audao-src-name}.xml</xsl:text>
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
					<xsl:text>${build.examples.dir}/jar/${audao-name}.jar</xsl:text>
				</xsl:attribute>
			</ant:property>

			<ant:property>
				<xsl:attribute name="name">audao-gen-dir</xsl:attribute>
				<xsl:attribute name="location">
					<xsl:text>${build.tmp.examples.dir}/${audao-name}</xsl:text>
				</xsl:attribute>
			</ant:property>

			<ant:uptodate>
				<xsl:attribute name="property">audao-uptodate</xsl:attribute>
				<xsl:attribute name="srcfile">${audao-xml}</xsl:attribute>
				<xsl:attribute name="targetfile">${audao-jar}</xsl:attribute>
			</ant:uptodate>

			<ant:antcall target="audao.impl"/>
		</ant:target>


		<ant:target name="audao.impl" unless="audao-uptodate">
			<ant:antcall target="audao-jar"/>

			<ant:zip>
				<xsl:attribute name="destfile">
					<xsl:text>${build.examples.dir}/dao/${audao-name}.zip</xsl:text>
				</xsl:attribute>
				<ant:fileset>
					<xsl:attribute name="dir">
						<xsl:text>${audao-gen-dir}/dao</xsl:text>
					</xsl:attribute>
				</ant:fileset>
			</ant:zip>

			<ant:javadoc>
				<xsl:attribute name="destdir">${build.examples.dir}/javadoc/${audao-name}</xsl:attribute>
				<xsl:attribute name="windowtitle">${audao-label} - generated by AuDAO (${audao-dbtype})</xsl:attribute>
				<xsl:attribute name="classpathref">audao-default-compile-gae.path</xsl:attribute>
				<xsl:attribute name="nodeprecatedlist">yes</xsl:attribute>
				<xsl:attribute name="noindex">yes</xsl:attribute>
				<xsl:attribute name="nohelp">yes</xsl:attribute>
				<ant:packageset>
					<xsl:attribute name="dir">${audao-gen-dir}/dao</xsl:attribute>
					<ant:include>
						<xsl:attribute name="name">${audao-packagedir}/**</xsl:attribute>
					</ant:include>
				</ant:packageset>
				<ant:doctitle>
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;h1&gt;${audao-label} - generated by AuDAO (${audao-dbtype})&lt;/h1&gt;]]&gt;</xsl:text>
				</ant:doctitle>
				<ant:bottom>
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;i&gt;Copyright &amp;#169; 2010 Spolecne s.r.o. All Rights Reserved.&lt;/i&gt;]]&gt;</xsl:text>
				</ant:bottom>
				<ant:group>
					<xsl:attribute name="title">Database</xsl:attribute>
					<xsl:attribute name="packages">${audao-package}*</xsl:attribute>
				</ant:group>
				<ant:link>
					<xsl:attribute name="href">../audao</xsl:attribute>
				</ant:link>
			</ant:javadoc>

			<ant:condition property="has-sql">
				<ant:not>
					<ant:or>
						<ant:equals>
							<xsl:attribute name="arg1">gae</xsl:attribute>
							<xsl:attribute name="arg2">${audao-dbtype}</xsl:attribute>
						</ant:equals>
						<ant:equals>
							<xsl:attribute name="arg1">gaejdo</xsl:attribute>
							<xsl:attribute name="arg2">${audao-dbtype}</xsl:attribute>
						</ant:equals>
					</ant:or>
				</ant:not>
			</ant:condition>

			<ant:antcall target="copy-sql"/>

		</ant:target>


		<ant:target name="copy-sql" if="has-sql">
			<ant:mkdir>
				<xsl:attribute name="dir">
					<xsl:text>${build.examples.dir}/sql/${audao-name}</xsl:text>
				</xsl:attribute>
			</ant:mkdir>
			<ant:copy>
				<xsl:attribute name="todir">
					<xsl:text>${build.examples.dir}/sql/${audao-name}</xsl:text>
				</xsl:attribute>
				<ant:fileset>
					<xsl:attribute name="dir">
						<xsl:text>${build.tmp.examples.dir}/${audao-name}/sql</xsl:text>
					</xsl:attribute>
				</ant:fileset>
			</ant:copy>
		</ant:target>


		<ant:target name="javadoc-static" unless="javadoc-static.present">
			<ant:javadoc>
				<xsl:attribute name="destdir">${build.examples.dir}/javadoc/audao</xsl:attribute>
				<xsl:attribute name="windowtitle">AuDAO Base Classes</xsl:attribute>
				<ant:packageset>
					<xsl:attribute name="dir">../generator/src/java</xsl:attribute>
				</ant:packageset>
				<ant:packageset>
					<xsl:attribute name="dir">../parser/src/java</xsl:attribute>
					<!--
					<xsl:attribute name="includes">com/spoledge/audao/parser/gql</xsl:attribute>
					-->
				</ant:packageset>
				<ant:doctitle>
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;h1&gt;AuDAO Base Classes&lt;/h1&gt;]]&gt;</xsl:text>
				</ant:doctitle>
				<ant:bottom>
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;i&gt;Copyright &amp;#169; 2010 Spolecne s.r.o. All Rights Reserved.&lt;/i&gt;]]&gt;</xsl:text>
				</ant:bottom>
				<ant:group>
					<xsl:attribute name="title">AuDAO Runtime</xsl:attribute>
					<xsl:attribute name="packages">com.spoledge.audao.db*</xsl:attribute>
				</ant:group>
				<ant:group>
					<xsl:attribute name="title">AuDAO - GQL and GQLExt Parser</xsl:attribute>
					<xsl:attribute name="packages">com.spoledge.audao.parser*</xsl:attribute>
				</ant:group>
			</ant:javadoc>
		</ant:target>

	</xsl:template>

</xsl:stylesheet>

