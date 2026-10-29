<?xml version='1.0'?>
<!-- The PDF edition: the single-page HTML with a cover and a running header, printed by
     WeasyPrint with docbook/print/dhs-print.css (fonts and logos in docbook/print/). -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
                exclude-result-prefixes="l"
                version="1.0">
<xsl:import href="docbook-html-utf8.xsl"/>

<!-- Set by the Makefile: the date and commit the PDF was built from. -->
<xsl:param name="build.date" select="''"/>
<xsl:param name="build.commit" select="''"/>

<xsl:param name="html.stylesheet" select="'dhs-print.css'"/>
<xsl:param name="admon.style" select="''"/>
<xsl:param name="table.borders.with.css" select="1"/>
<xsl:param name="css.decoration" select="0"/>

<!-- "1. Introduction": the stylesheet prints "Chapter" / "Appendix" above the title. -->
<xsl:param name="local.l10n.xml" select="document('')"/>
<l:i18n>
  <l:l10n language="en">
    <l:context name="title-numbered">
      <l:template name="chapter" text="%n. %t"/>
      <l:template name="appendix" text="%n. %t"/>
    </l:context>
  </l:l10n>
</l:i18n>

<xsl:template name="body.attributes"/>

<xsl:template name="user.head.content">
  <meta name="author" content="Zainium Dynamics"/>
  <meta name="keywords" content="Dualayer Hierarchy Standard, DHS, filesystem hierarchy, musl, glibc, OverlayFS, Zainium OS"/>
</xsl:template>

<xsl:template name="user.header.content">
  <xsl:variable name="info" select="/*/*[local-name() = 'info']"/>
  <xsl:variable name="release" select="normalize-space($info/*[local-name() = 'releaseinfo'])"/>
  <xsl:variable name="version">
    <xsl:choose>
      <xsl:when test="starts-with($release, 'Version ')"><xsl:value-of select="substring-after($release, 'Version ')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$release"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div class="cover">
    <div class="cover-brand">
      <img class="cover-logo" src="zainium-logo.png" alt="Zainium Dynamics"/>
      <span class="cover-org">Zainium Dynamics</span>
    </div>
    <div class="cover-main">
      <p class="cover-kind">Open specification</p>
      <p class="cover-title"><xsl:value-of select="$info/*[local-name() = 'title']"/></p>
      <p class="cover-subtitle"><xsl:value-of select="$info/*[local-name() = 'subtitle']"/></p>
    </div>
    <table class="cover-meta">
      <tr><th>Version</th><td><xsl:value-of select="$version"/></td></tr>
      <tr><th>Published</th><td><xsl:value-of select="$info/*[local-name() = 'pubdate']"/></td></tr>
      <xsl:if test="$build.commit != ''">
        <tr><th>Build</th><td><xsl:value-of select="$build.date"/> · <xsl:value-of select="$build.commit"/></td></tr>
      </xsl:if>
      <tr><th>License</th><td>CC BY-SA 4.0</td></tr>
    </table>
    <div class="cover-foot">
      <span>zainiumdynamics.tech/dhs</span>
      <span>github.com/Zainium-Dynamics/dualayer-hierarchy-standard</span>
    </div>
  </div>

  <div class="running-header">
    <img src="zainium-mark.png" alt=""/>
    <span class="running-title"><xsl:value-of select="$info/*[local-name() = 'title']"/></span>
    <span class="running-version"><xsl:value-of select="$version"/></span>
  </div>
</xsl:template>

</xsl:stylesheet>
