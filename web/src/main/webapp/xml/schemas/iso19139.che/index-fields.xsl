<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:gmd="http://www.isotc211.org/2005/gmd"
										xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:gml="http://www.opengis.net/gml"
										xmlns:srv="http://www.isotc211.org/2005/srv"
										xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
										xmlns:xlink="http://www.w3.org/1999/xlink"
										xmlns:che="http://www.geocat.ch/2008/che"
										>

	<!-- This file defines what parts of the metadata are indexed by Lucene
	     Searches can be conducted on indexes defined here. 
	     The Field@name attribute defines the name of the search variable.
		 If a variable has to be maintained in the user session, it needs to be 
		 added to the GeoNetwork constants in the Java source code.
		 Please keep indexes consistent among metadata standards if they should
		 work accross different metadata resources -->
	
	<!-- TODO : ISO profil index could be the same as iso19139 for all elements
	using gco:isoType attribute to look for matching elements. Then only profil specific
	elements (element defined in the profil and not existing in iso19139) could 
	be indexed here ? -->
	<!-- ========================================================================================= -->
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:include href="../index-utils.xsl"/>
	
    
	<!-- ========================================================================================= -->

	<xsl:template match="/">
		<xsl:variable name="iso3LangId">
		  <xsl:call-template name="langId19139"/>
    </xsl:variable>
		
		<Document locale="{string($iso3LangId)}">
			<xsl:apply-templates mode="xlinks"/>
			<Field name="_locale" string="{string($iso3LangId)}" store="true" index="true" token="false"/>

			<xsl:variable name="docLang" select="/*[@gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString"/>
			<Field name="_docLocale" string="{normalize-space(string($docLang))}" store="true" index="true" token="false"/>

			<xsl:variable name="_defaultTitle">
				<xsl:call-template name="defaultTitle"/>
			</xsl:variable>
	
			<!-- not tokenized title for sorting -->
			<Field name="_defaultTitle" string="{string($_defaultTitle)}" store="true" index="true" token="false" />
			<!-- not tokenized title for sorting -->
			<Field name="_title" string="{string($_defaultTitle)}" store="true" index="true" token="false" />
			<Field name="title" string="{string($_defaultTitle)}" store="true" index="true" token="true" />
			
			<xsl:apply-templates select="che:CHE_MD_Metadata" mode="metadata"/>
		</Document>
	</xsl:template>
	
	<xsl:template name="defaultTitle">
		<xsl:choose>
		<xsl:when test="string-length(/*[@gco:isoType='gmd:MD_Metadata']/gmd:identificationInfo//gmd:citation//gmd:title/gco:CharacterString) != 0">
			<xsl:value-of select="string(/*[@gco:isoType='gmd:MD_Metadata']/gmd:identificationInfo//gmd:citation//gmd:title/gco:CharacterString)"></xsl:value-of>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="string(/*[@gco:isoType='gmd:MD_Metadata']/gmd:identificationInfo//gmd:citation//gmd:title//gmd:LocalisedCharacterString)"></xsl:value-of>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ========================================================================================= -->

	<xsl:template match="*" mode="metadata">

		<!-- === Data or Service Identification === -->		

		<!-- the double // here seems needed to index MD_DataIdentification when
           it is nested in a SV_ServiceIdentification class -->

		<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification|
							  gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|
							  gmd:identificationInfo/srv:SV_ServiceIdentification|
							  gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']">

			<xsl:for-each select="gmd:citation/gmd:CI_Citation">
				<xsl:for-each select="gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
					<Field name="identifier" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:title/gco:CharacterString">
					<Field name="title" string="{string(.)}" store="true" index="true" token="true"/>
				</xsl:for-each>
	
				<xsl:for-each select="gmd:alternateTitle/gco:CharacterString">
					<Field name="altTitle" string="{string(.)}" store="true" index="true" token="true"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/gco:Date">
					<Field name="revisionDate" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']/gmd:date/gco:Date">
					<Field name="createDate" string="{string(.)}" store="true" index="true" token="false"/>
					<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true" token="false"/>
					<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true" token="false"/>					
				</xsl:for-each>

				<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']/gmd:date/gco:Date">
					<Field name="publicationDate" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>

				<!-- fields used to search for metadata in paper or digital format -->

				<xsl:for-each select="gmd:presentationForm">
					<xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Digital')">
						<Field name="digital" string="true" store="true" index="true" token="false"/>
					</xsl:if>
				
					<xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Hardcopy')">
						<Field name="paper" string="true" store="true" index="true" token="false"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	
			<xsl:for-each select="gmd:abstract/gco:CharacterString">
				<Field name="abstract" string="{string(.)}" store="true" index="true" token="true"/>
			</xsl:for-each>


			<xsl:for-each select="che:basicGeodataID/gco:CharacterString">
				<Field name="basicgeodataid" string="{string(.)}" store="true" index="true" token="false"/>
				<Field name="type" string="basicgeodata" store="true" index="true" token="false"/>
			</xsl:for-each>
			<xsl:for-each select="che:basicGeodataIDType/che:basicGeodataIDTypeCode[@codeListValue!='']">
				<Field name="type" string="basicgeodata-{@codeListValue}" store="true" index="true" token="false"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

			<xsl:for-each select="*/gmd:EX_Extent">
				<xsl:apply-templates select="gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="latLon"/>

				<xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
					<Field name="geoDescCode" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:description//gco:CharacterString">
					<Field name="extentDesc" string="{string(.)}" store="true" index="true" token="true"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent|
					gmd:temporalElement/gmd:EX_SpatialTemporalExtent/gmd:extent">
					<xsl:for-each select="gml:TimePeriod/gml:beginPosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true" token="false"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimePeriod/gml:endPosition">
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true" token="false"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true" token="false"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true" token="false"/>
					</xsl:for-each>
					
					<xsl:for-each select="gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true" token="false"/>
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true" token="false"/>
					</xsl:for-each>
					
				</xsl:for-each>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

			<xsl:for-each select="*/gmd:MD_Keywords">
				<xsl:for-each select="gmd:keyword/gco:CharacterString">
					<Field name="keyword" string="{string(.)}" store="true" index="true" token="false"/>
					<Field name="subject" string="{string(.)}" store="true" index="true" token="false"/>					
				</xsl:for-each>

				<xsl:for-each select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">
					<Field name="keywordType" string="{string(.)}" store="true" index="true" token="true"/>
				</xsl:for-each>
			</xsl:for-each>
	
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	
			<xsl:for-each select="//gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString|
				//che:CHE_CI_ResponsibleParty/gmd:organisationName/gco:CharacterString">
                <Field name="orgName" string="{string(.)}" store="true" index="true" token="true"/>
                <Field name="_orgName" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			<xsl:for-each select="//gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString|
				//che:CHE_CI_ResponsibleParty/che:individualFirstName/gco:CharacterString|
				//che:CHE_CI_ResponsibleParty/che:individualLastName/gco:CharacterString">
				<Field name="creator" string="{string(.)}" store="true" index="true" token="true"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	
			<xsl:choose>
				<xsl:when test="gmd:resourceConstraints/gmd:MD_SecurityConstraints">
					<Field name="secConstr" string="true" store="true" index="true" token="false"/>
				</xsl:when>
				<xsl:otherwise>
					<Field name="secConstr" string="false" store="true" index="true" token="false"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	
			<xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
				<Field name="topicCat" string="{string(.)}" store="true" index="true" token="false"/>
				<Field name="subject" string="{string(.)}" store="true" index="true" token="false"/>				
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	
			<xsl:for-each select="gmd:language/gco:CharacterString">
				<Field name="datasetLang" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
			
			<xsl:for-each select="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue">
				<Field name="spatialRepresentation" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->      
			
			<xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
				<xsl:for-each select="gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer">
					<Field name="denominator" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:distance/gco:Distance">
					<Field name="distanceVal" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>

				<xsl:for-each select="gmd:distance/gco:Distance/@uom">
					<Field name="distanceUom" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>
			</xsl:for-each>



			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<!--  Fields use to search on Service -->
			
			<xsl:for-each select="srv:serviceType/gco:LocalName">
				<Field  name="serviceType" string="{string(.)}" store="true" index="true" token="false"/>
				<Field  name="type" string="service-{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			
			<xsl:for-each select="srv:serviceTypeVersion/gco:CharacterString">
				<Field  name="serviceTypeVersion" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			
			<xsl:for-each select="//srv:SV_OperationMetadata/srv:operationName/gco:CharacterString">
				<Field  name="operation" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			
			<xsl:for-each select="srv:operatesOn/@uuidref">
				<Field  name="operatesOn" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			
			<xsl:for-each select="srv:coupledResource">
				<xsl:for-each select="srv:SV_CoupledResource/srv:identifier/gco:CharacterString">
					<Field  name="operatesOnIdentifier" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>
				
				<xsl:for-each select="srv:SV_CoupledResource/srv:operationName/gco:CharacterString">
					<Field  name="operatesOnName" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>
			</xsl:for-each>
			
			<xsl:for-each select="//srv:SV_CouplingType/srv:code/@codeListValue">
				<Field  name="couplingType" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
			
			
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === Distribution === -->		

		<xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
			<xsl:for-each select="gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString">
				<Field name="format" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>

            <xsl:for-each select="gmd:distributionFormat/gmd:MD_Format/gmd:version/gco:CharacterString">
				<Field name="formatversion" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>

			<!-- index online protocol -->
			
			<xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString">
				<Field name="protocol" string="{string(.)}" store="true" index="true" token="false"/>
			</xsl:for-each>
		</xsl:for-each>



		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Service stuff ===  -->
		<!-- Service type           -->
		<xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName|
			gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:serviceType/gco:LocalName">
			<Field name="serviceType" string="{string(.)}" store="true" index="true" token="false"/>
		</xsl:for-each>
		
		<!-- Service version        -->
		<xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceTypeVersion/gco:CharacterString|
			gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:serviceTypeVersion/gco:CharacterString">
			<Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true" token="false"/>
		</xsl:for-each>
		
	

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === General stuff === -->		

		<xsl:choose>
			<xsl:when test="gmd:hierarchyLevel">
				<xsl:for-each select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue">
					<Field name="type" string="{string(.)}" store="true" index="true" token="false"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<Field name="type" string="dataset" store="true" index="true" token="false"/>
			</xsl:otherwise>
		</xsl:choose>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

		<xsl:for-each select="gmd:hierarchyLevelName/gco:CharacterString">
			<Field name="levelName" string="{string(.)}" store="true" index="true" token="true"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

		<xsl:for-each select="gmd:language/gco:CharacterString">
			<Field name="language" string="{string(.)}" store="true" index="true" token="false"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

		<xsl:for-each select="gmd:fileIdentifier/gco:CharacterString">
			<Field name="fileId" string="{string(.)}" store="true" index="true" token="false"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

		<xsl:for-each select="gmd:parentIdentifier/gco:CharacterString">
			<Field name="parentUuid" string="{string(.)}" store="true" index="true" token="false"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === Reference system info === -->		

		<xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
			<xsl:for-each select="gmd:referenceSystemIdentifier/gmd:RS_Identifier">
				<xsl:variable name="crs" select="concat(string(gmd:codeSpace/gco:CharacterString),'::',string(gmd:code/gco:CharacterString))"/>

				<xsl:if test="$crs != '::'">
					<Field name="crs" string="{$crs}" store="true" index="true" token="false"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === Free text search === -->		

		<Field name="any" store="false" index="true" token="true">
			<xsl:attribute name="string">
				<xsl:apply-templates select="." mode="allText"/>
			</xsl:attribute>
		</Field>

		<xsl:apply-templates select="." mode="codeList"/>
		
	</xsl:template>

	<!-- ========================================================================================= -->
	<!-- codelist element, indexed, not stored nor tokenized -->
	
	<xsl:template match="*[./*/@codeListValue]" mode="codeList">
		<xsl:param name="name" select="name(.)"/>
		
		<Field name="{$name}" string="{*/@codeListValue}" store="false" index="true" token="false"/>		
	</xsl:template>

	<!-- ========================================================================================= -->
	
	<xsl:template match="*" mode="codeList">
		<xsl:apply-templates select="*" mode="codeList"/>
	</xsl:template>
	
	<!-- ========================================================================================= -->
	<!-- latlon coordinates + 360, zero-padded, indexed, not stored, not tokenized -->
	
	<xsl:template match="*" mode="latLon">
	
		<xsl:for-each select="gmd:westBoundLongitude">
			<Field name="westBL" string="{string(gco:Decimal) + 360}" store="true" index="true" token="false"/>
		</xsl:for-each>
	
		<xsl:for-each select="gmd:southBoundLatitude">
			<Field name="southBL" string="{string(gco:Decimal) + 360}" store="true" index="true" token="false"/>
		</xsl:for-each>
	
		<xsl:for-each select="gmd:eastBoundLongitude">
			<Field name="eastBL" string="{string(gco:Decimal) + 360}" store="true" index="true" token="false"/>
		</xsl:for-each>
	
		<xsl:for-each select="gmd:northBoundLatitude">
			<Field name="northBL" string="{string(gco:Decimal) + 360}" store="true" index="true" token="false"/>
		</xsl:for-each>
	
	</xsl:template>

	<!-- ========================================================================================= -->
	<!--allText -->
	
	<xsl:template match="*" mode="allText">
		<xsl:for-each select="@*">
			<xsl:if test="name(.) != 'codeList' ">
				<xsl:value-of select="concat(string(.),' ')"/>
			</xsl:if>	
		</xsl:for-each>

		<xsl:choose>
			<!-- Index all elements in default metadata language (having no locale attribute)
			other terms will go in language specific indices -->
			<xsl:when test="*[@locale]"/>
			<xsl:when test="*"><xsl:apply-templates select="*" mode="allText"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="concat(string(.),' ')"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:template>

	<!-- ========================================================================================= -->

	<!-- xlinks -->

	<xsl:template match="*[contains(string(@xlink:href),'xml.reusable.deleted')]" mode="xlinks" priority="100">
		<Field name="xlink_deleted" string="{@xlink:href}" store="true" index="true" token="false"/>
	</xsl:template>

	<xsl:template match="*[@xlink:href and @xlink:role]" mode="xlinks">
		<xsl:apply-templates select="." mode="non-valid-xlink"/>
	</xsl:template>

	<xsl:template match="*[@xlink:href and not(@xlink:role)]" mode="xlinks">
		<xsl:apply-templates select="." mode="valid-xlink"/>
	</xsl:template>
	
	<xsl:template match="*" mode="xlinks">
		<xsl:apply-templates mode="xlinks"/>
	</xsl:template>
	
	<xsl:template match="text()" mode="xlinks">
	</xsl:template>	

	<xsl:template mode="non-valid-xlink" match="gmd:extent|srv:extent">
		<Field name="invalid_xlink_extent" string="{@xlink:href}" store="true" index="true" token="false"/>
	</xsl:template>
	<xsl:template mode="valid-xlink" match="gmd:extent|srv:extent">
		<Field name="valid_xlink_extent" string="{@xlink:href}" store="true" index="true" token="false"/>
	</xsl:template>

	<xsl:template mode="non-valid-xlink" match="gmd:distributionFormat|gmd:resourceFormat">
		<Field name="invalid_xlink_format" string="{@xlink:href}" store="true" index="true" token="false"/>
	</xsl:template>
	<xsl:template mode="valid-xlink" match="gmd:distributionFormat|gmd:resourceFormat">
		<Field name="valid_xlink_format" string="{@xlink:href}" store="true" index="true" token="false"/>	
	</xsl:template>

	<xsl:template mode="non-valid-xlink" match="gmd:descriptiveKeywords">
		<Field name="invalid_xlink_keyword" string="{@xlink:href}" store="true" index="true" token="false"/>
	</xsl:template>
	<xsl:template mode="valid-xlink" match="gmd:descriptiveKeywords">
		<Field name="valid_xlink_keyword" string="{@xlink:href}" store="true" index="true" token="false"/>	
	</xsl:template>

	<xsl:template mode="non-valid-xlink" match="che:parentResponsibleParty|gmd:citedResponsibleParty|gmd:pointOfContact|gmd:contact|gmd:userContactInfo|gmd:distributorContact">
		<Field name="invalid_xlink_contact" string="{@xlink:href}" store="true" index="true" token="false"/>
	</xsl:template>
	<xsl:template mode="valid-xlink" match="che:parentResponsibleParty|gmd:citedResponsibleParty|gmd:pointOfContact|gmd:contact|gmd:userContactInfo|gmd:distributorContact">
		<Field name="valid_xlink_contact" string="{@xlink:href}" store="true" index="true" token="false"/>	
	</xsl:template>

	<xsl:template match="text()" mode="non-valid-xlink">
	</xsl:template>
	<xsl:template match="text()" mode="valid-xlink">
	</xsl:template>

</xsl:stylesheet>
