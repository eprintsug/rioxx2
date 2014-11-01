<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rioxx="http://docs.rioxx.net/schema/v2.0/">

<xsl:output method="html" doctype-system="about:legacy-compat"/>

<xsl:template match="/">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="rioxx:rioxx">
	<html>
		<head>
			<script src="http://rioxx.net/javascripts/jquery-1.10.2.js" type="text/javascript"></script>
			<link href="http://rioxx.net/stylesheets/application.css" rel="stylesheet" type="text/css" media="all" />
			<title>RIOXX: Application Profile Version 2.0 beta 1</title>
		</head>
		<body>
			<div class='container-fluid'>
				<div class='row-fluid'>
					<div class='col-xs-12'><a href="http://rioxx.net/"><img src="http://rioxx.net/images/rioxx_logo.png" /></a></div>
				</div>
			</div>
			<div class='row-fluid'>
				<div class='col-xs-12'>
					<div class='panel panel-default'>
						<div class='panel-heading'>
							<h1 class='post-title'>Application Profile Version 2.0 beta 1</h1>
						</div>
					</div>
				</div>
			</div>
			<table class='table table-condensed table-striped sorted-table'>
				<thead>
					<tr>
						<th>Element</th>
						<th>Value</th>
						<th>XML</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="*">
						<tr>
							<td><xsl:value-of select="name()"/></td>
							<td><xsl:value-of select="."/></td>
							<td class="xml" style="font-family: monospace"><xsl:copy-of select="."/></td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			<script type="text/javascript">
				$("td.xml").each( function() {
					// escape XML
					$( this ).text( $( this ).html() )
					// remove xmlns attributes
					$( this ).text( $( this ).text().replace( /\sxmlns(:[a-z]+)?=\"[^\"]+\"/g, '' ) );
				} );
			</script>
		</body>
	</html>
</xsl:template>

</xsl:stylesheet>
