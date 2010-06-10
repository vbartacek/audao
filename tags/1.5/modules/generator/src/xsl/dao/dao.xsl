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
	<xsl:import href="enum-utils.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="table_name"/>

	<xsl:variable name="daoctx" select="/db:database/*/*[@name=$table_name]"/>
	<xsl:variable name="keycol" select="$daoctx/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

	<xsl:variable name="dao_root">
		<xsl:call-template name="db-conf-elem">
			<xsl:with-param name="ctx" select="$daoctx"/>
			<xsl:with-param name="type" select="'dao'"/>
			<xsl:with-param name="elem" select="'root'"/>
		</xsl:call-template>
	</xsl:variable>


	<xsl:template match="db:database">
		<xsl:apply-templates select="$daoctx"/>
	</xsl:template>


	<xsl:template match="db:table|db:view">
		<xsl:call-template name="file-header"/>
		<xsl:text>package </xsl:text>
		<xsl:value-of select="$pkg_dao"/>
		<xsl:text>;
</xsl:text>
		<xsl:if test="db:columns/db:column[db:type = 'Serializable' and not(db:type/@class)]">
			<xsl:text>
import java.io.Serializable;
</xsl:text>
		</xsl:if>
		<xsl:call-template name="imports-java-dates"/>
		<xsl:if test="db:columns/db:column[db:type = 'List'] or db:methods//db:params/*[@list='true']">
			<xsl:text>
import java.util.List;
</xsl:text>
		</xsl:if>
		<xsl:call-template name="dbutil-imports-gae-types"/>
		<xsl:text>
</xsl:text>
		<xsl:if test="not(@extends) and $dao_root=''">
			<xsl:text>import com.spoledge.audao.db.dao.AbstractDao;
</xsl:text>
		</xsl:if>
		<xsl:text>import com.spoledge.audao.db.dao.DaoException;
</xsl:text>
		<xsl:if test="not(@generic)">
			<xsl:text>
import </xsl:text>
			<xsl:value-of select="$pkg_dto"/>
			<xsl:text>.</xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text>;
</xsl:text>
		</xsl:if>
		<xsl:call-template name="dbutil-imports-embed"/>
		<xsl:call-template name="enums-import"/>
		<xsl:text>

/**
 * This is the DAO.
 *
 * @author generated
 */
public interface </xsl:text>
		<xsl:call-template name="dao-name"/>
		<xsl:if test="@generic">
			<xsl:text>&lt;T&gt;</xsl:text>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="@extends">
				<xsl:text> extends </xsl:text>
				<xsl:call-template name="extends-java-Name"/>
				<xsl:text>Dao</xsl:text>

				<xsl:variable name="extname" select="@extends"/>

				<xsl:if test="//db:table[@name=$extname and @generic]">
					<xsl:text>&lt;</xsl:text>
					<xsl:call-template name="dto-name"/>
					<xsl:text>&gt;</xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$dao_root!=''">
				<xsl:text> extends </xsl:text>
				<xsl:value-of select="$dao_root"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text> extends AbstractDao</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text> {
</xsl:text>
		<xsl:call-template name="dao-methods"/>
		<xsl:text>
}
</xsl:text>
	</xsl:template>

	<xsl:template match="db:methods">
		<xsl:for-each select="db:count">
			<xsl:call-template name="msign-counter"/>
			<xsl:call-template name="mbody-counter"/>
		</xsl:for-each>
		<xsl:for-each select="db:find">
			<xsl:call-template name="msign-finder"/>
			<xsl:call-template name="mbody-finder"/>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="../db:read-only and (db:update or db:delete or db:move)">
				<xsl:message terminate="yes">
					The table <xsl:value-of select="../@name"/> is flagged as read-only, but update/delete/move methods are also declared.
				</xsl:message>
			</xsl:when>
		</xsl:choose>
		<xsl:for-each select="db:update">
			<xsl:call-template name="msign-update-batch"/>
			<xsl:call-template name="mbody-update-batch"/>
		</xsl:for-each>
		<xsl:for-each select="db:delete">
			<xsl:call-template name="msign-delete"/>
			<xsl:call-template name="mbody-delete"/>
		</xsl:for-each>
		<xsl:for-each select="db:truncate[1]">
			<xsl:call-template name="msign-truncate"/>
			<xsl:call-template name="mbody-truncate"/>
		</xsl:for-each>
		<xsl:for-each select="db:move">
			<xsl:call-template name="msign-mover"/>
			<xsl:call-template name="mbody-mover"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="imports-java-dates">
		<xsl:text>
