# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Authors: James D. Trotter <james@simula.no>
#
# nss-3.69

nss-version = 3.69
nss = nss-$(nss-version)
$(nss)-description = Network Security Services (NSS) libraries for cross-platform development of security-enabled client and server applications
$(nss)-url = https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS
$(nss)-srcurl = https://archive.mozilla.org/pub/security/nss/releases/NSS_3_69_RTM/src/nss-3.69.tar.gz
$(nss)-builddeps = $(nspr) $(sqlite)
$(nss)-prereqs = $(nspr) $(sqlite)
$(nss)-src = $(pkgsrcdir)/$(notdir $($(nss)-srcurl))
$(nss)-srcdir = $(pkgsrcdir)/$(nss)
$(nss)-builddir = $($(nss)-srcdir)/nss
$(nss)-modulefile = $(modulefilesdir)/$(nss)
$(nss)-prefix = $(pkgdir)/$(nss)

$($(nss)-src): $(dir $($(nss)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(nss)-srcurl)

$($(nss)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(nss)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(nss)-prefix)/.pkgunpack: $$($(nss)-src) $($(nss)-srcdir)/.markerfile $($(nss)-prefix)/.markerfile $$(foreach dep,$$($(nss)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(nss)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(nss)-srcdir)/nss-3.69-standalone-1.patch: $($(nss)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'Submitted By:            Xi Ruoyao <xry111_AT_mengyan1223_DOT_wang>' >>$@.tmp
	@echo 'Date:                    2020-08-22' >>$@.tmp
	@echo 'Initial Package Version: 3.12.4' >>$@.tmp
	@echo 'Upstream Status:         Not applicable' >>$@.tmp
	@echo 'Origin:                  Self, adjusted for nss-3.56.' >>$@.tmp
	@echo 'Description:             Adds auto-generated nss.pc and nss-config script, and' >>$@.tmp
	@echo '                         allows building without nspr in the source tree.' >>$@.tmp
	@echo '                         Minimum NSPR version is now read out from package,' >>$@.tmp
	@echo '                         instead of hardcoded value in the patch.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --color -uNar nss-3.55.orig/nss/config/Makefile nss-3.55/nss/config/Makefile' >>$@.tmp
	@echo '--- nss-3.55.orig/nss/config/Makefile	1970-01-01 08:00:00.000000000 +0800' >>$@.tmp
	@echo '+++ nss-3.55/nss/config/Makefile	2020-07-25 19:34:36.272982957 +0800' >>$@.tmp
	@echo '@@ -0,0 +1,42 @@' >>$@.tmp
	@echo '+CORE_DEPTH = ..' >>$@.tmp
	@echo '+DEPTH      = ..' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+include $$(CORE_DEPTH)/coreconf/config.mk' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+NSS_MAJOR_VERSION = `grep "NSS_VMAJOR" ../lib/nss/nss.h | awk '\''{print $$$$3}'\''`' >>$@.tmp
	@echo '+NSS_MINOR_VERSION = `grep "NSS_VMINOR" ../lib/nss/nss.h | awk '\''{print $$$$3}'\''`' >>$@.tmp
	@echo '+NSS_PATCH_VERSION = `grep "NSS_VPATCH" ../lib/nss/nss.h | awk '\''{print $$$$3}'\''`' >>$@.tmp
	@echo '+NSS_NSPR_MINIMUM = `head -n1 ../automation/release/nspr-version.txt`' >>$@.tmp
	@echo '+PREFIX = /usr' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+all: export libs' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+export:' >>$@.tmp
	@echo '+	# Create the nss.pc file' >>$@.tmp
	@echo '+	mkdir -p $$(DIST)/lib/pkgconfig' >>$@.tmp
	@echo '+	sed -e "s,@prefix@,$$(PREFIX)," \' >>$@.tmp
	@echo '+	    -e "s,@exec_prefix@,\$$$${prefix}," \' >>$@.tmp
	@echo '+	    -e "s,@libdir@,\$$$${prefix}/lib," \' >>$@.tmp
	@echo '+	    -e "s,@includedir@,\$$$${prefix}/include/nss," \' >>$@.tmp
	@echo '+	    -e "s,@NSS_MAJOR_VERSION@,$$(NSS_MAJOR_VERSION),g" \' >>$@.tmp
	@echo '+	    -e "s,@NSS_MINOR_VERSION@,$$(NSS_MINOR_VERSION)," \' >>$@.tmp
	@echo '+	    -e "s,@NSS_PATCH_VERSION@,$$(NSS_PATCH_VERSION)," \' >>$@.tmp
	@echo '+	    -e "s,@NSS_NSPR_MINIMUM@,$$(NSS_NSPR_MINIMUM)," \' >>$@.tmp
	@echo '+	    nss.pc.in > nss.pc' >>$@.tmp
	@echo '+	chmod 0644 nss.pc' >>$@.tmp
	@echo '+	ln -sf ../../../../nss/config/nss.pc $$(DIST)/lib/pkgconfig' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+	# Create the nss-config script' >>$@.tmp
	@echo '+	mkdir -p $$(DIST)/bin' >>$@.tmp
	@echo '+	sed -e "s,@prefix@,$$(PREFIX)," \' >>$@.tmp
	@echo '+	    -e "s,@NSS_MAJOR_VERSION@,$$(NSS_MAJOR_VERSION)," \' >>$@.tmp
	@echo '+	    -e "s,@NSS_MINOR_VERSION@,$$(NSS_MINOR_VERSION)," \' >>$@.tmp
	@echo '+	    -e "s,@NSS_PATCH_VERSION@,$$(NSS_PATCH_VERSION)," \' >>$@.tmp
	@echo '+	    nss-config.in > nss-config' >>$@.tmp
	@echo '+	chmod 0755 nss-config' >>$@.tmp
	@echo '+	ln -sf ../../../nss/config/nss-config $$(DIST)/bin' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+libs:' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+dummy: all export libs' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo 'diff --color -uNar nss-3.55.orig/nss/config/nss-config.in nss-3.55/nss/config/nss-config.in' >>$@.tmp
	@echo '--- nss-3.55.orig/nss/config/nss-config.in	1970-01-01 08:00:00.000000000 +0800' >>$@.tmp
	@echo '+++ nss-3.55/nss/config/nss-config.in	2020-07-25 19:32:37.239032214 +0800' >>$@.tmp
	@echo '@@ -0,0 +1,153 @@' >>$@.tmp
	@echo '+#!/bin/sh' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+prefix=@prefix@' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+major_version=@NSS_MAJOR_VERSION@' >>$@.tmp
	@echo '+minor_version=@NSS_MINOR_VERSION@' >>$@.tmp
	@echo '+patch_version=@NSS_PATCH_VERSION@' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+usage()' >>$@.tmp
	@echo '+{' >>$@.tmp
	@echo '+	cat <<EOF' >>$@.tmp
	@echo '+Usage: nss-config [OPTIONS] [LIBRARIES]' >>$@.tmp
	@echo '+Options:' >>$@.tmp
	@echo '+	[--prefix[=DIR]]' >>$@.tmp
	@echo '+	[--exec-prefix[=DIR]]' >>$@.tmp
	@echo '+	[--includedir[=DIR]]' >>$@.tmp
	@echo '+	[--libdir[=DIR]]' >>$@.tmp
	@echo '+	[--version]' >>$@.tmp
	@echo '+	[--libs]' >>$@.tmp
	@echo '+	[--cflags]' >>$@.tmp
	@echo '+Dynamic Libraries:' >>$@.tmp
	@echo '+	nss' >>$@.tmp
	@echo '+	nssutil' >>$@.tmp
	@echo '+	smime' >>$@.tmp
	@echo '+	ssl' >>$@.tmp
	@echo '+	softokn' >>$@.tmp
	@echo '+EOF' >>$@.tmp
	@echo '+	exit $$1' >>$@.tmp
	@echo '+}' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test $$# -eq 0; then' >>$@.tmp
	@echo '+	usage 1 1>&2' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+lib_nss=yes' >>$@.tmp
	@echo '+lib_nssutil=yes' >>$@.tmp
	@echo '+lib_smime=yes' >>$@.tmp
	@echo '+lib_ssl=yes' >>$@.tmp
	@echo '+lib_softokn=yes' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+while test $$# -gt 0; do' >>$@.tmp
	@echo '+  case "$$1" in' >>$@.tmp
	@echo '+  -*=*) optarg=`echo "$$1" | sed "s/[-_a-zA-Z0-9]*=//"` ;;' >>$@.tmp
	@echo '+  *) optarg= ;;' >>$@.tmp
	@echo '+  esac' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+  case $$1 in' >>$@.tmp
	@echo '+    --prefix=*)' >>$@.tmp
	@echo '+      prefix=$$optarg' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --prefix)' >>$@.tmp
	@echo '+      echo_prefix=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --exec-prefix=*)' >>$@.tmp
	@echo '+      exec_prefix=$$optarg' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --exec-prefix)' >>$@.tmp
	@echo '+      echo_exec_prefix=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --includedir=*)' >>$@.tmp
	@echo '+      includedir=$$optarg' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --includedir)' >>$@.tmp
	@echo '+      echo_includedir=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --libdir=*)' >>$@.tmp
	@echo '+      libdir=$$optarg' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --libdir)' >>$@.tmp
	@echo '+      echo_libdir=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --version)' >>$@.tmp
	@echo '+      echo $${major_version}.$${minor_version}.$${patch_version}' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --cflags)' >>$@.tmp
	@echo '+      echo_cflags=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    --libs)' >>$@.tmp
	@echo '+      echo_libs=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    nss)' >>$@.tmp
	@echo '+      lib_nss=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    nssutil)' >>$@.tmp
	@echo '+      lib_nssutil=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    smime)' >>$@.tmp
	@echo '+      lib_smime=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    ssl)' >>$@.tmp
	@echo '+      lib_ssl=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    softokn)' >>$@.tmp
	@echo '+      lib_softokn=yes' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+    *)' >>$@.tmp
	@echo '+      usage 1 1>&2' >>$@.tmp
	@echo '+      ;;' >>$@.tmp
	@echo '+  esac' >>$@.tmp
	@echo '+  shift' >>$@.tmp
	@echo '+done' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+# Set variables that may be dependent upon other variables' >>$@.tmp
	@echo '+if test -z "$$exec_prefix"; then' >>$@.tmp
	@echo '+    exec_prefix=`pkg-config --variable=exec_prefix nss`' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+if test -z "$$includedir"; then' >>$@.tmp
	@echo '+    includedir=`pkg-config --variable=includedir nss`' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+if test -z "$$libdir"; then' >>$@.tmp
	@echo '+    libdir=`pkg-config --variable=libdir nss`' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test "$$echo_prefix" = "yes"; then' >>$@.tmp
	@echo '+    echo $$prefix' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test "$$echo_exec_prefix" = "yes"; then' >>$@.tmp
	@echo '+    echo $$exec_prefix' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test "$$echo_includedir" = "yes"; then' >>$@.tmp
	@echo '+    echo $$includedir' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test "$$echo_libdir" = "yes"; then' >>$@.tmp
	@echo '+    echo $$libdir' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test "$$echo_cflags" = "yes"; then' >>$@.tmp
	@echo '+    echo -I$$includedir' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+if test "$$echo_libs" = "yes"; then' >>$@.tmp
	@echo '+      libdirs="-L$$libdir"' >>$@.tmp
	@echo '+      if test -n "$$lib_nss"; then' >>$@.tmp
	@echo '+	libdirs="$$libdirs -lnss$${major_version}"' >>$@.tmp
	@echo '+      fi' >>$@.tmp
	@echo '+      if test -n "$$lib_nssutil"; then' >>$@.tmp
	@echo '+        libdirs="$$libdirs -lnssutil$${major_version}"' >>$@.tmp
	@echo '+      fi' >>$@.tmp
	@echo '+      if test -n "$$lib_smime"; then' >>$@.tmp
	@echo '+	libdirs="$$libdirs -lsmime$${major_version}"' >>$@.tmp
	@echo '+      fi' >>$@.tmp
	@echo '+      if test -n "$$lib_ssl"; then' >>$@.tmp
	@echo '+	libdirs="$$libdirs -lssl$${major_version}"' >>$@.tmp
	@echo '+      fi' >>$@.tmp
	@echo '+      if test -n "$$lib_softokn"; then' >>$@.tmp
	@echo '+        libdirs="$$libdirs -lsoftokn$${major_version}"' >>$@.tmp
	@echo '+      fi' >>$@.tmp
	@echo '+      echo $$libdirs' >>$@.tmp
	@echo '+fi      ' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo 'diff --color -uNar nss-3.55.orig/nss/config/nss.pc.in nss-3.55/nss/config/nss.pc.in' >>$@.tmp
	@echo '--- nss-3.55.orig/nss/config/nss.pc.in	1970-01-01 08:00:00.000000000 +0800' >>$@.tmp
	@echo '+++ nss-3.55/nss/config/nss.pc.in	2020-07-25 19:33:05.958889937 +0800' >>$@.tmp
	@echo '@@ -0,0 +1,12 @@' >>$@.tmp
	@echo '+prefix=@prefix@' >>$@.tmp
	@echo '+exec_prefix=@exec_prefix@' >>$@.tmp
	@echo '+libdir=@libdir@' >>$@.tmp
	@echo '+includedir=@includedir@' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+Name: NSS' >>$@.tmp
	@echo '+Description: Network Security Services' >>$@.tmp
	@echo '+Version: @NSS_MAJOR_VERSION@.@NSS_MINOR_VERSION@.@NSS_PATCH_VERSION@' >>$@.tmp
	@echo '+Requires: nspr >= @NSS_NSPR_MINIMUM@' >>$@.tmp
	@echo '+Libs: -L@libdir@ -lnss@NSS_MAJOR_VERSION@ -lnssutil@NSS_MAJOR_VERSION@ -lsmime@NSS_MAJOR_VERSION@ -lssl@NSS_MAJOR_VERSION@ -lsoftokn@NSS_MAJOR_VERSION@' >>$@.tmp
	@echo '+Cflags: -I$${includedir}' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo 'diff --color -uNar nss-3.55.orig/nss/Makefile nss-3.55/nss/Makefile' >>$@.tmp
	@echo '--- nss-3.55.orig/nss/Makefile	2020-07-24 23:10:32.000000000 +0800' >>$@.tmp
	@echo '+++ nss-3.55/nss/Makefile	2020-07-25 19:32:37.239032214 +0800' >>$@.tmp
	@echo '@@ -4,6 +4,8 @@' >>$@.tmp
	@echo ' # License, v. 2.0. If a copy of the MPL was not distributed with this' >>$@.tmp
	@echo ' # file, You can obtain one at http://mozilla.org/MPL/2.0/.' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+default: nss_build_all' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo ' #######################################################################' >>$@.tmp
	@echo ' # (1) Include initial platform-independent assignments (MANDATORY).   #' >>$@.tmp
	@echo ' #######################################################################' >>$@.tmp
	@echo '@@ -48,12 +50,10 @@' >>$@.tmp
	@echo ' #######################################################################' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' nss_build_all:' >>$@.tmp
	@echo '-	$$(MAKE) build_nspr' >>$@.tmp
	@echo ' 	$$(MAKE) all' >>$@.tmp
	@echo ' 	$$(MAKE) latest' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' nss_clean_all:' >>$@.tmp
	@echo '-	$$(MAKE) clobber_nspr' >>$@.tmp
	@echo ' 	$$(MAKE) clobber' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' NSPR_CONFIG_STATUS = $$(CORE_DEPTH)/../nspr/$$(OBJDIR_NAME)/config.status' >>$@.tmp
	@echo 'diff --color -uNar nss-3.55.orig/nss/manifest.mn nss-3.55/nss/manifest.mn' >>$@.tmp
	@echo '--- nss-3.55.orig/nss/manifest.mn	2020-07-24 23:10:32.000000000 +0800' >>$@.tmp
	@echo '+++ nss-3.55/nss/manifest.mn	2020-07-25 19:32:37.240032237 +0800' >>$@.tmp
	@echo '@@ -10,7 +10,7 @@' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' RELEASE = nss' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-DIRS = coreconf lib cmd cpputil gtests' >>$@.tmp
	@echo '+DIRS = coreconf lib cmd cpputil gtests config' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' lib: coreconf' >>$@.tmp
	@echo ' cmd: lib' >>$@.tmp
	@mv $@.tmp $@

$($(nss)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nss)-builddeps),$(modulefilesdir)/$$(dep)) $($(nss)-prefix)/.pkgunpack $($(nss)-srcdir)/nss-3.69-standalone-1.patch
	cd $($(nss)-srcdir) && \
		patch -f -Np1 -i nss-3.69-standalone-1.patch
	@touch $@

ifneq ($($(nss)-builddir),$($(nss)-srcdir))
$($(nss)-builddir)/.markerfile: $($(nss)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(nss)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nss)-builddeps),$(modulefilesdir)/$$(dep)) $($(nss)-builddir)/.markerfile $($(nss)-prefix)/.pkgpatch
	cd $($(nss)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nss)-builddeps) && \
		$(MAKE) \
			PREFIX=$($(nss)-prefix) \
			BUILD_OPT=1 \
			NSPR_INCLUDE_DIR="$${NSPR_INCDIR}" \
			USE_SYSTEM_ZLIB=1 \
			ZLIB_LIBS=-lz \
			NSS_ENABLE_WERROR=0 \
			NSS_USE_SYSTEM_SQLITE=1 \
			$$([ $$(uname -m) = x86_64 ] && echo USE_64=1)
	@touch $@

$($(nss)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nss)-builddeps),$(modulefilesdir)/$$(dep)) $($(nss)-builddir)/.markerfile $($(nss)-prefix)/.pkgbuild
	@touch $@

$($(nss)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nss)-builddeps),$(modulefilesdir)/$$(dep)) $($(nss)-builddir)/.markerfile $($(nss)-prefix)/.pkgcheck
	cd $($(nss)-srcdir)/dist && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nss)-builddeps) && \
		$(INSTALL) -d $($(nss)-prefix)/bin && \
		$(INSTALL) -d $($(nss)-prefix)/include && \
		$(INSTALL) -d $($(nss)-prefix)/include/nss && \
		$(INSTALL) -d $($(nss)-prefix)/lib && \
		$(INSTALL) -d $($(nss)-prefix)/lib/pkgconfig && \
		$(INSTALL) -v -m755 Linux*/lib/*.so $($(nss)-prefix)/lib && \
		$(INSTALL) -v -m644 Linux*/lib/{*.chk,libcrmf.a} $($(nss)-prefix)/lib && \
		$(INSTALL) -v -m755 -d $($(nss)-prefix)/include/nss && \
		cp -v -RL {public,private}/nss/* $($(nss)-prefix)/include/nss && \
		chmod -v 644 $($(nss)-prefix)/include/nss/* && \
		$(INSTALL) -v -m755 Linux*/bin/{certutil,nss-config,pk12util} $($(nss)-prefix)/bin && \
		$(INSTALL) -v -m644 Linux*/lib/pkgconfig/nss.pc $($(nss)-prefix)/lib/pkgconfig
	@touch $@

$($(nss)-modulefile): $(modulefilesdir)/.markerfile $($(nss)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(nss)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(nss)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(nss)-description)\"" >>$@
	echo "module-whatis \"$($(nss)-url)\"" >>$@
	printf "$(foreach prereq,$($(nss)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NSS_ROOT $($(nss)-prefix)" >>$@
	echo "setenv NSS_INCDIR $($(nss)-prefix)/include" >>$@
	echo "setenv NSS_INCLUDEDIR $($(nss)-prefix)/include" >>$@
	echo "setenv NSS_LIBDIR $($(nss)-prefix)/lib" >>$@
	echo "setenv NSS_LIBRARYDIR $($(nss)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(nss)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(nss)-prefix)/include/nss" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(nss)-prefix)/include/nss" >>$@
	echo "prepend-path LIBRARY_PATH $($(nss)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(nss)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(nss)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(nss)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(nss)-prefix)/share/info" >>$@
	echo "set MSG \"$(nss)\"" >>$@

$(nss)-src: $$($(nss)-src)
$(nss)-unpack: $($(nss)-prefix)/.pkgunpack
$(nss)-patch: $($(nss)-prefix)/.pkgpatch
$(nss)-build: $($(nss)-prefix)/.pkgbuild
$(nss)-check: $($(nss)-prefix)/.pkgcheck
$(nss)-install: $($(nss)-prefix)/.pkginstall
$(nss)-modulefile: $($(nss)-modulefile)
$(nss)-clean:
	rm -rf $($(nss)-modulefile)
	rm -rf $($(nss)-prefix)
	rm -rf $($(nss)-builddir)
	rm -rf $($(nss)-srcdir)
	rm -rf $($(nss)-src)
$(nss): $(nss)-src $(nss)-unpack $(nss)-patch $(nss)-build $(nss)-check $(nss)-install $(nss)-modulefile
