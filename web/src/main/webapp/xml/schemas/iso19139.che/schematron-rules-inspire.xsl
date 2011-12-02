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
            <xsl:value-of select="$loc/strings/M35"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M36"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M37"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M38"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M39"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M40"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M42"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M43"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M44"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M45"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M46"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M47"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M48"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M49"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M50"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M51"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M52"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M53"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M54"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M55"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M56"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M57"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M58"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M59"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M60"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M62"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M33"/>
      </geonet:schematronerrors>
   </xsl:template>
   <xsl:template match="//gmd:citation" priority="4000" mode="M8">
      <xsl:if test="not(gmd:CI_Citation/gmd:title)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e29">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M35/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M9">
      <xsl:if test="not(gmd:abstract)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e39">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M36/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="//gmd:MD_Metadata|//*[@gco:isoType='gmd:MD_Metadata']" priority="4000"
                 mode="M10">
      <xsl:if test="not(gmd:hierarchyLevel)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e48">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M37/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="//gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation|    //*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation    "
                 priority="4000"
                 mode="M11">
      <xsl:if test="not(gmd:identifier) or gmd:identifier[*/gmd:code/@gco:nilReason]">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e57">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M38/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M12">
      <xsl:if test="not(gmd:topicCategory)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e66">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M39/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M13">
      <xsl:if test="not(gmd:descriptiveKeywords)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e75">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M40/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M14">
      <xsl:if test="not(gmd:citation/gmd:CI_Citation/gmd:date or gmd:extent/gmd:EX_extent/gmd:temporalElement)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e87">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M42/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="//gmd:DQ_DataQuality" priority="4000" mode="M15">
      <xsl:if test="not(gmd:lineage/gmd:LI_Lineage/gmd:statement)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e96">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M43/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="//gmd:dataQualityInfo/gmd:DQ_DataQuality" priority="4000" mode="M16">
      <xsl:if test="not(gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e105">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M44/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="//gmd:resourceConstraints/gmd:MD_LegalConstraints" priority="4000"
                 mode="M17">
      <xsl:if test="     not(gmd:accessContraints) and     not(gmd:useConstraints)     ">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e114">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M45/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="//gmd:resourceConstraints/gmd:MD_Constraints" priority="4000" mode="M18">
      <xsl:if test="not(gmd:useLimitation)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e123">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M46/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="//gmd:MD_DataIdentification" priority="4000" mode="M19">
      <xsl:if test="(gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName) and (gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:adress/gmd:CI_Adress/gmd:electronicMailAdress)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e132">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M47/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="//gmd:MD_Metadata/gmd:contact" priority="4000" mode="M20">
      <xsl:if test="not((gmd:CI_ResponsibleParty/gmd:organisationName) and (gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress))">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e142">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M48/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="//gmd:MD_Metadata" priority="4000" mode="M21">
      <xsl:if test="not(gmd:language)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e151">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M49/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="//gmd:MD_Metadata|//*[@gco:isoType='gmd:MD_Metadata']" priority="4000"
                 mode="M22">
      <xsl:if test="not(gmd:dateStamp)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e160">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M50/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="//gmd:identificationInfo" priority="4000" mode="M23">
      <xsl:if test="(../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service') and not(*/srv:operatesOn)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e169">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M51/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="//gmd:distributionInfo" priority="4000" mode="M24">
      <xsl:if test="not(*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e178">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M52/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="//gmd:identificationInfo" priority="4000" mode="M25">
      <xsl:if test="count(*/gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation) &gt;1 or      count(*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation) &gt;1 or      count(*/gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:useLimitation) &gt;1 or      count(*/gmd:resourceConstraints/*[@gco:isoType='gmd:MD_Constraints']/gmd:useLimitation) &gt;1 or      count(*/gmd:resourceConstraints/*[@gco:isoType='gmd:MD_LegalConstraints']/gmd:useLimitation) &gt;1 or      count(*/gmd:resourceConstraints/*[@gco:isoType='gmd:MD_SecurityConstraints']/gmd:useLimitation) &gt;1">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e187">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M53/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="//gmd:identificationInfo" priority="4000" mode="M26">
      <xsl:if test="(*/gmd:resourceConstraints/*/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue='otherRestrictions') and      not(*/gmd:resourceConstraints/*/gmd:otherConstraints)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e197">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M54/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M27">
      <xsl:if test="not(../../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series'        or ../../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and       not(gmd:language)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e206">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M55/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="//gmd:MD_DataIdentification/gmd:spatialResolution|//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialResolution"
                 priority="4000"
                 mode="M28">
      <xsl:if test="not(*/gmd:equivalentScale) and not(*/gmd:distance)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e215">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M56/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="4000"
                 mode="M29">
      <xsl:if test="not(srv:containsOperations/srv:SV_OperationMetadata/srv:operationName)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e224">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M57/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="4000"
                 mode="M30">
      <xsl:if test="not(srv:containsOperations/srv:SV_OperationMetadata/srv:DCP)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e233">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M58/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="4000"
                 mode="M31">
      <xsl:if test="not(srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e242">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M59/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="4000"
                 mode="M32">
      <xsl:if test="not(srv:serviceType)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e252">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M60/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="4000"
                 mode="M33">
      <xsl:if test="(string(.//srv:couplingType/srv:SV_CouplingType/@codeListValue) = 'tight' or 
                    string(.//srv:couplingType/srv:SV_CouplingType/@codeListValue) = 'mixed') 
                    and not ( 
                      .//srv:extent//gmd:EX_GeographicBoundingBox or
                      .//srv:extent//gmd:EX_GeographicDescription
                    )" >
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e252">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M62/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="text()" priority="-1"/>
</xsl:stylesheet>