import java.sql.Date;
import java.sql.Timestamp;
</xsl:text>
	</xsl:template>


	<xsl:template name="dto-name">
		<xsl:variable name="ctx" select="$daoctx"/>
		<xsl:choose>
			<xsl:when test="$ctx/@generic">
				<xsl:text>T</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx/@use-dto">
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name=$ctx/@use-dto]"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="dao-name">
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$daoctx"/>
		</xsl:call-template>
		<xsl:text>Dao</xsl:text>
	</xsl:template>


	<xsl:template name="dao-methods">
		<xsl:if test="not(@abstract='true')">
			<xsl:variable name="getordexpr">
				<xsl:call-template name="db-conf-attr">
					<xsl:with-param name="type" select="'dao'"/>
					<xsl:with-param name="attr" select="'method-get-order-expr'"/>
					<xsl:with-param name="def" select="'false'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$getordexpr='true'">
				<xsl:call-template name="msign-get-order-expr"/>
				<xsl:call-template name="mbody-get-order-expr"/>
			</xsl:if>
		</xsl:if>

		<xsl:call-template name="pk-finders"/>
		<xsl:call-template name="indexed-finders"/>
		<xsl:apply-templates select="db:methods"/>
		<xsl:if test="not(@abstract='true') and not(db:read-only) and not(../db:view)">
			<xsl:call-template name="msign-insert"/>
			<xsl:call-template name="mbody-insert"/>
			<xsl:call-template name="edit-methods"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="msign-get-order-expr">
		<xsl:text>
    /**
     * Returns the expression used for ORDER BY clause.
     * @return the order expression for the given column, for example:
     *           company_name (MySQL)
     *           NLSSORT(company_name, 'NLS_SORT=generic_m') (Oracle)
     */
    public String getOrderExpr( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>.Column col )</xsl:text>
	</xsl:template>


	<xsl:template name="pk-finders">
		<xsl:variable name="isauto">
			<xsl:call-template name="is-auto-find">
				<xsl:with-param name="type" select="'pk'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$isauto=1 and not(db:methods/db:find[db:pk]) and db:columns/db:column[(not(@defined-by) or @defined-by=$table_name) and db:pk]">
			<xsl:call-template name="msign-find-by-pk"/>
			<xsl:call-template name="mbody-find-by-pk"/>
			<xsl:if test="count(db:columns/db:column[db:pk]) &gt; 1">
				<xsl:call-template name="pk-finder"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="pk-finder">
		<xsl:param name="idx" select="1"/>
		<xsl:call-template name="msign-finder-index">
			<xsl:with-param name="idx" select="$idx"/>
			<xsl:with-param name="columns" select="db:columns"/>
			<xsl:with-param name="columnrefs" select="db:columns/db:column[db:pk]"/>
		</xsl:call-template>
		<xsl:call-template name="mbody-finder-index">
			<xsl:with-param name="idx" select="$idx"/>
			<xsl:with-param name="columns" select="db:columns"/>
			<xsl:with-param name="columnrefs" select="db:columns/db:column[db:pk]"/>
		</xsl:call-template>
		<xsl:if test="$idx + 1 &lt; count(db:columns/db:column[db:pk])">
			<xsl:call-template name="pk-finder">
				<xsl:with-param name="idx" select="$idx+1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="indexed-finders">
		<xsl:variable name="isauto">
			<xsl:call-template name="is-auto-find">
				<xsl:with-param name="type" select="'index'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$isauto=1">
			<xsl:for-each select="db:indexes/db:index[not(@inherited-from) and not(db:no-find[not(db:level)])]">
				<xsl:call-template name="indexed-finder"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>


	<xsl:template name="indexed-finder">
		<xsl:param name="idx" select="0"/>
		<xsl:if test="not(db:no-find[db:level/@no = $idx+1])">
			<xsl:call-template name="msign-finder-index">
				<xsl:with-param name="idx" select="$idx"/>
				<xsl:with-param name="columns" select="../../db:columns"/>
				<xsl:with-param name="columnrefs" select="db:columns/db:column"/>
			</xsl:call-template>
			<xsl:call-template name="mbody-finder-index">
				<xsl:with-param name="idx" select="$idx"/>
				<xsl:with-param name="columns" select="../../db:columns"/>
				<xsl:with-param name="columnrefs" select="db:columns/db:column"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$idx + 1 &lt; count(db:columns/db:column)">
			<xsl:call-template name="indexed-finder">
				<xsl:with-param name="idx" select="$idx+1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="msign-find-by-pk">
		<xsl:text>
    /**
     * Finds a record identified by its primary key.
     * @return the record found or null
     */
    public </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> findByPrimaryKey( </xsl:text>
		<xsl:call-template name="pk-params"/>
		<xsl:text> )</xsl:text>
	</xsl:template>


	<xsl:template name="msign-counter">
		<xsl:call-template name="comment-method"/>
		<xsl:text>    public int count</xsl:text>
		<xsl:call-template name="method-name"/>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="msign-finder-params"/>
		<!-- finders do not throw DaoException -->
		<xsl:text> )</xsl:text>
	</xsl:template>


	<xsl:template name="msign-finder">
		<xsl:call-template name="comment-method"/>
		<xsl:text>    public </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:variable name="isunique">
			<xsl:call-template name="is-unique-condition"/>
		</xsl:variable>
		<xsl:if test="not($isunique=1)">
			<xsl:text>[]</xsl:text>
		</xsl:if>
		<xsl:text> find</xsl:text>
		<xsl:call-template name="method-name"/>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="msign-finder-params"/>
		<!-- finders do not throw DaoException -->
		<xsl:text> )</xsl:text>
	</xsl:template>


	<xsl:template name="msign-finder-index">
		<xsl:param name="idx"/>
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:call-template name="comment-method">
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>
    <xsl:text>    public </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:if test="$idx != 0 or not(db:unique)">
			<xsl:text>[]</xsl:text>
		</xsl:if>
		<xsl:text> findBy</xsl:text>

		<xsl:call-template name="name-by-index">
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:text>( </xsl:text>

		<xsl:call-template name="index-param-names">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
			<xsl:with-param name="islist" select="0"/>
		</xsl:call-template>

		<!-- finders do not throw DaoException -->
		<xsl:text> )</xsl:text>
	</xsl:template>


	<xsl:template name="comment-method">
		<xsl:param name="idx" select="0"/>
		<xsl:call-template name="comment-method-start"/>
		<xsl:choose>
			<xsl:when test="db:comment">
				<xsl:value-of select="db:comment"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="local-name()='move'">
						<xsl:text>Moves</xsl:text>
					</xsl:when>
					<xsl:when test="local-name()='truncate'">
						<xsl:text>Truncates all</xsl:text>
					</xsl:when>
					<xsl:when test="local-name()='delete'">
						<xsl:text>Deletes</xsl:text>
					</xsl:when>
					<xsl:when test="local-name()='update'">
						<xsl:text>Updates</xsl:text>
					</xsl:when>
					<xsl:when test="local-name()='count'">
						<xsl:text>Counts</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Finds</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="($idx = 0 and db:unique) or db:pk">
					<xsl:text> a</xsl:text>
				</xsl:if>
				<xsl:text> record</xsl:text>
				<xsl:if test="($idx != 0 or not(db:unique)) and not(db:pk)">
					<xsl:text>s</xsl:text>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="db:pk">
						<xsl:text> identified by its primary key</xsl:text>
					</xsl:when>
					<xsl:when test="db:index">
						<xsl:text> using index </xsl:text>
						<xsl:value-of select="db:index/@name"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="local-name()='move'">
			<xsl:text> to table </xsl:text>
			<xsl:value-of select="@target"/>
		</xsl:if>
		<xsl:if test="db:order-by">
			<xsl:text> ordered by </xsl:text>
			<xsl:for-each select="db:order-by/db:column">
				<xsl:call-template name="comma-if-next"/>
				<xsl:value-of select="@name"/>
				<xsl:if test="@desc = 'true'">
					<xsl:text> desc</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="@limit">
			<xsl:text>.
     * The result is limited to the first </xsl:text>
			<xsl:value-of select="@limit"/>
			<xsl:text> records</xsl:text>
		</xsl:if>
		<xsl:text>.
