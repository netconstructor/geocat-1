<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:geonet="http://www.fao.org/geonetwork">

	<!--
	edit metadata form
	-->
	<xsl:include href="main.xsl"/>
	<xsl:include href="metadata.xsl"/>
	<xsl:include href="metadata-validation-report.xsl"/>
	<xsl:include href="mapfish_includes.xsl" />

	<!--
	additional scripts
	-->
	<xsl:template mode="script" match="/">
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/prototype.js"></script>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/ed.js"></script>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/scriptaculous/scriptaculous.js?load=slider,effects,controls"/>

	    <xsl:call-template name="mapfish_includes"/>
	    <xsl:call-template name="extentViewerJavascript"/>
        <link rel="stylesheet" type="text/css" href="{/root/gui/url}/scripts/not-migrated/ext-ux/MultiselectItemSelector-3.0/Multiselect.css" />
        <script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/ext-ux/MultiselectItemSelector-3.0/Multiselect.js"></script>
        <script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/ext-ux/MultiselectItemSelector-3.0/DDView.js"></script>
        <script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/ext-ux/TwinTriggerComboBox/TwinTriggerComboBox.js"></script>

        <script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/editor/KeywordSelectionPanel.js"></script>

        <xsl:call-template name="js-translations"/>
		<script language="JavaScript1.2" type="text/javascript">
            var inAction = false;

            function createNewExtent() {
                var format = Ext.get('extent.format').getValue();
                var inclusion = Ext.get('extent.type.code').getValue();

                var loc = window.location;
                $('href').value = loc.protocol+'//'+loc.host+Env.locService+'/xml.extent.get?wfs=default&amp;typename=gn:non_validated&amp;id=createNewExtent&amp;format='+format+'&amp;extentTypeCode='+inclusion;

				doAction('metadata.xlink.add');
            }

			function submitXLink() {
                // Move xlink element to mainForm before submit
                var el = Ext.get("keywordList").select("input.href");
                var hiddenFormElements = Ext.get("hiddenFormElements");
                el.each(function(item) { hiddenFormElements.insertFirst(item); });

				// Check xlink exist
				// FIXME : should check only non empty one and selected
				if (($('href') == undefined || $('href').value == '') &amp;&amp;
					($('href_1') == undefined || $('href_1').value == '')) {
					alert("<xsl:value-of select="/root/gui/strings/noXlink"/>");
					return;
				}
                
                if( $('href').value.contains("&amp;&amp;") ){
                    $('href').value = $('href').value.replace("&amp;&amp;","&amp;") 
                }
                // Submit form
				doAction('metadata.xlink.add');
			}


			// findPos comes from http://www.quirksmode.org
			// prototype 1.6 will make findPos redundant
			function findPos(obj) {
				var curtop = 0;
				if (obj.offsetParent) {
					do {
								curtop += obj.offsetTop;
					} while (obj = obj.offsetParent);
				}
				return curtop;
			}

			function doActionInWindow(action)
			{
				// alert("In doAction(" + action + ")"); // DEBUG
				popWindow('about:blank');
				document.mainForm.action = action;
				oldTarget = document.mainForm.target;
				document.mainForm.target = 'popWindow';
				goSubmit('mainForm');
				document.mainForm.target = oldTarget;
			}

			function doAction(action)
			{
                if (inAction) {              
                    return;
                }

				// alert("In doAction(" + action + ")"); // DEBUG
				document.mainForm.action = action;
				goSubmit('mainForm');

                inAction = true;
			}

            function doActionReset() {
                if (inAction) {
                    return;
                }

                inAction = true;
                goReset('mainForm');
                inAction = false;
            }

			function doTabAction(action, tab)
			{
				// alert("In doTabAction(" + action + ", " + tab + ")"); // DEBUG
				document.mainForm.currTab.value = tab;
				doAction(action);
			}

			function doElementAction(action, ref, id, offset)
			{
				var top = findPos($(id));
				//alert("In doElementAction(" + action + ", " + ref + ", " + offset + ")"); // DEBUG
				document.mainForm.ref.value = ref;
				document.mainForm.position.value = top + offset;
				doAction(action);
			}

			function doMoveElementAction(action, ref, id)
			{
				var top = findPos($(id));
				// position at top of both elements -
				// ie. if up then subtract height of previous sibling - if down then
				// do nothing
				if (action.include('elem.up')) {
					var prev = $(id).previous();
					top = top - prev.getHeight();
					// alert("in doMoveElementAction " + prev.inspect() + ")");
				}
				document.mainForm.ref.value = ref;
				document.mainForm.position.value = top;
				doAction(action);
			}

			function doNewElementAction(action, ref, name, id)
			{
				document.mainForm.name.value = name;
				var offset = 0;
				var buttons = $(id).getElementsBySelector('a#button'+id);
				var blocks = $(id).getElementsBySelector('fieldset');
				// calculate offset to scroll screen down so added element is at top
				if (buttons.length > 1 || blocks.length > 0) {
					offset = $(id).getHeight();
				}
				//alert("In doNewElementAction ( " + $(id).inspect() + ", " + buttons.inspect() + ", " + blocks.inspect() + ", " + offset + ")");
				doElementAction(action, ref, id, offset);
			}

			function doNewORElementAction(action, ref, name, child, id)
			{
				// alert("In doNewORElementAction(" + action + ", " + ref + ", " + name + ", " + child + ", " + id + ")"); // DEBUG
				document.mainForm.child.value = child;
				document.mainForm.name.value = name;
				doElementAction(action, ref, id, 0);
			}

			function doConfirm(action, message)
			{
				// alert("In doConfirm(" + action + ", " + message + ")"); // DEBUG
				if(confirm(message))
				{
					doAction(action);
					return true;
				}
				return false;
			}

			function doFileUploadAction(action, ref, fname, access, id)
			{
				var top = findPos($(id));
				// alert("In doFileUploadAction(" + action + ", " + ref + ", " + fname + ")"); // DEBUG

				if (fname.indexOf('/') > -1)
					fname = fname.substring(fname.lastIndexOf('/') + 1, fname.length);
				else
					fname = fname.substring(fname.lastIndexOf('\\') + 1, fname.length);

				document.mainForm.fname .value = fname;
				document.mainForm.access.value = access;
				document.mainForm.ref   .value = ref;
				document.mainForm.position.value = top;
				document.mainForm.action = action;
				document.mainForm.enctype="multipart/form-data";
				document.mainForm.encoding="multipart/form-data";
				goSubmit('mainForm');
			}

			function doFileRemoveAction(action, ref, access, id)
			{
				// alert("In doFileRemoveAction(" + action + ", " + ref + ")"); // DEBUG
				document.mainForm.access.value = access;
				doElementAction(action, ref, id, 0);
			}

			function setRegion(westField, eastField, southField, northField, choice)
			{
				// alert(westField.name + ", " + eastField.name + ", " + southField.name + ", " + northField.name + " set to " + choice); // FIXME

				if (choice != "")
				{
					coords = choice.split(";");
					westField.value  = coords[0];
					eastField.value  = coords[1];
					southField.value = coords[2];
					northField.value = coords[3];
				}
				else
				{
					westField.value  = "";
					eastField.value  = "";
					southField.value = "";
					northField.value = "";
				}
			}

			function scrollIt()
			{
				window.scroll(0,<xsl:value-of select="/root/gui/position"/>);
			}

			// override the body onLoad init() function in geonetwork.js
			function onloadinit()
			{
                validateMetadataFields();
				timeId = setTimeout('scrollIt()',1000);
				<!-- <xsl:message>POSITION: <xsl:value-of select="/root/gui/position"/></xsl:message>
-->
			}
			Event.observe(window,'load',onloadinit);


            function validateMetadataFields() {
                $$('input,textarea').each(function(input) {
                    if (input.onkeyup) input.onkeyup();
                });
            }

	        function enableLocalInput(node, focus) {
	            var ref = node.value;
	            var parent = node.parentNode.parentNode;
	            var nodes = parent.getElementsByTagName("input");
	            var textarea = parent.getElementsByTagName("textarea");

	            show(nodes,ref,focus);
	            show(textarea,ref,focus);

	        };

	        function show(nodes,ref,focus){
	           for ( index in nodes ) {
	             var input = nodes[index];
	              if( input.style!=null &amp;&amp; input.style.display != "none" ) input.style.display = "none";
	          }
	          for ( index in nodes ) {
	                var input = nodes[index];
	                if( input.name == ref ){
                        input.style.display = "block";
                        if(focus) input.focus();
                    }
	            }
	        }
	        /**
	         * Build duration format
	         *
	         * Format: PnYnMnDTnHnMnS
	         */
	        function buildDuration(ref){
	        	if ($('Y'+ref).value=='')
	        		$('Y'+ref).value = 0;
        		if ($('M'+ref).value=='')
	        		$('M'+ref).value = 0;
        		if ($('D'+ref).value=='')
	        		$('D'+ref).value = 0;
	       		if ($('H'+ref).value=='')
	        		$('H'+ref).value = 0;
	       		if ($('MI'+ref).value=='')
	        		$('MI'+ref).value = 0;
        		if ($('S'+ref).value=='')
	        		$('S'+ref).value = 0;

	        	$('_'+ref).value =
	        		($('N'+ref).checked?"-":"") +
	        		"P" +
	        		$('Y'+ref).value + "Y" +
	        		$('M'+ref).value + "M" +
	        		$('D'+ref).value + "DT" +
	        		$('H'+ref).value + "H" +
	        		$('MI'+ref).value + "M" +
	        		$('S'+ref).value + "S";
	        }

            /**
             * Check that GM03 distance are between 0.00 .. 9999999999.99
             */
            function validateGM03Distance(input, nullValue, noDecimals){
	            
	            if (validateNumber(input, nullValue, noDecimals)) {
	            
    	            var value = Number(input.value);
    	            if (value &lt; 0.00 || value &gt; 9999999999.99) {
        	            enableSave(false);
        	            input.addClassName('error');
        	            return false;
    	            } else {
        	            enableSave(true);
        	            input.removeClassName('error');
        	            return true;
    	            }
    	        } else 
    	            return false;
    	        
	        }
	        /**
	         * Validate Interlis NAME
	         * (composed of letters and digits, starting with a letter, ili-Refmanual, p. 23)
	         */
	        function validateGM03NAME(input){
	            var text = input.value.toUpperCase();
	            var validDigits = "0123456789";
	            var validChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	            var chars = validChars + validDigits;
	            var valid = true;
	            if (text.length &gt; 0) {
	                var firstChar = text.charAt(0);
	                if (validChars.indexOf(firstChar) == -1)
	                    valid = false;
	            }
	            for (i = 0; i &lt; text.length; i++) {
	                char = text.charAt(i);
	                if (chars.indexOf(char) == -1)
                        valid = false;
                }
                
                if(!valid ){
                    enableSave(false);
                    input.addClassName('error');
                    return false;
                }else{
                    enableSave(true);
                    input.removeClassName('error');
                    return true;
                }
	            
	            console.log(text);
	        }
	        function validateNumber(input, nullValue, noDecimals){
	          var text = input.value
	          var validChars = "0123456789";

	          if( !nullValue ) {
	          	if ( !validateNonEmpty(input) )
	          		return false;
	          }

	          if( !noDecimals ) validChars += '.'
			   var isNumber=true;
			   var char;


			   for (i = 0; i &lt; text.length &amp;&amp; isNumber; i++)
			      {
			      char = text.charAt(i);
			      if(char=='-' || char=="+" ){
			         if( i&gt;0 )  isNumber=false;
			      }else if (validChars.indexOf(char) == -1)
			         {
			         isNumber = false;
			         }
			      }
                if(!isNumber ){
                    enableSave(false);
                    input.addClassName('error');
                    return false;
                }else{
                    enableSave(true);
                    input.removeClassName('error');
                    return true;
                }
	        }
            function validateNonEmpty(input){
                if (input.value.length &lt; 1) {
                    enableSave(false);
                    input.addClassName('error');
                    return false;
                } else {
                    enableSave(true);
                    input.removeClassName('error');
                    return true;
                }
            }

	        function enableSave(enable){
                return; // users should be able to save anyway
                var saveButton = $('saveButton')
                saveButton.disabled = !enable;
                $('saveAndCloseButton').disabled = !enable;
	        }


            var updateDatasetTitle = '<xsl:value-of select="/root/gui/strings/updateDatasetTitle" />';
            var updateDatasetMsg = '<xsl:value-of select="/root/gui/strings/updateDatasetMsg" />';

		</script>
		<style type="text/css">@import url(<xsl:value-of select="/root/gui/url"/>/scripts/not-migrated/calendar/calendar-blue2.css);</style>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/calendar/calendar.js"></script>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/calendar/lang/calendar-en.js"></script>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/calendar/calendar-setup.js"></script>

		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/core/kernel/kernel.js"/>
		<script type="text/javascript" src="{/root/gui/url}/scripts/not-migrated/editor/tooltip-manager.js"></script>

	</xsl:template>

	<!--
	page content
	-->
	<xsl:template name="content">
		<table  width="100%" height="100%">
			<xsl:for-each select="/root/*[name(.)!='gui' and name(.)!='request']"> <!-- just one -->
				<xsl:variable name="locales" select="//gmd:locale"/>

				<xsl:variable name="localesValue">
					<xsl:for-each select="$locales//gmd:PT_Locale">
						<xsl:value-of select="@id"/>
						<xsl:if test="position()!=last()">,</xsl:if>
					</xsl:for-each>
				</xsl:variable>


				<tr height="100%">
					<td class="blue-content" width="150" valign="top">
						<xsl:call-template name="tab">
							<xsl:with-param name="tabLink" select="concat(/root/gui/locService,'/metadata.update')"/>
							<xsl:with-param name="edit" select="true()"/>
						</xsl:call-template>
					</td>
					<td class="content" valign="top">
						<form id="mainForm" name="mainForm" accept-charset="UTF-8" method="POST" action="{/root/gui/locService}/metadata.update">
							<input type="hidden" id="id" name="id" value="{geonet:info/id}"/>
							<input type="hidden" id="version" name="version" value="{geonet:info/version}"/>
							<input type="hidden" id="ref" name="ref"/>
							<input type="hidden" name="name"/>
							<input type="hidden" name="child"/>
							<input type="hidden" name="fname"/>
							<input type="hidden" name="access"/>
							<input type="hidden" name="position"/>
							<input type="hidden" name="currTab" value="{/root/gui/currTab}"/>

							<!-- Use for metadata for service  -->
							<input type="hidden" name="srvIds" id="srvIds"/>
							<input type="hidden" name="datasetIds" id="datasetIds"/>
							<input type="hidden" name="upMdd" id="upMdd"/>
							<input type="hidden" name="srvScopedName" id="srvScopedName"/>

							<!-- Use for adding xlink -->
							<input type="hidden" id="xlink.schema" name="schema" value="{geonet:info/schema}"/>
							<input type="hidden" id="xlink.type" name="type" value="simple"/>
							<input type="hidden" id="xlink.show" name="show" value="embed"/>
							<input type="hidden" id="xlink.role" name="role" value="embed"/>
							<input type="hidden" id="xlink.geom" name="geom" value="none"/>
							<input type="hidden" id="href" name="href" value=""/>
							<input type="hidden" id="keyword.locales" name="keyword.locales" value="{$localesValue}"/>
							<!-- Hidden div to contains extra elements like when posting multiple keywords. -->
							<div id="hiddenFormElements" style="display:none;"/>

							<table width="100%">
								<tr><td class="padded-content" height="100%" align="center" valign="top">
									<xsl:call-template name="editButtons"/>
								</td></tr>
								<tr><td class="padded-content">
									<table class="md" width="100%">
										<xsl:choose>
											<xsl:when test="$currTab='xml'">
												<xsl:apply-templates mode="xmlDocument" select=".">
													<xsl:with-param name="edit" select="true()"/>
												</xsl:apply-templates>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates mode="elementEP" select=".">
													<xsl:with-param name="edit" select="true()"/>
												</xsl:apply-templates>
											</xsl:otherwise>
										</xsl:choose>
									</table>
								</td></tr>
								<tr><td class="padded-content" height="100%" align="center" valign="top">
									<xsl:call-template name="templateChoice"/>
								</td></tr>
								<tr><td class="padded-content" height="100%" align="center" valign="top">
									<xsl:call-template name="editButtons"/>
								</td></tr>
							</table>


							<xsl:call-template name="xlinkSelector">
								<xsl:with-param name="locales" select="$locales"/>
							</xsl:call-template>
						</form>

						<xsl:call-template name="catSearcher"/>

						<xsl:call-template name="metadata-validation-report">
							<xsl:with-param name="metadata" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:for-each>
			<tr><td class="blue-content" colspan="3"/></tr>
		</table>

	</xsl:template>

	<xsl:template name="editButtons" match="*">

		<!-- save button -->
		<button class="content" id="saveButton" onclick="doAction('{/root/gui/locService}/metadata.update')">
			<xsl:value-of select="/root/gui/strings/save"/>
		</button>

        <!-- reset button -->
        &#160;
        <button class="content" onclick="doActionReset(); return false;"><xsl:value-of select="/root/gui/strings/reset"/></button>

		<!-- save and close button -->
		&#160;
		<button class="content" id="saveAndCloseButton" onclick="doAction('{/root/gui/locService}/metadata.update.finish')">
			<xsl:value-of select="/root/gui/strings/saveAndClose"/>
		</button>

		<!-- thumbnails -->
		<xsl:if test="string(geonet:info/schema)='iso19115' or starts-with(string(geonet:info/schema),'iso19139')"> <!-- FIXME: should be more general -->
			&#160;
			<button class="content" onclick="doAction('{/root/gui/locService}/metadata.thumbnail.form')">
				<xsl:value-of select="/root/gui/strings/thumbnails"/>
			</button>
		</xsl:if>

		<!-- create button -->
		<xsl:if test="string(geonet:info/isTemplate)!='s' and (geonet:info/isTemplate='y' or geonet:info/source=/root/gui/env/site/siteId) and /root/gui/services/service/@name='metadata.duplicate.form'">
			&#160;
			<button class="content" onclick="load('{/root/gui/locService}/metadata.duplicate.form?id={geonet:info/id}')">
				<xsl:value-of select="/root/gui/strings/create"/>
			</button>
		</xsl:if>

		<!-- cancel button -->
		&#160;
		<button class="content" onclick="doAction('{/root/gui/locService}/metadata.show')">
			<xsl:value-of select="/root/gui/strings/cancel"/>
		</button>


		<!-- validate button
			&#160;
			<button class="content" onclick="displayValidationReportBox();">
			<xsl:value-of select="/root/gui/strings/saveAndValidate"/>
			</button>-->

	</xsl:template>

	<xsl:template name="templateChoice" match="*">

		<b><xsl:value-of select="/root/gui/strings/type"/></b>
		<xsl:text>&#160;</xsl:text>
		<select class="content" name="template" size="1">
			<option value="n">
				<xsl:if test="string(geonet:info/isTemplate)='n'">
					<xsl:attribute name="selected">true</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="/root/gui/strings/metadata"/>
			</option>
			<option value="y">
				<xsl:if test="string(geonet:info/isTemplate)='y'">
					<xsl:attribute name="selected">true</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="/root/gui/strings/template"/>
			</option>
			<!-- <option value="s">
				<xsl:if test="string(geonet:info/isTemplate)='s'">
					<xsl:attribute name="selected">true</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="/root/gui/strings/subtemplate"/>
			</option> -->
		</select>
		<!--<xsl:text>&#160;</xsl:text>
		<xsl:value-of select="/root/gui/strings/subtemplateTitle"/>
		<xsl:text>&#160;</xsl:text>
		<input class="content" type="text" name="title" value="{geonet:info/title}"/>

		<input class="content" type="checkbox" name="template">
			<xsl:if test="geonet:info/isTemplate='y'">
				<xsl:attribute name="checked"/>
			</xsl:if>
			<xsl:value-of select="/root/gui/strings/template"/>
		</input>
		-->

	</xsl:template>



	<!--
		Div element to be use to select remote resources via XLink.
		See scripts/not-migrated/ed.js for javascript behaviour.
	-->
	<xsl:template name="xlinkSelector">
		<xsl:param name="locales"/>

	    <div id="popXLink" name="popXLink" style="display:none;width:460px;padding:10px">

            <!-- Almost common scripaculous autocompleter results div -->
            <div id='xll' class="keywordList"/>

            <div id="popXLink.contact">
                <xsl:value-of select="/root/gui/strings/popXlink.contact.search"/><br/>
                <input type="text" id="xlink-s-contact" value="" size="50" style="margin-top:2px;"/>
                <span id="xlink.contact.indicator" style="display:none;">
                    <img src="../../images/spinner.gif" alt="{/root/gui/strings/searching}" title="{/root/gui/strings/searching}"/>
                </span>
                <br/><br/>
                <!-- Codelist for contact role. CI_ResponsibleParty as to defined the role
                of the contact element.
                FIXME : in iso19139.che, role could be multiple.
                -->
                <xsl:value-of select="/root/gui/strings/popXlink.contact.role"/><br/>
                <select name="contact.role" id="contact.role" onChange="contactSetRole(this.options[this.selectedIndex].value);">
                    <!-- add point of contact first -->
                    <option value="pointOfContact">
                        <xsl:attribute name="selected"></xsl:attribute>
                        <xsl:value-of select="/root/gui/iso19139/codelist[@name='gmd:CI_RoleCode']/entry[code='pointOfContact']/label"/>
                     </option>

                    <!-- add the rest of elements --> 
                    <xsl:for-each select="/root/gui/iso19139/codelist[@name='gmd:CI_RoleCode']/entry">
                        <xsl:sort select="label" order="ascending"/>

                        <xsl:if test="code!='pointOfContact'">
                            <option value="{code}">
                                <xsl:value-of select="label"/>
                            </option>
                        </xsl:if>
                     
                    </xsl:for-each>
                </select>
                <br/><br/>
                <xsl:value-of select="/root/gui/strings/popXlink.contact.action"/><br/>
            </div>

            <div id="popXLink.format">
                <input type="text" id="xlink-s-format" value="" size="50" style="margin-top:2px;"/>
                <span id="xlink.format.indicator" style="display: none">
                    <img src="../../images/spinner.gif" alt="{/root/gui/strings/searching}" title="{/root/gui/strings/searching}"/>
                </span>
                <br/>
                <xsl:value-of select="/root/gui/strings/popXlink.about"/><br/>
                <!-- Autocompletion list -->
            </div>

            <div id="popXLink.keyword">
                <span id="xlink.keyword.indicator" style="display: none">
                    <img src="../../images/spinner.gif" alt="{/root/gui/strings/searching}" title="{/root/gui/strings/searching}"/>
                </span>
                <br/><br/>
                <xsl:value-of select="/root/gui/strings/popXlink.about"/>
                <br/><br/>
                <!-- Div which contains keyword list. -->
                <div id='keywordList' style="padding:2px;margin:2px;"/>
            </div>

            <div id="popXLink.extent">
                <input type="text" id="xlink-s-extent" value="" size="50" style="margin-top:2px;"/>
                <span id="xlink.extent.indicator" style="display: none">
                    <img src="../../images/spinner.gif" alt="{/root/gui/strings/searching}" title="{/root/gui/strings/searching}"/>
                </span>
                <br/><br/>
                <xsl:value-of select="/root/gui/strings/popXlink.about"/>
                <br/><br/>
                <!-- Autocompletion list -->
                <!--div id="extent.map" style="width:300px; height:250px;"></div-->
                <select name="extent.format" id="extent.format" onChange="extentSetFormat(this.options[this.selectedIndex].value);" style="display:none;">
                    <option value="gmd_bbox"><xsl:value-of select="/root/gui/strings/extentBbox"/></option>
                    <!--<option value="gmd_polygon" selected="true"><xsl:value-of select="/root/gui/strings/extentPolygon"/></option>-->
                    <option value="gmd_complete" selected="true"><xsl:value-of select="/root/gui/strings/extentBboxAndPolygon"/></option>
                </select>
                <select name="extent.type.code" id="extent.type.code" onChange="extentTypeCode(this.options[this.selectedIndex].value);">
                    <option value="true"><xsl:value-of select="/root/gui/strings/boolean[@context='gmd:extentTypeCode' and @value=true()]"/></option>
                    <option value="false"><xsl:value-of select="/root/gui/strings/boolean[@context='gmd:extentTypeCode' and @value='false']"/></option>
                </select>
            </div>

            <!-- common buttons -->
            <button onClick="javascript:submitXLink();"><xsl:value-of select="/root/gui/strings/add"/></button> &#160;
            <button id="common.xlink.create" onClick="javascript:doNewElementAction('metadata.elem.add', dialogRequest.ref, dialogRequest.name, dialogRequest.id);"><xsl:value-of select="/root/gui/strings/xlink.new"/></button>
            <button id="extent.xlink.create" onClick="javascript:createNewExtent();"><xsl:value-of select="/root/gui/strings/xlink.newGeographic"/></button>
		</div>
	</xsl:template>

	<!--
		Div element to be use to select remote parent metadata record.
		See scripts/not-migrated/ed.js for javascript behaviour.
	-->
	<xsl:template name="catSearcher">
		<xsl:param name="category"/>
		<div id="popSearcher" name="popSearcher" style="display:none;width:500px;">
			<fieldset>
				<table>
					<tr>
						<td style="width:65%;">
							<input type="text" id="any" name="any"/>
							<input type="button" value="{/root/gui/strings/search}" onclick="javascript:GNSearcher.search();"/>
							<div id="catResults" name="catResults"/>
							<div id="scopedDesc" style="display:none;">
								<br/>
								<label>
									<xsl:value-of select="/root/gui/strings/scopedName"/>
									<xsl:text> :</xsl:text>
								</label>
								<input type="text" name="scopedName" id="scopedName"/>
								<br/>
							</div>
							<div id="mdsButton" style="display:none">
								<input id="createAsso" name="createAsso" type="button" value="{/root/gui/strings/createAssoService}"
									onclick="javascript:updateMDforServices();" disabled="disabled"/>
								<br/>
								<input id="updateMDD" name="updateMDD" type="checkbox" />
								<label for="updateMDD"><xsl:value-of select="/root/gui/strings/updateMdd"/></label>
								<br/><br/>
							</div>
							<div id="mddButton" style="display:none">
								<!-- Get Service URL from GetCapabilities Operation, if null from distribution information-->
								<xsl:variable name="url">
									<xsl:value-of select="//gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata[srv:operationName/gco:CharacterString='GetCapabilities']/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL|
										//gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:containsOperations/srv:SV_OperationMetadata[srv:operationName/gco:CharacterString='GetCapabilities']/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
								</xsl:variable>


								<!-- TODO : here we could use service type and version if
									GetCapabilities url is not complete with parameter. -->
								<xsl:variable name="parameters">&amp;SERVICE=WMS&amp;VERSION=1.1.1&amp;REQUEST=GetCapabilities</xsl:variable>

								<!-- Try to build a valid capabilities URL -->
								<xsl:variable name="capabilitiesUrl">
									<xsl:choose>
										<xsl:when test="$url=''">
											<xsl:value-of select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
											<xsl:if test="not(contains(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL, '?'))">
												<xsl:text>?</xsl:text>
											</xsl:if>
											<xsl:value-of select="$parameters"/>
										</xsl:when>
										<xsl:when test="not(contains($url, '?'))">
											<xsl:value-of select="$url"/>?<xsl:value-of select="$parameters"/>
										</xsl:when>
										<xsl:when test="not(contains($url, 'GetCapabilities'))">
											<xsl:value-of select="$url"/><xsl:value-of select="$parameters"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$url"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:text> </xsl:text>
								(<xsl:choose>
									<xsl:when test="$capabilitiesUrl and starts-with($capabilitiesUrl, 'http://')">
										<a target="getCapabilities"
											alt="{/root/gui/strings/viewCapabilitiesHelp}"
											title="{/root/gui/strings/viewCapabilitiesHelp}"
											href="{$capabilitiesUrl}">
											<xsl:value-of select="/root/gui/strings/viewCapabilities"/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="/root/gui/strings/noCapabilities"/>
									</xsl:otherwise>
								</xsl:choose>)
								<br/>

								<input id="createAssoCoupledResource" name="createAssoCoupledResource" type="button" value="{/root/gui/strings/associateDataset}"
									onclick="javascript:updateCoupledResourceforServices();" disabled="disabled"/>
							</div>
						</td>
						<td style="width:30%;">
							<div id="mddInfo" style="display:none;">
								<xsl:copy-of select="/root/gui/strings/createAssoServiceHelp"/>
							</div>
						</td>
					</tr>
				</table>

			</fieldset>
			<div id="createService" name="createService" style="display:none;">
				<br/><br/>
				<fieldset>
					<legend>
						<xsl:value-of select="/root/gui/strings/serviceCreate"/>
					</legend>
					<input type="button" value="{/root/gui/strings/serviceCreate}" onclick="window.open('metadata.create.form?any=service', 'editor');"/>
				</fieldset>
			</div>
			<div id="createDataset" name="createDataset" style="display:none;">
				<br/><br/>
				<fieldset>
					<legend>
						<xsl:value-of select="/root/gui/strings/datasetCreate"/>
					</legend>
					<input type="button" value="{/root/gui/strings/datasetCreate}" onclick="window.open('metadata.create.form?any=dataset', 'editor');"/>
				</fieldset>
			</div>
		</div>
	</xsl:template>


</xsl:stylesheet>
