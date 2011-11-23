<?xml version="1.0" encoding="UTF-8"?>
<!--
  XSL for metadata controls (ie. buttons +, -, up, down actions)
  TODO : remove some JS dependencies eg. setBunload 
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common" xmlns:str="http://exslt.org/strings"
  xmlns:geonet="http://www.fao.org/geonetwork" exclude-result-prefixes="exslt geonet str">

  <xsl:template name="getButtons">
    <xsl:param name="addLink"/>
    <xsl:param name="addXMLFragment"/>
    <xsl:param name="addXmlFragmentSubTemplate"/>
    <xsl:param name="removeLink"/>
    <xsl:param name="upLink"/>
    <xsl:param name="downLink"/>
    <xsl:param name="validationLink"/>
    <xsl:param name="id"/>


    <span class="buttons" id="buttons_{$id}">
      <!-- 
				add as remote XML fragment button when relevant -->
      <xsl:if test="normalize-space($addXMLFragment)">
        <xsl:variable name="xlinkTokens" select="tokenize($addXMLFragment,'!')"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="normalize-space($xlinkTokens[2])">
            <a id="addXlink_{$id}" class="small find"
              onclick="if (noDoubleClick()) {$xlinkTokens[1]}" style="display:none;">
              <span>&#160;</span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a id="addXlink_{$id}" class="small find" onclick="{$addXMLFragment}"
              style="cursor:pointer;" alt="{/root/gui/strings/addXMLFragment}"
              title="{/root/gui/strings/addXMLFragment}">
              <span>&#160;</span>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- 
	      add as remote XML fragment button when relevant -->
      <xsl:if test="normalize-space($addXmlFragmentSubTemplate)">
        <xsl:variable name="xlinkTokens" select="tokenize($addXmlFragmentSubTemplate,'!')"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="normalize-space($xlinkTokens[2])">
            <a id="addXlink_{$id}" class="small find"
              onclick="if (noDoubleClick()) {$xlinkTokens[1]}" style="display:none;">
              <span>&#160;</span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a id="addXlink_{$id}" class="small findsub" onclick="{$addXmlFragmentSubTemplate}"
              style="cursor:pointer;" alt="{/root/gui/strings/addXMLFragment}"
              title="{/root/gui/strings/addXMLFragment}">
              <span>&#160;</span>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- add button -->
      <xsl:choose>
        <xsl:when test="normalize-space($addLink)">
          <xsl:variable name="linkTokens" select="tokenize($addLink,'!')"/>
          <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="normalize-space($linkTokens[2])">
              <a id="add_{$id}" class="small add" onclick="if (noDoubleClick()) {$linkTokens[1]}"
                target="_blank" alt="{/root/gui/strings/add}" title="{/root/gui/strings/add}"
                style="display:none;">
                <span>&#160;</span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a id="add_{$id}" class="small add" onclick="if (noDoubleClick()) {$addLink}"
                target="_blank" alt="{/root/gui/strings/add}" title="{/root/gui/strings/add}">
                <span>&#160;</span>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <span id="add_{$id}"/>
        </xsl:otherwise>
      </xsl:choose>


      <!-- remove button -->
      <xsl:choose>
        <xsl:when test="normalize-space($removeLink)">
          <xsl:variable name="linkTokens" select="tokenize($removeLink,'!')"/>
          <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="normalize-space($linkTokens[2]) and 
                    not(starts-with(name(.), 'dc:')) and not(starts-with(name(.), 'dct:'))">
              <a id="remove_{$id}" class="small del" onclick="if (noDoubleClick()) {$linkTokens[1]}"
                target="_blank" alt="{/root/gui/strings/del}" title="{/root/gui/strings/del}"
                style="display:none;">
                <span>&#160;</span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a id="remove_{$id}" class="small del" onclick="if (noDoubleClick()) {$removeLink}"
                target="_blank" alt="{/root/gui/strings/del}" title="{/root/gui/strings/del}">
                <span>&#160;</span>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <span id="remove_{$id}"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- up button -->
      <xsl:choose>
        <xsl:when test="normalize-space($upLink)">
          <xsl:variable name="linkTokens" select="tokenize($upLink,'!')"/>
          <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="normalize-space($linkTokens[2])">
              <a id="up_{$id}" class="small up" style="display:none"
                onclick="if (noDoubleClick()) {$linkTokens[1]}" target="_blank"
                alt="{/root/gui/strings/up}" title="{/root/gui/strings/up}">
                <span>&#160;</span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a id="up_{$id}" class="small up" onclick="if (noDoubleClick()) {$upLink}"
                target="_blank" alt="{/root/gui/strings/up}" title="{/root/gui/strings/up}">
                <span>&#160;</span>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <span id="up_{$id}"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- down button -->
      <xsl:choose>
        <xsl:when test="normalize-space($downLink)">
          <xsl:variable name="linkTokens" select="tokenize($downLink,'!')"/>
          <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="normalize-space($linkTokens[2])">
              <a id="down_{$id}" class="small down" style="display:none;"
                onclick="if (noDoubleClick()) {$linkTokens[1]}" target="_blank"
                alt="{/root/gui/strings/down}" title="{/root/gui/strings/down}">
                <span>&#160;</span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a id="down_{$id}" class="small down" onclick="if (noDoubleClick()) {$downLink}"
                target="_blank" alt="{/root/gui/strings/down}" title="{/root/gui/strings/down}">
                <span>&#160;</span>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <span id="down_{$id}"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- xsd and schematron validation error button -->
      <xsl:if test="normalize-space($validationLink)">
        <xsl:text> </xsl:text>
        <a id="validationError{$id}" onclick="setBunload(false);"
          href="javascript:doEditorAlert(&quot;error_{$id}&quot;, &quot;errorimg_{$id}&quot;);" class="small error">
          <span>&#160;</span>
        </a>
        <div style="display:none;" class="toolTipOverlay" id="error_{$id}"
          onclick="this.style.display='none';">
          <xsl:copy-of select="$validationLink"/>
        </div>
      </xsl:if>
    </span>
  </xsl:template>

  <!-- Template to display a calendar with a clear button -->
  <xsl:template name="calendar">
    <xsl:param name="ref"/>
    <xsl:param name="date"/>
    <xsl:param name="format" select="'%Y-%m-%d'"/>

    <table width="100%">
      <tr>
        <td>
          <div class="cal" id="_{$ref}"/>
          <input type="hidden" id="_{$ref}_format" value="{$format}"/>
          <input type="hidden" id="_{$ref}_cal" value="{$date}"/>
        </td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>