</xsl:text>
		<xsl:for-each select=".//db:params/*[db:comment]">
			<xsl:text>     * @param </xsl:text>
			<xsl:call-template name="param-name"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="db:comment"/>
			<xsl:text>
</xsl:text>
		</xsl:for-each>
		<xsl:if test="local-name()='delete'">
			<xsl:choose>
				<xsl:when test="db:pk or db:unique">
					<xsl:text>     * @return true iff the record was really deleted (existed)
</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>     * @return the number of records deleted
</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:call-template name="comment-method-end"/>
	</xsl:template>


	<xsl:template name="msign-finder-params">
		<xsl:param name="commafirst"/>
		<xsl:variable name="begin">
			<xsl:if test="$commafirst">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="db:all"/>
			<xsl:when test="db:dynamic and (local-name() = 'count' or local-name() = 'update' or local-name() ='delete')">
				<xsl:value-of select="$begin"/>
    		<xsl:text> String cond, Object... params</xsl:text>
			</xsl:when>
			<xsl:when test="db:dynamic">
				<xsl:value-of select="$begin"/>
    		<xsl:text> String cond, int offset, int count, Object... params</xsl:text>
			</xsl:when>
			<xsl:when test="db:index">
				<xsl:call-template name="msign-finder-params-index">
					<xsl:with-param name="begin" select="$begin"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="db:condition">
				<xsl:call-template name="msign-finder-params-condition">
					<xsl:with-param name="begin" select="$begin"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="db:ref">
				<xsl:text> </xsl:text>
				<xsl:call-template name="msign-finder-params-ref">
					<xsl:with-param name="begin" select="$begin"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="db:pk">
				<xsl:value-of select="$begin"/>
				<xsl:text> </xsl:text>
				<xsl:call-template name="pk-params">
					<xsl:with-param name="ctx" select="../.."/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="msign-finder-params-index">
		<xsl:param name="begin"/>

		<xsl:value-of select="$begin"/>
		<xsl:if test="db:range">
			<xsl:text> int offset, int count,</xsl:text>
		</xsl:if>

		<xsl:variable name="name" select="db:index/@name"/>
		<xsl:variable name="ind" select="../../db:indexes/db:index[@name = $name]"/>

		<xsl:if test="not($ind)">
			<xsl:message terminate="yes">
			Referenced index "<xsl:value-of select="$name"/>" not found
			in table "<xsl:value-of select="../../@name"/>", method "<xsl:value-of select="local-name()"/><xsl:call-template name="method-name"/>".
			</xsl:message>
		</xsl:if>

		<xsl:text> </xsl:text>
		<xsl:call-template name="index-param-names">
			<xsl:with-param name="columns" select="../../db:columns"/>
			<xsl:with-param name="columnrefs" select="$ind/db:columns/db:column"/>
			<xsl:with-param name="idx">
				<xsl:call-template name="index-level"/>
			</xsl:with-param>
			<xsl:with-param name="islist" select="count(db:index[@list='true'])"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="msign-finder-params-condition">
		<xsl:param name="begin"/>

		<xsl:choose>
			<xsl:when test="db:range">
				<xsl:value-of select="$begin"/>
				<xsl:text> int offset, int count</xsl:text>
				<xsl:if test="db:condition/db:params">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="db:condition/db:params">
				<xsl:value-of select="$begin"/>
			</xsl:when>
		</xsl:choose>

		<xsl:text> </xsl:text>
		<xsl:for-each select="db:condition/db:params/*">
			<xsl:call-template name="comma-if-next"/>
			<xsl:call-template name="param-ObjectType"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="param-name"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="msign-finder-params-ref">
		<xsl:param name="begin"/>
		<xsl:value-of select="$begin"/>
		<xsl:if test="db:range">
			<xsl:value-of select="$begin"/>
			<xsl:text> int offset, int count,</xsl:text>
		</xsl:if>
		<xsl:variable name="refname" select="db:ref/@table"/>
		<xsl:variable name="reftable" select="/db:database/db:tables/db:table[@name=$refname]"/>
		<xsl:variable name="refcol" select="$reftable/db:columns/db:column[db:ref/@table = $table_name]"/>
		<xsl:variable name="lname" select="$refcol/db:ref/@column"/>
		<xsl:variable name="rname" select="$refcol/@name"/>
		<xsl:for-each select="$reftable/db:columns/db:column[@name != $rname]">
			<xsl:call-template name="comma-if-next"/>
			<xsl:call-template name="column-ObjectType"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="column-name"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="msign-update-batch">
		<xsl:call-template name="comment-method"/>
		<xsl:text>    public </xsl:text>
		<xsl:variable name="isunique">
			<xsl:call-template name="is-unique-condition"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$isunique=1">
				<xsl:text>boolean</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>int</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> update</xsl:text>
		<xsl:call-template name="method-name"/>
		<xsl:text>( </xsl:text>
		<xsl:for-each select="db:set/db:params/*">
			<xsl:call-template name="comma-if-next"/>
			<xsl:call-template name="param-ObjectType"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="param-name"/>
		</xsl:for-each>
		<xsl:call-template name="msign-finder-params">
			<xsl:with-param name="commafirst">
				<xsl:if test="db:set/db:params">
					<xsl:text>1</xsl:text>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text> ) throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="msign-delete">
		<xsl:call-template name="comment-method"/>
		<xsl:text>    public </xsl:text>
		<xsl:variable name="isunique">
			<xsl:call-template name="is-unique-condition"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$isunique=1">
				<xsl:text>boolean</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>int</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> delete</xsl:text>
		<xsl:call-template name="method-name"/>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="msign-finder-params"/>
		<xsl:text> ) throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="msign-truncate">
		<xsl:call-template name="comment-method"/>
		<xsl:text>    public void truncate() throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="msign-mover">
		<xsl:call-template name="comment-method"/>
		<xsl:text>    public void move</xsl:text>
		<xsl:call-template name="method-name"/>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="msign-finder-params"/>
		<xsl:text> ) throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="msign-insert">
		<xsl:variable name="ispkauto">
			<xsl:call-template name="is-pk-auto"/>
		</xsl:variable>
		<xsl:text>
    /**
     * Inserts a new record.
</xsl:text>
		<xsl:if test="$ispkauto=1">
			<xsl:text>     * @return the generated primary key - </xsl:text>
			<xsl:call-template name="pk-name"/>
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:text>     */
    public </xsl:text>
		<xsl:choose>
			<xsl:when test="$ispkauto=1">
				<xsl:call-template name="pk-type"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>void</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> insert( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto</xsl:text>
		<xsl:text> ) throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="edit-methods">
		<xsl:if test="db:columns/db:column[db:edit]">
			<xsl:if test="not(db:columns/db:column[db:pk])">
				<xsl:message terminate="yes">
					Update methods are supported only if primary key is defined !
					Problem detected in table '<xsl:value-of select="@name"/>'.
				</xsl:message>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="db:edit-mode = 'column'">
					<xsl:for-each select="db:columns/db:column[db:edit]">
						<xsl:call-template name="msign-update-column"/>
						<xsl:call-template name="mbody-update-column"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="msign-update"/>
					<xsl:call-template name="mbody-update"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	<xsl:template name="msign-update">
		<xsl:text>
    /**
     * Updates one record found by primary key.
     * @return true iff the record was really updated (=found and any change was really saved)
     */
    public boolean update( </xsl:text>
		<xsl:call-template name="pk-params"/>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto ) throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="msign-update-column">
		<xsl:text>
    /**
     * Updates column </xsl:text>
		 <xsl:value-of select="@name"/>
		 <xsl:text> of one record found by primary key.
     * @return true iff the record was really updated (=found)
     */
    public boolean update</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>( </xsl:text>
		<xsl:call-template name="pk-params">
			<xsl:with-param name="ctx" select="../.."/>
		</xsl:call-template>
		<xsl:text>, </xsl:text>
		<xsl:choose>
			<xsl:when test="(db:pk or db:not-null) and not(db:enum) and db:type!='Serializable' and db:type!='List'">
				<xsl:value-of select="db:type"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="column-ObjectType"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:if test="db:pk">
			<xsl:text>_</xsl:text>
		</xsl:if>
		<xsl:call-template name="column-name"/>
		<xsl:text> ) throws DaoException</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-get-order-expr">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-counter">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-finder-index">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-finder">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-find-by-pk">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-update-batch">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-delete">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-truncate">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-mover">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-insert">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-update">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>

	<xsl:template name="mbody-update-column">
		<xsl:call-template name="mbody-abstract"/>
	</xsl:template>


	<xsl:template name="mbody-abstract">
		<xsl:text>;
