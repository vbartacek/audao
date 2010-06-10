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

	<xsl:variable name="dtoctx" select="/db:database/*/*[@name=$table_name]"/>
	<xsl:variable name="keycol" select="$dtoctx/db:columns/db:column[db:ref/@gae-parent = 'true']"/>

	<xsl:variable name="dtoname">
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="$dtoctx"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="own-columns" select="$dtoctx/db:columns/db:column[not(@defined-by) and not(db:transient[not(@gwt) or @gwt='true'])]"/>

	<xsl:template match="db:database">
		<xsl:apply-templates select="$dtoctx"/>
	</xsl:template>

	<xsl:template match="db:table|db:view">
		<xsl:call-template name="file-header"/>
		<xsl:text>package </xsl:text>
		<xsl:value-of select="$pkg_dto"/>
		<xsl:text>;
</xsl:text>

		<xsl:call-template name="imports-java-dates"/>
		<xsl:call-template name="imports-java-blobs"/>
		<xsl:call-template name="imports-java"/>
		<xsl:text>
/**
 * </xsl:text>
		<xsl:choose>
			<xsl:when test="db:comment">
				<xsl:text> * </xsl:text>
				<xsl:value-of select="db:comment"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>This is a GWT custom serializer of a DTO class.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>
 *
 * @author generated
 */
</xsl:text>
		<xsl:text>public class </xsl:text>
		<xsl:call-template name="class-name"/>
		<xsl:text> {
</xsl:text>
		<xsl:call-template name="method-serialize"/>
		<xsl:call-template name="method-instantiate"/>
		<xsl:call-template name="method-deserialize"/>
		<xsl:if test="$own-columns[(db:type='Serializable' or db:type='List') and db:type/@class='gae:Key']">
			<xsl:call-template name="method-serialize-key"/>
		</xsl:if>
		<xsl:text>}
</xsl:text>
	</xsl:template>


	<xsl:template name="imports-java">
		<xsl:if test="$own-columns[db:type='List' or db:type='Serializable' and db:type/@class='java.util.List']">
			<xsl:text>
import java.util.ArrayList;
</xsl:text>
		</xsl:if>
		<xsl:if test="$own-columns[(db:type='Serializable' or db:type='List') and db:type/@class='gae:Key']">
			<xsl:text>
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.KeyFactory;
</xsl:text>
		</xsl:if>
		<xsl:text>
import com.google.gwt.user.client.rpc.SerializationException;
import com.google.gwt.user.client.rpc.SerializationStreamReader;
import com.google.gwt.user.client.rpc.SerializationStreamWriter;
</xsl:text>
	</xsl:template>


	<xsl:template name="parent-class">
		<xsl:variable name="parent">
			<xsl:call-template name="parent-dto"/>
		</xsl:variable>
		<xsl:call-template name="java-Name">
			<xsl:with-param name="ctx" select="//db:table[@name=$parent]"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="imports-java-dates">
		<xsl:if test="db:columns/db:column[db:type = 'Date']">
			<xsl:text>
import java.sql.Date;
</xsl:text>
		</xsl:if>
		<xsl:if test="db:columns/db:column[db:type= 'Timestamp']">
			<xsl:text>
import java.sql.Timestamp;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="imports-java-blobs">
		<xsl:if test="db:columns/db:column[db:type = 'Serializable' and not(db:type/@class)]">
			<xsl:text>
import java.io.Serializable;
</xsl:text>
		</xsl:if>
		<xsl:if test="db:columns/db:column[db:type = 'List']">
			<xsl:text>
