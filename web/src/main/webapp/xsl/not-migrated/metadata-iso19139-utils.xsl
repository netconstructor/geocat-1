<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
    version="1.0">


    <!-- Template use to return a gco:CharacterString element
        in default metadata language or in a specific locale
        if exist. 
        FIXME : gmd:PT_FreeText should not be in the match clause as gco:CharacterString 
        is mandatory and PT_FreeText optional. Added for testing GM03 import.
    -->
    <xsl:template name="localised" mode="localised" match="*[gco:CharacterString or gmd:PT_FreeText]">
        <xsl:param name="langId"/>

        <xsl:choose>
            <xsl:when
                test="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId]) != ''">
                <xsl:value-of
                    select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId]"
                />
            </xsl:when>
            <xsl:when test="not(gco:CharacterString)">
                <!-- If no CharacterString, try to use the first textGroup available -->
                <xsl:value-of
                    select="gmd:PT_FreeText/gmd:textGroup[position()=1]/gmd:LocalisedCharacterString"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="gco:CharacterString"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Get lang #id in metadata PT_Locale section,  if not return english by default -->
    <xsl:template name="getLangId">
        <xsl:param name="md"/>
        <xsl:param name="langGui"/>

        <!-- Check loc exist in locales -->
        <xsl:choose>
            <xsl:when
                test="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $langGui]/@id"
                    >#<xsl:value-of
                        select="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $langGui]/@id"
                /></xsl:when>
            <xsl:otherwise>#EN</xsl:otherwise>            
        </xsl:choose>
    </xsl:template>
    
    <!-- Get lang codeListValue in metadata PT_Locale section,  if not return eng by default -->
    <xsl:template name="getLangCode">
        <xsl:param name="md"/>
        <xsl:param name="langId"/>

          <xsl:choose>
            <xsl:when
                test="$md/gmd:locale/gmd:PT_Locale[@id=$langId]/gmd:languageCode/gmd:LanguageCode/@codeListValue"
                    ><xsl:value-of
                        select="$md/gmd:locale/gmd:PT_Locale[@id=$langId]/gmd:languageCode/gmd:LanguageCode/@codeListValue"
                /></xsl:when>
            <xsl:otherwise>eng</xsl:otherwise>            
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
