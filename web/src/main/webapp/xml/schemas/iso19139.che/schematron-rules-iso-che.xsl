<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:gml="http://www.opengis.net/gml" gml:dummy-for-xmlns="" xmlns:gmd="http://www.isotc211.org/2005/gmd" gmd:dummy-for-xmlns="" xmlns:che="http://www.geocat.ch/2008/che" che:dummy-for-xmlns="" xmlns:srv="http://www.isotc211.org/2005/srv" srv:dummy-for-xmlns="" xmlns:gco="http://www.isotc211.org/2005/gco" gco:dummy-for-xmlns="" xmlns:geonet="http://www.fao.org/geonetwork" geonet:dummy-for-xmlns="" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:dummy-for-xmlns="" version="1.0">
<!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<axsl:param name="archiveDirParameter"/>
<axsl:param name="archiveNameParameter"/>
<axsl:param name="fileNameParameter"/>
<axsl:param name="fileDirParameter"/>
<axsl:variable name="document-uri">
<axsl:value-of select="document-uri(/)"/>
</axsl:variable>

<!--PHASES-->


<!--PROLOG-->
<axsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" indent="yes" standalone="yes" omit-xml-declaration="no" method="xml"/>
<axsl:include xmlns:svrl="http://purl.oclc.org/dsdl/svrl" href="../../../xsl/utils-fn.xsl"/>
<axsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="lang"/>
<axsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="thesaurusDir"/>
<axsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="rule"/>
<axsl:variable xmlns:svrl="http://purl.oclc.org/dsdl/svrl" select="document(concat('loc/', $lang, '/', substring-before($rule, '.xsl'), '.xml'))" name="loc"/>

