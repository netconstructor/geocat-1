<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable name="modal" select="count(/root/gui/config/search/use-modal-box-for-banner-functions)"/>

	<!--
	main html banner
	-->
	<xsl:template name="banner">

		<table width="100%">

            <!-- print banner -->
            <tr class="banner doprint" style="display:none;white-space:nowrap">
                <td class="banner" colspan="2" width="100%"><div style="width:1024px">
                    <img src="{/root/gui/url}/images/geocat_logo_li.gif" alt="geocat.ch logo"/>
                    <img src="{/root/gui/url}/images/header-background-print.jpg" alt="geocat.ch logo"/>
                    <img src="{/root/gui/url}/images/bg_kopf_geocat.gif" alt="geocat.ch logo"/>
                </div></td>
            </tr>


            <!-- title -->
            <tr class="banner noprint">
                <td class="banner" colspan="2" width="100%">
                    <div style="width:100%; height:103; background-image:url('{/root/gui/url}/images/header-background.jpg');">
                        <img src="{/root/gui/url}/images/bg_kopf_geocat.gif" alt="geocat.ch logo" style="float: right;"/>
                        <img src="{/root/gui/url}/images/geocat_logo_li.gif" alt="geocat.ch logo"/>
                    </div>
                </td>
            </tr>



			<!-- title -->
