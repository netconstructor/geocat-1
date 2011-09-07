<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:util="xalan://org.fao.geonet.util.XslUtil"
	xmlns:xalan= "http://xml.apache.org/xalan" exclude-result-prefixes="xalan">

	<xsl:include href="metadata-iso19115.xsl"/>
	<xsl:include href="metadata-iso19139.xsl"/>
	<xsl:include href="metadata-iso19139-utils.xsl"/>
    <xsl:include href="metadata-iso19139.che.xsl"/>
	<xsl:include href="metadata-fgdc-std.xsl"/>
	<xsl:include href="metadata-dublin-core.xsl"/>

	<!--
	hack to extract geonet URI; I know, I could have used a string constant like
	<xsl:variable name="geonetUri" select="'http://www.fao.org/geonetwork'"/>
	but this is more interesting
	-->
	<xsl:variable name="geonetNodeSet"><geonet:dummy/></xsl:variable>

	<xsl:variable name="geonetUri">
		<xsl:value-of select="namespace-uri($geonetNodeSet/*)"/>
	</xsl:variable>

	<xsl:variable name="currTab">
		<xsl:choose>
			<xsl:when test="/root/gui/currTab"><xsl:value-of select="/root/gui/currTab"/></xsl:when>
			<xsl:otherwise>simple</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template mode="schema" match="*">
		<xsl:choose>
			<xsl:when test="string(geonet:info/schema)!=''"><xsl:value-of select="geonet:info/schema"/></xsl:when>
			<xsl:when test="name(.)='Metadata'">iso19115</xsl:when>
			<xsl:when test="local-name(.)='CHE_MD_Metadata' and namespace-uri(.)='http://www.geocat.ch/2008/che'">iso19139.che</xsl:when>
            <xsl:when test="local-name(.)='MD_Metadata'">iso19139</xsl:when>
			<xsl:when test="name(.)='metadata'">fgdc-std</xsl:when>
			<xsl:otherwise>UNKNOWN</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- summary: copy it -->
	<xsl:template match="summary" mode="brief">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- brief -->
	<xsl:template match="*" mode="brief">
		<xsl:param name="schema">
			<xsl:apply-templates mode="schema" select="."/>
		</xsl:param>
		<!--
		[schema:<xsl:value-of select="$schema"/>]
		-->
		<xsl:choose>
			<!-- subtemplate -->
			<xsl:when test="geonet:info/isTemplate='s'">
				<metadata>
					<title><xsl:value-of select="geonet:info/title"/></title>
					<xsl:copy-of select="geonet:info"/>
				</metadata>
			</xsl:when>

			<!-- ISO 19115 -->
			<xsl:when test="$schema='iso19115'">
				<xsl:call-template name="iso19115Brief"/>
			</xsl:when>

			<!-- ISO 19139 and ISO profil -->
			<xsl:when test="starts-with($schema,'iso19139.che')">
				<xsl:call-template name="iso19139.cheBrief"/>
			</xsl:when>
			<xsl:when test="starts-with($schema,'iso19139')">
			<xsl:call-template name="iso19139Brief"/>
			</xsl:when>

			<!-- FGDC -->
			<xsl:when test="$schema='fgdc-std'">
				<xsl:call-template name="fgdc-stdBrief"/>
			</xsl:when>

			<!-- Dublin core -->
			<xsl:when test="$schema='dublin-core'">
				<xsl:call-template name="dublin-coreBrief"/>
			</xsl:when>

			<!-- default, no schema-specific formatting -->
			<xsl:otherwise>
				<metadata>
					<xsl:apply-templates mode="copy" select="*"/>
				</metadata>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<!-- Metadata header on view/edit mode in popup/fullpage mode -->
	<xsl:template name="metadata-show-header">
		<xsl:param name="metadata"/>
		<xsl:param name="buttons"/>
		<xsl:param name="baseURL"/>

		<xsl:variable name="mdURL" select="normalize-space(concat($baseURL, '?uuid=', geonet:info/uuid))"/>

		<xsl:call-template name="socialBookmarks">
			<xsl:with-param name="baseURL" select="$baseURL" /> <!-- The base URL of the local GeoNetwork site -->
			<xsl:with-param name="mdURL" select="$mdURL" /> <!-- The URL of the metadata using the UUID -->
			<xsl:with-param name="title" select="$metadata/title" />
			<xsl:with-param name="abstract" select="$metadata/abstract" />
		</xsl:call-template>


			<xsl:if test="$buttons!=''">
				<xsl:copy-of select="$buttons"/>
			</xsl:if>
			<tr>
				<td align="center" valign="left" class="padded-content">
					<table width="100%">
						<tr>
							<td align="left" valign="middle" class="padded-content" height="40">
								<xsl:call-template name="logo"/>
							</td>
							<td class="padded" width="90%">
								<h1 align="left">
									<xsl:value-of select="$metadata/title"/>
								</h1>
							</td>

							<!-- Schema based user interactions -->
							<td align="right" class="padded-content" height="16" nowrap="nowrap">
								<xsl:choose>
									<xsl:when test="contains(geonet:info/schema,'dublin-core')">
											<a class="noprint" href="{/root/gui/locService}/dc.xml?id={geonet:info/id}" target="_blank" title="Download Dublin Core metadata in XML">
												<img src="{/root/gui/url}/images/xml.png" alt="Dublin Core XML" title="Save Dublin Core metadata as XML" border="0"/>
											</a>
									</xsl:when>
									<xsl:when test="contains(geonet:info/schema,'fgdc-std')">
											<a class="noprint" href="{/root/gui/locService}/fgdc.xml?id={geonet:info/id}" target="_blank" title="Download FGDC metadata in XML">
												<img src="{/root/gui/url}/images/xml.png" alt="FGDC XML" title="Save FGDC metadata as XML" border="0"/>
											</a>
									</xsl:when>
									<xsl:when test="contains(geonet:info/schema,'iso19115')">
											<a class="noprint" href="{/root/gui/locService}/iso19115to19139.xml?id={geonet:info/id}" target="_blank" title="Save ISO19115/19139 metadata as XML">
												<img src="{/root/gui/url}/images/xml.png" alt="IISO19115/19139 XML" title="Save ISO19115/19139 metadata as XML" border="0"/>
											</a>
											<a href="{/root/gui/locService}/iso_arccatalog8.xml?id={geonet:info/id}" target="_blank" title="Download ISO19115 metadata in XML for ESRI ArcCatalog">
												<img src="{/root/gui/url}/images/ac.png" alt="ISO19115 XML for ArcCatalog" title="Save ISO19115 metadata in XML for ESRI ArcCatalog" border="0"/>
											</a>
									</xsl:when>
									<xsl:when test="contains(geonet:info/schema,'iso19139')">
											<a class="noprint" href="{/root/gui/locService}/iso19139.xml?id={geonet:info/id}" target="_blank" title="Download ISO19115/19139 metadata in XML">
												<img src="{/root/gui/url}/images/xml.png" alt="ISO19115/19139 XML" title="Save ISO19115/19139 metadata as XML" border="0"/>
											</a>
										<!-- Profil specific export services -->
										<xsl:choose>
											<xsl:when test="geonet:info/schema='iso19139.che'">
												<a href="{/root/gui/locService}/gm03.xml?id={geonet:info/id}" target="_blank" title="Download GM03"><!-- TODO : Translate -->
													<img src="{/root/gui/url}/images/xml_gm03.png" alt="GM03 XML" title="Save GM03" border="0"/>
												</a>
											</xsl:when>
										</xsl:choose>

									</xsl:when>
								</xsl:choose>
                                <!-- start permalink code -->
                                <xsl:variable name="host" select="/root/gui/env/server/host" />
                                <xsl:variable name="port" select="/root/gui/env/server/port" />
                                <xsl:variable name="serverUrl">
                                    <xsl:choose>
                                        <xsl:when test="80 = /root/gui/env/server/port">
                                            <xsl:value-of select="concat('http://',$host,/root/gui/locService)" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('http://',$host,':',$port,/root/gui/locService)" />    
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>


                                <xsl:variable name="fileId" select="normalize-space(*:fileIdentifier)"/>
                                <a onClick="permlink('{$serverUrl}/metadata.show?fileIdentifier={$fileId}&amp;currTab=simple') " target="_{$fileId}" title="Download GM03"><!-- TODO : Translate -->
                                    <img src="{/root/gui/url}/images/link.png" alt="{/root/gui/strings/permlink}" title="{/root/gui/strings/permlink}" border="0"/>
                                </a>
                                <!-- end permalink code -->

                                <xsl:if test="/root/gui/reqService='metadata.show.embedded'">
									<br/><br/>
									<a href="metadata.show?id={geonet:info/id}&#38;currTab=complete" target="_{$fileId}"><xsl:value-of select="/root/gui/strings/completeTab"/></a>
                                    <br/>
                                    <a href="metadata.show?id={geonet:info/id}&#38;printview" target="_{$fileId}"><xsl:value-of select="/root/gui/strings/completeTabPrint"/></a>
								</xsl:if>
							</td>
						</tr>
						<tr>
							<td colspan="2" style="text-align:center;">
								<xsl:call-template name="thumbnail">
									<xsl:with-param name="metadata" select="$metadata"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="relatedResources">
									<xsl:with-param name="edit" select="false()"/>
								</xsl:call-template>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<!-- subtemplate title button -->
			<xsl:if test="(string(geonet:info/isTemplate)='s')">
				<tr><td class="padded-content" height="100%" align="center" valign="top">
					<b><xsl:value-of select="geonet:info/title"/></b>
				</td></tr>
			</xsl:if>
	</xsl:template>



	<!--
		creates a logo image, possibly with a link
	-->
	<xsl:template name="logo">
		<xsl:variable name="source" select="string(geonet:info/source)"/>
		<xsl:variable name="groupLogoUuid" select="string(geonet:info/groupLogoUuid)"/>
		<xsl:variable name="groupWebsite" select="string(geonet:info/groupWebsite)"/>
		<xsl:choose>
			<xsl:when test="$groupWebsite != '' and $groupLogoUuid != ''">
				<a href="{$groupWebsite}" target="_blank">
					<img src="{/root/gui/url}/images/logos/{$groupLogoUuid}.png" width="40"/>
				</a>
			</xsl:when>
			<xsl:when test="$groupLogoUuid != ''">
				<img src="{/root/gui/url}/images/logos/{$groupLogoUuid}.png" width="40"/>
			</xsl:when>
			<!-- //FIXME does not point to baseURL yet-->
			<xsl:when test="/root/gui/sources/record[string(siteid)=$source]">
				<a href="{/root/gui/sources/record[string(siteid)=$source]/baseURL}" target="_blank">
					<img src="{/root/gui/url}/images/logos/{$source}.gif" width="40"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<img src="{/root/gui/url}/images/logos/{$source}.gif" width="40"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<!--
	creates a thumbnail image, possibly with a link to larger image
	-->
	<xsl:template name="thumbnail">
		<xsl:param name="metadata"/>

		<xsl:choose>

			<!-- small thumbnail -->
			<xsl:when test="$metadata/image[@type='thumbnail']">

				<xsl:choose>

					<!-- large thumbnail link -->
					<xsl:when test="$metadata/image[@type='overview']">
						<a href="javascript:popWindow('{$metadata/image[@type='overview']}')">
							<img src="{$metadata/image[@type='thumbnail']}" alt="{/root/gui/strings/thumbnail}"/>
						</a>
					</xsl:when>

					<!-- no large thumbnail -->
					<xsl:otherwise>
						<img src="{$metadata/image[@type='thumbnail']}" alt="{/root/gui/strings/thumbnail}"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>

			<!-- papermaps thumbnail -->
			<!-- FIXME
			<xsl:when test="/root/gui/paperMap and string(dataIdInfo/idCitation/presForm/PresFormCd/@value)='mapHardcopy'">
				<a href="PAPERMAPS-URL">
					<img src="{/root/gui/paperMap}" alt="{/root/gui/strings/paper}" title="{/root/gui/strings/paper}"/>
				</a>
			</xsl:when>
			-->

			<!-- no thumbnail -->
			<xsl:otherwise>
				<img src="{/root/gui/locUrl}/images/nopreview.gif" alt="{/root/gui/strings/thumbnail}"/>
			</xsl:otherwise>
		</xsl:choose>
		<br/>
	</xsl:template>

	<!--
	adds toggle for Hidden Element editing in Advanced View
	-->
	<xsl:template name="toggle-visibility-edit">
		<xsl:param name="edit" select="false()"/>

		<xsl:if test="$edit=true()">
			<tr align="left">
                <td></td>
				<td colspan="1">
					<xsl:if test="$currTab!='simple'">
					<input class="content" type="checkbox" onclick="toggleVisibilityEdit()" name="toggleVisibilityEditCB" id="toggleVisibilityEditCB" value="true"/><label for="toggleVisibilityEditCB" style="margin-left:0.5em"><xsl:value-of select="/root/gui/strings/toggleVisibilityEdit"/></label>
					</xsl:if>
					<xsl:call-template name="relatedResources">
						<xsl:with-param name="edit" select="true()"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<!--
	adds per-element icon for Hidden Element editing
	-->
	<xsl:template name="visibility-icons">
		<xsl:param name="ref" />

		<!-- Must be a non-empty element ref and not in default view (simple) -->
		<xsl:if test="$ref!='' and $currTab!='simple'">

			<!-- Get current visibility level -->
			<xsl:variable name="level">
				<xsl:choose>
					<xsl:when test="geonet:hide/@level='all'">all</xsl:when>
					<!-- // Note (just@justobjects.nl 090517): allow only 'all' and 'no' visibility for Swiss Topo
                    <xsl:when test="geonet:hide/@level='intranet'">intranet</xsl:when>   -->
					<xsl:otherwise>no</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- Determine icon on current visibility level -->
			<xsl:variable name="image">
				<xsl:choose>
					<xsl:when test="$level='all'">red-ball.gif</xsl:when>
					<!--
                    Note (just@justobjects.nl 090517): allow only 'all' and 'no' visibility for Swiss Topo
					<xsl:when test="$level='intranet'">yellow-ball.gif</xsl:when>   -->
					<xsl:otherwise>green-ball.gif</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- Setup edit icon -->
			<xsl:if test="name(.)!='gmd:LocalisedCharacterString'">
				<a style="display:none;" href="javascript:void(0)" onClick="changeVisibility({$ref})" class="elementHiding">
					<img id="{$ref}_visibility_icon" src="{/root/gui/url}/images/{$image}" />
				</a>
			</xsl:if>

			<!-- Reference to parent. -->
			<xsl:variable name="parentRef" select="../geonet:element/@ref"/>
			<!-- Identifies and stores hiding info, parent ref number in class attribute -->
			<input type="hidden" id="hide_{$ref}" name="hide_{$ref}" value="{$level}" class="parent_{$parentRef}"/>
		</xsl:if>
	</xsl:template>

	<!--
	standard metadata buttons (edit/delete/privileges/categories)
	-->
	<xsl:template name="buttons" match="*">
		<xsl:param name="metadata" select="."/>

		<!-- create button -->
		<!-- When a user with access to the metadata.duplicate.form can see a template, he can use it.
			  Also when not allowed to edit the template himself -->

		<xsl:if test="string(geonet:info/isTemplate)!='s' and (geonet:info/isTemplate='y' or geonet:info/source=/root/gui/env/site/siteId) and /root/gui/services/service/@name='metadata.duplicate.form'">
			<button class="content" onclick="load('{/root/gui/locService}/metadata.duplicate.form?id={$metadata/geonet:info/id}')"><xsl:value-of select="/root/gui/strings/create"/></button>
		</xsl:if>

		<!-- it is the server that decides if a user can edit/delete/set privileges/set categories to a metadata -->
		<xsl:if test="geonet:info/edit='true'">
			<!-- edit button -->
			&#160;
			<button class="content" onclick="load('{/root/gui/locService}/metadata.edit?id={$metadata/geonet:info/id}')"><xsl:value-of select="/root/gui/strings/edit"/></button>

			<!-- delete button -->
			&#160;
			<button class="content" onclick="return doConfirm('{/root/gui/locService}/metadata.delete?id={$metadata/geonet:info/id}', '{/root/gui/strings/confirmDelete}')"><xsl:value-of select="/root/gui/strings/delete"/></button>

			<!-- privileges button -->
			&#160;
			<button class="content" onclick="load('{/root/gui/locService}/metadata.admin.form?id={$metadata/geonet:info/id}&amp;uuid={$metadata/geonet:info/uuid}&amp;schema={$metadata/geonet:info/schema}')"><xsl:value-of select="/root/gui/strings/privileges"/></button>

			<!-- Ticket #13917 categories button
			&#160;
			<button class="content" onclick="load('{/root/gui/locService}/metadata.category.form?id={$metadata/geonet:info/id}')"><xsl:value-of select="/root/gui/strings/categories"/></button>
			-->
		</xsl:if>

	</xsl:template>

	<!--
	editor left tab
	-->
	<xsl:template name="tab">
		<xsl:param name="schema">
			<xsl:apply-templates mode="schema" select="."/>
		</xsl:param>
		<xsl:param name="tabLink"/>
		<xsl:param name="edit" select="false()"/>

		<table width="100%">

			<!-- simple tab -->
			<xsl:call-template name="displayTab">
				<xsl:with-param name="tab"     select="'simple'"/>
				<xsl:with-param name="text"    select="/root/gui/strings/simpleTab"/>
				<xsl:with-param name="tabLink" select="$tabLink"/>
			</xsl:call-template>

			<!--  complete tab(s) -->
			<xsl:choose>

				<!-- hide complete tab for subtemplates -->
				<xsl:when test="geonet:info[isTemplate='s']"/>

				<xsl:when test="$currTab='xml' or $currTab='simple'">
					<xsl:call-template name="displayTab">
						<xsl:with-param name="tab"     select="'metadata'"/>
						<xsl:with-param name="text"    select="/root/gui/strings/completeTab"/>
						<xsl:with-param name="tabLink" select="$tabLink"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>

					<!-- metadata type-specific complete tab -->
					<xsl:choose>

						<!-- ISO 19115 -->
						<xsl:when test="$schema='iso19115'">
							<xsl:call-template name="iso19115CompleteTab">
								<xsl:with-param name="tabLink" select="$tabLink"/>
							</xsl:call-template>
						</xsl:when>

					    <!-- ISO 19139.che -->
					    <xsl:when test="starts-with($schema,'iso19139.che')">
					        <xsl:call-template name="iso19139.cheCompleteTab">
					            <xsl:with-param name="tabLink" select="$tabLink"/>
					        </xsl:call-template>
					    </xsl:when>

					    <!-- ISO 19139 -->
						<xsl:when test="starts-with($schema,'iso19139')">
							<xsl:call-template name="iso19139CompleteTab">
								<xsl:with-param name="tabLink" select="$tabLink"/>
							</xsl:call-template>
						</xsl:when>

						<!-- default, no schema-specific formatting -->
						<xsl:otherwise>
							<xsl:call-template name="completeTab">
								<xsl:with-param name="tabLink" select="$tabLink"/>
							</xsl:call-template>
						</xsl:otherwise>

					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>

			<!-- xml tab -->
			<xsl:choose>
				<xsl:when test="contains($tabLink,'metadata.show')">
					<xsl:call-template name="displayTab">
						<xsl:with-param name="tab"     select="'xml'"/>
						<xsl:with-param name="text"    select="/root/gui/strings/xmlTab"/>
						<xsl:with-param name="tabLink" select="$tabLink"/>
				</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="displayTab">
						<xsl:with-param name="tab"     select="'xml'"/>
						<xsl:with-param name="text"    select="/root/gui/strings/xmlTab"/>
						<xsl:with-param name="tabLink" select="$tabLink"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

			<tr><td><br/></td></tr>

			<xsl:if test="$edit=true()">
				<tr>
					<td class="banner-login">
						<a class="palette" href="javascript:displayValidationReportBox('{/root/gui/strings/displayValidationReport}');"><xsl:value-of select="/root/gui/strings/displayValidationReport"/></a>
					</td>
				</tr>
				<tr>
					<td>
						<!-- TODO : style in css and translate -->
						<div class="help">
							<xsl:value-of select="/root/gui/strings/help"/>
							<ul>
								<li><div><img src="../../images/plus.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementAdd"/></li>
								<li><div>[<img src="../../images/plus.gif" alt="" title=""/>]</div><xsl:value-of select="/root/gui/strings/elementXLink"/></li>
								<li><div><img src="../../images/del.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementDel"/></li>
								<li><div><img src="../../images/up.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementUp"/></li>
								<li><div><img src="../../images/down.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementDown"/></li>
								<li><div>*</div><xsl:value-of select="/root/gui/strings/elementMandatory"/></li>
								<li><div><img src="../../images/schematron.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementSch"/></li>
								<li><p>&#160;</p></li>
								<li>&#160;<xsl:value-of select="/root/gui/strings/elementVisibility"/><br/></li>
								<li><div><img src="../../images/green-ball.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementVisAll"/><br/></li>
								<!-- // Note (just@justobjects.nl 090517): allow only 'all' and 'no' visibility for Swiss Topo
                                    <li><div><img src="../../images/yellow-ball.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementVisNo"/><br/></li>  -->
								<li><div><img src="../../images/red-ball.gif" alt="" title=""/></div><xsl:value-of select="/root/gui/strings/elementVisIntra"/><br/></li>
							</ul>
						</div>
					</td>
				</tr>
			</xsl:if>

		</table>
	</xsl:template>

	<!--
	default complete tab template
	-->
	<xsl:template name="completeTab">
		<xsl:param name="tabLink"/>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'metadata'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/completeTab"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		<!--
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'metadata'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/metadata"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		-->
	</xsl:template>

	<!--
	shows a tab
	-->
	<xsl:template name="displayTab">
		<xsl:param name="tab"/>
		<xsl:param name="text"/>
		<xsl:param name="indent"/>
		<xsl:param name="tabLink"/>

		<xsl:variable name="currTab" select="/root/gui/currTab"/>

		<tr><td>
			<xsl:attribute name="class">
                <xsl:choose>
					<xsl:when test="$currTab=$tab">mdmenu-active</xsl:when>
					<xsl:otherwise>banner-login</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="$indent"/>

			<xsl:choose>
				<!-- not active -->
				<xsl:when test="$tabLink=''"><font class="banner-passive"><xsl:value-of select="$text"/></font></xsl:when>

				<!-- selected -->
				<xsl:when test="$currTab=$tab"><xsl:value-of select="$text"/></xsl:when>

				<!-- not selected -->
				<xsl:otherwise><a class="palette" href="javascript:doTabAction('{$tabLink}','{$tab}')"><xsl:value-of select="$text"/></a></xsl:otherwise>
			</xsl:choose>
		</td></tr>
	</xsl:template>


</xsl:stylesheet>
