#
# spec file for package suse-xsl-stylesheets
#
# Copyright (c) 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (version 1.9)
# published by the Open Source Initiative.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/


Name:           suse-xsl-stylesheets
Version:        2.0~rc4
Release:        1

###############################################################
#
# ATTENTION: Do NOT edit this file outside of
#            https://svn.code.sf.net/p/daps/svn/trunk/daps/\
#            suse/packaging/suse-xsl-stylesheets.spec
#
#  Your changes will be lost on the next update
#  If you do not have access to the SVN repository, notify
#  <fsundermeyer@opensuse.org> and <toms@opensuse.org>
#  or send a patch
#
################################################################

%define dtdversion      1.0
%define dtdname         novdoc
%define regcat          %{_bindir}/sgml-register-catalog
%define dbstyles        %{_datadir}/xml/docbook/stylesheet/nwalsh/current
%define novdoc_catalog  for-catalog-%{dtdname}-%{dtdversion}.xml
%define susexsl_catalog for-catalog-%{name}.xml

Summary:        SUSE-branded Docbook stylesheets for XSLT 1.0
License:        GPL-2.0 or GPL-3.0
Group:          Productivity/Publishing/XML
Url:            http://sourceforge.net/p/daps/suse-xslt
Source0:        %{name}-%{version}.tar.bz2
Source1:        susexsl-fetch-source
Source2:        %{name}.rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

BuildRequires:  docbook-xsl-stylesheets >= 1.77
BuildRequires:  fdupes
BuildRequires:  libxslt
BuildRequires:  make
# Only needed to fix the "have choice" error between xerces-j2 and crimson
%if 0%{?suse_version} == 1210
BuildRequires:  xerces-j2
%endif
BuildRequires:  trang

Requires:       docbook-xsl-stylesheets >= 1.77
Requires:       docbook_4
Requires:       libxslt

Recommends:     daps
Recommends:     docbook_5
Recommends:     docbook5-xsl-stylesheets

#------
# Fonts
#------
%if 0%{?suse_version} >= 1220
Requires:       dejavu-fonts
Requires:       gnu-free-fonts
Requires:       liberation-fonts
Recommends:     agfa-fonts
# Japanese:
Recommends:     sazanami-fonts
# Korean:
Recommends:     un-fonts
%else
Requires:       dejavu
Requires:       freefont
Requires:       liberation-fonts
Recommends:     agfa-fonts
# Japanese:
Recommends:     sazanami-fonts
# Korean:
Recommends:     unfonts
%endif
# Chinese -- only available from M17N:fonts in Code 11:
Recommends:     wqy-microhei-fonts

%if 0%{?sles_version}
Recommends:     ttf-founder-simplified
%endif

# FONTS USED IN suse_beta STYLESHEETS
# A rather simplistic solution which roughly means that you need M17N:fonts to
# build the new stylesheets on older OS's.
%if 0%{?suse_version} >= 1220
Requires:       google-opensans-fonts
Requires:       sil-charis-fonts
%else
Recommends:     google-opensans-fonts
Recommends:     sil-charis-fonts
%endif
# Monospace -- dejavu-fonts, already required
# Western fonts fallback -- gnu-free-fonts, already required

# Chinese simplified -- wqy-microhei-fonts, already recommended
# Chinese traditional:
Recommends:     arphic-uming-fonts
# Japanese:
Recommends:     ipa-pgothic-fonts
Recommends:     ipa-pmincho-fonts
# Korean:
Recommends:     nanum-fonts
# Arabic:
Recommends:     arabic-amiri-fonts

Obsoletes:      susedoc <= 4.3.33
Provides:       susedoc = 4.3.34

%description
SUSE-branded DocBook stylesheets for XSLT 1.0

Extensions for the DocBook XSLT 1.0 stylesheets that provide SUSE branding
for PDF, HTML, and ePUB. This package also provides the NovDoc DTD, a subset of
the DocBook 4 DTD.

#--------------------------------------------------------------------------
%prep
%setup -q -n %{name}
#
# Patch the VERSION.xsl file to hold the current version
# FIXME: this is not the right place for these sed lines -- if anyone ever
#        creates e.g. a Debian package, these would lines would have to be
#        duplicated in the DEB equivalent of a spec file. This should be in
#        ../Makefile instead.
sed -i "s/@@#version@@/%{version}/" xslt2005/version.xsl
sed -i "s/@@#version@@/%{version}/" suse2013/version.xsl
sed -i "s/@@#version@@/%{version}/" daps2013/version.xsl
sed -i "s/@@#version@@/%{version}/" opensuse2013/version.xsl

#--------------------------------------------------------------------------
%build
%__make  %{?_smp_mflags}

#--------------------------------------------------------------------------
%install
make install DESTDIR=$RPM_BUILD_ROOT

# create symlinks:
%fdupes -s $RPM_BUILD_ROOT/%{_datadir}

#----------------------
%post
# register catalogs
#
# SGML CATALOG
#
if [ -x %{regcat} ]; then
  %{regcat} -a %{_datadir}/sgml/CATALOG.%{dtdname}-%{dtdversion} >/dev/null 2>&1 || true
fi
# XML Catalogs
#
# remove existing entries first - needed for
# zypper in, since it does not call postun
# delete ...
if [ "2" = "$1" ]; then
 edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}-%{dtdversion} || true
 edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{name} || true
fi

# ... and (re)add it again
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --add /etc/xml/%{novdoc_catalog}
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --add /etc/xml/%{susexsl_catalog}

exit 0

#----------------------
%postun
#
# Remove catalog entries
#
# delete catalog entries
# only run if package is really uninstalled ($1 = 0) and not
# in case of an update
#
if [ "0" = "$1" ]; then
  if [ ! -f %{_sysconfdir}/xml/%{novdoc_catalog} -a -x /usr/bin/edit-xml-catalog ] ; then
    # SGML: novdoc dtd entry
    %{regcat} -r %{_datadir}/sgml/CATALOG.%{dtdname}-%{dtdversion} >/dev/null 2>&1 || true
    # XML
    # novdoc dtd entry
    edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
        --del %{dtdname}-%{dtdversion}
    # susexsl entry
    edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
        --del %{name}
  fi
fi

exit 0


#----------------------
%files
%defattr(-,root,root)

# Directories
%dir %{_datadir}/xml/docbook/stylesheet/suse
%dir %{_datadir}/xml/docbook/stylesheet/suse2013
%dir %{_datadir}/xml/docbook/stylesheet/daps2013
%dir %{_datadir}/xml/docbook/stylesheet/opensuse2013

%dir %{_datadir}/xml/%{dtdname}
%dir %{_datadir}/xml/%{dtdname}/schema
%dir %{_datadir}/xml/%{dtdname}/schema/*
%dir %{_datadir}/xml/%{dtdname}/schema/*/%{dtdversion}

%dir %{_defaultdocdir}/%{name}

# stylesheets
%{_datadir}/xml/docbook/stylesheet/suse/*
%{_datadir}/xml/docbook/stylesheet/suse2013/*
%{_datadir}/xml/docbook/stylesheet/daps2013/*
%{_datadir}/xml/docbook/stylesheet/opensuse2013/*

# NovDoc Schemas
%{_datadir}/xml/%{dtdname}/schema/dtd/%{dtdversion}/*
%{_datadir}/xml/%{dtdname}/schema/rng/%{dtdversion}/*

# Catalogs
%config /var/lib/sgml/CATALOG.*
%{_datadir}/sgml/CATALOG.*
%config %{_sysconfdir}/xml/*.xml

# Documentation
%doc %{_defaultdocdir}/%{name}/*

#----------------------
%changelog
