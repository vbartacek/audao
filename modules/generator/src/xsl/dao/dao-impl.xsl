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
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
>

	<xsl:import href="dao.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="db_type"/>
	<xsl:param name="table_name"/>

	<xsl:variable name="pkg_dao_impl" select="concat($pkg_dao, concat('.', $db_type))"/>
	<xsl:variable name="daoimpl">
		<xsl:call-template name="dao-name"/>
		<xsl:text>Impl</xsl:text>
	</xsl:variable>

	<xsl:variable name="defcache0">
		<xsl:call-template name="db-conf-node">
			<xsl:with-param name="ctx" select="$daoctx"/>
			<xsl:with-param name="type" select="'dao-impl'"/>
			<xsl:with-param name="elem" select="'default-cache'"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="defcache" select="exsl:node-set($defcache0)/db:default-cache"/>

	<xsl:variable name="dao_Findmany">
		<xsl:call-template name="uc-first">
			<xsl:with-param name="name" select="$dao_findmany"/>
		</xsl:call-template>
	</xsl:variable>


	<xsl:template match="db:table|db:view">
		<xsl:call-template name="file-header"/>
		<xsl:text>package </xsl:text>
		<xsl:value-of select="$pkg_dao_impl"/>
		<xsl:text>;

</xsl:text>
		<xsl:call-template name="imports-jdbc"/>
		<xsl:if test="db:columns/db:column[db:type = 'Serializable' and not(db:type/@class)]">
			<xsl:text>
import java.io.Serializable;
</xsl:text>
		</xsl:if>
		<xsl:text>
import java.util.ArrayList;
</xsl:text>
		<xsl:if test="db:columns/db:column/db:enum[db:value[@db] or db:value[@id] and ../db:type != 'String']">
			<xsl:text>import java.util.HashMap;
</xsl:text>
		</xsl:if>
		<xsl:if test="$dao_findmany='list' or db:columns/db:column[db:type = 'List'] or db:methods//db:params/*[@list='true']">
			<xsl:text>
import java.util.List;
</xsl:text>
		</xsl:if>
		<xsl:call-template name="dbutil-imports-gae-types"/>
		<xsl:call-template name="imports-java"/>
		<xsl:call-template name="import-abstract-dao-impl"/>
		<xsl:text>import com.spoledge.audao.db.dao.DBException;
import com.spoledge.audao.db.dao.DaoException;
</xsl:text>
		<xsl:if test="$defcache">
			<xsl:text>import com.spoledge.audao.db.dao.DtoCache;
import com.spoledge.audao.db.dao.DtoCacheFactory;
</xsl:text>
		</xsl:if>
		<xsl:call-template name="imports-audao-impl"/>
<xsl:text>

import </xsl:text>
		<xsl:value-of select="$pkg_dao"/>
		<xsl:text>.</xsl:text>
		<xsl:call-template name="dao-name"/>
		<xsl:text>;
</xsl:text>
		<xsl:if test="not(@generic)">
			<xsl:text>import </xsl:text>
			<xsl:value-of select="$pkg_dto"/>
			<xsl:text>.</xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text>;
</xsl:text>
			<xsl:call-template name="import-dtoimpl"/>
		</xsl:if>
		<xsl:call-template name="dbutil-imports-embed"/>
		<xsl:call-template name="enums-import"/>
		<xsl:text>

/**
 * This is the DAO imlementation class.
 *
 * @author generated
 */
public</xsl:text>
		<xsl:if test="@abstract='true'">
			<xsl:text> abstract</xsl:text>
		</xsl:if>
		<xsl:text> class </xsl:text>
		<xsl:value-of select="$daoimpl"/>
		<xsl:if test="@generic">
			<xsl:text>&lt;T&gt;</xsl:text>
		</xsl:if>
		<xsl:text> extends </xsl:text>

		<xsl:variable name="gentpl">
			<xsl:text>&lt;</xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text>&gt;</xsl:text>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@extends">
				<xsl:call-template name="extends-java-Name"/>
				<xsl:text>DaoImpl</xsl:text>

				<xsl:variable name="extname" select="@extends"/>
				<xsl:if test="/db:database/db:tables/db:table[@name=$extname and @generic]">
					<xsl:value-of select="$gentpl"/>
				</xsl:if>
			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="db-conf-elem-dbtype">
					<xsl:with-param name="type" select="'dao-impl'"/>
					<xsl:with-param name="elem" select="'root'"/>
					<xsl:with-param name="def">
						<xsl:call-template name="abstract-dao-impl-name"/>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:if test="not(@generic)">
					<xsl:value-of select="$gentpl"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text> implements </xsl:text>
		<xsl:call-template name="dao-name"/>
		<xsl:if test="@generic">
			<xsl:text>&lt;T&gt;</xsl:text>
		</xsl:if>

		<xsl:text> {
</xsl:text>

		<xsl:if test="not(@abstract='true')">
			<xsl:call-template name="attr-table-name"/>
		</xsl:if>

		<xsl:if test="db:columns/db:column[not(@defined-by)]">
			<xsl:call-template name="attr-select-columns"/>
		</xsl:if>

		<xsl:if test="db:columns/db:column[not(@defined-by) and db:pk]">
			<xsl:call-template name="attr-pk-condition"/>
		</xsl:if>

		<xsl:if test="not(@abstract='true') and not(db:read-only) and not(../db:view)">
			<xsl:call-template name="attr-sql-insert"/>
		</xsl:if>

		<xsl:if test="$defcache">
			<xsl:call-template name="attr-default-cache"/>
		</xsl:if>

		<xsl:if test="not(@abstract='true')">
			<xsl:call-template name="enums-mapping"/>
		</xsl:if>

		<xsl:call-template name="constructors"/>

		<xsl:call-template name="dao-methods"/>

		<xsl:if test="not(@abstract='true')">
			<xsl:call-template name="method-get-table-name"/>
		</xsl:if>
		<xsl:if test="db:columns/db:column[not(@defined-by)]">
			<xsl:call-template name="method-get-select-columns"/>
		</xsl:if>
		<xsl:if test="not(@abstract='true')">
			<xsl:call-template name="method-fetch"/>
			<xsl:call-template name="method-to-array"/>
		</xsl:if>
		<xsl:if test="$defcache">
			<xsl:call-template name="method-copy-of"/>
			<xsl:call-template name="method-create-dtocache-factory"/>
		</xsl:if>
		<xsl:text>
}
</xsl:text>
	</xsl:template>


	<xsl:template name="imports-java">
	</xsl:template>

	<xsl:template name="imports-audao-impl">
		<xsl:if test="$defcache">
			<xsl:text>import com.spoledge.audao.db.dao.MemoryDtoCacheFactoryImpl;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="imports-jdbc">
		<xsl:text>
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
</xsl:text>
	</xsl:template>


	<xsl:template name="import-abstract-dao-impl">
		<xsl:text>
