<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prepare docupdates appendix automatically

   Parameters:
     - rootid

   Input:
     DocBook 5 document
   
   Dependencies:
     - none ATM

   Prerequisites:
     Whenever you want an automatically created docupdate appendix,
     do the following:
     
     1. Create a new appendix with role='docupdates' or use an existing
        appendix if you already have one.
     2. Insert one or more sect1's with a revision attribute. The revision
        attribute needs to be a unique value. Typically something which
        describes your release like "1.0", "1.1", "12GA", "12SP1", "12SP2"
        etc.
     3. Add your <revhistory> inside <info> in your *chapter*.
        Each <revision> must contain a revision attribute which one of
        the unique values from step 2.
     4. Add as many <revision>s as you like. However, keep in mind these
        recommendations:
        a. Add the latest entry as first child.
        b. Insert whatever you like inside <revision>. Usually an
           <itemizedlist> works quite well to list all your changes for this
           release to this specific chapter
        c. When the <revhistory> grows, try to keep readability high. Maybe
           it's a good idea to move (very?) old entries into a separate file
           and xinclude them.

   Implementation Details:
     The xsl:key 'revs' selects all revision elements inside a chapter info
     element. Currently, only revisions inside a chapters info are
     implemented, no sections.

   Example:
      <chapter xml:id="cha.example">
        <title>Example</title>
        <info>
          <revhistory>
            <revision revision="12SP1">
              <date/>
              <revdescription>...</revdescription>
            </revision>
            <revision revision="11SP4">
              <date/>
              <revdescription>...</revdescription>
            </revision>
          </revhistory>
        </info>
          ...
      </chapter>

      <appendix role="docupdate">
        <title>Documentation Updates</title>
        <para>The quick brown fox jumps over the lazy dog.</para>
        <sect1 revision="12SP1">
          <title>March 2016 (Maintenance Release of SUSE Linux Enterprise Server)</title>
          <para>...</para>
        </sect1>

        <sect1 revision="11SP4">
          <title>December 2015 (Initial Release of SUSE Linux Enterprise Server)</title>
          <para/>
        </sect1>

        <sect1 xml:id="sec.old-stuff">
          <title>The very old docupdate</title>
          <para>This is old stuff, but it should be there...</para>
        </sect1>
      </appendix>


   Output:
     DocBook5
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db5ns "http://docbook.org/ns/docbook">
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="&db5ns;"
  xmlns:d="&db5ns;"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="exsl d">

  <xsl:output indent="yes"/>


  <!-- =================================================================== -->
 <xsl:key name="revs" match="//d:chapter/d:info/d:revhistory/d:revision"
          use="@revision"/>

  <!-- =================================================================== -->
  <xsl:param name="rootid"/>

  <!-- =================================================================== -->
  <xsl:template match="node() | @*" name="copy">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="d:appendix[@role='docupdate']">   
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="docupdate"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*" mode="docupdate">
   <xsl:message>docupdates: Copying <xsl:value-of select="concat(local-name(.), '#', @xml:id)"/></xsl:message>
   <xsl:apply-templates select="."/>
  </xsl:template>


  <xsl:template match="d:title|d:subtitle|d:titleabbrev|d:info|d:para[. != '']" mode="docupdate">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="d:para[. = '']" mode="docupdate"/>


  <!--
     Investigate sections with an revision attribute and add revision
     histories
  -->
  <xsl:template match="d:sect1[@revision]" mode="docupdate">
   <xsl:variable name="rev" select="key('revs', @revision)"/>
   <xsl:variable name="targets" select="key('revs', @revision)"/>
   <xsl:variable name="origin" select="."/>
   <xsl:variable name="revisions" select="$targets[ancestor-or-self::d:book/@xml:id = $origin/ancestor-or-self::d:book/@xml:id]"/>

   <!--<xsl:message>
    targets = <xsl:value-of select="count($targets)"/>
    d:sect1[@revision] = <xsl:value-of select="count($revisions)"/>
   </xsl:message>-->

   <xsl:choose>
    <xsl:when test="count($revisions) > 0">
     <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/><!-- select="node()[not(self::d:para[. = ''])]" -->
      <xsl:message>docupdates: Grouping <xsl:value-of select="@revision"/></xsl:message>

      <variablelist>
       <xsl:for-each select="$revisions">
        <xsl:apply-templates select="current()" mode="docupdate">
         <xsl:with-param name="origin" select="."/>
         <xsl:sort select="@revision" order="descending"/>
        </xsl:apply-templates>
       </xsl:for-each>
      </variablelist>
     </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
     <xsl:message>docupdates: No entry found for revision '<xsl:value-of select="@revision"/>'</xsl:message>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>


 <xsl:template match="d:revhistory/d:revision" mode="docupdate">
  <xsl:param name="origin" select="."/>
  <xsl:variable name="division" select="ancestor::d:info/parent::*"/>

  <varlistentry>
   <term>
    <xsl:choose>
     <xsl:when test="$division/self::d:book">General</xsl:when>
     <xsl:otherwise><xref linkend="{$division/@xml:id}"/></xsl:otherwise>
    </xsl:choose>
   </term>
   <listitem>
    <xsl:apply-templates select="d:revdescription/node()"/>
   </listitem>
  </varlistentry>
 </xsl:template>
  
</xsl:stylesheet>