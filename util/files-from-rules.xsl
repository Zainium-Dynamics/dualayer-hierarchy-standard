<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:lr="http://thaiopensource.com/ns/locating-rules/1.0">
  <xsl:output method="text"/>
  <xsl:template match="/">
    <xsl:text>XMLFILES := \&#10;</xsl:text>
    <xsl:apply-templates select="/lr:locatingRules/lr:uri"/>
  </xsl:template>
  <xsl:template match="lr:uri">
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$DIR" disable-output-escaping="yes"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="./@resource" disable-output-escaping="yes"/>
    <xsl:if test="position() != last()"><xsl:text> \</xsl:text></xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
