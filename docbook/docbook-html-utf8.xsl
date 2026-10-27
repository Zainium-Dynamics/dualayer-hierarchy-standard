<?xml version='1.0'?>
<!-- Single-page HTML in UTF-8 (html/docbook.xsl defaults to iso-8859-1). -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:import href="xsl/html/docbook.xsl"/>
<xsl:output method="html" encoding="UTF-8" indent="no"/>
<xsl:param name="html.head.extra" select="''"/>
<xsl:template name="user.head.content">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
</xsl:template>
</xsl:stylesheet>
