<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="exslt">
    <xsl:include href="banner.xsl"/>
    <xsl:include href="utils.xsl"/>
    <xsl:include href="metadata.xsl"/>
    <xsl:include href="mapfish_includes.xsl"/>

    <xsl:template match="*[not(*) and not(@value) and not(@id)]" mode="js-translations">
                "<xsl:value-of select="name(.)"/>":"<xsl:value-of select="normalize-space(translate(.,'&quot;', '`'))"/>",</xsl:template>

    <xsl:template match="*" mode="js-translations"/>

    <xsl:template match="*" mode="js-translations-combo-suite">
        ,["<xsl:value-of select="@value"/><xsl:value-of select="@id"/>", "<xsl:value-of select="."/>"]</xsl:template>

    <xsl:template match="*" mode="js-translations-combo">
        <xsl:if test="position()>1">,</xsl:if>["<xsl:value-of select="@value"/><xsl:value-of select="@id"/>", "<xsl:value-of select="."/>"]</xsl:template>

    <xsl:template match="entry" mode="js-translations-topicCat">
        ,["<xsl:value-of select="code"/>", "<xsl:value-of select="label"/>"]</xsl:template>

    <xsl:template match="record" mode="js-translations-sources-groups"><xsl:if test="position()>1">,</xsl:if><xsl:choose><xsl:when test="siteid">["_source/<xsl:value-of select="siteid"/>", "<xsl:value-of select="name"/>"</xsl:when><xsl:otherwise>["_groupOwner/<xsl:value-of select="id"/>", "<xsl:value-of select="label/*[name()=/root/gui/language]"/>"</xsl:otherwise></xsl:choose>]</xsl:template>

    <xsl:template match="record" mode="js-translations-formats">
        ,["<xsl:value-of select="name"/><xsl:if test="version != '-'">_<xsl:value-of select="version"/></xsl:if>", "<xsl:value-of select="name"/> (<xsl:value-of select="version"/>)"]</xsl:template>

    <xsl:template name="sources">
        <xsl:text>{</xsl:text>
        <xsl:for-each select="/root/gui/sources/record">
            "<xsl:value-of select="siteid"/>":{"name":"<xsl:value-of select="name"/>","url":"<xsl:value-of select="url"/>"}<xsl:if test="following-sibling::record">,</xsl:if>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="/">
        <html width="100%" height="100%">
            <head>
                <title><xsl:value-of select="/root/gui/strings/title"/></title>
                <link href="{/root/gui/url}/favicon.ico" rel="shortcut icon" type="image/x-icon" />
                <link href="{/root/gui/url}/favicon.ico" rel="icon" type="image/x-icon" />

                <!-- Recent updates newsfeed -->
                <link href="{/root/gui/locService}/rss.latest?georss=gml" rel="alternate" type="application/rss+xml" title="GeoNetwork opensource GeoRSS | {/root/gui/strings/recentAdditions}" />
                <link href="{/root/gui/locService}/portal.opensearch" rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="title">GeoNetwork|<xsl:value-of select="//site/organization"/>|<xsl:value-of select="//site/name"/></xsl:attribute>
                </link>

                <!-- meta tags -->
                <xsl:copy-of select="/root/gui/strings/header_meta/meta"/>
            </head>
            <body width="100%" height="100%">
                <div id="north" style="width:100%">
                    <xsl:call-template name="banner"/>
                </div>
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
                <xsl:call-template name="mapfish_includes"/>

                <script type="text/javascript"
                        src="{/root/gui/url}/scripts/mapfishIntegration/geocat.js"/>
                <script type="text/javascript"
                        src="{/root/gui/url}/scripts/not-migrated/geonetwork.js"/>

                <script type="text/javascript">
                   var sources = <xsl:call-template name="sources"/>;
                
                    var translations = {
                        <xsl:apply-templates select="/root/gui/strings/*" mode="js-translations"/>
                        'sortByTypes':[<xsl:apply-templates select="/root/gui/strings/sortByType" mode="js-translations-combo"/>],
                        'outputTypes':[<xsl:apply-templates select="/root/gui/strings/outputType" mode="js-translations-combo"/>],
                        'dataTypes':[['', '<xsl:value-of select="/root/gui/strings/any"/>']<xsl:apply-templates select="/root/gui/strings/dataType" mode="js-translations-combo-suite"/>],
                        'hitsPerPageChoices':[<xsl:apply-templates select="/root/gui/strings/hitsPerPageChoice" mode="js-translations-combo"/>],
                        'topicCat': [['', '<xsl:value-of select="/root/gui/strings/any"/>']<xsl:apply-templates select="/root/gui/iso19139/codelist[@name='gmd:MD_TopicCategoryCode']/entry" mode="js-translations-topicCat"/>],
                        'sources_groups': [<xsl:apply-templates select="/root/gui/groups/record" mode="js-translations-sources-groups"><xsl:sort select="label/*[name()=/root/gui/language]"/><xsl:sort select="name"/></xsl:apply-templates><xsl:if
                        test="count(/root/gui/groups/record) > 0 and count(/root/gui/sources/record) > 0">,</xsl:if><xsl:apply-templates select="/root/gui/sources/record" mode="js-translations-sources-groups"><xsl:sort select="label/*[name()=/root/gui/language]"/><xsl:sort select="name"/></xsl:apply-templates>],
                        'formats': [['', '<xsl:value-of select="/root/gui/strings/any"/>']<xsl:apply-templates select="/root/gui/formats/record" mode="js-translations-formats"/>]
                    };
                    

                    function translate(text) {
                        return translations[text] || text;
                    }

                    Ext.onReady(function() {
	                    geocatConf = {
						    header : {
				                region: 'north',
				                contentEl: 'north',
				                autoHeight: true,
				                border: false
				            },
						    extraSetup : function() {},
						    loadingElemId : "loadingMask"
						};
                        geocat.language = '<xsl:value-of select="/root/gui/language"/>';
						<xsl:variable name="userid" select="normalize-space(root/gui/session/userId)"/>
						<xsl:variable name="profile" select="normalize-space(root/gui/session/profile)"/>
						geocat.session.userId = '<xsl:value-of select="$userid"/>';
						geocat.session.profile = '<xsl:value-of select="$profile"/>';
						<xsl:for-each select="/root/gui/usergroups/record[normalize-space(userid) = $userid or $profile = 'Administrator' ]">
							geocat.session.groups.push('<xsl:value-of select="normalize-space(groupid)"/>');
						</xsl:for-each>

                        geocat.initialize('<xsl:value-of select="/root/gui/url"/>/', '../../proxy?url=<xsl:value-of select="/root/gui/config/geoserver.url"/>/', '<xsl:value-of select="/root/gui/session/userId"/>');
                    });
                </script>
            </body>
        </html>
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
</xsl:stylesheet>