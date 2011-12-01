<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:che="http://www.geocat.ch/2008/che"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="xml" indent="yes"/>

    <xsl:include href="../iso-internal-multilingual-conversion.xsl"/>
    <xsl:include href="../iso-internal-multilingual-conversion-url.xsl"/>

	<!-- Return an iso19139 representation of a contact
	stored in the metadata catalogue.
	-->
	<xsl:template match="/">
     <xsl:apply-templates mode="iso19139.che" select="root/response/record"/>
<!--
        See comment by the commented out iso19139 for why this is commented out.
<xsl:choose>
			<xsl:when test="/root/request/schema='iso19139.che'">
				<xsl:apply-templates mode="iso19139.che" select="root/response/record"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="iso19139" select="root/response/record"/>
			</xsl:otherwise>
		</xsl:choose>-->
	</xsl:template>

 <xsl:template match="record" mode="iso19139.che">
		<che:CHE_CI_ResponsibleParty gco:isoType="gmd:CI_ResponsibleParty">
			<gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="organisation"/>
                </xsl:call-template>
			</gmd:organisationName>
			<gmd:positionName xsi:type="gmd:PT_FreeText_PropertyType">
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="positionname"/>
                </xsl:call-template>
			</gmd:positionName>
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:phone>
						<che:CHE_CI_Telephone gco:isoType="gmd:CI_Telephone">
                            <gmd:voice>
                                <xsl:if test="normalize-space(phone)=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(phone)"/>
                                </gco:CharacterString>
                            </gmd:voice>
                            <xsl:if test="phone1!=''">
                                <gmd:voice>
                                     <xsl:if test="normalize-space(phone1)=''">
                                         <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                     </xsl:if>
                                     <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(phone1)"/>
                                     </gco:CharacterString>
                                </gmd:voice>
                            </xsl:if>
                            <xsl:if test="phone2!=''">
                                <gmd:voice>
                                     <xsl:if test="normalize-space(phone2)=''">
                                         <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                     </xsl:if>
                                     <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(phone2)"/>
                                     </gco:CharacterString>
                                </gmd:voice>
                            </xsl:if>
                            <gmd:facsimile>
                                <xsl:if test="normalize-space(facsimile)=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(facsimile)"/>
                                </gco:CharacterString>
                            </gmd:facsimile>
                            <xsl:if test="facsimile1!=''">
                                <gmd:facsimile>
                                    <xsl:if test="normalize-space(facsimile1)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(facsimile1)"/>
                                    </gco:CharacterString>
                                </gmd:facsimile>
                            </xsl:if>
                            <xsl:if test="facsimile2!=''">
                                <gmd:facsimile>
                                    <xsl:if test="normalize-space(facsimile2)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(facsimile2)"/>
                                    </gco:CharacterString>
                                </gmd:facsimile>
                            </xsl:if>
							<che:directNumber>
								<xsl:if test="directnumber=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="directnumber"/>
								</gco:CharacterString>
							</che:directNumber>
							<che:mobile>
								<xsl:if test="mobile=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="mobile"/>
								</gco:CharacterString>
							</che:mobile>
						</che:CHE_CI_Telephone>
					</gmd:phone>
					<gmd:address>
						<che:CHE_CI_Address gco:isoType="gmd:CI_Address">
							<gmd:city>
								<xsl:if test="city=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="city"/>
								</gco:CharacterString>
							</gmd:city>
							<gmd:administrativeArea>
								<xsl:if test="state=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="state"/>
								</gco:CharacterString>
							</gmd:administrativeArea>
							<gmd:postalCode>
								<xsl:if test="zip=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="zip"/>
								</gco:CharacterString>
							</gmd:postalCode>
							<gmd:country xsi:type="gmd:PT_FreeText_PropertyType">
                                <xsl:if test="country=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="country"/>
                                </gco:CharacterString>
							</gmd:country>
							<gmd:electronicMailAddress>
								<xsl:if test="normalize-space(email)=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="normalize-space(email)"/>
								</gco:CharacterString>
							</gmd:electronicMailAddress>
                            <xsl:if test="email1!=''">
                                <gmd:electronicMailAddress>
                                    <xsl:if test="normalize-space(email1)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(email1)"/>
                                    </gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </xsl:if>
                            <xsl:if test="email2!=''">
                                <gmd:electronicMailAddress>
                                    <xsl:if test="normalize-space(email2)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(email2)"/>
                                    </gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </xsl:if>
							<che:streetName>
								<xsl:if
									test="streetname=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="streetname"/>
								</gco:CharacterString>
							</che:streetName>
							<che:streetNumber>
								<xsl:if
									test="streetnumber=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="streetnumber"/>
								</gco:CharacterString>
							</che:streetNumber>
							<che:addressLine>
								<xsl:if
									test="address=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="address"/>
								</gco:CharacterString>
							</che:addressLine>
							<che:postBox>
								<xsl:if
									test="postbox=''">
									<xsl:attribute name="gco:nilReason"
										>missing</xsl:attribute>
								</xsl:if>
								<gco:CharacterString>
									<xsl:value-of select="postbox"/>
								</gco:CharacterString>
							</che:postBox>
						</che:CHE_CI_Address>
					</gmd:address>
						<gmd:onlineResource>
							<gmd:CI_OnlineResource>
							    <xsl:for-each select="onlineresource[normalize-space(text())!='']">
									<gmd:linkage xsi:type="che:PT_FreeURL_PropertyType">
	                                <xsl:call-template name="composeURLTranslations">
	                                    <xsl:with-param name="elem" select="."/>
	                                </xsl:call-template>
									</gmd:linkage>
								</xsl:for-each>
								<gmd:protocol>
									<gco:CharacterString>text/html</gco:CharacterString>
								</gmd:protocol>
                                <gmd:name xsi:type="gmd:PT_FreeText_PropertyType">
                                <xsl:call-template name="composeTranslations">
                                    <xsl:with-param name="elem" select="onlinename"/>
                                </xsl:call-template>
                                </gmd:name>
                                <gmd:description xsi:type="gmd:PT_FreeText_PropertyType">
                                <xsl:call-template name="composeTranslations">
                                    <xsl:with-param name="elem" select="onlinedescription"/>
                                </xsl:call-template>
                                </gmd:description>
							</gmd:CI_OnlineResource>
						</gmd:onlineResource>
						<gmd:hoursOfService>
                            <xsl:if test="hoursofservice=''">
                                    <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                            </xsl:if>
							<gco:CharacterString>
								<xsl:value-of select="hoursofservice"/>
							</gco:CharacterString>
						</gmd:hoursOfService>
						<gmd:contactInstructions>
                            <xsl:if test="contactinstructions=''">
                                    <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                            </xsl:if>
							<gco:CharacterString>
								<xsl:value-of select="contactinstructions"/>
							</gco:CharacterString>
						</gmd:contactInstructions>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<gmd:role>
				<gmd:CI_RoleCode codeListValue="{/root/request/role}"
					codeList="http://www.isotc211.org/2005/resources/codeList.xml#CI_RoleCode"/>
			</gmd:role>
			<che:individualFirstName>
				<xsl:if test="name=''">
					<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				</xsl:if>
				<gco:CharacterString>
					<xsl:value-of select="name"/>
				</gco:CharacterString>
			</che:individualFirstName>
			<che:individualLastName>
				<xsl:if test="surname=''">
					<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				</xsl:if>
				<gco:CharacterString>
					<xsl:value-of select="surname"/>
				</gco:CharacterString>
			</che:individualLastName>
			<che:organisationAcronym xsi:type="gmd:PT_FreeText_PropertyType">
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="orgacronym"/>
                </xsl:call-template>
            </che:organisationAcronym>
            <xsl:if test="normalize-space(parentinfo) != ''">
                <xsl:variable name="validated">
                </xsl:variable>
		<che:parentResponsibleParty xmlns:xlink="http://www.w3.org/1999/xlink"
					    xlink:href="http://{/root/gui/env/server/host}:{/root/gui/env/server/port}/geonetwork/srv/eng/xml.user.get?id={parentinfo}&amp;schema=iso19139.che&amp;role=distributor"
					    xlink:show="embed">
		  <xsl:if test="string(../parentValidated)='n'">
		    <xsl:attribute name="xlink:role">http://www.geonetwork.org/non_valid_obj</xsl:attribute>
		  </xsl:if>
                </che:parentResponsibleParty>
            </xsl:if>
		</che:CHE_CI_ResponsibleParty>
	</xsl:template>


    <!--  This template is for the case where CHE is not used.  It is not currently used in geocat so I have
          stopped supporting it.  If it is needed again.  Uncomment this block.  Fix the statements to be inline with the
          statements in the che template.  (basically copy che template and delete che specific elements.  Then uncomment the choose in the
          / template

    <xsl:template match="record" mode="iso19139">
        <gmd:CI_ResponsibleParty>
            <gmd:individualName>
                <xsl:if test="name='' and surname=''">
                    <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                </xsl:if>
                <gco:CharacterString>
                    <xsl:value-of select="concat(name, ' ', surname)"/>
                </gco:CharacterString>
            </gmd:individualName>
            <gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="organisation"/>
                </xsl:call-template>

            </gmd:organisationName>
            <gmd:positionName xsi:type="gmd:PT_FreeText_PropertyType">
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="positionname"/>
                </xsl:call-template>
            </gmd:positionName>
            <gmd:contactInfo>
                <gmd:CI_Contact>
                    <gmd:phone>
                        <gmd:CI_Telephone>
                            <gmd:voice>
                                <xsl:if test="normalize-space(phone)=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="phone"/>
                                </gco:CharacterString>
                            </gmd:voice>
                            <xsl:if test="phone1!=''">
                                <gmd:voice>
                                     <xsl:if test="normalize-space(phone1)=''">
                                         <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                     </xsl:if>
                                     <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(phone1)"/>
                                     </gco:CharacterString>
                                </gmd:voice>
                            </xsl:if>
                            <xsl:if test="phone2!=''">
                                <gmd:voice>
                                     <xsl:if test="normalize-space(phone2)=''">
                                         <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                     </xsl:if>
                                     <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(phone2)"/>
                                     </gco:CharacterString>
                                </gmd:voice>
                            </xsl:if>
                            <gmd:facsimile>
                                <xsl:if test="normalize-space(facsimile)=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(facsimile)"/>
                                </gco:CharacterString>
                            </gmd:facsimile>
                            <xsl:if test="facsimile1!=''">
                                <gmd:facsimile>
                                    <xsl:if test="normalize-space(facsimile1)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(facsimile1)"/>
                                    </gco:CharacterString>
                                </gmd:facsimile>
                            </xsl:if>
                            <xsl:if test="facsimile2!=''">
                                <gmd:facsimile>
                                    <xsl:if test="normalize-space(facsimile1)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(facsimile2)"/>
                                    </gco:CharacterString>
                                </gmd:facsimile>
                            </xsl:if>
                        </gmd:CI_Telephone>
                    </gmd:phone>
                    <gmd:address>
                        <gmd:CI_Address>
                            <gmd:deliveryPoint>
                                <xsl:if
                                    test="streetnumber='' and streetname='' and address='' and postbox=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="streetnumber"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="streetname"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="address"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="postbox"/>
                                </gco:CharacterString>
                            </gmd:deliveryPoint>
                            <gmd:city>
                                <xsl:if test="city=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="city"/>
                                </gco:CharacterString>
                            </gmd:city>
                            <gmd:administrativeArea>
                                <xsl:if test="state=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="state"/>
                                </gco:CharacterString>
                            </gmd:administrativeArea>
                            <gmd:postalCode>
                                <xsl:if test="zip=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="zip"/>
                                </gco:CharacterString>
                            </gmd:postalCode>
                            <gmd:country xsi:type="gmd:PT_FreeText_PropertyType">
                                <xsl:if test="country=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="country"/>
                                </gco:CharacterString>
                            </gmd:country>
                            <gmd:electronicMailAddress>
                                <xsl:if test="normalize-space(email)=''">
                                    <xsl:attribute name="gco:nilReason"
                                        >missing</xsl:attribute>
                                </xsl:if>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(email)"/>
                                </gco:CharacterString>
                            </gmd:electronicMailAddress>
                            <xsl:if test="email1!=''">
                                <gmd:electronicMailAddress>
                                    <xsl:if test="normalize-space(email1)=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(email1)"/>
                                    </gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </xsl:if>
                            <xsl:if test="email2!=''">
                                <gmd:electronicMailAddress>
                                    <xsl:if test="phone1=''">
                                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                                    </xsl:if>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(email2)"/>
                                    </gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </xsl:if>
                        </gmd:CI_Address>
                    </gmd:address>
                    <xsl:if test="onlineresource!=''">
                        <gmd:onlineResource>
                            <gmd:CI_OnlineResource>
                                <gmd:linkage>
                                    <gmd:URL><xsl:value-of select="onlineresource"/></gmd:URL>
                                </gmd:linkage>
                                <gmd:protocol>
                                    <gco:CharacterString>text/html</gco:CharacterString>
                                </gmd:protocol>
                                <gmd:name>
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="onlinename"/>
                </xsl:call-template>
                                </gmd:name>
                                <gmd:description>
                <xsl:call-template name="composeTranslations">
                    <xsl:with-param name="elem" select="onlinedescription"/>
                </xsl:call-template>
                                </gmd:description>
                            </gmd:CI_OnlineResource>
                        </gmd:onlineResource>
                    </xsl:if>
                    <xsl:if test="hoursofservice!=''">
                        <gmd:hoursOfService>
                            <gco:CharacterString>
                                <xsl:value-of select="hoursofservice"/>
                            </gco:CharacterString>
                        </gmd:hoursOfService>
                    </xsl:if>
                    <xsl:if test="contactinstructions!=''">
                        <gmd:contactInstructions>
                            <gco:CharacterString>
                                <xsl:value-of select="contactinstructions"/>
                            </gco:CharacterString>
                        </gmd:contactInstructions>
                    </xsl:if>
                </gmd:CI_Contact>
            </gmd:contactInfo>
            <gmd:role>
                <gmd:CI_RoleCode codeListValue="{/root/request/role}"
                    codeList="http://www.isotc211.org/2005/resources/codeList.xml#CI_RoleCode"/>
            </gmd:role>
        </gmd:CI_ResponsibleParty>
    </xsl:template>-->

</xsl:stylesheet>
