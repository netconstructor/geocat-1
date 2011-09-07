<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xalan= "http://xml.apache.org/xalan" exclude-result-prefixes="xalan util"
	xmlns:exslt= "http://exslt.org/common"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:che="http://www.geocat.ch/2008/che"
    xmlns:util="xalan://org.fao.geonet.util.XslUtil"
	xmlns:geonet="http://www.fao.org/geonetwork">

	<xsl:include href="metadata-utils.xsl"/>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- main schema switch -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template mode="elementEP" match="*|@*">
		<xsl:param name="schema">
			<xsl:apply-templates mode="schema" select="."/>
		</xsl:param>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="embedded" />
   
		<xsl:choose>

			<!-- ISO 19115 -->
			<xsl:when test="$schema='iso19115'">
				<xsl:apply-templates mode="iso19115" select="." >
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded" />
				</xsl:apply-templates>
			</xsl:when>

			<!-- ISO 19139 and profiles -->
            <xsl:when test="starts-with($schema,'iso19139')">
				<xsl:apply-templates mode="iso19139" select="." >
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded" />
				</xsl:apply-templates>
			</xsl:when>

			<!-- FGDC -->
			<xsl:when test="$schema='fgdc-std'">
				<xsl:apply-templates mode="fgdc-std" select="." >
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded" />
				</xsl:apply-templates>
			</xsl:when>

			<!-- Dublin Core -->
			<xsl:when test="$schema='dublin-core'">
				<xsl:apply-templates mode="dublin-core" select="." >
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded" />
				</xsl:apply-templates>
			</xsl:when>

			<!-- default, no schema-specific formatting -->
			<xsl:otherwise>
				<xsl:apply-templates mode="element" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- Don't display these -->
    <xsl:template mode="elementEP" priority="3"
        match="geonet:child[../gmd:geographicElement and 
                       (string(@name) = 'geographicElement' or
                        string(@name) = 'temporalElement' or
                        string(@name) = 'verticalElement')]"/>

	<!--
	new children
	-->
	<xsl:template mode="elementEP" match="geonet:child">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="embedded" />
		<!-- draw new children if
		- it is not simple mode and
			- it is an OR element or
			- it does not exists a preceding brother
		- or there are subtemplates
		-->
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="@prefix=''"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="concat(@prefix,':',@name)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="parentName" select="../geonet:element/@ref"/>
		<xsl:variable name="prevBrother" select="preceding-sibling::*[1]"/>
		<!-- <xsl:variable name="subtemplates" select="/root/gui/subtemplates/record[string(root)=$name]"/> -->
		<xsl:variable name="subtemplates" select="/root/gui/subtemplates/record[string(root)='']"/>

		<!-- here you could add exception if you want to display some geonet:child element
		in simple view mode. -->
		<xsl:if test="$currTab!='simple'
			and (geonet:choose or name($prevBrother)!=$name)
            or $subtemplates
            or @name='topicCategory'
            or @name='graphicOverview'
            or @name='portrayalCatalogueInfo'
            or @name='MD_DigitalTransferOptions'
            or @name='unitsOfDistribution'
            or @name='unitsOfDistribution'
            or @name='transferSize'
            or @name='onLine'
            or @name='offLine'
            or @name='contentInfo'
            or @name='linkage'
            or (@name='contact' and name($prevBrother)!=$name)
            or (@name='pointOfContact' and name($prevBrother)!=$name)
            or (@name='extent' and name($prevBrother)!=$name)
            or (@name='geographicElement' and name($prevBrother)!=$name)
            or (@name='polygon' and name($prevBrother)!=$name)">
			<xsl:variable name="text">
				<xsl:if test="geonet:choose or $subtemplates">
					<select class="md" name="_{$parentName}_{@name}" size="1">
						<xsl:for-each select="geonet:choose">
							<!-- che profil does not allow gmd:URL.
							gmd:datasetURI is CharacterString so that's fine.
							Not sure we could define that in the schema
							without changing gmd:URL_PropertyType -->
							<xsl:if test="$schema='iso19139.che' and @name!='gmd:URL'">
								<option value="{@name}">
									<xsl:call-template name="getTitle">
										<xsl:with-param name="name"   select="@name"/>
										<xsl:with-param name="schema" select="$schema"/>
									</xsl:call-template>
									(<xsl:value-of select="@name"/>)<!-- Debug info in editor to have name of substitution groups -->
								</option>
							</xsl:if>
						</xsl:for-each>
						<xsl:for-each select="$subtemplates">
							<option value="_s{id}">
								<xsl:value-of select="title"/>
							</option>
						</xsl:for-each>
					</select>
				</xsl:if>
			</xsl:variable>
			<xsl:variable name="id" select="generate-id(.)"/>
			<xsl:variable name="addLink">
				<xsl:choose>
                    <xsl:when test="$edit!=true()">
                       <!-- don't show link if not edit for these elements --> 
                    </xsl:when>
					<xsl:when test="geonet:choose or $subtemplates">
						<xsl:value-of select="concat('javascript:doNewORElementAction(',$apos,/root/gui/locService,'/metadata.elem.add',$apos,',',$parentName,',',$apos,$name,$apos,',document.mainForm._',$parentName,'_',@name,'.value,',$apos,$id,$apos,');')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('javascript:doNewElementAction(',$apos,/root/gui/locService,'/metadata.elem.add',$apos,',',$parentName,',',$apos,$name,$apos,',',$apos,$id,$apos,');')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
            <xsl:variable name="addAsXLink">
                <xsl:value-of select="concat('javascript:displayXLinkSearchBox(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',$parentName,',',$apos,$name,$apos,',',$apos,$id,$apos,');')"/>
            	<!--<xsl:value-of select="concat('javascript:popXLink(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',$parentName,',',$apos,$name,$apos,',',$apos,$id,$apos,', event);')"/>-->
            </xsl:variable>
			<xsl:variable name="helpLink">
				<xsl:call-template name="getHelpLink">
					<xsl:with-param name="name"   select="$name"/>
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="simpleElementGui">
				<xsl:with-param name="title">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name"   select="$name"/>
						<xsl:with-param name="schema" select="$schema"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="text" select="$text"/>
				<xsl:with-param name="addLink"  select="$addLink"/>
                <xsl:with-param name="addAsXLink"  select="$addAsXLink"/>
				<xsl:with-param name="helpLink" select="$helpLink"/>
				<xsl:with-param name="edit"     select="$edit"/>
				<xsl:with-param name="id"     	select="$id"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- callbacks from schema templates -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template mode="element" match="*|@*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"   select="false()"/>
		<xsl:param name="flat"   select="false()"/>
		<xsl:param name="embedded" />

		<xsl:choose>

			<!-- has children or attributes, existing or potential -->
			<xsl:when test="*[namespace-uri(.)!=$geonetUri]|@*|geonet:child|geonet:element/geonet:attribute">

				<xsl:choose>

					<!-- display as a list -->
					<xsl:when test="$flat=true()">
						<!-- if it does not have children show it as a simple element -->
						<xsl:if test="not(*[namespace-uri(.)!=$geonetUri]|geonet:child|geonet:element/geonet:attribute)">
							<xsl:apply-templates mode="simpleElement" select=".">
								<xsl:with-param name="schema" select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
							</xsl:apply-templates>
						</xsl:if>
						<!-- existing attributes -->
						<xsl:apply-templates mode="simpleElement" select="@*[
							(local-name(.)!='type' and namespace-uri(.)!='http://www.w3.org/2001/XMLSchema-instance') and
							(local-name(.)!='isoType' and namespace-uri(.)!='http://www.isotc211.org/2005/gco')
										]">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						<!-- new attributes -->
						<!-- FIXME
						<xsl:apply-templates mode="elementEP" select="geonet:attribute">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						-->
						<!-- existing and new children -->
						<xsl:apply-templates mode="elementEP" select="*[namespace-uri(.)!=$geonetUri]|geonet:child">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
					</xsl:when>

					<!-- display boxed -->
					<xsl:otherwise>
						<xsl:apply-templates mode="complexElement" select=".">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- neither children nor attributes, just text -->
			<xsl:otherwise>
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<xsl:template mode="simpleElement" match="*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"   select="false()"/>
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="text">
			<xsl:call-template name="getElementText">
                <xsl:with-param name="visible" select="'true'" />
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="helpLink">
			<xsl:call-template name="getHelpLink">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:param>

        <!-- when an ancestor contains an xlink then all is readonly -->
        <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>
        <xsl:variable name="edit">
            <xsl:choose>
                <xsl:when test="$xlinkedAncestor = 'true'"><xsl:value-of select="false()"/> </xsl:when>
                <xsl:otherwise><xsl:value-of select="$edit"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:call-template name="editSimpleElement">
					<xsl:with-param name="schema"   select="$schema"/>
					<xsl:with-param name="title"    select="$title"/>
					<xsl:with-param name="text"     select="$text"/>
					<xsl:with-param name="helpLink" select="$helpLink"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="showSimpleElement">
					<xsl:with-param name="schema"   select="$schema"/>
					<xsl:with-param name="title"    select="$title"/>
					<xsl:with-param name="text"     select="$text"/>
					<xsl:with-param name="helpLink" select="$helpLink"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="simpleElement" match="@*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"   select="false()"/>
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="text">
			<xsl:call-template name="getAttributeText">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="helpLink">
			<xsl:call-template name="getHelpLink">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:param>

		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:call-template name="editAttribute">
					<xsl:with-param name="schema"   select="$schema"/>
					<xsl:with-param name="title"    select="$title"/>
					<xsl:with-param name="text"     select="$text"/>
					<xsl:with-param name="helpLink" select="$helpLink"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="showSimpleElement">
					<xsl:with-param name="schema"   select="$schema"/>
					<xsl:with-param name="title"    select="$title"/>
					<xsl:with-param name="text"     select="$text"/>
					<xsl:with-param name="helpLink" select="$helpLink"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="complexElement" match="*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"   select="false()"/>
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="content">
			<xsl:call-template name="getContent">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="helpLink">
			<xsl:call-template name="getHelpLink">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:param>

		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:call-template name="editComplexElement">
					<xsl:with-param name="schema"   select="$schema"/>
					<xsl:with-param name="title"    select="$title"/>
					<xsl:with-param name="content"  select="$content"/>
					<xsl:with-param name="helpLink" select="$helpLink"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="showComplexElement">
					<xsl:with-param name="schema"   select="$schema"/>
					<xsl:with-param name="title"    select="$title"/>
					<xsl:with-param name="content"  select="$content"/>
					<xsl:with-param name="helpLink" select="$helpLink"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!--
	prevent drawing of geonet:* elements
	-->
	<xsl:template mode="element" match="geonet:null|geonet:element|geonet:info|geonet:attribute|geonet:schematronerrors|geonet:xsderror|@geonet:xsderror|@xlink:type|@xlink:href|@xlink:title|@xlink:role|@xlink:show"/>
	<xsl:template mode="simpleElement" match="geonet:null|geonet:element|geonet:info|geonet:attribute|geonet:schematronerrors|geonet:xsderror|@geonet:xsderror|@xlink:type|@xlink:href|@xlink:title|@xlink:role|@xlink:show"/>
	<xsl:template mode="complexElement" match="geonet:null|geonet:element|geonet:info|geonet:attribute|geonet:schematronerrors|geonet:xsderror|@geonet:xsderror|@xlink:type|@xlink:href|@xlink:title|@xlink:role|@xlink:show"/>

	<!--
	prevent drawing of attributes starting with "_", used in old GeoNetwork versions
	-->
	<xsl:template mode="simpleElement" match="@*[starts-with(name(.),'_')]"/>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- elements/attributes templates -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<!--
	shows a simple element
	-->
	<xsl:template name="showSimpleElement">
		<xsl:param name="schema"/>
		<xsl:param name="title"/>
		<xsl:param name="text"/>
		<xsl:param name="helpLink"/>

		<xsl:call-template name="simpleElementGui">
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="text" select="$text"/>
			<xsl:with-param name="helpLink" select="$helpLink"/>
		</xsl:call-template>
	</xsl:template>

	<!--
	shows a complex element
	-->
	<xsl:template name="showComplexElement">
		<xsl:param name="schema"/>
		<xsl:param name="title"/>
		<xsl:param name="content"/>
		<xsl:param name="helpLink"/>

		<xsl:call-template name="complexElementGui">
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="text" select="text()"/>
			<xsl:with-param name="content" select="$content"/>
			<xsl:with-param name="helpLink" select="$helpLink"/>
			<xsl:with-param name="schema" select="$schema"/>
		</xsl:call-template>
	</xsl:template>

	<!--
	shows editable fields for a simple element
	-->
	<xsl:template name="editSimpleElement">
		<xsl:param name="schema"/>
		<xsl:param name="title"/>
		<xsl:param name="text"/>
		<xsl:param name="helpLink"/>

		<!-- if it's the last brother of it's type and there is a new brother make addLink -->

		<xsl:variable name="id" select="generate-id(.)"/>
		<xsl:variable name="addLink">
			<xsl:call-template name="addLink">
				<xsl:with-param name="id" select="$id"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="addAsXLink">
            <xsl:call-template name="addAsXLink">
                <xsl:with-param name="id" select="$id"/>
            </xsl:call-template>
        </xsl:variable>
		<xsl:variable name="removeLink">
			<xsl:if test="geonet:element/@del='true'">
				<xsl:value-of select="concat('javascript:doElementAction(',$apos,/root/gui/locService,'/metadata.elem.delete',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,',0);')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="upLink">
			<xsl:if test="geonet:element/@up='true'">
				<xsl:value-of select="concat('javascript:doMoveElementAction(',$apos,/root/gui/locService,'/metadata.elem.up',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="downLink">
			<xsl:if test="geonet:element/@down='true'">
				<xsl:value-of select="concat('javascript:doMoveElementAction(',$apos,/root/gui/locService,'/metadata.elem.down',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
			</xsl:if>
		</xsl:variable>
		<!-- schematron info if in advanced mode (all elements) -->
		<xsl:variable name="schematronLink">
			<xsl:variable name="ref" select="concat('#_',geonet:element/@ref)"/>

			<xsl:if test="//geonet:errorFound[@ref=$ref] or @geonet:xsderror or */@geonet:xsderror">
				<div class="tooltip" style="display:none;" id="{$ref}Schematron" onclick="this.style.display='none';">
					<xsl:for-each select="//geonet:errorFound[@ref=$ref]">
						<xsl:copy-of select="geonet:diagnostics/*"/>
						<hr/>
					</xsl:for-each>
					<xsl:if test="@geonet:xsderror">
						<xsl:value-of select="@geonet:xsderror"/><br/>
					</xsl:if>
					<!-- some simple elements hide lower elements to remove some
						complexity from the display (eg. gco: in iso19139)
						so check if they have a schematron/xsderror and move it up
						if they do -->
					<xsl:if test="*/@geonet:xsderror">
						<xsl:value-of select="*/@geonet:xsderror"/>
					</xsl:if>
                    <div class="close">[<a href="javascript:void(0)"><xsl:value-of select="/root/gui/strings/close"/></a>]</div>
				</div>
			</xsl:if>
		</xsl:variable>


		<xsl:call-template name="simpleElementGui">
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="text" select="$text"/>
			<xsl:with-param name="addLink" select="$addLink"/>
            <xsl:with-param name="addAsXLink" select="$addAsXLink"/>
			<xsl:with-param name="removeLink" select="$removeLink"/>
			<xsl:with-param name="upLink"     select="$upLink"/>
			<xsl:with-param name="downLink"   select="$downLink"/>
			<xsl:with-param name="helpLink"   select="$helpLink"/>
			<xsl:with-param name="schematronLink" select="$schematronLink"/>
			<xsl:with-param name="edit"       select="true()"/>
			<xsl:with-param name="id" select="$id"/>
			<xsl:with-param name="ref" select="geonet:element/@ref"/>
			<xsl:with-param name="schema" select="$schema"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="addLink">
        <xsl:param name="id"/>

		<xsl:variable name="name" select="name(.)"/>
		<!-- <xsl:variable name="subtemplates" select="/root/gui/subtemplates/record[string(root)=$name]"/> -->
		<xsl:variable name="subtemplates" select="/root/gui/subtemplates/record[string(root)='']"/>
		<xsl:variable name="nextBrother" select="following-sibling::*[1]"/>
		<xsl:variable name="nb">
			<xsl:if test="name($nextBrother)='geonet:child'">
				<xsl:choose>
					<xsl:when test="$nextBrother/@prefix=''">
						<xsl:if test="$nextBrother/@name=$name"><xsl:copy-of select="$nextBrother"/></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="concat($nextBrother/@prefix,':',$nextBrother/@name)=$name">
							<xsl:copy-of select="$nextBrother"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="newBrother" select="$nb"/>

		<xsl:if test="$newBrother/* and not($newBrother/*/geonet:choose or $subtemplates)">
			<xsl:choose>
				<xsl:when test="$nextBrother/@prefix=''">
					<xsl:value-of select="concat('javascript:doNewElementAction(',$apos,/root/gui/locService,'/metadata.elem.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,',',$apos,$id,$apos,');')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('javascript:doNewElementAction(',$apos,/root/gui/locService,'/metadata.elem.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@prefix,':',$nextBrother/@name,$apos,',',$apos,$id,$apos,');')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


    <!-- Add an element as an XLink / will popup a remote element selector
        and add the XLink in the metadata -->
    <xsl:template name="addAsXLink">
        <xsl:param name="id"/>

        <xsl:variable name="name" select="name(.)"/>
        <xsl:variable name="nextBrother" select="following-sibling::*[1]"/>
        <xsl:variable name="nb">
            <xsl:if test="name($nextBrother)='geonet:child'">
                <xsl:choose>
                    <xsl:when test="$nextBrother/@prefix=''">
                        <xsl:if test="$nextBrother/@name=$name"><xsl:copy-of select="$nextBrother"/></xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="concat($nextBrother/@prefix,':',$nextBrother/@name)=$name">
                            <xsl:copy-of select="$nextBrother"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="newBrother" select="$nb"/>

        <xsl:if test="($newBrother/* and not($newBrother/*/geonet:choose)) or $name='gmd:distributorContact'">
            <xsl:choose>
            	<xsl:when test="$name='gmd:distributorContact'">
            		<xsl:value-of select="concat('javascript:displayXLinkSearchBox(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',../geonet:element/@ref,',',$apos,$name,$apos,',',$apos,$id,$apos,');')"/>
            		<!--<xsl:value-of select="concat('javascript:popXLink(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,',',$apos,$id,$apos,', event);')"/>-->
            	</xsl:when>
            	<xsl:when test="$nextBrother/@prefix=''">
                	<xsl:value-of select="concat('javascript:displayXLinkSearchBox(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,',',$apos,$id,$apos,');')"/>
                	<!--<xsl:value-of select="concat('javascript:popXLink(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,',',$apos,$id,$apos,', event);')"/>-->
                </xsl:when>
                <xsl:otherwise>
                	<xsl:value-of select="concat('javascript:displayXLinkSearchBox(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@prefix,':',$nextBrother/@name,$apos,',',$apos,$id,$apos,');')"/>
                	<!--<xsl:value-of select="concat('javascript:popXLink(',$apos,/root/gui/locService,'/metadata.xlink.add',$apos,',',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,',',$apos,$id,$apos,', event);')"/>-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

	<!--
	shows editable fields for an attribute
	-->
	<!-- FIXME: not schema-configurable -->
	<xsl:template name="editAttribute">
		<xsl:param name="schema"/>
		<xsl:param name="title"/>
		<xsl:param name="text"/>
		<xsl:param name="helpLink"/>

		<xsl:variable name="name" select="name(.)"/>
		<xsl:variable name="value" select="string(.)"/>
		<xsl:call-template name="simpleElementGui">
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="text" select="$text"/>
			<xsl:with-param name="helpLink" select="$helpLink"/>
			<xsl:with-param name="edit"     select="true()"/>
		</xsl:call-template>
	</xsl:template>

	<!--
	shows editable fields for a complex element
	-->
	<xsl:template name="editComplexElement">
		<xsl:param name="schema"/>
		<xsl:param name="title"/>
		<xsl:param name="content"/>
		<xsl:param name="helpLink"/>

		<!-- if it's the last brother of it's type and there is a new brother make addLink -->

		<xsl:variable name="id" select="generate-id(.)"/>
		<xsl:variable name="addLink">
			<xsl:call-template name="addLink">
				<xsl:with-param name="id" select="$id"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="addAsXLink">
            <xsl:call-template name="addAsXLink">
                <xsl:with-param name="id" select="$id"/>
            </xsl:call-template>
        </xsl:variable>
		<xsl:variable name="removeLink">
			<xsl:if test="geonet:element/@del='true'">
				<xsl:value-of select="concat('javascript:doElementAction(',$apos,/root/gui/locService,'/metadata.elem.delete',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,',0);')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="upLink">
			<xsl:if test="geonet:element/@up='true'">
				<xsl:value-of select="concat('javascript:doMoveElementAction(',$apos,/root/gui/locService,'/metadata.elem.up',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="downLink">
			<xsl:if test="geonet:element/@down='true'">
				<xsl:value-of select="concat('javascript:doMoveElementAction(',$apos,/root/gui/locService,'/metadata.elem.down',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
			</xsl:if>
		</xsl:variable>
