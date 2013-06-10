<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"                
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:loc="com.qutoric.xq.functions"
                exclude-result-prefixes="loc xs"
                xmlns="">
  
  <xsl:variable name="ops" select="', / = &lt; &gt; + - * ? | != &lt;= &gt;= &lt;&lt; &gt;&gt; // := ! || { } ; ~'"/>
  <xsl:variable name="aOps" select="'or and eq ne lt le gt ge is to div idiv mod union intersect except in return satisfies then else as map where'"/>
  <xsl:variable name="hOps" select="'for some every let'"/>
  <xsl:variable name="nodes" select="'attribute comment document-node namespace-node element node processing-instruction text'"/>
  <xsl:variable name="types" select="'empty-sequence function item node schema-attribute schema-element type'"/>
  
  <xsl:variable name="ambiguousOps" select="tokenize($aOps,'\s+')" as="xs:string*"/>
  <xsl:variable name="simpleOps" select="tokenize($ops,'\s+')" as="xs:string*"/>
  <xsl:variable name="nodeTests" select="tokenize($nodes,'\s+')" as="xs:string*"/>
  <xsl:variable name="typeTests" select="tokenize($types,'\s+')" as="xs:string*"/>
  <xsl:variable name="higherOps" select="tokenize($hOps,'\s+')" as="xs:string*"/>
  <xsl:variable name="bgColor" select="'black'" as="xs:string"/>    
  
  <xsl:function name="loc:pad" as="xs:string">
    <xsl:param name="padStringIn" as="xs:string?"/>
    <xsl:param name="fixedWidth" as="xs:integer"/>
    <xsl:variable name="padString" as="xs:string" select="replace($padStringIn, '\n','\\n')"/>
    <xsl:variable name="stringLength" as="xs:integer" select="string-length($padString)"/>
    <xsl:variable name="padChar" select="if ($fixedWidth gt 20) then '.' else ' '"/>
    <xsl:variable name="padCount" as="xs:integer" select="$fixedWidth - $stringLength"/>
    <xsl:if test="$padCount ge 0">
      <xsl:sequence select="concat($padString, string-join(for $i in 1 to $padCount 
                            return $padChar,''))"/>
    </xsl:if>
    <xsl:if test="$padCount lt 0">
      <xsl:sequence select="concat($padString, '&#10;',' ', string-join(for $i in 1 to $fixedWidth 
                            return $padChar,''))"/>
    </xsl:if>
  </xsl:function>
   
  
  <!-- top-level call - marks up tokens with their type -->  
  <xsl:function name="loc:createXqTokens" as="element()*">
    <xsl:param name="part" as="xs:string"/>
    <xsl:param name="preceding-is-closed" as="xs:boolean"/>  
    <xsl:if test="string-length($part) gt 0">
      <xsl:variable name="rawTokens" as="xs:string*"
                    select="loc:rawTokens($part)"/>
      
      <!-- The XSLT that generates the tokens -->
      <xsl:variable name="processedTokens" as="element()*"
        select="loc:processXqTokens($rawTokens, 1, 1, ())"/>
      
      <xsl:sequence select="loc:rationalizeTokens($processedTokens, 1, $preceding-is-closed, false(), false(), ())"/>
