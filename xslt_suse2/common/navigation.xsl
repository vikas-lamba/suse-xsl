<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Check, if navigation nodes needs to be created in regards to
     $rootid
   
   Named Templates:
    * is.next.node.in.navig(next=NODE)
      Returns boolean, if the next node is inside the descendants of 
      $rootid node and needs to be included in navigation. 
      
    * is.prev.node.in.navig(prev=NODE)
      Returns boolean, if the previous node is inside the descendants of 
      $rootid node and needs to be included in navigation. 
    
    * is.node.in.rootid.node(next=NODE, prev=NODE)
      Returns boolean, if the previous, next, up and home link
    

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">
  
  <!-- ===================================================== -->
  <xsl:template name="is.next.node.in.navig">
    <xsl:param name="next"/>
    
    <xsl:variable name="next.book"
      select="($next/ancestor-or-self::book |
      $next/ancestor-or-self::article)[last()]"/>
    <xsl:variable name="this.book"
      select="(ancestor-or-self::book|ancestor-or-self::article)[last()]"/>
    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
     -->
    <xsl:value-of select="generate-id($this.book) = generate-id($next.book)"/>
  </xsl:template>
  
  <xsl:template name="is.prev.node.in.navig">
    <xsl:param name="prev"/>
    
    <xsl:variable name="prev.book"
      select="($prev/ancestor-or-self::book |
      $prev/ancestor-or-self::article)[last()]"/>
    <xsl:variable name="this.book"
      select="(ancestor-or-self::book|ancestor-or-self::article)[last()]"/>
    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
     -->
    <xsl:value-of select="generate-id($this.book) = generate-id($prev.book)"/>
  </xsl:template>
  
  <xsl:template name="is.node.in.navig">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="debug"/>
    
    <!-- The next.book, prev.book, and this.book variables contains the
       ancestor or self nodes for book or article, but only one node.
     -->
    <xsl:variable name="next.book"
      select="($next/ancestor-or-self::book |
      $next/ancestor-or-self::article)[last()]"/>
    <xsl:variable name="prev.book"
      select="($prev/ancestor-or-self::book |
      $prev/ancestor-or-self::article)[last()]"/>
    <xsl:variable name="this.book"
      select="(ancestor-or-self::book|ancestor-or-self::article)[last()]"/>
    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
     -->
    <xsl:variable name="isnext"
      select="generate-id($this.book) = generate-id($next.book)"/>
    <xsl:variable name="isprev"
      select="generate-id($this.book) = generate-id($prev.book)"/>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>
    <xsl:if test="$debug">
      <xsl:message>is.node.in.rootid.node
        Element:  <xsl:value-of select="local-name(.)"/>
        prev:     <xsl:value-of select="local-name($prev)"/>
        next:     <xsl:value-of select="local-name($next)"/>
        rootid:   <xsl:value-of select="$rootid"/>
        isnext:   <xsl:value-of select="$isnext"/>
        isprev:   <xsl:value-of select="$isprev"/>
      </xsl:message>
    </xsl:if>
    <!-- Return our result: -->
    <xsl:value-of name="result"
      select="(count($prev) > 0 and $isprev) or
      (count($up) &gt; 0 and 
      generate-id($up) != generate-id($home) and 
      $navig.showtitles != 0) or
      (count($next) > 0 and $isnext)"/>
  </xsl:template>
  
</xsl:stylesheet>