</xsl:text>
	</xsl:template>

	<xsl:template name="pk-params">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="pk-params-keys"/>
		<xsl:for-each select="$ctx/db:columns/db:column[db:pk]">
			<xsl:if test="$keycol or position() != 1">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="db:enum">
					<xsl:call-template name="column-ObjectType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="db:type"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text> </xsl:text>
			<xsl:call-template name="column-name"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="pk-params-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:for-each select="$ctx">
			<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
			<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
			<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

			<xsl:call-template name="pk-params-keys">
				<xsl:with-param name="ctx" select="$pkeycol"/>
			</xsl:call-template>

			<xsl:if test="$pkeycol">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="db:enum">
					<xsl:call-template name="column-ObjectType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="db:type"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text> </xsl:text>
			<xsl:call-template name="column-name"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="is-unique-condition">
		<xsl:choose>
			<xsl:when test="db:pk or db:unique">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:when test="db:index[@level and @level !=1 ]"/>
			<xsl:when test="db:index">
				<xsl:variable name="name" select="db:index/@name"/>
				<xsl:variable name="ind" select="../../db:indexes/db:index[@name = $name]"/>
				<xsl:if test="$ind/db:unique">
					<xsl:text>1</xsl:text>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="name-by-index">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="columnrefs" select="$ctx/db:columns/db:column"/>
		<xsl:param name="idx" select="0"/>
		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:call-template name="column-Name"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>



	<xsl:template name="index-param-names">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>
		<xsl:param name="islist"/>
		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:call-template name="comma-if-next"/>
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="col" select="$columns/db:column[@name=$name]"/>

				<xsl:if test="not($col)">
					<xsl:message terminate="yes">
	Unknown referenced column "<xsl:value-of select="$name"/>" in index "<xsl:value-of select="$columnrefs/../../@name"/>" of table "<xsl:value-of select="$columns/../@name"/>"
					</xsl:message>
				</xsl:if>

				<xsl:call-template name="index-column-type">
					<xsl:with-param name="ctx" select="$col"/>
					<xsl:with-param name="islist" select="$islist"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:call-template name="column-name"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="method-name">
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:call-template name="uc-first">
					<xsl:with-param name="name" select="@name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="db:all">
				<xsl:text>All</xsl:text>
			</xsl:when>
			<xsl:when test="db:dynamic">
				<xsl:text>Dynamic</xsl:text>
			</xsl:when>
			<xsl:when test="db:pk">
				<xsl:text>ByPrimaryKey</xsl:text>
			</xsl:when>
			<xsl:when test="db:index">
				<xsl:variable name="name" select="db:index/@name"/>
				<xsl:text>By</xsl:text>
				<xsl:call-template name="name-by-index">
					<xsl:with-param name="ctx" select="../../db:indexes/db:index[@name = $name]"/>
					<xsl:with-param name="idx">
						<xsl:call-template name="index-level"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					Automatic method name is not supported for this condition type.
					In table "<xsl:value-of select="../../@name"/>" method "<xsl:value-of select="local-name()"/>".
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="is-auto-find">
		<xsl:param name="type"/>
		<xsl:choose>
			<xsl:when test="db:auto-find">
				<xsl:choose>
					<xsl:when test="db:auto-find/@*[local-name()=$type][1]='false'"></xsl:when>
					<xsl:otherwise>
						<xsl:text>1</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="../db:auto-find">
				<xsl:choose>
					<xsl:when test="../db:auto-find/@*[local-name()=$type][1]='false'"></xsl:when>
					<xsl:otherwise>
						<xsl:text>1</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="index-level">
		<xsl:choose>
			<xsl:when test="db:index[@level]">
				<xsl:value-of select="db:index/@level - 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
