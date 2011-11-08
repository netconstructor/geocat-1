<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geonet="http://www.fao.org/geonetwork"
	xmlns:exslt="http://exslt.org/common" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
	exclude-result-prefixes="gco gmd dc exslt geonet">

    <xsl:template name="geocatButtons">
        <xsl:param name="metadata"/>
        <xsl:param name="buttons"/>
        <xsl:param name="baseURL"/>

        <xsl:variable name="mdURL" select="normalize-space(concat($baseURL, '?uuid=', geonet:info/uuid))"/>

            <xsl:if test="$buttons!=''">
                <xsl:copy-of select="$buttons"/>
            </xsl:if>
            <tr>
                <td align="center" valign="left" class="padded-content">
                    <table width="100%">
                        <tr>
                            <td align="left" valign="middle" class="padded-content" height="40">
                                <xsl:call-template name="logo"/>
                            </td>
                            <td class="padded" width="90%">
                                <h1 align="left">
                                    <xsl:value-of select="$metadata/title"/>
                                </h1>
                            </td>
							<xsl:variable name="fileId" select="normalize-space(*:fileIdentifier)" />

                            <!-- Schema based user interactions -->
                            <td align="right" class="padded-content" height="16" nowrap="nowrap">
								<xsl:call-template name="geocatMetadataLinks">
									<xsl:with-param name="metadata" select="$metadata"/>
									<xsl:with-param name="baseURL" select="$baseURL"/>
								</xsl:call-template>
                                <xsl:if test="/root/gui/reqService='metadata.show.embedded'">
                                    <br/><br/>
                                    <a href="metadata.show?id={geonet:info/id}&#38;currTab=complete" target="_{$fileId}"><xsl:value-of select="/root/gui/strings/completeTab"/></a>
                                </xsl:if>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="text-align:center;">
                                <xsl:call-template name="thumbnail">
                                    <xsl:with-param name="metadata" select="$metadata"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="relatedResources">
                                    <xsl:with-param name="edit" select="false()"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <!-- subtemplate title button -->
            <xsl:if test="(string(geonet:info/isTemplate)='s')">
                <tr><td class="padded-content" height="100%" align="center" valign="top">
                    <b><xsl:value-of select="geonet:info/title"/></b>
                </td></tr>
            </xsl:if>
    </xsl:template>
    
    <xsl:template name="geocatMetadataLinks">
        <xsl:param name="metadata"/>
        <xsl:param name="baseURL"/>

		<a class="noprint"
			href="{/root/gui/locService}/xml.metadata.get?id={geonet:info/id}"
			target="_blank" title="Download raw xml metadata">
			<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/download.png"
				alt="Native Version" title="Download raw xml metadata" />
		</a>
		<xsl:choose>
			<xsl:when test="contains(geonet:info/schema,'dublin-core')">
				<a class="noprint" href="{/root/gui/locService}/dc.xml?id={geonet:info/id}"
					target="_blank" title="Download Dublin Core metadata in XML">
					<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/xml.png"
						alt="Dublin Core XML" title="Save Dublin Core metadata as XML"
						border="0" />
				</a>
			</xsl:when>
			<xsl:when test="contains(geonet:info/schema,'fgdc-std')">
				<a class="noprint" href="{/root/gui/locService}/fgdc.xml?id={geonet:info/id}"
					target="_blank" title="Download FGDC metadata in XML">
					<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/xml.png"
						alt="FGDC XML" title="Save FGDC metadata as XML" border="0" />
				</a>
			</xsl:when>
			<xsl:when test="contains(geonet:info/schema,'iso19115')">
				<a class="noprint"
					href="{/root/gui/locService}/iso19115to19139.xml?id={geonet:info/id}"
					target="_blank" title="Save ISO19115/19139 metadata as XML">
					<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/xml.png"
						alt="IISO19115/19139 XML" title="Save ISO19115/19139 metadata as XML"
						border="0" />
				</a>
				<a href="{/root/gui/locService}/iso_arccatalog8.xml?id={geonet:info/id}"
					target="_blank" title="Download ISO19115 metadata in XML for ESRI ArcCatalog">
					<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/ac.png"
						alt="ISO19115 XML for ArcCatalog" title="Save ISO19115 metadata in XML for ESRI ArcCatalog"
						border="0" />
				</a>
			</xsl:when>
			<xsl:when test="contains(geonet:info/schema,'iso19139')">
				<a class="noprint" href="{/root/gui/locService}/iso19139.xml?id={geonet:info/id}"
					target="_blank" title="Download ISO19115/19139 metadata in XML">
					<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/xml.png"
						alt="ISO19115/19139 XML" title="Save ISO19115/19139 metadata as XML"
						border="0" />
				</a>
				<!-- Profil specific export services -->
				<xsl:choose>
					<xsl:when test="geonet:info/schema='iso19139.che'">
						<a href="{/root/gui/locService}/gm03.xml?id={geonet:info/id}"
							target="_blank" title="Download GM03"><!-- TODO : Translate -->
							<img style="border:0px;max-height:16px;" src="{/root/gui/url}/images/xml_gm03.png"
								alt="GM03 XML" title="Save GM03" border="0" />
						</a>
					</xsl:when>
				</xsl:choose>
	
			</xsl:when>
		</xsl:choose>
		<a href="{/root/gui/locService}/pdf?id={geonet:info/id}" title="PDF">
			<img src="{/root/gui/url}/images/pdf.gif" alt="PDF" title="PDF"
				style="border:0px;max-height:16px;" />
		</a>
		<!-- start permalink code -->
		<xsl:variable name="host" select="/root/gui/env/server/host" />
		<xsl:variable name="port" select="/root/gui/env/server/port" />
		<xsl:variable name="serverUrl">
			<xsl:choose>
				<xsl:when test="80 = /root/gui/env/server/port">
					<xsl:value-of select="concat('http://',$host,/root/gui/locService)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="concat('http://',$host,':',$port,/root/gui/locService)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
	
		<xsl:variable name="fileId" select="normalize-space(*:fileIdentifier)" />
		<a id="permalink_{$fileId}"
			onClick="permlink('{$serverUrl}/metadata.show?fileIdentifier={$fileId}&amp;currTab=simple') "
			target="_{$fileId}" title="Permalink"><!-- TODO : Translate -->
			<img src="{/root/gui/url}/images/link.png" alt="{/root/gui/strings/permlink}"
				title="{/root/gui/strings/permlink}" border="0" />
		</a>
		<!-- end permalink code -->
	</xsl:template>
   <xsl:template name="logo">
        <xsl:variable name="source" select="string(geonet:info/source)"/>
        <xsl:variable name="groupLogoUuid" select="string(geonet:info/groupLogoUuid)"/>
        <xsl:variable name="groupWebsite" select="string(geonet:info/groupWebsite)"/>
        <xsl:choose>
            <xsl:when test="$groupWebsite != '' and $groupLogoUuid != ''">
                <a href="{$groupWebsite}" target="_blank">
                    <img src="{/root/gui/url}/images/logos/{$groupLogoUuid}.png" width="40"/>
                </a>
            </xsl:when>
            <xsl:when test="$groupLogoUuid != ''">
                <img src="{/root/gui/url}/images/logos/{$groupLogoUuid}.png" width="40"/>
            </xsl:when>
            <xsl:when test="/root/gui/sources/record[string(siteid)=$source]">
                <a href="{/root/gui/sources/record[string(siteid)=$source]/url}" target="_blank">
                    <img src="{/root/gui/url}/images/logos/{$source}.gif" width="40"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <img src="{/root/gui/url}/images/logos/{$source}.gif" width="40"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    
</xsl:stylesheet>