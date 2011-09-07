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
    
    <xsl:variable name="host" select="/root/gui/env/server/host" />
    <xsl:variable name="port" select="/root/gui/env/server/port" />
    <xsl:variable name="baseURL" select="concat('http://',$host,':',$port,/root/gui/url)" />
    <xsl:variable name="serverUrl" select="concat('http://',$host,':',$port,/root/gui/locService)" />
    
    <xsl:template match="/">
            
        <table width="100%" height="100%">
            <!-- content -->
            <tr height="100%"><td>
                <xsl:call-template name="content"/>
            </td></tr>
        </table>
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
                    <td class="content" valign="top">
                        
                        <xsl:variable name="md">
                            <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="$md/*[1]"/>
                        
                        <table width="100%">
                            
                            <xsl:call-template name="metadata-show-header">
                                <xsl:with-param name="metadata" select="$metadata"/>
                                <xsl:with-param name="buttons"/>
                                <xsl:with-param name="baseURL" select="$baseURL"/>
                            </xsl:call-template>
                            
                            <tr>
                                <td class="padded-content">
                                <table class="md" width="100%">
                                        <xsl:choose>
                                            <xsl:when test="$currTab='xml'">
                                                <xsl:apply-templates mode="xmlDocument" select="."/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates mode="elementEP" select=".">
                                                    <xsl:with-param name="embedded" select="true()" />
                                                </xsl:apply-templates>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                </table>
                            </td></tr>
                        </table>
                    </td>
                </tr>
            </xsl:for-each>
            <!--<tr>-->
                <!--<td class="blue-content" />-->
            <!--</tr>-->
        </table>
    </xsl:template>
    
</xsl:stylesheet>
