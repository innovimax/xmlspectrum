<?xml version="1.0" encoding="utf-8"?>
<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT and XSD 1.1 file formats

Description:

Transforms the source XHTML file by converting <samp> elements to para elements
with span child elements containing class attributes for color styles. Also
inserts a link to a generated CSS file output as a xsl:result-document. 

Note that this interface stylesheet is a simple wrapper for xmlspectrum.xsl.

Dependencies:

1. xmlspectrum.xsl

Usage:

initial-template: 'main'
source-xml: (not used)
xsl parameters:
    sourcepath:  (path or URI for source file)
    color-theme: (name of color theme: default is 'solarized-dark')
    css-path:    (path for output CSS)

Sample transform using Saxon-HE/Java on command-line (unbroken line):

java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main
-xsl:xsl/highlight-file.xsl sourcepath=../samples/xpathcolorer-x.xsl

-->

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
exclude-result-prefixes="loc f xs css"
xmlns="http://www.w3.org/1999/xhtml"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns:f="internal">

<xsl:import href="xmlspectrum.xsl"/>

<xsl:output indent="no" method="html"/>

<xsl:param name="color-theme" select="'dark'" as="xs:string"/>
<xsl:param name="indent" select="'-1'" as="xs:string"/>
<xsl:param name="auto-trim" select="'no'" as="xs:string"/>
<xsl:param name="font-name" select="'std'"/>

<xsl:variable name="indent-size" select="xs:integer($indent)" as="xs:integer"/>
<xsl:variable name="do-trim" select="$auto-trim eq 'yes'"/>

<xsl:template match="/">
<xsl:apply-templates/>
<xsl:call-template name="create-css"/>
</xsl:template>

<xsl:template match="html">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
<xsl:copy>
<xsl:apply-templates select="node()|@*"/>
</xsl:copy>
</xsl:template>

<xsl:template match="head">
<xsl:apply-templates select="@*"/>
<link rel="stylesheet" type="text/css" href="theme.css"/>
<xsl:apply-templates/>
</xsl:template>


<xsl:template match="@* | node()">
<xsl:copy>
<xsl:apply-templates select="@* | node()"/>
</xsl:copy>
</xsl:template>

<xsl:template match="pre[exists(@lang) and @lang ne 'xpath']">
<xsl:variable name="is-xsl" select="@lang eq 'xslt'" as="xs:boolean"/>
<xsl:variable name="prefix" select="(@data-prefix, '')[1]" as="xs:string"/>
<xsl:variable name="context-indent" select="if (exists(@data-indent))
then xs:integer(@data-indent)
else $indent-size"/>
<xsl:copy>
<xsl:attribute name="class" select="'spectrum'"/>
<xsl:apply-templates select="@* except @class"/>
<xsl:variable name="real-trim" as="xs:boolean"
select="if (exists(@data-trim))
then @data-trim='yes'
else $do-trim"/>
<xsl:choose>
<xsl:when test="$real-trim or $context-indent gt 0">
<xsl:variable name="renderedXML" select="f:render(., @lang, $prefix)"
as="element()*"/>
<xsl:sequence select="f:indent($renderedXML, $context-indent, $real-trim)"/>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="f:render(., @lang, $prefix)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:copy>
</xsl:template>

<xsl:template match="pre[@lang eq 'xpath']">
<xsl:copy>
<xsl:attribute name="class" select="'spectrum'"/>
<xsl:apply-templates select="@* except @class"/>
<xsl:sequence select="loc:showXPath(.)"/>
</xsl:copy>
</xsl:template>

<xsl:template name="create-css">

<xsl:result-document href="theme.css" method="text" indent="no">
<xsl:sequence select="f:get-css()"/>
</xsl:result-document>

</xsl:template>

</xsl:stylesheet>