<!--          <span class="test" closed="{string($preceding-is-closed)}"><xsl:value-of select="$part"/></span>-->
    </xsl:if>    
  </xsl:function>
  
  <xsl:function name="loc:rationalizeTokens">
    <xsl:param name="tokens" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="prevIsClosed" as="xs:boolean"/>
    <xsl:param name="typeExpected" as="xs:boolean"/>
    <xsl:param name="quantifierExpected" as="xs:boolean"/>
    <xsl:param name="result" as="element()*"/>
    
    <!-- when closed, a probable operator is a QName instead -->
    
    <xsl:variable name="token" select="$tokens[$index]" as="element()?"/>
    <xsl:variable name="n1Token" select="$tokens[$index + 1]" as="element()?"/>
    <xsl:variable name="n2Token" select="$tokens[$index + 2]" as="element()?"/>
    <xsl:variable name="isQuantifier" select="$quantifierExpected and $token/@value = ('?','*','+')"/>
    <xsl:variable name="is-wildcard" as="xs:boolean"
                  select="not($isQuantifier) and not($prevIsClosed) and $token/@value eq '*'"/>
    <xsl:variable name="currentIsClosed" as="xs:boolean"
                  select="$is-wildcard or $isQuantifier or not($token/@type) or ($token/@value = (')',']', '}') or ($token/@type = ('literal','numeric','variable', 'context')))"/>
    
    <xsl:variable name="class">
          <xsl:choose>
            <xsl:when test="$token/@type = 'probableOp'">
              <xsl:value-of select="if ($prevIsClosed) then 'op' else 'qname'"/>
            </xsl:when>
            <xsl:when test="empty($token/@type) and $token/@value = ('element','attribute')
                            and exists($n2Token) and $n1Token/@type eq 'whitespace' and empty($n2Token/@type)">
              <xsl:value-of select="'axis'"/>
            </xsl:when>
            <xsl:when test="empty($token/@type) and $token/@value eq 'default'
                            and exists($n2Token) and $n1Token/@type eq 'whitespace' and $n2Token/@value eq 'return'">
              <xsl:value-of select="'axis'"/>
            </xsl:when>
            <xsl:when test="empty($token/@type) and $token/@value eq 'case'
                            and exists($n2Token) and $n1Token/@type eq 'whitespace' and (empty($n2Token/@type) or $n2Token/@type = ('node', 'type-name'))">
              <xsl:value-of select="'axis'"/>
            </xsl:when>
            <xsl:when test="empty($token/@type) and $token/@value = ('ascending','descending')
                            and exists($n2Token) and $n1Token/@type eq 'whitespace' and $n2Token/@value eq 'return'">
              <xsl:value-of select="'op'"/>
            </xsl:when>
            <xsl:when test="$is-wildcard">
              <xsl:text>qname</xsl:text>
            </xsl:when>
            <xsl:when test="$token/@type = ('function','if', 'node') or $token/@value = ('(','[')">
              <xsl:choose>
                <xsl:when test="$typeExpected and $token/@type = ('node', 'function')">
                  <xsl:value-of select="'node-type'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$token/@type"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$typeExpected">
              <xsl:value-of select="if ($token/@type) then $token/@type else 'type-name'"/>
            </xsl:when>
            <xsl:when test="$isQuantifier">
              <xsl:value-of select="'quantifier'"/>
            </xsl:when>
            <xsl:when test="$token/@type">
              <xsl:value-of select="$token/@type"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>qname</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
    </xsl:variable>
      
    <xsl:variable name="result1" as="element()+">       
        <xsl:element name="span">
