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
	xmlns:msg="http://www.spoledge.com/audao/xsl/messages"
>

	<xsl:param name="lang" select="'en'"/>

	<xsl:template name="error">
		<xsl:param name="errcode"/>
		<xsl:param name="detail"/>
		<xsl:param name="table" select="."/>
		<xsl:param name="tablename" select="$table/@name"/>
		<xsl:param name="col"/>
		<xsl:param name="colname"/>
		<xsl:param name="coltype" select="'COLUMN'"/>

		<xsl:message terminate="yes">
			<xsl:call-template name="message">
				<xsl:with-param name="errcode" select="$errcode"/>
				<xsl:with-param name="detail" select="$detail"/>
				<xsl:with-param name="table" select="$table"/>
				<xsl:with-param name="tablename" select="$tablename"/>
				<xsl:with-param name="col" select="$col"/>
				<xsl:with-param name="colname" select="$colname"/>
				<xsl:with-param name="coltype" select="$coltype"/>
			</xsl:call-template>
		</xsl:message>
	</xsl:template>


	<xsl:template name="warning">
		<xsl:param name="errcode"/>
		<xsl:param name="detail"/>
		<xsl:param name="table" select="."/>
		<xsl:param name="tablename" select="$table/@name"/>
		<xsl:param name="col"/>
		<xsl:param name="colname"/>
		<xsl:param name="coltype" select="'COLUMN'"/>

		<xsl:message>
			<xsl:call-template name="message">
				<xsl:with-param name="errcode" select="$errcode"/>
				<xsl:with-param name="detail" select="$detail"/>
				<xsl:with-param name="table" select="$table"/>
				<xsl:with-param name="tablename" select="$tablename"/>
				<xsl:with-param name="col" select="$col"/>
				<xsl:with-param name="colname" select="$colname"/>
				<xsl:with-param name="coltype" select="$coltype"/>
			</xsl:call-template>
		</xsl:message>
	</xsl:template>


	<xsl:template name="message">
		<xsl:param name="errcode"/>
		<xsl:param name="detail"/>
		<xsl:param name="table" select="."/>
		<xsl:param name="tablename" select="$table/@name"/>
		<xsl:param name="col"/>
		<xsl:param name="colname"/>
		<xsl:param name="coltype" select="'COLUMN'"/>

		<xsl:call-template name="message-word">
			<xsl:with-param name="name" select="'ERROR'"/>
		</xsl:call-template>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="$errcode"/>
		<xsl:text>): </xsl:text>
		<xsl:call-template name="message-error">
			<xsl:with-param name="errcode" select="$errcode"/>
		</xsl:call-template>
		<xsl:text>.
</xsl:text>
		<xsl:if test="$detail">
			<xsl:call-template name="message-word">
				<xsl:with-param name="name" select="'DETAIL'"/>
			</xsl:call-template>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="$detail"/>
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:call-template name="message-word">
			<xsl:with-param name="name" select="'LOCATION'"/>
		</xsl:call-template>
		<xsl:text>: </xsl:text>
		<xsl:choose>
			<xsl:when test="local-name($table) = 'view'">
				<xsl:call-template name="message-word">
					<xsl:with-param name="name" select="'VIEW'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="message-word">
					<xsl:with-param name="name" select="'TABLE'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> '</xsl:text>
		<xsl:value-of select="$tablename"/>
		<xsl:text>'</xsl:text>
		<xsl:if test="$colname or $col or $coltype != 'COLUMN'">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="message-word">
				<xsl:with-param name="name" select="$coltype"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="$colname">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="$colname"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
				<xsl:when test="$col and $col/@name">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="$col/@name"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
				<xsl:when test="$coltype = 'METHOD' and $col and $col/@name">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="$col/@name"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
				<xsl:when test="$coltype = 'METHOD' and $col">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="local-name($col)"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
				<xsl:when test="$coltype = 'METHOD' and @name">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
				<xsl:when test="$coltype = 'METHOD'">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="local-name()"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	<xsl:template name="message-word">
		<xsl:param name="name"/>

		<xsl:variable name="docpath">
			<xsl:call-template name="message-docpath">
				<xsl:with-param name="l" select="$lang"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="doc" select="document($docpath)/msg:messages"/>
		<xsl:variable name="word" select="$doc/msg:words/msg:word[@name=$name]"/>

		<xsl:choose>
			<xsl:when test="$word">
				<xsl:value-of select="$word"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="docpath2">
					<xsl:call-template name="message-docpath"/>
				</xsl:variable>
				<xsl:variable name="doc2" select="document($docpath2)/msg:messages"/>
				<xsl:value-of select="$doc2/msg:words/msg:word[@name=$name]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="message-error">
		<xsl:param name="errcode"/>

		<xsl:variable name="docpath">
			<xsl:call-template name="message-docpath">
				<xsl:with-param name="l" select="$lang"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="doc" select="document($docpath)/msg:messages"/>
		<xsl:variable name="word" select="$doc/msg:errors/msg:error[@errcode=$errcode]"/>

		<xsl:choose>
			<xsl:when test="$word">
				<xsl:value-of select="$word"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="docpath2">
					<xsl:call-template name="message-docpath"/>
				</xsl:variable>
				<xsl:variable name="doc2" select="document($docpath2)/msg:messages"/>
				<xsl:value-of select="$doc2/msg:errors/msg:error[@errcode=$errcode]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="message-docpath">
		<xsl:param name="l" select="'en'"/>
		<xsl:text>messages@DIR_SEP@</xsl:text>
		<xsl:value-of select="$l"/>
		<xsl:text>.xml</xsl:text>
	</xsl:template>

</xsl:stylesheet>

