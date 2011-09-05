<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:util="xalan://org.fao.geonet.util.XslUtil">
	
	<xsl:include href="main.xsl"/>

	<xsl:template mode="script" match="/">
		<script type="text/javascript" language="JavaScript">			
			function setAll(id)
			{
				var list = $(id).getElementsByTagName('input');
			
				for (var i=0; i &lt; list.length; i++)
					list[i].checked = true;
			}

			function clearAll(id)
			{
				var list = $(id).getElementsByTagName('input');
			
				for (var i=0; i &lt; list.length; i++)
					list[i].checked = false;
			}
		</script>
	</xsl:template>

	<!-- ================================================================================= -->
	<!-- page content -->
	<!-- ================================================================================= -->

	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title" select="/root/gui/strings/privileges"/>
			<xsl:with-param name="content">
			
				<xsl:variable name="lang" select="/root/gui/language"/>

				<xsl:variable name="validXsd" select="util:getIndexField(string(/root/gui/app/path), string(/root/request/uuid), '_validxsd', string(/root/gui/language))"/>
				<xsl:variable name="validSch-iso" select="util:getIndexField(string(/root/gui/app/path), string(/root/request/uuid), '_validsch-schematron-rules-iso', string(/root/gui/language))"/>
				<xsl:variable name="validSch-iso-che" select="util:getIndexField(string(/root/gui/app/path), string(/root/request/uuid), '_validsch-schematron-rules-iso-che', string(/root/gui/language))"/>
				<xsl:variable name="validSch-inspire" select="util:getIndexField(string(/root/gui/app/path), string(/root/request/uuid), '_validsch-schematron-rules-inspire', string(/root/gui/language))"/>
				
				<xsl:variable name="valid">
					<xsl:choose>
						<!-- only apply restriction to iso19139 metadata records -->
						<xsl:when test="not(starts-with(/root/request/schema, 'iso19139'))">y</xsl:when>
						<xsl:when test="$validXsd='y' and $validSch-iso='y' and $validSch-iso-che='y'"><xsl:text>y</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>n</xsl:text></xsl:otherwise>
					</xsl:choose>                                   
				</xsl:variable>
				
				<div style="float:right;text-align:left;">
				<h1><xsl:value-of select="/root/gui/strings/displayValidationReport"/></h1><br/>
				<xsl:choose>
					<xsl:when test="$valid='y'"><img src="../../images/button_ok.png" alt="valid" title="valid"/></xsl:when>
					<xsl:otherwise><img src="../../images/schematron.gif" alt="{/root/gui/strings/publishOnlyIfAdminOrValid}" title="{/root/gui/strings/publishOnlyIfAdminOrValid}"/></xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="/root/gui/strings/standardValid"/>
				<br/>
				<xsl:if test="starts-with(/root/request/schema, 'iso19139')">
					<xsl:choose>
						<xsl:when test="$validSch-inspire='y'"><img src="../../images/button_ok.png" alt="valid" title="valid"/></xsl:when>
						<xsl:otherwise><img src="../../images/schematron.gif" alt="error" title="error"/></xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="/root/gui/strings/inspireValid"/><br/>
					<br/>
				</xsl:if>
				</div>

				<form name="update" accept-charset="UTF-8" action="{/root/gui/locService}/metadata.admin" method="post">
					<input name="id" type="hidden" value="{/root/response/id}"/>
					<table>
						<tr>
							<th class="padded"><xsl:value-of select="/root/gui/strings/groups"/></th>
							<!-- loop on all operations, add edit, notify and admin privileges to the end -->
							<xsl:for-each select="/root/response/operations/record">
								<xsl:if test="id!='2' and id!='4' and id!='3'">
									<th class="padded-center"><xsl:value-of select="label/child::*[name() = $lang]"/></th>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each select="/root/response/operations/record">
								<xsl:if test="id='3'">
									<th class="padded-center"><xsl:value-of select="label/child::*[name() = $lang]"/></th>
								</xsl:if>
							</xsl:for-each>
							<th width="90" colspan="2">
							</th>
						</tr>
			
						<!-- 'All' and 'Internal' groups -->

						<xsl:apply-templates select="/root/response/groups/group[id='1']" mode="group">
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="valid" select="$valid"/>
						</xsl:apply-templates>
<!-- Hide intranet level
						<xsl:apply-templates select="/root/response/groups/group[id='0']" mode="group">
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="valid" select="$valid"/>
						</xsl:apply-templates>