<!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<axsl:template mode="schematron-select-full-path" match="*">
<axsl:apply-templates mode="schematron-get-full-path" select="."/>
</axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<axsl:template mode="schematron-get-full-path" match="*">
<axsl:apply-templates mode="schematron-get-full-path" select="parent::*"/>
<axsl:text>/</axsl:text>
<axsl:choose>
<axsl:when test="namespace-uri()=''">
<axsl:value-of select="name()"/>
<axsl:variable select="1+    count(preceding-sibling::*[name()=name(current())])" name="p_1"/>
<axsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<axsl:value-of select="$p_1"/>]</axsl:if>
</axsl:when>
<axsl:otherwise>
<axsl:text>*[local-name()='</axsl:text>
<axsl:value-of select="local-name()"/>
<axsl:text>']</axsl:text>
<axsl:variable select="1+   count(preceding-sibling::*[local-name()=local-name(current())])" name="p_2"/>
<axsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<axsl:value-of select="$p_2"/>]</axsl:if>
</axsl:otherwise>
</axsl:choose>
</axsl:template>
<axsl:template mode="schematron-get-full-path" match="@*">
<axsl:text>/</axsl:text>
<axsl:choose>
<axsl:when test="namespace-uri()=''">@<axsl:value-of select="name()"/>
</axsl:when>
<axsl:otherwise>
<axsl:text>@*[local-name()='</axsl:text>
<axsl:value-of select="local-name()"/>
<axsl:text>' and namespace-uri()='</axsl:text>
<axsl:value-of select="namespace-uri()"/>
<axsl:text>']</axsl:text>
</axsl:otherwise>
</axsl:choose>
</axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<axsl:template mode="schematron-get-full-path-2" match="node() | @*">
<axsl:for-each select="ancestor-or-self::*">
<axsl:text>/</axsl:text>
<axsl:value-of select="name(.)"/>
<axsl:if test="preceding-sibling::*[name(.)=name(current())]">
<axsl:text>[</axsl:text>
<axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
<axsl:text>]</axsl:text>
</axsl:if>
</axsl:for-each>
<axsl:if test="not(self::*)">
<axsl:text/>/@<axsl:value-of select="name(.)"/>
</axsl:if>
</axsl:template>
<!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<axsl:template mode="schematron-get-full-path-3" match="node() | @*">
<axsl:for-each select="ancestor-or-self::*">
<axsl:text>/</axsl:text>
<axsl:value-of select="name(.)"/>
<axsl:if test="parent::*">
<axsl:text>[</axsl:text>
<axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
<axsl:text>]</axsl:text>
</axsl:if>
</axsl:for-each>
<axsl:if test="not(self::*)">
<axsl:text/>/@<axsl:value-of select="name(.)"/>
</axsl:if>
</axsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<axsl:template mode="generate-id-from-path" match="/"/>
<axsl:template mode="generate-id-from-path" match="text()">
<axsl:apply-templates mode="generate-id-from-path" select="parent::*"/>
<axsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
</axsl:template>
<axsl:template mode="generate-id-from-path" match="comment()">
<axsl:apply-templates mode="generate-id-from-path" select="parent::*"/>
<axsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
</axsl:template>
<axsl:template mode="generate-id-from-path" match="processing-instruction()">
<axsl:apply-templates mode="generate-id-from-path" select="parent::*"/>
<axsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
</axsl:template>
<axsl:template mode="generate-id-from-path" match="@*">
<axsl:apply-templates mode="generate-id-from-path" select="parent::*"/>
<axsl:value-of select="concat('.@', name())"/>
</axsl:template>
<axsl:template priority="-0.5" mode="generate-id-from-path" match="*">
<axsl:apply-templates mode="generate-id-from-path" select="parent::*"/>
<axsl:text>.</axsl:text>
<axsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
</axsl:template>

<!--MODE: GENERATE-ID-2 -->
<axsl:template mode="generate-id-2" match="/">U</axsl:template>
<axsl:template priority="2" mode="generate-id-2" match="*">
<axsl:text>U</axsl:text>
<axsl:number count="*" level="multiple"/>
</axsl:template>
<axsl:template mode="generate-id-2" match="node()">
<axsl:text>U.</axsl:text>
<axsl:number count="*" level="multiple"/>
<axsl:text>n</axsl:text>
<axsl:number count="node()"/>
</axsl:template>
<axsl:template mode="generate-id-2" match="@*">
<axsl:text>U.</axsl:text>
<axsl:number count="*" level="multiple"/>
<axsl:text>_</axsl:text>
<axsl:value-of select="string-length(local-name(.))"/>
<axsl:text>_</axsl:text>
<axsl:value-of select="translate(name(),':','.')"/>
</axsl:template>
<!--Strip characters-->
<axsl:template priority="-1" match="text()"/>

<!--SCHEMA SETUP-->
<axsl:template match="/">
<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" schemaVersion="" title="Schematron validation / GeoNetwork recommendations">
<axsl:comment>
<axsl:value-of select="$archiveDirParameter"/>   
		 <axsl:value-of select="$archiveNameParameter"/>  
		 <axsl:value-of select="$fileNameParameter"/>  
		 <axsl:value-of select="$fileDirParameter"/>
</axsl:comment>
<svrl:ns-prefix-in-attribute-values prefix="gml" uri="http://www.opengis.net/gml"/>
<svrl:ns-prefix-in-attribute-values prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
<svrl:ns-prefix-in-attribute-values prefix="che" uri="http://www.geocat.ch/2008/che"/>
<svrl:ns-prefix-in-attribute-values prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
<svrl:ns-prefix-in-attribute-values prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
<svrl:ns-prefix-in-attribute-values prefix="geonet" uri="http://www.fao.org/geonetwork"/>
<svrl:ns-prefix-in-attribute-values prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
<svrl:active-pattern>
<axsl:attribute name="document">
<axsl:value-of select="document-uri(/)"/>
</axsl:attribute>
<axsl:attribute name="name">
<axsl:value-of select="$loc/strings/M100"/>
</axsl:attribute>
<axsl:apply-templates/>
</svrl:active-pattern>
<axsl:apply-templates mode="M8" select="/"/>
<svrl:active-pattern>
<axsl:attribute name="document">
<axsl:value-of select="document-uri(/)"/>
</axsl:attribute>
<axsl:attribute name="name">
<axsl:value-of select="$loc/strings/M101"/>
</axsl:attribute>
<axsl:apply-templates/>
</svrl:active-pattern>
<axsl:apply-templates mode="M9" select="/"/>
<svrl:active-pattern>
<axsl:attribute name="document">
<axsl:value-of select="document-uri(/)"/>
</axsl:attribute>
<axsl:attribute name="name">
<axsl:value-of select="$loc/strings/M102"/>
</axsl:attribute>
<axsl:apply-templates/>
</svrl:active-pattern>
<axsl:apply-templates mode="M10" select="/"/>
<svrl:active-pattern>
<axsl:attribute name="document">
<axsl:value-of select="document-uri(/)"/>
</axsl:attribute>
<axsl:attribute name="name">
<axsl:value-of select="$loc/strings/M103"/>
</axsl:attribute>
<axsl:apply-templates/>
</svrl:active-pattern>
<axsl:apply-templates mode="M11" select="/"/>
</svrl:schematron-output>
</axsl:template>

<!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron validation / GeoNetwork recommendations</svrl:text>

<!--PATTERN $loc/strings/M100-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/M100"/>
</svrl:text>

	<!--RULE -->
<axsl:template mode="M8" priority="1000" match="//che:CHE_MD_DataIdentification">
<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//che:CHE_MD_DataIdentification"/>
<axsl:variable select="che:basicGeodataID/gco:CharacterString!='' and (not(che:basicGeodataIDType) or che:basicGeodataIDType/che:basicGeodataIDTypeCode/@codeListValue='')" name="emptyGeoId"/>

		<!--ASSERT -->
<axsl:choose>
<axsl:when test="not($emptyGeoId)"/>
<axsl:otherwise>
<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyGeoId)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/alert.M100"/>
</svrl:text>
</svrl:failed-assert>
</axsl:otherwise>
</axsl:choose>

		<!--REPORT -->
