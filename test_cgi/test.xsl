<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	exclude-result-prefixes="#default"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	version="1.0"
>

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
	      <td><xsl:value-of select="./source/text()" /></td>
	      <td><xsl:value-of select="./function/text()" /></td>
	      <td><xsl:value-of select="./description/text()" /></td>
	      </tr>
</xsl:template>

<xsl:template match="text()">
</xsl:template>

</xsl:stylesheet>