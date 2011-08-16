<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common" xmlns:geonet="http://www.fao.org/geonetwork"
    exclude-result-prefixes="xsl exslt geonet">

    <xsl:include href="main.xsl"/>
    <xsl:include href="metadata.xsl"/>
    
    <xsl:template mode="css" match="/">
        <script type="text/javascript">
            window.gMfLocation = '<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/';
        </script>
    
        <xsl:call-template name="geoCssHeader"/>
<!--         <xsl:call-template name="ext-ux-css"/> -->
        <link rel="stylesheet" type="text/css"
              href="{/root/gui/url}/scripts/mapfishIntegration/boxselect.css"/>
        <link href="{/root/gui/url}/print.css" type="text/css" rel="stylesheet" media="print"/>
        <link href="{/root/gui/url}/scripts/mapfish/mapfish.css" type="text/css" rel="stylesheet"/>
        <style type="text/css">
            .olControlAttribution {
              left: 5px !important;
              bottom: 5px !important;
            }
            .olControlAttribution a {
              padding: 2px;
            }

            .float-left {
              float: left;
            }
            .clear-left {
              clear: left;
            }
            .zoomin {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/icon_zoomin.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .zoomout {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/icon_zoomout.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .zoomfull {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/icon_zoomfull.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .pan {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/icon_pan.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .selectBbox {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/draw_polygon_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .drawPolygon {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/draw_polygon_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .drawRectangle {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/images/draw_rectangle_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .clearPolygon {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/mapfish/img/draw_polygon_clear_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .layerTreeButton {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/images/layers.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .compressedFieldSet {
              padding-top: 0;
              padding-bottom: 2px;
              margin-bottom: 2px;
            }
            .compressedFormItem {
              margin-bottom: 0;
            }
            .compressedFormItem div {
              padding-top: 0;
            }
            .compressedFormItem label {
              padding: 0;
            }
            .simpleFormFieldset {
                border-style: none;
            }
            .vCenteredColumn div.x-form-item {
              position: absolute;
              top: 60px;
            }
            .uriButtons li {
              display: block;
              float: left;
              list-style-type: none;
              padding-right: 20px;
            }
            fieldset#featured {
              margin: 5px;
              float: right;
            }
            fieldset#latestUpdates {
              margin-top: 2em;
              float: left;
            }

            .mf-email-pdf-action {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/images/emailPDF.png) !important;
            }
        </style>
    </xsl:template>
    
    <!--
    additional scripts
    -->
    <xsl:template mode="script" match="/">
    
        <!-- To avoid an interaction with prototype and ExtJs.Tooltip, should be loadded before ExtJs -->
        <xsl:choose>
            <xsl:when test="/root/request/debug">
                <script type="text/javascript" src="{/root/gui/url}/scripts/prototype.js"></script>
            </xsl:when>
            <xsl:otherwise>
              <script type="text/javascript" src="{/root/gui/url}/scripts/lib/gn.libs.js"></script>      
            </xsl:otherwise>
        </xsl:choose>
    
        <xsl:call-template name="geoHeader"/>
        
        <!-- Required by keyword selection panel -->
        <xsl:if test="/root/gui/config/search/keyword-selection-panel">
            <xsl:call-template name="ext-ux"/>
        </xsl:if>
        
         <xsl:choose>
            <xsl:when test="/root/request/debug">           
                <script type="text/javascript" src="{/root/gui/url}/scripts/geonetwork.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/scriptaculous/scriptaculous.js?load=slider,effects,controls"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/modalbox.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/gn_search.js"></script>
                
                <!--link rel="stylesheet" type="text/css" href="{/root/gui/url}/scripts/ext/resources/css/ext-all.css" />
                <link rel="stylesheet" type="text/css" href="{/root/gui/url}/scripts/ext/resources/css/file-upload.css" />

                <link rel="stylesheet" type="text/css" href="{/root/gui/url}/scripts/openlayers/theme/default/style.css" />
                <link rel="stylesheet" type="text/css" href="{/root/gui/url}/geonetwork_map.css" /-->
         
                <script type="text/javascript" src="{/root/gui/url}/scripts/ext/adapter/ext/ext-base.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/ext/ext-all-debug.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/ext/form/FileUploadField.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/openlayers/lib/OpenLayers.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/openlayers/addins/LoadingPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/openlayers/addins/ScaleBar.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/geo/proj4js-compressed.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/geoext/lib/GeoExt.js"></script>             

                <script type="text/javascript" src="{/root/gui/url}/scripts/map/core/OGCUtil.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/core/MapStateManager.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/core/CatalogueInterface.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/core/WMCManager.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/map/Control/ExtentBox.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/Control/ZoomWheel.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/map/lang/de.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/lang/en.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/lang/es.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/lang/fr.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/lang/nl.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/lang/no.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/map/Ext.ux/form/DateTime.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/tree/WMSListGenerator.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/tree/WMSTreeGenerator.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/wms/BrowserPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/wms/LayerInfoPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/wms/LayerStylesPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/wms/PreviewPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/wms/WMSLayerInfo.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/FeatureInfoPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/LegendPanel.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/OpacitySlider.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/PrintAction.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/ProjectionSelector.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/widgets/TimeSelector.js"></script>
                
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/BaseWindow.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/SingletonWindowManager.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/AddWMS.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/FeatureInfo.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/Opacity.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/LoadWmc.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/WMSTime.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/LayerStyles.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/WmsLayerMetadata.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/map/windows/Disclaimer.js"></script>

                <script type="text/javascript" src="{/root/gui/url}/scripts/ol_settings.js"></script>       
                <script type="text/javascript" src="{/root/gui/url}/scripts/ol_minimap.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/ol_map.js"></script>
                
                <script type="text/javascript" src="{/root/gui/url}/scripts/editor/tooltip.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/editor/tooltip-manager.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/editor/simpletooltip.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/editor/metadata-show.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/editor/metadata-editor.js"></script>
            </xsl:when>
            <xsl:otherwise>             
                <script type="text/javascript" src="{/root/gui/url}/scripts/lib/gn.libs.scriptaculous.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/lib/gn.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/lib/gn.search.js"></script>

                <!-- Editor JS is still required here at least for batch operation -->
                <script type="text/javascript" src="{/root/gui/url}/scripts/lib/gn.editor.js"></script>
                <script type="text/javascript" src="{/root/gui/url}/scripts/lib/gn.libs.map.js"></script>              
            </xsl:otherwise>
         </xsl:choose>
            
            
        <script type="text/javascript" src="{/root/gui/url}/scripts/core/kernel/kernel.js"></script>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/proj4js-compressed.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/MapComponent.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/MapDrawComponent.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/Ext.ux.BoxSelect.js"/>
        <script type="text/javascript">
            OpenLayers.Lang.setCode('<xsl:value-of select="/root/gui/strings/language"/>');
            Proj4js.defs["EPSG:21781"] = "+title=CH1903 / LV03 +proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +x_0=600000 +y_0=200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs";
        </script>

        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/searchTools.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/EMailPDFAction.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/DomQueryNS.js"/>
        <script type="text/javascript" src="{/root/gui/url}/scripts/mapfishIntegration/geocat.js"></script>
        <script type="text/javascript">
            Ext.apply(translations, {
                        'sortByTypes':[<xsl:apply-templates select="/root/gui/strings/sortByType" mode="js-translations-combo"/>],
                        'outputTypes':[<xsl:apply-templates select="/root/gui/strings/outputType" mode="js-translations-combo"/>],
                        'dataTypes':[['', '<xsl:value-of select="/root/gui/strings/any"/>']<xsl:apply-templates select="/root/gui/strings/dataType" mode="js-translations-combo-suite"/>],
                        'hitsPerPageChoices':[<xsl:apply-templates select="/root/gui/strings/hitsPerPageChoice" mode="js-translations-combo"/>],
                        'topicCat': [['', '<xsl:value-of select="/root/gui/strings/any"/>']<xsl:apply-templates select="/root/gui/iso19139/codelist[@name='gmd:MD_TopicCategoryCode']/entry" mode="js-translations-topicCat"/>],
                        'sources_groups': [<xsl:apply-templates select="/root/gui/groups/record" mode="js-translations-sources-groups"><xsl:sort select="label/*[name()=/root/gui/language]"/><xsl:sort select="name"/></xsl:apply-templates><xsl:if
                        test="count(/root/gui/groups/record) > 0 and count(/root/gui/sources/record) > 0">,</xsl:if><xsl:apply-templates select="/root/gui/sources/record" mode="js-translations-sources-groups"><xsl:sort select="label/*[name()=/root/gui/language]"/><xsl:sort select="name"/></xsl:apply-templates>],
                        'formats': [['', '<xsl:value-of select="/root/gui/strings/any"/>']<xsl:apply-templates select="/root/gui/formats/record" mode="js-translations-formats"/>]
                    });
            
            Ext.onReady(function() {
                geocat.initialize('<xsl:value-of select="/root/gui/url"/>/', Env.proxy+'url=<xsl:value-of select="/root/gui/config/geoserver.url"/>/', '<xsl:value-of select="/root/gui/session/userId"/>');
                geocat.language = '<xsl:value-of select="root/gui/language"/>';
            });
        </script>
        
    </xsl:template>


    <xsl:variable name="lang" select="/root/gui/language"/>

    <xsl:template name="content">
                <div id="searchResults" style="display:none;">
                    <h2><xsl:value-of select="/root/gui/strings/mainpageTitle"/></h2>
                    <img src="{/root/gui/url}/images/geocatII-web.jpg" alt="Geocat cat" width="100px"/>
                    <!--<xsl:call-template name="featured"/>-->
                    <xsl:call-template name="mostPopular"/>
                    <xsl:call-template name="latestUpdates"/>
                </div>
                <div id="loadingMask" style="position:absolute; top:0; left:0; width:100%; height:100%; background-color: white; z-index: 1000;">
                    <table width="100%" height="100%">
                        <tr><td align="center" style="vertical-align:middle">
                            <img src="{/root/gui/url}/images/geocatII-web.jpg" alt="Geocat cat"/>
                            <p><xsl:value-of select="/root/gui/strings/loading"/></p>
                        </td></tr>
                    </table>
                </div>
  </xsl:template>   

    <!--
    loading indicator   
    -->
  <xsl:template mode="loading" match="/" priority="2">
    <div id="loading">
      <div class="loading-indicator">
        <img src="{/root/gui/url}/images/spinner.gif" width="32" height="32"/>Geocat.ch Geographic Catalogue<br />
        <span id="loading-msg"><xsl:value-of select="/root/gui/strings/loading"/></span>
      </div>
    </div>
  </xsl:template>

    <!--
        featured map
    -->
    <xsl:template name="featured">
        <xsl:if test="/root/gui/featured/*">
            <fieldset id="featured">
                <legend><xsl:value-of select="/root/gui/strings/featuredMap"/></legend>
                <table>
                    <xsl:for-each select="/root/gui/featured/*">
                        <xsl:variable name="md">
                            <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                        <tr>
                            <td>
                                <h2>
                                    <div class="arrow">
                                        <a href="javascript:geocat.openMetadataWindow('{geonet:info/uuid}');" title="{$metadata/title}"><xsl:value-of select="$metadata/title"/></a>
                                    </div>
                                </h2>
                                <p/>
                                <xsl:variable name="abstract" select="$metadata/abstract"/>
                                <xsl:choose>
                                    <xsl:when test="string-length($abstract) &gt; $maxAbstract">
                                        <xsl:value-of select="substring($abstract, 0, $maxAbstract)"/>
                                        <a href="javascript:geocat.openMetadataWindow('{geonet:info/uuid}');" title="{$metadata/title}">...<xsl:value-of select="/root/gui/strings/more"/>...</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$abstract"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </fieldset>
         </xsl:if>
    </xsl:template>

    <!--
        latest updates
    -->
    <xsl:template name="latestUpdates">
        <xsl:if test="/root/gui/latestUpdated/*">
            <fieldset id="latestUpdates">
                <legend>
                    <xsl:value-of select="/root/gui/strings/recentAdditions"/>&#160;<a style="vertical-align:middle" href="{/root/gui/locService}/rss.latest?georss=simplepoint" target="_blank">
                        <img style="cursor:hand;cursor:pointer" src="{/root/gui/url}/images/georss_light.png"
                            alt="GeoRSS-GML" title="{/root/gui/strings/georss}" width="16"/>
                    </a>
                </legend>
                <br/>
                <xsl:for-each select="/root/gui/latestUpdated/*">
                    <xsl:variable name="md">
                        <xsl:apply-templates mode="brief" select="."/>
                    </xsl:variable>
                    <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                    <a class="arrow" href="javascript:geocat.openMetadataWindow('{geonet:info/uuid}');" title="{$metadata/title}">
                        <xsl:value-of select="$metadata/title"/>
                        <br/>
                    </a>
                </xsl:for-each>
            </fieldset>
        </xsl:if>
    </xsl:template>

    <!--
        Most popular
    -->
    <xsl:template name="mostPopular">
        <xsl:if test="/root/gui/mostPopular/*">
            <fieldset id="mostPopular">
                <legend>
                    <xsl:value-of select="/root/gui/strings/mostPopular"/>
                </legend>
                <br/>
                <xsl:for-each select="/root/gui/mostPopular/*">
                    <xsl:variable name="md">
                        <xsl:apply-templates mode="brief" select="."/>
                    </xsl:variable>
                    <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                    <a class="arrow" href="javascript:geocat.openMetadataWindow('{geonet:info/uuid}');" title="{$metadata/title}">
                        <xsl:value-of select="$metadata/title"/>
                        <br/>
                    </a>
                </xsl:for-each>
            </fieldset>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="js-translations-combo-suite">
        ,["<xsl:value-of select="@value"/><xsl:value-of select="@id"/>", "<xsl:value-of select="."/>"]</xsl:template>

    <xsl:template match="*" mode="js-translations-combo">
        <xsl:if test="position()>1">,</xsl:if>["<xsl:value-of select="@value"/><xsl:value-of select="@id"/>", "<xsl:value-of select="."/>"]</xsl:template>

    <xsl:template match="entry" mode="js-translations-topicCat">
        ,["<xsl:value-of select="code"/>", "<xsl:value-of select="label"/>"]</xsl:template>

    <xsl:template match="record" mode="js-translations-sources-groups"><xsl:if test="position()>1">,</xsl:if><xsl:choose><xsl:when test="siteid">["_source/<xsl:value-of select="siteid"/>", "<xsl:value-of select="name"/>"</xsl:when><xsl:otherwise>["_groupOwner/<xsl:value-of select="id"/>", "<xsl:value-of select="label/*[name()=/root/gui/language]"/>"</xsl:otherwise></xsl:choose>]</xsl:template>

    <xsl:template match="record" mode="js-translations-formats">
        ,["<xsl:value-of select="name"/><xsl:if test="version != '-'">_<xsl:value-of select="version"/></xsl:if>", "<xsl:value-of select="name"/> (<xsl:value-of select="version"/>)"]</xsl:template>

</xsl:stylesheet>
