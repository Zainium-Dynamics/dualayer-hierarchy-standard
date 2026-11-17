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
    <p class="cover-org"><img src="zainium-mark.png" alt=""/> Zainium Dynamics</p>
    <div class="cover-main">
      <p class="cover-title"><xsl:value-of select="$info/*[local-name() = 'title']"/></p>
      <p class="cover-subtitle"><xsl:value-of select="$info/*[local-name() = 'subtitle']"/></p>
      <p class="cover-version">Version <xsl:value-of select="$version"/></p>
      <p class="cover-date"><xsl:value-of select="$info/*[local-name() = 'pubdate']"/></p>
    </div>
    <div class="cover-foot">
      <p>Published under the Creative Commons Attribution-ShareAlike 4.0 International license.</p>
      <p>https://zainiumdynamics.tech/dhs<br/>https://github.com/Zainium-Dynamics/dualayer-hierarchy-standard</p>
      <xsl:if test="$build.commit != ''">
        <p class="cover-build">Built <xsl:value-of select="$build.date"/> from commit <xsl:value-of select="$build.commit"/></p>
      </xsl:if>
    </div>
  </div>

  <div class="running-header">
    <xsl:value-of select="$info/*[local-name() = 'title']"/>, version <xsl:value-of select="$version"/>
  </div>
</xsl:template>

</xsl:stylesheet>
