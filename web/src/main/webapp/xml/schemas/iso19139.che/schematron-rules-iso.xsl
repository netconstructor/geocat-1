<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sch="http://www.ascc.net/xml/schematron"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.0"
                gml:dummy-for-xmlns=""
                gmd:dummy-for-xmlns=""
                srv:dummy-for-xmlns=""
                gco:dummy-for-xmlns=""
                geonet:dummy-for-xmlns=""
                xlink:dummy-for-xmlns="">
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
            <xsl:value-of select="$loc/strings/M6"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M7"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M8"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M9"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M10"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M11"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M13"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M14"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M15"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M16"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M17"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M18"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M19"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M20"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M21"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M22"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M23"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M24"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M25"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M26"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M27"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M28"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M29"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M30"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <geonet:pattern>
            <xsl:value-of select="$loc/strings/M61"/>
         </geonet:pattern>
         <xsl:apply-templates select="/" mode="M31"/>
      </geonet:schematronerrors>
   </xsl:template>
   <xsl:template match="*[gco:CharacterString]" priority="4000" mode="M7">
      <xsl:if test="(normalize-space(gco:CharacterString) = '') and (not(@gco:nilReason) or not(contains('inapplicable missing template unknown withheld',@gco:nilReason)))">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e27">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M6.characterString/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="//gml:DirectPositionType" priority="4000" mode="M8">
      <xsl:if test="not(@srsDimension) or @srsName">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e38">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M6.directPosition/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:if test="not(@axisLabels) or @srsName">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e41">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M7.axisAndSrs/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:if test="not(@uomLabels) or @srsName">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e44">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M7.uomAndSrs/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:if test="(not(@uomLabels) and not(@axisLabels)) or (@uomLabels and @axisLabels)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e47">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M7.uomAndAxis/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="//gmd:CI_ResponsibleParty" priority="4000" mode="M9">
      <xsl:choose>
         <xsl:when test="(count(gmd:individualName) + count(gmd:organisationName) + count(gmd:positionName)) &gt; 0"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e61">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M8/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="//gmd:MD_LegalConstraints|//*[@gco:isoType='gmd:MD_LegalConstraints']"
                 priority="4000"
                 mode="M10">
      <xsl:if test="gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue='otherRestrictions' and not(gmd:otherConstraints)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e74">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M9.access/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:if test="gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue='otherRestrictions' and not(gmd:otherConstraints)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e77">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M9.use/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="//gmd:MD_Band" priority="4000" mode="M11">
      <xsl:if test="(gmd:maxValue or gmd:minValue) and not(gmd:units)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e91">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M9/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="//gmd:LI_Source" priority="4000" mode="M12">
      <xsl:choose>
         <xsl:when test="gmd:description or gmd:sourceExtent"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e106">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M11/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="//gmd:DQ_DataQuality" priority="4000" mode="M13">
      <xsl:if test="(((count(*/gmd:LI_Lineage/gmd:source) + count(*/gmd:LI_Lineage/gmd:processStep)) = 0)       and (gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset'         or gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series'))       and not(gmd:lineage/gmd:LI_Lineage/gmd:statement)       and (gmd:lineage)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e117">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M13/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="//gmd:LI_Lineage" priority="4000" mode="M14">
      <xsl:if test="not(gmd:source) and not(gmd:statement) and not(gmd:processStep)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e129">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M14/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="//gmd:LI_Lineage" priority="4000" mode="M15">
      <xsl:if test="not(gmd:processStep) and not(gmd:statement) and not(gmd:source)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e140">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M15/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="//gmd:DQ_DataQuality" priority="4000" mode="M16">
      <xsl:if test="gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset'          and not(gmd:report)          and not(gmd:lineage)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e151">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M16/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="//gmd:DQ_Scope" priority="4000" mode="M17">
      <xsl:choose>
         <xsl:when test="gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset'          or gmd:level/gmd:MD_ScopeCode/@codeListValue='series'          or (gmd:levelDescription and ((normalize-space(gmd:levelDescription) != '')          or (gmd:levelDescription/gmd:MD_ScopeDescription)          or (gmd:levelDescription/@gco:nilReason          and contains('inapplicable missing template unknown withheld',gmd:levelDescription/@gco:nilReason))))"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e163">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M17/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="//gmd:MD_Medium" priority="4000" mode="M18">
      <xsl:if test="gmd:density and not(gmd:densityUnits)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e176">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M18/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="//gmd:MD_Distribution" priority="4000" mode="M19">
      <xsl:choose>
         <xsl:when test="count(gmd:distributionFormat)&gt;0         or count(gmd:distributor/gmd:MD_Distributor/gmd:distributorFormat)&gt;0"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e187">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M19/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="gmd:identification" priority="4000" mode="M20">
      <xsl:choose>
         <xsl:when test="count(*/*/gmd:EX_Extent/gmd:description)&gt;0 or
                         count(*/*/gmd:EX_Extent/gmd:geographicElement)&gt;0 or
                         count(*/*/gmd:EX_Extent/gmd:temporalElement)&gt;0 or
                         count(*/*/gmd:EX_Extent/gmd:verticalElement)&gt;0"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e201">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M20/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M21">
      <xsl:if test="(not(../../gmd:hierarchyLevel) or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and 
                        (count(gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox)  + 
                         count (gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicDescription))=0 ">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e212">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M21/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="//gmd:MD_DataIdentification|//*[@gco:isoType='gmd:MD_DataIdentification']"
                 priority="4000"
                 mode="M22">
      <xsl:if test="(not(../../gmd:hierarchyLevel) or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset'       or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series')      and not(gmd:topicCategory)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e223">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M6/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="//gmd:MD_AggregateInformation" priority="4000" mode="M23">
      <xsl:choose>
         <xsl:when test="gmd:aggregateDataSetName or gmd:aggregateDataSetIdentifier"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e235">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M22/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="//gmd:MD_Metadata/gmd:language|//*[@gco:isoType='gmd:MD_Metadata']/gmd:language"
                 priority="4000"
                 mode="M24">
      <xsl:choose>
         <xsl:when test=". and ((normalize-space(.) != '')            or (normalize-space(./gco:CharacterString) != '')            or (./gmd:LanguageCode)            or (./@gco:nilReason             and contains('inapplicable missing template unknown withheld',./@gco:nilReason)))"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e248">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M23/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="//gmd:MD_Metadata|//*[@gco:isoType='gmd:MD_Metadata']" priority="4000"
                 mode="M25">
      <xsl:apply-templates mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="//gmd:MD_ExtendedElementInformation" priority="4000" mode="M26">
      <xsl:choose>
         <xsl:when test="(gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelist' or gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='enumeration' or gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelistElement') or (gmd:obligation and ((normalize-space(gmd:obligation) != '')  or (gmd:obligation/gmd:MD_ObligationCode) or (gmd:obligation/@gco:nilReason and contains('inapplicable missing template unknown withheld',gmd:obligation/@gco:nilReason))))"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e274">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M26.obligation/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="(gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelist' or gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='enumeration' or gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelistElement') or (gmd:maximumOccurrence and ((normalize-space(gmd:maximumOccurrence) != '')  or (normalize-space(gmd:maximumOccurrence/gco:CharacterString) != '') or (gmd:maximumOccurrence/@gco:nilReason and contains('inapplicable missing template unknown withheld',gmd:maximumOccurrence/@gco:nilReason))))"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e277">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M26.minimumOccurence/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="(gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelist' or gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='enumeration' or gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelistElement') or (gmd:domainValue and ((normalize-space(gmd:domainValue) != '')  or (normalize-space(gmd:domainValue/gco:CharacterString) != '') or (gmd:domainValue/@gco:nilReason and contains('inapplicable missing template unknown withheld',gmd:domainValue/@gco:nilReason))))"/>
         <xsl:otherwise>
            <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e280">
               <geonet:pattern name="{name(.)}"/>
               <geonet:diagnostics>
                  <xsl:copy-of select="$loc/strings/alert.M26.domainValue/div"/>
               </geonet:diagnostics>
            </geonet:errorFound>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="//gmd:MD_ExtendedElementInformation" priority="4000" mode="M27">
      <xsl:if test="gmd:obligation/gmd:MD_ObligationCode='conditional' and not(gmd:condition)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e291">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M27/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="//gmd:MD_ExtendedElementInformation" priority="4000" mode="M28">
      <xsl:if test="gmd:dataType/gmd:MD_DatatypeCode/@codeListValue='codelistElement' and not(gmd:domainCode)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e302">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M28/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="//gmd:MD_ExtendedElementInformation" priority="4000" mode="M29">
      <xsl:if test="gmd:dataType/gmd:MD_DatatypeCode/@codeListValue!='codelistElement' and not(gmd:shortName)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e314">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M29/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="//gmd:MD_Georectified" priority="4000" mode="M30">
      <xsl:if test="(gmd:checkPointAvailability/gco:Boolean='1' or gmd:checkPointAvailability/gco:Boolean='true') and not(gmd:checkPointDescription)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e327">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M30/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="//gmd:MD_Metadata/gmd:hierarchyLevel|//*[@gco:isoType='gmd:MD_Metadata']/gmd:hierarchyLevel"
                 priority="4000"
                 mode="M31">
      <xsl:if test="not(../gmd:hierarchyLevel/gmd:MD_ScopeCode[@codeListValue='dataset']) and (not(../gmd:hierarchyLevelName) or ../gmd:hierarchyLevelName/@gco:nilReason)">
         <geonet:errorFound ref="#_{geonet:element/@ref}" id="#d2e338">
            <geonet:pattern name="{name(.)}"/>
            <geonet:diagnostics>
               <xsl:copy-of select="$loc/strings/alert.M61/div"/>
            </geonet:diagnostics>
         </geonet:errorFound>
      </xsl:if>
      <xsl:apply-templates mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="text()" priority="-1"/>
</xsl:stylesheet>