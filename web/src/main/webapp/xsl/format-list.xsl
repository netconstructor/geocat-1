<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	>
    <xsl:import  href="translate-widget.xsl"/>
    <xsl:import  href="utils.xsl"/>
	<xsl:output method="html"/>
	
    
	<!-- Return a list of user to be use
		for search and select user actions
	-->
	<xsl:template match="/">
		<ul>
			<xsl:for-each select="/root/response/record">                     
                <xsl:variable name="valid">
                    <xsl:call-template name="validIndicator">
                        <xsl:with-param name="indicator" select="normalize-space(translate(validated,$LOWER,$UPPER)) = 'N'" />
                    </xsl:call-template>
                </xsl:variable>
                
				<li xlink:href="{concat('http://', /root/gui/env/server/host, ':', /root/gui/env/server/port, /root/gui/locService)}/xml.format.get?id={id}">
                    <xsl:copy-of select="$valid"/><xsl:text> </xsl:text>
 					<xsl:value-of select="name"/> 
					<xsl:text> </xsl:text>
					<xsl:if test="version != ''">[<xsl:value-of select="version"/>]</xsl:if>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
</xsl:stylesheet>
