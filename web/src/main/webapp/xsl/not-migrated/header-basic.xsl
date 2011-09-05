<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
	main html header
	-->
	<xsl:template name="header-basic">

		<!-- title -->
		<title><xsl:value-of select="/root/gui/strings/title"/></title>
		<link href="{/root/gui/url}/favicon.ico" rel="shortcut icon" type="image/x-icon" />
		<link href="{/root/gui/url}/favicon.ico" rel="icon" type="image/x-icon" />

		<!-- stylesheet -->
		<link rel="stylesheet" type="text/css" href="{/root/gui/url}/scripts/not-migrated/geonetwork.css"/>
        <link rel="stylesheet" type="text/css" href="{/root/gui/url}/print.css" media="print"/>
        <xsl:if test="/root/request/printview">
          <link rel="stylesheet" type="text/css" href="{/root/gui/url}/print.css" media="all"/>
        </xsl:if>

		<!-- Recent updates newsfeed -->
		<link href="{/root/gui/locService}/rss.latest?georss=gml" rel="alternate" type="application/rss+xml" title="GeoNetwork opensource GeoRSS | {/root/gui/strings/recentAdditions}" />
		<link href="{/root/gui/locService}/portal.opensearch" rel="search" type="application/opensearchdescription+xml">

		<xsl:attribute name="title">GeoNetwork|<xsl:value-of select="//site/organization"/>|<xsl:value-of select="//site/name"/></xsl:attribute>

		</link>


		<!-- meta tags -->
		<xsl:copy-of select="/root/gui/strings/header_meta/meta"/>

		<META HTTP-EQUIV="Pragma"  CONTENT="no-cache"/>
		<META HTTP-EQUIV="Expires" CONTENT="-1"/>

		<script language="JavaScript" type="text/javascript">
			var Env = new Object();

			Env.locService= "<xsl:value-of select="/root/gui/locService"/>";
			Env.locUrl    = "<xsl:value-of select="/root/gui/locUrl"/>";
			Env.url       = "<xsl:value-of select="/root/gui/url"/>";
			Env.lang      = "<xsl:value-of select="/root/gui/language"/>";
			var on        = "<xsl:value-of select="/root/gui/url"/>/images/plus.gif";
            var off       = "<xsl:value-of select="/root/gui/url"/>/images/minus.png";

			<xsl:if test="//service/@name = 'main.home'">
            document.onkeyup = alertkey;

            function alertkey(e) {
             if (!e) {
                 if (window.event) {
                     e = window.event;
                 } else {
                     return;
                 }
             }

             if (e.keyCode == 13) {
                  <xsl:if test="string(/root/gui/session/userId)=''">
                  if ($('username').value != '') { // login action
                    goSubmit('login')
                    return;
                  }
                  </xsl:if>
                  if (document.cookie.indexOf("search=advanced")!=-1)
                    runAdvancedSearch();
                  else
                    runSimpleSearch();
             }
            };
			</xsl:if>
			
			var strings = {
				<xsl:for-each select="/root/gui/strings/*[@mode='js']">
					"<xsl:value-of select="name(.)"/>":"<xsl:value-of select="normalize-space(translate(.,'&quot;', '`'))"/>"
					<xsl:if test="position()!=last()">,</xsl:if>
				</xsl:for-each>
			};
			
			
			function translateStrings(text) {
				return strings[text] || text;
			}
		</script>

	</xsl:template>
	

</xsl:stylesheet>