<!-- schematron info -->
		<xsl:variable name="schematronLink">
			<xsl:variable name="ref" select="concat('#_',geonet:element/@ref)"/>
			<xsl:if test="//geonet:errorFound[@ref=$ref] or @geonet:xsderror">
				<div class="tooltip" style="display:none;" id="{$ref}Schematron" onclick="this.style.display='none';">
					<xsl:for-each select="//geonet:errorFound[@ref=$ref]">
						<xsl:copy-of select="geonet:diagnostics"/>
                        <hr/>
					</xsl:for-each>
					<xsl:if test="@geonet:xsderror">
						<xsl:value-of select="@geonet:xsderror"/><br/>
					</xsl:if>
                    <div class="close">[<a href="javascript:void(0)"><xsl:value-of select="/root/gui/strings/close"/></a>]</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:call-template name="complexElementGui">
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="text" select="text()"/>
			<xsl:with-param name="content" select="$content"/>
			<xsl:with-param name="addLink" select="$addLink"/>
            <xsl:with-param name="addAsXLink" select="$addAsXLink"/>
			<xsl:with-param name="removeLink" select="$removeLink"/>
			<xsl:with-param name="upLink" select="$upLink"/>
			<xsl:with-param name="downLink" select="$downLink"/>
			<xsl:with-param name="helpLink" select="$helpLink"/>
			<xsl:with-param name="schematronLink" select="$schematronLink"/>
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="true()"/>
			<xsl:with-param name="id" select="$id"/>
			<xsl:with-param name="ref" select="geonet:element/@ref"/>
		</xsl:call-template>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- gui templates -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<!--
	gui to show a simple element
	-->
	<xsl:template name="simpleElementGui">
		<xsl:param name="title"/>
		<xsl:param name="text"/>
		<xsl:param name="helpLink"/>
		<xsl:param name="addLink"/>
        <xsl:param name="addAsXLink"/>
		<xsl:param name="removeLink"/>
		<xsl:param name="upLink"/>
		<xsl:param name="downLink"/>
		<xsl:param name="schematronLink"/>
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="id"/>
		<xsl:param name="ref"/>
        <xsl:variable name="row">
                <xsl:if test="$edit">
                    <xsl:call-template name="visibility-icons">
                        <xsl:with-param name="ref" select="$ref"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$helpLink!=''">
                        <span id="tip.{$helpLink}" style="cursor:help;"><xsl:value-of select="$title"/>
                            <xsl:call-template name="asterisk">
                                <xsl:with-param name="link" select="$helpLink"/>
                                <xsl:with-param name="edit" select="$edit"/>
                            </xsl:call-template>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="showTitleWithTag">
                            <xsl:with-param name="title" select="$title"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Flag mandatory elements. In edit mode, an element
                with no remove link (no x button) and with no link to
                create one (no + button) is a mandatory element which
                is displayed.
                Add some exception in order to flag that metadata contact is mandatory.
                We should add to geonet:child element their status in order to add
                info in the editor ?
                -->
                <xsl:if test="($edit = true() and $removeLink='' and $addLink='') or
                    ($edit = true() and @name='contact' and @prefix='gmd' and count(parent::node()[@gco:isoType='gmd:MD_Metadata'])=1)">*</xsl:if>
                <xsl:text>&#160;</xsl:text>
                <xsl:call-template name="getButtons">
                    <xsl:with-param name="addLink" select="$addLink"/>
                    <xsl:with-param name="addAsXLink" select="$addAsXLink"/>
                    <xsl:with-param name="removeLink" select="$removeLink"/>
                    <xsl:with-param name="upLink" select="$upLink"/>
                    <xsl:with-param name="downLink" select="$downLink"/>
                    <xsl:with-param name="schematronLink" select="$schematronLink"/>
                    <xsl:with-param name="id" select="$id"/>
                    <xsl:with-param name="ref" select="$ref"/>
                    <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="requiredContact"
            select="$edit = true() and 
                   ((@name='contact' and @prefix='gmd' and count(parent::node()[@gco:isoType='gmd:MD_Metadata'])=1)
                    or
                    (@name='userContactInfo' and @prefix='gmd' and count(parent::gmd:MD_Usage)=1))
                            " />

        <xsl:variable name="serviceIdentification"
            select ="parent::node()[@gco:isoType='srv:SV_ServiceIdentification']"/>
        <xsl:variable name="dataIdentification"
            select ="parent::node()[@gco:isoType='gmd:MD_DataIdentification']"/>
        <xsl:variable name="mixedOrTightCouplingType">
            <xsl:choose>
                <xsl:when test="$serviceIdentification//srv:SV_CouplingType/@codeListValue = 'mixed' or
                     $serviceIdentification//srv:SV_CouplingType/@codeListValue = 'tight'">
                    <xsl:value-of select="true()"/>
                 </xsl:when>
                 <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="requiredExtent"
            select="$edit = true() and 
                    @name='extent' and  
                    ( count($dataIdentification)>0 or
                      (count($serviceIdentification)>0 and 
                       string($mixedOrTightCouplingType) = true()
                      )
                    )
            " />

        <tr id="{$id}">
            <xsl:choose>
                <xsl:when test="$requiredContact or $requiredExtent">
                    <th class="md" width="20%" valign="top"
                        style="border-width: 3px 3px 3px 3px; border-style: solid solid solid solid; border-color: red red red red;">
                        <xsl:copy-of select="$row" />
                    </th>
                </xsl:when>
                <xsl:otherwise>
                    <th class="md" width="20%" valign="top">
                        <xsl:copy-of select="$row" />
                    </th>
                </xsl:otherwise>
            </xsl:choose>
            <td class="padded" valign="top">
            <xsl:choose>
            	<xsl:when test="$edit"><xsl:copy-of select="$text" /></xsl:when>
            	<xsl:otherwise><xsl:copy-of select="util:toHyperlinks($text)" /></xsl:otherwise>
            </xsl:choose>
            </td>
        </tr>
	</xsl:template>
	<!--
	gui to show a title and do special mapping for container elements
	-->
	<xsl:template name="showTitleWithTag">
		<xsl:param name="title"/>
		<xsl:param name="class"/>
		<xsl:variable name="shortTitle" select="normalize-space($title)"/>
		<xsl:variable name="conthelp" select="concat('This is a container element name - you can give it a title and help by entering some help for ',$shortTitle,' in the help file')"/>
		<xsl:variable name="nohelp" select="concat('This is an element/attribute name - you can give it a title and help by entering some help for ',$shortTitle,' in the help file')"/>

		<xsl:choose>
			<xsl:when test="contains($title,'CHOICE_ELEMENT')">
				<a class="{$class}" title="{$conthelp}">Choice</a>
			</xsl:when>
			<xsl:when test="contains($title,'GROUP_ELEMENT')">
				<a class="{$class}" title="{$conthelp}">Group</a>
			</xsl:when>
			<xsl:when test="contains($title,'SEQUENCE_ELEMENT')">
				<a class="{$class}" title="{$conthelp}">Sequence</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="{$class}" title="{$nohelp}"><xsl:value-of select="$title"/></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	gui to show a complex element
	-->
	<xsl:template name="complexElementGui">
		<xsl:param name="title"/>
		<xsl:param name="text"/>
		<xsl:param name="content"/>
		<xsl:param name="helpLink"/>
		<xsl:param name="addLink"/>
        <xsl:param name="addAsXLink"/>
		<xsl:param name="removeLink"/>
		<xsl:param name="upLink"/>
		<xsl:param name="downLink"/>
		<xsl:param name="schematronLink"/>
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="id"/>
		<xsl:param name="ref"/>

        
        <xsl:variable name="deletedXlinkAncestorOrSelf" select="count(ancestor-or-self::node()[contains(string(@xlink:href), 'xml.reusable.deleted')]) > 0" />
        <xsl:variable name="deletedXlinkAncestor" select="$deletedXlinkAncestorOrSelf and 
                                                          (count(ancestor::node()[contains(string(@xlink:href), 'xml.reusable.deleted')]) = 0
                                                           or name(.) = 'gmd:MD_Format'
                                                          )"/>
        <xsl:variable name="updatedTitle">
            <xsl:choose>
                <xsl:when test="$deletedXlinkAncestor">
                <xsl:value-of select="$title"/> (<xsl:value-of select="/root/gui/strings/rejected"/>)
                </xsl:when>
                <xsl:otherwise>
                <xsl:value-of select="$title"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
		<tr id="{$id}">
			<td class="padded-content" width="100%" colspan="2">
           <xsl:if test="$deletedXlinkAncestorOrSelf">
                <xsl:attribute name="class">deleted-reusable</xsl:attribute>
           </xsl:if>
				<fieldset class="metadata-block">
					<legend class="block-legend">
						<xsl:if test="$edit">
							<xsl:call-template name="visibility-icons">
								<xsl:with-param name="ref" select="$ref"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$helpLink!=''">
								<span id="tip.{$helpLink}" class="help-content" style="cursor:help;"><xsl:value-of select="$updatedTitle"/>
									<xsl:call-template name="asterisk">
										<xsl:with-param name="link" select="$helpLink"/>
										<xsl:with-param name="edit" select="$edit"/>
									</xsl:call-template>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="showTitleWithTag">
									<xsl:with-param name="title" select="$title"/>
									<xsl:with-param name="class" select="'no-help'"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="getButtons">
							<xsl:with-param name="addLink" select="$addLink"/>
                            <xsl:with-param name="addAsXLink" select="$addAsXLink"/>
							<xsl:with-param name="removeLink" select="$removeLink"/>
							<xsl:with-param name="upLink" select="$upLink"/>
							<xsl:with-param name="downLink" select="$downLink"/>
							<xsl:with-param name="schematronLink" select="$schematronLink"/>
							<xsl:with-param name="id" select="$id"/>
							<xsl:with-param name="ref" select="$ref"/>
							<xsl:with-param name="schema" select="$schema"/>
						</xsl:call-template>
					</legend>
					<table width="100%">
						<xsl:copy-of select="$content"/>
					</table>
				</fieldset>
			</td>
		</tr>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- utility templates -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<!--
	Returns the title of an element. If the schema is a profile of iso19139 then search
	* the profile help first
	  * with context (ie. context is the class where the element is defined)
	  * with no context
	and if not found search the iso19139 main help.

	If not iso based, search in corresponding schema.

	If not found return the element name between "[]".
	-->
	<xsl:template name="getTitle">
		<xsl:param name="name"/>
		<xsl:param name="schema"/>

		<xsl:variable name="context" select="name(parent::node())"/>
		<xsl:variable name="contextIsoType" select="parent::node()/@gco:isoType"/>

		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="starts-with($schema,'iso19139')">
					<!-- Name with context in current schema -->
					<xsl:variable name="schematitleWithContext"
								  select="string(/root/gui/*[name(.)=$schema]
								  /element[@name=$name and (@context=$context or @context=$contextIsoType)]
								  /label)"/>

					
					<!-- Name with context in base schema -->
					<xsl:variable name="schematitleWithContextIso"
						select="string(/root/gui/iso19139/element[@name=$name and (@context=$context or @context=$contextIsoType)]
						/label)"/>

					<!-- Name in current schema -->
					<xsl:variable name="schematitle" select="string(/root/gui/*[name(.)=$schema]/element[@name=$name and not(@context)]/label)"/>

					<xsl:choose>

                        <xsl:when test="name(.)='gmd:LocalisedCharacterString' and string-length(@language)>0">
                             &#160;&#160;&#160;&#160;&#160;&#160;<xsl:value-of select="@language"/>
                        </xsl:when>
                        <xsl:when test="name(.)='gmd:LocalisedCharacterString' and string-length(@code)>0">
                             &#160;&#160;&#160;&#160;&#160;&#160;<xsl:value-of select="@code"/>
                        </xsl:when>
                        <xsl:when test="name(.)='gmd:LocalisedCharacterString' and string-length(@locale)>0">
                             &#160;&#160;&#160;&#160;&#160;&#160;<xsl:value-of select="substring(@locale,2)"/>
                        </xsl:when>
						<xsl:when test="normalize-space($schematitle)='' and
										normalize-space($schematitleWithContext)='' and
										normalize-space($schematitleWithContextIso)=''">
							<xsl:value-of select="string(/root/gui/iso19139/element[@name=$name]/label)"/>
						</xsl:when>
						<xsl:when test="normalize-space($schematitleWithContext)='' and
										normalize-space($schematitleWithContextIso)=''">
								<xsl:value-of select="$schematitle"/>
						</xsl:when>
						<xsl:when test="normalize-space($schematitleWithContext)=''">
								<xsl:value-of select="$schematitleWithContextIso"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$schematitleWithContext"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

