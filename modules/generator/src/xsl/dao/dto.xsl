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

	<xsl:variable name="own-columns" select="$dtoctx/db:columns/db:column[not(@defined-by)]"/>

	<xsl:variable name="equality">
		<xsl:call-template name="db-conf-attr">
			<xsl:with-param name="ctx" select="$dtoctx"/>
			<xsl:with-param name="type" select="'dto'"/>
			<xsl:with-param name="attr" select="'equality'"/>
			<xsl:with-param name="def" select="'columns'"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="gwtcomp">
		<xsl:call-template name="db-conf-attr">
			<xsl:with-param name="ctx" select="$dtoctx"/>
			<xsl:with-param name="type" select="'dto'"/>
			<xsl:with-param name="attr" select="'gwt-compatible'"/>
			<xsl:with-param name="def" select="'false'"/>
		</xsl:call-template>
	</xsl:variable>


	<xsl:template match="db:database">
		<xsl:apply-templates select="$dtoctx"/>
	</xsl:template>

	<xsl:template match="db:table|db:view">
		<xsl:call-template name="file-header"/>
		<xsl:text>package </xsl:text>
		<xsl:call-template name="package-name"/>
		<xsl:text>;
</xsl:text>

		<xsl:call-template name="imports-java-dates"/>
		<xsl:call-template name="imports-java-blobs"/>
		<xsl:call-template name="imports-java"/>
		<xsl:call-template name="comment-class">
			<xsl:with-param name="def" select="'This is a DTO class.'"/>
		</xsl:call-template>
		<xsl:call-template name="annotation-class"/>
		<xsl:text>public class </xsl:text>
		<xsl:call-template name="class-name"/>
		<xsl:call-template name="extends"/>

		<xsl:text> {
</xsl:text>
		<xsl:if test="not(@abstract='true')">
			<xsl:variable name="enumcol">
				<xsl:call-template name="db-conf-attr">
					<xsl:with-param name="type" select="'dto'"/>
					<xsl:with-param name="attr" select="'enum-column'"/>
					<xsl:with-param name="def" select="'false'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="getordexpr">
				<xsl:call-template name="db-conf-attr">
					<xsl:with-param name="type" select="'dao'"/>
					<xsl:with-param name="attr" select="'method-get-order-expr'"/>
					<xsl:with-param name="def" select="'false'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$enumcol='true' or $getordexpr='true'">
				<xsl:call-template name="columns-enum"/>
			</xsl:if>
		</xsl:if>
		<xsl:call-template name="enums-def"/>
		<xsl:call-template name="constants"/>
		<xsl:call-template name="attributes"/>
		<xsl:call-template name="attributes-modified"/>
		<xsl:call-template name="constructors"/>
		<xsl:call-template name="methods"/>

		<xsl:text>}
</xsl:text>
	</xsl:template>


	<xsl:template name="package-name">
		<xsl:value-of select="$pkg_dto"/>
	</xsl:template>


	<xsl:template name="imports-java">
		<xsl:if test="not(@extends)">
			<xsl:text>
import com.spoledge.audao.db.dto.AbstractDto;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="extends">
		<xsl:text> extends </xsl:text>

		<xsl:variable name="root">
			<xsl:call-template name="db-conf-elem">
				<xsl:with-param name="type" select="'dto'"/>
				<xsl:with-param name="elem" select="'root'"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@extends">
				<xsl:call-template name="parent-class"/>
			</xsl:when>
			<xsl:when test="$root!=''">
				<xsl:value-of select="$root"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="abstract-dto"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="abstract-dto">
		<xsl:text>AbstractDto</xsl:text>
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
	</xsl:template>


	<xsl:template name="annotation-class">
	</xsl:template>


	<xsl:template name="annotation-attribute-persistent">
	</xsl:template>


	<xsl:template name="annotation-attribute-not-persistent">
	</xsl:template>


	<xsl:template name="annotation-attribute-key">
	</xsl:template>


	<xsl:template name="columns-enum">
		<xsl:text>
    public enum Column {
</xsl:text>
		<xsl:for-each select="db:columns/db:column">
			<xsl:text>        </xsl:text>
			<xsl:call-template name="uc">
				<xsl:with-param name="name" select="@name"/>
			</xsl:call-template>
			<xsl:text>( "</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>" )</xsl:text>
			<xsl:choose>
				<xsl:when test="position()=last()">
					<xsl:text>;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>,</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>
</xsl:text>
		</xsl:for-each>
		<xsl:text>
        private final String columnName;

        Column( String columnName ) {
            this.columnName = columnName;
        }

        public String columnName() {
            return columnName;
        }

        @Override
        public String toString() {
            return columnName;
        }
    };
