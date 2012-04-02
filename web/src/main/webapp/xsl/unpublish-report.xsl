<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" indent="no" media-type="text/csv"></xsl:output>

	<xsl:template match="/">
		<xsl:text>"Metadata Id","Changing Entity","Valid","Published","failureReason"</xsl:text>
		<xsl:apply-templates select="/root/report/allElements/record"/> 
	</xsl:template>
	<xsl:template match="record">
"<xsl:value-of select="id"/>","<xsl:value-of select="entity"/>","<xsl:value-of select="validated"/>","<xsl:value-of select="published"/>","<xsl:value-of select="failureReason"/>"</xsl:template>

</xsl:stylesheet>
