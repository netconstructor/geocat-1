<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="*[not(*) and not(@value) and not(@id)]" mode="js-translations">
     "<xsl:value-of select="name(.)"/>":"<xsl:value-of select="normalize-space(translate(.,'&quot;', '`'))"/>",</xsl:template>

    <xsl:template match="*" mode="js-translations"/>

    <xsl:template name="js-translations">
        <script type="text/javascript">
            var translations = {
                <xsl:apply-templates select="/root/gui/strings/*" mode="js-translations"/>
                "":""
            };

            function translate(text) {
                return translations[text] || text;
            }
        </script>
    </xsl:template>


    <!--
    main mapfish includes
    -->
    <xsl:template name="mapfish_includes">
        <link rel="stylesheet" type="text/css"
              href="{/root/gui/url}/scripts/not-migrated/mfbase/ext/resources/css/ext-all.css"/>
        <link rel="stylesheet" type="text/css"
              href="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/boxselect.css"/>
        <link href="{/root/gui/url}/scripts/not-migrated/geonetwork.css" type="text/css" rel="stylesheet"/>
        <link href="{/root/gui/url}/print.css" type="text/css" rel="stylesheet" media="print"/>
        <link href="{/root/gui/url}/scripts/not-migrated/mfbase/mapfish/mapfish.css" type="text/css" rel="stylesheet"/>
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
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/icon_zoomin.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .zoomout {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/icon_zoomout.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .zoomfull {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/icon_zoomfull.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .pan {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/icon_pan.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .selectBbox {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/draw_polygon_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .drawPolygon {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/draw_polygon_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .drawRectangle {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/images/draw_rectangle_off.png) !important;
              height:20px !important;
              width:20px !important;
            }
            .clearPolygon {
              background-image:url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/img/draw_polygon_clear_off.png) !important;
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
        <script type="text/javascript">
            window.gMfLocation = '<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/mfbase/mapfish/';
        </script>
        <xsl:choose>
            <xsl:when test="/root/request/debug">
                <script src="{/root/gui/url}/scripts/not-migrated/mfbase/ext/adapter/ext/ext-base.js" type="text/javascript"/>
                <script src="{/root/gui/url}/scripts/not-migrated/mfbase/ext/ext-all-debug.js" type="text/javascript"/>
                <script src="{/root/gui/url}/scripts/not-migrated/mfbase/openlayers/lib/OpenLayers.js" type="text/javascript"/>
                <script src="{/root/gui/url}/scripts/not-migrated/mfbase/mapfish/MapFish.js" type="text/javascript"/>
            </xsl:when>
            <xsl:otherwise>
                <!--<script src="{/root/gui/url}/scripts/not-migrated/mfbase/ext/adapter/ext/ext-base.js" type="text/javascript"/>-->
                <!--<script src="{/root/gui/url}/scripts/not-migrated/mfbase/ext/ext-all.js" type="text/javascript"/>-->
                <script src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/ext-small.js" type="text/javascript"/>
                <script src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/MapFish.js" type="text/javascript"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="/root/gui/language!='eng'">
            <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mfbase/openlayers/lib/OpenLayers/Lang/{/root/gui/strings/language}.js"/>
            <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mfbase/mapfish/lang/{/root/gui/strings/language}.js"/>
        </xsl:if>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/proj4js-compressed.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/MapComponent.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/MapDrawComponent.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/Ext.ux.BoxSelect.js"/>
        <script type="text/javascript">
            OpenLayers.Lang.setCode('<xsl:value-of select="/root/gui/strings/language"/>');
            Proj4js.defs["EPSG:21781"] = "+title=CH1903 / LV03 +proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +x_0=600000 +y_0=200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs";
        </script>

        <script type="text/javascript"
                src="{/root/gui/url}/scripts/mapfishIntegration/searchTools.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/EMailPDFAction.js"/>
        <script type="text/javascript"
                src="{/root/gui/url}/scripts/not-migrated/mapfishIntegration/DomQueryNS.js"/>
    </xsl:template>

    <xsl:template name="extentViewerJavascript">

        <script language="JavaScript1.2" type="text/javascript">
        if( Ext )
            Ext.onReady(searchTools.initMapDiv)
        else
            Event.observe(window,'load',searchTools.initMapDiv);
        </script>
    </xsl:template>
</xsl:stylesheet>
