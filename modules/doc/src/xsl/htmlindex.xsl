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
	xmlns:frg="http://www.spoledge.com/audao/doc/fragments"
	>

	<xsl:import href="htmlfrag.xsl"/>

	<xsl:output
		method="xml"
		indent="yes"
		encoding="utf-8"
		omit-xml-declaration="yes"
	/>

	<xsl:param name="fragments_dir"/>
	<xsl:param name="prefix"/>
	<xsl:param name="extension"/>


	<xsl:template match="/">
		<xsl:apply-templates select="frg:fragments"/>
	</xsl:template>


	<xsl:template match="frg:fragments">
		<div class="chapter">
			<h1>Contents</h1>
			<div class="doc-contents">
				<ol>
					<xsl:for-each select="frg:fragment">
						<xsl:variable name="no" select="position()"/>
						<xsl:variable name="path" select="concat($fragments_dir, concat('/', concat(@name,'.html')))"/>
						<xsl:variable name="ctx" select="document($path)"/>
						<xsl:variable name="pprefix">
							<xsl:value-of select="$prefix"/>
							<xsl:value-of select="@name"/>
							<xsl:value-of select="$extension"/>
						</xsl:variable>

						<xsl:call-template name="contents-value">
							<xsl:with-param name="ctx" select="$ctx/div"/>
							<xsl:with-param name="no" select="$no"/>
							<xsl:with-param name="prefix" select="$pprefix"/>
						</xsl:call-template>

						<xsl:for-each select="$ctx/div">
							<xsl:call-template name="reccontents">
								<xsl:with-param name="no" select="$no"/>
								<xsl:with-param name="prefix" select="$pprefix"/>
							</xsl:call-template>
						</xsl:for-each>

					</xsl:for-each>
				</ol>
			</div>
		</div>
	</xsl:template>


</xsl:stylesheet>

