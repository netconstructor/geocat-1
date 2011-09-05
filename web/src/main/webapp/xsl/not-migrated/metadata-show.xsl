<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:geonet="http://www.fao.org/geonetwork"
	xmlns:xalan= "http://xml.apache.org/xalan"
	xmlns:dc = "http://purl.org/dc/elements/1.1/"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:gco="http://www.isotc211.org/2005/gco">

	<!--
	show metadata form
	-->

	<xsl:include href="main.xsl"/>
	<xsl:include href="metadata.xsl"/>
    <xsl:include href="mapfish_includes.xsl" />

	<xsl:variable name="host" select="/root/gui/env/server/host" />
	<xsl:variable name="port" select="/root/gui/env/server/port" />
	<xsl:variable name="baseURL" select="concat('http://',$host,':',$port,/root/gui/url)" />
	<xsl:variable name="serverUrl" select="concat('http://',$host,':',$port,/root/gui/locService)" />

	<!--
	additional scripts
	-->
	<xsl:template mode="script" match="/">
    <xsl:call-template name="mapfish_includes"/>
    <xsl:call-template name="extentViewerJavascript"/>

    <script language="JavaScript1.2" type="text/javascript">

			function doAction(action)
			{
				// alert("In doAction(" + action + ")"); // DEBUG
				document.mainForm.action = action;
				goSubmit('mainForm');
			}

			function doTabAction(action, tab)
			{
				// alert("In doTabAction(" + action + ", " + tab + ")"); // DEBUG
				document.mainForm.currTab.value = tab;
				doAction(action);
			}
		</script>

		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/core/kernel/kernel.js"/>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/editor/tooltip-manager.js"></script>
        <xsl:call-template name="js-translations"/>
	</xsl:template>

	<!--
	page content
	-->
	<xsl:template name="content">
		<xsl:param name="schema">
			<xsl:apply-templates mode="schema" select="."/>
		</xsl:param>

		<table  width="100%" height="100%">
			<xsl:for-each select="/root/*[name(.)!='gui' and name(.)!='request']"> <!-- just one -->
				<tr height="100%">
					<td class="blue-content noprint" width="150" valign="top">
						<xsl:call-template name="tab">
							<xsl:with-param name="tabLink" select="concat(/root/gui/locService,'/metadata.show')"/>
						</xsl:call-template>
					</td>
					<td class="content" valign="top">

						<xsl:variable name="md">
							<xsl:apply-templates mode="brief" select="."/>
						</xsl:variable>
						<xsl:variable name="metadata" select="xalan:nodeset($md)/*[1]"/>

						<xsl:variable name="buttons">
							<tr class="noprint"><td class="padded-content" height="100%" align="center" valign="top">
								<xsl:call-template name="buttons"/>
							</td></tr>
						</xsl:variable>

						<table width="100%">

							<xsl:call-template name="metadata-show-header">
								<xsl:with-param name="metadata" select="$metadata"/>
								<xsl:with-param name="buttons" select="$buttons"/>
								<xsl:with-param name="baseURL" select="$baseURL"/>
							</xsl:call-template>

							<tr><td class="padded-content">
								<table class="md" width="100%">
									<form name="mainForm" accept-charset="UTF-8" method="POST" action="{/root/gui/locService}/metadata.edit">
										<input type="hidden" name="id" value="{geonet:info/id}"/>
										<input type="hidden" name="currTab" value="{/root/gui/currTab}"/>

										<xsl:choose>
											<xsl:when test="$currTab='xml'">
												<xsl:apply-templates mode="xmlDocument" select="."/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates mode="elementEP" select="."/>
											</xsl:otherwise>
										</xsl:choose>

									</form>
								</table>
							</td></tr>

							<xsl:if test="$buttons!=''">
								<xsl:copy-of select="$buttons"/>
							</xsl:if>

						</table>
					</td>
				</tr>
			</xsl:for-each>
			<tr><td class="blue-content" colspan="3"/></tr>
		</table>
	</xsl:template>

</xsl:stylesheet>
