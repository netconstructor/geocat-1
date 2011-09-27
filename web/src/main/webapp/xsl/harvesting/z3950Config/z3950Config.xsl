<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- ============================================================================================= -->
	<!-- === editPanel -->
	<!-- ============================================================================================= -->

	<xsl:template name="editPanel-Z3950Config">
		<div id="z3950Config.editPanel">
			<xsl:call-template name="site-Z3950Config"/>
			<div class="dots"/>
			<xsl:call-template name="search-Z3950Config"/>
			<div class="dots"/>
			<xsl:call-template name="options-Z3950Config"/>
			<div class="dots"/>
			<xsl:call-template name="content-Z3950Config"/>
			<div style="display:none;"> // make these invisible as we don't need them
				<div class="dots"/>
				<xsl:call-template name="privileges-Z3950Config"/>
				<div class="dots"/>
				<xsl:call-template name="categories-Z3950Config"/>
			</div>
		</div>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="site-Z3950Config">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/site"/></h1>

		<table>
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/name"/></td>
				<td class="padded"><input id="z3950Config.name" class="content" type="text" value="" size="30"/></td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/host"/></td>
				<td class="padded"><input id="z3950Config.host" class="content" type="text" value="" size="30"/></td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/port"/></td>
				<td class="padded"><input id="z3950Config.port" class="content" type="text" value="" size="30"/></td>
			</tr>


			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/useAccount"/></td>
				<td class="padded"><input id="z3950Config.useAccount" type="checkbox" checked="on"/></td>
			</tr>

			<tr>
				<td/>
				<td>
					<table id="z3950Config.account">
						<tr>
							<td class="padded"><xsl:value-of select="/root/gui/harvesting/username"/></td>
							<td class="padded"><input id="z3950Config.username" class="content" type="text" value="" size="20"/></td>
						</tr>
		
						<tr>
							<td class="padded"><xsl:value-of select="/root/gui/harvesting/password"/></td>
							<td class="padded"><input id="z3950Config.password" class="content" type="password" value="" size="20"/></td>
						</tr>
					</table>
				</td>
			</tr>			
		</table>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="search-Z3950Config">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/search"/></h1>

		<div id="z3950Config.searches"/>
		
		<div style="margin:4px;">
			<button id="z3950Config.addSearch" class="content" onclick="harvesting.z3950Config.addSearchRow()">
				<xsl:value-of select="/root/gui/harvesting/add"/>
			</button>
		</div>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="options-Z3950Config">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/options"/></h1>

		<table border="0">

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/clearConfig"/></td>
				<td class="padded"><input id="z3950Config.clearConfig" type="checkbox" value=""/></td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/every"/></td>
				<td class="padded">
					<input id="z3950Config.every.days"  class="content" type="text" size="2"/> :
					<input id="z3950Config.every.hours" class="content" type="text" size="2"/> :
					<input id="z3950Config.every.mins"  class="content" type="text" size="2"/>
					&#160;
					<xsl:value-of select="/root/gui/harvesting/everySpec"/>
				</td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/oneRun"/></td>
				<td class="padded"><input id="z3950Config.oneRunOnly" type="checkbox" value=""/></td>
			</tr>
		</table>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="content-Z3950Config">
	<div style="display:none;"> <!-- UNUSED -->
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/content"/></h1>

		<table border="0">
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/importxslt"/></td>
				<td class="padded">
					&#160;
					<select id="z3950Config.importxslt" class="content" name="importxslt" size="1"/>
				</td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/validate"/></td>
				<td class="padded"><input id="z3950Config.validate" type="checkbox" value=""/></td>
			</tr>
		</table>
	</div>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="privileges-Z3950Config">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/privileges"/></h1>
		
		<table>
			<tr>
				<td class="padded" valign="top"><xsl:value-of select="/root/gui/harvesting/groups"/></td>
				<td class="padded"><select id="z3950Config.groups" class="content" size="8" multiple="on"/></td>					
				<td class="padded" valign="top">
					<div align="center">
						<button id="z3950Config.addGroups" class="content" onclick="harvesting.z3950Config.addGroupRow()">
							<xsl:value-of select="/root/gui/harvesting/add"/>
						</button>
					</div>
				</td>					
			</tr>
		</table>
		
		<table id="z3950Config.privileges">
			<tr>
				<th class="padded"><xsl:value-of select="/root/gui/harvesting/group"/></th>
				<th class="padded"><xsl:value-of select="/root/gui/harvesting/oper/op[@id='0']"/></th>
				<th/>
			</tr>
		</table>
	</xsl:template>
	
	<!-- ============================================================================================= -->

	<xsl:template name="categories-Z3950Config">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/categories"/></h1>
		
		<select id="z3950Config.categories" class="content" size="8" multiple="on"/>
	</xsl:template>
	
	<!-- ============================================================================================= -->

</xsl:stylesheet>