import com.spoledge.audao.db.dao.AbstractDaoImpl;
</xsl:text>
	</xsl:template>


	<xsl:template name="import-dtoimpl">
	</xsl:template>


	<xsl:template name="abstract-dao-impl-name">
		<xsl:text>AbstractDaoImpl</xsl:text>
	</xsl:template>


	<xsl:template name="attr-table-name">
		<xsl:text>
    private static final String TABLE_NAME = "</xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text>";
</xsl:text>
	</xsl:template>


	<xsl:template name="attr-select-columns">
		<xsl:text>
    protected static final String SELECT_COLUMNS = "</xsl:text>
		<xsl:for-each select="db:columns/db:column">
			<xsl:call-template name="comma-if-next"/>
			<xsl:value-of select="@name"/>
		</xsl:for-each>
		<xsl:text>";
</xsl:text>
	</xsl:template>


	<xsl:template name="attr-pk-condition">
		<xsl:text>
    protected static final String PK_CONDITION = "</xsl:text>
		<xsl:for-each select="db:columns/db:column[db:pk]">
			<xsl:call-template name="and-if-next"/>
			<xsl:value-of select="@name"/>
			<xsl:text>=?</xsl:text>
		</xsl:for-each>
		<xsl:text>";
</xsl:text>
	</xsl:template>


	<xsl:template name="attr-sql-insert">
		<xsl:text>
    private static final String SQL_INSERT = "INSERT INTO </xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text> (</xsl:text>
		<xsl:for-each select="db:columns/db:column">
			<xsl:call-template name="comma-if-next"/>
			<xsl:value-of select="@name"/>
		</xsl:for-each>
		<xsl:text>) VALUES (</xsl:text>
		<xsl:for-each select="db:columns/db:column">
			<xsl:call-template name="comma-if-next"/>
			<xsl:text>?</xsl:text>
		</xsl:for-each>
		<xsl:text>)";
</xsl:text>
	</xsl:template>


	<xsl:template name="attr-default-cache">
		<xsl:variable name="keytype">
			<xsl:call-template name="dtocache-key-type"/>
		</xsl:variable>
		<xsl:text>
    private static final DtoCache&lt;</xsl:text>
		<xsl:value-of select="$keytype"/>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>&gt; _defaultCache = createDefaultDtoCacheFactory().createDtoCache( </xsl:text>
		<xsl:if test="$defcache/@expire-millis and $defcache/@expire-millis &gt; 0">
			<xsl:value-of select="$defcache/@expire-millis"/>
			<xsl:text>L, </xsl:text>
		</xsl:if>
		<xsl:value-of select="$defcache/@max-size"/>
		<xsl:text> );
</xsl:text>
	</xsl:template>


	<xsl:template name="constructors">
		<xsl:text>
    public </xsl:text>
		<xsl:value-of select="$daoimpl"/>
		<xsl:text>( Connection conn ) {
        super( conn );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-get-order-expr">
		<xsl:call-template name="open-mbody"/>
			<xsl:text>        return col.toString();
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-find-by-pk">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        return findOne( PK_CONDITION</xsl:text>
		<xsl:call-template name="pk-param-names"/>
		<xsl:text>);
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-update-column">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="isprimitive">
			<xsl:call-template name="is-primitive"/>
		</xsl:variable>
		<xsl:variable name="autodate" select="../db:column[db:auto[@on='update' or @on='update-only'] and (db:type='Date' or db:type='Timestamp')]"/>
		<xsl:choose>
			<xsl:when test="(db:not-null or db:pk) and ($isprimitive != 1 or db:enum)">
				<xsl:call-template name="check-Null"/>
				<xsl:if test="db:type = 'String' and not(db:enum)">
					<xsl:text>        </xsl:text>
					<xsl:call-template name="check-Length">
						<xsl:with-param name="getter">
							<xsl:call-template name="column-name"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:text>
</xsl:text>
			</xsl:when>
			<xsl:when test="db:type = 'String' and not(db:enum)">
				<xsl:text>        if ( </xsl:text>
				<xsl:call-template name="column-name"/>
				<xsl:text> != null ) {
            </xsl:text>
				<xsl:call-template name="check-Length">
					<xsl:with-param name="getter">
						<xsl:call-template name="column-name"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text>        }

