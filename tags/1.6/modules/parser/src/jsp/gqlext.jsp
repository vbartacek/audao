<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<jsp:directive.page language="java" contentType="text/html; charset=UTF-8" isELIgnored="false"/>
<jsp:directive.page import="com.google.appengine.api.datastore.DatastoreServiceFactory"/>
<jsp:directive.page import="com.google.appengine.api.datastore.Entity"/>
<jsp:directive.page import="com.spoledge.audao.parser.gql.GqlExtDynamic"/>
<jsp:directive.page import="com.spoledge.audao.parser.gql.PreparedGql"/>
<jsp:directive.page import="java.util.ArrayList"/>
<jsp:directive.page import="java.util.HashSet"/>
<jsp:directive.page import="java.util.Iterator"/>
<html>
<head>
<title>Extended GQL Console</title>
<style type="text/css">
body { background: #fff; color: #333; font-family: Arial, Verdana, Sans-Serif;}
table { border-collapse: collapse; border: 1px solid #888; width:100%}
td { border-top: 1px solid #888; padding: 2px 10px; font-size: 85%}
tr.header td { font-weigth: bold; background: #555; color: #fff}
tr.even td { background: #fff;}
tr.odd td { background: #ccc;}
</style>
</head>
<body>
<form action="gqlext.jsp" method="post">
	Enter a GQL statement (e.g. "SELECT * FROM MyEntity WHERE propertyName='propertyValue'"):<br/>
	<input type="text" size="96" name="gql" value="<c:out value="${param.gql}" escapeXml="true"/>"/><br/>
	<input type="submit" value="Execute"/>
	<input type="checkbox" name="confirm" value="true"/> confirm
</form>
<%
	String gql = request.getParameter( "gql" );
	int offset = 0;
	int maxRows = 20;

	try {
		offset = Integer.parseInt( request.getParameter("offset"));
	}
	catch (Exception e) {}

	if (gql != null && gql.length() != 0) {
		GqlExtDynamic gqld = new GqlExtDynamic( DatastoreServiceFactory.getDatastoreService());
							  
		try {
			PreparedGql pq = gqld.prepare( gql );

			if (pq.getQueryType().isUpdate()) {
				if ("true".equals(request.getParameter("confirm"))) {
					out.print( "Records processed: " + pq.executeUpdate());
				}
				else out.print( "Please confirm the statement." );
			}
			else {
				Iterator<Entity> result = pq.executeQuery().iterator();

				// find all property names
				ArrayList<Entity> entities = new ArrayList<Entity>( maxRows );
				HashSet<String> propNameSet = new HashSet<String>();

				int off = offset;

				while (result.hasNext()) {
					Entity ent = result.next();
					if (off-- > 0) continue;

					propNameSet.addAll( ent.getProperties().keySet() );
					entities.add( ent );

					if (entities.size() >= maxRows) break;
				}

				ArrayList<String> propNames = new ArrayList<String>( propNameSet );
				java.util.Collections.sort( propNames,
					new java.util.Comparator<String>() {
						public int compare( String s1, String s2) {
							return s1.compareTo( s2 );
						}
					});

				// render header
				out.print("<table><tr class=\"summary\"><td colspan=\""+ (propNames.size()+1)+"\">");
				if (entities.size() == 0) {
					out.print("No records found");
				}
				else {
					if (offset > 0 ) {
						off = offset >= maxRows ? offset - maxRows : 0;
						out.print("<a href=\"gqlext.jsp?gql=" + gql
							+ "&offset=" + off
							+ "\">Previous</a> " );
					}
					else {
						out.print( "Previous" );
					}

					out.print(" <b>" + (offset+1) + '-' + (offset+entities.size()) + "</b> ");

					if (result.hasNext()) {
						out.print("<a href=\"gqlext.jsp?gql=" + gql
							+ "&offset=" + (offset+maxRows)
							+ "\">Next</a> " );
					}
					else {
						out.print( "Next" );
					}
				}
				out.print("</td></tr>");

				if (entities.size() != 0) {
					out.print("<tr class=\"header\">");
					out.print("<td>Id</td>");
					for (String propName : propNames) {
						out.print("<td>" + propName + "</td>");
					}
					out.print("</tr>");
				}

				// render values
				int i = 0;
				for (Entity ent : entities) {
					out.print("<tr class=\"" + ((++i % 2)==0 ? "odd" : "even" ) +"\">");
					out.print("<td>");
					out.print( ent.getKey().getName() != null ? ent.getKey().getName() : ent.getKey().getId());
					out.print("</td>");
					for (String propName : propNames) {
						out.print( "<td>" );
						if (ent.hasProperty( propName )) {
							Object o = ent.getProperty( propName );
							if (o == null) {
								out.print( "null" );
							}
							else {
								pageContext.setAttribute("val", o.toString());
	%>
		<c:out value="${val}" escapeXml="true"/>
	<%
							}
						}
						out.print( "</td>" );
					}
					out.print("</tr>");
				}
				out.print("</table>");
			} // SELECT
		}
		catch (Exception e) {
			out.print( "Invalid GQL: " + e );
			e.printStackTrace();
		}
	}
	else {
%>
	Please enter a statement.
<%
	}
%>
</body>
</html>

