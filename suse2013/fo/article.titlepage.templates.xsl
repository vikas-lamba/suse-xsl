<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle article titlepage

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <!-- Article ==================================================== -->
  <xsl:template name="article.titlepage.recto">
    <xsl:variable name="height">
      <xsl:call-template name="get.value.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="unit">
      <xsl:call-template name="get.unit.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>


    <fo:table space-after="4em"><!--  border="1pt solid red" -->
      <fo:table-body>
        <fo:table-cell>
          <fo:block text-align="start" padding-left="0">
            <xsl:choose>
              <!-- Don't let Geeko overhang the right side of the page - it
             is not mirrored, thus some letters would hang over the side
             of the page, instead of the tail. -->
              <!-- FIXME: This is not the optimal implementation if we ever
             want to be able to switch out images easily. -->
              <xsl:when test="$writing.mode = 'rl'">
                <xsl:attribute name="margin-right">
                  <xsl:value-of select="&columnfragment; + &gutter;"/>mm
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="margin-left">
                  <xsl:value-of
                    select="&columnfragment; + &gutter; - $titlepage.logo.overhang"
                  />mm </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          <fo:instream-foreign-object content-width="{$titlepage.logo.width}"
            width="{$titlepage.logo.width}">
            <xsl:call-template name="logo-image"/>
          </fo:instream-foreign-object>
          </fo:block>
        </fo:table-cell>
        <fo:table-cell>
          <xsl:choose>
            <xsl:when test="/article[@role='sbp']">
              <xsl:call-template name="sbp-head"/>
            </xsl:when>
            <xsl:otherwise>
              <fo:block/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:table-cell>
      </fo:table-body>
    </fo:table>


    <fo:block start-indent="{&columnfragment; + &gutter;}mm" text-align="start"
      role="article.titlepage.recto">
      <fo:block space-after="{&gutterfragment;}mm">
        <xsl:choose>
          <xsl:when test="articleinfo/title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="articleinfo/title"/>
          </xsl:when>
          <xsl:when test="artheader/title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="artheader/title"/>
          </xsl:when>
          <xsl:when test="info/title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="info/title"/>
          </xsl:when>
          <xsl:when test="title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode" select="title"/>
          </xsl:when>
        </xsl:choose>
       <xsl:choose>
        <xsl:when test="articleinfo/subtitle">
         <xsl:apply-templates
          mode="article.titlepage.recto.auto.mode"
          select="articleinfo/subtitle"/>
        </xsl:when>
        <xsl:when test="artheader/subtitle">
         <xsl:apply-templates
          mode="article.titlepage.recto.auto.mode"
          select="artheader/subtitle"/>
        </xsl:when>
        <xsl:when test="info/subtitle">
         <xsl:apply-templates
          mode="article.titlepage.recto.auto.mode"
          select="info/subtitle"/>
        </xsl:when>
        <xsl:when test="subtitle">
         <xsl:apply-templates
          mode="article.titlepage.recto.auto.mode"
          select="subtitle"/>
        </xsl:when>
       </xsl:choose>
      </fo:block>

    <fo:block padding-before="{2 * &gutterfragment;}mm"
      padding-start="{&column; + &columnfragment; + &gutter;}mm">
      <xsl:attribute name="border-top"><xsl:value-of select="concat(&mediumline;,'mm solid ',$dark-green)"/></xsl:attribute>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="(articleinfo/productname[not(@role='abbrev')] | info/productname[not(@role='abbrev')])[1]"/>
    </fo:block>

    <fo:block>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/author"/>
    </fo:block>

   <xsl:if test="articleinfo/cover[@role='logos'] or info/cover[@role='logos']">
     <xsl:call-template name="cover-logo-lockup">
       <xsl:with-param name="node" select="(articleinfo/cover[@role='logos']|info/cover[@role='logos'])[1]"/>
     </xsl:call-template>
   </xsl:if>

   <fo:block page-break-before="always">
    <xsl:choose>
      <xsl:when test="articleinfo/abstract or info/abstract">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/abstract"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/abstract"/>
      </xsl:when>
      <xsl:when test="abstract">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="abstract"/>
      </xsl:when>
    </xsl:choose>
    </fo:block>
     
    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"  select="articleinfo/othercredit"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"  select="info/othercredit"/>
    </fo:block>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/editor"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/editor"/>
    </fo:block>

    <fo:block>
      <xsl:call-template name="date.and.revision"/>
    </fo:block>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/mediaobject"/>
    </fo:block>
    </fo:block>
  </xsl:template>

  <xsl:template name="sbp-head">
    <fo:block text-align="end" font-size="&x-large;" xsl:use-attribute-sets="dark-green">
    <!-- FIXME: Run this through l10n machinery. -->
      SUSE Best Practices
    </fo:block>
  </xsl:template>

  <xsl:template name="cover-logo-lockup">
    <xsl:param name="node" select="."/>
    <fo:block-container top="245mm" left="&column;mm"
    width="{&column; * 6 + &gutter; * 6}mm"
    absolute-position="fixed">
    <fo:block border="&test2border;">
      <fo:table width="100%" border="&test1border;"
        table-layout="fixed" block-progression-dimension="auto">
        <!-- A maximum of four logos should hopefully be fine. -->
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell>
              <fo:block/>
            </fo:table-cell>
            <fo:table-cell display-align="center" margin="0">
              <xsl:if test="$node/mediaobject[4]">
                <xsl:attribute name="border-right">&thinline;mm solid &black;</xsl:attribute>
              </xsl:if>
              <fo:block padding="{&gutter; * .5}mm &gutter;mm">
                <xsl:if test="$node/mediaobject[4]">
                  <xsl:apply-templates select="$node/mediaobject[4]"/>
                </xsl:if>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell display-align="center" margin="0">
              <xsl:if test="$node/mediaobject[3]">
                <xsl:attribute name="border-right">&thinline;mm solid &black;</xsl:attribute>
              </xsl:if>
              <fo:block padding="{&gutter; * .5}mm &gutter;mm">
                <xsl:if test="$node/mediaobject[3]">
                  <xsl:apply-templates select="$node/mediaobject[3]"/>
                </xsl:if>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell display-align="center" margin="0">
              <xsl:if test="$node/mediaobject[2]">
                <xsl:attribute name="border-right">&thinline;mm solid &black;</xsl:attribute>
              </xsl:if>
              <fo:block padding="0" margin="0" width="auto" height="auto" text-align="center" line-height="1em" border="&test2border;">
                <xsl:if test="$node/mediaobject[2]">
                  <xsl:variable name="imagepath2" select="concat($img.src.path,$node/mediaobject[2]/imageobject[1]/imagedata[1]/@fileref)"/>
                  <fo:external-graphic src="url({$imagepath2})" border="&test5border;" padding="0" margin="0" width="&column;mm" height="auto" content-width="scale-to-fit" content-height="scale-to-fit"/>