</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:call-template name="mbody-update-column-body">
			<xsl:with-param name="autodate" select="$autodate"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="mbody-update-column-body">
		<xsl:param name="autodate"/>
		<xsl:text>        return updateOne( </xsl:text>
		<xsl:choose>
			<xsl:when test="db:not-null or db:pk">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>=?"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>( </xsl:text>
				<xsl:call-template name="column-name"/>
				<xsl:text> != null ? "</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>=?" : "</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>=NULL")</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="$autodate">
			<xsl:text> + ", </xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>=?"</xsl:text>
		</xsl:for-each>

		<xsl:text>, PK_CONDITION, </xsl:text>

		<xsl:call-template name="column-val">
			<xsl:with-param name="set" select="1"/>
		</xsl:call-template>

		<xsl:for-each select="$autodate">
			<xsl:text>, new </xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>( System.currentTimeMillis())</xsl:text>
		</xsl:for-each>

		<xsl:for-each select="../db:column[db:pk]">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="column-val"/>
		</xsl:for-each>
		<xsl:text>);
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-update">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="autodate" select="db:columns/db:column[db:auto[@on='update' or @on='update-only'] and (db:type='Date' or db:type='Timestamp')]"/>
		<xsl:text>        StringBuffer sb = new StringBuffer();
        ArrayList&lt;Object&gt; params = new ArrayList&lt;Object&gt;();
</xsl:text>
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
        if (sb.length() == 0) {
            return false;
        }
</xsl:text>

		<xsl:for-each select="$autodate">
			<xsl:text>
        sb.append(", </xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>=?");
        params.add( new </xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>( System.currentTimeMillis()));
</xsl:text>
		</xsl:for-each>

		<xsl:for-each select="db:columns/db:column[db:pk]">
			<xsl:text>
        params.add( </xsl:text>
			<xsl:call-template name="column-val"/>
			<xsl:text> );
</xsl:text>
		</xsl:for-each>
		<xsl:text>
        Object[] oparams = new Object[ params.size() ];

        return updateOne( sb.toString(), PK_CONDITION, params.toArray( oparams ));
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="update-append-not-null">
		<xsl:text>
        if ( </xsl:text>
		<xsl:call-template name="getter"/>
		<xsl:text> != null ) {
</xsl:text>
		<xsl:call-template name="update-append-comma"/>
		<xsl:call-template name="update-append-common"/>
		<xsl:text>        }
</xsl:text>
	</xsl:template>


	<xsl:template name="update-append-null">
		<xsl:text>
        if ( dto.is</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>Modified()) {
</xsl:text>
		<xsl:call-template name="update-append-comma"/>
		<xsl:text>            if ( </xsl:text>
		<xsl:call-template name="getter"/>
		<xsl:text> == null ) {
                sb.append( "</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>=NULL" );
            }
            else {
</xsl:text>
		<xsl:call-template name="update-append-common">
			<xsl:with-param name="indent" select="'                '"/>
		</xsl:call-template>
		<xsl:text>            }
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="update-append-comma">
		<xsl:if test="position()!=1">
			<xsl:text>            if (sb.length() &gt; 0) {
                sb.append( ", " );
            }

</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="update-append-common">
		<xsl:param name="indent" select="'            '"/>
		<xsl:if test="db:type = 'String' and not(db:enum)">
			<xsl:value-of select="$indent"/>
			<xsl:call-template name="check-Length"/>
		</xsl:if>
		<xsl:value-of select="$indent"/>
		<xsl:text>sb.append( "</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>=?" );
</xsl:text>
		<xsl:value-of select="$indent"/>
		<xsl:text>params.add( </xsl:text>
		<xsl:call-template name="column-val">
			<xsl:with-param name="colname">
				<xsl:call-template name="getter"/>
			</xsl:with-param>
			<xsl:with-param name="notnull" select="1"/>
			<xsl:with-param name="set" select="1"/>
		</xsl:call-template>
		<xsl:text>);
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-insert">
		<xsl:message>The 'mbody-insert' template should be overridden by subclass</xsl:message>
	</xsl:template>

	<xsl:template name="mbody-insert-all">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        for ( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto : dtos ) {
            insert( dto );
        }
    }
</xsl:text>
	</xsl:template>

	<xsl:template name="catch-sqlexception">
		<xsl:text>        }
        catch (SQLException e) {
            throw new DBException( e );
        }
</xsl:text>
	</xsl:template>

	<xsl:template name="catch-sqlexception-write">
		<xsl:param name="sql"/>
		<xsl:param name="params"/>
		<xsl:text>        }
        catch (SQLException e) {
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
		<xsl:text>            handleException( e );
            throw new DBException( e );
        }
