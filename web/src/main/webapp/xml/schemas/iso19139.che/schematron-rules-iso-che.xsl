<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sch="http://www.ascc.net/xml/schematron"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:che="http://www.geocat.ch/2008/che"
                version="1.0"
                gml:dummy-for-xmlns=""
                gmd:dummy-for-xmlns=""
                srv:dummy-for-xmlns=""
                gco:dummy-for-xmlns=""
                geonet:dummy-for-xmlns=""
                xlink:dummy-for-xmlns=""
                che:dummy-for-xmlns="">
   <xsl:output method="xml"/>
   <xsl:param name="lang"/>
   <xsl:variable name="loc" select="document(concat('loc/', $lang, '/schematron.xml'))"/>
   <xsl:template match="*|@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:if test="count(. | ../@*) = count(../@*)">@</xsl:if>
      <xsl:value-of select="name()"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="/">
      <geonet:schematronerrors>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M100"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M101"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M102"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M103"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M11"/>
      </geonet:schematronerrors>
   </xsl:template>
   <xsl:template match="//che:CHE_MD_DataIdentification" priority="4000" mode="M8">
      <xsl:if test="che:basicGeodataID/gco:CharacterString!='' and      (not(che:basicGeodataIDType) or che:basicGeodataIDType/che:basicGeodataIDTypeCode/@codeListValue='')">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e29">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M100/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="//che:CHE_MD_FeatureCatalogueDescription" priority="4000" mode="M9">
      <xsl:if test="che:dataModel/che:PT_FreeURL/che:URLGroup/che:LocalisedURL!='' and      (not(che:modelType) or che:modelType/che:CHE_MD_modelTypeCode/@codeListValue='')">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e39">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M101/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="//*[*/@codeListValue]" priority="4000" mode="M10">
      <xsl:if test="*/@codeListValue=''">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e48">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M102/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="//gmd:CI_Citation/gmd:title" priority="4000" mode="M11">
      <xsl:if test="gco:CharacterString=''">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e57">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M103/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="text()" priority="-1"/>
</xsl:stylesheet>