</xsl:text>
	</xsl:template>


	<xsl:template name="constants">
		<xsl:text>
    ////////////////////////////////////////////////////////////////////////////
    // Static
    ////////////////////////////////////////////////////////////////////////////

    public static final String TABLE = "</xsl:text>
		<xsl:call-template name="db-name"/>
		<xsl:text>";
</xsl:text>
		<xsl:variable name="sv">
			<xsl:call-template name="db-conf-attr">
				<xsl:with-param name="type" select="'dto'"/>
				<xsl:with-param name="attr" select="'serial-version'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$sv!=''">
			<xsl:text>
    public static final long serialVersionUID = </xsl:text>
			<xsl:value-of select="$sv"/>
			<xsl:text>L;
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="attributes">
		<xsl:if test="$own-columns">
			<xsl:text>
    ////////////////////////////////////////////////////////////////////////////
    // Attributes
    ////////////////////////////////////////////////////////////////////////////

</xsl:text>
		</xsl:if>
		<xsl:for-each select="$own-columns">
			<xsl:call-template name="attribute"/>
		</xsl:for-each>

		<xsl:if test="count($keycol) &gt; 1">
			<xsl:call-template name="error">
				<xsl:with-param name="errcode" select="'MULTIPLE_PARENT_KEYS'"/>
				<xsl:with-param name="col" select="$keycol[2]"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="attributes-keys"/>
	</xsl:template>


	<xsl:template name="attribute">
		<xsl:call-template name="annotation-attribute-persistent"/>
		<xsl:text>    private </xsl:text>
		<xsl:call-template name="transient"/>
		<xsl:call-template name="dto-column-type"/>
		<xsl:text> </xsl:text>
		<xsl:call-template name="column-name"/>
		<xsl:text>;
</xsl:text>
	</xsl:template>


	<xsl:template name="attributes-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:call-template name="attribute-key"/>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="attributes-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="attribute-key">
		<xsl:call-template name="annotation-attribute-key"/>
		<xsl:text>    private </xsl:text>
		<xsl:call-template name="dto-column-type"/>
		<xsl:text> </xsl:text>
		<xsl:call-template name="column-name"/>
		<xsl:text>;
</xsl:text>
	</xsl:template>


	<xsl:template name="attributes-modified">
		<xsl:variable name="edit" select="$own-columns[db:edit and not(db:pk) and not(db:not-null)]"/>
		<xsl:if test="not(db:edit-mode = 'column') and $edit">
			<xsl:text>
</xsl:text>
			<xsl:for-each select="$edit">
				<xsl:call-template name="annotation-attribute-not-persistent"/>
				<xsl:text>    private </xsl:text>
				<xsl:call-template name="transient"/>
				<xsl:text>boolean is</xsl:text>
				<xsl:call-template name="column-Name"/>
				<xsl:text>Modified;
</xsl:text>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>


	<xsl:template name="constructors">
		<xsl:text>
    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////