</xsl:text>
	</xsl:template>

	<xsl:template name="method-fetch">
		<xsl:text>
    protected </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> fetch( ResultSet rs ) throws SQLException {
        </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto = new </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>();
</xsl:text>
		<xsl:for-each select="db:columns/db:column">
			<xsl:text>        </xsl:text>
			<xsl:if test="db:enum and db:type='String'">
				<xsl:text>{
            String _tmp = </xsl:text>
				<xsl:text>rs.get</xsl:text>
				<xsl:call-template name="column-Type"/>
				<xsl:text>( </xsl:text>
				<xsl:value-of select="position()"/>
				<xsl:text> );
            if (_tmp != null) </xsl:text>
			</xsl:if>
			<xsl:text>dto.set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( </xsl:text>
			<xsl:choose>
				<xsl:when test="db:type='byte[]'">
					<xsl:text>rs.getBytes( </xsl:text>
					<xsl:value-of select="position()"/>
					<xsl:text> )</xsl:text>
				</xsl:when>
				<xsl:when test="db:type='Serializable'">
					<xsl:text>deserialize( rs.getBytes( </xsl:text>
					<xsl:value-of select="position()"/>
					<xsl:text> ), </xsl:text>
					<xsl:call-template name="column-ObjectType-raw"/>
					<xsl:text>.class )</xsl:text>
				</xsl:when>
				<xsl:when test="db:enum and db:type='String'">
					<xsl:call-template name="enum-get-by-id">
						<xsl:with-param name="id" select="'_tmp'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="enum-get-by-id">
						<xsl:with-param name="id">
							<xsl:text>rs.get</xsl:text>
							<xsl:call-template name="column-Type"/>
							<xsl:text>( </xsl:text>
							<xsl:value-of select="position()"/>
							<xsl:text> )</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="db:type='boolean'">
						<xsl:text> ? Boolean.TRUE : Boolean.FALSE </xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
					<xsl:text>);
</xsl:text>
			<xsl:if test="db:enum and db:type='String'">
				<xsl:text>        }
</xsl:text>
			</xsl:if>
			<xsl:variable name="isprimitive">
				<xsl:call-template name="is-primitive"/>
			</xsl:variable>
			<xsl:if test="not(db:not-null or db:pk) and $isprimitive=1">
				<xsl:text>
        if ( rs.wasNull()) {
            dto.set</xsl:text>
				<xsl:call-template name="column-Name"/>
				<xsl:text>( null );
        }

</xsl:text>
			</xsl:if>

		</xsl:for-each>
		<xsl:text>
        return dto;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-get-table-name">
		<xsl:text>
    /**
     * Returns the table name.
     */
    public String getTableName() {
        return TABLE_NAME;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-get-select-columns">
		<xsl:text>
    protected String getSelectColumns() {
        return SELECT_COLUMNS;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-to-array">
		<xsl:text>
    protected </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>[] toArray(ArrayList&lt;</xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>&gt; list ) {
        </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>[] ret = new </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>[ list.size() ];
        return list.toArray( ret );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-copy-of">
		<xsl:text>
    protected static </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> copyOf( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> _dto ) {
        </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> _ret = new </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>();
</xsl:text>
		<xsl:call-template name="copy-of-keys"/>
		<xsl:for-each select="db:columns/db:column">
			<xsl:text>        _ret.set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( _dto.get</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>());
</xsl:text>
		</xsl:for-each>
		<xsl:text>
        return _ret;
    }
</xsl:text>
	</xsl:template>

	<xsl:template name="copy-of-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:for-each select="$ctx">
			<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
			<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
			<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

			<xsl:call-template name="copy-of-keys">
				<xsl:with-param name="ctx" select="$pkeycol"/>
			</xsl:call-template>

			<xsl:text>        _ret.set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( _dto.get</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>());
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="method-create-dtocache-factory">
		<xsl:variable name="tpl">
			<xsl:text>&lt;</xsl:text>
			<xsl:call-template name="dtocache-key-type"/>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text>&gt;</xsl:text>
		</xsl:variable>

		<xsl:text>
    protected static DtoCacheFactory</xsl:text>
		<xsl:value-of select="$tpl"/>
		<xsl:text> createDefaultDtoCacheFactory() {
        return </xsl:text>
		<xsl:call-template name="dtocache-factory-impl">
			<xsl:with-param name="tpl" select="$tpl"/>
		</xsl:call-template>
		<xsl:text>;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="null-column-condition">
		<xsl:param name="getter"/>
		<xsl:text>
            if ( </xsl:text>
		<xsl:value-of select="$getter"/>
		<xsl:text> == null ) {
                </xsl:text>
	</xsl:template>


	<xsl:template name="set-column-insert">
		<xsl:variable name="getter">
			<xsl:call-template name="getter"/>
		</xsl:variable>
		<xsl:variable name="getter4sql">
			<xsl:call-template name="getter4sql"/>
		</xsl:variable>
		<xsl:variable name="isprimitive">
			<xsl:call-template name="is-primitive"/>
		</xsl:variable>
		<xsl:variable name="uctype">
			<xsl:call-template name="column-Type"/>
		</xsl:variable>
		<xsl:variable name="autodate">
			<xsl:if test="db:auto[not(@on='update-only')] and (db:type='Date' or db:type='Timestamp')">1</xsl:if>
		</xsl:variable>

		<xsl:if test="$isprimitive=1 or db:not-null or db:pk or $autodate=1 or db:default-value">
			<xsl:call-template name="null-column-condition">
				<xsl:with-param name="getter" select="$getter"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="$autodate=1">
					<xsl:text>dto.set</xsl:text>
					<xsl:call-template name="column-Name"/>
					<xsl:text>( new </xsl:text>
					<xsl:value-of select="db:type"/>
					<xsl:text>( System.currentTimeMillis()));
</xsl:text>
				</xsl:when>
				<xsl:when test="db:default-value">
					<xsl:text>dto.set</xsl:text>
					<xsl:call-template name="column-Name"/>
					<xsl:text>( </xsl:text>
					<xsl:value-of select="db:default-value"/>
					<xsl:text> );
</xsl:text>
				</xsl:when>
				<xsl:when test="db:not-null or db:pk">
					<xsl:text>throw new DaoException("Value of column '</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>' cannot be null");
</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="stmt-set-null"/>
					<xsl:text>            }
            else {
</xsl:text>
					<xsl:call-template name="stmt-set">
						<xsl:with-param name="uctype" select="$uctype"/>
						<xsl:with-param name="getter" select="$getter4sql"/>
						<xsl:with-param name="notnull" select="1"/>
						<xsl:with-param name="indent" select="'                '"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>            }
</xsl:text>
		</xsl:if>
		<xsl:if test="db:pk or db:not-null or $isprimitive=0 or db:default-value">

			<xsl:if test="db:type='String' and not(db:enum)">
				<xsl:if test="not(db:default-value) and not(db:not-null)">
					<xsl:text>
            if ( </xsl:text>
					<xsl:value-of select="$getter"/>
					<xsl:text> != null ) {
</xsl:text>
				</xsl:if>
				<xsl:call-template name="insert-String-not-null">
					<xsl:with-param name="indent">
						<xsl:if test="not(db:default-value) and not(db:not-null)">
							<xsl:text>    </xsl:text>
						</xsl:if>
						<xsl:text>            </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="not(db:default-value) and not(db:not-null)">
					<xsl:text>            }
</xsl:text>
				</xsl:if>
			</xsl:if>

			<xsl:call-template name="stmt-set">
				<xsl:with-param name="uctype" select="$uctype"/>
				<xsl:with-param name="getter" select="$getter4sql"/>
				<xsl:with-param name="notnull" select="count(db:not-null)"/>
				<xsl:with-param name="indent" select="'            '"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="insert-String-not-null">
		<xsl:param name="indent"/>
		<xsl:if test="not(db:default-value)">
			<xsl:value-of select="$indent"/>
			<xsl:call-template name="check-Length"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="check-Length">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="getter">
			<xsl:call-template name="getter">
				<xsl:with-param name="ctx" select="$ctx"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="isexpr"/>

		<xsl:text>check</xsl:text>
		<xsl:if test="not($ctx/db:type/@min-length)">
			<xsl:text>Max</xsl:text>
		</xsl:if>
		<xsl:text>Length( "</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>", </xsl:text>
		<xsl:if test="$ctx/db:type/@class='java.lang.String' or $ctx/db:type/@class='String'">
			<xsl:text>(Object) </xsl:text>
		</xsl:if>
		<xsl:value-of select="$getter"/>
		<xsl:if test="$ctx/db:type/@min-length">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$ctx/db:type/@min-length"/>
		</xsl:if>
		<xsl:text>, </xsl:text>
		<xsl:choose>
			<xsl:when test="$ctx/db:type/@max-length">
				<xsl:value-of select="$ctx/db:type/@max-length"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> )</xsl:text>
		<xsl:if test="not($isexpr=1)">
			<xsl:text>;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="check-Null">
		<xsl:text>        checkNull( "</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>", </xsl:text>
		<xsl:call-template name="column-name"/>
		<xsl:text> );
</xsl:text>
	</xsl:template>


	<xsl:template name="stmt-set">
		<xsl:param name="uctype"/>
		<xsl:param name="getter"/>
		<xsl:param name="notnull"/>
		<xsl:param name="indent"/>
		<xsl:value-of select="$indent"/>
		<xsl:text>stmt.set</xsl:text>
		<xsl:choose>
			<xsl:when test="$uctype = 'Boolean'">
				<xsl:text>Byte( </xsl:text>
				<xsl:value-of select="position()"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text> ? ((byte)1) : ((byte)0)</xsl:text>
			</xsl:when>

			<xsl:when test="$uctype = 'Byte[]' or $uctype = 'Serializable'">
				<xsl:text>Bytes( </xsl:text>
				<xsl:value-of select="position()"/>
				<xsl:text>,  </xsl:text>
				<xsl:call-template name="check-Length">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="isexpr" select="1"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$uctype"/>
				<xsl:text>( </xsl:text>
				<xsl:value-of select="position()"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:if test="$uctype = 'Boolean'">
					<xsl:text> ? ((byte)1) : ((byte)0)</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text> );
</xsl:text>
	</xsl:template>


	<xsl:template name="stmt-set-null">
		<xsl:text>stmt.setNull( </xsl:text>
		<xsl:value-of select="position()"/>
		<xsl:text>, Types.</xsl:text>
		<xsl:call-template name="sql-type"/>
		<xsl:text> );
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-counter">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        return count( </xsl:text>
		<xsl:call-template name="finder-condition"/>
		<xsl:call-template name="finder-params"/>
		<xsl:text>);
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
			<xsl:text>, 0, -1</xsl:text>
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


	<xsl:template name="mbody-finder">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="isunique">
			<xsl:call-template name="is-unique-condition"/>
		</xsl:variable>

		<xsl:call-template name="find-one-or-many">
			<xsl:with-param name="isunique" select="$isunique"/>
		</xsl:call-template>

		<xsl:call-template name="finder-condition">
			<xsl:with-param name="isunique" select="$isunique"/>
		</xsl:call-template>

		<xsl:if test="$isunique != 1">
			<xsl:text>, </xsl:text>
			<xsl:choose>
				<xsl:when test="db:dynamic or db:range">
					<xsl:text>offset, count</xsl:text>
				</xsl:when>
				<xsl:when test="@limit">
					<xsl:text>0, </xsl:text>
					<xsl:value-of select="@limit"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0, -1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:call-template name="finder-params"/>
		<xsl:text>);
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="finder-condition">
		<xsl:variable name="orderby">
			<xsl:call-template name="order-by"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="db:pk">
				<xsl:text>PK_CONDITION</xsl:text>
				<xsl:if test="db:order-by">
					<xsl:text> + "</xsl:text>
					<xsl:value-of select="$orderby"/>
					<xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="db:index">
				<xsl:call-template name="finder-condition-index"/>
			</xsl:when>
			<xsl:when test="db:condition">
				<xsl:text>"</xsl:text>
				<xsl:call-template name="condition-query"/>
				<xsl:value-of select="$orderby"/>
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:when test="db:dynamic">
				<xsl:text>cond</xsl:text>
				<xsl:if test="db:order-by">
					<xsl:text> + "</xsl:text>
					<xsl:value-of select="$orderby"/>
					<xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="db:ref">
				<xsl:call-template name="finder-condition-ref"/>
			</xsl:when>
			<xsl:when test="db:order-by">
				<xsl:text>"1=1</xsl:text>
				<xsl:value-of select="$orderby"/>
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:when test="db:all">
				<xsl:text>null</xsl:text>
			</xsl:when>
		</xsl:choose>
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
		<xsl:if test="db:order-by">
			<xsl:text> + "</xsl:text>
			<xsl:call-template name="order-by"/>
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="finder-condition-ref">
		<xsl:variable name="refname" select="db:ref/@table"/>
		<xsl:variable name="reftable" select="/db:database/db:tables/db:table[@name=$refname]"/>
		<xsl:variable name="refcol" select="$reftable/db:columns/db:column[db:ref/@table = $table_name]"/>
		<xsl:variable name="lname" select="$refcol/db:ref/@column"/>
		<xsl:variable name="rname" select="$refcol/@name"/>

		<xsl:text>"</xsl:text>
		<xsl:value-of select="$lname"/>
		<xsl:text> in (select </xsl:text>
		<xsl:value-of select="$rname"/>
		<xsl:text> from </xsl:text>
		<xsl:value-of select="$refname"/>
		<xsl:text> where </xsl:text>
		<xsl:for-each select="$reftable/db:columns/db:column[@name != $rname]">
			<xsl:call-template name="and-if-next"/>
			<xsl:value-of select="@name"/>
			<xsl:text>=?</xsl:text>
		</xsl:for-each>
		<xsl:text> )</xsl:text>
		<xsl:call-template name="order-by"/>
		<xsl:text>"</xsl:text>
	</xsl:template>


	<xsl:template name="finder-params">
		<xsl:choose>
			<xsl:when test="db:all"/>
			<xsl:when test="db:pk">
				<xsl:call-template name="pk-param-names"/>
			</xsl:when>
			<xsl:when test="db:index">
				<xsl:call-template name="finder-params-index"/>
			</xsl:when>
			<xsl:when test="db:condition">
				<xsl:call-template name="finder-params-condition"/>
			</xsl:when>
			<xsl:when test="db:dynamic">
				<xsl:text>, params</xsl:text>
			</xsl:when>
			<xsl:when test="db:ref">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="finder-params-ref"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="finder-params-index">
		<xsl:variable name="name" select="db:index/@name"/>
		<xsl:variable name="ind" select="../../db:indexes/db:index[@name = $name]"/>
		<xsl:call-template name="index-param-values">
			<xsl:with-param name="columns" select="../../db:columns"/>
			<xsl:with-param name="columnrefs" select="$ind/db:columns/db:column"/>
			<xsl:with-param name="idx">
				<xsl:call-template name="index-level"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="finder-params-condition">
		<xsl:param name="ctx" select="db:condition"/>
		<xsl:for-each select="$ctx/db:params/*">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="param-val"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="finder-params-ref">
		<xsl:variable name="refname" select="db:ref/@table"/>
		<xsl:variable name="reftable" select="/db:database/db:tables/db:table[@name=$refname]"/>
		<xsl:variable name="refcol" select="$reftable/db:columns/db:column[db:ref/@table = $table_name]"/>
		<xsl:variable name="lname" select="$refcol/db:ref/@column"/>
		<xsl:variable name="rname" select="$refcol/@name"/>
		<xsl:for-each select="$reftable/db:columns/db:column[@name != $rname]">
			<xsl:call-template name="comma-if-next"/>
			<xsl:call-template name="column-val"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="order-by">
		<xsl:if test="db:order-by">
			<xsl:call-template name="order-by-syntax"/>
			<xsl:call-template name="order-by-items"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="order-by-items">
		<xsl:for-each select="db:order-by/db:column">
			<xsl:call-template name="comma-if-next"/>
			<xsl:variable name="colname" select="@name"/>
			<xsl:variable name="col" select="../../../../db:columns/db:column[@name=$colname]"/>
			<xsl:if test="not($col)">
				<xsl:message terminate="yes">
					The referenced column name '<xsl:value-of select="$colname"/>' does not exist.
					In table '<xsl:value-of select="../../../../@name"/>' method '<xsl:value-of select="local-name(../..)"/>' with name '<xsl:value-of select="../../@name"/>' - order-by clause.
				</xsl:message>
			</xsl:if>
			<xsl:call-template name="get-order-expr">
				<xsl:with-param name="ctx" select="$col"/>
			</xsl:call-template>
			<xsl:if test="@desc = 'true'">
				<xsl:text> desc</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="order-by-syntax">
		<xsl:text> ORDER BY </xsl:text>
	</xsl:template>


	<xsl:template name="find-one-or-many">
		<xsl:param name="idx" select="0"/>
		<xsl:param name="isunique"/>
		<xsl:text>        return find</xsl:text>
		<xsl:choose>
			<xsl:when test="$isunique=1 or $idx=0 and db:unique">
				<xsl:text>One</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Many</xsl:text>
				<xsl:value-of select="$dao_Findmany"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>( </xsl:text>
	</xsl:template>


	<xsl:template name="mbody-update-batch">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        return update</xsl:text>
		<xsl:choose>
			<xsl:when test="db:unique or db:pk">
				<xsl:text>One( "</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Many( "</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="db:set/db:query">
				<xsl:value-of select="db:set/db:query"/>
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="columns" select="../../db:columns"/>
				<xsl:for-each select="db:set/db:params/db:column">
					<xsl:call-template name="comma-if-next"/>
					<xsl:value-of select="@name"/>
					<xsl:variable name="name" select="@name"/>
					<xsl:variable name="col" select="$columns/db:column[@name=$name]"/>

					<xsl:choose>
						<xsl:when test="$col/db:not-null or $col/db:pk">
							<xsl:text>=?</xsl:text>
							<xsl:if test="position() = last()">
								<xsl:text>"</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>" + (new</xsl:text>
							<xsl:call-template name="column-name">
								<xsl:with-param name="ctx" select="$col"/>
								<xsl:with-param name="capital" select="1"/>
							</xsl:call-template>
							<xsl:text> != null ? "=?" : "=NULL")</xsl:text>
							<xsl:if test="position() != last()">
								<xsl:text> + "</xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="finder-condition"/>
		<xsl:call-template name="finder-params-condition">
			<xsl:with-param name="ctx" select="db:set"/>
		</xsl:call-template>
		<xsl:call-template name="finder-params"/>
		<xsl:text>);
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-delete">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        return delete</xsl:text>
		<xsl:choose>
			<xsl:when test="db:pk or db:unique">
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
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-truncate">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        executeUpdate( getTruncateSql());
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-mover">
		<xsl:text> {
        String sqlInsert = getInsertSelect( "</xsl:text>
		<xsl:value-of select="@target"/>
		<xsl:text>", </xsl:text>
		<xsl:call-template name="finder-condition"/>
		<xsl:text>);
        debugSql( sqlInsert );
        executeUpdate( sqlInsert</xsl:text>
		<xsl:call-template name="finder-params"/>
		<xsl:text> );

        String sqlDelete = getDeleteSql( </xsl:text>
		<xsl:call-template name="finder-condition"/>
		<xsl:text>
            + " AND EXISTS (SELECT * FROM </xsl:text>
		<xsl:value-of select="@target"/>
		<xsl:text> t2 WHERE </xsl:text>
		<xsl:for-each select="../../db:columns/db:column[db:pk]">
			<xsl:call-template name="and-if-next"/>
			<xsl:text>t2.</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>=" + getTableName() + ".</xsl:text>
			<xsl:value-of select="@name"/>
		</xsl:for-each>
		<xsl:text>)" );
        debugSql( sqlDelete );
        executeUpdate( sqlDelete</xsl:text>
		<xsl:call-template name="finder-params"/>
		<xsl:text> );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="index-condition">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>

		<xsl:text>"</xsl:text>
		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">

				<xsl:call-template name="and-if-next"/>
				<xsl:value-of select="@name"/>
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="col" select="$columns/db:column[@name=$name]"/>

				<xsl:choose>
					<xsl:when test="$col/db:not-null or $col/db:pk">
						<xsl:text>=?</xsl:text>
						<xsl:if test="position() = last() - $idx">
							<xsl:text>"</xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>" + (</xsl:text>
						<xsl:call-template name="column-name">
							<xsl:with-param name="ctx" select="$col"/>
						</xsl:call-template>
						<xsl:text> != null ? "=?" : " IS NULL")</xsl:text>
						<xsl:if test="position() != last() - $idx">
							<xsl:text> + "</xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="index-param-values">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>

		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:text>, </xsl:text>
				<xsl:variable name="name" select="@name"/>
				<xsl:call-template name="column-val">
					<xsl:with-param name="ctx" select="$columns/db:column[@name=$name]"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="get-order-expr">
		<xsl:param name="ctx" select="."/>
		<xsl:value-of select="@name"/>
	</xsl:template>


	<xsl:template name="pk-param-names">
		<xsl:param name="nocomma"/>
		<xsl:for-each select="$daoctx/db:columns/db:column[db:pk]">
			<xsl:if test="not($nocomma) or position()!=1">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="column-val"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="condition-query">
		<xsl:variable name="query" select="db:condition/db:query[@dbtype=$db_type]"/>
		<xsl:choose>
			<xsl:when test="$query">
				<xsl:value-of select="$query"/>
			</xsl:when>
			<xsl:when test="db:condition/db:query[not(@dbtype)]">
				<xsl:value-of select="db:condition/db:query[not(@dbtype)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
	Condition not supported by DB type '<xsl:value-of select="$db_type"/>'
	in method '<xsl:value-of select="local-name()"/><xsl:call-template name="method-name"/>' in table '<xsl:value-of select="../../@name"/>'
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="open-mbody">
		<xsl:text> {
</xsl:text>
	</xsl:template>

	<xsl:template name="close-mbody">
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="and-if-next">
		<xsl:if test="position() != 1">
			<xsl:text> and </xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="if-modified">
		<xsl:text>
        if ( </xsl:text>
		<xsl:choose>
			<xsl:when test="db:not-null or db:pk">
				<xsl:call-template name="getter"/>
				<xsl:text> != null </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>is</xsl:text>
				<xsl:call-template name="column-Name"/>
				<xsl:text>Modified()</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>) {
</xsl:text>
	</xsl:template>

	<xsl:template name="if-not-null">
		<xsl:text>
        if ( </xsl:text>
		<xsl:call-template name="getter"/>
		<xsl:text> != null) {
</xsl:text>
	</xsl:template>


	<xsl:template name="getter">
		<xsl:variable name="camelname">
			<xsl:call-template name="column-Name"/>
		</xsl:variable>
		<xsl:value-of select="concat(concat('dto.get',$camelname),'()')"/>
	</xsl:template>

	<!-- Assume the value is not null -->
	<xsl:template name="getter4sql">
		<xsl:variable name="getter">
			<xsl:call-template name="getter"/>
		</xsl:variable>
		<xsl:choose>
			<!-- TODO byte ??-->
			<xsl:when test="db:enum and db:type = 'String' and not(db:not-null)">
				<xsl:value-of select="$getter"/>
				<xsl:text> != null ? </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:choose>
					<xsl:when test="db:enum/db:value[@db]">
						<xsl:text>.getId()</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>.name()</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> : null</xsl:text>
			</xsl:when>
			<xsl:when test="db:enum/db:value[@id or @db]">
				<xsl:value-of select="concat($getter,'.getId()')"/>
			</xsl:when>
			<xsl:when test="db:enum and db:type = 'String'">
				<xsl:value-of select="concat($getter,'.name()')"/>
			</xsl:when>
			<xsl:when test="db:enum">
				<xsl:if test="db:type = 'short'">
					<xsl:text>(short) (</xsl:text>
				</xsl:if>
				<xsl:value-of select="concat($getter,'.ordinal() + 1')"/>
				<xsl:if test="db:type = 'short'">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$getter"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="is-primitive">
		<xsl:choose>
			<xsl:when test="db:type = 'boolean' or db:type = 'short' or db:type = 'int' or db:type = 'long' or db:type = 'double'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sql-type">
		<xsl:choose>
			<xsl:when test="db:type='boolean'">TINYINT</xsl:when>
			<xsl:when test="db:type='short'">SMALLINT</xsl:when>
			<xsl:when test="db:type='int'">INTEGER</xsl:when>
			<xsl:when test="db:type='long'">BIGINT</xsl:when>
			<xsl:when test="db:type='double'">DOUBLE</xsl:when>
			<xsl:otherwise>
				<xsl:message>UNKNOWN primitive type <xsl:value-of select="db:type"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="db-conf-elem-dbtype">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="type"/>
		<xsl:param name="elem"/>
		<xsl:param name="def"/>
		<xsl:variable name="p" select="$ctx/db:config/*[local-name()=$type]/*[local-name()=$elem]"/>
		<xsl:choose>
			<xsl:when test="$p">
				<xsl:call-template name="filter-by-dbtype">
					<xsl:with-param name="ctx" select="$p"/>
					<xsl:with-param name="def" select="$def"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pp" select="$db_conf/*[local-name()=$type]/*[local-name()=$elem]"/>
				<xsl:choose>
					<xsl:when test="$pp">
						<xsl:call-template name="filter-by-dbtype">
							<xsl:with-param name="ctx" select="$pp"/>
							<xsl:with-param name="def" select="$def"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$def"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="filter-by-dbtype">
		<xsl:param name="ctx" select="."/>
		<xsl:param name="def"/>
		<xsl:choose>
			<xsl:when test="$ctx/@dbtype=$db_type">
				<xsl:value-of select="$ctx[@dbtype=$db_type]"/>
			</xsl:when>
			<xsl:when test="$ctx[not(@dbtype)]">
				<xsl:value-of select="$ctx[not(@dbtype)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$def"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="dtocache-key-type">
		<xsl:choose>
			<xsl:when test="$keycol or count($daoctx/db:columns/db:column[db:pk]) &gt; 1">
				<xsl:text>String</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="column-ObjectType-raw">
					<xsl:with-param name="ctx" select="$daoctx/db:columns/db:column[db:pk]"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="dtocache-keyval">
		<xsl:choose>
			<xsl:when test="$keycol or count($daoctx/db:columns/db:column[db:pk]) &gt; 1">
				<xsl:text>dtoKey( </xsl:text>
				<xsl:call-template name="dtocache-keyval-key"/>
				<xsl:for-each select="$daoctx/db:columns/db:column[db:pk]">
					<xsl:if test="$keycol or position()!=1">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:call-template name="column-name"/>
				</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="column-name">
					<xsl:with-param name="ctx" select="$daoctx/db:columns/db:column[db:pk]"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="dtocache-keyval-key">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:for-each select="$ctx">
			<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
			<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
			<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

			<xsl:call-template name="dtocache-keyval-key">
				<xsl:with-param name="ctx" select="$pkeycol"/>
			</xsl:call-template>

			<xsl:if test="$pkeycol">
				<xsl:text>, </xsl:text>
			</xsl:if>

			<xsl:call-template name="column-name"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="dtocache-keyval-dto">
		<xsl:param name="dto" select="'_dto'"/>
		<xsl:choose>
			<xsl:when test="$keycol or count($daoctx/db:columns/db:column[db:pk]) &gt; 1">
				<xsl:text>dtoKey( </xsl:text>
				<xsl:call-template name="dtocache-keyval-dto-key">
					<xsl:with-param name="dto" select="$dto"/>
				</xsl:call-template>
				<xsl:for-each select="$daoctx/db:columns/db:column[db:pk]">
					<xsl:if test="$keycol or position()!=1">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="$dto"/>
					<xsl:text>.get</xsl:text>
					<xsl:call-template name="column-Name"/>
					<xsl:text>()</xsl:text>
				</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dto"/>
				<xsl:text>.get</xsl:text>
				<xsl:call-template name="column-Name">
					<xsl:with-param name="ctx" select="$daoctx/db:columns/db:column[db:pk]"/>
				</xsl:call-template>
				<xsl:text>()</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="dtocache-keyval-dto-key">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="dto"/>
		<xsl:for-each select="$ctx">
			<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
			<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
			<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

			<xsl:call-template name="dtocache-keyval-dto-key">
				<xsl:with-param name="ctx" select="$pkeycol"/>
				<xsl:with-param name="dto" select="$dto"/>
			</xsl:call-template>

			<xsl:if test="$pkeycol">
				<xsl:text>, </xsl:text>
			</xsl:if>

			<xsl:value-of select="$dto"/>
			<xsl:text>.get</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>()</xsl:text>

		</xsl:for-each>
	</xsl:template>


	<xsl:template name="dtocache-factory-impl">
		<xsl:param name="tpl"/>
		<xsl:text>new MemoryDtoCacheFactoryImpl</xsl:text>
		<xsl:value-of select="$tpl"/>
		<xsl:text>()</xsl:text>
	</xsl:template>


	<xsl:template name="dtokey">
		<xsl:text>dtoKey( </xsl:text>
		<xsl:call-template name="pk-param-names">
			<xsl:with-param name="nocomma" select="1"/>
		</xsl:call-template>
		<xsl:text> )</xsl:text>
	</xsl:template>

</xsl:stylesheet>