<!-- 			<tr class="banner"> -->
<!-- 				<td class="banner"> -->
<!-- 					<img src="{/root/gui/url}/images/header-left.jpg" alt="World picture" align="top" /> -->
<!-- 				</td> -->
<!-- 				<td align="right" class="banner"> -->
<!-- 					<img src="{/root/gui/url}/images/header-right.gif" alt="GeoNetwork opensource logo" align="top" /> -->
<!-- 				</td> -->
<!-- 			</tr> -->

			<!-- buttons -->
						<!-- buttons -->
			<tr class="banner noprint">
				<td class="banner-menu">
                    <a class="banner" href="http://www.geocat.ch/geonetwork/srv/{/root/gui/language}/geocat">
                        <xsl:value-of select="/root/gui/strings/nav/home"/>
                    </a> |
                    <a class="banner" href="http://www.geocat.ch/internet/geocat/{/root/gui/strings/language}/tools/sitemap.html">
                        <xsl:value-of select="/root/gui/strings/nav/overview"/>
                    </a> |
				</td>
				<td align="right" class="banner-menu">
					<xsl:choose>
						<xsl:when test="/root/gui/language='eng'">
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" href="../eng/geocat"><xsl:value-of select="/root/gui/strings/en"/></a> |
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="/root/gui/language='fra'">
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" href="../fra/geocat"><xsl:value-of select="/root/gui/strings/fr"/></a>
							<xsl:choose><xsl:when test="not(/root/gui/language='deu')">
								|
							</xsl:when></xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="/root/gui/language='deu'">
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" href="../deu/geocat"><xsl:value-of select="/root/gui/strings/de"/></a>
                            <!--<xsl:choose><xsl:when test="not(/root/gui/language='ita')">
                                |
                            </xsl:when></xsl:choose>-->
						</xsl:otherwise>
					</xsl:choose>
        			<!--<xsl:choose>
						<xsl:when test="/root/gui/language='ita'">
						</xsl:when>
						<xsl:otherwise>
					        <a class="banner" href="../ita/geocat"><xsl:value-of select="/root/gui/strings/it"/></a>
						</xsl:otherwise>
					</xsl:choose>-->
				</td>
			</tr>

            <!-- buttons -->
            <tr class="banner noprint">
                <td class="banner-nav">
                    <table><tr><td class="first">
                        <a href="http://www.geocat.ch/internet/geocat/{/root/gui/strings/language}/home/news.html"><xsl:value-of select="/root/gui/strings/nav/news"/></a>
                    </td><td>
                        <xsl:choose>
                            <xsl:when test="/root/gui/reqService='geocat' or /root/gui/reqService='user.login' or /root/gui/reqService='user.logout'">
                                <a class="banner-active" href="geocat"><xsl:value-of select="/root/gui/strings/nav/metasearch"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a class="banner" href="geocat"><xsl:value-of select="/root/gui/strings/nav/metasearch"/></a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td><td>
                        <xsl:if test="string(/root/gui/session/userId)!=''">
                            <xsl:choose>
                                <xsl:when test="/root/gui/reqService='admin'">
                                    <a class="banner-active" href="admin"><xsl:value-of select="/root/gui/strings/nav/metainput"/></a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a class="banner" href="admin"><xsl:value-of select="/root/gui/strings/nav/metainput"/></a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </td><td>
                        <a href="http://www.geocat.ch/internet/geocat/{/root/gui/strings/language}/home/documentation.html"><xsl:value-of select="/root/gui/strings/nav/doc"/></a>
                    </td><td>
                        <a href="http://www.geocat.ch/internet/geocat/{/root/gui/strings/language}/home/about.html"><xsl:value-of select="/root/gui/strings/nav/about"/></a>
                    </td></tr></table>
                </td>
                <xsl:choose>
                    <xsl:when test="string(/root/gui/session/userId)!=''">
                        <td align="right" class="banner-login">
                            <form name="logout" action="user.logout" method="post">
                                <xsl:value-of select="/root/gui/strings/user"/>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="/root/gui/session/name"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="/root/gui/session/surname"/>
                                <xsl:text> </xsl:text>
                                <button class="banner" onclick="goSubmit('logout')"><xsl:value-of select="/root/gui/strings/logout"/></button>
                            </form>
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td align="right" class="banner-login">
                            <form name="login" action="user.login" method="post">
                                <input type="submit" style="display: none;" />
                                <xsl:value-of select="/root/gui/strings/username"/>
                                <input class="banner" type="text" id="username" name="username" size="10" onkeypress="return entSub('login')"/>
                                <xsl:value-of select="/root/gui/strings/password"/>
                                <input class="banner" type="password" id="password" name="password" size="10" onkeypress="return entSub('login')"/>
                                <button class="banner" onclick="goSubmit('login')"><xsl:value-of select="/root/gui/strings/login"/></button>
                            </form>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>
            </tr>
			
			
			<!--  PMT c2c : trunk vs old geocat version ; previous (trunk GN) was: -->
			<!--	
			<tr class="banner">
				<td class="banner-menu" width="380px">
					<a class="banner" href="{/root/gui/locService}/home"><xsl:value-of select="/root/gui/strings/home"/></a>
					|
					<xsl:if test="$modal">
						<xsl:if test="/root/gui/services/service/@name='metadata.add.form'">
							<a class="banner" href="javascript:void(0)" onclick="doBannerButton('{/root/gui/locService}/metadata.create.form','{/root/gui/strings/newMetadata}',{$modal}, 600);"><xsl:value-of select="/root/gui/strings/newMetadata"/></a>
						|
						</xsl:if>
					</xsl:if>
					<xsl:if test="string(/root/gui/session/userId)!=''">
						<xsl:choose>
							<xsl:when test="/root/gui/reqService='admin'">
								<font class="banner-active"><xsl:value-of select="/root/gui/strings/admin"/></font>
							</xsl:when>
							<xsl:otherwise>
								<a class="banner" onclick="doAdminBannerButton('{/root/gui/locService}/admin','{/root/gui/strings/admin}','{$modal}',800, 500)" href="javascript:void(0);"><xsl:value-of select="/root/gui/strings/admin"/></a>
							</xsl:otherwise>
						</xsl:choose>
						|
					</xsl:if>
					<xsl:choose>
						<xsl:when test="/root/gui/reqService='feedback'">
							<font class="banner-active"><xsl:value-of select="/root/gui/strings/contactUs"/></font>
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" onclick="doBannerButton('{/root/gui/locService}/feedback','{/root/gui/strings/contactUs}','{$modal}',600)" href="javascript:void(0);"><xsl:value-of select="/root/gui/strings/contactUs"/></a>
						</xsl:otherwise>
					</xsl:choose>
					|
					<xsl:choose>
						<xsl:when test="/root/gui/reqService='links'">
							<font class="banner-active"><xsl:value-of select="/root/gui/strings/links"/></font>
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" onclick="doBannerButton('{/root/gui/locService}/links','{/root/gui/strings/links}','{$modal}',600)" href="javascript:void(0);"><xsl:value-of select="/root/gui/strings/links"/></a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="string(/root/gui/session/userId)='' and
-->
<!-- 											string(/root/gui/env/userSelfRegistration/enable)='true'"> -->
<!--
						|
						<a class="banner" onclick="doBannerButton('{/root/gui/locService}/password.forgotten.form','{/root/gui/strings/changePassword}','1',300)" href="javascript:void(0);">
							<xsl:value-of select="/root/gui/strings/forgottenPassword"/>
						</a>
						|
						<a class="banner" onclick="doBannerButton('{/root/gui/locService}/user.register.get','{/root/gui/strings/registerTitle}','{$modal}',600)" href="javascript:void(0);">
							<xsl:value-of select="/root/gui/strings/register"/>
						</a>
					</xsl:if>
					|
					<xsl:choose>
						<xsl:when test="/root/gui/reqService='about'">
							<font class="banner-active"><xsl:value-of select="/root/gui/strings/about"/></font>
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" onclick="doBannerButton('{/root/gui/locService}/about','{/root/gui/strings/about}','{$modal}',800)" href="javascript:void(0);"><xsl:value-of select="/root/gui/strings/about"/></a>
						</xsl:otherwise>
					</xsl:choose>
					|
					Help section to be displayed according to GUI language
					<xsl:choose>
						<xsl:when test="/root/gui/language='fr'">
							<a class="banner" href="{/root/gui/url}/docs/fra/users" target="_blank"><xsl:value-of select="/root/gui/strings/help"/></a>
						</xsl:when>
						<xsl:otherwise>
							<a class="banner" href="{/root/gui/url}/docs/eng/users" target="_blank"><xsl:value-of select="/root/gui/strings/help"/></a>
						</xsl:otherwise>
					</xsl:choose>
					|
				</td>
				<td align="right" class="banner-menu" width="590px">
					<xsl:if test="count(/root/gui/config/languages/*) &gt; 1">
