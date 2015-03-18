# AuDAO - SQL and Java DAO layer generator #

Source: XML (see [documentation](http://audao.spoledge.com/doc-index.html) or [xsd documentation](http://audao.spoledge.com/audao.html) or [xsd](http://audao.spoledge.com/audao.xsd)).

Target: Java source DAO + DTO files and SQL files.

DAO layer contains abstract classes (Java interfaces) and corresponding target implementation classes.

DAO Implementations for:
  * MySQL
  * Oracle DB
  * HSQLDB
  * Google App Engine (+ GQL parser and [Extended GQL parser](ExtendedGQLParser.md))

DTO classes can be used with GWT without any restrictions.

Online generator, full documentation and examples are at http://audao.spoledge.com

## Generating your DAO ##

Unpack the audao zip file. In your project's directory create Apache Ant build.xml:

```
<?xml version="1.0"?>
<project name="test" basedir="." default="dist">

  <property name="audao.home" location="/usr/local/audao-1.3"/>

  <import file="${audao.home}/tools/build-audao.xml"/>

  <target name="dist">
    <antcall target="audao-jar">
      <param name="audao-xml" location="src/my-config.xml"/>
      <param name="audao-gen-dir" location="build/audao"/>
      <param name="audao-dbtype" value="oracle"/>
      <param name="audao-package" value="com.foo"/>
      <param name="audao-jar" location="dist/test-db-oracle.jar"/>
    </antcall>
  </target>

</project>
```

The full description of the parameters is [here](http://audao.spoledge.com/doc-generator-tools.html#ant_tools)

<wiki:gadget url="http://google-code-feed-gadget.googlecode.com/svn/trunk/gadget.xml" up\_feeds="http://audao.spoledge.com/feed.jsp" width="500px" height="340px" border="0"/>