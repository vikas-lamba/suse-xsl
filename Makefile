# Makefile for suse-xsl-stylesheets
#
# Copyright (C) 2011-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
ifndef PREFIX
  PREFIX := /usr/share
endif

SHELL         := /bin/bash
PACKAGE       := suse-xsl-stylesheets
VERSION       := 2.0~rc6
SUSE_XML_PATH := $(PREFIX)/xml/suse
DB_XML_PATH   := $(PREFIX)/xml/docbook
SUSE_SCHEMA_PATH := $(SUSE_XML_PATH)/schema
SUSE_STYLES_PATH := $(DB_XML_PATH)/stylesheet

#--------------------------------------------------------------
# NOVDOC

NOVDOC_NAME     := novdoc
NOVDOC_VERSION  := 1.0
NOVDOC_DTD_PATH := $(SUSE_SCHEMA_PATH)/dtd/$(NOVDOC_VERSION)

#--------------------------------------------------------------
# SUSEDOC

#SUSEDOC_NAME     := susedoc
#SUSEDOC_VERSION  := 0.9
#SUSEDOC_RNG_PATH := $(SUSE_SCHEMA_PATH)/rng/$(SUSEDOC_VERSION)

#--------------------------------------------------------------
# stylsheet directory names

DIR2005          := suse
DIR2013_SUSE     := suse2013
DIR2013_OPENSUSE := opensuse2013
DIR2013_DAPS     := daps2013

ALL_STYLEDIRS := $(DIR2005) $(DIR2013_SUSE) $(DIR2013_OPENSUSE) $(DIR2013_DAPS)

#--------------------------------------------------------------
# Directories and files that will be created

BUILD_DIR       := build
DEV_ASPELL_DIR  := $(BUILD_DIR)/aspell
DEV_CATALOG_DIR := $(BUILD_DIR)/catalogs
DEV_STYLE_DIR   := $(BUILD_DIR)/stylesheet
DEV_HTML_DIR    := $(BUILD_DIR)/$(DIR2005)/html

# aspell dictionary
SUSE_DICT := $(BUILD_DIR)/aspell/en_US-suse-addendum.rws

# Catalog stuff
#
SUSEXSL_CATALOG    := $(DEV_CATALOG_DIR)/catalog-for-$(PACKAGE).xml
SUSESCHEMA_CATALOG := $(DEV_CATALOG_DIR)/catalog-for-suse_schemas.xml