<!--                  <xsl:apply-templates select="$node/mediaobject[2]"/>-->
                </xsl:if>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell display-align="center" margin="0">
              <fo:block padding="0" margin="0" width="auto" height="auto" text-align="center" line-height="1em" border="&test1border;">
                <xsl:if test="$node/mediaobject[1]">
                  <xsl:variable name="imagepath1" select="concat($img.src.path,$node/mediaobject[1]/imageobject[1]/imagedata[1]/@fileref)"/>
                  <fo:external-graphic src="url({$imagepath1})" border="&test4border;" padding="0" margin="0" width="&column;mm" height="auto" content-width="scale-to-fit" content-height="scale-to-fit"/>
<!--                  <xsl:apply-templates select="$node/mediaobject[1]"/>-->
                </xsl:if>
               </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
    </fo:block-container>
  </xsl:template>


  <xsl:template match="mediaobject" mode="article.titlepage.recto.auto.mode">
   <xsl:call-template name="select.mediaobject"/>
  </xsl:template>
 
  <xsl:template match="articleinfo/mediaobject" mode="article.titlepage.recto.auto.mode">
    <fo:block break-after="page">
      <xsl:call-template name="select.mediaobject"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="title" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&super-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.85}em"
      xsl:use-attribute-sets="article.titlepage.recto.style dark-green"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="subtitle" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&xx-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.75}em"
      xsl:use-attribute-sets="article.titlepage.recto.style mid-green"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="productname[1]" mode="article.titlepage.recto.auto.mode">
    <fo:block text-align="start" font-size="{&xx-large; * $sans-fontsize-adjust}pt"
      xsl:use-attribute-sets="mid-green">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
      <xsl:if test="../productnumber">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="../productnumber[1]" mode="article.titlepage.recto.mode"/>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="authorgroup" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&large; * $sans-fontsize-adjust}pt" space-before="1em" text-align="start">
      <xsl:call-template name="person.name.list">
        <xsl:with-param name="person.list" select="author|corpauthor"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

  <xsl:template match="author|corpauthor"
    mode="article.titlepage.recto.auto.mode">
   <xsl:variable name="person">
    <xsl:call-template name="person.name.first-last"/>
   </xsl:variable>
    <fo:block space-before="1em" font-size="{&large; * $sans-fontsize-adjust}pt" text-align="start">
       <xsl:value-of select="$person"/>
       <xsl:if test="affiliation/jobtitle">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="affiliation/jobtitle"/>
        <xsl:text>, </xsl:text>
       </xsl:if>
       <xsl:if test="affiliation/orgname">
        <xsl:value-of select="affiliation/orgname"/>
       </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="editor|othercredit"
    mode="article.titlepage.recto.auto.mode">
    <xsl:if test=". = ((../othercredit)|(../editor))[1]">
      <fo:block font-size="{&normal; * $sans-fontsize-adjust}pt">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">
            <xsl:choose>
              <xsl:when test="count((../othercredit)|(../editor)) > 1"
                >Contributors</xsl:when>
              <xsl:otherwise>Contributor</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>: </xsl:text>
        <xsl:call-template name="person.name.list">
          <xsl:with-param name="person.list"
            select="(../othercredit)|(../editor)"/>
        </xsl:call-template>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match="abstract" mode="article.titlepage.recto.auto.mode">
    <fo:block space-after="1.5em">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="article/abstract"/>

</xsl:stylesheet>
