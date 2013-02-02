XMLSpectrum===========================***Syntax-highlighter and formatter for XPath 2.0 - 3.0 and any hosting XML such as XSLT***###Why1. Many syntax-highlighters fail to accurately render XPath 2.0, whether it is standalone or embedded in XML, such as XSLT or XSD. Even XQuery syntax-highlighting solutions suffer from limitations imposed on generic syntax highlighter plugins.2. The 'pretty-print' options of many XML editors do not align XML attributes and their contents properly. This omission is especially important for the readability of XPath 2.0/3.0.The goal of XMLSpectrum is to remedy these problems.###WhatXMLSpectrum comprises a principal XSLT 2.0 stylesheet and supporting stylesheets  designed specially to convert XPath 2.0 and any host XML code (such as XSLT) to HTML with syntax highlighting. Rendered code may be standalone and complete or embedded as samples which may have a missing 'root' element and/or missing namespace declarations***Main Roles***- Syntax highlighter- Code formatter- Code hyper-linker***Built-in language support***- XPath 1.0, 2.0, 3.0- XSLT 1.0, 2.0, 3.0- XSD 1.1- XProc- Schematron*Image of sample output rendered in browser:*![Screenshot](http://www.qutoric.com/xslt/xmlspectrum/images/xsl-light.png)Emphasis on accurate rendering of XPath 2.0 expressions, either within XSLT/XSD or standalone.By default,  *all* formatting is preserved exactly as-is - with trim and formatting options##Features### Syntax Highlighting:- Processes plain-text or XML-text (complete or otherwise)- Optionally processes xsl:include and xsl:import referenced XSLT- Uses standard XSLT 2.0 - no extensions required (tested on Saxon-HE)- Use [Solarized](http://ethanschoonover.com/solarized) color light/dark or [Roboticket](http://eclipsecolorthemes.org/?view=theme&id=93) color themes - or define your own- Generates the required CSS file also - depending on theme specified- Can use internal or external CSS style definitions- Option to use the new Adobe [Source Code Pro](http://blogs.adobe.com/typblography/2012/09/source-code-pro.html) font- Extensible for any XML format containing embedded XPath- XPath Highlighting:	- Supports XPath Comments	- All whitespace formatting preserved	- No dependency on reserved keywords           - Standalone files supported - or embedded in XML- XML Highlighting	- Supports fragments or complete XML           - Target namespace prefix can be inferred from 1st element	- Built-in XML parser (coded in XSLT) keeps all text, as-is	- CDATA preserved intact and highlighted	- Language identification (from namespace - if present)           - CSS styled element/ancestor highlighting - on mouse hover- XSLT Highlighting	- Scheme colors help separate instructions from expressions           - Literal Result Elements have different coloring	- XPath colored for AVTs or native XPath attributes	- All formatting preserved- Other 'Host Language' Highlighting (built-in)	- XSD 1.1	- Schematron	- XProc 1.0	- Generic XML### Formatting:- Formatting including whitespace between attributes and within attribute contents preserved by default- XML content is shown exactly as in the source - including intact entity references and CDATA sections etc._Formatting options - for use when original formatting requires correction_- [Option] *Indent*	- Indents XML proportional to the nesting level (Same as standard formatters)	- Smart attribute formatting (advanced feature)		- Aligned vertically with indentation consistent with the host element		- Multi-line content vertically aligned with pre-existing indentation preserved- [Option] *Auto-Trim*	- Removes pre-existing indentation (normally combined with the indent option)### Cross-referencing: Recursively processes all XSLT modules from a top-level stylesheet in a multi-file project- Creates top-level 'map' to all modules	- Global members listed for each module	- Map entries hyperlinked to the code definitions	- Module entries hyperlinked to syntax-highlighted file	- Global members sorted alphabetically by name- Adds hyperlinks in code for:	- *xsl:include* and *xsl:import* hrefs	- Global Parameters	- Global Variables	- Standard Functions	- User-defined Functions	- Named Templates- Clark-notation based linking to ensure integrity of links##XMLSpectrum in use###Online Implementations[Syntax highlighter web app](http://highlight.myxsl.net/) by [Max Toro](https://github.com/maxtoroq)###Sample Output from XMLSpectrum transforms[demo output of Docbook XSLT 2.0 Project](http://qutoric.com/samples/docbook20demo/)[XMLSpectrum (highlight-file.xsl entry-file) run on itself](http://qutoric.com/samples/xmlspectrum-code/)[Transformed web page with embedded code samples](http://qutoric.com/samples/inline/highlighted-inline.html)[Syntax-highlighted XProc file](http://qutoric.com/samples/xproc/xproccorb.xpl.html)### Included XSLT solutionsThe *xmlspectrum.xsl* stylesheet is intended for use by other stylesheets that import this and exploit its main functions: `render`, `showXPath` and `indent`:- *highlight-inline.xsl* - transforms XHTML file containing descriptive text and XSLT, XSD or XPath code examples-  *highlight-file.xsl*     - transforms files containing XSLT,XSD or XPath - can process multi-file XSLT projects*The dark theme:*![Screenshot](http://www.qutoric.com/xslt/xmlspectrum/images/xsd-dark.png)	##UsageFor usage instructions, see [xmlspectrum/app/xsl/readme](https://github.com/pgfearo/xmlspectrum/blob/master/app/xsl/readme.md)