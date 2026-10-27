<?xml version='1.0'?>
<!-- One HTML page per chapter, UTF-8, with a mobile viewport. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:import href="xsl/html/chunk.xsl"/>
<xsl:param name="chunk.section.depth" select="0"/>
<xsl:param name="navig.showtitles" select="1"/>
<xsl:template name="user.head.content">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
</xsl:template>
</xsl:stylesheet>
