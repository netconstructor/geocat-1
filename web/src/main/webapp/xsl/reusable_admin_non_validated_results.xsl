<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:util="xalan://org.fao.geonet.util.XslUtil"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:include href="main.xsl"/>
    <xsl:include href="mapfish_includes.xsl"/>

    <xsl:template mode="script" match="/">
        <xsl:call-template name="mapfish_includes"/>
        <script src="{/root/gui/url}/scripts/mfbase/ext/ext-all.js" type="text/javascript"/>
        <script src="{/root/gui/url}/scripts/RowExpander.js" type="text/javascript"/>
         
         <script language="JavaScript1.2" type="text/javascript">
                         
            locUrl = '<xsl:value-of select="/root/gui/locService"/>';
            function refresh(){
                msgWindow.close();  
                var page = Ext.query("tr.blue-content").first().id.substring(4);
                show(page);
            }             
            
            function pageInit(){
                rejectBtnDefaultTxt = '<xsl:value-of select="/root/gui/strings/reject" />';
                var page = 'contacts';
                <xsl:if test="/root/request/page">
                page = '<xsl:value-of select="/root/request/page"/>';
                </xsl:if>
                
                show(page, '<xsl:value-of select="/root/gui/strings/delete"/>');
            }
         </script>

         <script src="{/root/gui/url}/scripts/reusable-validate.js" type="text/javascript"/>
        <xsl:call-template name="js-translations"/>

    </xsl:template>
    
	<xsl:template name="content">
	   <xsl:call-template name="formLayout">
            <xsl:with-param name="title" select="/root/gui/strings/reusable/nonValidTitle"/>
            <xsl:with-param name="navpane">
                <xsl:call-template name="nav"/>
            </xsl:with-param>
            <xsl:with-param name="content">
                <xsl:call-template name="form"/>
            </xsl:with-param>
            <xsl:with-param name="buttons">
                <xsl:call-template name="buttons"/>
            </xsl:with-param>
            
       </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="buttons">
        <button class="content" id='edit' onclick="edit()">
            <xsl:value-of select="/root/gui/strings/edit"/>
        </button>
                            &#160;
        <button class="content" id='duplicates' onclick="replaceDuplicates()">
            <xsl:value-of select="/root/gui/strings/replaceDuplicates"/>
        </button>
                            &#160;
        <button class="content" id='validate' onclick="validate()">
            <xsl:value-of select="/root/gui/strings/validate"/>
        </button>
                            &#160;
        <button class="content" id="reject" onclick="reject('reject', '{/root/gui/strings/submit}', '{/root/gui/strings/cancel}')">
            <xsl:value-of select="/root/gui/strings/reject"/>
        </button>
                            &#160;
        <button class="content" onclick="load('{/root/gui/locService}/admin')">
            <xsl:value-of select="/root/gui/strings/back"/>
        </button>
    </xsl:template>
	
	<xsl:template name="nav">
        <table align="left" width="100%">
            <tr id="nav_contacts"><td><a href="javascript:show('contacts')"><xsl:value-of select="/root/gui/strings/user"/></a></td></tr>
            <tr id="nav_formats"><td><a href="javascript:show('formats')"><xsl:value-of select="/root/gui/strings/formats"/></a></td></tr>
            <tr id="nav_extents"><td><a href="javascript:show('extents')"><xsl:value-of select="/root/gui/strings/extents"/></a></td></tr>
            <tr id="nav_keywords"><td><a href="javascript:show('keywords')"><xsl:value-of select="/root/gui/strings/keywords"/></a></td></tr>
            <tr id="nav_deleted"><td><a href="javascript:showDeletePage('{/root/gui/strings/delete}')"><xsl:value-of select="/root/gui/strings/deleted"/></a></td></tr>
       </table>
	</xsl:template>
	
	   
    <xsl:template name="form">
    
        <div id="msg_win" class="x-hidden">
            <div class="x-window-header"><xsl:value-of select="/root/gui/strings/reusable/rejectTitle"/></div>
               <div id="msg-panel">
                    <textarea style="width: 100%; height: 300px;" id="reusable_msg"><xsl:value-of select="/root/gui/strings/reusable/rejectDefaultMsg"/></textarea>
            </div>
        </div>

        <div id="grid-panel"/>        
    </xsl:template>

    <xsl:template match="text()"></xsl:template>
    
</xsl:stylesheet>