-->
<!-- 						Redirect to current page when no error could happen
						(ie. when having no parameters in GET), if not redirect to the home page.
-->
<!--						
						<xsl:variable name="redirectTo">
						<xsl:choose>
							<xsl:when test="/root/gui/reqService='metadata.show'">main.home</xsl:when>
-->
<!-- 							TODO : Add other exception ? -->
<!--
							<xsl:otherwise><xsl:value-of select="/root/gui/reqService"/></xsl:otherwise>
						</xsl:choose>
						</xsl:variable>
						
						<select class="banner-content content">
							<xsl:attribute name="onchange">location.replace('../' + this.options[this.selectedIndex].value + '/<xsl:value-of select="$redirectTo"/>');</xsl:attribute>
							<xsl:for-each select="/root/gui/config/languages/*">
								<xsl:variable name="lang" select="name(.)"/>
								<option value="{$lang}">
									<xsl:if test="/root/gui/language=$lang">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="/root/gui/strings/*[name(.)=$lang]"/>
								</option>	
							</xsl:for-each>
						</select>
					</xsl:if>
				</td>
			</tr>
-->
			<!-- FIXME: should also contain links to last results and metadata -->

			<!-- login -->
			<!--
			<tr class="banner">
				<td class="banner-login" align="right" width="380px">
				</td>
				<xsl:choose>
					<xsl:when test="string(/root/gui/session/userId)!=''">
						<td align="right" class="banner-login">
							<form name="logout" action="{/root/gui/locService}/user.logout" method="post">
								<xsl:value-of select="/root/gui/strings/user"/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="/root/gui/session/name"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="/root/gui/session/surname"/>
								<xsl:text> </xsl:text>
								<button class="banner" onclick="doLogout()"><xsl:value-of select="/root/gui/strings/logout"/></button>
							</form>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td align="right" class="banner-login">
							<form name="login" action="{/root/gui/locService}/user.login" method="post">
								<xsl:if test="string(/root/gui/env/shib/use)='true'">
									<a class="banner" href="{/root/gui/env/shib/path}">
										<xsl:value-of select="/root/gui/strings/shibLogin"/>
									</a>
									|
								</xsl:if>
								<input type="submit" style="display: none;" />
								<xsl:value-of select="/root/gui/strings/username"/>
								<input class="banner" type="text" id="username" name="username" size="10" onkeypress="return entSub('login')"/>
								<xsl:value-of select="/root/gui/strings/password"/>
								<input class="banner" type="password" id="password" name="password" size="10" onkeypress="return entSub('login')"/>
								<button class="banner" onclick="goSubmit('login')"><xsl:value-of select="/root/gui/strings/login"/></button>
							</form>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
			  -->
		</table>
	</xsl:template>

	<!--
	main html banner in a popup window
	-->
	<xsl:template name="bannerPopup">

		<table width="100%">

			<!-- title -->
			<!-- TODO : Mutualize with main banner template -->
			
			    <tr class="banner noprint">
		        <td class="banner" colspan="2" width="100%">
		            <div style="width:100%; height:103; background-image:url('{/root/gui/url}/images/header-background.jpg');">
		                <img src="{/root/gui/url}/images/header-cat.jpg" alt="GeoNetwork opensource logo" style="float: right;"/>
		                <img src="{/root/gui/url}/images/header-logo.jpg" alt="World picture"/>
		            </div>
		        </td>
		    </tr>		    
	
	
	
	
	<!--  PMT c2c : trunk vs old geocat version ; previous (trunk GN) was: -->		
<!-- 			<tr class="banner"> -->
<!-- 				<td class="banner"> -->
<!-- 					<img src="{/root/gui/url}/images/header-left.jpg" alt="GeoNetwork opensource" align="top" /> -->
<!-- 				</td> -->
<!-- 				<td align="right" class="banner"> -->
<!-- 					<img src="{/root/gui/url}/images/header-right.gif" alt="World picture" align="top" /> -->
<!-- 				</td> -->
<!-- 			</tr> -->

			<!-- buttons -->
			<tr class="banner">
				<td class="banner-menu" colspan="2">
				</td>
			</tr>

			<tr class="banner">
				<td class="banner-login" colspan="2">
				</td>
			</tr>
		</table>
	</xsl:template>


</xsl:stylesheet>

