<?xml version="1.0" encoding="utf8" standalone="yes" ?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3c.org/1999/XSL/Transform"
	version="1.0"
>
	<xsl:output method="xml" encoding="utf8" />

<xsl:template match="compiler_messages">
	      <table summary="Error Message (Compiler)"> 
	      <caption>Error List</caption>
	      <tbody>
	      <tr>
	      <th>Line</th>
	      <th>Status</th>
	      <th>Source</th>
	      <th>Function</th>
	      <th>Description</th>
	      </tr>
	      <xsl:apply-templates />
	      </tbody>
	      </table>
</xsl:template>

<xsl:template match="message">
	      <tr>
	      <td><xsl:value-of select="@line" /></td>
	      <td><xsl:value-of select="@status" /></td>
	      <td><xsl:apply-templates /></td>
	      <td><xsl:apply-templates /></td>
	      <td><xsl:apply-templates /></td>
	      </tr>
</xsl:template>

<xsl:template match="source">
	      <xsl:value-of select="text()" />
</xsl:template>

<xsl:template match="function">
	      <xsl:value-of select="text()" />
</xsl:template>

<xsl:template match="description">
	      <xsl:value-of select="text()" />
</xsl:template>


</xsl:stylesheet>