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
	xmlns:java="http://xml.apache.org/xalan/java"
>

	<xsl:import href="..@DIR_SEP@dao-impl.xsl"/>
	<xsl:import href="common.xsl"/>

	<xsl:output
		method="text"
		indent="yes"
		encoding="utf-8"/>

	<xsl:param name="pkg_db"/>
	<xsl:param name="table_name"/>

	<xsl:variable name="own-columns" select="$daoctx/db:columns/db:column[not(@defined-by)]"/>
	<xsl:variable name="gqlparser" select="java:com.spoledge.audao.parser.gql.GqlStatic.new()"/>


	<xsl:template name="imports-java">
		<xsl:if test="db:methods/db:insert-all">
import java.util.LinkedList;
import java.util.List;
		</xsl:if>
		<xsl:if test="db:columns/db:column[(db:type = 'byte[]' or db:type = 'Serializable') and not(db:type/@max-length &lt; 501)]">
			<xsl:text>
import com.google.appengine.api.datastore.Blob;</xsl:text>
		</xsl:if>
		<xsl:text>
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
</xsl:text>
		<xsl:if test="db:columns/db:column[(db:type = 'byte[]' or db:type = 'Serializable') and db:type/@max-length &lt; 501]">
			<xsl:text>
import com.google.appengine.api.datastore.ShortBlob;</xsl:text>
		</xsl:if>
		<xsl:if test="db:columns/db:column[db:type = 'String' and db:type/@max-length &gt; 500]">
			<xsl:text>
import com.google.appengine.api.datastore.Text;</xsl:text>
		</xsl:if>
		<xsl:text>
</xsl:text>
	</xsl:template>


	<xsl:template name="imports-audao-impl">
		<xsl:if test="$defcache">
			<xsl:text>import com.spoledge.audao.db.dao.gae.MemchainDtoCacheFactoryImpl;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="imports-jdbc">
		<xsl:text>
import java.sql.Date;
import java.sql.Timestamp;
</xsl:text>
	</xsl:template>


	<xsl:template name="import-abstract-dao-impl">
		<xsl:text>
