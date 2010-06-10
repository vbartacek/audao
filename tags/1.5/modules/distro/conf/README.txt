AUDAO - Automatic DAO Generator README
======================================

Version 1.5
June 9, 2010


OVERVIEW
--------

AUDAO is a tool for generating SQL - DDL and DAO libraries.
The input is a configuration file (XML) describing the database entities
and relations. The output is a set of SQLs (CREATE/DROP/INSERT)
and Java source codes.

The purpose of this tool is to speed up of development of database
powered applications. The designer creates one configuration file
and everything other is automatically generated. The developer does not need
to be aware of the database type or to handle most of potential
DB exceptions (SQLException or JDOException).

Currently the following databases are supported:
    * MySQL - version 3, 4, 5
    * Oracle - version 9i, 10g and 11g
    * Google App Engie (Java - low-level API) - Appengine SDK 1.3.3.1
    * JDO (Google App Engine) - DEPRECATED - NOT FULLY IMPLEMENTED !

Currently the following DAO / DTO programming language is supported:
    * Java - version 1.5, 1.6



DEPENDENCIES
------------


= Compilation =

Currently the following external libraries are needed for compilation
of the generated Java source files:
    * Apache Commons Logging: commons-logging-1.1.1.jar
    * Google AppEngine API: appengine-api-1.0-sdk-1.3.4.jar  (only for GAE)
    * JDO2 - javax.jdo.*: jdo2-api*.jar  (only for GAE - JDO)
    * Google Web Toolkit API (1.6 or higher): gwt-user.jar
        (only for DTO GWT custom serializers)
 


= Running =

For using (running) the DAO classes you need to install MySQL or Oracle JDBC
implementation libraries (mysl-connector*.jar or ojdbc*.jar) depending
the target DB type.

For Google App Engine as the target DB type you need to have installed
the AppEngine API - which is a part of the Google App Engine SDK.

If you are using dynamic queries for Google App Engine DB type,
then you also the following libraries are needed:
    * ANTLR3 runtime library: lib/antlr-runtime.jar
    * GQL dynamic query parser library: lib/audao-runtime-gql-1.5.jar

For Google App Engine - JDO - you need to have installed also the JDO2 library
(javax.jdo.*) - which is a part of the Google App Engine SDK.



INSTALLATION INSTRUCTION
------------------------

AuDAO is distributed as a ZIP file.

You can unzip the file into a global directory such as /usr/local or
C:\Program Files (preferred variant) or into any other directory you
choose.



DOCUMENTATION:
--------------

The documentation is included within this distribution in HTML form.
Point your browser to docs/index.html file.



KNOWN ISSUES:
-------------

This version of AuDAO should do the following:

    * generate SQL create/drop scripts
    * generate Java DAO sources for MySQL, Oracle and Google App Engine

The open issues:
    http://code.google.com/p/audao/issues/list



UNINSTALLING AUDAO
------------------

Remove the directory where you unzipped the distribution ZIP file.
AuDAO does not reside anywhere else.



SOURCE CODE
-----------

AuDAO is an open-source project. The sources and other relevant information
you can find at http://code.google.com/p/audao/



SUPPORT:
--------

For support, please send e-mail to audao@spoledge.com


Thank you for choosing AuDAO.
   -The Spoledge AuDAO Team, www.spoledge.com

