<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:param name="appLocEncoded"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="saveButton" select="$localeXml/string[@key='saveButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>

<xsl:variable name="portletEditSASReportHeight" select="$localeXml/string[@key='portletEditSASReportHeight']/text()"/>
<xsl:variable name="portletEditSASReportUri" select="$localeXml/string[@key='portletEditSASReportUri']/text()"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>


<xsl:variable name="portletId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@PortletType"/>
<xsl:variable name="parentTreeId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/Trees/Tree/@Id"/>

<!-- Properties -->

<xsl:variable name="configPropertySet" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']"/>
<xsl:variable name="configPropertySetId" select="$configPropertySet/@Id"/>

<xsl:variable name="configProperties" select="$configPropertySet/SetProperties"/>
<xsl:variable name="configPropertySets" select="$configPropertySet/PropertySets"/>

<xsl:variable name="portletHeight" select="$configPropertySets/PropertySet[@Name='portletHeight']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>

<!--  The URI we store has the prefix SBIP://METASERVER on it.  No need to force the user to enter that, just have them enter the full path -->

<xsl:variable name="portletURI" select="$configPropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="portletPath" select="substring-after($portletURI,'SBIP://METASERVER')"/>

<xsl:variable name="portletURIFolder" select="$configPropertySets/PropertySet[@Name='selectedFolder']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="portletPathFolder" select="substring-after($portletURIFolder,'SBIP://METASERVER')"/>

<xsl:variable name="portletPrompts" select="$configPropertySets/PropertySet[@Name='promptNames']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>

<xsl:variable name="saveLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem&amp;id=',$portletId,'&amp;portletType=',$portletType,'&amp;type=PSPortlet')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<form method="post" target="formResponse">
<xsl:attribute name="action"><xsl:value-of select="$saveLink"/></xsl:attribute>

    <xsl:if test="$parentTreeId">
       <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$parentTreeId"/></xsl:attribute></input>
    </xsl:if>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataEntryBG">
<tbody>
<tr>
<td>
<table border="0" cellpadding="2" cellspacing="0">

 <tbody>
  <tr>
  <td colspan="3">&#160;</td>
 </tr>

 <tr>
     <td align="center" valign="center" colspan="3" width="100%">
     <div id="portal_message"></div>
     </td>
 </tr>
 <tr>
  <td>&#160;</td>
  <td align="center">
        <table border="0">
         <tbody><tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditSASReportUri"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" name="portletPath" size="60"><xsl:attribute name="value"><xsl:value-of select="$portletPath"/></xsl:attribute></input>
          </td>
         </tr>
         <tr>
          <td nowrap="">
          </td>
         </tr><tr></tr>
         <tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditSASReportHeight"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" id="height" name="portletHeight" size="4"><xsl:attribute name="value"><xsl:value-of select="$portletHeight"/></xsl:attribute></input>
          </td>
         </tr>
        </tbody></table>
  </td>
 </tr>
 <tr>
 <td>&#160;</td>
 </tr>
</tbody>

</table>

<table border="0" width="100%" cellspacing="0" cellpadding="6">

            <tbody><tr class="buttonBar">
            <td width="12">
            &#160;
            </td>
            <td>
                    <input class="button" type="submit" name="submit"><xsl:attribute name="value"><xsl:value-of select="$saveButton"/></xsl:attribute></input>
            </td>
            <td>
                    <input class="button" type="button" name="cancel" onclick="history.back()"><xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute></input>
            </td>
            <td width="100%">
            &#160;
            </td>
            </tr>
</tbody>
</table>
</td>
</tr>
</tbody></table>
</form>

<!-- This iframe is here to capture the response from submitting the form -->
      
      <iframe id="formResponse" name="formResponse" style="display:none">
      
      </iframe>

</xsl:template>

<xsl:template name="thisPageScripts">

</xsl:template>

</xsl:stylesheet>

