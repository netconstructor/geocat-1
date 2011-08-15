<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--
    main mapfish includes
    -->
    <xsl:template name="mapfish_includes">
        <link rel="stylesheet" type="text/css"
              href="{/root/gui/url}/scripts/mapfishIntegration/boxselect.css"/>
        <link href="{/root/gui/url}/geonetwork.css" type="text/css" rel="stylesheet"/>
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

</xsl:stylesheet>