<!-- otherwise just get the title out of the approriate schema help file -->

				<xsl:otherwise>
					<xsl:value-of select="string(/root/gui/*[name(.)=$schema]/element[@name=$name]/label)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($title)!=''">
				<xsl:value-of select="$title"/>
			</xsl:when>
			<xsl:otherwise>
				[<xsl:value-of select="$name"/>]
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
	returns the text of an element

	Specific behaviour:
	* if iso19139.*, gco:CharacterString elements are displayed in GUI language
	using PT_FreeText elements if exists. If not, main metadata record language
	is used (as defined by gmd:language). For a PT_FreeText element to be valid,
	the gmd:locale MUST be declared in gmd:MD_Metadata root elements.

	* in editing mode, for gco:CharacterString elements (with no codelist),
	an helper list could be	defined in loc files. Then a list of values
	is displayed next to the input field.
	-->
	<xsl:template name="getElementText">

		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="rows" select="1"/>
        <xsl:param name="cols" select="50"/>
        <xsl:param name="visible" select="'true'"/>
        <xsl:param name="langId"/>
        <xsl:param name="validator"/>
        <xsl:param name="input_type">text</xsl:param>
        <xsl:param name="no_name" select="false()" />

		<xsl:variable name="name"  select="name(.)"/>
		<xsl:variable name="value" select="string(.)"/>

        <!-- Turn off editing on child elements of an xlinked ancestor -->
        <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>

		<xsl:choose>
			<!-- list of values -->
			<xsl:when test="geonet:element/geonet:text">
				<select class="md" name="_{geonet:element/@ref}" size="1" >
                     <xsl:if test="$visible = 'false'">
                        <xsl:attribute name="style">display:none;</xsl:attribute>
                     </xsl:if>
					<xsl:if test="$xlinkedAncestor = 'true'">
                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                    </xsl:if>
					<option name=""/>
					<xsl:for-each select="geonet:element/geonet:text">
						<option>
							<xsl:if test="@value=$value">
								<xsl:attribute name="selected"/>
							</xsl:if>
							<xsl:variable name="choiceValue" select="string(@value)"/>
							<xsl:attribute name="value"><xsl:value-of select="$choiceValue"/></xsl:attribute>

							<!-- it seems that this code is run only under FGDC -->
							<xsl:variable name="label" select="/root/gui/*[name(.)=$schema]/codelist[@name = $name]/entry[code = $choiceValue]/label"/>
							<xsl:choose>
								<xsl:when test="$label"><xsl:value-of select="$label"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$choiceValue"/></xsl:otherwise>
							</xsl:choose>
						</option>
					</xsl:for-each>
				</select>
			</xsl:when>
			<xsl:when test="$edit=true() and $rows=1">
				<xsl:choose>
					<xsl:when test="($schema='dublin-core' and $name='dc:subject') or
									($schema='fgdc' and $name='themekey') or
									($schema='iso19115' and $name='keyword') or
									(starts-with($schema,'iso19139') and (name(..)='gmd:keyword'
										or ../@gco:isoType='gmd:keyword'))">
						<input class="md" type="text" id="_{geonet:element/@ref}" name="_{geonet:element/@ref}" value="{text()}" size="{$cols}">

                            <xsl:if test="$visible = 'false'">
                               <xsl:attribute name="style">display:none;</xsl:attribute>
                            </xsl:if>

                           <xsl:if test="$xlinkedAncestor = 'true'">
                              <xsl:attribute name="disabled">disabled</xsl:attribute>
                           </xsl:if>
						</input>

						<xsl:call-template name="helper">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="attribute" select="false()"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<input class="md" type="{$input_type}" value="{text()}" size="{$cols}" onkeyup="{$validator}" onchange="{$validator}">

                            <xsl:if test="$visible = 'false'">
                               <xsl:attribute name="style">display:none;</xsl:attribute>
                            </xsl:if>

                          <xsl:choose>
                             <xsl:when test="$no_name=false()">

                                <xsl:attribute name="name">_<xsl:value-of select="geonet:element/@ref"/></xsl:attribute>
                                <xsl:attribute name="id">_<xsl:value-of select="geonet:element/@ref"/></xsl:attribute>
                             </xsl:when>
                             <xsl:otherwise>
                                <xsl:attribute name="id"><xsl:value-of select="geonet:element/@ref"/></xsl:attribute>
                             </xsl:otherwise>
                          </xsl:choose>

						  <xsl:variable name="parentName" select="name(parent::node())"/>
						  <xsl:if test="$xlinkedAncestor = 'true' or /root/gui/iso19139/element[@name = $parentName]/@readonly">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
                          </xsl:if>
						</input>

						<xsl:call-template name="helper">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="attribute" select="false()"/>
						</xsl:call-template>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$edit=true()">
				<textarea class="md" name="_{geonet:element/@ref}" rows="{$rows}" cols="{$cols}">
                    <xsl:if test="$visible = 'false'">
                       <xsl:attribute name="style">display:none;</xsl:attribute>
                    </xsl:if>
					<xsl:if test="$validator!=''">
						<xsl:attribute name="onkeyup"><xsl:value-of select="$validator"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$xlinkedAncestor = 'true'">
                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="text()"/>
				</textarea>
			</xsl:when>
			<xsl:when test="$edit=false() and $rows!=1">
				<xsl:variable name="text">
				<xsl:choose>
					<xsl:when test="starts-with($schema,'iso19139')">
						<xsl:apply-templates mode="localised" select="..">
							<xsl:with-param name="langId" select="$langId"></xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value"/>
					</xsl:otherwise>
				</xsl:choose>
				</xsl:variable>
    				<xsl:call-template name="preformatted">
    					<xsl:with-param name="text" select="$text"/>
    				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- not editable text/codelists -->
				<xsl:variable name="label" select="/root/gui/*[name(.)=$schema]/codelist[@name = $name]/entry[code=$value]/label"/>
				<xsl:choose>
					<xsl:when test="$label"><xsl:value-of select="$label"/></xsl:when>
					<xsl:when test="starts-with($schema,'iso19139') and name(.)!='gco:ScopedName'">
						<xsl:apply-templates mode="localised" select="..">
							<xsl:with-param name="langId" select="$langId"></xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template name="helper">
		<xsl:param name="schema"/>
		<xsl:param name="attribute"/>

		<!-- Helper list are defined in parent of gco:CharacterString elements
			Look for an helper list in profil first and then in iso19139.
		-->
		<xsl:if test="starts-with($schema,'iso19139')">
			<xsl:variable name="parentName">
				<xsl:choose>
					<xsl:when test="$attribute=true()">
						<xsl:value-of select="name(.)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="name(parent::node())"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="helper">
				<xsl:choose>
					<xsl:when test="not(/root/gui/*[name(.)=$schema]/element[@name = $parentName]/helper)">
						<xsl:copy-of select="/root/gui/iso19139/element[@name = $parentName]/helper"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="/root/gui/*[name(.)=$schema]/element[@name = $parentName]/helper"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="normalize-space($helper)!=''">
				<xsl:variable name="refId">
					<xsl:choose>
						<xsl:when test="$attribute=true()">
							<xsl:value-of select="concat(../geonet:element/@ref, '_', name(.))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="geonet:element/@ref"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>


				(<xsl:value-of select="/root/gui/strings/helperList"/>
				<select onchange="$('_{$refId}').value=this.options[this.selectedIndex].value;">
					<option/>
					<xsl:copy-of select="exslt:node-set($helper)"/>
				</select>)
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<!--
	returns the text of an attribute
	-->
	<xsl:template name="getAttributeText">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="rows" select="1"/>
		<xsl:param name="cols" select="50"/>

		<xsl:variable name="name"  select="name(.)"/>
		<xsl:variable name="value" select="string(.)"/>
		<xsl:variable name="parent"  select="name(..)"/>
		<!-- the following variable is used in place of name as a work-around to
         deal with qualified attribute names like gml:id
		     which if not modified will cause JDOM errors on update because of the
				 way in which changes to ref'd elements are parsed as XML -->
		<xsl:variable name="updatename">
      <xsl:choose>
        <xsl:when test="contains($name,':')">
          <xsl:value-of select="concat(substring-before($name,':'),'COLON',substring-after($name,':'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
		<xsl:choose>
			<!-- list of values -->
			<xsl:when test="../geonet:attribute[string(@name)=$name]/geonet:text">
				<select class="md" name="_{../geonet:element/@ref}_{name(.)}" size="1">
					<option name=""/>
					<xsl:for-each select="../geonet:attribute/geonet:text">
						<option>
							<xsl:if test="@value=$value">
								<xsl:attribute name="selected"/>
							</xsl:if>
							<xsl:variable name="choiceValue" select="string(@value)"/>
							<xsl:attribute name="value"><xsl:value-of select="$choiceValue"/></xsl:attribute>

							<!-- codelist in edit mode -->
							<xsl:variable name="label" select="/root/gui/*[name(.)=$schema]/codelist[@name = $parent]/entry[code=$choiceValue]/label"/>
							<xsl:choose>
								<xsl:when test="$label"><xsl:value-of select="$label"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$choiceValue"/></xsl:otherwise>
							</xsl:choose>
						</option>
					</xsl:for-each>
				</select>
			</xsl:when>
			<xsl:when test="$edit=true() and $rows=1">
				<input class="md" type="text" id="_{../geonet:element/@ref}_{$updatename}" name="_{../geonet:element/@ref}_{$updatename}" value="{string()}" size="{$cols}" />

				<xsl:call-template name="helper">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="attribute" select="true()"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:when test="$edit=true()">
				<textarea class="md" name="_{../geonet:element/@ref}_{$updatename}" rows="{$rows}" cols="{$cols}">
					<xsl:value-of select="string()"/>
				</textarea>
			</xsl:when>
			<xsl:otherwise>
				<!-- codelist in view mode -->
				<xsl:variable name="label" select="/root/gui/*[name(.)=$schema]/codelist[@name = $parent]/entry[code = $value]/label"/>
				<xsl:choose>
					<xsl:when test="$label"><xsl:value-of select="$label"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$value"/></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
	returns the content of a complex element
	-->
	<xsl:template name="getContent">
		<xsl:param name="schema"/>
		<xsl:param name="edit"   select="false()"/>

		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="elementEP" select="@*">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementEP" select="*[namespace-uri(.)!=$geonetUri]|geonet:child">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="elementEP" select="@*">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="false()"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementEP" select="*">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="false()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================================ -->
	<!-- returns the help url -->
	<!-- ================================================================================ -->

	<xsl:template name="getHelpLink">
		<xsl:param name="name"/>
		<xsl:param name="schema"/>

		<xsl:choose>
			<xsl:when test="contains($name,'_ELEMENT')">
				<xsl:value-of select="''"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($schema,'|', $name ,'|', name(parent::node()) ,'|', ../@gco:isoType)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================================ -->

	<xsl:template name="asterisk">
		<xsl:param name="link"/>
		<xsl:param name="edit"/>

		<xsl:variable name="schema" select="substring-before($link, '|')"/>
		<xsl:variable name="name"   select="substring-after($link, '|')"/>

		<xsl:if test="$edit">
			<xsl:if test="/root/gui/*[name() = $schema]/element[@name=$name]/condition">
				<sup><font size="-1" color="#FF0000">&#xA0;*</font></sup>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- ================================================================================ -->

	<xsl:template name="getButtons">
		<xsl:param name="addLink"/>
		<xsl:param name="addAsXLink"/>
		<xsl:param name="removeLink"/>
		<xsl:param name="upLink"/>
		<xsl:param name="downLink"/>
		<xsl:param name="schematronLink"/>
		<xsl:param name="id"/>
		<xsl:param name="ref"/>
		<xsl:param name="schema"/>

	    <!-- XLink:
             * Turn off delete, up and down on child elements of an xlinked ancestor
            because the remote resource should be edited instead
             * TODO : Turn off up and down mechanism should work for the XLinked element (not for its childs)
            -->


        <!-- XLinked ancestor ? -->
        <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>
        <xsl:variable name="isXlink" select="@xlink:href"/>
        <xsl:variable name="partOfKeywd" select="count(ancestor::gmd:descriptiveKeywords) > 0"/>
		<xsl:variable name="childname" select="concat(@prefix, ':', @name)"/>
		<xsl:variable name="name" select="name(.)"/>

		<!-- add asXLink button for
            * element not descendant of an XLinked element
            * elements defined in schema-suggestions.xml

            FIXME : this is only valid for iso19139 based records
            
            gmd:source element could be contact or source (LI_source) class.
            schema-suggestion configuration does not allow yet such distinction.
            Add temporary fix.
             -->
		<xsl:if test="normalize-space($addAsXLink)
                        and $xlinkedAncestor = 'false'
                        and count(/root/gui/iso19139sugg/field[contains(@mode, 'xlink') and (@name=$childname or @name=$name) and not(exception[@parent = name(..)])]) != 0
                        and not(name(..) = /root/gui/iso19139sugg/field[contains(@mode, 'xlink') and (@name=$childname or @name=$name)]/exception/@parent)
                        and not(geonet:choose/@name='gmi:LE_Source')
                        ">
            <xsl:text> </xsl:text>

            [<a id="button{$id}" href="{$addAsXLink}" alt="{/root/gui/strings/elementXLink}"
                title="{/root/gui/strings/elementXLink}">
                <img src="{/root/gui/url}/images/plus.gif"
                    alt="{/root/gui/strings/elementXLink}"
                    title="{/root/gui/strings/elementXLink}"/>
            </a>]
		</xsl:if>

		<!-- add button -->
		<xsl:if test="normalize-space($addLink)
			and $xlinkedAncestor = 'false'
			and not($isXlink)
            and $partOfKeywd != 'true'

			and (
				count(/root/gui/*[name(.)=concat($schema, 'sugg')]/field[@mode='xlinkOnly' and (@name=$childname or @name=$name)]) = 0
				or geonet:choose/@name='gmi:LE_Source'
                or name(..) = /root/gui/iso19139sugg/field[contains(@mode, 'xlink') and (@name=$childname or @name=$name)]/exception/@parent
				)
			">
			<xsl:text> </xsl:text>
			<a id="button{$id}"  href="{$addLink}"><img src="{/root/gui/url}/images/plus.gif" alt="{/root/gui/strings/add}"/></a>
		</xsl:if>
		<!-- remove button -->
		<xsl:if test="normalize-space($removeLink)
            and $xlinkedAncestor = 'false'
            and $partOfKeywd != 'true'
            and $name != 'gmd:extentTypeCode'
            and not(ancestor::che:CHE_CI_ResponsibleParty and not(normalize-space($addLink) or normalize-space($downLink)))
            and not($name = 'gmd:description' and name(..) = 'gmd:EX_Extent')"
            >
			<xsl:text> </xsl:text>
			<a id="button{$id}"  href="{$removeLink}"><img src="{/root/gui/url}/images/del.gif" alt="{/root/gui/strings/del}"/></a>
		</xsl:if>
		<!-- up button -->
		<xsl:if test="normalize-space($upLink)
            and $xlinkedAncestor = 'false'
            and $partOfKeywd != 'true'">
			<xsl:text> </xsl:text>
			<a id="button{$id}"  href="{$upLink}"><img src="{/root/gui/url}/images/up.gif" alt="{/root/gui/strings/up}"/></a>
		</xsl:if>
		<!-- down button -->
		<xsl:if test="normalize-space($downLink)
            and $xlinkedAncestor = 'false'
            and $partOfKeywd != 'true'">
			<xsl:text> </xsl:text>
			<a id="button{$id}"  href="{$downLink}"><img src="{/root/gui/url}/images/down.gif" alt="{/root/gui/strings/down}"/></a>
		</xsl:if>
		<!-- schematron button -->
		<xsl:if test="normalize-space($schematronLink)">
			<xsl:text> </xsl:text>
			<a href="javascript:void(0)" onclick="$('#_{$ref}Schematron').style.display='block';"><img src="{/root/gui/url}/images/schematron.gif"/></a>
			<xsl:copy-of select="$schematronLink"/>
		</xsl:if>
	</xsl:template>

	<!--
	translates CR-LF sequences into HTML newlines <p/>
	-->
	<xsl:template name="preformatted">
		<xsl:param name="text"/>

		<xsl:choose>
			<xsl:when test="contains($text,'&#13;&#10;')">
				<xsl:value-of select="substring-before($text,'&#13;&#10;')"/>
				<br/>
				<xsl:call-template name="preformatted">
					<xsl:with-param name="text"  select="substring-after($text,'&#13;&#10;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text,'&#10;')">
				<xsl:value-of select="substring-before($text,'&#10;')"/>
				<br/>
				<xsl:call-template name="preformatted">
					<xsl:with-param name="text"  select="substring-after($text,'&#10;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- XML formatting -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<!--
	draws an element as xml document
	-->
	<xsl:template mode="xmlDocument" match="*">
		<xsl:param name="edit" select="false()"/>

		<xsl:choose>
			<xsl:when test="$edit=true()">
				<tr><td>
					<textarea class="md" name="data" rows="30" cols="100">
						<xsl:text>&lt;?xml version="1.0" encoding="UTF-8"?&gt;</xsl:text>
						<xsl:text>&#10;</xsl:text>
						<xsl:apply-templates mode="editXMLElement" select="."/>
					</textarea>
				</td></tr>
			</xsl:when>
			<xsl:otherwise>
				<tr><td>
					<b><xsl:text>&lt;?xml version="1.0" encoding="UTF-8"?&gt;</xsl:text></b><br/>
					<xsl:apply-templates mode="showXMLElement" select="."/>
				</td></tr>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!--
	draws an editable element in xml
	-->
	<xsl:template mode="editXMLElement" match="*">
		<xsl:param name="indent"/>
		<xsl:choose>

			<!-- has children -->
			<xsl:when test="*[not(starts-with(name(),'geonet:'))]">
				<xsl:if test="not(contains(name(.),'_ELEMENT'))">
					<xsl:call-template name="editXMLStartTag">
						<xsl:with-param name="indent" select="$indent"/>
					</xsl:call-template>
					<xsl:text>&#10;</xsl:text>
				</xsl:if>
				<xsl:for-each select="*">
					<xsl:apply-templates select="." mode="editXMLElement">
						<xsl:with-param name="indent" select="concat($indent, '&#09;')"/>
					</xsl:apply-templates>
				</xsl:for-each>
				<xsl:if test="not(contains(name(.),'_ELEMENT'))">
					<xsl:call-template name="editEndTag">
						<xsl:with-param name="indent" select="$indent"/>
					</xsl:call-template>
					<xsl:text>&#10;</xsl:text>
				</xsl:if>
			</xsl:when>

			<!-- no children but text -->
			<xsl:when test="text()">
				<xsl:if test="not(contains(name(.),'_ELEMENT'))">
					<xsl:call-template name="editXMLStartTag">
						<xsl:with-param name="indent" select="$indent"/>
					</xsl:call-template>

					<!-- xml entities should be doubly escaped -->
					<xsl:apply-templates mode="escapeXMLEntities" select="text()"/>

					<xsl:call-template name="editEndTag"/>
					<xsl:text>&#10;</xsl:text>
				</xsl:if>
			</xsl:when>

			<!-- empty element -->
			<xsl:otherwise>
				<xsl:if test="not(contains(name(.),'_ELEMENT'))">
					<xsl:call-template name="editXMLStartEndTag">
						<xsl:with-param name="indent" select="$indent"/>
					</xsl:call-template>
					<xsl:text>&#10;</xsl:text>
				</xsl:if>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>
	<!--
	draws the start tag of an editable element
	-->
	<xsl:template name="editXMLStartTag">
		<xsl:param name="indent"/>

		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name(.)"/>
		<xsl:call-template name="editXMLNamespaces"/>
		<xsl:call-template name="editXMLAttributes"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>

	<!--
	draws the end tag of an editable element
	-->
	<xsl:template name="editEndTag">
		<xsl:param name="indent"/>

		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="name(.)"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>

	<!--
	draws the empty tag of an editable element
	-->
	<xsl:template name="editXMLStartEndTag">
		<xsl:param name="indent"/>

		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name(.)"/>
		<xsl:call-template name="editXMLNamespaces"/>
		<xsl:call-template name="editXMLAttributes"/>
		<xsl:text>/&gt;</xsl:text>
	</xsl:template>

	<!--
	draws attribute of an editable element
	-->
	<xsl:template name="editXMLAttributes">
		<xsl:for-each select="@*[namespace-uri(.)!='http://www.fao.org/geonetwork']">
			<xsl:text> </xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:text>=</xsl:text>
				<xsl:text>"</xsl:text>
				<xsl:call-template name="escapeXMLEntities">
					<xsl:with-param name="expr" select="string()"/>
				</xsl:call-template>
				<xsl:text>"</xsl:text>
		</xsl:for-each>
	</xsl:template>

	<!--
	draws namespaces of an editable element
	-->
	<xsl:template name="editXMLNamespaces">
		<xsl:variable name="parent" select=".."/>
		<xsl:for-each select="namespace::*">
			<xsl:if test="not(.=$parent/namespace::*) and name()!='geonet'">
				<xsl:text> xmlns</xsl:text>
				<xsl:if test="name()">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="name()"/>
				</xsl:if>
				<xsl:text>=</xsl:text>
				<xsl:text>"</xsl:text>
				<xsl:value-of select="string()"/>
				<xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--
	draws an element in xml
	-->
	<xsl:template mode="showXMLElement" match="*">
		<xsl:choose>

			<!-- has children -->
			<xsl:when test="*">
				<xsl:call-template name="showXMLStartTag"/>
				<dl>
					<xsl:for-each select="*">
						<dd>
							<xsl:apply-templates select="." mode="showXMLElement"/>
						</dd>
					</xsl:for-each>
				</dl>
				<xsl:call-template name="showEndTag"/>
			</xsl:when>

			<!-- no children but text -->
			<xsl:when test="text()">
				<xsl:call-template name="showXMLStartTag"/>
				<xsl:value-of select="text()"/>
				<xsl:call-template name="showEndTag"/>
			</xsl:when>

			<!-- empty element -->
			<xsl:otherwise>
				<xsl:call-template name="showXMLStartEndTag"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
	draws the start tag of an element
	-->
	<xsl:template name="showXMLStartTag">
			<font color="4444ff">
			<xsl:text>&lt;</xsl:text>
			<b>
				<xsl:value-of select="name(.)"/>
			</b>
			<xsl:call-template name="showXMLNamespaces"/>
			<xsl:call-template name="showXMLAttributes"/>
			<xsl:text>&gt;</xsl:text>
		</font>
	</xsl:template>

	<!--
	draws the end tag of an element
	-->
	<xsl:template name="showEndTag">
		<font color="4444ff">
			<xsl:text>&lt;/</xsl:text>
			<b>
				<xsl:value-of select="name(.)"/>
			</b>
			<xsl:text>&gt;</xsl:text>
		</font>
	</xsl:template>

	<!--
	draws the empty tag of an element
	-->
	<xsl:template name="showXMLStartEndTag">
		<font color="4444ff">
			<xsl:text>&lt;</xsl:text>
			<b>
				<xsl:value-of select="name(.)"/>
			</b>
			<xsl:call-template name="showXMLNamespaces"/>
			<xsl:call-template name="showXMLAttributes"/>
			<xsl:text>/&gt;</xsl:text>
		</font>
	</xsl:template>

	<!--
	draws attributes of an element
	-->
	<xsl:template name="showXMLAttributes">
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:text>=</xsl:text>
			<font color="ff4444">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="string()"/>
				<xsl:text>"</xsl:text>
			</font>
		</xsl:for-each>
	</xsl:template>

	<!--
	draws namespaces of an element
	-->
	<xsl:template name="showXMLNamespaces">
		<xsl:variable name="parent" select=".."/>
		<xsl:for-each select="namespace::*">
			<xsl:if test="not(.=$parent/namespace::*) and name()!='geonet'">
				<xsl:text> xmlns</xsl:text>
				<xsl:if test="name()">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="name()"/>
				</xsl:if>
				<xsl:text>=</xsl:text>
				<font color="888844">
					<xsl:text>"</xsl:text>
					<xsl:value-of select="string()"/>
					<xsl:text>"</xsl:text>
				</font>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--
	prevent drawing of geonet:* elements
	-->
	<xsl:template mode="showXMLElement" match="geonet:*"/>
	<xsl:template mode="editXMLElement" match="geonet:*"/>

    <xsl:template name="validatedXlink">

       <xsl:variable name="xlinkedAncestor" select="ancestor::node()[@xlink:href]" />
       <xsl:choose>
       <xsl:when test="count($xlinkedAncestor) != 0 and count(ancestor::node()[@xlink:role = 'http://www.geonetwork.org/non_valid_obj']) = 0">
           <xsl:value-of select="true()" />
       </xsl:when>
       <xsl:otherwise>
           <xsl:value-of select="false()" />
       </xsl:otherwise>
       </xsl:choose>
       </xsl:template>
</xsl:stylesheet>