# html4 stylesheets for STYLEDIR2005 are autogenerated from the xhtml
# stylesheets so we only need to maintain them in one place
#
XHTML2HTML      := $(DIR2005)/common/xhtml2html.xsl
HTMLSTYLESHEETS := $(subst $(DIR2005)/xhtml,$(DEV_HTML_DIR),$(wildcard $(DIR2005)/xhtml/*.xsl))

#-------
# Local Stylsheets Directories

DEV_DIR2005          := $(DEV_STYLE_DIR)/$(DIR2005)-ns
DEV_DIR2013_DAPS     := $(DEV_STYLE_DIR)/$(DIR2013_DAPS)-ns
DEV_DIR2013_OPENSUSE := $(DEV_STYLE_DIR)/$(DIR2013_OPENSUSE)-ns
DEV_DIR2013_SUSE     := $(DEV_STYLE_DIR)/$(DIR2013_SUSE)-ns

DEV_DIRECTORIES := $(DEV_ASPELL_DIR) $(DEV_CATALOG_DIR) $(DEV_HTML_DIR) \
   $(DEV_DIR2005) $(DEV_DIR2013_DAPS) $(DEV_DIR2013_OPENSUSE) \
   $(DEV_DIR2013_SUSE)

LOCAL_STYLEDIRS := $(DIR2005) $(DEV_DIR2005) \
   $(DIR2013_SUSE) $(DEV_DIR2013_SUSE) $(DIR2013_DAPS) $(DEV_DIR2013_DAPS) \
   $(DIR2013_OPENSUSE) $(DEV_DIR2013_OPENSUSE)


#-------------------------------------------------------
# Directories for installation

INST_STYLE_ROOT          := $(DESTDIR)$(SUSE_STYLES_PATH)

STYLEDIR2005            := $(INST_STYLE_ROOT)/$(DIR2005)
STYLEDIR2005-NS         := $(INST_STYLE_ROOT)/$(DIR2005)-ns
SUSESTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)
SUSESTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)-ns
DAPSSTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_DAPS)
DAPSSTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_DAPS)-ns
OPENSUSESTYLEDIR2013    := $(INST_STYLE_ROOT)/$(DIR2013_OPENSUSE)
OPENSUSESTYLEDIR2013-NS := $(INST_STYLE_ROOT)/$(DIR2013_OPENSUSE)-ns

ASPELLDIR     := $(DESTDIR)$(PREFIX)/suse-xsl-stylesheets/aspell
DOCDIR        := $(DESTDIR)$(PREFIX)/doc/packages/suse-xsl-stylesheets
DTDDIR_10     := $(DESTDIR)$(PREFIX)/xml/suse/schema/dtd/1.0
RNGDIR_09     := $(DESTDIR)$(PREFIX)/xml/suse/schema/rng/0.9
RNGDIR_10     := $(DESTDIR)$(PREFIX)/xml/suse/schema/rng/1.0
TTF_FONT_DIR  := $(DESTDIR)$(PREFIX)/fonts/truetype
CATALOG_DIR   := $(DESTDIR)/etc/xml
SGML_DIR      := $(DESTDIR)$(PREFIX)/sgml
VAR_SGML_DIR  := $(DESTDIR)/var/lib/sgml

INST_STYLEDIRS := $(STYLEDIR2005) $(STYLEDIR2005-NS) \
   $(SUSESTYLEDIR2013) $(SUSESTYLEDIR2013-NS) $(DAPSSTYLEDIR2013) \
   $(DAPSSTYLEDIR2013-NS) $(OPENSUSESTYLEDIR2013) $(OPENSUSESTYLEDIR2013-NS)

INST_DIRECTORIES := $(ASPELLDIR) $(INST_STYLEDIRS) $(DOCDIR) $(DTDDIR_10) \
   $(RNGDIR_09) $(RNGDIR_10) $(TTF_FONT_DIR) $(CATALOG_DIR) $(SGML_DIR) \
   $(VAR_SGML_DIR)

#############################################################

all: schema/rng/1.0/novdocx.rng schema/rng/1.0/novdocxi.rng
all: $(SUSESCHEMA_CATALOG) $(SUSEXSL_CATALOG)
all: $(DEV_CATALOG_DIR)/CATALOG.$(NOVDOC_NAME)-$(NOVDOC_VERSION)
all: $(HTMLSTYLESHEETS) $(SUSE_DICT) generate_xslns
	@echo "Ready to install..."

#-----------------------------
install: | $(INST_DIRECTORIES)
	install -m644 $(SUSE_DICT) $(ASPELLDIR)
	install -m644 schema/rng/0.9/*.rnc $(RNGDIR_09)
	install -m644 schema/rng/1.0/*.{rnc,rng,ent} $(RNGDIR_10)
	install -m644 schema/dtd/1.0/{*.dtd,*.ent,catalog.xml,CATALOG} $(DTDDIR_10)
	install -m644 $(DEV_CATALOG_DIR)/CATALOG.$(NOVDOC_NAME)-$(NOVDOC_VERSION) $(VAR_SGML_DIR)
	ln -s /var/lib/sgml/CATALOG.$(NOVDOC_NAME)-$(NOVDOC_VERSION) $(SGML_DIR)
	install -m644 $(DEV_CATALOG_DIR)/*.xml $(CATALOG_DIR)
	install -m644 COPYING* $(DOCDIR)
	install -m644 fonts/*.ttf $(TTF_FONT_DIR)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2005) . | (cd  $(STYLEDIR2005); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2005) . | (cd  $(STYLEDIR2005-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_DAPS) . | (cd  $(DAPSSTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_DAPS) . | (cd  $(DAPSSTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_OPENSUSE) . | (cd  $(OPENSUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_OPENSUSE) . | (cd  $(OPENSUSESTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_SUSE) . | (cd  $(SUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_SUSE) . | (cd  $(SUSESTYLEDIR2013-NS); tar xp)
	for SDIR in $(INST_STYLEDIRS); do \
	   sed -i "s/@@#version@@/$(VERSION)/" $$SDIR/version.xsl; \
	done

#-----------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) schema/rng/1.0/novdocx-core.rnc \
	  schema/rng/1.0/novdocx-core.rng schema/rng/1.0//novdocx.rng \
	  schema/rng/1.0//novdocxi.rng

#-----------------------------
# Generate SUSE aspell dictionary
#
$(SUSE_DICT): $(DEV_ASPELL_DIR)/suse_wordlist_tmp.txt
	aspell --lang=en create master ./$@ < $<

.INTERMEDIATE: $(DEV_ASPELL_DIR)/suse_wordlist_tmp.txt
$(DEV_ASPELL_DIR)/suse_wordlist_tmp.txt: aspell/suse_wordlist.txt | $(DEV_ASPELL_DIR)
	cat $< | sort | uniq > $@

#-----------------------------
# auto-generate the DocBook5 (xsl-ns) stylesheets
# Let's be super lazy and generate them every time make is called by
# making this target PHONY
#
.PHONY: generate_xslns
generate_xslns: | $(LOCAL_STYLEDIRS)
	bin/xslns-build $(DIR2005) $(DEV_DIR2005)
	bin/xslns-build $(DIR2013_DAPS) $(DEV_DIR2013_DAPS)
	bin/xslns-build $(DIR2013_OPENSUSE) $(DEV_DIR2013_OPENSUSE)
	bin/xslns-build $(DIR2013_SUSE) $(DEV_DIR2013_SUSE)

#-----------------------------
# Auto-generate HTML stylesheets from XHTML:
$(DEV_HTML_DIR)/%.xsl: $(DIR2005)/xhtml/%.xsl | $(DEV_HTML_DIR)
	xsltproc --output $@  ${XHTML2HTML} $<


#-----------------------------
# Generate SGML catalog for novdoc
#
$(DEV_CATALOG_DIR)/CATALOG.$(NOVDOC_NAME)-$(NOVDOC_VERSION): | $(DEV_CATALOG_DIR)
$(DEV_CATALOG_DIR)/CATALOG.$(NOVDOC_NAME)-$(NOVDOC_VERSION):
	echo \
	  "CATALOG \"$(NOVDOC_DTD_PATH)/CATALOG\"" \
	  > $@

#-----------------------------
# Generate RELAX NG schemes for novdoc
#
# schemas cannot be build under build/schema, because the *-core files
# are included

schema/rng/1.0/novdocx-core.rnc: schema/dtd/1.0/novdocx.dtd.tmp
	trang -I dtd -i no-generate-start $< $@

schema/rng/1.0/novdocx-core.rng: schema/dtd/1.0/novdocx.dtd.tmp
	trang -I dtd -i no-generate-start $< $@

schema/rng/1.0/novdocx.rng: schema/rng/1.0/novdocx.rnc schema/rng/1.0/novdocx-core.rnc
	trang -I rnc $< $@

schema/rng/1.0/novdocxi.rng: schema/rng/1.0/novdocxi.rnc schema/rng/1.0/novdocx-core.rnc
	trang -I rnc $< $@

#schema/rng/0.9/susedoc5.rng: schema/rng/0.9/susedoc5.rnc
#	trang -I rnc $< $@


# To avoid unknown host errors with trang, we have to switch off the external
# entities from DocBook by creating a temporary file novdocx.dtd.tmp.
# As the entities are not used in RELAX NG anyway, this is uncritical.
#
.INTERMEDIATE: schema/dtd/1.0/novdocx.dtd.tmp
schema/dtd/1.0/novdocx.dtd.tmp:
	sed 's:\(%[ \t]*ISO[^\.]*\.module[ \t]*\)"INCLUDE":\1"IGNORE":g' \
	  < schema/dtd/1.0/novdocx.dtd > $@

#-----------------------------
# Generate SUSE schema catalog
#

# since xmlcatalog cannot create groups (<group>) we need to use sed
# to fix this; while we are at it, we also remove the DOCTYPE line since
# it may cause problems with some XML parsers (hen/egg problem)
#
$(SUSESCHEMA_CATALOG): | $(DEV_CATALOG_DIR)
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add "delegatePublic" "-//Novell//DTD NovDoc XML" \
	  "file://$(NOVDOC_DTD_PATH)/catalog.xml" $@
	xmlcatalog --noout --add "delegateSystem" "novdocx.dtd" \
	  "file://$(NOVDOC_DTD_PATH)/catalog.xml" $@
	xmlcatalog --noout --add "rewriteSystem" "http://raw.githubusercontent.com/openSUSE/suse-xsl/master/schema/" "file://$(SUSE_SCHEMA_PATH)/" $@
	xmlcatalog --noout --add "rewriteURI" "http://raw.githubusercontent.com/openSUSE/suse-xsl/master/schema/" "file://$(SUSE_SCHEMA_PATH)/" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="suse_schemas">' $@
	sed -i '/<\/catalog/i\ </group>' $@

# FIXME: None of the below URLs exist. Would be good if they would at least
#        redirect into the SVN instead of 404ing.
$(SUSEXSL_CATALOG): | $(DEV_CATALOG_DIR)
	xmlcatalog --noout --create $@
	for catalog in $(ALL_STYLEDIRS); do \
	  xmlcatalog --noout --add "rewriteSystem" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$$catalog" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$$catalog)" $@; \
	  xmlcatalog --noout --add "rewriteURI" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$$catalog" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$$catalog)" $@; \
	  xmlcatalog --noout --add "rewriteSystem" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$${catalog}-ns" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$${catalog}-ns)" $@; \
	  xmlcatalog --noout --add "rewriteURI" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$${catalog}-ns" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$${catalog}-ns)" $@; \
	done
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	sed -i '/<\/catalog/i\ </group>' $@

# create needed directories
#
$(INST_DIRECTORIES) $(DEV_DIRECTORIES):
	mkdir -p $@
