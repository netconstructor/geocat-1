<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="main.xsl"/>
    <xsl:include href="stylesheet-list.xsl"/>

    <!-- ================================================================================ -->
    <!-- additional scripts -->
    <!-- ================================================================================ -->
    <xsl:template mode="script" match="/">
        <script type="text/javascript" language="JavaScript">
            function init()
            {
                var modeValue = getModeValue();

                typeChanged();
                insertMode(modeValue);

                if (modeValue == 1)
                    updateForm();
            }

            function getModeValue()
            {
                for (var i=0; i &lt; document.xmlinsert.insert_mode.length; i++)
                {
                    if (document.xmlinsert.insert_mode[i].checked)
                    {
                        var modeValue = document.xmlinsert.insert_mode[i].value;
                    }
                }
                return modeValue;
            }

            function getFileValue()
            {
                for (var i=0; i &lt; document.xmlinsert.file_type.length; i++)
                {
                    if (document.xmlinsert.file_type[i].checked)
                    {
                        var fileValue = document.xmlinsert.file_type[i].value;
                    }
                }
                return fileValue;
            }

            function updateForm() {
                var fileType = getFileValue();

                if (fileType == 'single')       displayAllForm(true);
                else if (fileType == 'mef')     displayAllForm(false);
                else if (fileType == 'mef2')       displayMEF2Form();
            }

            function typeChanged()
            {
                var type = $F('metadata.type');

                if (type == 's')    Element.show('metadata.title');
                    else                Element.hide('metadata.title');
            }

            function insertMode(value){
                if (value == 0) {
                    Element.hide('gn.fileUp');
                    Element.show('gn.xmlUp');
                    $('gn.fileType').style.display='none';
                    $('gn.uuidAction').style.display='none';
                    document.xmlinsert.action=Env.locService+"/metadata.insert";
                    document.xmlinsert.target='_self';
                } else {
                    Element.hide('gn.xmlUp');
                    Element.show('gn.fileUp');
                    $('gn.fileType').style.display='';
                    $('gn.uuidAction').style.display='';
                    document.xmlinsert.enctype="multipart/form-data";
                    document.xmlinsert.action=Env.locService+"/mef.import";
                    document.xmlinsert.target='upFrame';
                }
            }

            function displayAllForm(show){
                var display;

                if (show == true)
                    display='';
                else
                    display='none';

                displayElement('gn.type',display);
                displayElement('gn.stylesheet',display);
                displayElement('gn.validate',display);
                displayElement('gn.groups',display);
                displayElement('gn.categories',display);
            }

            function displayMEF2Form(){
                var show ='';
                var hide ='none';

                displayElement('gn.type',hide);
                displayElement('gn.stylesheet',hide);
                displayElement('gn.validate',show);
                displayElement('gn.groups',show);
                displayElement('gn.categories',show);
            }

            function displayElement(id, value) {
                if ($(id))
                    $(id).style.display=value;
            }
            function submitInsertForm() {
                $('btInsert').disabled=true;
                goSubmit('xmlinsert');
            }
            function doFileUpload() {

                var response = $('upFrame').contentWindow.document;
                var elt;
                if (response.XMLDocument) {
                	elt = response.XMLDocument.selectSingleNode('ok');
                } else {
                	elt = response.getElementsByTagName('ok')[0];
                }
                var error = $('upFrame').contentWindow.document.getElementById('error');

                if (elt != null || error != null) {
                	$('btInsert').style.display='none';
                    $('gn.insertTable').style.display = 'none';
                	if (elt != null) {
						var id;
                		if (response.XMLDocument)
                			id= elt.text;
                		else
                			id = elt.firstChild.nodeValue;
                		createResponseForm(id);
                	} else if (error != null){
                		$('back').style.display='none';
                		displayError(error);
                	}
                    $('gn.result').style.display = 'block';
            	}
            }

            function createResponseForm(value) {
                var ids = value.split(";");
                var contentElt = $('gn.resultContent');

                for (var i=0; i &lt; ids.length - 1; i++) {

                    var id = document.createTextNode(ids[i]);
                    var element = document.createElement("a");
                    var space = document.createTextNode("&#160;");

                    element.setAttribute("href", Env.locService+"/metadata.show?id="+ids[i]+"&amp;currTab=simple");
                    element.appendChild(id);
                    contentElt.appendChild(element);
                    contentElt.appendChild(space);
                }

            }

            function displayError(errorDiv) {
            	var content = $('gn.resultContent');
            	$('gn.resultTitle').innerHTML = "" ;
           		if (!$('error')) {
           			$('gn.resultContent').innerHTML = errorDiv.innerHTML;
           			$('goBack').onclick = function () {
           				load('metadata.xmlinsert.form');
           			};
           		}
            }


        </script>
    </xsl:template>

    <!-- ================================================================================ -->
    <!-- page content   -->
    <!-- ================================================================================ -->

    <xsl:template name="content">
        <xsl:call-template name="formLayout">
            <xsl:with-param name="title" select="/root/gui/strings/xmlInsert"/>
            <xsl:with-param name="content">
                <form name="xmlinsert" accept-charset="UTF-8" method="post" enctype="multipart/form-data" action="{/root/gui/locService}/metadata.insert">
                    <input type="submit" style="display: none;" />
                    <table id="gn.insertTable">
                        <tr>
                            <th class="padded" valign="top"><xsl:value-of select="/root/gui/strings/insertMode"/></th>
                            <td>
                                <table>
                                    <tr>
                                        <td class="padded" colspan="2">
                                            <input type="radio" id="insertFileMode" name="insert_mode" value="1"
                                                onclick="insertMode(this.value)" checked="true"/>
                                            <label for="insertFileMode"><xsl:value-of select="/root/gui/strings/insertFileMode"/></label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="gn.fileType">
                            <th class="padded" valign="top"><xsl:value-of select="/root/gui/strings/fileType"/></th>
                            <td>
                                <table>
                                    <tr>
                                        <td class="padded">
                                            <input type="radio" id="singleFile" name="file_type" value="single" onclick="displayAllForm(this.checked)" checked="true"/>
                                            <label for="singleFile"><xsl:value-of select="/root/gui/strings/singleFile"/></label>
                                            <xsl:text>&#160;</xsl:text>
                                        </td>
                                        <td class="padded">
                                            <input type="radio" id="mefFile" name="file_type" value="mef" onclick="displayAllForm(false)"/>
                                            <label for="mefFile"><xsl:value-of select="/root/gui/strings/mefFile"/></label>
                                            <xsl:text>&#160;</xsl:text>
                                        </td>
                                        <td class="padded">
                                            <input type="radio" id="mef2File" name="file_type" value="mef2" onclick="displayMEF2Form()"/>
                                            <label for="mef2File"><xsl:value-of select="/root/gui/strings/mef2File"/></label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th class="padded" valign="top"><xsl:value-of select="/root/gui/strings/metadata"/></th>
                            <td class="padded">
                                <span id="gn.xmlUp" style="display:none">
                                    <textarea class="content" name="data" cols="80" rows="20"/>
                                </span>
                                <span id="gn.fileUp" style="display:none">
                                    <input type="file" accept="*.xml, *.zip, *.mef" class="content" size="60" name="mefFile" value=""/>
                                </span>
                            </td>
                        </tr>
                        <!-- uuid constraints -->
                        <tr id="gn.uuidAction">
                            <th class="padded" valign="top"><xsl:value-of select="/root/gui/strings/uuidAction"/></th>
                            <td>
                                <table>
                                    <tr>
                                        <td class="padded">
                                            <input type="radio" id="generateUUID" name="uuidAction" value="generateUUID" checked="true" />
                                            <label for="generateUUID"><xsl:copy-of select="/root/gui/strings/generateUUID/*"/></label>
                                            <xsl:text>&#160;</xsl:text>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="padded">
                                            <input type="radio" id="nothing" name="uuidAction" value="nothing"/>
                                            <label for="nothing"><xsl:value-of select="/root/gui/strings/nothing"/></label>
                                            <xsl:text>&#160;</xsl:text>
                                        </td>
                                    </tr><tr>
                                        <td class="padded">
                                            <input type="radio" id="overwrite" name="uuidAction" value="overwrite" />
                                            <label for="overwrite"><xsl:value-of select="/root/gui/strings/overwrite"/></label>
                                            <xsl:text>&#160;</xsl:text>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <!-- type -->
                        <tr id="gn.type">
                            <th class="padded" valign="top"><xsl:value-of select="/root/gui/strings/type"/></th>
                            <td>
                                <select class="content" name="template" size="1" id="metadata.type" onchange="typeChanged()">
                                    <option value="n"><xsl:value-of select="/root/gui/strings/metadata"/></option>
                                    <option value="y"><xsl:value-of select="/root/gui/strings/template"/></option>
                                    <!-- <option value="s"><xsl:value-of select="/root/gui/strings/subtemplate"/></option> -->
                                </select>
                                <div id="metadata.title">
                                    <xsl:text>&#160;</xsl:text>
                                    <xsl:value-of select="/root/gui/strings/subtemplateTitle"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <input class="content" type="text" name="title"/>
                                </div>
                            </td>
                        </tr>

                        <!-- stylesheet -->
                        <tr id="gn.stylesheet">
                            <th class="padded"><xsl:value-of select="/root/gui/strings/styleSheet"/></th>
                            <td class="padded">
                                <select class="content" id="styleSheet" name="styleSheet" size="1">
                                    <xsl:call-template name="stylesheet-list"/>
                                </select>
                            </td>
                        </tr>

                        <!-- validate -->

                        <tr id="gn.validate">
                            <th class="padded"><xsl:value-of select="/root/gui/strings/validate"/></th>
                            <td><input class="content" type="checkbox" name="validate"/></td>
                        </tr>

                        <!-- groups -->

                        <xsl:variable name="lang" select="/root/gui/language"/>

                        <tr id="gn.groups">
                            <th class="padded"><xsl:value-of select="/root/gui/strings/group"/></th>
                            <td class="padded">
                                <select class="content" name="group" size="1">
                                    <xsl:for-each select="/root/gui/groups/record">
                                        <xsl:sort select="label/child::*[name() = $lang]"/>
                                        <option value="{id}">
                                            <xsl:value-of select="label/child::*[name() = $lang]"/>
                                        </option>
                                    </xsl:for-each>
                                </select>
                            </td>
                        </tr>

                        <!-- categories -->
                        <tr id="gn.categories">
                            <th class="padded"></th>
                            <td class="padded">
                                <input type="hidden" name="category" value="_none_"/>
                            </td>
                        </tr>
                    </table>
                    <iframe id="upFrame" name="upFrame" width="200p" height="100p" onload="javascript:doFileUpload();" style="display:none;" />
                    <table id="gn.result" style="display:none;">
                    <tr>
                        <th id="gn.resultTitle" class="padded-content">
                            <h2><xsl:value-of select="/root/gui/strings/newMdInsert" /></h2>
                        </th>
                        <td id="gn.resultContent" class="padded-content" />
                    </tr>
                    </table>
                </form>
            </xsl:with-param>
            <xsl:with-param name="buttons">
                <button class="content" onclick="goBack()" id="back"><xsl:value-of select="/root/gui/strings/back"/></button>
                &#160;
                <button class="content" onclick="javascript:submitInsertForm()" id="btInsert"><xsl:value-of select="/root/gui/strings/insert"/></button>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- ================================================================================ -->

</xsl:stylesheet>