</xsl:text>
		<xsl:call-template name="constructor-default"/>
		<xsl:if test="@extends or /db:database/db:tables/db:table[@use-dto = $table_name and @name != $table_name] or /db:database/db:tables/db:table[@extends=$table_name]">
			<xsl:call-template name="constructor-copy"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="constructor-default">
		<xsl:text>
    /**
     * Creates a new empty DTO.
     */
    public </xsl:text>
		<xsl:call-template name="class-name"/>
		<xsl:text>() {
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="constructor-copy">
		<xsl:param name="tablename" select="@name"/>
		<xsl:variable name="ctx" select="//db:table[@name=$tablename]"/>

		<xsl:if test="$ctx/@extends">
			<xsl:call-template name="constructor-copy">
				<xsl:with-param name="tablename">
					<xsl:call-template name="parent-dto">
						<xsl:with-param name="ctx" select="$ctx"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$own-columns or $table_name != $tablename">
			<xsl:text>
    /**
     * Creates a new DTO as a copy af an existing one.
     */
    public </xsl:text>
			<xsl:value-of select="$dtoname"/>
			<xsl:text>( </xsl:text>
			<xsl:call-template name="java-Name">
				<xsl:with-param name="ctx" select="$ctx"/>
			</xsl:call-template>
			<xsl:text> _other) {
</xsl:text>

			<xsl:if test="@extends">
				<xsl:text>        super( _other );
</xsl:text>
			</xsl:if>
			<xsl:if test="$table_name = $tablename">
				<xsl:if test="@extends">
					<xsl:text>
</xsl:text>
				</xsl:if>
				<xsl:for-each select="$own-columns">
					<xsl:text>        this.</xsl:text>
					<xsl:call-template name="column-name"/>
					<xsl:text> = _other.</xsl:text>
					<xsl:call-template name="column-name"/>
					<xsl:text>;
</xsl:text>
				</xsl:for-each>

			</xsl:if>
			<xsl:text>    }
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="methods">
		<xsl:call-template name="getsetters"/>
		<xsl:call-template name="method-toString"/>
		<xsl:if test="$equality != 'none'">
			<xsl:call-template name="method-equals"/>
			<xsl:call-template name="method-hashCode"/>
		</xsl:if>
		<xsl:call-template name="methods-protected"/>
	</xsl:template>


	<xsl:template name="methods-protected">
		<xsl:if test="$own-columns">

    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////
		</xsl:if>
		<xsl:if test="$own-columns">
			<xsl:call-template name="method-contentToString"/>
		</xsl:if>
		<xsl:if test="not(@extends)">
			<xsl:call-template name="method-append"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="getsetters">
		<xsl:if test="$own-columns">
			<xsl:text>
    ////////////////////////////////////////////////////////////////////////////
    // Public
    ////////////////////////////////////////////////////////////////////////////
</xsl:text>
		</xsl:if>
		<xsl:for-each select="$own-columns">
			<xsl:variable name="is_modified">
				<xsl:call-template name="is-modified"/>
			</xsl:variable>
			<xsl:call-template name="getter"/>
			<xsl:call-template name="setter">
				<xsl:with-param name="is_modified" select="$is_modified"/>
			</xsl:call-template>
			<xsl:if test="$is_modified='yes'">
				<xsl:call-template name="method-is-modified"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:call-template name="getsetters-keys"/>
	</xsl:template>


	<xsl:template name="getsetters-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:call-template name="getter"/>
				<xsl:call-template name="setter"/>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="getsetters-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="getter">
		<xsl:choose>
			<xsl:when test="db:comment">
				<xsl:call-template name="comment-method"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>
</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>    public </xsl:text>
		<xsl:call-template name="dto-column-type"/>
		<xsl:text> get</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>() {
        return </xsl:text>
		<xsl:call-template name="column-name"/>
		<xsl:text>;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="setter">
		<xsl:param name="is_modified"/>

		<xsl:call-template name="setter-date"/>

		<xsl:if test="db:type = 'short' and not(db:enum)">
			<xsl:text>
    public void set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( int _val ) {
        set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( new Short((short) _val ));
    }
</xsl:text>
		</xsl:if>

		<xsl:text>
    public void set</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>( </xsl:text>
		<xsl:call-template name="dto-column-type"/>
		<xsl:text> _val) {
        this.</xsl:text>
		<xsl:call-template name="column-name"/>
		<xsl:text> = _val;
</xsl:text>
		<xsl:if test="$is_modified='yes'">
			<xsl:text>        this.is</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>Modified = true;
</xsl:text>
		</xsl:if>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="setter-date">
		<xsl:if test="db:type = 'Date' or db:type = 'Timestamp'">
			<xsl:text>
    public void set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>( java.util.Date _val ) {
        set</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>((</xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>)( _val != null ? new </xsl:text>
			<xsl:value-of select="db:type"/>
			<xsl:text>( _val.getTime()) : null ));
    }
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="method-is-modified">
		<xsl:text>
    public boolean is</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>Modified() {
        return is</xsl:text>
		<xsl:call-template name="column-Name"/>
		<xsl:text>Modified;
    }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-toString">
	</xsl:template>


	<xsl:template name="method-equals">
		<xsl:text>
    /**
     * Indicates whether some other object is "equal to" this one.
     * Uses '</xsl:text>
		<xsl:value-of select="$equality"/>
		<xsl:text>' equality type.
     */
    @Override
    public boolean equals( Object _other ) {
</xsl:text>
		<xsl:choose>
			<xsl:when test="$equality='identity'">
				<xsl:text>        return _other == this;
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="equals-values"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="equals-values">
<xsl:text>        if (_other == this) return true;
        if (_other == null || (!(_other instanceof </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text>))) return false;

        </xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text> _o = (</xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text>) _other;
</xsl:text>
		<xsl:call-template name="equals-parent-keys"/>
		<xsl:choose>
			<xsl:when test="$equality='pk'">
				<xsl:for-each select="db:columns/db:column[db:pk]">
					<xsl:call-template name="equals-value"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@extends">
					<xsl:text>
        if (!super.equals( _o )) return false;
</xsl:text>
				</xsl:if>
				<xsl:for-each select="$own-columns">
					<xsl:call-template name="equals-value"/>
				</xsl:for-each>
				<xsl:for-each select="db:columns/db:column[db:type='byte[]']">
					<xsl:variable name="is_modified">
						<xsl:call-template name="is-modified"/>
					</xsl:variable>
					<xsl:if test="not($equality='full' and $is_modified='yes')">
						<xsl:call-template name="equals-column-bytearray"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>
        return true;
</xsl:text>
	</xsl:template>


	<xsl:template name="equals-parent-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:call-template name="equals-value"/>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="equals-parent-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="equals-value">
		<xsl:variable name="cname">
			<xsl:call-template name="column-name"/>
		</xsl:variable>
		<xsl:variable name="is_modified">
			<xsl:call-template name="is-modified"/>
		</xsl:variable>
		<xsl:if test="$equality='full' and $is_modified='yes'">
			<xsl:text>
        if ( is</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>Modified != _o.is</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>Modified ) return false;</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="db:enum">
				<xsl:text>
        if ( </xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text> != _o.</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text> ) return false;
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="equals-column">
					<xsl:with-param name="cname" select="$cname"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="equals-column">
		<xsl:param name="cname"/>
		<xsl:text>
        if ( </xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text> == null ) {
            if ( _o.</xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text> != null ) return false;
        }
        else if ( _o.</xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text> == null || </xsl:text>
		<xsl:choose>
			<xsl:when test="db:type='boolean' or db:type='short' or db:type='int' or db:type='long' or db:type='double'">
				<xsl:value-of select="$cname"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="db:type"/>
				<xsl:text>Value() != _o.</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="db:type"/>
				<xsl:text>Value()</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='Date' or db:type='Timestamp'">
				<xsl:value-of select="$cname"/>
				<xsl:text>.getTime() != _o.</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text>.getTime()</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='byte[]'">
				<xsl:value-of select="$cname"/>
				<xsl:text>.length != _o.</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text>.length</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>!</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text>.equals( _o.</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text> )</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>) return false;
</xsl:text>
	</xsl:template>


	<xsl:template name="equals-column-bytearray">
		<xsl:variable name="cname">
			<xsl:call-template name="column-name"/>
		</xsl:variable>
		<xsl:text>
        if ( </xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text> != null ) {
            for (int _i=0; _i &lt; </xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text>.length; _i++) {
                if ( </xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text>[_i] != _o.</xsl:text>
		<xsl:value-of select="$cname"/>
		<xsl:text>[_i] ) return false;
            }
        }
</xsl:text>
	</xsl:template>


	<xsl:template name="method-hashCode">
		<xsl:text>
    /**
     * Returns a hash code value for the object.
     */
    @Override
    public int hashCode() {
</xsl:text>
		<xsl:choose>
			<xsl:when test="$equality='identity'">
				<xsl:text>        return System.identityHashCode( this );
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="hashCode-values"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="hashCode-values">
		<xsl:text>        int _ret = </xsl:text>
		<xsl:variable name="jstring" select="java:java.lang.String.new($dtoname)"/>
		<xsl:value-of select="java:hashCode($jstring)"/>
		<xsl:text>; // = "</xsl:text>
		<xsl:value-of select="$dtoname"/>
		<xsl:text>".hashCode()
</xsl:text>
		<xsl:call-template name="hashCode-parent-keys"/>
		<xsl:variable name="keycount" select="count($keycol)"/>
		<xsl:choose>
			<xsl:when test="$equality='pk'">
				<xsl:for-each select="db:columns/db:column[db:pk]">
					<xsl:call-template name="hashCode-column">
						<xsl:with-param name="pos" select="$keycount + position()"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@extends">
					<xsl:text>
        _ret += super.hashCode();
</xsl:text>
				</xsl:if>
				<xsl:for-each select="$own-columns">
					<xsl:call-template name="hashCode-column">
						<xsl:with-param name="pos" select="$keycount + position()"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>
        return _ret;
</xsl:text>
	</xsl:template>


	<xsl:template name="hashCode-parent-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:param name="pos" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:call-template name="hashCode-column">
					<xsl:with-param name="pos" select="$pos"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="hashCode-parent-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
				<xsl:with-param name="pos" select="$pos + 1"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="hashCode-column">
		<xsl:param name="pos"/>
		<xsl:variable name="cname">
			<xsl:call-template name="column-name"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$pos=1">
				<xsl:text>        _ret += </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>        _ret = 29 * _ret + (</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$cname"/>
		<xsl:text> == null ? 0 : </xsl:text>
		<xsl:choose>
			<xsl:when test="db:enum">
				<xsl:value-of select="$cname"/>
				<xsl:text>.hashCode()</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='boolean'">
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text> ? 1 : 0)</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='short' or db:type='int'">
				<xsl:value-of select="$cname"/>
			</xsl:when>
			<xsl:when test="db:type='long'">
				<xsl:text>(int)(</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text> ^ (</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text> &gt;&gt;&gt; 32))</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='double'">
				<xsl:choose>
					<xsl:when test="$gwtcomp='true'">
						<xsl:value-of select="$cname"/>
						<xsl:text>.intValue()</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Float.floatToIntBits(</xsl:text>
						<xsl:value-of select="$cname"/>
						<xsl:text>.floatValue())</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="db:type='Date' or db:type='Timestamp'">
				<xsl:text>(int)</xsl:text>
				<xsl:value-of select="$cname"/>
				<xsl:text>.getTime()</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='byte[]'">
				<xsl:value-of select="$cname"/>
				<xsl:text>.length</xsl:text>
			</xsl:when>
			<xsl:when test="db:type='List' or db:type='Serializable' and db:type/@class='java.util.List'">
				<xsl:value-of select="$cname"/>
				<xsl:text>.size()</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$cname"/>
				<xsl:text>.hashCode()</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$pos!=1">
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:text>;
</xsl:text>
		<xsl:variable name="is_modified">
			<xsl:call-template name="is-modified"/>
		</xsl:variable>
		<xsl:if test="$equality='full' and $is_modified='yes'">
			<xsl:text>        _ret = 29 * _ret + (is</xsl:text>
			<xsl:call-template name="column-Name"/>
			<xsl:text>Modified ? 1 : 0);
</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="method-contentToString">
		<xsl:text>
    /**
     * Constructs the content for the toString() method.
     */
</xsl:text>
		<xsl:if test="@extends">
			<xsl:text>    @Override
</xsl:text>
		</xsl:if>
		<xsl:text>    protected void contentToString(StringBuffer sb) {
</xsl:text>
		<xsl:if test="@extends">
			<xsl:text>        super.contentToString( sb );

</xsl:text>
		</xsl:if>
		<xsl:for-each select="$own-columns">
			<xsl:text>        append( sb, "</xsl:text>
			<xsl:call-template name="column-name"/>
			<xsl:text>", </xsl:text>
			<xsl:call-template name="column-name"/>
			<xsl:text> );
</xsl:text>
		</xsl:for-each>
		<xsl:call-template name="append-keys"/>
		<xsl:text>    }
</xsl:text>
	</xsl:template>


	<xsl:template name="append-keys">
		<xsl:param name="ctx" select="$keycol"/>
		<xsl:param name="blocked" select="1"/>
		<xsl:for-each select="$ctx">
			<xsl:if test="$blocked != 1">
				<xsl:text>        append( sb, "</xsl:text>
				<xsl:call-template name="column-name"/>
				<xsl:text>", </xsl:text>
				<xsl:call-template name="column-name"/>
				<xsl:text> );
</xsl:text>
			</xsl:if>
			<xsl:variable name="ptname" select="db:ref/@table"/>
			<xsl:call-template name="append-keys">
				<xsl:with-param name="ctx" select="/db:database/db:tables/db:table[@name = $ptname]/db:columns/db:column[db:ref/@gae-parent = 'true']"/>
				<xsl:with-param name="blocked" select="0"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template> 


	<xsl:template name="method-append">
	</xsl:template>


	<xsl:template name="is-modified">
		<xsl:variable name="mode_column" select="../../db:edit-mode='column'"/>
		<xsl:if test="not($mode_column) and db:edit and not(db:not-null) and not(db:pk)">
			<xsl:text>yes</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="dto-column-type">
		<xsl:call-template name="column-ObjectType"/>
	</xsl:template>

	<xsl:template name="transient">
		<xsl:if test="db:transient[not(@io) or @io='true']">
			<xsl:text>transient </xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
