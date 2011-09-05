<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="main.xsl"/>

	<!-- ============================================================================= -->

	<xsl:template mode="script" match="/">
		<script type="text/javascript" language="JavaScript">
			function checkAndSubmit()
			{
				document.createform.submit();
			}
		</script>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- page content -->
	<!-- ============================================================================= -->

	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title" select="/root/gui/create/title"/>
			<xsl:with-param name="content">
				<xsl:call-template name="form"/>
			</xsl:with-param>
			<xsl:with-param name="buttons">
				<button class="content" onclick="goBack()"><xsl:value-of select="/root/gui/strings/back"/></button>
				<xsl:if test="/root/gui/templates/record">
					&#160;
					<button class="content" onclick="checkAndSubmit()"><xsl:value-of select="/root/gui/create/button"/></button>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template name="form">
		<form name="createform" accept-charset="UTF-8" action="{/root/gui/locService}/metadata.create" method="post">
			<table>
				<xsl:choose>
					<xsl:when test="not(/root/gui/templates/record)">
						<tr>
							<td>
								<xsl:value-of select="/root/gui/strings/noTemplatesAvailable"/>
							</td>
						</tr>
					</xsl:when>
					<xsl:otherwise>
						<tr>
							<th class="padded"><xsl:value-of select="/root/gui/strings/template"/></th>
							<td class="padded">
								<select class="content" name="id" size="1">
									<xsl:for-each select="/root/gui/templates/record">
										<xsl:sort select="name"/>
										<option value="{id}">
											<xsl:value-of select="name"/>
										</option>
									</xsl:for-each>
								</select>
							</td>
						</tr>

						<!-- groups -->
						<xsl:variable name="lang" select="/root/gui/language"/>
						<tr>
							<th class="padded"><xsl:value-of select="/root/gui/strings/group"/></th>
							<td class="padded">
								<select class="content" name="group" size="1" id="group">
									<xsl:for-each select="/root/gui/groups/record">
										<xsl:sort select="label/child::*[name() = $lang]"/>
										<option value="{id}">
											<xsl:value-of select="label/child::*[name() = $lang]"/>
										</option>
									</xsl:for-each>
								</select>
							</td>
						</tr>
					</xsl:otherwise>
			</xsl:choose>
			</table>
		</form>
	</xsl:template>

	<!-- ============================================================================= -->

</xsl:stylesheet>