<!--          <xsl:attribute name="start" select="$token/@start"/>-->
          <xsl:attribute name="class" select="$class"/>
          <xsl:variable name="value" select="$token/@value"/>         
          <xsl:value-of select="if ($class = ('type', 'node-type','function')) then substring($value, 1, string-length($value) - 1) else $value"/>
        </xsl:element>
        <xsl:if test="$class = ('type', 'node-type','function')">
          <span class="parenthesis">(</span>
        </xsl:if>
    </xsl:variable>
      
    <xsl:variable name="ignorable" as="xs:boolean"
                  select="$token/@type = ('whitespace', 'comment')"/>
    
    <xsl:variable name="isNewClosed" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="$ignorable">
          <xsl:value-of select="$prevIsClosed"/>
        </xsl:when>
        <xsl:when test="$token/@type = 'probableOp'">
          <xsl:value-of select="not($prevIsClosed)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$currentIsClosed"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="newTypeExpected" as="xs:boolean"
                  select="if ($ignorable) then $typeExpected
                          else ($token/@type = 'type-op') or ($token/@value eq 'as')"/>
    <xsl:choose>
        <xsl:when test="$index + 1 le count($tokens)">
          <xsl:variable name="qExpected" as="xs:boolean"
                        select="$typeExpected or $token/@value = ')'"/> 
          
          
          <xsl:sequence select="loc:rationalizeTokens($tokens, $index + 1, $isNewClosed,
                                $newTypeExpected, $qExpected, ($result, $result1))"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="not($isNewClosed)">
              <span class="open"/>
            </xsl:if>
            <xsl:sequence select="($result, $result1)"/>
        </xsl:otherwise>
    </xsl:choose>

    
  </xsl:function>
  
  <xsl:function name="loc:processXqTokens" as="element()*">
    <xsl:param name="tokens" as="xs:string*"/>
    <xsl:param name="start" as="xs:integer"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()*"/>  
    
    <xsl:variable name="token" as="xs:string?"
                  select="$tokens[$index]"/>
    <xsl:variable name="end" as="xs:integer"
                  select="$start + string-length($token)"/>
      
    <xsl:variable name="result1" as="element()">       
      <xsl:element name="token">
      <xsl:attribute name="start" select="$start"/>
      <xsl:attribute name="end" select="$end - 1"/>
      <xsl:attribute name="value" select="$token"/>
      <xsl:variable name="isSimpleOps" select="$token = $simpleOps" as="xs:boolean"/>
      <xsl:if test="$isSimpleOps">
        <xsl:attribute name="type" select="if($token = ('/','//')) then 'step' else 'op'"/>
      </xsl:if>
      <xsl:variable name="isDoubleToken" as="xs:boolean">
        <xsl:choose>
          <xsl:when test="$isSimpleOps">
            <xsl:value-of select="false()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="splitToken" as="xs:string*"
                          select="tokenize($token, '[\s\p{Zs}]+')"/>
            <xsl:value-of
                select="if (count($splitToken) ne 2) then false()
                        else if ($splitToken[1] eq 'instance' and $splitToken[2] eq 'of') 
                        then true()
                        else if ($splitToken[1] eq 'order' and $splitToken[2] eq 'by') 
                        then true()
                        else if ($splitToken[1] = ('cast','castable','treat') and $splitToken[2] eq 'as')
                        then true() else false()"/>
            
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$isDoubleToken">
        <xsl:attribute name="type" select="'type-op'"/>
      </xsl:if>
      
      <xsl:variable name="functionType" as="xs:string">
        <xsl:choose>
          <xsl:when test="$isSimpleOps or $isDoubleToken or string-length($token) = 1 or not(ends-with($token,'('))">
            <xsl:text></xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="fnName" as="xs:string" select="tokenize($token, '[\s\p{Zs}]+|\(')[1]"/>
            <xsl:choose>
              <xsl:when test="$fnName = 'if'">
                <xsl:text>if</xsl:text>
              </xsl:when>
              <xsl:when test="some $n in $nodeTests satisfies $n = $fnName">
                <xsl:text>node</xsl:text>
              </xsl:when>
              <xsl:when test="some $x in $typeTests satisfies $x = $fnName">
                <xsl:text>type</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>function</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="starts-with($token, 'Q{')">
          <xsl:attribute name="type" select="'bracedq'"/>
        </xsl:when>
        <xsl:when test="$isSimpleOps or $isDoubleToken"></xsl:when>
        <xsl:when test="$functionType ne ''">
          <xsl:attribute name="type" select="$functionType"/>
        </xsl:when>
        <xsl:when test="ends-with($token, '::') or $token eq '@'">
          <xsl:attribute name="type" select="'axis'"/>
        </xsl:when>
        <xsl:when test="matches($token,'[\s\p{Zs}]+')">
          <xsl:attribute name="type" select="'whitespace'"/>
        </xsl:when>
        <xsl:when test="$token = ('.','..')">
          <xsl:attribute name="type" select="'context'"/>
        </xsl:when>
        <xsl:when test="$token = ('(',')')">
          <xsl:attribute name="type" select="'parenthesis'"/>
        </xsl:when>
        <xsl:when test="$token = ('[',']')">
          <xsl:attribute name="type" select="'filter'"/>
        </xsl:when>
        <xsl:when test="number($token) = number($token)">
          <xsl:attribute name="type" select="'numeric'"/>
        </xsl:when>
        <xsl:when test="$token = $ambiguousOps">
          <xsl:attribute name="type" select="'probableOp'"/>
        </xsl:when>
        <xsl:when test="$token = $higherOps">
          <xsl:if test="starts-with(loc:nextNonWhite($tokens, $index), '$')">
            <xsl:attribute name="type" select="'higher'"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$token eq 'if'">
          <xsl:if test="loc:nextNonWhite($tokens, $index) eq '('">
            <xsl:attribute name="type" select="'if'"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($token, '$')">
          <xsl:attribute name="type" select="'variable'"/>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$index + 1 le count($tokens)">
      <xsl:sequence select="loc:processXqTokens($tokens, $end, $index + 1, ($result, $result1))"/>
    </xsl:when>
        <xsl:otherwise>
            <xsl:sequence select="($result, $result1)"/>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="loc:nextNonWhite" as="xs:string?">
    <xsl:param name="tokens" as="xs:string*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="true()"><!-- test="$index + 2 lt count($tokens)">  --> 
        <xsl:value-of select="if(replace($tokens[$index + 1],'[\s\p{Zs}]+','') eq '')
                              then $tokens[$index + 2] else $tokens[$index + 1]"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="loc:rawTokens" as="xs:string*">
    <xsl:param name="chunk" as="xs:string"/>
    <xsl:analyze-string
        regex="(((-)?\d+)(\.)?(\d+([eE][\+\-]?)?\d*)?)|(\?)|(Q\{{[^\{{\}}]*\}})|(instance[\s\p{{Zs}}]+of)|(cast[\s\p{{Zs}}]+as)|(:=)|(\|\|)|(order[\s\p{{Zs}}]+by)|(castable[\s\p{{Zs}}]+as)|(treat[\s\p{{Zs}}]+as)|((\$[\s\p{{Zs}}]*)?[\i\*][\p{{L}}\p{{Nd}}\.\-_]*(:[\p{{L}}\p{{Nd}}\.\-\*_]*)?(::)?:?(#\d+)?)(\()?|(\.\.)|((-)?\d?\.\d*)|-|([&lt;&gt;!]=)|(&gt;&gt;|&lt;&lt;)|(//)|([\s\p{{Zs}}]+)|(\C)"
        select="$chunk">
      <xsl:matching-substring>
        <xsl:value-of select="string(.)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>
  
      
</xsl:stylesheet>