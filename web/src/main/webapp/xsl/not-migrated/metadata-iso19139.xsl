<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geonet="http://www.fao.org/geonetwork"
    xmlns:xalan="http://xml.apache.org/xalan" xmlns:exslt="http://exslt.org/common"
    xmlns:util="xalan://org.fao.geonet.util.XslUtil"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <!--
        ===================================================================
    -->
    <!-- default: in simple mode just a flat list -->
    <!--
        ===================================================================
    -->

    <xsl:template mode="iso19139" match="*|@*">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <!-- do not show empty elements in view mode -->
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                    <xsl:with-param name="flat" select="$currTab='simple'" />
                </xsl:apply-templates>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="empty">
                    <xsl:apply-templates mode="iso19139IsEmpty"
                        select="." />
                </xsl:variable>

                <xsl:if test="$empty!=''">
                    <xsl:apply-templates mode="element" select=".">
                        <xsl:with-param name="schema" select="$schema" />
                        <xsl:with-param name="edit" select="false()" />
                        <xsl:with-param name="flat" select="$currTab='simple'" />
                    </xsl:apply-templates>
                </xsl:if>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!--
        =====================================================================
    -->
    <!-- these elements should not be displayed -->
    <!--
        =====================================================================
    -->

    <xsl:template mode="iso19139"
        match="gmd:graphicOverview[gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString='thumbnail' or gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString='large_thumbnail']|
        gmd:textGroup|gmd:LocalisedCharacterString|
    @locale|@gco:isoType|@xsi:type"
        priority="20" />

    <!--
        =====================================================================
    -->
    <!--
        these elements should not be displayed in view mode and should be
        boxed
    -->
    <!--
        * available locales in metadata records are not displayed in view
        mode, only used in editing mode in order to add multilingual content.
    -->
    <!--
        =====================================================================
    -->

    <xsl:template mode="iso19139" match="gmd:locale" priority="1">
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:if test="$edit = true()">
            <xsl:apply-templates mode="complexElement"
                select=".">
                <xsl:with-param name="schema" select="$schema" />
                <xsl:with-param name="edit" select="$edit" />
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!--
        =====================================================================
    -->
    <!-- these elements should be boxed -->
    <!--
        =====================================================================
    -->

    <xsl:template mode="iso19139"
        match="gmd:processStep|gmd:MD_Usage|gmd:locale|gmd:contact|gmd:identificationInfo|gmd:descriptiveKeywords|
        gmd:spatialRepresentationInfo|gmd:pointOfContact|gmd:dataQualityInfo|gmd:referenceSystemInfo|
        gmd:equivalentScale|gmd:projection|gmd:ellipsoid|gmd:extent|srv:extent|gmd:verticalElement|
        gmd:geographicBox|gmd:EX_TemporalExtent|gmd:MD_Distributor|srv:containsOperations|gmd:source|
        gmd:featureCatalogueCitation|gmd:MD_LegalConstraints|gmd:MD_SecurityConstraints|gmd:MD_Constraints|
        gmd:MD_Resolution|gmd:MD_Format|srv:SV_CoupledResource|gmd:resourceMaintenance|gmd:resourceConstraints|
        gmd:spatialResolution|gmd:distributionFormat|gmd:transferOptions|gmd:MD_Medium|gmd:distributionInfo|srv:parameters|
        gmd:portrayalCatalogueInfo|gmd:contentInfo|gmd:metadataMaintenance|gmd:userDefinedMaintenanceFrequency">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
        </xsl:apply-templates>
    </xsl:template>


    <!--
        =====================================================================
    -->
    <!-- xlink elements are editable only if the xlink is non_valid -->
    <!--
        =====================================================================
    -->

    <xsl:template mode="iso19139"
        match="gmd:geographicElement">
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:choose>
            <xsl:when test="$edit=true() and (../../@xlink:role='http://www.geonetwork.org/non_valid_obj' or not(../../@xlink:role))">
                <xsl:apply-templates mode="iso19139">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="iso19139">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="false()" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!--
        =============================================================================
    -->
    <!--
        Create an autocompleter list for the parent identifier selection and
        display an hyperlink to the parent metadata record.
    -->
    <!--
        =============================================================================
    -->
    <xsl:template mode="iso19139" match="gmd:parentIdentifier"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:variable name="text">
                    <xsl:variable name="ref"
                        select="gco:CharacterString/geonet:element/@ref" />
                    <input onfocus="javascript:displaySearchBox('parentIdentifier','{/root/gui/strings/parentSearch}','_{$ref}');"
                    class="md" type="text" name="_{$ref}" id="_{$ref}" value="{gco:CharacterString/text()}" size="20" />
                    <img src="../../images/gdict.png" alt="{/root/gui/strings/parentSearch}" title="{/root/gui/strings/parentSearch}"
                        onclick="javascript:displaySearchBox('parentIdentifier','{/root/gui/strings/parentSearch}','_{$ref}');"/>
                </xsl:variable>

                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                    <xsl:with-param name="text" select="$text" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="text">
                        <xsl:variable name="metadataTitle">
                            <xsl:call-template name="getMetadataTitle">
                                <xsl:with-param name="uuid" select="gco:CharacterString"></xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <a href="metadata.show?uuid={gco:CharacterString}">
                            <xsl:value-of select="$metadataTitle"/>
                        </a>
                        <!--
                            FIXME : this will display the record on the same browser window
                            and could cause trouble when using popup or modal view.
                        -->
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Display extra thumbnails (not managed by GeoNetwork).
    Thumbnails managed by GeoNetwork are displayed on header.
    If fileName does not start with http://, just display as
    simple elements.
    -->
    <xsl:template mode="iso19139" match="gmd:graphicOverview" priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <!-- do not show empty elements in view mode -->
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="text">
                        <xsl:choose>
                            <xsl:when test="starts-with(gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString, 'http://')">

                                <xsl:variable name="langId">
                                    <xsl:call-template name="getLangId">
                                        <xsl:with-param name="langGui" select="/root/gui/language" />
                                        <xsl:with-param name="md"
                                            select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                                    </xsl:call-template>
                                </xsl:variable>

                                <img src="{gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString}">
                                    <xsl:attribute name="alt">
                                        <xsl:choose>
                                            <xsl:when test="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString">
                                                <xsl:apply-templates mode="localised" select="gmd:MD_BrowseGraphic/gmd:fileDescription">
                                                    <xsl:with-param name="langId" select="$langId"/>
                                                </xsl:apply-templates>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="title">
                                        <xsl:choose>
                                            <xsl:when test="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString">
                                                <xsl:apply-templates mode="localised" select="gmd:MD_BrowseGraphic/gmd:fileDescription">
                                                    <xsl:with-param name="langId" select="$langId"/>
                                                </xsl:apply-templates>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates mode="element" select=".">
                                    <xsl:with-param name="schema" select="$schema" />
                                    <xsl:with-param name="edit" select="false()" />
                                    <xsl:with-param name="flat" select="$currTab='simple'" />
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:apply-templates>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>



    <!--
        =====================================================================
    -->
    <!-- these elements should be geographicaly displayed -->
    <!--
        =====================================================================
    -->
    <xsl:template mode="iso19139" match="gmd:EX_BoundingPolygon" priority="20">
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:apply-templates mode="iso19139" select="gmd:extentTypeCode">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
        </xsl:apply-templates>


        <xsl:apply-templates mode="iso19139" select="gmd:polygon">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template mode="iso19139" match="gmd:polygon"
        priority="20">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="targetId" select="geonet:element/@ref"/>
        <xsl:variable name="geometry">
            <xsl:apply-templates mode="editXMLElement"/>
        </xsl:variable>

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="content">
                <input type="hidden" id="_X{$targetId}" name="_X{$targetId}" value="{string($geometry)}"/>
                <td class="padded" align="center" style="width:100%;">
                    <xsl:variable name="geom" select="util:gmlToWKT($geometry)"/>
                    <xsl:call-template name="showMap">
                        <xsl:with-param name="edit" select="$edit" />
                        <xsl:with-param name="coords" select="$geom"/>
                        <xsl:with-param name="targetPolygon" select="$targetId"/>
                    </xsl:call-template>
                </td>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- =====================================================================  -->
    <!-- some gco: elements -->
    <!-- =====================================================================  -->

    <!--
        Create widget to handle editing of xsd:duration elements.

        Format: PnYnMnDTnHnMnS

        *  P indicates the period (required)
        * nY indicates the number of years
        * nM indicates the number of months
        * nD indicates the number of days
        * T indicates the start of a time section (required if you are going to specify hours, minutes, or seconds)
        * nH indicates the number of hours
        * nM indicates the number of minutes
        * nS indicates the number of seconds
    -->
    <xsl:template mode="iso19139" match="gts:TM_PeriodDuration" priority="100">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <!--Set default value -->
        <xsl:variable name="p">
            <xsl:choose>
                <xsl:when test=".=''">P0Y0M0DT0H0M0S</xsl:when>
                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Extract fragment -->
        <xsl:variable name="NEG">
            <xsl:choose>
                <xsl:when test="starts-with($p, '-')">true</xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="Y" select="substring-before(substring-after($p, 'P'), 'Y')"/>
        <xsl:variable name="M" select="substring-before(substring-after($p, 'Y'), 'M')"/>
        <xsl:variable name="D" select="substring-before(substring-after($p, 'M'), 'DT')"/>
        <xsl:variable name="H" select="substring-before(substring-after($p, 'DT'), 'H')"/>
        <xsl:variable name="MI" select="substring-before(substring-after($p, 'H'), 'M')"/>
        <xsl:variable name="S" select="substring-before(substring-after(substring-after($p,'M' ),'M' ), 'S')"/>

        <xsl:variable name="text">
            <xsl:choose>
                <xsl:when test="$edit=true()">
                    <xsl:variable name="ref" select="geonet:element/@ref"/>

                    <input type="checkbox" id="N{$ref}" onchange="buildDuration('{$ref}');">
                        <xsl:if test="$NEG!=''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                    </input>
                    <label for="N{$ref}"><xsl:value-of select="/root/gui/strings/durationSign"/></label><br/>
                    <xsl:value-of select="/root/gui/strings/durationNbYears"/><input type="text" id="Y{$ref}" value="{substring-before(substring-after($p, 'P'), 'Y')}" size="4" onchange="buildDuration('{$ref}');" onkeyup="validateNumber(this,true,true);"/>-
                    <xsl:value-of select="/root/gui/strings/durationNbMonths"/><input type="text" id="M{$ref}" value="{substring-before(substring-after($p, 'Y'), 'M')}" size="4" onchange="buildDuration('{$ref}');" onkeyup="validateNumber(this,true,true);"/>-
                    <xsl:value-of select="/root/gui/strings/durationNbDays"/><input type="text" id="D{$ref}" value="{substring-before(substring-after($p, 'M'), 'DT')}" size="4" onchange="buildDuration('{$ref}');" onkeyup="validateNumber(this,true,true);"/><br/>
                    <xsl:value-of select="/root/gui/strings/durationNbHours"/><input type="text" id="H{$ref}" value="{substring-before(substring-after($p, 'DT'), 'H')}" size="4" onchange="buildDuration('{$ref}');" onkeyup="validateNumber(this,true,true);"/>-
                    <xsl:value-of select="/root/gui/strings/durationNbMinutes"/><input type="text" id="MI{$ref}" value="{substring-before(substring-after($p, 'H'), 'M')}" size="4" onchange="buildDuration('{$ref}');" onkeyup="validateNumber(this,true,true);"/>-
                    <xsl:value-of select="/root/gui/strings/durationNbSeconds"/><input type="text" id="S{$ref}" value="{substring-before(substring-after(substring-after($p,'M' ),'M' ), 'S')}" size="4" onchange="buildDuration('{$ref}');" onkeyup="validateNumber(this,true,false);"/><br/>
                    <input type="hidden" name="_{$ref}" id="_{$ref}" value="{$p}" size="20"/><br/>

                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$NEG!=''">-</xsl:if><xsl:text> </xsl:text>
                    <xsl:value-of select="$Y"/><xsl:text> </xsl:text><xsl:value-of select="/root/gui/strings/durationYears"/><xsl:text>  </xsl:text>
                    <xsl:value-of select="$M"/><xsl:text> </xsl:text><xsl:value-of select="/root/gui/strings/durationMonths"/><xsl:text>  </xsl:text>
                    <xsl:value-of select="$D"/><xsl:text> </xsl:text><xsl:value-of select="/root/gui/strings/durationDays"/><xsl:text> / </xsl:text>
                    <xsl:value-of select="$H"/><xsl:text> </xsl:text><xsl:value-of select="/root/gui/strings/durationHours"/><xsl:text>  </xsl:text>
                    <xsl:value-of select="$MI"/><xsl:text> </xsl:text><xsl:value-of select="/root/gui/strings/durationMinutes"/><xsl:text>  </xsl:text>
                    <xsl:value-of select="$S"/><xsl:text> </xsl:text><xsl:value-of select="/root/gui/strings/durationSeconds"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="text"   select="$text"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- For all boolean elements display a select box.
    Default selection labels are true/false and values are 0/1
    If needed, customization of label for could be done using localized
    files. Eg.
    <boolean value="1" context="gmd:extentTypeCode">Include</boolean>
    -->
    <xsl:template mode="iso19139"
        match="gmd:*[gco:Boolean]|srv:*[gco:Boolean]" priority="100">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="langId">
            <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/gui/language" />
                <xsl:with-param name="md"
                    select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="iso19139Boolean">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="langId" select="$langId" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="iso19139Boolean">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="langId"/>

        <xsl:variable name="value" select="string(gco:Boolean)"/>
        <xsl:variable name="nodeName" select="name(.)"/>
        <xsl:variable name="context">
            <xsl:choose>
                <xsl:when test="count(/root/gui/strings/boolean[@context=$nodeName])>0">
                    <xsl:value-of select="name(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:variable name="text">

                    <xsl:variable name="ref" select="gco:Boolean/geonet:element/@ref"/>


                    <select class="md" name="_{$ref}" id="_{$ref}">
                        <xsl:if test="$value=''">
                            <option value=""/>
                        </xsl:if>
                        <xsl:for-each select="/root/gui/strings/boolean[@value and @context=$context]">
                            <xsl:variable name="thisVal" select="string()"/>
                            <xsl:variable name="alt">
                                <xsl:choose>
                                    <xsl:when test="$value=false()">0</xsl:when>
                                    <xsl:when test="$value=true()">1</xsl:when>
                                    <xsl:when test="$value=1">true</xsl:when>
                                    <xsl:otherwise>false</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>

                            <xsl:if test="not(preceding-sibling::boolean[$thisVal=string() and @context=$context])">
                              <option>
                                  <xsl:if test="@value=$value or @value=$alt">
                                      <xsl:attribute name="selected"/>
                                  </xsl:if>
                                  <xsl:attribute name="value"><xsl:value-of select="string(@value)"/></xsl:attribute>
                                  <xsl:value-of select="string(.)"/>
                              </option>
                            </xsl:if>
                        </xsl:for-each>
                    </select>
                </xsl:variable>
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="$edit"/>
                    <xsl:with-param name="text"   select="$text"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="$edit"/>
                    <xsl:with-param name="text"   select="/root/gui/strings/boolean[string(@value)=$value and @context=$context]"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template mode="iso19139"
        match="gmd:*[gco:Date|gco:DateTime|
                        gco:Angle|gco:RecordType]|
                srv:*[gco:Date|gco:DateTime|
                        gco:Angle|gco:RecordType]">
        <xsl:param name="schema" />
        <xsl:param name="edit" />


        <xsl:variable name="langId">
            <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/gui/language" />
                <xsl:with-param name="md"
                    select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="langId" select="$langId" />
        </xsl:call-template>
    </xsl:template>


    <!-- Use this template for numeric datatypes.
    User editing is validated on the editor. If not valid,
    form input will be highlighted (red).
    -->
    <xsl:template mode="iso19139"
        match="gmd:*[gco:Integer|gco:Decimal|gco:Real|gco:Length|gco:Measure|
                        gco:Distance|gco:Scale]|
                srv:*[gco:Integer|gco:Decimal|gco:Real|gco:Length|gco:Measure|
                        gco:Distance|gco:Scale]">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <!-- Define validator according to node context. -->
        <xsl:variable name="validator">
        <xsl:choose>
            <xsl:when test="
                (name(parent::node())='gmd:EX_VerticalExtent' and (name(.)='gmd:minimumValue' or name(.)='gmd:maximumValue')) or
                name(.)='gmd:denominator'
                ">
                <xsl:value-of select="'validateNumber(this, false);'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'validateNumber(this, true)'"/>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>

        <xsl:variable name="langId">
            <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/gui/language" />
                <xsl:with-param name="md"
                    select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="validator" select="$validator" />
        </xsl:call-template>
    </xsl:template>



    <!-- All elements having gco:CharacterString or gmd:PT_FreeText elements
    have to display multilingual editor widget. Even if default language
    is set, an element could have gmd:PT_FreeText and no gco:CharacterString
    (ie. no value for default metadata language) .
    -->
    <xsl:template mode="iso19139"
        match="gmd:*[gco:CharacterString or gmd:PT_FreeText]|
                srv:*[gco:CharacterString or gmd:PT_FreeText]|
                    gco:aName[gco:CharacterString]">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <!-- Define a rows variable if form element as
        to be a textarea instead of a simple text input.
        This parameter define the number of rows of the textarea. -->
        <xsl:variable name="rows">
            <xsl:choose>
                <xsl:when test="name(.)='gmd:abstract'">10</xsl:when>
                <xsl:when test="name(.)='gmd:supplementalInformation'
                    or name(.)='gmd:purpose'
                    or name(.)='gmd:statement'">5</xsl:when>
                <xsl:when test="name(.)='gmd:description'
                    or name(.)='gmd:specificUsage'
                    or name(.)='gmd:explanation'
                    ">3</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <!-- Use this template for mandatory text fields.
            User editing is validated on the editor. If not valid,
            form input will be highlighted (red).
        -->
        <xsl:variable name="validator">
            <xsl:choose>
                <xsl:when test="name(.)='gmd:title'
                    or name(.)='gmd:abstract'
                    or (name(.)='gmd:description' and name(..)='gmd:LI_ProcessStep')
                    or name(.)='gmd:specificUsage'
                    or name(.)='gmd:code'
                    or name(.)='gmd:explanation'
                    or name(.)='gmd:definition'">
                    <xsl:value-of select="'validateNonEmpty(this)'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="localizedCharStringField">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="rows" select="$rows" />
            <xsl:with-param name="validator" select="$validator" />
        </xsl:call-template>
    </xsl:template>


    <!-- Use this template to define which elements
        are not multilingual.
        If an element is not multilingual and require
        a specific widget (eg. protocol list), create
        a new template for this new element.
    -->
    <xsl:template mode="iso19139"
        match="
        gmd:identifier[gco:CharacterString]|
        gmd:metadataStandardName[gco:CharacterString]|
        gmd:metadataStandardVersion[gco:CharacterString]|
        gmd:hierarchyLevelName[gco:CharacterString]|
        gmd:dataSetURI[gco:CharacterString]|
        gmd:postalCode[gco:CharacterString]|
        gmd:city[gco:CharacterString]|
        gmd:administrativeArea[gco:CharacterString]|
        gmd:voice[gco:CharacterString]|
        gmd:facsimile[gco:CharacterString]|
        gmd:MD_ScopeDescription/gmd:dataset[gco:CharacterString]|
        gmd:MD_ScopeDescription/gmd:other[gco:CharacterString]|
        gmd:hoursOfService[gco:CharacterString]|
        gmd:applicationProfile[gco:CharacterString]|
        gmd:CI_Series/gmd:page[gco:CharacterString]|
        gmd:MD_BrowseGraphic/gmd:fileName[gco:CharacterString]|
        gmd:MD_BrowseGraphic/gmd:fileType[gco:CharacterString]|
        gmd:unitsOfDistribution[gco:CharacterString]|
        gmd:amendmentNumber[gco:CharacterString]|
        gmd:specification[gco:CharacterString]|
        gmd:fileDecompressionTechnique[gco:CharacterString]|
        gmd:turnaround[gco:CharacterString]|
        gmd:fees[gco:CharacterString]|
        gmd:userDeterminedLimitations[gco:CharacterString]|
        gmd:RS_Identifier/gmd:codeSpace[gco:CharacterString]|
        gmd:RS_Identifier/gmd:version[gco:CharacterString]|
        gmd:edition[gco:CharacterString]|
        gmd:ISBN[gco:CharacterString]|
        gmd:ISBN[gco:CharacterString]|
        gmd:measureDescription[gco:CharacterString]|
        gmd:evaluationMethodDescription[gco:CharacterString]|
        gmd:errorStatistic[gco:CharacterString]|
        gmd:schemaAscii[gco:CharacterString]|
        gmd:softwareDevelopmentFileFormat[gco:CharacterString]|
        gmd:MD_ExtendedElementInformation/gmd:shortName[gco:CharacterString]|
        gmd:MD_ExtendedElementInformation/gmd:condition[gco:CharacterString]|
        gmd:MD_ExtendedElementInformation/gmd:maximumOccurence[gco:CharacterString]|
        gmd:MD_ExtendedElementInformation/gmd:domainValue[gco:CharacterString]|
        gmd:densityUnits[gco:CharacterString]|
        gmd:MD_RangeDimension/gmd:descriptor[gco:CharacterString]|
        gmd:classificationSystem[gco:CharacterString]|
        gmd:checkPointDescription[gco:CharacterString]|
        gmd:transformationDimensionDescription[gco:CharacterString]|
        gmd:orientationParameterDescription[gco:CharacterString]|
        srv:SV_OperationChainMetadata/srv:name[gco:CharacterString]|
        srv:SV_OperationMetadata/srv:invocationName[gco:CharacterString]|
        srv:serviceTypeVersion[gco:CharacterString]
        "
        priority="100">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
    </xsl:template>


    <!-- Use this template to define which elements
        are not multilingual and mandatory-->
    <xsl:template mode="iso19139"
        match="
            gmd:MD_ExtendedElementInformation/gmd:name[gco:CharacterString]|
            gmd:MD_ExtendedElementInformation/gmd:rule[gco:CharacterString]|
            gmd:schemaLanguage[gco:CharacterString]|
            gmd:constraintLanguage[gco:CharacterString]|
            gmd:MD_Format/gmd:name[gco:CharacterString]|
            gmd:MD_Format/gmd:version[gco:CharacterString]|
            srv:SV_Parameter/srv:optionality[gco:CharacterString]|
            srv:SV_Parameter/srv:valueType[gco:CharacterString]|
            srv:SV_OperationMetadata/srv:operationName[gco:CharacterString]|
            srv:SV_CoupledResource/srv:identifier[gco:CharacterString]|
            srv:SV_CoupledResource/srv:operationName[gco:CharacterString]
            "
            priority="100">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:call-template name="iso19139String">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit"   select="$edit"/>
        <xsl:with-param name="validator" select="'validateNonEmpty(this)'" />
    </xsl:call-template>
    </xsl:template>




    <!-- Multilingual editor widget is composed of input box
    with a list of languages. Metadata languages are :
     * the main    language (gmd:language) and
     * all languages defined in gmd:locale. -->
    <xsl:template name="localizedCharStringField" >
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:param name="rows" select="1" />
        <xsl:param name="validator" />

        <xsl:variable name="langId">
            <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/gui/language" />
                <xsl:with-param name="md"
                    select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="widget">
            <xsl:if test="$edit='true'">
                <xsl:variable name="tmpFreeText">
                    <xsl:call-template name="PT_FreeText_Tree" />
                </xsl:variable>

                <xsl:variable name="ptFreeTextTree" select="$tmpFreeText" />

                <xsl:variable name="mainLang"
                    select="string(/root/*/gmd:language/gco:CharacterString)" />
                <xsl:variable name="mainLangId"
                    select="concat('#',/root/*/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue=$mainLang]/@id)" />

                <table><tr><td>
                <!-- Match gco:CharacterString element which is in default language or
                process a PT_FreeText with a reference to the main metadata language. -->
                <xsl:choose>
                    <xsl:when test="gco:*">
                        <xsl:for-each select="gco:*">
                            <xsl:call-template name="getElementText">
                                <xsl:with-param name="schema" select="$schema" />
                                <xsl:with-param name="edit" select="'true'" />
                                <xsl:with-param name="visible" select="'true'" />
                                <xsl:with-param name="rows" select="$rows" />
                                <xsl:with-param name="validator" select="$validator" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="gco:*">
                        <xsl:for-each select="gco:*">
                            <xsl:call-template name="getElementText">
                                <xsl:with-param name="schema" select="$schema" />
                                <xsl:with-param name="edit" select="'true'" />
                                <xsl:with-param name="rows" select="$rows" />
                                <xsl:with-param name="visible" select="'true'" />
                                <xsl:with-param name="validator" select="$validator" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$mainLangId]">
                        <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$mainLangId]">
                            <xsl:call-template name="getElementText">
                                <xsl:with-param name="schema" select="$schema" />
                                <xsl:with-param name="edit" select="'true'" />
                                <xsl:with-param name="visible" select="'true'" />
                                <xsl:with-param name="rows" select="$rows" />
                                <xsl:with-param name="validator" select="$validator" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale=$mainLangId]">
                            <xsl:call-template name="getElementText">
                                <xsl:with-param name="schema" select="$schema" />
                                <xsl:with-param name="edit" select="'true'" />
                                <xsl:with-param name="visible" select="'true'" />
                                <xsl:with-param name="rows" select="$rows" />
                                <xsl:with-param name="validator" select="$validator" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                    <xsl:call-template name="getElementText">
                        <xsl:with-param name="schema" select="$schema" />
                        <xsl:with-param name="edit" select="'true'" />
                        <xsl:with-param name="visible" select="'false'" />
                        <xsl:with-param name="rows" select="$rows" />
                        <xsl:with-param name="validator" select="$validator" />
                    </xsl:call-template>
                </xsl:for-each>
                </td>
                <td align="left">&#160;
                    <select class="md lang_selector" name="localization" onchange="enableLocalInput(this)" SELECTED="true">
                        <xsl:choose>
                            <xsl:when test="gco:*">
                                <option value="_{gco:*/geonet:element/@ref}">
                                    <xsl:choose>
                                            <xsl:when test="normalize-space($mainLang)=''">
                                                    <xsl:value-of select="/root/gui/strings/mainMetadataLanguageNotSet"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                    <xsl:value-of
                                                            select="/root/gui/isoLang/record[code=$mainLang]/label/*[name(.)=/root/gui/language]" />
                                            </xsl:otherwise>
                                    </xsl:choose>
                                </option>
                                <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                    <option value="_{geonet:element/@ref}">
                                        <xsl:value-of select="@language" />
                                    </option>
                                    <xsl:value-of select="name(.)" />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString">
                                    <option value="_{geonet:element/@ref}">
                                        <xsl:value-of select="@language" />
                                    </option>
                                    <xsl:value-of select="name(.)" />
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </select>

                </td></tr></table>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="langId" select="$langId" />
            <xsl:with-param name="widget" select="$widget" />
            <xsl:with-param name="rows" select="$rows" />
            <xsl:with-param name="validator" select="$validator" />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="PT_FreeText_Tree">
        <xsl:variable name="mainLang"
                select="string(/root/*/gmd:language/gco:CharacterString)" />
        <xsl:variable name="languages"
                select="/root/*/gmd:locale/gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue" />
        <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>

        <xsl:variable name="currentNode" select="node()" />
        <xsl:for-each select="$languages">
            <xsl:variable name="langId"
                    select="concat('&#35;',string(../../../@id))" />
            <xsl:variable name="code">
                <xsl:call-template name="getLangCode">
                        <xsl:with-param name="md"
                                select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                        <xsl:with-param name="langId" select="substring($langId,2)" />
                </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="ref" select="$currentNode/../geonet:element/@ref" />
            <xsl:variable name="guiLang" select="/root/gui/language" />
            <xsl:variable name="language"
                    select="/root/gui/isoLang/record[code=$code]/label/*[name(.)=$guiLang]" />
            <gmd:PT_FreeText>
                <!-- Propagate xlink attribute to the var which contains translation
                in order to turn off editing. -->
                <xsl:if test="$xlinkedAncestor = 'true'">
                    <xsl:attribute name="xlink:href"></xsl:attribute>
                </xsl:if>
                <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$langId}"
                            code="{$code}" language="{$language}">
                        <xsl:value-of
                                select="$currentNode//gmd:LocalisedCharacterString[@locale=$langId]" />
                        <xsl:choose>
                            <xsl:when
                                    test="$currentNode//gmd:LocalisedCharacterString[@locale=$langId]">
                                    <geonet:element
                                            ref="{$currentNode//gmd:LocalisedCharacterString[@locale=$langId]/geonet:element/@ref}" />
                            </xsl:when>
                            <xsl:otherwise>
                                    <geonet:element ref="lang_{substring($langId,2)}_{$ref}" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </gmd:LocalisedCharacterString>
                    <geonet:element ref="" />
                </gmd:textGroup>
                <geonet:element ref="" />
            </gmd:PT_FreeText>
        </xsl:for-each>
    </xsl:template>

    <!--
        ====================================================================
    -->

    <!-- ===================================================================== -->
    <!--     Open a ModabBox to select the dataset identifier selection        -->
    <!-- ===================================================================== -->

    <xsl:template mode="iso19139" match="srv:operatesOn">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:variable name="text">

            <xsl:choose>
                <xsl:when test="$edit=true()">
                    <xsl:variable name="ref" select="geonet:element/@ref"/>
                    <input type="text" onfocus="javascript:displaySearchBox('dataset','{/root/gui/strings/associateDataset}','_{$ref}_uuidref');" name="_{$ref}_uuidref" id="_{$ref}_uuidref" value="{./@uuidref}" size="20"/>
                    <img src="../../images/gdict.png" alt="{/root/gui/strings/associateDataset}" title="{/root/gui/strings/associateDataset}"
                        onclick="javascript:displaySearchBox('dataset','{/root/gui/strings/associateDataset}','_{$ref}_uuidref');"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="metadataTitle">
                        <xsl:call-template name="getMetadataTitle">
                            <xsl:with-param name="uuid" select="@uuidref"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>

                    <a href="metadata.show?uuid={@uuidref}">
                        <xsl:value-of select="$metadataTitle"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="text"   select="$text"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ============================================================================= -->
    <!--   Open a ModabBox to select the dataset identifier selection                  -->
    <!-- ============================================================================= -->
    <xsl:template mode="iso19139" match="srv:coupledResource/srv:SV_CoupledResource/srv:identifier" priority="200">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:variable name="text">
                    <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
                    <!--Not used : Modal box UI for coupledResources <input type="text" class="md" onfocus="javascript:displaySearchBox('dataset','{/root/gui/strings/associateDataset}','_{$ref}');" name="_{$ref}" id="_{$ref}" value="{gco:CharacterString/text()}" size="50"/>-->
                    <!-- Display list of related resources to which the current service metadata operatesOn.
                        Ie. User should define related metadata record using operatesOn elements and then if
                        needed, set a coupledResource to create a link to the data itself (using layer name/feature type/
                        coverage name as described in capabilities documents). -->
                    <input type="text" class="md" name="_{$ref}" id="_{$ref}" onchange="validateNonEmpty(this)" value="{gco:CharacterString/text()}" size="50"/>
                    <xsl:choose>
                        <xsl:when test="count(//srv:operatesOn[@uuidref!=''])=0">
                            <xsl:value-of select="/root/gui/strings/noOperatesOn"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <select onchange="javascript:$('_{$ref}').value=this.options[this.selectedIndex].value;">
                                <option></option>
                                <xsl:for-each select="//srv:operatesOn[@uuidref!='']">
                                    <option value="{@uuidref}">
                                        <xsl:call-template name="getMetadataTitle">
                                            <xsl:with-param name="uuid" select="@uuidref"/>
                                        </xsl:call-template>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="true()"/>
                    <xsl:with-param name="text"   select="$text"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema"  select="$schema"/>
                    <xsl:with-param name="text"><a href="metadata.show?uuid={.}"><xsl:value-of select="string(.)"/></a></xsl:with-param>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--
        ====================================================================
    -->
    <!--
        Display XLink information in readOnly mode TODO : Remove this link
        because it should not be displayed to end-user.
    -->
    <xsl:template mode="iso19139" match="@xlink:title|@xlink:show|@xlink:role|@xlink:href" />
    <!--<xsl:template mode="iso19139" match="@xlink:href">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="title"></xsl:variable>
        <xsl:variable name="helpLink" />
        <xsl:variable name="text">

            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="." />
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="../@xlink:title">
                        <xsl:value-of select="../@xlink:title" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </xsl:variable>
        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="helpLink" select="$helpLink" />
            <xsl:with-param name="text" select="$text" />
        </xsl:apply-templates>
        </xsl:template>-->

    <!--
        ====================================================================
    -->

    <xsl:template name="iso19139String">
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:param name="rows" select="1" />
        <xsl:param name="cols" select="50" />
        <xsl:param name="langId" />
        <xsl:param name="widget" />
        <xsl:param name="validator" />

        <xsl:variable name="title">
            <xsl:call-template name="getTitle">
                <xsl:with-param name="name" select="name(.)" />
                <xsl:with-param name="schema" select="$schema" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="helpLink">
            <xsl:call-template name="getHelpLink">
                <xsl:with-param name="name" select="name(.)" />
                <xsl:with-param name="schema" select="$schema" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="text">
            <xsl:choose>
                <xsl:when test="not($edit=true() and $widget)">
                    <!-- Having only gmd:PT_FreeText is allowed by schema.
                    So using a PT_FreeText to set a translation even
                    in main metadata language could be valid.-->
                    <xsl:choose>
                        <xsl:when test="not(gco:*)">
                            <xsl:for-each select="gmd:PT_FreeText">
                                <xsl:call-template name="getElementText">
                                    <xsl:with-param name="edit" select="$edit" />
                                    <xsl:with-param name="schema" select="$schema" />
                                    <xsl:with-param name="visible" select="'true'" />
                                    <xsl:with-param name="rows" select="$rows" />
                                    <xsl:with-param name="cols" select="$cols" />
                                    <xsl:with-param name="langId" select="$langId" />
                                    <xsl:with-param name="validator" select="$validator" />
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="gco:*">
                                <xsl:call-template name="getElementText">
                                    <xsl:with-param name="edit" select="$edit" />
                                    <xsl:with-param name="schema" select="$schema" />
                                    <xsl:with-param name="rows" select="$rows" />
                                    <xsl:with-param name="cols" select="$cols" />
                                    <xsl:with-param name="visible" select="'true'" />
                                    <xsl:with-param name="langId" select="$langId" />
                                    <xsl:with-param name="validator" select="$validator" />
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$widget" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="attrs">
            <xsl:for-each select="gco:*/@*">
                <xsl:value-of select="name(.)" />
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="normalize-space($attrs)!=''">
                <xsl:apply-templates mode="complexElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                    <xsl:with-param name="title" select="$title" />
                    <xsl:with-param name="helpLink" select="$helpLink" />
                    <xsl:with-param name="content">

                        <!-- existing attributes -->
                        <xsl:for-each select="gco:*/@*">
                            <xsl:apply-templates mode="simpleElement"
                                select=".">
                                <xsl:with-param name="schema" select="$schema" />
                                <xsl:with-param name="edit" select="$edit" />
                            </xsl:apply-templates>
                        </xsl:for-each>

                        <!-- existing content -->
                        <xsl:apply-templates mode="simpleElement"
                            select=".">
                            <xsl:with-param name="schema" select="$schema" />
                            <xsl:with-param name="edit" select="$edit" />
                            <xsl:with-param name="title" select="$title" />
                            <xsl:with-param name="helpLink" select="$helpLink" />
                            <xsl:with-param name="text" select="$text" />
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                    <xsl:with-param name="title" select="$title" />
                    <xsl:with-param name="helpLink" select="$helpLink" />
                    <xsl:with-param name="text" select="$text" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!--
        ====================================================================
    -->

    <xsl:template mode="iso19139" match="gco:ScopedName|gco:LocalName">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="text">
            <xsl:call-template name="getElementText">
                <xsl:with-param name="edit" select="$edit" />
                <xsl:with-param name="visible" select="'true'" />
                <xsl:with-param name="schema" select="$schema" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="title" select="'Name'" />
            <xsl:with-param name="text" select="$text" />
        </xsl:apply-templates>
    </xsl:template>

    <!--
        =================================================================
    -->
    <!--
        some elements that have both attributes and content
    -->
    <!--
        =================================================================
    -->

    <xsl:template mode="iso19139"
        match="gml:coordinates|gml:identifier|gml:axisDirection|gml:descriptionReference">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="content">

                <!-- existing attributes -->
                <xsl:apply-templates mode="simpleElement"
                    select="@*">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                </xsl:apply-templates>

                <!-- existing content -->
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                </xsl:apply-templates>

            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>


    <!-- Enumerations in the schema -->
    <xsl:template mode="iso19139" match="gmd:country" priority="1">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="qname" select="name(.)"/>
        <xsl:variable name="value" >
            <xsl:choose>
                <xsl:when test="gmd:Country/@codeListValue">
                    <xsl:value-of select="gmd:Country/@codeListValue"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="gco:CharacterString/."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="text">
                <xsl:choose>

                    <xsl:when test="$edit=true()">
                    <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>
                    <xsl:variable name="geonetRef">
                        <xsl:choose>
                            <xsl:when test="gmd:Country/geonet:attribute[@name = 'codeListValue']">
                                <xsl:value-of select="gmd:Country/geonet:element/@ref"/><xsl:text>_codeListValue</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="gco:CharacterString/geonet:element/@ref"></xsl:value-of>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                        <!-- codelist in edit mode -->
                        <select class="md" name="_{$geonetRef}" size="1">
                            <xsl:if test="$xlinkedAncestor = 'true'">
                                <xsl:attribute name="disabled">true</xsl:attribute>
                            </xsl:if>
                            <option name="" />
                            <xsl:for-each select="/root/gui/countries/country">
                                <xsl:sort select="text()"/>
                                <option>
                                    <xsl:if test="@iso2=$value">
                                        <xsl:attribute name="selected" />
                                    </xsl:if>
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="@iso2" />
                                    </xsl:attribute>
                                    <xsl:value-of select="text()" />
                                </option>
                            </xsl:for-each>
                        </select>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="/root/gui/countries/country[@iso2=$value]/text()" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Enumerations in the schema -->
    <xsl:template mode="iso19139" match="gmd:MD_TopicCategoryCode|srv:SV_ParameterDirection|gmd:MD_PixelOrientationCode">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="qname" select="name(.)"/>
        <xsl:variable name="value" select="."/>

        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="text">
                <xsl:choose>
                    <xsl:when test="$edit=true()">
                        <!-- codelist in edit mode -->
                        <select class="md" name="_{geonet:element/@ref}"
                            size="1">
                            <option name="" />
                            <xsl:for-each select="/root/gui/*[name(.)='iso19139']/codelist[@name=$qname]/entry">
                                <xsl:sort select="label"/>
                                <option>
                                    <xsl:if test="code=$value">
                                        <xsl:attribute name="selected" />
                                    </xsl:if>
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="code" />
                                    </xsl:attribute>
                                    <xsl:value-of select="label" />
                                </option>
                            </xsl:for-each>
                        </select>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="/root/gui/*[name(.)='iso19139']/codelist[@name=$qname]/entry[code=$value]/label" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:apply-templates>
        </xsl:template>

    <!--
        =================================================================
    -->
    <!-- codelists -->
    <!--
        =================================================================
    -->

    <xsl:template mode="iso19139" match="*[*/@codeList]">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:call-template name="iso19139Codelist">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
        </xsl:call-template>
    </xsl:template>

    <!--
        =============================================================================
    -->

    <xsl:template name="iso19139Codelist">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="text">
                <xsl:apply-templates mode="iso19139GetAttributeText"
                    select="*/@codeListValue">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                </xsl:apply-templates>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139" match="gmd:LanguageCode">
        <xsl:param name="edit"/>

        <xsl:variable name="value" select="@codeListValue" />
        <xsl:variable name="lang" select="/root/gui/language" />
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <select class="md" name="_{geonet:element/@ref}_codeListValue"
                    size="1">
                    <option name="" />

                    <xsl:for-each select="/root/gui/isoLang/record">
                        <option value="{code}">
                            <xsl:if test="code = $value">
                                <xsl:attribute name="selected" />
                            </xsl:if>
                            <xsl:value-of select="label/child::*[name() = $lang]" />
                        </option>
                    </xsl:for-each>
                </select>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of
                    select="/root/gui/isoLang/record[code=$value]/label/child::*[name() = $lang]" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="iso19139GetAttributeText" match="@*">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="name" select="local-name(..)" />
        <xsl:variable name="qname" select="name(..)" />
        <xsl:variable name="value" select="../@codeListValue" />

        <xsl:choose>
            <xsl:when test="$qname='gmd:LanguageCode'">
                <xsl:apply-templates mode="iso19139" select="..">
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!--
                    Get codelist from profil first and use use default one if not
                    available.
                -->
                <xsl:variable name="codelistProfil">
                    <xsl:choose>
                        <xsl:when test="starts-with($schema,'iso19139.')">
                            <xsl:copy-of
                                select="/root/gui/*[name(.)=$schema]/codelist[@name = $qname]/*" />
                        </xsl:when>
                        <xsl:otherwise />
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="codelistCore">
                    <xsl:choose>
                        <xsl:when test="normalize-space($codelistProfil)!=''">
                            <xsl:copy-of select="$codelistProfil" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of
                                select="/root/gui/*[name(.)='iso19139']/codelist[@name = $qname]/*" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="codelist" select="exslt:node-set($codelistCore)" />
                <!-- Turn off editing on child elements of an xlinked ancestor -->
                <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>
                <xsl:choose>
                    <xsl:when test="$edit=true()">
                        <!-- codelist in edit mode -->
                        <select class="md" name="_{../geonet:element/@ref}_{name(.)}"
                            size="1">
                            <xsl:if test="$xlinkedAncestor = 'true'">
                                <xsl:attribute name="disabled">disabled</xsl:attribute>
                            </xsl:if>
                            <option name="" />
                            <xsl:for-each select="$codelist/entry">
                                <xsl:sort select="label"/>
                                <option>
                                    <xsl:if test="code=$value">
                                        <xsl:attribute name="selected" />
                                    </xsl:if>
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="code" />
                                    </xsl:attribute>
                                    <xsl:value-of select="label" />
                                </option>
                            </xsl:for-each>
                        </select>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- codelist in view mode -->
                        <xsl:value-of select="$codelist/entry[code = $value]/label" />
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!--
        =============================================================================
    -->
    <!--
        make the following fields always not editable: dateStamp
        metadataStandardName metadataStandardVersion fileIdentifier
        characterSet PT_Locale : id attribute is generated from iso3code (used
        for multilingual metadata).
    -->
    <!--
        =============================================================================
    -->
    <!-- Elements -->
    <xsl:template mode="iso19139"
        match="gmd:dateStamp|gmd:metadataStandardName|gmd:metadataStandardVersion|gmd:fileIdentifier"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="false()" />
        </xsl:call-template>
    </xsl:template>

    <!-- Attributes -->
    <xsl:template mode="iso19139" match="gmd:PT_Locale/@id"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="false()" />
        </xsl:apply-templates>
    </xsl:template>

    <!-- Codelists -->
    <xsl:template mode="iso19139"
        match="//gmd:MD_Metadata/gmd:characterSet|//*[@gco:isoType='gmd:MD_Metadata']/gmd:characterSet"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:call-template name="iso19139Codelist">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="false()" />
        </xsl:call-template>
    </xsl:template>

    <!--
        =============================================================================
    -->
    <!-- electronicMailAddress -->
    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139" match="gmd:electronicMailAddress"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:call-template name="iso19139String">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="text">
                        <a href="mailto:{string(.)}">
                            <xsl:value-of select="string(.)" />
                        </a>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        =============================================================================
    -->
    <!-- descriptiveKeywords -->
    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139" match="gmd:descriptiveKeywords">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="text">
                        <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                            <xsl:if test="position() &gt; 1">
                                ,
                            </xsl:if>

                            <xsl:variable name="langId">
                                <xsl:call-template name="getLangId">
                                    <xsl:with-param name="langGui" select="/root/gui/language" />
                                    <xsl:with-param name="md"
                                        select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:apply-templates mode="localised" select=".">
                                <xsl:with-param name="langId" select="$langId"></xsl:with-param>
                            </xsl:apply-templates>

                        </xsl:for-each>
                        <xsl:if
                            test="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue!=''">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of
                                select="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue" />
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:text>.</xsl:text>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        =============================================================================
    -->
    <!--
        place keyword; only called in edit mode (see descriptiveKeywords
        template)
    -->
    <!--
        =============================================================================

        <xsl:template mode="iso19139"
        match="gmd:keyword[following-sibling::gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='place']">
        <xsl:param name="schema"/> <xsl:param name="edit"/> <xsl:variable
        name="text"> <xsl:variable name="ref"
        select="gco:CharacterString/geonet:element/@ref"/> <xsl:variable
        name="keyword" select="gco:CharacterString/text()"/> <input class="md"
        type="text" name="_{$ref}" value="{gco:CharacterString/text()}"
        size="50"/> <xsl:variable name="lang" select="/root/gui/language"/>

        <select name="place" size="1"
        onChange="document.mainForm._{$ref}.value=this.options[this.selectedIndex].text">
        <option value=""/> <xsl:for-each select="/root/gui/regions/record">
        <xsl:sort select="label/child::*[name() = $lang]" order="ascending"/>
        <option value="{id}"> <xsl:if test="string(label/child::*[name() =
        $lang])=$keyword"> <xsl:attribute name="selected"/> </xsl:if>
        <xsl:value-of select="label/child::*[name() = $lang]"/> </option>
        </xsl:for-each> </select> </xsl:variable> <xsl:apply-templates
        mode="simpleElement" select="."> <xsl:with-param name="schema"
        select="$schema"/> <xsl:with-param name="edit" select="true()"/>
        <xsl:with-param name="text" select="$text"/> </xsl:apply-templates>
        </xsl:template>
    -->
    <!--
        =============================================================================
    -->
    <!-- EX_GeographicBoundingBox -->
    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139" match="gmd:EX_GeographicBoundingBox[../../gmd:geographicElement/gmd:EX_BoundingPolygon]"
        priority="3">
        <!-- don't display bounding boxes when there is a bounding polygon. It's
             managed behind the scene by the server automatically-->
    </xsl:template>

    <xsl:template mode="iso19139" match="gmd:EX_GeographicBoundingBox"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:apply-templates mode="iso19139" select="gmd:extentTypeCode">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
        </xsl:apply-templates>

        <xsl:variable name="geoBox">
            <xsl:apply-templates mode="iso19139GeoBox"
                select=".">
                <xsl:with-param name="schema" select="$schema" />
                <xsl:with-param name="edit" select="$edit" />
            </xsl:apply-templates>
        </xsl:variable>

        <xsl:apply-templates mode="complexElement"
            select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="$edit" />
            <xsl:with-param name="content">
                <tr>
                    <td>
                        <xsl:copy-of select="$geoBox" />
                    </td>
                </tr>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139GeoBox" match="*">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:variable name="eltRef">
            <xsl:choose>
                <xsl:when test="$edit=true()">
                    <xsl:value-of select="geonet:element/@ref"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="wID">
            <xsl:choose>
                <xsl:when test=".//gmd:westBoundLongitude/gco:Decimal/geonet:element/@ref"><xsl:value-of select=".//gmd:westBoundLongitude/gco:Decimal/geonet:element/@ref"/></xsl:when>
                <xsl:otherwise>w<xsl:value-of select="$eltRef"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="eID">
            <xsl:choose>
                <xsl:when test="./gmd:eastBoundLongitude/gco:Decimal/geonet:element/@ref"><xsl:value-of select="./gmd:eastBoundLongitude/gco:Decimal/geonet:element/@ref"/></xsl:when>
                <xsl:otherwise>e<xsl:value-of select="$eltRef"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="nID">
            <xsl:choose>
                <xsl:when test="./gmd:northBoundLatitude/gco:Decimal/geonet:element/@ref"><xsl:value-of select="./gmd:northBoundLatitude/gco:Decimal/geonet:element/@ref"/></xsl:when>
                <xsl:otherwise>n<xsl:value-of select="$eltRef"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="sID">
            <xsl:choose>
                <xsl:when test="./gmd:southBoundLatitude/gco:Decimal/geonet:element/@ref"><xsl:value-of select="./gmd:southBoundLatitude/gco:Decimal/geonet:element/@ref"/></xsl:when>
                <xsl:otherwise>s<xsl:value-of select="$eltRef"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <input id="ch03_{$eltRef}" type="radio" name="proj_{$eltRef}" value="ch03" checked="checked" />
        <label for="ch03_{$eltRef}">CH03</label>
        <input id="wgs84_{$eltRef}" type="radio" name="proj_{$eltRef}" value="wgs84" />
        <label for="wgs84_{$eltRef}">WGS84</label>

        <table>
            <tr>
                <td />
                <div id="native_{$eltRef}" style="display:none"><xsl:value-of select="comment()"/></div>
                <td class="padded" align="center">
                    <xsl:apply-templates mode="iso19139VertElement"
                            select="gmd:northBoundLatitude/gco:Decimal">
                        <xsl:with-param name="schema" select="$schema" />
                        <xsl:with-param name="edit" select="$edit" />
                        <xsl:with-param name="name" select="'gmd:northBoundLatitude'" />
                        <xsl:with-param name="eltRef" select="$nID"/>
                    </xsl:apply-templates>
                </td>
                <td />
            </tr>
            <tr>
                <td class="padded" align="center">
                    <xsl:apply-templates mode="iso19139VertElement"
                            select="gmd:westBoundLongitude/gco:Decimal">
                        <xsl:with-param name="schema" select="$schema" />
                        <xsl:with-param name="edit" select="$edit" />
                        <xsl:with-param name="name" select="'gmd:westBoundLongitude'" />
                        <xsl:with-param name="eltRef" select="$wID"/>
                    </xsl:apply-templates>
                </td>


                <td class="padded">
                    <xsl:variable name="w" select="./gmd:westBoundLongitude/gco:Decimal"/>
                    <xsl:variable name="e" select="./gmd:eastBoundLongitude/gco:Decimal"/>
                    <xsl:variable name="n" select="./gmd:northBoundLatitude/gco:Decimal"/>
                    <xsl:variable name="s" select="./gmd:southBoundLatitude/gco:Decimal"/>

                    <xsl:variable name="geom" >
                        <xsl:value-of select="concat('Polygon((', $w, ' ', $s,',',$e,' ',$s,',',$e,' ',$n,',',$w,' ',$n,',',$w,' ',$s, '))')"/>
                    </xsl:variable>
                    <xsl:call-template name="showMap">
                        <xsl:with-param name="edit" select="$edit" />
                        <xsl:with-param name="coords" select="$geom"/>
                        <xsl:with-param name="watchedBbox" select="concat($wID, ',', $sID, ',', $eID, ',', $nID)"/>
                        <xsl:with-param name="eltRef" select="$eltRef"/>
                    </xsl:call-template>
                </td>

                <td class="padded" align="center">
                    <xsl:apply-templates mode="iso19139VertElement"
                            select="gmd:eastBoundLongitude/gco:Decimal">
                        <xsl:with-param name="schema" select="$schema" />
                        <xsl:with-param name="edit" select="$edit" />
                        <xsl:with-param name="name" select="'gmd:eastBoundLongitude'" />
                        <xsl:with-param name="eltRef" select="$eID"/>
                    </xsl:apply-templates>
                </td>
            </tr>
            <tr>
                <td />
                <td class="padded" align="center">
                    <xsl:apply-templates mode="iso19139VertElement"
                            select="gmd:southBoundLatitude/gco:Decimal">
                        <xsl:with-param name="schema" select="$schema" />
                        <xsl:with-param name="edit" select="$edit" />
                        <xsl:with-param name="name" select="'gmd:southBoundLatitude'" />
                        <xsl:with-param name="eltRef" select="$sID"/>
                    </xsl:apply-templates>
                </td>
                <td />
            </tr>
        </table>
    </xsl:template>

    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139VertElement" match="*">
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:param name="name" />
        <xsl:param name="eltRef" />

        <xsl:variable name="title">
            <xsl:call-template name="getTitle">
                <xsl:with-param name="schema" select="$schema" />
                <xsl:with-param name="name" select="$name" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="helpLink">
            <xsl:call-template name="getHelpLink">
                <xsl:with-param name="schema" select="$schema" />
                <xsl:with-param name="name" select="$name" />
            </xsl:call-template>
        </xsl:variable>
        <b>
            <xsl:choose>
                <xsl:when test="$helpLink!=''">
                    <span id="tip.{$helpLink}" style="cursor:help;">
                        <xsl:value-of select="$title" />
                        <xsl:call-template name="asterisk">
                            <xsl:with-param name="link" select="$helpLink" />
                            <xsl:with-param name="edit" select="$edit" />
                        </xsl:call-template>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$title" />
                </xsl:otherwise>
            </xsl:choose>
        </b>
        <br/>
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:call-template name="getElementText">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                    <xsl:with-param name="cols" select="10" />
                    <xsl:with-param name="visible" select="'true'" />
                    <xsl:with-param name="validator" select="'validateNumber(this, false)'" />
                    <xsl:with-param name="no_name" select="true()" />
                </xsl:call-template>
                <xsl:call-template name="getElementText">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="true()" />
                    <xsl:with-param name="visible" select="'true'" />
                    <xsl:with-param name="cols" select="10" />
                    <xsl:with-param name="input_type" select="'hidden'" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <input class="md" type="text" id="{$eltRef}" value="{text()}" readonly="readonly"/>
                <input class="md" type="hidden" id="_{$eltRef}" name="_{$eltRef}" value="{text()}" readonly="readonly"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!--
        =============================================================================
    -->
    <!--
        dateTime (format = %Y-%m-%dT%H:%M:00) usageDateTime
        plannedAvailableDateTime
    -->
    <!--
        =============================================================================
    -->

    <xsl:template mode="iso19139"
        match="gmd:dateTime|gmd:usageDateTime|gmd:plannedAvailableDateTime"
        priority="2">
        <xsl:param name="schema" />
        <xsl:param name="edit" />

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="simpleElement"
                    select=".">
                    <xsl:with-param name="schema" select="$schema" />
                    <xsl:with-param name="edit" select="$edit" />
                    <xsl:with-param name="text">
                        <xsl:variable name="ref"
                            select="gco:Date/geonet:element/@ref|gco:DateTime/geonet:element/@ref" />

                        <table width="100%">
                            <tr>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="gco:DateTime">
                                            <input class="md" type="text" name="_{$ref}" id="_{$ref}_cal"
                                                value="{gco:DateTime/text()}" size="30" readonly="1" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <input class="md" type="text" name="_{$ref}" id="_{$ref}_cal"
                                                value="{gco:Date/text()}" size="30" readonly="1" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td align="center" width="30" valign="middle">
                                    <img src="{/root/gui/url}/scripts/not-migrated/calendar/img.gif" id="_{$ref}_trigger"
                                        style="cursor: pointer; border: 1px solid;" title="Date selector"
                                        onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
                                    <script type="text/javascript">
                                        Calendar.setup(
                                        { inputField :&quot;_<xsl:value-of select="$ref"/>_cal&quot;,
                                            <xsl:choose>
                                                <xsl:when test="gco:Date">
                                                    ifFormat : "%Y-%m-%d",
                                                    showsTime : false, </xsl:when>
                                                <xsl:otherwise>
                                                    ifFormat : "%Y-%m-%dT%H:%M:00",
                                                    showsTime : true,
                                            </xsl:otherwise>
                                            </xsl:choose>
                                             button : &quot;_<xsl:value-of select="$ref"/>_trigger&quot;
                                            }
                                        );
                                        Calendar.setup(
                                            { inputField : &quot;_<xsl:value-of    select="$ref"/>_cal&quot;,
                                            <xsl:choose>
                                                <xsl:when test="gco:Date">
                                                    ifFormat : "%Y-%m-%d",
                                                    showsTime : false, </xsl:when>
                                                <xsl:otherwise>
                                                    ifFormat : "%Y-%m-%dT%H:%M:00",
                                                    showsTime : true,
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            button : &quot;_<xsl:value-of select="$ref"/>_cal&quot;
                                            }
                                        );
                                    </script>
                                </td>
                                <td align="left" width="100%">
                                    <xsl:text>  </xsl:text>
                                    <a href="JavaScript:clear{$ref}();">
                                        <xsl:value-of select="/root/gui/strings/clear"/>
                                    </a>
                                    <script type="text/javascript">
                                        function clear<xsl:value-of select="$ref"/>() {
                                            document.mainForm._<xsl:value-of select="$ref"/>.value = &quot;&quot;
                                        } </script>
                                </td>
                            </tr>
                        </table>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="iso19139String">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================================================= -->
    <!--
    date (format = %Y-%m-%d)
    editionDate
    dateOfNextUpdate
    mdDateSt is not editable (!we use DateTime instead of only Date!)
    -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139"
        match="gmd:date[gco:DateTime|gco:Date]|gmd:editionDate|gmd:dateOfNextUpdate" priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="text">
                        <xsl:variable name="ref"
                            select="gco:DateTime/geonet:element/@ref|gco:Date/geonet:element/@ref"/>

                        <table width="100%">
                            <tr>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="gco:DateTime">
                                            <input class="md" type="text" name="_{$ref}"
                                                id="_{$ref}_cal" value="{gco:DateTime/text()}"
                                                size="30" readonly="1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <input class="md" type="text" name="_{$ref}"
                                                id="_{$ref}_cal" value="{gco:Date/text()}" size="30"
                                                readonly="1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td align="center" width="30" valign="middle">
                                    <img src="{/root/gui/url}/scripts/not-migrated/calendar/img.gif"
                                        id="_{$ref}_trigger"
                                        style="cursor: pointer; border: 1px solid;"
                                        title="Date selector"
                                        onmouseover="this.style.background='red';"
                                        onmouseout="this.style.background=''"/>
                                    <script type="text/javascript">
                                        Calendar.setup(
                                            { inputField : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,

                                            <xsl:choose>
                                                <xsl:when test="gco:DateTime">
                                                    ifFormat : "%Y-%m-%dT%H:%M:00",
                                                    showsTime :    true, </xsl:when>
                                                <xsl:otherwise>
                                                    ifFormat : "%Y-%m-%d",
                                                    showsTime : false,
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            button : &quot;_<xsl:value-of select="$ref"/>_trigger&quot;
                                            }
                                        );
                                        Calendar.setup(
                                            { inputField : &quot;_<xsl:value-of    select="$ref"/>_cal&quot;,
                                            <xsl:choose>
                                                <xsl:when test="gco:DateTime">
                                                    ifFormat : "%Y-%m-%dT%H:%M:00",
                                                    showsTime :    true,
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    ifFormat : "%Y-%m-%d",
                                                    showsTime : false,
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            button : &quot;_<xsl:value-of select="$ref"/>_cal&quot;
                                            }
                                        );
                                    </script>
                                </td>
                                <td align="left" width="100%">
                                    <xsl:text>  </xsl:text>
                                    <a href="JavaScript:clear{$ref}();"><xsl:value-of select="/root/gui/strings/clear"/></a>
                                    <script type="text/javascript">
                                        function clear<xsl:value-of select="$ref"/>() {
                                            document.mainForm._<xsl:value-of select="$ref"/>.value = &quot;&quot;
                                        } </script>
                                </td>
                            </tr>
                        </table>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="iso19139String">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ===================================================================== -->
    <!-- gml:TimePeriod (format = %Y-%m-%dThh:mm:ss) -->
    <!-- ===================================================================== -->

    <xsl:template mode="iso19139"
        match="gml:*[gml:beginPosition|gml:endPosition]|gml:TimeInstant[gml:timePosition]"
        priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:for-each select="gml:beginPosition|gml:endPosition|gml:timePosition">
            <xsl:choose>
                <xsl:when test="$edit=true()">
                    <xsl:apply-templates mode="simpleElement" select=".">
                        <xsl:with-param name="schema" select="$schema"/>
                        <xsl:with-param name="edit" select="$edit"/>
                        <xsl:with-param name="text">
                            <xsl:variable name="ref" select="geonet:element/@ref"/>

                            <table width="100%">
                                <tr>
                                    <td>
                                        <input class="md" type="text" name="_{$ref}"
                                            id="_{$ref}_cal" value="{text()}" size="30" readonly="1"
                                        />
                                    </td>
                                    <td align="center" width="30" valign="middle">
                                        <img src="{/root/gui/url}/scripts/not-migrated/calendar/img.gif"
                                            id="_{$ref}_trigger"
                                            style="cursor: pointer; border: 1px solid;"
                                            title="Date selector"
                                            onmouseover="this.style.background='red';"
                                            onmouseout="this.style.background=''"/>
                                        <script type="text/javascript">
                                            Calendar.setup(
                                                {
                                                    inputField : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,
                                                    ifFormat : "%Y-%m-%dT%H:%M:00",
                                                    showsTime :    true,
                                                    button : &quot;_<xsl:value-of select="$ref"/>_trigger&quot;
                                                }
                                            ); </script>
                                    </td>
                                    <td align="left" width="100%">
                                        <xsl:text>  </xsl:text>
                                        <a href="JavaScript:clear{$ref}();"><xsl:value-of select="/root/gui/strings/clear"/></a>
                                        <script type="text/javascript">
                                            function clear<xsl:value-of select="$ref"/>() {
                                                document.mainForm._<xsl:value-of select="$ref"/>.value = &quot;&quot;
                                            }
                                        </script>
                                    </td>
                                </tr>
                            </table>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="simpleElement" select=".">
                        <xsl:with-param name="schema" select="$schema"/>
                        <xsl:with-param name="text">
                            <xsl:value-of select="text()"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- =================================================================== -->
    <!-- subtemplates -->
    <!-- =================================================================== -->

    <xsl:template mode="iso19139" match="*[geonet:info/isTemplate='s']" priority="3">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:apply-templates mode="element" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- =================================================================== -->
    <!--
    placeholder
    <xsl:template mode="iso19139" match="TAG">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        BODY
    </xsl:template>
    -->

    <!-- ==================================================================== -->
    <!-- Metadata -->
    <!-- ==================================================================== -->

    <xsl:template mode="iso19139" match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="embedded"/>

        <xsl:call-template name="toggle-visibility-edit">
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>

        <xsl:choose>

            <!-- metadata tab -->
            <xsl:when test="$currTab='metadata'">

                <!-- thumbnail -->
                <tr>
                    <td class="padded" align="center" valign="middle" colspan="2">
                        <xsl:variable name="md">
                            <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="$md/*[1]"/>
                        <xsl:call-template name="thumbnail">
                            <xsl:with-param name="metadata" select="$metadata"/>
                        </xsl:call-template>
                    </td>
                </tr>

                <xsl:call-template name="iso19139Metadata">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:call-template>
            </xsl:when>

            <!-- identification tab -->
            <xsl:when test="$currTab='identification'">

                <!-- thumbnail -->
                <tr>
                    <td class="padded" align="center" valign="middle" colspan="2">
                        <xsl:variable name="md">
                            <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="$md/*[1]"/>
                        <xsl:call-template name="thumbnail">
                            <xsl:with-param name="metadata" select="$metadata"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <xsl:apply-templates mode="elementEP"
                    select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- maintenance tab -->
            <xsl:when test="$currTab='maintenance'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- constraints tab -->
            <xsl:when test="$currTab='constraints'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- spatial tab -->
            <xsl:when test="$currTab='spatial'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- refSys tab -->
            <xsl:when test="$currTab='refSys'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- distribution tab -->
            <xsl:when test="$currTab='distribution'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- embedded distribution tab -->
            <xsl:when test="$currTab='distribution2'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- dataQuality tab -->
            <xsl:when test="$currTab='dataQuality'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- appSchInfo tab -->
            <xsl:when test="$currTab='appSchInfo'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- porCatInfo tab -->
            <xsl:when test="$currTab='porCatInfo'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- contentInfo tab -->
            <xsl:when test="$currTab='contentInfo'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- extensionInfo tab -->
            <xsl:when test="$currTab='extensionInfo'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- default -->
            <xsl:otherwise>

                <!-- thumbnail -->
                <tr>
                    <td class="padded" align="center" valign="middle" colspan="2">
                        <xsl:variable name="md">
                            <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="$md/*[1]"/>
                        <xsl:call-template name="thumbnail">
                            <xsl:with-param name="metadata" select="$metadata"/>
                        </xsl:call-template>
                    </td>
                </tr>

                <xsl:call-template name="iso19139Simple">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="flat" select="$currTab='simple'"/>
                </xsl:call-template>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template name="iso19139Metadata">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <!-- if the parent is root then display fields not in tabs -->

        <xsl:choose>
            <xsl:when test="name(..)='root'">
                <xsl:apply-templates mode="elementEP"
                    select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:language|geonet:child[string(@name)='language']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:contact|geonet:child[string(@name)='contact']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:locale|geonet:child[string(@name)='locale']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:series|geonet:child[string(@name)='series']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:describes|geonet:child[string(@name)='describes']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:propertyType|geonet:child[string(@name)='propertyType']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:featureType|geonet:child[string(@name)='featureType']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:when>

            <!-- otherwise, display everything because we have embedded MD_Metadata -->

            <xsl:otherwise>
                <xsl:apply-templates mode="elementEP" select="*">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ============================================================================= -->
    <!--
    simple mode; ISO order is:
    - gmd:fileIdentifier
    - gmd:language
    - gmd:characterSet
    - gmd:parentIdentifier
    - gmd:hierarchyLevel
    - gmd:hierarchyLevelName
    - gmd:contact
    - gmd:dateStamp
    - gmd:metadataStandardName
    - gmd:metadataStandardVersion
    + gmd:dataSetURI
    + gmd:locale
    - gmd:spatialRepresentationInfo
    - gmd:referenceSystemInfo
    - gmd:metadataExtensionInfo
    - gmd:identificationInfo
    - gmd:contentInfo
    - gmd:distributionInfo
    - gmd:dataQualityInfo
    - gmd:portrayalCatalogueInfo
    - gmd:metadataConstraints
    - gmd:applicationSchemaInfo
    - gmd:metadataMaintenance
    + gmd:series
    + gmd:describes
    + gmd:propertyType
    + gmd:featureType
    + gmd:featureAttribute
    -->
    <!-- ============================================================================= -->

    <xsl:template name="iso19139Simple">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="flat"/>

        <xsl:apply-templates mode="elementEP"
            select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:call-template name="complexElementGui">
            <xsl:with-param name="title" select="/root/gui/strings/metadata"/>
            <xsl:with-param name="content">
                <xsl:call-template name="iso19139Simple2">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="flat" select="$flat"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>

        <xsl:apply-templates mode="elementEP"
            select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template mode="iso19139" match="//gmd:language">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="text">
                <xsl:apply-templates mode="iso19139GetIsoLanguage" select="gco:CharacterString">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template mode="iso19139GetIsoLanguage" match="*">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:variable name="lang" select="/root/gui/language"/>
        <xsl:variable name="value" select="string(.|@codeListValue)"/>
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <select class="md" name="_{geonet:element/@ref}" size="1">
                    <option name=""/>

                    <xsl:for-each select="/root/gui/isoLang/record">
                        <xsl:sort select="label/child::*[name() = $lang]"/>
                        <option value="{code}">
                            <xsl:if test="code = $value">
                                <xsl:attribute name="selected"/>
                            </xsl:if>
                            <xsl:value-of select="label/child::*[name() = $lang]"/>
                        </option>
                    </xsl:for-each>
                </select>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of
                    select="/root/gui/isoLang/record[code=$value]/label/child::*[name() = $lang]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template name="iso19139Simple2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="flat"/>

        <xsl:apply-templates mode="elementEP"
            select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:language|geonet:child[string(@name)='language']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:contact|geonet:child[string(@name)='contact']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:locale|geonet:child[string(@name)='locale']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:series|geonet:child[string(@name)='series']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:describes|geonet:child[string(@name)='describes']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:propertyType|geonet:child[string(@name)='propertyType']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:featureType|geonet:child[string(@name)='featureType']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP"
            select="gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$flat"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- ============================================================================= -->
    <!--
    FIXME
    rpCntInfo: ISO order is:
    - rpIndName
    - rpOrgName
    - rpPosName
    - rpCntInfo
    - role
    -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139" match="mdContact|idPoC">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:variable name="content">
            <xsl:if test="*">
                <td class="padded-content" width="100%" colspan="2">
                    <table width="100%">
                        <tr>
                            <td width="50%" valign="top">
                                <table width="100%">

                                    <xsl:apply-templates mode="elementEP"
                                        select="rpIndName|geonet:child[string(@name)='rpIndName']">
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="edit" select="$edit"/>
                                    </xsl:apply-templates>

                                    <xsl:apply-templates mode="elementEP"
                                        select="rpOrgName|geonet:child[string(@name)='rpOrgName']">
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="edit" select="$edit"/>
                                    </xsl:apply-templates>

                                    <xsl:apply-templates mode="elementEP"
                                        select="rpPosName|geonet:child[string(@name)='rpPosName']">
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="edit" select="$edit"/>
                                    </xsl:apply-templates>

                                    <xsl:apply-templates mode="elementEP"
                                        select="role|geonet:child[string(@name)='role']">
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="edit" select="$edit"/>
                                    </xsl:apply-templates>

                                </table>
                            </td>
                            <td valign="top">
                                <table width="100%">
                                    <xsl:apply-templates mode="elementEP"
                                        select="rpCntInfo|geonet:child[string(@name)='rpCntInfo']">
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="edit" select="$edit"/>
                                    </xsl:apply-templates>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </xsl:if>
        </xsl:variable>

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template mode="iso19139" match="gmd:CI_OnlineResource" priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>

        <xsl:variable name="langId">
            <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/gui/language" />
                <xsl:with-param name="md"
                    select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="defaultLang">
            <xsl:call-template name="getLangId">
                <xsl:with-param name="langGui" select="/root/*/gmd:language/gco:CharacterString" />
                <xsl:with-param name="md"
                    select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="name">
            <xsl:for-each select="gmd:name">
                <xsl:call-template name="localised">
                    <xsl:with-param name="langId" select="$langId"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="description">
            <xsl:for-each select="gmd:description">
                <xsl:call-template name="localised">
                    <xsl:with-param name="langId" select="$langId"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="string($linkage)!=''">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="text">
                        <a href="{$linkage}" target="_new">
                            <xsl:choose>
                                <xsl:when test="string($description)!='' and string($name)!=''">
                                    <xsl:value-of select="$name"/><xsl:text> (</xsl:text><xsl:value-of select="$description"/>)
                                </xsl:when>
                                <xsl:when test="string($description)!=''">
                                    <xsl:value-of select="$description"/>
                                </xsl:when>
                                <xsl:when test="string($name)!=''">
                                    <xsl:value-of select="$name"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$linkage"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template mode="iso19139EditOnlineRes" match="*">
        <xsl:param name="schema"/>

        <xsl:variable name="id" select="generate-id(.)"/>
        <div id="{$id}"/>
        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="true()"/>
            <xsl:with-param name="content">

                <!-- Protocol ref is used to define GUI elements -->
                <xsl:variable name="ref" select="gmd:protocol/gco:CharacterString/geonet:element/@ref|geonet:child[string(@name)='protocol']/gco:CharacterString/geonet:element/@ref"/>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:linkage|geonet:child[string(@name)='linkage']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="true()"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:protocol|geonet:child[string(@name)='protocol']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="true()"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:applicationProfile|geonet:child[string(@name)='applicationProfile']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="true()"/>
                </xsl:apply-templates>

                <xsl:choose>
                    <xsl:when
                        test="string(gmd:protocol/gco:CharacterString)='WWW:DOWNLOAD-1.0-http--download' and string(gmd:name/gco:CharacterString)!=''">
                        <xsl:apply-templates mode="iso19139FileRemove"
                            select="gmd:name/gco:CharacterString">
                            <xsl:with-param name="access" select="'private'"/>
                            <xsl:with-param name="id" select="$id"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when
                        test="string(gmd:protocol/gco:CharacterString)='WWW:DOWNLOAD-1.0-http--download' and gmd:name">
                        <xsl:apply-templates mode="iso19139FileUpload"
                            select="gmd:name/gco:CharacterString">
                            <xsl:with-param name="access" select="'private'"/>
                            <xsl:with-param name="id" select="$id"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when
                        test="string(gmd:protocol/gco:CharacterString)='WWW:LINK-1.0-http--link'"/>
                    <!-- hide orName for www links -->
                    <xsl:otherwise>
                        <xsl:apply-templates mode="elementEP"
                            select="gmd:name|geonet:child[string(@name)='name']">
                            <xsl:with-param name="schema" select="$schema"/>
                            <xsl:with-param name="edit" select="true()"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:description|geonet:child[string(@name)='description']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="true()"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementEP"
                    select="gmd:function|geonet:child[string(@name)='function']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="true()"/>
                </xsl:apply-templates>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ======================================================================================= -->
    <!-- Template used to show related metadata for services when consulting metadata for data   -->
    <!-- ======================================================================================= -->

    <xsl:template name="iso19139LinkedServices" >
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:if test="/root/gui/linkedSrv/summary/@count > 0 and $edit=false()">
            <xsl:apply-templates mode="complexElement" select=".">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
                <xsl:with-param name="content">
                    <xsl:for-each select="/root/gui/linkedSrv/gmd:MD_Metadata">
                        <xsl:variable name="currentUUID">
                            <xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/>
                        </xsl:variable>
                        <xsl:variable name="currentTitle">
                            <xsl:value-of select="gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
                        </xsl:variable>
                        <xsl:if test="position()=1">
                            <br/><xsl:value-of select="/root/gui/strings/linkedServices"/><br/>
                        </xsl:if>
                        <a href="metadata.show?uuid={$currentUUID}">
                            <xsl:choose>
                                <xsl:when test="$currentTitle!=''">
                                    <xsl:value-of select="$currentTitle"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$currentUUID"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a><br/>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- online resources: WMS get map -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139"
        match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-map') and gmd:name]"
        priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString)"/>
        <xsl:variable name="description"
            select="normalize-space(gmd:description/gco:CharacterString)"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when
                test="string(//geonet:info/dynamic)='true' and string($name)!='' and string($linkage)!=''">

                <!-- Create a link for a WMS service that will open in map viewer
                    if in the main search interface. If in view mode, no maps
                    available.
                -->
                <xsl:variable name="linkText">
                    <xsl:choose>
                        <xsl:when test="string($description)!=''">
                            <xsl:value-of select="$description"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="title" select="/root/gui/strings/interactiveMap"/>
                    <xsl:with-param name="text">
                        <xsl:choose>
                            <xsl:when test="/root/gui/reqService='metadata.show.embedded'">
                                <a href="javascript:geocat.addLayer('WMS', '{$linkage}', '{$name}', '{$description}', '{../../../../../..//gmd:fileIdentifier/gco:CharacterString}')"
                                    title="{/root/strings/interactiveMap}">
                                    <xsl:value-of select="$linkText"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$linkText"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <br/>(OGC-WMS Server: <xsl:value-of select="$linkage"/> )
                    </xsl:with-param>
                </xsl:apply-templates>

                <!-- Create a link for a WMS service that will open in Google Earth through the reflector -->
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="title" select="/root/gui/strings/viewInGE"/>
                    <xsl:with-param name="text">
                        <a
                            href="{/root/gui/locService}/google.kml?uuid={//geonet:info/uuid}&amp;layers={$name}"
                            title="{/root/strings/interactiveMap}">
                            <xsl:value-of select="$linkText"/><img
                                src="{/root/gui/url}/images/google_earth_link.gif" height="20px"
                                width="20px" alt="{/root/gui/strings/viewInGE}"
                                title="{/root/gui/strings/viewInGE}" style="border: 0px solid;"/>
                        </a>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- online resources: WMS get capabilities -->
    <!-- =============================================================================
    GetCapabilities document are not handled yet by MapFish client.


    <xsl:template mode="iso19139"
        match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-capabilities') and gmd:name]"
        priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString)"/>
        <xsl:variable name="description"
            select="normalize-space(gmd:description/gco:CharacterString)"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="string(//geonet:info/dynamic)='true' and string($linkage)!=''">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="title" select="/root/gui/strings/interactiveMap"/>
                    <xsl:with-param name="text">
                        <a href="javascript:runIM_selectService('{$linkage}',2,{//geonet:info/id})"
                            title="{/root/strings/interactiveMap}">
                            <xsl:choose>
                                <xsl:when test="string($description)!=''">
                                    <xsl:value-of select="$description"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$name"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
        </xsl:template>-->

    <!-- ============================================================================= -->
    <!-- online resources: download -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139"
        match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:protocol/gco:CharacterString,'http--download') and gmd:name]"
        priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:variable name="download_check">
            <xsl:text>&amp;fname=&amp;access</xsl:text>
        </xsl:variable>
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString)"/>
        <xsl:variable name="description"
            select="normalize-space(gmd:description/gco:CharacterString)"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when
                test="string(//geonet:info/download)='true' and string($linkage)!='' and not(contains($linkage,$download_check))">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="title" select="/root/gui/strings/downloadData"/>
                    <xsl:with-param name="text">
                        <a href="{$linkage}" target="_blank">
                            <xsl:choose>
                                <xsl:when test="string($description)!=''">
                                    <xsl:value-of select="$description"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$name"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- protocol -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139" match="gmd:protocol" priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <!-- Turn off editing on child elements of an xlinked ancestor -->
        <xsl:variable name="xlinkedAncestor"><xsl:call-template name="validatedXlink"/></xsl:variable>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="text">
                        <xsl:variable name="value" select="string(gco:CharacterString)"/>
                        <select name="_{gco:CharacterString/geonet:element/@ref}" size="1">
		                    <xsl:if test="$xlinkedAncestor = 'true'">
		                        <xsl:attribute name="disabled">disabled</xsl:attribute>
		                    </xsl:if>

                            <xsl:if test="$value=''">
                                <option value=""/>
                            </xsl:if>
                            <xsl:for-each select="/root/gui/strings/protocolChoice[@value]">
                                <option>
                                    <xsl:if test="string(@value)=$value">
                                        <xsl:attribute name="selected"/>
                                    </xsl:if>
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="string(@value)"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="string(.)"/>
                                </option>
                            </xsl:for-each>
                        </select>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="false()"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- ============================================================================= -->
    <!-- file upload/download utilities    -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139FileUpload" match="*">
        <xsl:param name="access" select="'public'"/>
        <xsl:param name="id"/>

        <xsl:call-template name="simpleElementGui">
            <xsl:with-param name="title" select="/root/gui/strings/file"/>
            <xsl:with-param name="text">
                <table width="100%">
                    <tr>
                        <xsl:variable name="ref" select="geonet:element/@ref"/>
                        <td width="70%"><input type="file" class="content" name="f_{$ref}"
                                value="{string(.)}"/>&#160;</td>
                        <td align="right">
                            <button class="content"
                                onclick="javascript:doFileUploadAction('{/root/gui/locService}/resources.upload','{$ref}',document.mainForm.f_{$ref}.value,'{$access}','{$id}')">
                                <xsl:value-of select="/root/gui/strings/upload"/>
                            </button>
                        </td>
                    </tr>
                </table>
            </xsl:with-param>
            <xsl:with-param name="schema"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template mode="iso19139FileRemove" match="*">
        <xsl:param name="access" select="'public'"/>
        <xsl:param name="id"/>

        <xsl:call-template name="simpleElementGui">
            <xsl:with-param name="title" select="/root/gui/strings/file"/>
            <xsl:with-param name="text">
                <table width="100%">
                    <tr>
                        <xsl:variable name="ref" select="geonet:element/@ref"/>
                        <td width="70%">
                            <xsl:value-of select="string(.)"/>
                        </td>
                        <td align="right">
                            <button class="content"
                                onclick="javascript:doFileRemoveAction('{/root/gui/locService}/resources.del','{$ref}','{$access}',{$id})">
                                <xsl:value-of select="/root/gui/strings/remove"/>
                            </button>
                        </td>
                    </tr>
                </table>
            </xsl:with-param>
            <xsl:with-param name="schema"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ===================================================================== -->
    <!-- === iso19139 brief formatting === -->
    <!-- ===================================================================== -->

    <xsl:template name="iso19139Brief">
        <metadata>
            <xsl:variable name="download_check">
                <xsl:text>&amp;fname=&amp;access</xsl:text>
            </xsl:variable>
            <xsl:variable name="id" select="geonet:info/id"/>
            <xsl:variable name="uuid" select="geonet:info/uuid"/>
            <xsl:variable name="langId">
                <xsl:call-template name="getLangId">
                    <xsl:with-param name="langGui" select="/root/gui/language"/>
                    <xsl:with-param name="md" select="."/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="gmd:parentIdentifier[gco:CharacterString!='']">
                <parentId><xsl:value-of select="gmd:parentIdentifier/gco:CharacterString"/></parentId>
            </xsl:if>

            <xsl:apply-templates mode="briefster"
                select="gmd:identificationInfo/gmd:MD_DataIdentification|
                    gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|
                    gmd:identificationInfo/srv:SV_ServiceIdentification|
                    gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']">
                <xsl:with-param name="id" select="$id"/>
                <xsl:with-param name="langId" select="$langId"/>
            </xsl:apply-templates>

            <xsl:for-each
                select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
                <xsl:variable name="protocol" select="gmd:protocol/gco:CharacterString"/>
                <xsl:variable name="linkage" select="normalize-space(gmd:linkage/gmd:URL)"/>
                <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString)"/>
                <xsl:variable name="desc"
                    select="normalize-space(gmd:description/gco:CharacterString)"/>

                <xsl:if test="string($linkage)!=''">

                    <xsl:element name="link">
                        <xsl:attribute name="title">
                            <xsl:value-of select="$desc"/>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$linkage"/>
                        </xsl:attribute>
                        <xsl:attribute name="name">
                            <xsl:value-of select="$name"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="starts-with($protocol,'WWW:LINK-')">
                                <xsl:attribute name="type">text/html</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($linkage,'.jpg')">
                                <xsl:attribute name="type">image/jpeg</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($linkage,'.png')">
                                <xsl:attribute name="type">image/png</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($linkage,'.gif')">
                                <xsl:attribute name="type">image/gif</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($linkage,'.doc')">
                                <xsl:attribute name="type">application/word</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($linkage,'.zip')">
                                <xsl:attribute name="type">application/zip</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($linkage,'.pdf')">
                                <xsl:attribute name="type">application/pdf</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'GLG:KML-') and contains($linkage,'.kml')">
                                <xsl:attribute name="type"
                                >application/vnd.google-earth.kml+xml</xsl:attribute>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($protocol,'GLG:KML-') and contains($linkage,'.kmz')">
                                <xsl:attribute name="type"
                                >application/vnd.google-earth.kmz</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="starts-with($protocol,'OGC:WMS-')">
                                <xsl:attribute name="type"
                                >application/vnd.ogc.wms_xml</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$protocol='ESRI:AIMS-'">
                                <xsl:attribute name="type"
                                >application/vnd.esri.arcims_axl</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$protocol!=''">
                                <xsl:attribute name="type">
                                    <xsl:value-of select="$protocol"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- fall back to the default content type -->
                                <xsl:attribute name="type">text/plain</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>

                </xsl:if>

                <!-- Generate a KML output link for a WMS service -->
                <xsl:if
                    test="string($linkage)!='' and starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-map') and string($linkage)!='' and string($name)!=''">

                    <xsl:element name="link">
                        <xsl:attribute name="title">
                            <xsl:value-of select="$desc"/>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('http://',/root/gui/env/server/host,':',/root/gui/env/server/port,/root/gui/locService,'/google.kml?uuid=',$uuid,'&amp;layers=',$name)"
                            />
                        </xsl:attribute>
                        <xsl:attribute name="name">
                            <xsl:value-of select="$name"/>
                        </xsl:attribute>
                        <xsl:attribute name="type"
                        >application/vnd.google-earth.kml+xml</xsl:attribute>
                    </xsl:element>
                </xsl:if>

                <!-- The old links still in use by some systems. Deprecated -->
                <xsl:choose>
                    <xsl:when
                        test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($protocol,'http--download') and not(contains($linkage,$download_check))">
                        <link type="download">
                            <xsl:value-of select="$linkage"/>
                        </link>
                    </xsl:when>
                    <xsl:when
                        test="starts-with($protocol,'ESRI:AIMS-') and contains($protocol,'-get-image') and string($linkage)!='' and string($name)!=''">
                        <link type="arcims">
                            <!--                            <xsl:value-of select="concat('javascript:popInterMap(&#34;',/root/gui/url,'/intermap/srv/',/root/gui/language,'/map.addServicesExt?url=',$linkage,'&amp;service=',$name,'&amp;type=1&#34;)')"/>-->
                            <xsl:value-of
                                select="concat('javascript:runIM_addService(&#34;'  ,  $linkage  ,  '&#34;, &#34;', $name  ,'&#34;, 1)' )"
                            />
                        </link>
                    </xsl:when>
                    <xsl:when
                        test="starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-map') and string($linkage)!='' and string($name)!=''">
                        <link type="wms">
                            <!--                            <xsl:value-of select="concat('javascript:popInterMap(&#34;',/root/gui/url,'/intermap/srv/',/root/gui/language,'/map.addServicesExt?url=',$linkage,'&amp;service=',$name,'&amp;type=2&#34;)')"/>-->
                            <xsl:value-of
                                select="concat('javascript:runIM_addService(&#34;'  ,  $linkage  ,  '&#34;, &#34;', $name  ,'&#34;, 2)' )"
                            />
                        </link>
                        <link type="googleearth">
                            <xsl:value-of
                                select="concat(/root/gui/locService,'/google.kml?uuid=',$uuid,'&amp;layers=',$name)"
                            />
                        </link>
                    </xsl:when>
                    <xsl:when
                        test="starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-capabilities') and string($linkage)!=''">
                        <link type="wms">
                            <xsl:value-of
                                select="concat('javascript:runIM_selectService(&#34;'  ,  $linkage  ,  '&#34;, 2,',$id,')' )"
                            />
                        </link>
                    </xsl:when>
                    <xsl:when test="string($linkage)!=''">
                        <link type="url">
                            <xsl:value-of select="$linkage"/>
                        </link>
                    </xsl:when>

                </xsl:choose>
            </xsl:for-each>

            <xsl:copy-of select="geonet:info"/>
        </metadata>
    </xsl:template>

    <xsl:template name="showMap">
        <xsl:param name="edit" />
        <xsl:param name="coords"/>
        <xsl:param name="targetPolygon"/>
        <xsl:param name="watchedBbox"/>
        <xsl:param name="eltRef"/>
        <div class="extentViewer" style="width:100%; height:300px;" edit="{$edit}" target_polygon="{$targetPolygon}" watched_bbox="{$watchedBbox}" elt_ref="{$eltRef}">
            <div style="display:none;">
                <xsl:value-of select="$coords"/>
            </div>
        </div>
    </xsl:template>

    <!-- Template returning a brief representation of an iso19139
        record. -->
    <xsl:template mode="briefster" match="*">
        <xsl:param name="id"/>
        <xsl:param name="langId"/>

        <xsl:if test="gmd:citation/gmd:CI_Citation/gmd:title">
            <title>
                <xsl:apply-templates mode="localised" select="gmd:citation/gmd:CI_Citation/gmd:title">
                    <xsl:with-param name="langId" select="$langId"></xsl:with-param>
                </xsl:apply-templates>
            </title>
        </xsl:if>

        <xsl:if test="gmd:abstract">
            <abstract>
                <xsl:apply-templates mode="localised" select="gmd:abstract">
                    <xsl:with-param name="langId" select="$langId"></xsl:with-param>
                </xsl:apply-templates>
            </abstract>
        </xsl:if>

        <xsl:for-each select=".//gmd:keyword">
            <keyword>
                <xsl:apply-templates mode="localised" select=".">
                    <xsl:with-param name="langId" select="$langId"></xsl:with-param>
                </xsl:apply-templates>
            </keyword>
        </xsl:for-each>

        <xsl:variable name="extent" select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox | srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox"/>
        <xsl:apply-templates select="gmd:extentTypeCode"/>
        <xsl:if test="$extent">
            <geoBox>
                <westBL>
                    <xsl:value-of
                        select="$extent/gmd:westBoundLongitude"
                    />
                </westBL>
                <eastBL>
                    <xsl:value-of
                        select="$extent/gmd:eastBoundLongitude"
                    />
                </eastBL>
                <southBL>
                    <xsl:value-of
                        select="$extent/gmd:southBoundLatitude"
                    />
                </southBL>
                <northBL>
                    <xsl:value-of
                        select="$extent/gmd:northBoundLatitude"
                    />
                </northBL>
            </geoBox>
        </xsl:if>

        <xsl:if test="not(geonet:info/server)">
            <xsl:variable name="info" select="geonet:info"/>

            <xsl:for-each select="gmd:graphicOverview/gmd:MD_BrowseGraphic">
                <xsl:variable name="fileName" select="gmd:fileName/gco:CharacterString"/>
                <xsl:if test="$fileName != ''">
                    <xsl:variable name="fileDescr" select="gmd:fileDescription/gco:CharacterString"/>
                    <xsl:choose>

                        <!-- the thumbnail is an url -->

                        <xsl:when test="contains($fileName ,'://')">
                            <image type="unknown">
                                <xsl:value-of select="$fileName"/>
                            </image>
                        </xsl:when>

                        <!-- small thumbnail -->

                        <xsl:when test="string($fileDescr)='thumbnail'">
                            <xsl:choose>
                                <xsl:when test="$info/isHarvested = 'y'">
                                    <xsl:if test="$info/harvestInfo/smallThumbnail">
                                        <image type="thumbnail">
                                            <xsl:value-of
                                                select="concat($info/harvestInfo/smallThumbnail, $fileName)"
                                            />
                                        </image>
                                    </xsl:if>
                                </xsl:when>

                                <xsl:otherwise>
                                    <image type="thumbnail">
                                        <xsl:value-of
                                            select="concat(/root/gui/locService,'/resources.get?id=',$id,'&amp;fname=',$fileName,'&amp;access=public')"
                                        />
                                    </image>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>

                        <!-- large thumbnail -->

                        <xsl:when test="string($fileDescr)='large_thumbnail'">
                            <xsl:choose>
                                <xsl:when test="$info/isHarvested = 'y'">
                                    <xsl:if test="$info/harvestInfo/largeThumbnail">
                                        <image type="overview">
                                            <xsl:value-of
                                                select="concat($info/harvestInfo/largeThumbnail, $fileName)"
                                            />
                                        </image>
                                    </xsl:if>
                                </xsl:when>

                                <xsl:otherwise>
                                    <image type="overview">
                                        <xsl:value-of
                                            select="concat(/root/gui/locService,'/graphover.show?id=',$id,'&amp;fname=',$fileName,'&amp;access=public')"
                                        />
                                    </image>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>

                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>

    </xsl:template>

    <xsl:template mode="iso19139" match="gmd:valueUnit" priority="100">
        <xsl:param name="schema" />
        <xsl:param name="edit" />
        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema" />
            <xsl:with-param name="edit" select="false()" />
        </xsl:apply-templates>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- iso19139 complete tab template    -->
    <!-- ============================================================================= -->

    <xsl:template name="iso19139CompleteTab">
        <xsl:param name="tabLink"/>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'complete'"/>
            <!-- just a non-existing tab -->
            <xsl:with-param name="text" select="/root/gui/strings/completeTab"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'metadata'"/>
            <xsl:with-param name="text" select="/root/gui/strings/metadata"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'identification'"/>
            <xsl:with-param name="text" select="/root/gui/strings/identificationTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'maintenance'"/>
            <xsl:with-param name="text" select="/root/gui/strings/maintenanceTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'constraints'"/>
            <xsl:with-param name="text" select="/root/gui/strings/constraintsTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'spatial'"/>
            <xsl:with-param name="text" select="/root/gui/strings/spatialTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'refSys'"/>
            <xsl:with-param name="text" select="/root/gui/strings/refSysTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'distribution'"/>
            <xsl:with-param name="text" select="/root/gui/strings/distributionTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'dataQuality'"/>
            <xsl:with-param name="text" select="/root/gui/strings/dataQualityTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'appSchInfo'"/>
            <xsl:with-param name="text" select="/root/gui/strings/appSchInfoTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'porCatInfo'"/>
            <xsl:with-param name="text" select="/root/gui/strings/porCatInfoTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'contentInfo'"/>
            <xsl:with-param name="text" select="/root/gui/strings/contentInfoTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

        <xsl:call-template name="displayTab">
            <xsl:with-param name="tab" select="'extensionInfo'"/>
            <xsl:with-param name="text" select="/root/gui/strings/extensionInfoTab"/>
            <xsl:with-param name="indent" select="'&#xA0;&#xA0;&#xA0;'"/>
            <xsl:with-param name="tabLink" select="$tabLink"/>
        </xsl:call-template>

    </xsl:template>

    <!-- ============================================================================= -->
    <!-- utilities -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19139IsEmpty" match="*|@*|text()">
        <xsl:choose>
            <!-- normal element -->
            <xsl:when test="*">
                <xsl:apply-templates mode="iso19139IsEmpty"/>
            </xsl:when>
            <!-- text element -->
            <xsl:when test="text()!=''">txt</xsl:when>
            <!-- empty element -->
            <xsl:otherwise>
                <!-- attributes? -->
                <xsl:for-each select="@*">
                    <xsl:if test="string-length(.)!=0">att</xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


	<!-- Display related metadata records. Related resource are only iso19139 metadate records for now.
		But the idea is to extends that to link other resources like iso19110 feature catalogue for example.

		Related resources are:
		* parent metadata record (if gmd:parentIdentifier is set)
		* services (dataset only)
		* datasets (service only)

		In view mode link to related resources are displayed
		In edit mode link to add elements are provided.
	-->
	<xsl:template name="relatedResources">
		<xsl:param name="edit"/>

		<xsl:variable name="metadata" select="/root/gmd:MD_Metadata|/root/*[@gco:isoType='gmd:MD_Metadata']"/>

		<xsl:if test="starts-with(geonet:info/schema, 'iso19139')">

			<xsl:variable name="parent" select="$metadata/gmd:parentIdentifier/gco:CharacterString"/>
			<xsl:variable name="service" select="/root/gui/linkedSrv/*[@gco:isoType='gmd:MD_Metadata']"/>
		    <xsl:variable name="children" select="/root/gui/children/*[geonet:info]"/>
		    <xsl:variable name="datasets" select="$metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']|
				$metadata/gmd:identificationInfo/srv:SV_ServiceIdentification"/>

		    <xsl:if test="$parent or $children or $service or $datasets/srv:operatesOn or $edit">
		        <div style="float:right;border:1px solid grey;width:320px;padding:2px;margin:2px;text-align:left;">
					<!-- Parent
						displayed for both service and datasets metadata.
					-->
					<xsl:choose>
						<xsl:when test="$parent!='' and not($edit)">
							<h3><img src="{/root/gui/url}/images/dataset.gif"
								alt="{/root/gui/strings/linkedParentMetadataHelp}" title="{/root/gui/strings/linkedParentMetadataHelp}" align="absmiddle"/>
								<xsl:value-of select="/root/gui/strings/linkedParentMetadata"/></h3>
						    <xsl:if test="normalize-space($parent)!=''">
								<ul>
									<li><a class="arrow" target="_blank" href="metadata.show?uuid={$parent}">
										<xsl:call-template name="getMetadataTitle">
											<xsl:with-param name="uuid" select="$parent"/>
										</xsl:call-template>
									</a></li>
								</ul>
						    </xsl:if>
							<br/>
						</xsl:when>
					    <xsl:when test="$edit">
							<h3><img src="{/root/gui/url}/images/dataset.gif"
								alt="{/root/gui/strings/linkedParentMetadataHelp}" title="{/root/gui/strings/linkedParentMetadataHelp}" align="absmiddle"/>
								<xsl:value-of select="/root/gui/strings/linkedParentMetadata"/></h3>
					        <xsl:if test="normalize-space($parent)!=''">
								<ul>
									<li><a class="arrow" target="_blank" href="metadata.show?uuid={$parent}">
										<xsl:call-template name="getMetadataTitle">
											<xsl:with-param name="uuid" select="$parent"/>
										</xsl:call-template>
									</a></li>
								</ul>
							</xsl:if>
							<img src="{/root/gui/url}/images/plus.gif"
								alt="{/root/gui/strings/linkedParentMetadataHelp}" title="{/root/gui/strings/linkedParentMetadataHelp}" align="absmiddle"/>
					        <xsl:text> </xsl:text>
					        <a alt="{/root/gui/strings/linkedParentMetadataHelp}"
								title="{/root/gui/strings/linkedParentMetadataHelp}"
								href="javascript:doTabAction('metadata.update', 'metadata');"><xsl:value-of select="/root/gui/strings/addParent"/></a>
							<br/>
					        <br/>
						</xsl:when>
					</xsl:choose>

		            <xsl:choose>
		                <xsl:when test="$children and not($edit)">
		                    <h3><img src="{/root/gui/url}/images/dataset.gif"
		                        alt="{/root/gui/strings/linkedChildrenMetadataHelp}" title="{/root/gui/strings/linkedChildrenMetadataHelp}" align="absmiddle"/>
		                        <xsl:value-of select="/root/gui/strings/linkedChildrenMetadata"/></h3>
		                    <xsl:if test="$children">
		                        <ul>
		                            <xsl:for-each select="$children">
		                                <li><a class="arrow" target="_blank" href="metadata.show?uuid={geonet:info/uuid}">
		                                    <xsl:call-template name="getMetadataTitle">
		                                        <xsl:with-param name="uuid" select="geonet:info/uuid"/>
		                                    </xsl:call-template>
		                                </a></li>
		                            </xsl:for-each>
		                        </ul>
		                    </xsl:if>
		                    <br/>
		                </xsl:when>
		            </xsl:choose>


					<!-- Services linked to metadata using an operatesOn elements.

						Not displayed for services. -->
					<xsl:if test="$metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|
						$metadata/gmd:identificationInfo/gmd:MD_DataIdentification">
						<xsl:choose>
							<xsl:when test="$service and not($edit)">
								<h3><img src="{/root/gui/url}/images/service.gif"
									alt="{/root/gui/strings/associateService}" title="{/root/gui/strings/associateService}" align="absmiddle"/><xsl:value-of select="/root/gui/strings/linkedServices"/></h3>
								<ul>
									<xsl:for-each select="$service">
										<li><a class="arrow" target="_blank" href="metadata.show?uuid={geonet:info/uuid}">
											<xsl:call-template name="getMetadataTitle">
												<xsl:with-param name="uuid" select="geonet:info/uuid"/>
											</xsl:call-template>
										</a></li>
									</xsl:for-each>
								</ul>
							</xsl:when>
							<xsl:when test="$edit">
								<h3><img src="{/root/gui/url}/images/service.gif"
									alt="{/root/gui/strings/associateService}" title="{/root/gui/strings/associateService}" align="absmiddle"/>
									<xsl:value-of select="/root/gui/strings/linkedServices"/></h3>
								<ul>
									<xsl:for-each select="$service">
										<li><a class="arrow" target="_blank" href="metadata.show?uuid={geonet:info/uuid}">
											<xsl:call-template name="getMetadataTitle">
												<xsl:with-param name="uuid" select="geonet:info/uuid"/>
											</xsl:call-template>
										</a></li>
									</xsl:for-each>
								</ul>
								<!-- List of services available to help user editing -->
								<img src="{/root/gui/url}/images/plus.gif"
									alt="{/root/gui/strings/associateServiceHelp}" title="{/root/gui/strings/associateServiceHelp}" align="absmiddle"/>
							    <xsl:text> </xsl:text>
							    <a alt="{/root/gui/strings/associateServiceHelp}" title="{/root/gui/strings/associateServiceHelp}"
							        href="#" onclick="javascript:displaySearchBox('service','{/root/gui/strings/associateService}', null);">
									<xsl:value-of select="/root/gui/strings/associateService"/>
								</a>
							</xsl:when>
						</xsl:choose>
						<br/>
					</xsl:if>


					<!-- Datasets
					. -->
					<xsl:choose>
					    <xsl:when test="$datasets/srv:operatesOn and not($edit)">
							<h3><img src="{/root/gui/url}/images/dataset.gif"
								align="absmiddle"/>
								<xsl:value-of select="/root/gui/strings/linkedDatasetMetadata"/></h3>
							<ul>
							    <xsl:for-each select="$datasets/srv:operatesOn[@uuidref!='']">
									<li><a class="arrow" target="_blank" href="metadata.show?uuid={@uuidref}">
										<xsl:call-template name="getMetadataTitle">
											<xsl:with-param name="uuid" select="@uuidref"/>
										</xsl:call-template>
									</a></li>
								</xsl:for-each>
							</ul>
						</xsl:when>
						<xsl:when test="$datasets and $edit">
							<h3><img src="{/root/gui/url}/images/dataset.gif"
								align="absmiddle"/>
								<xsl:value-of select="/root/gui/strings/linkedDatasetMetadata"/></h3>
							<ul>
							    <xsl:for-each select="$datasets/srv:operatesOn[@uuidref!='']">
									<li>
									    <a class="arrow" target="_blank" href="metadata.show?uuid={@uuidref}">
										<xsl:call-template name="getMetadataTitle">
											<xsl:with-param name="uuid" select="@uuidref"/>
										</xsl:call-template>
									    </a>
									    <!-- Allow deletion of coupledResource and operatesOn element -->
									    <xsl:text> </xsl:text>
									    <a href="metadata.services.detachDataset?id={$metadata/geonet:info/id}&amp;uuid={@uuidref}">
    									    <img alt="{/root/gui/strings/delete}" title="{/root/gui/strings/delete}"
    									        src="{/root/gui/url}/images/del.gif"
    									        align="absmiddle"
    									    />
									    </a>
									</li>
								</xsl:for-each>
							</ul>
						    <img alt="{/root/gui/strings/associateDatasetHelp}" title="{/root/gui/strings/associateDatasetHelp}"
						        src="{/root/gui/url}/images/plus.gif"
								align="absmiddle"/>
						    <xsl:text> </xsl:text>
						    <a alt="{/root/gui/strings/associateDatasetHelp}" title="{/root/gui/strings/associateDatasetHelp}"
						        href="#" onclick="javascript:displaySearchBox('coupledResource','{/root/gui/strings/associateDataset}', null);">
								<xsl:value-of select="/root/gui/strings/associateDataset"/></a>
						</xsl:when>
					</xsl:choose>

				</div>
			</xsl:if>

		</xsl:if>

	</xsl:template>

    <!-- Template to get metadata title using its uuid.
    Title is loaded from current language index if available.
    If not, default title is returned.
    If failed, return uuid. -->
    <xsl:template name="getMetadataTitle">
        <xsl:param name="uuid"/>

        <xsl:variable name="metadataTitle" select="util:getIndexField(string(/root/gui/app/path), string($uuid), '_title', string(/root/gui/language))"/>
        <xsl:choose>
            <xsl:when test="$metadataTitle=''">
                <xsl:variable name="metadataDefaultTitle" select="util:getIndexField(string(/root/gui/app/path), string($uuid), '_defaultTitle', string(/root/gui/language))"/>
                <xsl:choose>
                    <xsl:when test="$metadataDefaultTitle=''">
                        <xsl:value-of select="$uuid"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$metadataDefaultTitle"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$metadataTitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>