import java.util.List;
</xsl:text>
		</xsl:if>
		<xsl:call-template name="dbutil-imports-gae-types"/>
	</xsl:template>


	<xsl:template name="class-name">
		<xsl:value-of select="$dtoname"/>
		<xsl:text>_CustomFieldSerializer</xsl:text>
	</xsl:template>


	<xsl:template name="method-serialize">
		<xsl:text>
    public static void serialize( SerializationStreamWriter sw, </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> dto )
            throws SerializationException {

</xsl:text>
		<xsl:if test="@extends">
			<xsl:text>        </xsl:text>
			<xsl:call-template name="parent-class"/>
			<xsl:text>_CustomFieldSerializer.serialize( sw, dto );

</xsl:text>
		</xsl:if>
		<xsl:variable name="hasmodified">
			<xsl:call-template name="has-modified"/>
		</xsl:variable>
		<xsl:for-each select="$own-columns">
			<xsl:call-template name="serialize-column">
				<xsl:with-param name="hasmodified" select="$hasmodified"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="write-parent-keys"/>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-instantiate">
		<xsl:text>
    public static </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> instantiate( SerializationStreamReader sr ) throws SerializationException {
        return new </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text>();
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-deserialize">
		<xsl:text>
    public static void deserialize( SerializationStreamReader sr, </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> dto )
            throws SerializationException {

</xsl:text>
		<xsl:if test="@extends">
			<xsl:text>        </xsl:text>
			<xsl:call-template name="parent-class"/>
			<xsl:text>_CustomFieldSerializer.deserialize( sr, dto );

</xsl:text>
		</xsl:if>
		<xsl:variable name="hasmodified">
			<xsl:call-template name="has-modified"/>
		</xsl:variable>
		<xsl:for-each select="$own-columns">
			<xsl:call-template name="deserialize-column">
				<xsl:with-param name="hasmodified" select="$hasmodified"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="read-parent-keys"/>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-serialize-key">
		<xsl:text>
    private static void serializeKey( SerializationStreamWriter sw, Key key ) throws SerializationException {
        int meta = 0;
        for (Key k = key; k != null; k = k.getParent()) {
            meta &lt;&lt;= 2;
            if (!k.isComplete()) meta |= 0x03;
            else if (k.getName() != null) meta |= 0x02;
            else meta |= 0x01;
        }
        sw.writeInt( meta );
        writeKey( sw, key );
    }

    private static void writeKey( SerializationStreamWriter sw, Key key ) throws SerializationException {
        if (key.getParent() != null) writeKey( sw, key.getParent());

        sw.writeString( key.getKind());
        if (!key.isComplete()) {}
        else if (key.getName() != null) sw.writeString( key.getName());
        else sw.writeLong( key.getId());
    }

    private static Key deserializeKey( SerializationStreamReader sr ) throws SerializationException {
        int meta = sr.readInt();
        int mask = meta &amp; 0x03;
        KeyFactory.Builder kfb = null; 
        if (mask == 1) kfb = new KeyFactory.Builder( sr.readString(), sr.readLong());
        else if (mask == 2) kfb = new KeyFactory.Builder( sr.readString(), sr.readString());
        else return new Entity( sr.readString()).getKey();

        meta &gt;&gt;= 2;
        mask = meta &amp; 0x03;
        while (mask != 0) {
            if (mask == 1) kfb = kfb.addChild( sr.readString(), sr.readLong());
            else if (mask == 2) kfb = kfb.addChild( sr.readString(), sr.readString());
            else return new Entity( sr.readString(), kfb.getKey()).getKey();
            meta &gt;&gt;= 2;
            mask = meta &amp; 0x03;
        }

        return kfb.getKey();
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="serialize-column">
		<xsl:param name="hasmodified"/>
		<xsl:if test="((position()-1) mod 32) = 0">
			<xsl:text>        </xsl:text>
			<xsl:if test="position()=1">
				<xsl:text>int </xsl:text>
			</xsl:if>
			<xsl:text>nulls = 0;
</xsl:text>
			<xsl:if test="$hasmodified=1">
				<xsl:text>        </xsl:text>
				<xsl:if test="position()=1">
					<xsl:text>int </xsl:text>
				</xsl:if>
				<xsl:text>modifs = 0;
</xsl:text>
			</xsl:if>
			<xsl:text>
</xsl:text>
			<xsl:variable name="pos" select="position()"/>
			<xsl:for-each select="$own-columns">
				<xsl:if test="position() &gt; $pos - 1 and position() &lt; $pos + 32">
					<xsl:variable name="ismodified">
						<xsl:call-template name="is-modified"/>
					</xsl:variable>
					<xsl:text>        if (dto.get</xsl:text>
					<xsl:call-template name="column-Name"/>
					<xsl:text>() == null) </xsl:text>
					<xsl:choose>
						<xsl:when test="$ismodified=1">
							<xsl:text>{
            nulls |= </xsl:text>
							<xsl:call-template name="hexexp">
								<xsl:with-param name="n" select="position()-$pos"/>
							</xsl:call-template>
							<xsl:text>;
            if (dto.is</xsl:text>
							<xsl:call-template name="column-Name"/>
							<xsl:text>Modified()) modifs |= </xsl:text>
							<xsl:call-template name="hexexp">
								<xsl:with-param name="n" select="position()-$pos"/>
							</xsl:call-template>
							<xsl:text>;
        }
</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>nulls |= </xsl:text>
							<xsl:call-template name="hexexp">
								<xsl:with-param name="n" select="position()-$pos"/>
							</xsl:call-template>
							<xsl:text>;
</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>
        sw.writeInt( nulls );
</xsl:text>
			<xsl:if test="$hasmodified=1">
				<xsl:text>        sw.writeInt( modifs );
</xsl:text>
			</xsl:if>
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:text>        if (dto.get</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>() != null) </xsl:text>
		<xsl:choose>
			<xsl:when test="db:enum">
				<xsl:call-template name="write-enum"/>
			</xsl:when>
			<xsl:when test="db:type='List' or db:type='Serializable' and db:type/@class='java.util.List'">
				<xsl:call-template name="write-list"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="write-item"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="deserialize-column">
		<xsl:param name="hasmodified"/>
		<xsl:if test="((position()-1) mod 32) = 0">
			<xsl:text>        </xsl:text>
			<xsl:if test="position()=1">
				<xsl:text>int </xsl:text>
			</xsl:if>
			<xsl:text>nulls = sr.readInt();
</xsl:text>
			<xsl:if test="$hasmodified=1">
				<xsl:text>        </xsl:text>
				<xsl:if test="position()=1">
					<xsl:text>int </xsl:text>
				</xsl:if>
				<xsl:text>modifs = sr.readInt();
</xsl:text>
			</xsl:if>
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:text>        if ((nulls &amp; </xsl:text>
		<xsl:call-template name="hexexp">
			<xsl:with-param name="n" select="(position()-1) mod 32"/>
		</xsl:call-template>
		<xsl:text>) == 0) </xsl:text>
		<xsl:choose>
			<xsl:when test="db:enum">
				<xsl:call-template name="read-enum"/>
			</xsl:when>
			<xsl:when test="db:type='List' or db:type='Serializable' and db:type/@class='java.util.List'">
				<xsl:call-template name="read-list"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="read-item"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="ismodified">
			<xsl:call-template name="is-modified"/>
		</xsl:variable>
		<xsl:if test="$ismodified=1">
			<xsl:text>        else if ((modifs &amp; </xsl:text>
			<xsl:call-template name="hexexp">
				<xsl:with-param name="n" select="(position()-1) mod 32"/>
			</xsl:call-template>
			<xsl:text>) != 0) dto.set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( null );
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="write-parent-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:text>
        if (dto.get</xsl:text>
				<xsl:call-template name="column-Name"/>
				<xsl:text>() == null) sw.writeByte( (byte)1);
        else {
            sw.writeByte( (byte)0);
            </xsl:text>
				<xsl:call-template name="write-item"/>
				<xsl:text>        }
</xsl:text>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="write-parent-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="read-parent-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:text>        if (sr.readByte() == 0) </xsl:text>
				<xsl:call-template name="read-item"/>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="read-parent-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="write-item">
		<xsl:param name="type" select="db:type"/>
		<xsl:param name="cls" select="db:type/@class"/>
		<xsl:param name="getter">
			<xsl:text>dto.get</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>()</xsl:text>
		</xsl:param>
		<xsl:param name="indent"/>

		<xsl:choose>
			<xsl:when test="$type='Date' or $type='Timestamp' or ($type='Serializable' or $type='List') and $cls='java.util.Date'">
				<xsl:call-template name="write-date">
					<xsl:with-param name="getter" select="$getter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="($type='Serializable' or $type='List') and $cls and starts-with($cls,'table:')">
				<xsl:call-template name="write-dto">
					<xsl:with-param name="getter" select="$getter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="($type='Serializable' or $type='List') and $cls and starts-with($cls,'gae:')">
				<xsl:call-template name="write-gae">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="read-item">
		<xsl:param name="type" select="db:type"/>
		<xsl:param name="cls" select="db:type/@class"/>
		<xsl:param name="prefix">
			<xsl:text>dto.set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( </xsl:text>
		</xsl:param>
		<xsl:param name="indent"/>

		<xsl:choose>
			<xsl:when test="$type='Date' or $type='Timestamp' or ($type='Serializable' or $type='List') and $cls='java.util.Date'">
				<xsl:call-template name="read-date">
					<xsl:with-param name="prefix" select="$prefix"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="($type='Serializable' or $type='List') and $cls and starts-with($cls,'table:')">
				<xsl:call-template name="read-dto">
					<xsl:with-param name="prefix" select="$prefix"/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="($type='Serializable' or $type='List') and $cls and starts-with($cls,'gae:')">
				<xsl:call-template name="read-gae">
					<xsl:with-param name="prefix" select="$prefix"/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="stream-read">
					<xsl:with-param name="prefix" select="$prefix"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="write-enum">
		<xsl:call-template name="stream-write">
			<xsl:with-param name="method" select="'String'"/>
			<xsl:with-param name="subget" select="'name'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="read-enum">
		<xsl:text>dto.set</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>( </xsl:text>
		<xsl:call-template name="column-EnumType"/>
		<xsl:text>.valueOf( sr.readString()));
</xsl:text>
	</xsl:template>


	<xsl:template name="write-date">
		<xsl:param name="getter"/>
		<xsl:call-template name="stream-write">
			<xsl:with-param name="getter" select="$getter"/>
			<xsl:with-param name="method" select="'Long'"/>
			<xsl:with-param name="subget" select="'getTime'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="read-date">
		<xsl:param name="prefix"/>
		<xsl:value-of select="$prefix"/>
		<xsl:text>new </xsl:text>
		<xsl:choose>
			<xsl:when test="db:type='Serializable' or db:type='List'">
				<xsl:text>java.util.Date</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="db:type"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>( sr.readLong()));
</xsl:text>
	</xsl:template>


	<xsl:template name="write-dto">
		<xsl:param name="getter"/>
		<xsl:call-template name="objectType-ClassRef">
			<xsl:with-param name="ctx" select="db:type"/>
		</xsl:call-template>
		<xsl:text>_CustomFieldSerializer.serialize( sw, </xsl:text>
		<xsl:value-of select="$getter"/>
		<xsl:text> );
</xsl:text>
	</xsl:template>

	<xsl:template name="read-dto">
		<xsl:param name="prefix"/>
		<xsl:param name="indent"/>
		<xsl:variable name="clstype">
			<xsl:call-template name="objectType-ClassRef">
				<xsl:with-param name="ctx" select="db:type"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="block-start">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
		<xsl:value-of select="$clstype"/>
		<xsl:text> dto2 = new </xsl:text>
		<xsl:value-of select="$clstype"/>
		<xsl:text>();
</xsl:text>
		<xsl:call-template name="block-indent">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
		<xsl:value-of select="$clstype"/>
		<xsl:text>_CustomFieldSerializer.deserialize( sr, dto2 );
</xsl:text>
		<xsl:call-template name="block-indent">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
		<xsl:value-of select="$prefix"/>
		<xsl:text>dto2 );
</xsl:text>
		<xsl:call-template name="block-end">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="write-gae">
		<xsl:param name="getter"/>
		<xsl:param name="indent"/>
		<xsl:variable name="cls" select="db:type/@class"/>
		<xsl:choose>
			<xsl:when test="$cls='gae:GeoPt'">
				<xsl:call-template name="block-start">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>sw.writeFloat( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getLatitude());
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>sw.writeFloat( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getLongitude());
</xsl:text>
				<xsl:call-template name="block-end">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:Key'">
				<xsl:text>serializeKey( sw, </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text> );
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Category'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'String'"/>
					<xsl:with-param name="subget" select="'getCategory'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:Email'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'String'"/>
					<xsl:with-param name="subget" select="'getEmail'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:IMHandle'">
				<xsl:call-template name="block-start">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>sw.writeString( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getProtocol());
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>sw.writeString( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getAddress());
</xsl:text>
				<xsl:call-template name="block-end">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:Link'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'String'"/>
					<xsl:with-param name="subget" select="'getValue'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:PhoneNumber'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'String'"/>
					<xsl:with-param name="subget" select="'getNumber'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:PostalAddress'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'String'"/>
					<xsl:with-param name="subget" select="'getAddress'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:Rating'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'Int'"/>
					<xsl:with-param name="subget" select="'getRating'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:Text'">
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'String'"/>
					<xsl:with-param name="subget" select="'getValue'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$cls='gae:User'">
				<xsl:call-template name="block-start">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>int uflag = "gmail.com".equals( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getAuthDomain()) ? 0 : 0x02;
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>if (</xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getUserId() != null) uflag |= 0x01;
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>sw.writeByte( (byte)uflag );
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>sw.writeString( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getEmail());
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>if ((uflag &amp; 0x02) != 0) sw.writeString( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getAuthDomain());
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>if ((uflag &amp; 0x01) != 0) sw.writeString( </xsl:text>
				<xsl:value-of select="$getter"/>
				<xsl:text>.getUserId());
</xsl:text>
				<xsl:call-template name="block-end">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="stream-write">
					<xsl:with-param name="getter" select="$getter"/>
					<xsl:with-param name="method" select="'Object'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="read-gae">
		<xsl:param name="prefix"/>
		<xsl:param name="indent"/>
		<xsl:variable name="cls" select="db:type/@class"/>
		<xsl:choose>
			<xsl:when test="$cls='gae:GeoPt'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new GeoPt( sr.readFloat(), sr.readFloat()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Key'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>deserializeKey( sr ));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Category'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new Category( sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Email'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new Email( sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:IMHandle'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new IMHandle( IMHandle.Scheme.valueOf( sr.readString()), sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Link'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new Link( sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:PhoneNumber'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new PhoneNumber( sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:PostalAddress'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new PostalAddress( sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Rating'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new Rating( sr.readInt()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:Text'">
				<xsl:value-of select="$prefix"/>
				<xsl:text>new Text( sr.readString()));
</xsl:text>
			</xsl:when>
			<xsl:when test="$cls='gae:User'">
				<xsl:call-template name="block-start">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>int uflag = sr.readByte();
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>String email = sr.readString();
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>String domain = (uflag &amp; 0x02) != 0 ? sr.readString() : "gmail.com";
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>if ((uflag &amp; 0x01) == 0) </xsl:text>
				<xsl:value-of select="$prefix"/>
				<xsl:text>new User( email, domain ));
</xsl:text>
				<xsl:call-template name="block-indent">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:text>else </xsl:text>
				<xsl:value-of select="$prefix"/>
				<xsl:text>new User( email, domain, sr.readString()));
