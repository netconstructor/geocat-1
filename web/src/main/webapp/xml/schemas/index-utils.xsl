<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  version="1.0">
  <xsl:variable name="UPPER">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="LOWER">abcdefghijklmnopqrstuvwxyz</xsl:variable>

  <xsl:template name="langId19139">
    <xsl:variable name="tmp">
        <xsl:choose>
            <xsl:when test="*[@gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString">
               <xsl:value-of select="*[@gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString"/>  
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$defaultLang"/></xsl:otherwise>
         </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="translate($tmp, $UPPER, $LOWER)"></xsl:value-of>
  </xsl:template>

    <!-- iso3code of default index language -->
    <xsl:variable name="defaultLang">eng</xsl:variable>
</xsl:stylesheet>