<axsl:if test="not($emptyGeoId)">
<svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyGeoId)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<axsl:text/>
<axsl:copy-of select="$loc/strings/report.M100/div"/>
<axsl:text/>
</svrl:text>
</svrl:successful-report>
</axsl:if>
<axsl:apply-templates mode="M8" select="*|comment()|processing-instruction()"/>
</axsl:template>
<axsl:template mode="M8" priority="-1" match="text()"/>
<axsl:template mode="M8" priority="-2" match="@*|node()">
<axsl:apply-templates mode="M8" select="*|comment()|processing-instruction()"/>
</axsl:template>

<!--PATTERN $loc/strings/M101-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/M101"/>
</svrl:text>

	<!--RULE -->
<axsl:template mode="M9" priority="1000" match="//che:CHE_MD_FeatureCatalogueDescription">
<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//che:CHE_MD_FeatureCatalogueDescription"/>
<axsl:variable select="che:dataModel/che:PT_FreeURL/che:URLGroup/che:LocalisedURL!='' and (not(che:modelType) or che:modelType/che:CHE_MD_modelTypeCode/@codeListValue='')" name="emptyModelType"/>

		<!--ASSERT -->
<axsl:choose>
<axsl:when test="not($emptyModelType)"/>
<axsl:otherwise>
<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyModelType)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/alert.M101"/>
</svrl:text>
</svrl:failed-assert>
</axsl:otherwise>
</axsl:choose>

		<!--REPORT -->
<axsl:if test="not($emptyModelType)">
<svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyModelType)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<axsl:text/>
<axsl:copy-of select="$loc/strings/report.M101/div"/>
<axsl:text/>
</svrl:text>
</svrl:successful-report>
</axsl:if>
<axsl:apply-templates mode="M9" select="*|comment()|processing-instruction()"/>
</axsl:template>
<axsl:template mode="M9" priority="-1" match="text()"/>
<axsl:template mode="M9" priority="-2" match="@*|node()">
<axsl:apply-templates mode="M9" select="*|comment()|processing-instruction()"/>
</axsl:template>

<!--PATTERN $loc/strings/M102-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/M102"/>
</svrl:text>

	<!--RULE -->
<axsl:template mode="M10" priority="1000" match="//*[*/@codeListValue]">
<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*[*/@codeListValue]"/>
<axsl:variable select="*/@codeListValue=''" name="emptyCodeList"/>

		<!--ASSERT -->
<axsl:choose>
<axsl:when test="not($emptyCodeList)"/>
<axsl:otherwise>
<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyCodeList)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/alert.M102"/>
</svrl:text>
</svrl:failed-assert>
</axsl:otherwise>
</axsl:choose>

		<!--REPORT -->
<axsl:if test="not($emptyCodeList)">
<svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyCodeList)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<axsl:text/>
<axsl:copy-of select="$loc/strings/report.M102/div"/>
<axsl:text/>
</svrl:text>
</svrl:successful-report>
</axsl:if>
<axsl:apply-templates mode="M10" select="*|comment()|processing-instruction()"/>
</axsl:template>
<axsl:template mode="M10" priority="-1" match="text()"/>
<axsl:template mode="M10" priority="-2" match="@*|node()">
<axsl:apply-templates mode="M10" select="*|comment()|processing-instruction()"/>
</axsl:template>

<!--PATTERN $loc/strings/M103-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/M103"/>
</svrl:text>

	<!--RULE -->
<axsl:template mode="M11" priority="1000" match="//gmd:CI_Citation/gmd:title">
<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:CI_Citation/gmd:title"/>
<axsl:variable select="gmd:language/gco:CharacterString|gmd:language/gmd:LanguageCode/@codeListValue" name="language"/>
<axsl:variable select="//gmd:LocalisedCharacterString[@locale=$language]=''" name="emptyTitle"/>

		<!--ASSERT -->
<axsl:choose>
<axsl:when test="not($emptyTitle)"/>
<axsl:otherwise>
<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyTitle)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<xsl:copy-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="$loc/strings/alert.M103"/>
</svrl:text>
</svrl:failed-assert>
</axsl:otherwise>
</axsl:choose>

		<!--REPORT -->
<axsl:if test="not($emptyTitle)">
<svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($emptyTitle)" ref="#_{geonet:element/@ref}">
<axsl:attribute name="location">
<axsl:apply-templates mode="schematron-select-full-path" select="."/>
</axsl:attribute>
<svrl:text>
<axsl:text/>
<axsl:copy-of select="$loc/strings/report.M103/div"/>
<axsl:text/>
</svrl:text>
</svrl:successful-report>
</axsl:if>
<axsl:apply-templates mode="M11" select="*|comment()|processing-instruction()"/>
</axsl:template>
<axsl:template mode="M11" priority="-1" match="text()"/>
<axsl:template mode="M11" priority="-2" match="@*|node()">
<axsl:apply-templates mode="M11" select="*|comment()|processing-instruction()"/>
</axsl:template>
</axsl:stylesheet>
