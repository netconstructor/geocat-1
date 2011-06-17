metadata_expire_operations.xsl
metadata_expire_results.xsl<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="main.xsl" />
	<xsl:include href="extent-util.xsl" />
    <xsl:include href="mapfish_includes.xsl" />

	<!--
    additional scripts
    -->
	<xsl:template mode="script" match="/">
		<!-- javascript -->
		<script language="JavaScript1.2" type="text/javascript">
			var locService= "<xsl:value-of select="/root/gui/locService" />";
			var locUrl = "<xsl:value-of select="/root/gui/locUrl" />";
			var url = "<xsl:value-of select="/root/gui/url" />";
			var foundWords = '<xsl:value-of select="/root/gui/strings/foundWords" />';
			var pages = '<xsl:value-of select="/root/gui/strings/pages" />';
			var selection = '<xsl:value-of select="/root/gui/strings/selection" />';
			var sort = '<xsl:value-of select="/root/gui/strings/sort" />';
			var label = '<xsl:value-of select="/root/gui/strings/label" />';
			var definition = '<xsl:value-of select="/root/gui/strings/definition" />';
		</script>
		<script type="text/javascript" src="{/root/gui/url}/scripts/core/kernel/kernel.js" language="JavaScript" />
        <script type="text/javascript" src="{/root/gui/url}/scripts/extentSearching.js" language="JavaScript"/>
    	<script type="text/javascript" src="{/root/gui/url}/scripts/scriptaculous/scriptaculous.js?load=effects,controls" />

        <xsl:call-template name="mapfish_includes"/>

		<script language="JavaScript1.2" type="text/javascript">

         	function doSearchSubmit(page)
			{
    			esearching.search(document.simplesearch, page, drawCmp.writeFeature({format:'WKT'}));
			}

			function removeExtent(){
				if (confirm('<xsl:value-of select="/root/gui/strings/extent/confirmDelete" />')){
				    esearching.deleteExtent(document.simplesearch);
				}
			}
			function refresh(){
			    doSearchSubmit();
			    msgWindow.close();
			}

            Ext.onReady(initMapComponent);
            function initMapComponent() {
                var mapCmp = new MapComponent('olMap', {displayLayertree: false});
                drawCmp = new MapDrawComponent(mapCmp.map, {toolbar: mapCmp.toolbar, activate: true});
            }
		</script>
	</xsl:template>
	<!--
    page content
    -->
	<xsl:template name="content">
		<table width="100%" height="100%">
			<tr>
				<td>
					<xsl:call-template name="formLayout">
						<xsl:with-param name="title">
							<xsl:value-of select="/root/gui/strings/extent/management" />
						</xsl:with-param>

						<xsl:with-param name="content">
							<xsl:call-template name="form" />
						</xsl:with-param>
						<xsl:with-param name="buttons">
							<button onclick="javascript:doSearchSubmit(1);" class="content">
								<xsl:value-of select="/root/gui/strings/search" />
							</button>
                            &#160;
                            <xsl:call-template name="buttonAdd">
                            <xsl:with-param name="typename">
                                <xsl:value-of select="'gn:xlinks'" />
                            </xsl:with-param>
                            <xsl:with-param name="wfs">
                                <xsl:value-of select="/root/response/wfs/@id" />
                            </xsl:with-param>
                            </xsl:call-template>
                            &#160;
                            <button class="content" type="button" onclick="load('{/root/gui/locService}/admin');"><xsl:value-of select="/root/gui/strings/back"/></button>
                        </xsl:with-param>
                        <xsl:with-param name="formfooter" select="'false'"/>
                    </xsl:call-template>
                </td>
            </tr>
            <tr>
                <td height="100%">
                    <xsl:call-template name="formLayout">
                        <xsl:with-param name="content">
                            <div id="divResults" style="display:none"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    
    <xsl:template name="form">
        <form method="get" action="javascript:doSearchSubmit(1);" name="simplesearch">
            <input value="200" type="hidden" id="numResults" name="numResults"/>
            <table align="center">
                <tr>
                    <td class="padded-content">
                        <table>
                            <tr>
                                <td class="padded-content" colspan="2">
                                    <table>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="/root/gui/strings/extents"/>
                                            </td>
                                            <td class="padded-content">
                                                <input value="" size="30" name="pattern" id="pattern" class="content" autocomplete="off"></input>
                                                <div id="extentList" class="keywordList"></div>
                                                <script type="text/javascript">
                                                      document.simplesearch.pattern.focus();

                                                      new Ajax.Autocompleter('pattern', 'extentList', 'extent.search.list?typename=gn:xlinks&amp;property=desc&amp;method=loose',{method:'get', paramName: 'pattern'});
                                                </script>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id="olMap" style="width:500px; height:300px"></div>
                    </td>
                </tr>
            </table>
        </form>
    </xsl:template>
</xsl:stylesheet>
