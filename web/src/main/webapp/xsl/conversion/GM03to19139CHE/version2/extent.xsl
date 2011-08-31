<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:che="http://www.geocat.ch/2008/che"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:util="xalan://org.fao.geonet.util.XslUtil"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="int util xalan"
                xmlns:int="http://www.interlis.ch/INTERLIS2.3"
                >

    <xsl:template mode="Extent" match="int:GM03_2Core.Core.EX_Extent">
        <xsl:choose>
            <xsl:when test="int:GM03_2Core.Core.EX_ExtentgeographicElement[.//int:GM03_2Core.Core.EX_BoundingPolygon]">
                <gmd:extent>
                    <gmd:EX_Extent>
                       <xsl:apply-templates mode="Extent" select="int:description"/>

                        <xsl:variable name="polygon">
                            <xsl:if test="int:GM03_2Core.Core.EX_ExtentgeographicElement[.//int:GM03_2Core.Core.EX_BoundingPolygon]">
                                <xsl:apply-templates mode="Extent" select="int:GM03_2Core.Core.EX_ExtentgeographicElement[.//int:GM03_2Core.Core.EX_BoundingPolygon]"/>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:if test="normalize-space($polygon) != ''">
                            <gmd:geographicElement>
                                <xsl:copy-of select="util:multipolygon(string(int:description), $polygon)"/>
                            </gmd:geographicElement>
                            <xsl:if test="int:GM03_2Core.Core.EX_ExtentgeographicElement[.//int:GM03_2Core.Core.EX_GeographicBoundingBox]">
                                <gmd:geographicElement>
                                    <xsl:copy-of select="util:bbox(string(int:description), $polygon)"/>
                                </gmd:geographicElement>
                            </xsl:if>
                        </xsl:if>
                        <xsl:apply-templates mode="Extent" select="int:GM03_2Core.Core.EX_ExtentgeographicElement[not(.//int:GM03_2Core.Core.EX_BoundingPolygon or .//int:GM03_2Core.Core.EX_GeographicBoundingBox)]"/>
                    </gmd:EX_Extent>
                </gmd:extent>
            </xsl:when>
            <xsl:when test="int:GM03_2Core.Core.EX_ExtentgeographicElement[.//int:GM03_2Core.Core.EX_GeographicBoundingBox]">
                <xsl:for-each select="int:GM03_2Core.Core.EX_ExtentgeographicElement//int:GM03_2Core.Core.EX_GeographicBoundingBox">
                    <gmd:extent>
                        <gmd:EX_Extent>
                            <xsl:apply-templates mode="Extent" select="ancestor::int:GM03_2Core.Core.EX_Extent/int:description"/>
                             <gmd:geographicElement>
                                <xsl:apply-templates mode="Extent" select="."/>
                            </gmd:geographicElement>
                            <xsl:apply-templates mode="Extent" select="int:GM03_2Core.Core.EX_ExtentgeographicElement[not(.//int:GM03_2Core.Core.EX_BoundingPolygon or .//int:GM03_2Core.Core.EX_GeographicBoundingBox)]"/>
                        </gmd:EX_Extent>
                    </gmd:extent>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <gmd:extent>
                    <gmd:EX_Extent>
                        <xsl:apply-templates mode="Extent" select="int:description"/>
                        <xsl:apply-templates mode="Extent" select="int:GM03_2Core.Core.EX_ExtentgeographicElement[not(.//int:GM03_2Core.Core.EX_BoundingPolygon or .//int:GM03_2Core.Core.EX_GeographicBoundingBox)]"/>
                    </gmd:EX_Extent>
                </gmd:extent>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="*[not(.//int:GM03_2Core.Core.EX_BoundingPolygon or .//int:GM03_2Core.Core.EX_GeographicBoundingBox or .//int:GM03_2Core.Core.EX_GeographicDescription)]">
	       <gmd:extent>
	           <gmd:EX_Extent>
	               <xsl:apply-templates mode="Extent" select="*[not(.//int:GM03_2Core.Core.EX_BoundingPolygon or .//int:GM03_2Core.Core.EX_GeographicBoundingBox or .//int:GM03_2Core.Core.EX_GeographicDescription)]"/>
	           </gmd:EX_Extent>
	       </gmd:extent>
        </xsl:if>
    </xsl:template>

    <xsl:template mode="Extent" match="int:description">
        <gmd:description>
            <xsl:apply-templates mode="language"/>
        </gmd:description>
    </xsl:template>

    <!-- ================================================================================= -->

    <xsl:template mode="Extent" match="int:geographicElement[not(int:GM03_2Core.Core.EX_GeographicBoundingBox|int:GM03_2Core.Core.EX_BoundingPolygon)]">
        <gmd:geographicElement>
            <xsl:apply-templates mode="Extent"/>
        </gmd:geographicElement>
    </xsl:template>

    <xsl:template mode="Extent" match="int:geographicElement[int:GM03_2Core.Core.EX_BoundingPolygon]">
        <xsl:for-each select="int:GM03_2Core.Core.EX_BoundingPolygon">
            <gmd:geographicElement>
                <xsl:apply-templates mode="Extent" select="."/>
            </gmd:geographicElement>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="Extent" match="int:geographicElement[int:GM03_2Core.Core.EX_GeographicBoundingBox]">
        <xsl:choose>
            <xsl:when test="ancestor::int:GM03_2Core.Core.EX_Extent//int:GM03_2Core.Core.EX_BoundingPolygon">
                <xsl:comment>
                    GeographicBBox elements an associated Polygon are ignored
                </xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <gmd:geographicElement>
                    <xsl:apply-templates mode="Extent" select="int:GM03_2Core.Core.EX_GeographicBoundingBox"/>
                </gmd:geographicElement>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="Extent" match="int:GM03_2Core.Core.EX_GeographicDescription">
        <gmd:EX_GeographicDescription>
            <xsl:apply-templates mode="Extent"/>
        </gmd:EX_GeographicDescription>
    </xsl:template>

    <xsl:template mode="Extent" match="int:extentTypeCode">
        <gmd:extentTypeCode>
            <gco:Boolean>
                <xsl:value-of select="."/>
            </gco:Boolean>
        </gmd:extentTypeCode>
    </xsl:template>

    <xsl:template mode="Extent" match="int:geographicIdentifier">
        <gmd:geographicIdentifier>
            <xsl:apply-templates mode="Identifier"/>
        </gmd:geographicIdentifier>
    </xsl:template>

    <xsl:template mode="Extent" match="int:GM03_2Core.Core.EX_BoundingPolygon">
        <gmd:EX_BoundingPolygon>
            <xsl:apply-templates mode="BoundingPoly"/>
        </gmd:EX_BoundingPolygon>
    </xsl:template>

    <xsl:template mode="Extent" match="int:GM03_2Core.Core.EX_GeographicBoundingBox[not(ancestor::int:GM03_2Core.Core.EX_Extent//int:GM03_2Core.Core.EX_BoundingPolygon)]">
        <gmd:EX_GeographicBoundingBox>
            <xsl:apply-templates mode="BoundingPoly" select="int:extentTypeCode"/>
            <gmd:westBoundLongitude><xsl:apply-templates mode="ExtentCoord" select="int:westBoundLongitude"/></gmd:westBoundLongitude>
            <gmd:eastBoundLongitude><xsl:apply-templates mode="ExtentCoord" select="int:eastBoundLongitude"/></gmd:eastBoundLongitude>
            <gmd:southBoundLatitude><xsl:apply-templates mode="ExtentCoord" select="int:southBoundLatitude"/></gmd:southBoundLatitude>
            <gmd:northBoundLatitude><xsl:apply-templates mode="ExtentCoord" select="int:northBoundLatitude"/></gmd:northBoundLatitude>
        </gmd:EX_GeographicBoundingBox>
    </xsl:template>

    <xsl:template mode="ExtentCoord" match="text()">
        <gco:Decimal><xsl:value-of select="."/></gco:Decimal>
    </xsl:template>

    <!-- ================================================================================= -->

    <xsl:template mode="Extent" match="int:GM03_2Core.Core.EX_ExtenttemporalElement/int:temporalElement">
        <gmd:temporalElement>
            <gmd:EX_TemporalExtent>
                <xsl:apply-templates mode="Extent"/>
            </gmd:EX_TemporalExtent>
        </gmd:temporalElement>
    </xsl:template>

    <xsl:template mode="Extent" match="int:GM03_2Core.Core.EX_TemporalExtent">
        <gmd:extent>
            <gml:TimePeriod gml:id="{util:randomId()}">
                <xsl:apply-templates mode="TimePeriod"/>
            </gml:TimePeriod>
        </gmd:extent>
    </xsl:template>

    <xsl:template mode="TimePeriod" match="int:begin">
        <gml:begin>
            <xsl:apply-templates mode="TimeInstant" select="."/>
        </gml:begin>
    </xsl:template>
    <xsl:template mode="TimePeriod" match="int:end">
        <gml:end>
            <xsl:apply-templates mode="TimeInstant" select="."/>
        </gml:end>
    </xsl:template>
    
    <xsl:template mode="TimeInstant" match="*">
        <xsl:variable name="time">
            <xsl:apply-templates mode="dateTime"/>
        </xsl:variable>
		<gml:TimeInstant gml:id="{util:randomId()}">
		    <gml:timePosition>
		        <xsl:value-of select="normalize-space($time//text())"/>
		    </gml:timePosition>
		</gml:TimeInstant>
    </xsl:template>
    <!-- ================================================================================= -->

    <xsl:template mode="BoundingPoly" match="int:extentTypeCode">
        <gmd:extentTypeCode>
            <gco:Boolean>
                <xsl:value-of select="."/>
            </gco:Boolean>
        </gmd:extentTypeCode>
    </xsl:template>

    <xsl:template mode="BoundingPoly" match="int:polygon">
        <gmd:polygon>
            <xsl:apply-templates mode="GM_Object" select="."/>
        </gmd:polygon>
    </xsl:template>

    <!-- ================================================================================= -->

    <xsl:template mode="GM_Object" match="int:polygon">
        <gml:Polygon gml:id="{generate-id(.)}">
            <xsl:apply-templates mode="GM_Object"/>
        </gml:Polygon>
    </xsl:template>

    <xsl:template mode="GM_Object" match="int:SURFACE">
        <xsl:for-each select="int:BOUNDARY">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <gml:exterior>
                        <xsl:apply-templates mode="GM_Object" select="."/>
                    </gml:exterior>
                </xsl:when>
                <xsl:otherwise>
                    <gml:interior>
                        <xsl:apply-templates mode="GM_Object" select="."/>
                    </gml:interior>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="GM_Object" match="int:BOUNDARY">
        <gml:LinearRing>
                <xsl:apply-templates mode="GM_Object"  select="int:POLYLINE"/>
        </gml:LinearRing>
    </xsl:template>

    <xsl:template mode="GM_Object" match="int:POLYLINE">
            <gml:posList ><xsl:apply-templates mode="GM_Object"/></gml:posList>
    </xsl:template>

    <xsl:template match="int:GM03_2Core.Core.GM_Point_" mode="GM_Object">
        <gml:Point gml:id="{util:randomId()}">
            <gml:coordinates>
                <xsl:apply-templates mode="GM_Object" select="int:value"/>
            </gml:coordinates>
        </gml:Point>
    </xsl:template>

    <xsl:template mode="GM_Object" match="int:COORD"><xsl:value-of select="int:C1"/><xsl:text> </xsl:text><xsl:value-of select="int:C2"/><xsl:text> </xsl:text></xsl:template>

    <!-- ================================================================================= -->
    <xsl:template mode="BboxToPolygon" match="int:GM03_2Core.Core.EX_GeographicBoundingBox">

        <xsl:variable name="north" select="int:northBoundLatitude"/>
        <xsl:variable name="east" select="int:eastBoundLongitude"/>
        <xsl:variable name="south" select="int:southBoundLatitude"/>
        <xsl:variable name="west" select="int:westBoundLongitude"/>

        <xsl:variable name="ul">
            <xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>
        </xsl:variable>
        <xsl:variable name="ur">
            <xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>
        </xsl:variable>
        <xsl:variable name="lr">
            <xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>
        </xsl:variable>
        <xsl:variable name="ll">
            <xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>
        </xsl:variable>

        <gmd:geographicElement>
            <gmd:EX_BoundingPolygon>
                <gmd:extentTypeCode>
                    <gco:Boolean><xsl:value-of select="int:extentTypeCode"/></gco:Boolean>
                </gmd:extentTypeCode>
                <gmd:polygon>
                    <gml:MultiSurface gml:id="NN29">
                        <gml:surfaceMember>
                            <gml:Polygon gml:id="NN30">
                                <gml:exterior>
                                    <gml:LinearRing>
                                            <gml:posList><xsl:value-of select="$ul"/><xsl:text> </xsl:text><xsl:value-of select="$ur"/><xsl:text> </xsl:text><xsl:value-of select="$lr"/><xsl:text> </xsl:text><xsl:value-of select="$ll"/><xsl:text> </xsl:text><xsl:value-of select="$ul"/></gml:posList>
                                    </gml:LinearRing>
                                </gml:exterior>
                            </gml:Polygon>
                        </gml:surfaceMember>
                    </gml:MultiSurface>
                </gmd:polygon>
            </gmd:EX_BoundingPolygon>
        </gmd:geographicElement>
    </xsl:template>

    <!-- ================================================================================= -->

    <xsl:template mode="Extent" match="text()">
        <xsl:call-template name="UnMatchedText">
            <xsl:with-param name="mode">Extent</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