-->
						<tr>
							<td class="dots"/>
							<xsl:for-each select="/root/response/operations/record">
								<td class="dots"/>
							</xsl:for-each>
							<td class="dots"/>
							<td class="dots"/>
						</tr>
			
						<!-- loop on other groups except -->
						<xsl:for-each select="/root/response/groups/group">
							<xsl:sort select="label/child::*[name() = $lang]"/>
							
							<xsl:if test="id!='0' and id!='1'">
								<xsl:variable name="groupId" select="id"/>
								<tr id="row.{id}">
									<td class="padded"><xsl:value-of select="label/child::*[name() = $lang]"/></td>
									
									<!-- loop on all operations, add edit, notify and admin privileges to the end -->
									<xsl:for-each select="oper">
										<xsl:if test="id!='3'">
											<td class="padded" align="center" width="80">
												<input type="checkbox" name="_{$groupId}_{id}">
													<xsl:if test="on">
														<xsl:attribute name="checked"/>
													</xsl:if>
												</input>
											</td>
										</xsl:if>
									</xsl:for-each>
									<xsl:for-each select="oper">
										<xsl:if test="id='3'">
											<td class="padded" align="center" width="80">
												<input type="checkbox" name="_{$groupId}_{id}">
													<xsl:if test="on">
														<xsl:attribute name="checked"/>
													</xsl:if>
												</input>
											</td>
										</xsl:if>
									</xsl:for-each>

									<!-- 'set all' button -->

									<td>
										<button class="content" onclick="setAll('row.{id}'); return false;">
											<xsl:value-of select="/root/gui/strings/setAll"/>
										</button>
									</td>

									<!-- 'clear all' button -->

									<td>
										<button class="content" onclick="clearAll('row.{id}'); return false;">
											<xsl:value-of select="/root/gui/strings/clearAll"/>
										</button>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</table>					
				</form>
			</xsl:with-param>
			<xsl:with-param name="buttons">
				<button class="content" onclick="goBack()"><xsl:value-of select="/root/gui/strings/back"/></button>
				&#160;
				<button class="content" onclick="goSubmit('update')"><xsl:value-of select="/root/gui/strings/submit"/></button>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ================================================================================= -->

	<xsl:template match="*" mode="group">
		<xsl:param name="lang"/>
		<xsl:param name="valid"/>

		<xsl:variable name="groupId"  select="id"/>
		<xsl:variable name="profile"  select="/root/gui/session/profile"/>	
		<!-- Disabled check box if metadata is not valid and for editor and guest. 
			Admin could not publish/unpublish even if not valid. 
			and ($profile != 'Administrator')
		-->
		<xsl:variable name="disabled" select="(($profile != 'Administrator') and ($profile != 'UserAdmin') and ($profile != 'Reviewer')) 
										or ($valid='n')"/>
		
		<tr id="row.{id}">
			<td class="padded">
				<span>
					<xsl:if test="$disabled">
						<xsl:attribute name="style">color: #A0A0A0;</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="label/child::*[name() = $lang]"/>
				</span>
			</td>
			
			<!-- loop on all operations,  edit, notify and admin privileges are hidden-->
			<xsl:for-each select="oper">
				<xsl:if test="id!='3'">
					<td class="padded" align="center" width="80">
						<input type="checkbox" name="_{$groupId}_{id}">
							<xsl:if test="$disabled">
								<xsl:attribute name="disabled"/>
							</xsl:if>
							<xsl:if test="on">
								<xsl:attribute name="checked"/>
							</xsl:if>
						</input>
					</td>
				</xsl:if>
			</xsl:for-each>

			<!-- fill empty slots -->
			<xsl:for-each select="oper">
				<xsl:if test="id='3'">
					<td/>
				</xsl:if>
			</xsl:for-each>

			<!-- 'set all' button -->

			<td>
				<button class="content" onclick="setAll('row.{id}'); return false;">
					<xsl:if test="$disabled">
						<xsl:attribute name="disabled"/>
						<xsl:attribute name="style">color: #A0A0A0;</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="/root/gui/strings/setAll"/>
				</button>
			</td>

			<!-- 'clear all' button -->

			<td>
				<button class="content" onclick="clearAll('row.{id}'); return false;">
					<xsl:if test="$disabled">
						<xsl:attribute name="disabled"/>
						<xsl:attribute name="style">color: #A0A0A0;</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="/root/gui/strings/clearAll"/>
				</button>
			</td>
		</tr>
	</xsl:template>

	<!-- ================================================================================= -->

</xsl:stylesheet>