import com.spoledge.audao.db.dao.gae.GaeAbstractDaoImpl;
</xsl:text>
	</xsl:template>


	<xsl:template name="abstract-dao-impl-name">
		<xsl:text>GaeAbstractDaoImpl</xsl:text>
	</xsl:template>


	<xsl:template name="db-name">
		<xsl:param name="ctx" select="."/>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
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
		<xsl:text>( DatastoreService ds ) {
        super( ds );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-get-select-columns">
	</xsl:template>


	<xsl:template name="method-fetch">
		<xsl:call-template name="method-fetch-impl"/>
		<xsl:if test="db:methods/db:insert-all">
			<xsl:call-template name="method-to-entity"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="method-fetch-impl">
		<xsl:text>
    protected </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> fetch( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto, Entity ent ) {
        if ( dto == null ) dto = new </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>();
</xsl:text>
		<xsl:if test="@extends">
			<xsl:text>
        super.fetch( dto, ent );
</xsl:text>
		</xsl:if>
		<xsl:text>
</xsl:text>
		<xsl:for-each select="$own-columns">
			<xsl:variable name="iscoreclass">
				<xsl:if test="db:type/@class">
					<xsl:call-template name="is-gae-core-class">
						<xsl:with-param name="cls" select="db:type/@class"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>

			<xsl:text>        dto.set</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>( </xsl:text>
			<xsl:choose>

				<xsl:when test="db:pk">
					<xsl:text>ent.getKey()</xsl:text>
					<xsl:call-template name="key-to-native"/>
				</xsl:when>

				<xsl:when test="db:ref[@gae-parent='true']">
					<xsl:text>ent.getParent() != null ? ent.getParent()</xsl:text>
					<xsl:call-template name="key-to-native"/>
					<xsl:text> : null</xsl:text>
				</xsl:when>

				<xsl:when test="db:enum">
					<xsl:text>ent.getProperty( "</xsl:text>
					<xsl:call-template name="java-name"/>
					<xsl:text>" ) != null ? </xsl:text>
					<xsl:call-template name="enum-get-by-id">
						<xsl:with-param name="id">
							<xsl:text>getInteger( ent, "</xsl:text>
							<xsl:call-template name="java-name"/>
							<xsl:text>" )</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> : null</xsl:text>
				</xsl:when>

				<xsl:when test="db:type = 'byte[]'">
					<xsl:text>getByteArray( ent, "</xsl:text>
					<xsl:call-template name="java-name"/>
					<xsl:text>" )</xsl:text>
				</xsl:when>

				<xsl:when test="db:type = 'List' or db:type='Serializable' and db:type/@class='java.util.List'">
					<xsl:text>getList</xsl:text>
					<xsl:if test="$iscoreclass!=1 or (db:type='List' and db:type/@max-length)">
						<xsl:text>OfObjects</xsl:text>
					</xsl:if>
					<xsl:text>( ent, "</xsl:text>
					<xsl:call-template name="java-name"/>
					<xsl:text>"</xsl:text>
					<xsl:if test="db:type/@class and db:type='List'">
						<xsl:text>, </xsl:text>
						<xsl:call-template name="objectType-raw">
							<xsl:with-param name="ctx" select="db:type"/>
							<xsl:with-param name="islist" select="0"/>
						</xsl:call-template>
						<xsl:text>.class</xsl:text>
					</xsl:if>
					<xsl:text> )</xsl:text>
				</xsl:when>

				<xsl:when test="db:type = 'Serializable' and $iscoreclass=1 and not(db:type/@max-length)">
					<xsl:text>getCoreObject( ent, "</xsl:text>
					<xsl:call-template name="java-name"/>
					<xsl:text>", </xsl:text>
					<xsl:call-template name="column-ObjectType-raw"/>
					<xsl:text>.class )</xsl:text>
				</xsl:when>

				<xsl:when test="db:type = 'Serializable'">
					<xsl:text>getObject( ent, "</xsl:text>
					<xsl:call-template name="java-name"/>
					<xsl:text>", </xsl:text>
					<xsl:call-template name="column-ObjectType-raw"/>
					<xsl:text>.class )</xsl:text>
				</xsl:when>

				<xsl:otherwise>
					<xsl:text>get</xsl:text>
					<xsl:call-template name="column-ObjectType-raw"/>
					<xsl:text>( ent, "</xsl:text>
					<xsl:call-template name="java-name"/>
					<xsl:text>" )</xsl:text>
				</xsl:otherwise>

			</xsl:choose>

			<xsl:text>);
</xsl:text>
		</xsl:for-each>
		<xsl:call-template name="fetch-keys"/>
		<xsl:text>
        return dto;
</xsl:text>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="method-to-entity">
		<xsl:text>
    protected Entity prepareForInsert( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto ) throws DaoException {
</xsl:text>
		<xsl:call-template name="insert-fill-entity"/>
		<xsl:text>
        return _ent;
    }
</xsl:text>
	</xsl:template>

	<xsl:template name="fetch-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="depth" select="1"/>
		<xsl:if test="$ctx">
			<xsl:if test="$depth != 1">
				<xsl:text>        dto.set</xsl:text>
				<xsl:call-template name="key-Name">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
				<xsl:text>( parentKeyAs</xsl:text>
				<xsl:call-template name="column-Type">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
				<xsl:text>( ent.getKey(), </xsl:text>
				<xsl:value-of select="$depth"/>
				<xsl:text>));
</xsl:text>
			</xsl:if>

			<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
			<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
			<xsl:call-template name="fetch-keys">
				<xsl:with-param name="ctx" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="depth" select="$depth + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="mbody-find-by-pk">
		<xsl:call-template name="open-mbody"/>
		<xsl:if test="$defcache and not(db:use-no-cache)">
			<xsl:if test="$keycol">
				<xsl:text>        </xsl:text>
				<xsl:text>String _key = </xsl:text>
				<xsl:call-template name="dtokey"/>
				<xsl:text>;
</xsl:text>
			</xsl:if>
			<xsl:text>        </xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text> _dto = _defaultCache.get( </xsl:text>

			<xsl:choose>
				<xsl:when test="$keycol">
					<xsl:text>_key</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="pk-param-name"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:text> );

        if ( _dto != null ) {
            if (log.isDebugEnabled()) {
                log.debug("find-by-pk(): dto found in cache: " + _dto );
            }

            return copyOf( _dto );
        }

</xsl:text>
		</xsl:if>
		<xsl:call-template name="fetch-by-pk"/>
		<xsl:choose>
			<xsl:when test="$defcache">
				<xsl:text>
        if ( _ent == null ) return null;

        </xsl:text>
				<xsl:if test="db:use-no-cache">
					<xsl:call-template name="dto-name"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>_dto = fetch( null, _ent );
        _defaultCache.put( </xsl:text>

				<xsl:choose>
					<xsl:when test="$keycol and db:use-no-cache">
						<xsl:call-template name="dtokey"/>
					</xsl:when>
					<xsl:when test="$keycol">
						<xsl:text>_key</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="pk-param-name"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:text>, copyOf( _dto ));

        return _dto;
    }
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>
        return _ent != null ? fetch( null, _ent ) : null;
    }
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="mbody-delete-by-pk">
		<xsl:choose>
			<xsl:when test="$defcache">
				<xsl:text> {
        boolean _ret = entityDelete( </xsl:text>
				<xsl:call-template name="key-by-params"/>
				<xsl:text> );
        _defaultCache.remove( </xsl:text>
				<xsl:call-template name="dtocache-keyval"/>
				<xsl:text> );

        return _ret;
    }
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> {
        return entityDelete( </xsl:text>
				<xsl:call-template name="key-by-params"/>
				<xsl:text> );
    }
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="mbody-finder-index">
		<xsl:param name="idx"/>
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        Query _query = getQuery();
</xsl:text>

		<xsl:call-template name="index-query">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:text>
</xsl:text>

		<xsl:call-template name="find-one-or-many">
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:text>_query, "</xsl:text>

		<xsl:call-template name="index-condition">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:choose>
			<xsl:when test="$idx != 0 or not(db:unique)">
				<xsl:text>", 0, -1</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>", 0</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:call-template name="index-param-values-plain">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>

		<xsl:text>);
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-finder">
		<xsl:choose>
			<xsl:when test="db:pk">
				<xsl:call-template name="mbody-find-by-pk">
					<xsl:with-param name="ctx" select="../.."/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="mbody-finder-generic"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="mbody-counter">
		<xsl:call-template name="mbody-finder-generic"/>
	</xsl:template>


	<xsl:template name="mbody-delete">
		<xsl:choose>
			<xsl:when test="db:pk">
				<xsl:call-template name="mbody-delete-by-pk">
					<xsl:with-param name="ctx" select="../.."/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="mbody-finder-generic"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="mbody-update-batch">
		<xsl:call-template name="warning">
			<xsl:with-param name="errcode" select="'GAE_BATCH_UPDATE_NOT_SUPPORTED'"/>
			<xsl:with-param name="table" select="../.."/>
			<xsl:with-param name="coltype" select="'METHOD'"/>
		</xsl:call-template>
		<xsl:text> {
        throw new Error("Update method is not supported by GAE DAO implementation.");
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-truncate">
		<xsl:call-template name="warning">
			<xsl:with-param name="errcode" select="'GAE_TRUNCATE_NOT_SUPPORTED'"/>
			<xsl:with-param name="table" select="../.."/>
			<xsl:with-param name="coltype" select="'METHOD'"/>
		</xsl:call-template>
		<xsl:text> {
        throw new Error("Truncate method is not supported by GAE DAO implementation.");
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-mover">
		<xsl:call-template name="warning">
			<xsl:with-param name="errcode" select="'GAE_MOVE_NOT_SUPPORTED'"/>
			<xsl:with-param name="table" select="../.."/>
			<xsl:with-param name="coltype" select="'METHOD'"/>
		</xsl:call-template>
		<xsl:text> {
        throw new Error("Move method is not supported by GAE DAO implementation.");
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-finder-generic">
		<xsl:call-template name="open-mbody"/>
		<xsl:variable name="isunique">
			<xsl:call-template name="is-unique-condition"/>
		</xsl:variable>
		<xsl:text>        Query _query = getQuery();
</xsl:text>

		<xsl:call-template name="finder-query"/>

		<xsl:text>
        return </xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:choose>
			<xsl:when test="local-name() = 'count'"/>
			<xsl:when test="$isunique = 1">
				<xsl:text>One</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Many</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text>( _query, </xsl:text>
		<xsl:if test="not(db:dynamic)">
			<xsl:text>_</xsl:text>
		</xsl:if>

		<xsl:text>cond</xsl:text>

		<xsl:choose>
			<xsl:when test="local-name() = 'count'"/>
			<xsl:when test="$isunique = 1 and local-name() = 'find'">
				<xsl:text>, 0</xsl:text>
			</xsl:when>
			<xsl:when test="(db:range or db:dynamic) and local-name() = 'find'">
				<xsl:text>, offset, count</xsl:text>
			</xsl:when>
			<xsl:when test="@limit">
				<xsl:text>, 0, </xsl:text>
				<xsl:value-of select="@limit"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>, 0, -1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:call-template name="finder-params-plain"/>

		<xsl:text> );
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="insert-fill-entity">
		<xsl:if test="$keycol">
			<xsl:call-template name="insert-key-check-null">
				<xsl:with-param name="ctx" select="$keycol"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="pkman" select="db:columns/db:column[db:pk and not(db:auto)]"/>
		<xsl:for-each select="$pkman">
			<xsl:text>        checkNull( "</xsl:text>
			<xsl:call-template name="java-name"/>
			<xsl:text>", dto.get</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>());
</xsl:text>
		</xsl:for-each>

		<xsl:if test="$keycol or $pkman">
			<xsl:text>
</xsl:text>
		</xsl:if>

		<xsl:text>        Entity _ent = new Entity( </xsl:text>
		<xsl:if test="not($pkman)">
			<xsl:text>"</xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text>"</xsl:text>
			<xsl:if test="$keycol">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$keycol">
			<xsl:call-template name="key-object">
				<xsl:with-param name="ctx" select="$keycol"/>
				<xsl:with-param name="src" select="'dto'"/>
				<xsl:with-param name="isfirst" select="1 - count($pkman)"/>
			</xsl:call-template>
			<xsl:if test="$pkman">
				<xsl:text>.addChild( "</xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:if test="not($keycol) and $pkman">
			<xsl:text>new KeyFactory.Builder( "</xsl:text>
		</xsl:if>
		<xsl:if test="$pkman">
			<xsl:call-template name="dto-name"/>
			<xsl:text>", dto.get</xsl:text>
			<xsl:call-template name="java-Name">
				<xsl:with-param name="ctx" select="$pkman"/>
			</xsl:call-template>
			<xsl:text>()).getKey()</xsl:text>
		</xsl:if>

		<xsl:text>);

        {</xsl:text>
		<xsl:for-each select="db:columns/db:column[not(db:ref/@gae-parent = 'true' or db:pk or db:auto and db:type != 'Date' and db:type != 'Timestamp')]">
			<xsl:call-template name="set-column-insert"/>
		</xsl:for-each>
		<xsl:for-each select="db:columns/db:column[not(db:ref/@gae-parent = 'true' or db:pk) and db:auto and db:type != 'Date' and db:type != 'Timestamp']">
			<xsl:call-template name="set-column-insert-auto"/>
		</xsl:for-each>
		<xsl:text>        }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-insert">
		<xsl:call-template name="open-mbody"/>
		<xsl:choose>
			<xsl:when test="db:methods/db:insert-all">
				<xsl:text>        Entity _ent = prepareForInsert( dto );
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="insert-fill-entity"/>
			</xsl:otherwise>
		</xsl:choose>
			
		<xsl:text>
        entityPut( _ent, dto, "insert" );
</xsl:text>
		<xsl:if test="$ispkauto=1">
			<xsl:text>
        dto.set</xsl:text>
			<xsl:call-template name="pk-Name"/>
			<xsl:text>( _ent.getKey()</xsl:text>
			<xsl:call-template name="key-to-native">
				<xsl:with-param name="ctx" select="db:columns/db:column[db:pk]"/>
			</xsl:call-template>
			<xsl:text>);
</xsl:text>
		</xsl:if>
		<xsl:if test="$defcache">
			<xsl:text>
        _defaultCache.put( </xsl:text>
			<xsl:call-template name="dtocache-keyval-dto">
				<xsl:with-param name="dto" select="'dto'"/>
			</xsl:call-template>
			<xsl:text>, copyOf( dto ));
</xsl:text>
		</xsl:if>
		<xsl:if test="$ispkauto=1">
			<xsl:text>
        return dto.get</xsl:text>
			<xsl:call-template name="pk-Name"/>
			<xsl:text>();
</xsl:text>
		</xsl:if>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>


	<xsl:template name="mbody-insert-all">
		<xsl:call-template name="open-mbody"/>
		<xsl:text>        LinkedList&lt;Entity&gt; _ents = new LinkedList&lt;Entity&gt;();
        for ( </xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text> dto : dtos ) {
            _ents.add( prepareForInsert( dto ));
        }

        </xsl:text>
		<xsl:if test="$defcache or $ispkauto=1">
			<xsl:text>List&lt;Key&gt; _keys = </xsl:text>
		</xsl:if>
		<xsl:text>entityPut( _ents, dtos, "insert" );
</xsl:text>

		<xsl:if test="$defcache or $ispkauto=1">
			<xsl:text>
        java.util.Iterator&lt;</xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text>&gt; _dtoiter = dtos.iterator();

        for ( Key _key : _keys ) {
            </xsl:text>
			<xsl:call-template name="dto-name"/>
			<xsl:text> dto = _dtoiter.next();
</xsl:text>
			<xsl:if test="$ispkauto=1">
				<xsl:text>            dto.set</xsl:text>
				<xsl:call-template name="pk-Name">
					<xsl:with-param name="ctx" select="$daoctx"/>
				</xsl:call-template>
				<xsl:text>( _key</xsl:text>
				<xsl:call-template name="key-to-native">
					<xsl:with-param name="ctx" select="$daoctx/db:columns/db:column[db:pk]"/>
				</xsl:call-template>
				<xsl:text>);
</xsl:text>
			</xsl:if>

			<xsl:if test="$defcache">
				<xsl:text>
        _defaultCache.put( </xsl:text>
				<xsl:call-template name="dtocache-keyval-dto">
					<xsl:with-param name="dto" select="'dto'"/>
				</xsl:call-template>
				<xsl:text>, copyOf( dto ));
</xsl:text>
			</xsl:if>

			<xsl:text>        }
</xsl:text>
		</xsl:if>
		<xsl:call-template name="close-mbody"/>
	</xsl:template>



	<xsl:template name="mbody-update-column-body">
		<xsl:param name="autodate"/>
		<xsl:if test="db:ref/@gae-parent = 'true' or db:pk">
			<xsl:message>Updating of key columns is not supported - in table <xsl:value-of select="../../@name"/></xsl:message>
		</xsl:if>
		<xsl:call-template name="fetch-by-pk"/>
		<xsl:text>        if (_ent == null) return false;

</xsl:text>
		<xsl:call-template name="stmt-set">
			<xsl:with-param name="getter">
				<xsl:call-template name="java-name"/>
			</xsl:with-param>
			<xsl:with-param name="notnull" select="count(db:not-null)"/>
			<xsl:with-param name="isupdate" select="1"/>
			<xsl:with-param name="indent" select="'        '"/>
		</xsl:call-template>

		<xsl:call-template name="set-autodate">
			<xsl:with-param name="autodate" select="$autodate"/>
		</xsl:call-template>

		<xsl:text>
        entityPut( _ent, </xsl:text>
		<xsl:call-template name="java-name"/>
		<xsl:text>, "update</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>" );
</xsl:text>
		<xsl:if test="$defcache">
			<xsl:text>
        _defaultCache.put( </xsl:text>
			<xsl:call-template name="dtocache-keyval"/>
			<xsl:text>, fetch( null, _ent ));
</xsl:text>
		</xsl:if>

		<xsl:text>
        return true;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="mbody-update">
		<xsl:if test="db:columns/db:column[db:ref/@gae-parent = 'true' and db:edit]">
			<xsl:message>Updating of key columns is not supported - in table <xsl:value-of select="../../@name"/></xsl:message>
		</xsl:if>
		<xsl:call-template name="open-mbody"/>
		<xsl:call-template name="fetch-by-pk"/>
		<xsl:text>        if (_ent == null) return false;

        boolean isUpdated = false;
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
        if (!isUpdated) {
            return false;
        }
</xsl:text>
		<xsl:call-template name="set-autodate"/>
		<xsl:text>
        entityPut( _ent, dto, "update" );
</xsl:text>
		<xsl:if test="$defcache">
			<xsl:text>
        _defaultCache.put( </xsl:text>
			<xsl:call-template name="dtocache-keyval"/>
			<xsl:text>, fetch( null, _ent ));
</xsl:text>
		</xsl:if>
				<xsl:text>
        return true;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="update-append-null">
		<xsl:text>
        if ( dto.is</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>Modified()) {
</xsl:text>
		<xsl:call-template name="update-append-common"/>
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
		<xsl:call-template name="stmt-set">
			<xsl:with-param name="getter">
				<xsl:text>dto.get</xsl:text>
				<xsl:call-template name="java-Name"/>
				<xsl:text>()</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="notnull" select="count(db:not-null)"/>
			<xsl:with-param name="isupdate" select="1"/>
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
		<xsl:value-of select="$indent"/>
		<xsl:text>isUpdated = true;
</xsl:text>
	</xsl:template>


	<xsl:template name="insert-String-not-null">
		<xsl:param name="indent"/>
		<xsl:if test="not(db:default-value)">
			<xsl:value-of select="$indent"/>
			<xsl:call-template name="check-Length"/>
		</xsl:if>
		<xsl:if test="db:gae/@empty='true' or db:gae/@unindexed='true'">
			<xsl:value-of select="$indent"/>
			<xsl:text>_ent.set</xsl:text>
			<xsl:if test="db:gae/@unindexed='true'">
				<xsl:text>Unindexed</xsl:text>
			</xsl:if>
			<xsl:text>Property( "</xsl:text>
			<xsl:call-template name="java-name"/>
			<xsl:text>", </xsl:text>
			<xsl:if test="db:type/@max-length &gt; 500">
				<xsl:text>new Text( </xsl:text>
			</xsl:if>
			<xsl:text>dto.get</xsl:text>
			<xsl:call-template name="java-Name"/>
			<xsl:text>()</xsl:text>
			<xsl:if test="db:type/@max-length &gt; 500">
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>);
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="stmt-set">
		<xsl:param name="uctype"/>
		<xsl:param name="getter"/>
		<xsl:param name="isupdate"/>
		<xsl:param name="indent"/>
		<xsl:param name="notnull"/>
		<!-- always notnull in context insert()-->

		<xsl:variable name="isnnstr">
			<xsl:if test="not($isupdate) and db:type='String' and $notnull=1 and (db:gae/@empty='true' or db:gae/@unindexed='true')">
				<xsl:value-of select="1"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="not(db:pk or db:ref[@gae-parent='true']) and $isnnstr!=1">
			<xsl:variable name="nn">
				<xsl:choose>
					<xsl:when test="$notnull=1 or (db:gae/@empty='true' or db:gae/@unindexed='true')">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$indent"/>
			<xsl:if test="$notnull!=1 and (db:gae/@empty='true' or db:gae/@unindexed='true')">
				<xsl:text>if (</xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:choose>
					<xsl:when test="$isupdate">
						<xsl:text> == null) </xsl:text>
						<xsl:call-template name="stmt-set-null">
							<xsl:with-param name="isupdate" select="$isupdate"/>
						</xsl:call-template>
						<xsl:value-of select="$indent"/>
						<xsl:text>else </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> != null) </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<xsl:text>_ent.set</xsl:text>
			<xsl:if test="db:gae/@unindexed='true'">
				<xsl:text>Unindexed</xsl:text>
			</xsl:if>
			<xsl:text>Property( "</xsl:text>
			<xsl:call-template name="java-name"/>
			<xsl:text>", </xsl:text>

			<xsl:variable name="iscoreclass">
				<xsl:if test="db:type/@class">
					<xsl:call-template name="is-gae-core-class">
						<xsl:with-param name="cls" select="db:type/@class"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="db:type = 'String' and db:type/@max-length &gt; 500">
					<xsl:if test="$nn=0">
						<xsl:value-of select="$getter"/>
						<xsl:text> == null ? null : </xsl:text>
					</xsl:if>
					<xsl:text>new Text( </xsl:text>
					<xsl:value-of select="$getter"/>
					<xsl:text> )</xsl:text>
				</xsl:when>
				<xsl:when test="db:type = 'Date' or db:type = 'Timestamp'">
					<xsl:if test="$nn=0">
						<xsl:value-of select="$getter"/>
						<xsl:text> == null ? null : </xsl:text>
					</xsl:if>
					<xsl:text>date( </xsl:text>
					<xsl:value-of select="$getter"/>
					<xsl:text> )</xsl:text>
				</xsl:when>
				<xsl:when test="db:type = 'Serializable' and db:type/@class='java.util.List'">
					<xsl:value-of select="$getter"/>
				</xsl:when>
				<xsl:when test="db:type = 'byte[]' or db:type='Serializable' and (not($iscoreclass=1) or db:type/@max-length)">
					<!-- if core type is String/Text/.. and max-length is specified then serialize it -->
					<xsl:if test="$nn=0">
						<xsl:value-of select="$getter"/>
						<xsl:text> == null ? null : </xsl:text>
					</xsl:if>
					<xsl:text>new </xsl:text>
					<xsl:if test="db:type/@max-length &lt; 501">
						<xsl:text>Short</xsl:text>
					</xsl:if>
					<xsl:text>Blob( </xsl:text>
					<xsl:call-template name="check-Length">
						<xsl:with-param name="getter" select="$getter"/>
						<xsl:with-param name="isexpr" select="1"/>
					</xsl:call-template>
					<xsl:text> )</xsl:text>
				</xsl:when>
				<xsl:when test="db:type='List' and (not($iscoreclass=1) or db:type/@max-length)">
					<xsl:choose>
						<xsl:when test="db:type/@max-length &lt; 501">
							<xsl:text>shortB</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>b</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>lobs( </xsl:text>
					<xsl:value-of select="$getter"/>
					<xsl:text> )</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="enum-to-raw">
						<xsl:with-param name="val" select="$getter"/>
						<xsl:with-param name="notnull" select="$nn"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>);
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="stmt-set-null">
		<xsl:param name="isupdate"/>
		<xsl:choose>
			<xsl:when test="$isupdate and (db:gae/@empty='true' or db:gae/@unindexed='true')">
				<xsl:text>_ent.removeProperty( "</xsl:text>
				<xsl:call-template name="java-name"/>
				<xsl:text>" );
</xsl:text>
			</xsl:when>
			<xsl:when test="db:gae/@empty='true' or db:gae/@unindexed='true'">
				<xsl:text>// gae unindexed or empty property
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>_ent.setProperty( "</xsl:text>
				<xsl:call-template name="java-name"/>
				<xsl:text>", null );
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="getter4sql">
		<xsl:text>dto.get</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>()</xsl:text>
	</xsl:template>


	<xsl:template name="catch-sqlexception">
		<xsl:text>        }
        catch (Exception e) {
            throw new DBException( e );
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="catch-sqlexception-write">
		<xsl:param name="sql"/>
		<xsl:param name="params"/>
		<xsl:text>        }
        catch (Exception e) {
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


	<xsl:template name="set-autodate">
		<xsl:param name="autodate" select="db:columns/db:column[db:auto[@on='update' or @on='update-only'] and (db:type='Date' or db:type='Timestamp')]"/>
		<xsl:if test="$autodate">
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:for-each select="$autodate">
			<xsl:text>        _ent.set</xsl:text>
			<xsl:if test="db:gae/@unindexed='true'">
				<xsl:text>Unindexed</xsl:text>
			</xsl:if>
			<xsl:text>Property( "</xsl:text>
			<xsl:call-template name="java-name"/>
			<xsl:text>", date( new </xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>( System.currentTimeMillis())));
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="fetch-by-pk">
		<xsl:text>        Entity _ent = entityGet( </xsl:text>
		<xsl:call-template name="key-by-params"/>
		<xsl:text>);
</xsl:text>
	</xsl:template> 


	<xsl:template name="key-by-params">
		<xsl:choose>
			<xsl:when test="$keycol">
				<xsl:call-template name="key-object">
					<xsl:with-param name="ctx" select="$keycol"/>
					<xsl:with-param name="isfirst" select="0"/>
				</xsl:call-template>
				<xsl:text>.addChild( </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>new KeyFactory.Builder( </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="key-entity-id-pair">
			<xsl:with-param name="ctx" select="$daoctx/db:columns/db:column[db:pk]"/>
		</xsl:call-template>
		<xsl:text> ).getKey()</xsl:text>
	</xsl:template> 


	<xsl:template name="key-object">
		<xsl:param name="ctx"/>
		<xsl:param name="src" select="'param'"/>
		<xsl:param name="isfirst" select="1"/>

		<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
		<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
		<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

		<xsl:choose>
			<xsl:when test="$pkeycol">
				<xsl:call-template name="key-object">
					<xsl:with-param name="ctx" select="$pkeycol"/>
					<xsl:with-param name="src" select="$src"/>
					<xsl:with-param name="isfirst" select="0"/>
				</xsl:call-template>
				<xsl:text>.addChild( </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>new KeyFactory.Builder( </xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:variable name="cname" select="$ctx/@name"/>

		<xsl:call-template name="key-entity-id-pair">
			<xsl:with-param name="ctx" select="$ptable/db:columns/db:column[@name = $cname]"/>
			<xsl:with-param name="src" select="$src"/>
		</xsl:call-template>

		<xsl:if test="$src != 'dto'">
			<xsl:text> </xsl:text>
		</xsl:if>

		<xsl:text>)</xsl:text>
		<xsl:if test="$isfirst = 1">
			<xsl:text>.getKey()</xsl:text>
		</xsl:if>
	</xsl:template> 


	<xsl:template name="key-entity-id-pair">
		<xsl:param name="ctx"/>
		<xsl:param name="src" select='param'/>
		<xsl:text>"</xsl:text>
		<xsl:call-template name="db-name">
			<xsl:with-param name="ctx" select="$ctx/../.."/>
		</xsl:call-template>
		<xsl:text>", </xsl:text>
		<xsl:choose>
			<xsl:when test="$src = 'dto'">
				<xsl:text>dto.get</xsl:text>
				<xsl:call-template name="key-Name">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
				<xsl:text>()</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="key-name">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="get-order-expr">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="$ctx/db:pk or $ctx/db:ref/@gae-parent = 'true'">
				<xsl:text>__key__</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="java-name">
					<xsl:with-param name="ctx" select="$ctx"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="finder-query">
		<xsl:choose>
			<xsl:when test="db:pk"/>
			<xsl:when test="db:all">
				<xsl:call-template name="finder-query-all"/>
			</xsl:when>
			<xsl:when test="db:index">
				<xsl:call-template name="finder-query-index"/>
			</xsl:when>
			<xsl:when test="db:condition">
				<xsl:call-template name="finder-query-condition"/>
			</xsl:when>
			<xsl:when test="db:dynamic">
				<xsl:call-template name="finder-query-dynamic"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error">
					<xsl:with-param name="errcode" select="'GAE_FINDER_NOT_SUPPORTED'"/>
					<xsl:with-param name="table" select="../.."/>
					<xsl:with-param name="coltype" select="'METHOD'"/>
					<xsl:with-param name="detail" select="local-name(db:ref)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="finder-query-all">
		<xsl:text>
        multipleQueries = false;
        String _cond = "1 = 1";
</xsl:text>
	</xsl:template>


	<xsl:template name="finder-query-index">
		<xsl:variable name="name" select="db:index/@name"/>
		<xsl:variable name="ind" select="../../db:indexes/db:index[@name = $name]"/>
		<xsl:variable name="columns" select="../../db:columns"/>
		<xsl:variable name="columnrefs" select="$ind/db:columns/db:column"/>
		<xsl:variable name="idx">
			<xsl:call-template name="index-level"/>
		</xsl:variable>

		<xsl:call-template name="index-query">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
			<xsl:with-param name="islist" select="count(db:index[@list='true'])"/>
		</xsl:call-template>

		<xsl:call-template name="finder-query-orderby">
			<xsl:with-param name="columns" select="$columns"/>
		</xsl:call-template>

		<xsl:text>
        multipleQueries = false;
        String _cond = "</xsl:text>
		<xsl:call-template name="index-condition">
			<xsl:with-param name="columns" select="$columns"/>
			<xsl:with-param name="columnrefs" select="$columnrefs"/>
			<xsl:with-param name="idx" select="$idx"/>
		</xsl:call-template>
		<xsl:call-template name="order-by"/>
		<xsl:text>";
</xsl:text>
	</xsl:template>


	<xsl:template name="finder-query-condition">
		<xsl:variable name="query">
			<xsl:call-template name="condition-query"/>
		</xsl:variable>
		<xsl:variable name="params">
			<xsl:call-template name="finder-params-condition-plain"/>
		</xsl:variable>
		<xsl:variable name="paramtypes">
			<xsl:call-template name="finder-paramtypes-condition"/>
		</xsl:variable>
		<xsl:variable name="gql" select="string($query)"/>
		<xsl:variable name="argnames" select="string($params)"/>
		<xsl:variable name="argtypes" select="string($paramtypes)"/>
		<xsl:variable name="indent" select="string('        ')"/>
		<xsl:value-of select="java:parse( $gqlparser, $indent, $gql, $argnames, $argtypes)"/>

		<xsl:call-template name="finder-query-orderby"/>

		<xsl:text>
        multipleQueries = false; // TODO
        String _cond = "</xsl:text>

		<xsl:value-of select="$gql"/>
		<xsl:call-template name="order-by"/>
		<xsl:text>";
</xsl:text>
	</xsl:template>


	<xsl:template name="finder-query-dynamic">
		<xsl:text>        _query = getQueryCond( _query, cond, params );
</xsl:text>

		<xsl:if test="db:order-by">
			<xsl:call-template name="finder-query-orderby"/>
			<xsl:text>
        if ( _query.getSortPredicates().size() == 0 ) {
            cond += " ORDER BY ";
        }
        else {
            cond += ", ";
        }

        cond += "</xsl:text>
			<xsl:call-template name="order-by-items"/>
			<xsl:text>";
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="finder-query-orderby">
		<xsl:param name="columns" select="../../db:columns"/>
		<xsl:for-each select="db:order-by/db:column">
			<xsl:variable name="name" select="@name"/>
			<xsl:text>        _query.addSort( "</xsl:text>
			<xsl:call-template name="get-order-expr">
				<xsl:with-param name="ctx" select="$columns/db:column[@name=$name]"/>
			</xsl:call-template>
			<xsl:text>"</xsl:text>
			<xsl:if test="@desc = 'true'">
				<xsl:text>, Query.SortDirection.DESCENDING</xsl:text>
			</xsl:if>
			<xsl:text> );
</xsl:text>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="index-query">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>
		<xsl:param name="islist" select="0"/>

		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="col" select="$columns/db:column[@name=$name]"/>
				<xsl:choose>
					<xsl:when test="$col/db:ref/@gae-parent = 'true'">
						<xsl:text>        _query.setAncestor( </xsl:text>
						<xsl:call-template name="key-object">
							<xsl:with-param name="ctx" select="$col"/>
						</xsl:call-template>
						<xsl:text>);
</xsl:text>
					</xsl:when>
					<xsl:when test="$islist=1 and $col/db:type = 'List'">
						<xsl:call-template name="index-query-addfilter-list">
							<xsl:with-param name="col" select="$col"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$islist=1 and $col/db:type = 'Serializable' and $col/db:type/@class='java.util.List'">
						<xsl:call-template name="index-query-addfilter-list">
							<xsl:with-param name="col" select="$col"/>
							<xsl:with-param name="itemtype" select="'Object'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="index-query-addfilter">
							<xsl:with-param name="col" select="$col"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="index-query-addfilter">
		<xsl:param name="col"/>
		<xsl:param name="prop">
			<xsl:call-template name="java-name">
				<xsl:with-param name="ctx" select="$col"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="val">
			<xsl:call-template name="column-val">
				<xsl:with-param name="ctx" select="$col"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="hasclass" select="count($col[db:type='Serializable' or db:type='List'])"/>

		<xsl:text>        _query.addFilter( "</xsl:text>
		<xsl:value-of select="$prop"/>
		<xsl:text>", Query.FilterOperator.EQUAL, </xsl:text>
		<xsl:variable name="iscoreclass">
			<xsl:if test="$hasclass=1">
				<xsl:call-template name="is-gae-core-class">
					<xsl:with-param name="cls" select="$col/db:type/@class"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="useblob" select="$col/db:type='byte[]' or $hasclass and ($col/db:type/@max-length or $iscoreclass!=1)"/>
		<xsl:if test="$useblob and not($col/db:type/@max-length &lt; 501)">
			<xsl:call-template name="error">
				<xsl:with-param name="errcode" select="'GAE_FINDER_ON_UNINDEXED_PROPERTY'"/>
				<xsl:with-param name="table" select="$col/../.."/>
				<xsl:with-param name="col" select="$col"/>
				<xsl:with-param name="detail" select="'@max-length must be less or equal 500'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$col/db:type='Date' or $col/db:type='Timestamp'">
				<xsl:text>date( </xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text> ));
</xsl:text>
			</xsl:when>
			<xsl:when test="$useblob and $val!='null'">
				<xsl:text>shortBlob( </xsl:text>
				<xsl:value-of select="$val"/>
				<xsl:text> ));
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$val"/>
				<xsl:text> );
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="index-query-addfilter-list">
		<xsl:param name="col"/>
		<xsl:param name="itemtype">
			<xsl:call-template name="objectType-List">
				<xsl:with-param name="ctx" select="$col/db:type"/>
				<xsl:with-param name="islist" select="0"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:text>
        if ( </xsl:text>
		<xsl:call-template name="column-name">
			<xsl:with-param name="ctx" select="$col"/>
		</xsl:call-template>
		<xsl:text> != null &amp;&amp; </xsl:text>
		<xsl:call-template name="column-name">
			<xsl:with-param name="ctx" select="$col"/>
		</xsl:call-template>
		<xsl:text>.size() != 0 ) {
            for ( </xsl:text>
		<xsl:value-of select="$itemtype"/>
		<xsl:text> _listItem : </xsl:text>
		<xsl:call-template name="column-name">
			<xsl:with-param name="ctx" select="$col"/>
		</xsl:call-template>
		<xsl:text> ) {
        </xsl:text>
		<xsl:call-template name="index-query-addfilter">
			<xsl:with-param name="col" select="$col"/>
			<xsl:with-param name="val" select="'_listItem'"/>
			<xsl:with-param name="hasclass" select="1"/>
		</xsl:call-template>
		<xsl:text>            }
        }
        else {
    </xsl:text>
		<xsl:call-template name="index-query-addfilter">
			<xsl:with-param name="col" select="$col"/>
			<xsl:with-param name="val" select="'null'"/>
			<xsl:with-param name="hasclass" select="0"/>
		</xsl:call-template>
		<xsl:text>        }
</xsl:text>
	</xsl:template>


	<xsl:template name="index-condition">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>
		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="col" select="$columns/db:column[@name=$name]"/>
				<xsl:call-template name="and-if-next"/>
				<xsl:choose>
					<xsl:when test="$col/db:ref/@gae-parent = 'true'">
						<xsl:variable name="ptname" select="$col/db:ref/@table"/>
						<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name = $ptname]"/>
						<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
						<xsl:if test="$pkeycol">
							<xsl:call-template name="error">
								<xsl:with-param name="errcode" select="'GAE_INDEX_ON_COMPLEX_ANCESTOR'"/>
								<xsl:with-param name="table" select="$col/../.."/>
								<xsl:with-param name="col" select="$columnrefs/../.."/>
								<xsl:with-param name="coltype" select="'INDEX'"/>
								<xsl:with-param name="detail" select="$col/@name"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:text>ANCESTOR IS KEY('</xsl:text>
						<xsl:call-template name="java-Name">
							<xsl:with-param name="ctx" select="$ptable"/>
						</xsl:call-template>
						<xsl:text>', :</xsl:text>
						<xsl:value-of select="position()"/>
						<xsl:text> )</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="java-name">
							<xsl:with-param name="ctx" select="$col"/>
						</xsl:call-template>
						<xsl:text> = :</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="index-param-values-plain">
		<xsl:param name="columns"/>
		<xsl:param name="columnrefs"/>
		<xsl:param name="idx" select="0"/>

		<xsl:for-each select="$columnrefs">
			<xsl:if test="last() - $idx + 1 &gt; position()">
				<xsl:text>, </xsl:text>
				<xsl:variable name="name" select="@name"/>
				<xsl:call-template name="column-name">
					<xsl:with-param name="ctx" select="$columns/db:column[@name=$name]"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="finder-params-plain">
		<xsl:choose>
			<xsl:when test="db:index">
				<xsl:call-template name="finder-params-index-plain"/>
			</xsl:when>
			<xsl:when test="db:condition">
				<xsl:call-template name="finder-params-condition-plain"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="finder-params"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="finder-params-index-plain">
		<xsl:variable name="name" select="db:index/@name"/>
		<xsl:variable name="ind" select="../../db:indexes/db:index[@name = $name]"/>
		<xsl:call-template name="index-param-values-plain">
			<xsl:with-param name="columns" select="../../db:columns"/>
			<xsl:with-param name="columnrefs" select="$ind/db:columns/db:column"/>
			<xsl:with-param name="idx">
				<xsl:call-template name="index-level"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="finder-params-condition-plain">
		<xsl:param name="ctx" select="db:condition"/>
		<xsl:for-each select="$ctx/db:params/*">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="param-name"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="finder-paramtypes-condition">
		<xsl:param name="ctx" select="db:condition"/>
		<xsl:for-each select="$ctx/db:params/*">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="param-type-gql"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="param-type-gql">
		<xsl:param name="ctx" select="."/>
		<xsl:choose>
			<xsl:when test="local-name($ctx)='column'">
				<xsl:variable name="name" select="$ctx/@name"/>
				<xsl:call-template name="param-type-gql-impl">
					<xsl:with-param name="col" select="$ctx/../../../../../db:columns/db:column[@name=$name]"/>
					<xsl:with-param name="list" select="$ctx/@list"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="param-type-gql-impl">
					<xsl:with-param name="type" select="$ctx/@type"/>
					<xsl:with-param name="cls" select="$ctx/@class"/>
					<xsl:with-param name="list" select="$ctx/@list"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="param-type-gql-impl">
		<xsl:param name="col"/>
		<xsl:param name="type" select="$col/db:type"/>
		<xsl:param name="cls" select="$col/db:type/@class"/>
		<xsl:param name="list"/>

		<xsl:variable name="iscoreclass">
			<xsl:if test="$cls">
				<xsl:call-template name="is-gae-core-class">
					<xsl:with-param name="cls" select="$cls"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="useblob" select="$type='byte[]' or ($type='Serializable' or $type='List') and (($col and $col/db:type/@max-length) or $iscoreclass!=1)"/>

		<xsl:if test="$list='true'">
			<xsl:if test="not($type='List' or $type='Serializable' and $cls='java.util.List')">
				<xsl:text>Forced</xsl:text>
			</xsl:if>
			<xsl:text>List|</xsl:text>
			<xsl:choose>
				<xsl:when test="$col">
					<xsl:call-template name="column-ObjectType">
						<xsl:with-param name="ctx" select="$col"/>
						<xsl:with-param name="islist" select="0"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="objectType-raw">
						<xsl:with-param name="ctx" select="$type"/>
						<xsl:with-param name="cls" select="$cls"/>
						<xsl:with-param name="islist" select="0"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>|</xsl:text>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$col and $col/db:enum">
				<xsl:text>Enum</xsl:text>
				<xsl:if test="$col/db:enum/db:value/@id">
					<xsl:text>Id</xsl:text>
				</xsl:if>
				<xsl:text>/</xsl:text>
				<xsl:call-template name="objectType-raw">
					<xsl:with-param name="ctx" select="$col/db:type"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$useblob and $col and not($col/db:type/@max-length &lt; 501)">
				<xsl:call-template name="error">
					<xsl:with-param name="errcode" select="'GAE_FINDER_ON_UNINDEXED_PROPERTY'"/>
					<xsl:with-param name="table" select="$col/../.."/>
					<xsl:with-param name="col" select="$col"/>
					<xsl:with-param name="detail" select="concat('@max-length not less than 500 - ',$col/db:type)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type='byte[]'">
				<xsl:text>ShortBlobOfByteArray</xsl:text>
			</xsl:when>
			<xsl:when test="$useblob">
				<xsl:text>ShortBlob</xsl:text>
			</xsl:when>
			<xsl:when test="$col">
				<xsl:call-template name="column-ObjectType">
					<xsl:with-param name="ctx" select="$col"/>
					<xsl:with-param name="islist" select="0"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="objectType-raw">
					<xsl:with-param name="ctx" select="$type"/>
					<xsl:with-param name="islist" select="0"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template name="key-to-native">
		<xsl:param name="ctx" select="."/>

		<xsl:choose>
			<xsl:when test="$ctx/db:type = 'long'">
				<xsl:text>.getId()</xsl:text>
			</xsl:when>
			<xsl:when test="$ctx/db:type = 'String'">
				<xsl:text>.getName()</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error">
					<xsl:with-param name="errcode" select="'GAE_PK_TYPE_NOT_SUPPORTED'"/>
					<xsl:with-param name="table" select="$ctx/../.."/>
					<xsl:with-param name="col" select="$ctx"/>
					<xsl:with-param name="detail" select="$ctx/db:type"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="insert-key-check-null">
		<xsl:param name="ctx"/>

		<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
		<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
		<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

		<xsl:if test="$pkeycol">
			<xsl:call-template name="insert-key-check-null">
				<xsl:with-param name="ctx" select="$pkeycol"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:text>        checkNull( "</xsl:text>
		<xsl:call-template name="key-name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
		<xsl:text>", dto.get</xsl:text>
		<xsl:call-template name="key-Name">
			<xsl:with-param name="ctx" select="$ctx"/>
		</xsl:call-template>
		<xsl:text>());
</xsl:text>
	</xsl:template>


	<xsl:template name="set-column-insert-auto">

		<xsl:if test="db:type != 'long'">
			<xsl:call-template name="error">
				<xsl:with-param name="errcode" select="'GAE_AUTO_NUMBER_ONLY_LONG'"/>
				<xsl:with-param name="table" select="../.."/>
				<xsl:with-param name="col" select="."/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="db:auto/@on = 'update' or db:auto/@on = 'update-only'">
			<xsl:call-template name="error">
				<xsl:with-param name="errcode" select="'GAE_AUTO_NUMBER_ONLY_INSERT'"/>
				<xsl:with-param name="table" select="../.."/>
				<xsl:with-param name="col" select="."/>
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="getter">
			<xsl:call-template name="getter"/>
		</xsl:variable>

		<xsl:call-template name="null-column-condition">
			<xsl:with-param name="getter" select="$getter"/>
		</xsl:call-template>
		<xsl:text>dto.set</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>( ds.allocateIds( "</xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>", 1 ).getStart().getId());
            }
            _ent.set</xsl:text>
		<xsl:if test="db:gae/@unindexed='true'">
			<xsl:text>Unindexed</xsl:text>
		</xsl:if>
		<xsl:text>Property( "</xsl:text>
		<xsl:call-template name="java-name"/>
		<xsl:text>", dto.get</xsl:text>
		<xsl:call-template name="java-Name"/>
		<xsl:text>());
</xsl:text>
	</xsl:template>


	<xsl:template name="is-gae-core-class">
		<xsl:param name="cls" select="."/>
		<xsl:choose>
			<xsl:when test="starts-with($cls,'gae:')">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="contains($cls,':')">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="starts-with($cls,'java.lang.') and not(contains(substring-after($cls,'java.lang.'),'.'))">
				<xsl:call-template name="is-gae-core-class-java-lang">
					<xsl:with-param name="cls" select="substring-after($cls,'java.lang.')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='java.util.Date'">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="$cls='java.util.List'">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="contains($cls,'.')">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="is-gae-core-class-java-lang">
					<xsl:with-param name="cls" select="$cls"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="is-gae-core-class-java-lang">
		<xsl:param name="cls" select="."/>
		<xsl:choose>
			<xsl:when test="$cls='String'">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="$cls='Integer' or $cls='Long' or $cls='Short'">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="$cls='Float' or $cls='Double'">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="$cls='Boolean'">
				<xsl:value-of select="1"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="pk-param-name">
		<xsl:call-template name="column-name">
			<xsl:with-param name="ctx" select="$daoctx/db:columns/db:column[db:pk]"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="pk-param-names">
		<xsl:call-template name="pk-param-names-keys"/>
		<xsl:for-each select="$daoctx/db:columns/db:column[db:pk]">
			<xsl:if test="$keycol or position() != 1">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="column-name"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="pk-param-names-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:for-each select="$ctx">
			<xsl:variable name="ptname" select="$ctx/db:ref/@table"/>
			<xsl:variable name="ptable" select="/db:database/db:tables/db:table[@name=$ptname]"/>
			<xsl:variable name="pkeycol" select="$ptable/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

			<xsl:call-template name="pk-param-names-keys">
				<xsl:with-param name="ctx" select="$pkeycol"/>
			</xsl:call-template>

			<xsl:if test="$pkeycol">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="column-name"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="dtocache-factory-impl">
		<xsl:param name="tpl"/>
		<xsl:text>new MemchainDtoCacheFactoryImpl</xsl:text>
		<xsl:value-of select="$tpl"/>
		<xsl:text>( "</xsl:text>
		<xsl:call-template name="dto-name"/>
		<xsl:text>"</xsl:text>
		<xsl:if test="$defcache/@l2-expire-millis and $defcache/@l2-expire-millis &gt; 0">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$defcache/@l2-expire-millis"/>
			<xsl:text>L</xsl:text>
		</xsl:if>
		<xsl:text> )</xsl:text>
	</xsl:template>


</xsl:stylesheet>
