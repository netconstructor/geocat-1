<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
						    xmlns:gmd="http://www.isotc211.org/2005/gmd"
						    xmlns:gco="http://www.isotc211.org/2005/gco"
						    xmlns:gmx="http://www.isotc211.org/2005/gmx"
						    xmlns:gts="http://www.isotc211.org/2005/gts"
						    xmlns:srv="http://www.isotc211.org/2005/srv"
						    xmlns:gml="http://www.opengis.net/gml"
						    xmlns:che="http://www.geocat.ch/2008/che"
						    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"    
						    xmlns:xlink="http://www.w3.org/1999/xlink"
						    xmlns:java="java:org.fao.geonet.util.XslUtil"
						    xmlns:geonet="http://www.fao.org/geonetwork"
						    xmlns:xalan = "http://xml.apache.org/xalan">

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

	<!-- find all multilingual elements and move CharacterString to LocalisedCharacterString elements 
        this captures all elements with CharacterString and below are the exceptions that should not be caught	
	--> 
	<xsl:template priority="5" match="gmd:*[gco:CharacterString] | 
	                                  srv:*[gco:CharacterString] | 
	                                  gco:*[gco:CharacterString]">
	    <xsl:variable name="mainLang">
	       <xsl:call-template name="langId19139"/>
	    </xsl:variable>

	    <xsl:variable name="textGroup">
	       <gmd:textGroup>
            <gmd:LocalisedCharacterString locale="#{$mainLang}"><xsl:value-of select="gco:CharacterString"></xsl:value-of></gmd:LocalisedCharacterString>
          </gmd:textGroup>
	    </xsl:variable>

	    <xsl:choose>
	       <xsl:when test="gmd:PT_FreeText">
		       <xsl:copy>
		           <gmd:PT_FreeText>
		               <xsl:copy-of select="$textGroup"/>
		               <xsl:copy-of select="gmd:PT_FreeText/*"/>
		           </gmd:PT_FreeText>
	           </xsl:copy>
	       </xsl:when>
	       <xsl:otherwise>
		       <xsl:copy>
	               <gmd:PT_FreeText>
	                   <xsl:copy-of select="$textGroup"/>
	               </gmd:PT_FreeText>
               </xsl:copy>
	       </xsl:otherwise>
	    </xsl:choose>
   </xsl:template>

	<!-- find all multilingual elements and move CharacterString to LocalisedCharacterString elements 
        this captures all elements with CharacterString and below are the exceptions that should not be caught	
	--> 
	<xsl:template priority="5" match="gmd:*[gmd:URL] | 
	                                  srv:*[gmd:URL] | 
	                                  gco:*[gmd:URL]">
	    <xsl:variable name="mainLang">
	       <xsl:call-template name="langId19139"/>
	    </xsl:variable>

	    <xsl:variable name="urlGroup">
	       <che:URLGroup>
            <che:LocalisedURL locale="#{$mainLang}"><xsl:value-of select="gmd:URL"></xsl:value-of></che:LocalisedURL>
          </che:URLGroup>
	    </xsl:variable>

	    <xsl:choose>
	       <xsl:when test="che:PT_FreeURL">
		       <xsl:copy>
		           <che:PT_FreeURL>
		               <xsl:copy-of select="$urlGroup"/>
		               <xsl:copy-of select="che:PT_FreeURL"/>
		           </che:PT_FreeURL>
	           </xsl:copy>
	       </xsl:when>
	       <xsl:otherwise>
		       <xsl:copy>
	               <che:PT_FreeURL>
	                   <xsl:copy-of select="$urlGroup"/>
	               </che:PT_FreeURL>
               </xsl:copy>
	       </xsl:otherwise>
	    </xsl:choose>
   </xsl:template>

    <!-- The following are NOT multilingual -->
    <xsl:template priority="100" match="gmd:identifier|
        gmd:fileIdentifier|
        gmd:metadataStandardName|
        gmd:metadataStandardVersion|
        gmd:hierarchyLevelName|
        gmd:dataSetURI|
        gmd:postalCode|
        gmd:city|
        gmd:administrativeArea|
        gmd:voice|
        gmd:facsimile|
        gmd:MD_ScopeDescription/gmd:dataset|
        gmd:MD_ScopeDescription/gmd:other|
        gmd:hoursOfService|
        gmd:applicationProfile|
        gmd:CI_Series/gmd:page|
        gmd:MD_BrowseGraphic/gmd:fileName|
        gmd:MD_BrowseGraphic/gmd:fileType|
        gmd:unitsOfDistribution|
        gmd:amendmentNumber|
        gmd:specification|
        gmd:fileDecompressionTechnique|
        gmd:turnaround|
        gmd:fees|
        gmd:userDeterminedLimitations|
        gmd:RS_Identifier/gmd:codeSpace|
        gmd:RS_Identifier/gmd:version|
        gmd:edition|
        gmd:ISBN|
        gmd:ISSN|
        gmd:errorStatistic|
        gmd:schemaAscii|
        gmd:softwareDevelopmentFileFormat|
        gmd:MD_ExtendedElementInformation/gmd:shortName|
        gmd:MD_ExtendedElementInformation/gmd:condition|
        gmd:MD_ExtendedElementInformation/gmd:maximumOccurence|
        gmd:MD_ExtendedElementInformation/gmd:domainValue|
        gmd:densityUnits|
        gmd:MD_RangeDimension/gmd:descriptor|
        gmd:classificationSystem|
        gmd:checkPointDescription|
        gmd:transformationDimensionDescription|
        gmd:orientationParameterDescription|
        srv:SV_OperationChainMetadata/srv:name|
        srv:SV_OperationMetadata/srv:invocationName|
        srv:serviceTypeVersion|
        srv:operationName|
        srv:identifier|
        che:basicGeodataID|
        che:streetName|
        che:streetNumber|
        che:addressLine|
        che:postBox|
        che:directNumber|
        che:mobile|
        che:individualFirstName|
        che:individualLastName|
        che:internalReference">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template name="langId19139">
        <xsl:variable name="tmp">
            <xsl:choose>
                <xsl:when test="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString|
                                /*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue">
                    <xsl:value-of select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString|
                                /*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue"/>
                </xsl:when>
                <xsl:otherwise>en</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    <xsl:variable name="UPPER">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:variable name="LOWER">abcdefghijklmnopqrstuvwxyz</xsl:variable>

        <!-- <xsl:value-of select="translate(java:twoCharLangCode(normalize-space(string($tmp))), $LOWER, $UPPER)"></xsl:value-of>  -->
        <xsl:value-of select="translate(substring(normalize-space(string($tmp)),1,2), $LOWER, $UPPER)"></xsl:value-of>
    </xsl:template>

</xsl:stylesheet>