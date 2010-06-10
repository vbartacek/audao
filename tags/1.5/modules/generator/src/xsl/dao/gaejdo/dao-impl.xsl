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

	<xsl:import href="..@DIR_SEP@dao-impl.xsl"/>
	<xsl:import href="common.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="table_name"/>


	<xsl:template name="dtoimpl-name">
		<xsl:call-template name="dto-name"/>
		<xsl:text>Impl</xsl:text>
	</xsl:template>


	<xsl:template name="imports-java">
		<xsl:text>import java.util.List;

import javax.jdo.JDOException;
import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
</xsl:text>
	</xsl:template>


	<xsl:template name="imports-jdbc">
		<xsl:text>
import java.sql.Date;
import java.sql.Timestamp;
</xsl:text>
	</xsl:template>


	<xsl:template name="import-abstract-dao-impl">
		<xsl:text>
import com.spoledge.audao.db.dao.gae.GaeJdoAbstractDaoImpl;
</xsl:text>
	</xsl:template>


	<xsl:template name="import-dtoimpl">
		<xsl:text>import </xsl:text>
		<xsl:value-of select="$pkg_dto"/>
		<xsl:text>.gae.</xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>Impl;
</xsl:text>
	</xsl:template>


	<xsl:template name="abstract-dao-impl-name">
		<xsl:text>GaeJdoAbstractDaoImpl</xsl:text>
	</xsl:template>


	<xsl:template name="attr-table-name">
	</xsl:template>


	<xsl:template name="attr-select-columns">
	</xsl:template>


	<xsl:template name="attr-pk-condition">
	</xsl:template>


	<xsl:template name="attr-sql-insert">
	</xsl:template>


	<xsl:template name="constructors">
		<xsl:text>
    public </xsl:text>
		<xsl:value-of select="$daoimpl"/>
		<xsl:text>( PersistenceManager pm ) {
        super( pm );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-get-table-name">
		<xsl:text>
    /**
     * Returns the table name.
     */
    public String getTableName() {
        return null;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-get-select-columns">
	</xsl:template>


	<xsl:template name="method-fetch">
		<xsl:call-template name="method-query"/>
		<xsl:call-template name="method-fetch-one"/>
		<xsl:call-template name="method-fetch-array"/>
	</xsl:template>


	<xsl:template name="method-query">
		<xsl:text>
    protected Query getQuery() {
        return pm.newQuery( </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text>.class );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-fetch-one">
		<xsl:text>
    protected </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> fetch( Query q, Object... params ) {
        </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text> impl = (</xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text>) execute( q, params );

        return impl != null ? impl._getDto() : null;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-fetch-array">
		<xsl:text>
    protected </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>[] fetchArray( Query q, Object... params ) {
        List&lt;?&gt; list = (List&lt;?&gt;) execute( q, params );

        </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>[] ret = new </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>[ list.size() ];

        int index=0;
        for ( Object o : list ) {
            </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text> impl = (</xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text>) o;
            ret[ index++ ] = impl._getDto();
        }

        return ret;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-to-array">
	</xsl:template>


	<xsl:template name="mbody-find-by-pk">
		<xsl:call-template name="open-mbody"/>
		<xsl:call-template name="fetch-by-pk"/>
		<xsl:text>
        return impl != null ? impl._getDto() : null;
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-finder-index">
		<xsl:param name="idx"/>
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:call-template name="open-mbody"/>
		<xsl:call-template name="find-one-or-many">
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:call-template name="index-condition">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:if test="$idx != 0 or not(db:unique)">
			<xsl:text>, null, 0, Integer.MAX_VALUE</xsl:text>
		</xsl:if>

		<xsl:call-template name="index-param-values">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:text>);
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-insert">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="ispkauto">
			<xsl:call-template name="is-pk-auto"/>
		</xsl:variable>
		<xsl:variable name="isauto" select="db:columns/db:column[db:auto][db:type='short' or db:type='int' or db:type='long']"/>
		<xsl:text>
        debugSql( "insert", dto );

        try {
            </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text> impl = new </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text>();
</xsl:text>
		<xsl:for-each select="db:columns/db:column[not(db:auto) or db:type='Date' or db:type='Timestamp']">
			<xsl:call-template name="set-column-insert"/>
		</xsl:for-each>
		<xsl:text>
            pm.makePersistent( impl );
</xsl:text>
		<xsl:if test="$ispkauto=1">
			<xsl:text>
            dto.set</xsl:text>
			<xsl:call-template name="pk-Name-ucfirst"/>
			<xsl:text>( impl.get</xsl:text>
			<xsl:call-template name="pk-Name-ucfirst"/>
			<xsl:text>().get</xsl:text>
			<xsl:choose>
				<xsl:when test="db:columns/db:column[db:pk]/db:type='long'">
					<xsl:text>Id</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Name</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>());

            return dto.get</xsl:text>
			<xsl:call-template name="pk-Name-ucfirst"/>
			<xsl:text>();
</xsl:text>
		</xsl:if>
		<xsl:call-template name="catch-sqlexception-write">
			<xsl:with-param name="sql">"insert"</xsl:with-param>
			<xsl:with-param name="params">dto</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-update-column-body">
		<xsl:param name="autodate"/>
		<xsl:call-template name="fetch-by-pk">
			<xsl:with-param name="ctx" select="../.."/>
		</xsl:call-template>
		<xsl:text>        if (impl == null) return false;

        impl.set</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>( </xsl:text>
		<xsl:call-template name="column-val"/>
		<xsl:text>);
</xsl:text>

		<xsl:for-each select="$autodate">
			<xsl:text>        impl.set</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>( new </xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>( System.currentTimeMillis()));
</xsl:text>
		</xsl:for-each>

		<xsl:text>
        return true;
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-update">
		<xsl:call-template name="open-mbody"/>
		<xsl:call-template name="fetch-by-pk"/>
		<xsl:text>        if (impl == null) return false;

        boolean isUpdated = false;

</xsl:text>

		<xsl:variable name="autodate" select="db:columns/db:column[db:auto[@on='update' or @on='update-only'] and (db:type='Date' or db:type='Timestamp')]"/>

		<xsl:for-each select="db:columns/db:column[db:edit]">
			<xsl:choose>
				<xsl:when test="db:not-null or db:pk">
					<xsl:call-template name="update-append-not-null"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="update-append-null"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

		<xsl:text>
        if (!isUpdated) {
            return false;
        }
</xsl:text>

		<xsl:for-each select="$autodate">
			<xsl:text>        impl.set</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>( new </xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>( System.currentTimeMillis()));
</xsl:text>
		</xsl:for-each>

		<xsl:text>

        return true;
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="update-append-null">
		<xsl:text>
        if ( dto.is</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>Modified()) {
</xsl:text>
		<xsl:call-template name="update-append-common">
			<xsl:with-param name="indent" select="''"/>
		</xsl:call-template>
		<xsl:text>        }
</xsl:text>
	</xsl:template>


	<xsl:template name="update-append-comma">
	</xsl:template>


	<xsl:template name="update-append-common">
		<xsl:param name="indent" select="'            '"/>
		<xsl:if test="db:type = 'String'">
			<xsl:value-of select="$indent"/>
			<xsl:call-template name="check-Length"/>
		</xsl:if>
		<xsl:value-of select="$indent"/>
		<xsl:text>impl.set</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>( </xsl:text>
		<xsl:call-template name="column-val">
			<xsl:with-param name="colname">
				<xsl:call-template name="getter"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>);
</xsl:text>
		<xsl:value-of select="$indent"/>
		<xsl:text>isUpdated = true;
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-delete">
		<xsl:call-template name="open-mbody"/>
		<xsl:choose>
			<xsl:when test="db:pk">
				<xsl:call-template name="fetch-by-pk">
					<xsl:with-param name="ctx" select="../.."/>
				</xsl:call-template>

				<xsl:text>
        if (impl == null) return false;

        pm.deletePersistent( impl );

        return true;
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>        return delete</xsl:text>
				<xsl:variable name="isunique">
					<xsl:call-template name="is-unique-condition"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$isunique=1">
						<xsl:text>One( </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Many( </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="finder-condition"/>
				<xsl:call-template name="finder-params"/>
				<xsl:text>);
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="stmt-set">
		<xsl:param name="uctype"/>
		<xsl:param name="getter"/>
		<xsl:param name="notnull"/>
		<xsl:param name="indent"/>
		<xsl:value-of select="$indent"/>
		<xsl:text>impl.set</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>( </xsl:text>
		<xsl:choose>
			<xsl:when test="db:pk and ../db:ref[@gae-parent='true']">
				<xsl:message terminate="yes">NOT-IMPLEMENTED: GAE key reference without auto primary key</xsl:message>
			</xsl:when>
			<xsl:when test="db:ref[@gae-parent='true']">
				<xsl:variable name="origtable" select="db:type/@orig-table"/>
				<xsl:variable name="origcol" select="db:type/@orig-column"/>
				<xsl:text>KeyFactory.createKey( "</xsl:text>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="//db:table[@name=$origtable]"/>
				</xsl:call-template>
				<xsl:text>Impl", dto.get</xsl:text>
				<xsl:call-template name="java-Name"/>
				<xsl:text>())</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="enum-to-raw">
					<xsl:with-param name="val">
						<xsl:text>dto.get</xsl:text>
						<xsl:call-template name="java-Name"/>
						<xsl:text>()</xsl:text>
					</xsl:with-param>
					<!-- always notnull in this context insert()-->
					<xsl:with-param name="notnull" select="1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);
</xsl:text>
	</xsl:template>


	<xsl:template name="stmt-set-null">
		<xsl:text>// none for GAE
</xsl:text>
	</xsl:template>


	<xsl:template name="catch-sqlexception">
		<xsl:text>        }
        catch (JDOException e) {
            throw new DBException( e );
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="catch-sqlexception-write">
		<xsl:param name="sql"/>
		<xsl:param name="params"/>
		<xsl:text>        }
        catch (JDOException e) {
</xsl:text>
		<xsl:if test="$sql">
			<xsl:text>            errorSql( e, </xsl:text>
			<xsl:value-of select="$sql"/>
			<xsl:if test="$params">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$params"/>
			</xsl:if>
			<xsl:text> );
</xsl:text>
		</xsl:if>
		<xsl:text>
            throw new DaoException( e );
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="fetch-by-pk">
		<xsl:param name="ctx" select="."/>
		<xsl:text>        </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text> impl = null;

        try {
            impl = pm.getObjectById( </xsl:text>
		<xsl:call-template name="dtoimpl-name"/>
		<xsl:text>.class</xsl:text>
		<xsl:call-template name="pk-param-names">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
		<xsl:text>);
        }
        catch (JDOObjectNotFoundException _e) {}
</xsl:text>
	</xsl:template> 


	<xsl:template name="and-if-next">
		<xsl:if test="position() != 1">
			<xsl:text> &amp;&amp; </xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="get-order-expr">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="finder-condition">
		<xsl:param name="isunique"/>

		<xsl:choose>
			<xsl:when test="db:pk">
				<xsl:text>PK_CONDITION</xsl:text>
			</xsl:when>
			<xsl:when test="db:index">
				<xsl:call-template name="finder-condition-index"/>
			</xsl:when>
			<xsl:when test="db:condition">
				<xsl:text>"</xsl:text>
				<xsl:call-template name="condition-query"/>
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:when test="db:dynamic">
				<xsl:text>cond</xsl:text>
			</xsl:when>
			<xsl:when test="db:ref">
				<xsl:call-template name="finder-condition-ref"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>null</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="local-name() = 'find' and not($isunique=1)">
			<xsl:text>, </xsl:text>
			<xsl:choose>
				<xsl:when test="db:order-by">
					<xsl:text>"</xsl:text>
					<xsl:call-template name="order-by"/>
					<xsl:text>"</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>null</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	<xsl:template name="finder-condition-index">
		<xsl:variable name="name" select="db:index/@name"/>
		<xsl:variable name="ind" select="../../db:indexes/db:index[@name = $name]"/>
		<xsl:call-template name="index-condition">
			<xsl:with-param name="columns" select="../../db:columns"/>
			<xsl:with-param name="columnrefs" select="$ind/db:columns/db:column"/>
			<xsl:with-param name="idx">
				<xsl:call-template name="index-level"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="index-condition">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>

		<xsl:text>"</xsl:text>
		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="col" select="$columns/db:column[@name=$name]"/>

				<xsl:call-template name="and-if-next"/>
				<xsl:call-template name="java-name">
					<xsl:with-param name="ctx" select="$col"/>
				</xsl:call-template>

				<xsl:text> == :_</xsl:text>
				<xsl:call-template name="java-name"/>
				<xsl:if test="position() = last() - $idx">
					<xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="order-by-syntax">
	</xsl:template>


	<xsl:template name="column-val-otherwise">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="colname"/>
		<xsl:choose>
			<xsl:when test="$ctx/db:ref[@gae-parent='true']">
				<xsl:variable name="origtable" select="$ctx/db:type/@orig-table"/>
				<xsl:variable name="origcol" select="$ctx/db:type/@orig-column"/>
				<xsl:text>KeyFactory.createKey( "</xsl:text>
				<xsl:call-template name="java-Name">
					<xsl:with-param name="ctx" select="//db:table[@name=$origtable]"/>
				</xsl:call-template>
				<xsl:text>Impl", </xsl:text>
				<xsl:value-of select="$colname"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$colname"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="param-val-NOT-USED">
		<xsl:variable name="capital">
			<xsl:choose>
				<xsl:when test="local-name(../..)='set'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$capital=1">
			<xsl:text>new</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="local-name()='column'">
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="col" select="../../../../../db:columns/db:column[@name=$name]"/>
				<xsl:choose>
					<xsl:when test="$col/db:ref[@gae-parent='true']">
						<xsl:variable name="origtable" select="$col/db:type/@orig-table"/>
						<xsl:variable name="origcol" select="$col/db:type/@orig-column"/>
						<xsl:text>KeyFactory.createKey( "</xsl:text>
						<xsl:call-template name="java-Name">
							<xsl:with-param name="ctx" select="//db:table[@name=$origtable]"/>
						</xsl:call-template>
						<xsl:text>Impl", </xsl:text>
						<xsl:call-template name="column-val">
							<xsl:with-param name="ctx" select="$col"/>
							<xsl:with-param name="capital" select="$capital"/>
						</xsl:call-template>
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="column-val">
							<xsl:with-param name="ctx" select="$col"/>
							<xsl:with-param name="capital" select="$capital"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="camel-name">
					<xsl:with-param name="name" select="@name"/>
					<xsl:with-param name="capital" select="$capital"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
