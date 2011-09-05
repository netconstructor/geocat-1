<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:include href="main.xsl"/>
	<xsl:include href="stylesheet-list.xsl"/>

    <xsl:template mode="script" match="/">
        <script type="text/javascript" language="JavaScript">
            
            var schema = new Array (
            <xsl:for-each select="/root/gui/schemas/name">
               <xsl:sort select="."/>
                "<xsl:value-of select="."/>"<xsl:if test="position()!=last()">,</xsl:if>
            </xsl:for-each>);
            
            // Update schema according to stylesheet selected (ie. styleSheet MUST end with schemaName.xsl)
            function updateSchema() {
                var xsl = $('styleSheet').options[$('styleSheet').selectedIndex].value;
                for (i = 0; i &lt; schema.length; i ++) { 
                    if (xsl.toLowerCase().lastIndexOf(schema[i]+'.xsl') != -1) {
                        $('schema').selectedIndex = i;
                        return;
                    }
                 }
                 $('schema').selectedIndex = 0;      
            }
        
        </script>
    </xsl:template>
    
	<!--
	page content
	-->
	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title" select="/root/gui/strings/batchImport"/>
			<xsl:with-param name="content">
				<xsl:call-template name="form"/>
			</xsl:with-param>
			<xsl:with-param name="buttons">
				<button class="content" onclick="goBack()"><xsl:value-of select="/root/gui/strings/back"/></button>
				&#160;
				<button class="content" onclick="goSubmit('xmlbatch')"><xsl:value-of select="/root/gui/strings/upload"/></button>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="form">
		<form name="xmlbatch" accept-charset="UTF-8" action="{/root/gui/locService}/util.import" method="post">
			<input type="submit" style="display: none;" />
			
			<table>
				<tr>
					<th class="padded"><xsl:value-of select="/root/gui/strings/directory"/></th>
					<td class="padded"><input class="content" type="text" size="50" name="dir"/></td>
				</tr>
				
                <!-- transformation stylesheet -->
				<tr id="gn.fileType">
					<th class="padded" valign="top"><xsl:value-of select="/root/gui/strings/fileType"/></th>
					<td>
						<table>
							<tr>
								<td class="padded">
									<label for="singleFile"><xsl:value-of select="/root/gui/strings/singleFile"/></label>
									<input type="radio" id="singleFile" name="file_type" value="single" checked="true"/>
								</td>
								<td class="padded">
									<label for="mefFile"><xsl:value-of select="/root/gui/strings/mefFile"/></label>
									<input type="radio" id="mefFile" name="file_type" value="mef"/>
								</td>
							</tr>
						</table>
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
								</td>
							</tr><tr>
								<td class="padded">
									<input type="radio" id="overwrite" name="uuidAction" value="overwrite" />
									<label for="overwrite"><xsl:value-of select="/root/gui/strings/overwrite"/></label>
								</td>
							</tr>
						</table>
					</td>
				</tr>
                <tr>
                    <th class="padded"><xsl:value-of select="/root/gui/strings/styleSheet"/></th>
                    <td class="padded">
                        <select class="content" name="styleSheet" id="styleSheet" size="1" onchange="updateSchema();">
                            <xsl:call-template name="stylesheet-list"/>
                        </select>
                    </td>
                </tr>
				<tr>
					<th class="padded"><xsl:value-of select="/root/gui/strings/validate"/></th>
					<td><input class="content" type="checkbox" name="validate"/></td>
				</tr>
				
				<!-- groups -->
				
				<xsl:variable name="lang" select="/root/gui/language"/>

				<tr>
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
		</form>
	</xsl:template>

</xsl:stylesheet>
