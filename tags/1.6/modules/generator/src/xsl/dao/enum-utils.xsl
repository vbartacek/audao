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

	<xsl:template name="enums-import">
		<xsl:for-each select="db:columns/db:column[db:enum and db:ref]">
			<xsl:text>import </xsl:text>
			<xsl:value-of select="$pkg_dto"/>
			<xsl:text>.</xsl:text>
			<xsl:call-template name="column-EnumType-dto"/>
			<xsl:text>;
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="enums-def">
		<xsl:for-each select="db:columns/db:column[db:enum and not(db:ref)]">
			<xsl:text>
    public enum </xsl:text>
			<xsl:call-template name="column-EnumType-short"/>
			<xsl:text> {
</xsl:text>
			<xsl:variable name="hasid" select="count(db:enum/db:value[@id])"/>
			<xsl:variable name="hasdb" select="count(db:enum/db:value[@db])"/>
			<xsl:for-each select="db:enum/db:value">
				<xsl:text>        </xsl:text>
				<xsl:value-of select="."/>
				<xsl:if test="$hasid or $hasdb">
					<xsl:text>( </xsl:text>
					<xsl:if test="../../db:type = 'short'">
						<xsl:text>(short) </xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="@db and ../../db:type = 'String'">
							<xsl:text>"</xsl:text>
							<xsl:value-of select="@db"/>
							<xsl:text>"</xsl:text>
						</xsl:when>
						<xsl:when test="../../db:type = 'String'">
							<xsl:text>"</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>"</xsl:text>
						</xsl:when>
						<xsl:when test="@id">
							<xsl:value-of select="@id"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="position()"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> )</xsl:text>
				</xsl:if>
				<xsl:if test="position()!=last()">
					<xsl:text>,
</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="$hasid or $hasdb">
				<xsl:text>;

        private </xsl:text>
				<xsl:value-of select="db:type"/>
				<xsl:text> id;

        </xsl:text>
				<xsl:call-template name="column-EnumType-short"/>
				<xsl:text>( </xsl:text>
				<xsl:value-of select="db:type"/>
				<xsl:text> _id ) {
            this.id = _id;
        }

        public </xsl:text>
				<xsl:value-of select="db:type"/>
				<xsl:text> getId() {
            return id;
        }</xsl:text>
			</xsl:if>
			<xsl:text>
    }
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="enums-mapping">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="processed" select="'|'"/>
		<xsl:param name="pos" select="1"/>

		<xsl:for-each select="$ctx/db:columns/db:column[db:enum and (db:type != 'String' or db:enum/db:value/@db)][$pos]">
			<xsl:variable name="key">
				<xsl:choose>
					<xsl:when test="db:enum/@orig-table">
						<xsl:value-of select="db:enum/@orig-table"/>
						<xsl:text>@</xsl:text>
						<xsl:value-of select="db:enum/@orig-column"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="../../@name"/>
						<xsl:text>@</xsl:text>
						<xsl:value-of select="@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not(contains($processed, concat('|', concat( $key, '|'))))">
				<xsl:text>    private static final </xsl:text>
				<xsl:choose>
					<xsl:when test="db:enum/db:value[@id or @db]">
						<xsl:call-template name="enum-mapping-hash"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="enum-mapping-array"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:call-template name="enums-mapping">
				<xsl:with-param name="ctx" select="$ctx"/>
				<xsl:with-param name="processed" select="concat($processed, concat($key, '|'))"/>
				<xsl:with-param name="pos" select="$pos + 1"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="enum-mapping-hash">
		<xsl:call-template name="enum-mapping-hash-type"/>
		<xsl:text> </xsl:text>
		<xsl:call-template name="enum-hasharr-var"/>
		<xsl:text> = new </xsl:text>
		<xsl:call-template name="enum-mapping-hash-type"/>
		<xsl:text>();

    static {
</xsl:text>
		<xsl:variable name="var">
			<xsl:call-template name="enum-hasharr-var"/>
		</xsl:variable>
		<xsl:variable name="pref">
			<xsl:call-template name="column-EnumType"/>
			<xsl:text>.</xsl:text>
		</xsl:variable>
		<xsl:for-each select="db:enum/db:value">
			<xsl:text>        </xsl:text>
			<xsl:value-of select="$var"/>
			<xsl:text>.put( </xsl:text>
			<xsl:value-of select="concat($pref,.)"/>
			<xsl:text>.getId(), </xsl:text>
			<xsl:value-of select="concat($pref,.)"/>
			<xsl:text>);
</xsl:text>
		</xsl:for-each>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="enum-mapping-hash-type">
		<xsl:text>HashMap&lt;</xsl:text>
		<xsl:call-template name="column-ObjectType-raw"/>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="column-EnumType"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>


	<xsl:template name="enum-mapping-array">
		<xsl:call-template name="column-EnumType"/>
		<xsl:text>[] </xsl:text>
		<xsl:call-template name="enum-hasharr-var"/>
		<xsl:text> = { null</xsl:text>
		<xsl:variable name="pref">
			<xsl:call-template name="column-EnumType"/>
			<xsl:text>.</xsl:text>
		</xsl:variable>
		<xsl:for-each select="db:enum/db:value">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$pref"/>
			<xsl:value-of select="."/>
		</xsl:for-each>
		<xsl:text> };
</xsl:text>
	</xsl:template>


	<xsl:template name="enum-get-by-id">
		<xsl:param name="id"/>
		<xsl:choose>
			<xsl:when test="db:enum/db:value[@id or @db]">
				<xsl:call-template name="enum-hasharr-var"/>
				<xsl:text>.get( </xsl:text>
				<xsl:value-of select="$id"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="db:enum and db:type = 'String'">
				<xsl:call-template name="column-EnumType"/>
				<xsl:text>.valueOf( </xsl:text>
				<xsl:value-of select="$id"/>
				<xsl:text> )</xsl:text>
			</xsl:when>
			<xsl:when test="db:enum">
				<xsl:call-template name="enum-hasharr-var"/>
				<xsl:text>[ </xsl:text>
				<xsl:value-of select="$id"/>
				<xsl:text> ]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$id"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="enum-to-raw">
		<xsl:param name="val"/>
		<xsl:param name="notnull"/>
		<xsl:choose>
			<xsl:when test="$notnull=1 and db:enum/db:value[@id or @db]">
				<xsl:value-of select="$val"/>
				<xsl:text>.getId()</xsl:text>
			</xsl:when>
			<xsl:when test="db:enum/db:value[@id or @db]">
				<xsl:value-of select="$val"/>
				<xsl:text> != null ? </xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>.getId() : null</xsl:text>
			</xsl:when>
			<xsl:when test="$notnull=1 and db:enum and db:type='String'">
				<xsl:value-of select="$val"/>
				<xsl:text>.name()</xsl:text>
			</xsl:when>
			<xsl:when test="$notnull=1 and db:enum">
				<xsl:value-of select="$val"/>
				<xsl:text>.ordinal() + 1</xsl:text>
			</xsl:when>
			<xsl:when test="db:enum and db:type='String'">
				<xsl:value-of select="$val"/>
				<xsl:text> != null ? </xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>.name()</xsl:text>
				<xsl:text> : null</xsl:text>
			</xsl:when>
			<xsl:when test="db:enum">
				<xsl:value-of select="$val"/>
				<xsl:text> != null ? </xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text>.ordinal() + 1</xsl:text>
				<xsl:text> : null</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$val"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="enum-hasharr-var">
		<xsl:variable name="type">
			<xsl:call-template name="column-EnumType"/>
		</xsl:variable>
		<xsl:text>_</xsl:text>
		<xsl:value-of select="translate($type, '.', '_')"/>
		<xsl:text>s</xsl:text>
	</xsl:template>

</xsl:stylesheet>