</xsl:text>
				<xsl:call-template name="block-end">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="stream-read">
					<xsl:with-param name="prefix" select="$prefix"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="write-list">
		<xsl:param name="itemtype">
			<xsl:call-template name="objectType-raw">
				<xsl:with-param name="ctx" select="db:type"/>
				<xsl:with-param name="islist" select="0"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:text>{
            sw.writeInt( dto.get</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>().size());
            for (</xsl:text>
		<xsl:value-of select="$itemtype"/>
		<xsl:text> item : dto.get</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>()) {
                if (item == null) { sw.writeByte( (byte)1); continue; }
                else sw.writeByte( (byte)0);
                </xsl:text>
		<xsl:call-template name="write-item">
			<xsl:with-param name="getter" select="'item'"/>
			<xsl:with-param name="indent" select="'    '"/>
		</xsl:call-template>
		<xsl:text>            }
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="read-list">
		<xsl:param name="itemtype">
			<xsl:call-template name="objectType-raw">
				<xsl:with-param name="ctx" select="db:type"/>
				<xsl:with-param name="islist" select="0"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:text>{
            int n = sr.readInt();
            ArrayList&lt;</xsl:text>
		<xsl:value-of select="$itemtype"/>
		<xsl:text>&gt; list = new ArrayList&lt;</xsl:text>
		<xsl:value-of select="$itemtype"/>
		<xsl:text>&gt;(n);
            for (int i = 0; i &lt; n; i++) {
                if (sr.readByte() == 1) { list.add( null ); continue; }
                </xsl:text>
		<xsl:call-template name="read-item">
			<xsl:with-param name="prefix" select="'list.add( '"/>
			<xsl:with-param name="indent" select="'    '"/>
		</xsl:call-template>
		<xsl:text>            }
            dto.set</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>( list );
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="stream-write">
		<xsl:param name="getter">
			<xsl:text>dto.get</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>()</xsl:text>
		</xsl:param>
		<xsl:param name="method">
			<xsl:call-template name="serializer-method"/>
		</xsl:param>
		<xsl:param name="subget"/>

		<xsl:text>sw.write</xsl:text>
		<xsl:value-of select="$method"/>
		<xsl:text>( </xsl:text>
		<xsl:value-of select="$getter"/>
		<xsl:if test="$subget">
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$subget"/>
			<xsl:text>()</xsl:text>
		</xsl:if>
		<xsl:text>);
</xsl:text>
	</xsl:template>


	<xsl:template name="stream-read">
		<xsl:param name="prefix">
			<xsl:text>dto.set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( </xsl:text>
		</xsl:param>
		<xsl:param name="method">
			<xsl:call-template name="serializer-method"/>
		</xsl:param>
		<xsl:value-of select="$prefix"/>
		<xsl:if test="$method='Object'">
			<xsl:choose>
				<xsl:when test="db:type='byte[]'">
					<xsl:text>(byte[]) </xsl:text>
				</xsl:when>
				<xsl:when test="db:type='Serializable' and not(db:type/@class)">
					<xsl:text>(Serializable) </xsl:text>
				</xsl:when>
				<xsl:when test="db:type/@class and db:type/@class!='java.util.List'">
					<xsl:text>(</xsl:text>
					<xsl:call-template name="objectType-raw">
						<xsl:with-param name="ctx" select="db:type"/>
						<xsl:with-param name="islist" select="0"/>
					</xsl:call-template>
					<xsl:text>) </xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:text>sr.read</xsl:text>
		<xsl:value-of select="$method"/>
		<xsl:text>());
</xsl:text>
	</xsl:template>


	<xsl:template name="serializer-method">
		<xsl:param name="type" select="db:type"/>
		<xsl:param name="cls" select="db:type/@class"/>
		<xsl:variable name="hascls">
			<xsl:if test="$type='Serializable' or $type='List'">
				<xsl:value-of select="1"/>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$type='boolean' or $hascls=1 and $cls='Boolean' or $cls='java.lang.Boolean'">
				<xsl:text>Boolean</xsl:text>
			</xsl:when>
			<xsl:when test="$type='short' or $hascls=1 and $cls='Short' or $cls='java.lang.Short'">
				<xsl:text>Short</xsl:text>
			</xsl:when>
			<xsl:when test="$type='int' or $hascls=1 and $cls='Integer' or $cls='java.lang.Integer'">
				<xsl:text>Int</xsl:text>
			</xsl:when>
			<xsl:when test="$type='long' or $hascls=1 and $cls='Long' or $cls='java.lang.Long'">
				<xsl:text>Long</xsl:text>
			</xsl:when>
			<xsl:when test="$type='double' or $hascls=1 and $cls='Double' or $cls='java.lang.Double'">
				<xsl:text>Double</xsl:text>
			</xsl:when>
			<xsl:when test="$type='String' or $hascls=1 and $cls='String' or $cls='java.lang.String'">
				<xsl:text>String</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Object</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="hexexp">
		<xsl:param name="n"/>
		<xsl:text>0x</xsl:text>
		<xsl:variable name="m" select="$n mod 4"/>
		<xsl:choose>
			<xsl:when test="$m = 0">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:when test="$m = 1">
				<xsl:text>2</xsl:text>
			</xsl:when>
			<xsl:when test="$m = 2">
				<xsl:text>4</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>8</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="hexlevel">
			<xsl:with-param name="n" select="floor($n div 4)"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="hexlevel">
		<xsl:param name="n"/>
		<xsl:if test="$n &gt; 0">
			<xsl:text>0</xsl:text>
			<xsl:call-template name="hexlevel">
				<xsl:with-param name="n" select="$n - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="block-start">
		<xsl:param name="indent"/>
		<xsl:if test="not($indent)">
			<xsl:text>{
            </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="block-indent">
		<xsl:param name="indent"/>
		<xsl:text>            </xsl:text>
		<xsl:value-of select="$indent"/>
	</xsl:template>

	<xsl:template name="block-end">
		<xsl:param name="indent"/>
		<xsl:if test="not($indent)">
			<xsl:text>        }
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="is-modified">
		<xsl:variable name="mode_column" select="../../db:edit-mode='column'"/>
		<xsl:if test="not($mode_column) and db:edit and not(db:not-null) and not(db:pk)">
			<xsl:value-of select="1"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="has-modified">
		<xsl:variable name="mode_column" select="db:edit-mode='column'"/>
		<xsl:if test="not($mode_column) and db:columns/db:column[db:edit and not(db:not-null) and not(db:pk)]">
			<xsl:value-of select="1"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
