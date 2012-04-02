<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="main.xsl" />

	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title"
				select="/root/gui/strings/unpublishReport" />
			<xsl:with-param name="content">

				<table width="100%" class="text-aligned-left">
					<tr>
						<xsl:call-template name="table">
							<xsl:with-param name="title"
								select="/root/gui/strings/autoUnpublish" />
							<xsl:with-param name="records"
								select="/root/report/autoUnpublish/Record" />
						</xsl:call-template>
					</tr><tr>
						<xsl:call-template name="table">
							<xsl:with-param name="title"
								select="/root/gui/strings/manualUnpublish" />
							<xsl:with-param name="records"
								select="/root/report/manualUnpublish/Record" />
						</xsl:call-template>
					</tr><tr>
						<xsl:call-template name="table">
							<xsl:with-param name="title"
								select="/root/gui/strings/allElements" />
							<xsl:with-param name="records"
								select="/root/report/allElements/Record" />
							<xsl:with-param name="showType"
								select="true()" />
						</xsl:call-template>

					</tr>
				</table>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="table">
		<xsl:param name="title" />
		<xsl:param name="records" />
		<xsl:param name="showType" />
		<td>
			<h1>
				<xsl:value-of select="$title" />
			</h1>			
			<table class="text-aligned-left" width="100%" >
				<xsl:choose>
					<xsl:when test="not($records)">
					<tr><td class="">No Data</td></tr>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$records">
							<xsl:sort select="id"/>
							<xsl:apply-templates mode="record" select="." >
								<xsl:with-param name="showType" select="$showType"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</table>
		</td>
	</xsl:template>
	<xsl:template mode="record" match="Record">
		<xsl:param name="showType"/>
		<tr>
			<td>
				<xsl:value-of select="id" />
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="validated">valid</xsl:when>
					<xsl:otherwise>invalid</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="published">published</xsl:when>
					<xsl:otherwise>not published</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="autoUnpublish">System Unpublish</xsl:when>
					<xsl:otherwise>User Unpublish</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:value-of select="failureReason" />
			</td>
		</tr>
	</xsl:template>

</xsl:stylesheet>
