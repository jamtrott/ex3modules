# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
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
# libffi-3.2.1

libffi-version = 3.2.1
libffi = libffi-$(libffi-version)
$(libffi)-description = A Portable Foreign Function Interface Library
$(libffi)-url = https://sourceware.org/libffi/
$(libffi)-srcurl = ftp://sourceware.org/pub/libffi/libffi-$(libffi-version).tar.gz
$(libffi)-builddeps =
$(libffi)-prereqs =
$(libffi)-src = $(pkgsrcdir)/$(notdir $($(libffi)-srcurl))
$(libffi)-srcdir = $(pkgsrcdir)/$(libffi)
$(libffi)-builddir = $($(libffi)-srcdir)
$(libffi)-modulefile = $(modulefilesdir)/$(libffi)
$(libffi)-prefix = $(pkgdir)/$(libffi)

$($(libffi)-src): $(dir $($(libffi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libffi)-srcurl)

$($(libffi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libffi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libffi)-prefix)/.pkgunpack: $$($(libffi)-src) $($(libffi)-srcdir)/.markerfile $($(libffi)-prefix)/.markerfile
	tar -C $($(libffi)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libffi)-srcdir)/0001-disable-multi-os-directory.patch: $($(libffi)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo '--- ./configure.ac	2014-11-12 05:56:51.000000000 -0600' >>$@.tmp
	@echo '+++ ./configure.ac	2015-10-29 15:53:41.695055040 -0500' >>$@.tmp
	@echo '@@ -590,6 +590,10 @@' >>$@.tmp
	@echo '     AC_DEFINE(USING_PURIFY, 1, [Define this if you are using Purify and want to suppress spurious messages.])' >>$@.tmp
	@echo '   fi)' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+AC_ARG_ENABLE(multi-os-directory,' >>$@.tmp
	@echo '+[  --disable-multi-os-directory' >>$@.tmp
	@echo '+                          disable use of gcc --print-multi-os-directory to change the library installation directory])' >>$@.tmp
	@echo '+                          ' >>$@.tmp
	@echo ' # These variables are only ever used when we cross-build to X86_WIN32.' >>$@.tmp
	@echo ' # And we only support this with GCC, so...' >>$@.tmp
	@echo ' if test "x$$GCC" = "xyes"; then' >>$@.tmp
	@echo '@@ -601,11 +605,13 @@' >>$@.tmp
	@echo '     toolexecdir="$${libdir}"/gcc-lib/$$(target_alias)' >>$@.tmp
	@echo '     toolexeclibdir="$${libdir}"' >>$@.tmp
	@echo '   fi' >>$@.tmp
	@echo '-  multi_os_directory=`$$CC $$CFLAGS -print-multi-os-directory`' >>$@.tmp
	@echo '-  case $$multi_os_directory in' >>$@.tmp
	@echo '-    .) ;; # Avoid trailing /.' >>$@.tmp
	@echo '-    ../*) toolexeclibdir=$$toolexeclibdir/$$multi_os_directory ;;' >>$@.tmp
	@echo '-  esac' >>$@.tmp
	@echo '+  if test x"$$enable_multi_os_directory" != x"no"; then' >>$@.tmp
	@echo '+    multi_os_directory=`$$CC $$CFLAGS -print-multi-os-directory`' >>$@.tmp
	@echo '+    case $$multi_os_directory in' >>$@.tmp
	@echo '+      .) ;; # Avoid trailing /.' >>$@.tmp
	@echo '+      ../*) toolexeclibdir=$$toolexeclibdir/$$multi_os_directory ;;' >>$@.tmp
	@echo '+    esac' >>$@.tmp
	@echo '+  fi' >>$@.tmp
	@echo '   AC_SUBST(toolexecdir)' >>$@.tmp
	@echo ' else' >>$@.tmp
	@echo '   toolexeclibdir="$${libdir}"' >>$@.tmp
	@echo '--- ./configure	2014-11-12 11:59:57.000000000 +0000' >>$@.tmp
	@echo '+++ ./configure	2015-10-30 19:50:51.082221000 +0000' >>$@.tmp
	@echo '@@ -886,6 +886,7 @@' >>$@.tmp
	@echo ' enable_structs' >>$@.tmp
	@echo ' enable_raw_api' >>$@.tmp
	@echo ' enable_purify_safety' >>$@.tmp
	@echo '+enable_multi_os_directory' >>$@.tmp
	@echo " '" >>$@.tmp
	@echo "       ac_precious_vars='build_alias" >>$@.tmp
	@echo ' host_alias' >>$@.tmp
	@echo '@@ -1538,6 +1539,8 @@' >>$@.tmp
	@echo '   --disable-structs       omit code for struct support' >>$@.tmp
	@echo '   --disable-raw-api       make the raw api unavailable' >>$@.tmp
	@echo '   --enable-purify-safety  purify-safe mode' >>$@.tmp
	@echo '+  --disable-multi-os-directory' >>$@.tmp
	@echo '+                          disable use of gcc --print-multi-os-directory to change the library installation directory' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' Optional Packages:' >>$@.tmp
	@echo '   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]' >>$@.tmp
	@echo '@@ -18714,6 +18717,12 @@' >>$@.tmp
	@echo ' fi' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+# Check whether --enable-multi-os-directory was given.' >>$@.tmp
	@echo '+if test "$${enable_multi_os_directory+set}" = set; then :' >>$@.tmp
	@echo '+  enableval=$$enable_multi_os_directory;' >>$@.tmp
	@echo '+fi' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo ' # These variables are only ever used when we cross-build to X86_WIN32.' >>$@.tmp
	@echo ' # And we only support this with GCC, so...' >>$@.tmp
	@echo ' if test "x$$GCC" = "xyes"; then' >>$@.tmp
	@echo '@@ -18725,11 +18734,13 @@' >>$@.tmp
	@echo "     toolexecdir="$${libdir}"/gcc-lib/'$$(target_alias)'" >>$@.tmp
	@echo '     toolexeclibdir="$${libdir}"' >>$@.tmp
	@echo '   fi' >>$@.tmp
	@echo '-  multi_os_directory=`$$CC $$CFLAGS -print-multi-os-directory`' >>$@.tmp
	@echo '-  case $$multi_os_directory in' >>$@.tmp
	@echo '-    .) ;; # Avoid trailing /.' >>$@.tmp
	@echo '-    ../*) toolexeclibdir=$$toolexeclibdir/$$multi_os_directory ;;' >>$@.tmp
	@echo '-  esac' >>$@.tmp
	@echo '+  if test x"$$enable_multi_os_directory" != x"no"; then' >>$@.tmp
	@echo '+    multi_os_directory=`$$CC $$CFLAGS -print-multi-os-directory`' >>$@.tmp
	@echo '+    case $$multi_os_directory in' >>$@.tmp
	@echo '+      .) ;; # Avoid trailing /.' >>$@.tmp
	@echo '+      ../*) toolexeclibdir=$$toolexeclibdir/$$multi_os_directory ;;' >>$@.tmp
	@echo '+    esac' >>$@.tmp
	@echo '+  fi' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' else' >>$@.tmp
	@echo '   toolexeclibdir="$${libdir}"' >>$@.tmp
	@mv $@.tmp $@

$($(libffi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libffi)-prefix)/.pkgunpack $($(libffi)-srcdir)/0001-disable-multi-os-directory.patch
# Modify the Makefile to install headers in include/ instead of
# lib/libffi-<version>/include.
	cd $($(libffi)-srcdir) && \
		sed -e '/^includesdir/ s/$$(libdir).*$$/$$(includedir)/' -i include/Makefile.in && \
		sed -e '/^includedir/ s/=.*$$/=@includedir@/' -i libffi.pc.in
	cd $($(libffi)-srcdir) && \
		patch -t -p1 <0001-disable-multi-os-directory.patch
	@touch $@

ifneq ($($(libffi)-builddir),$($(libffi)-srcdir))
$($(libffi)-builddir)/.markerfile: $($(libffi)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libffi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libffi)-builddir)/.markerfile $($(libffi)-prefix)/.pkgpatch
	cd $($(libffi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libffi)-builddeps) && \
		./configure --prefix=$($(libffi)-prefix) \
			--disable-multi-os-directory && \
		$(MAKE)
	@touch $@

$($(libffi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libffi)-builddir)/.markerfile $($(libffi)-prefix)/.pkgbuild
	cd $($(libffi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libffi)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libffi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libffi)-builddir)/.markerfile $($(libffi)-prefix)/.pkgcheck
	cd $($(libffi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libffi)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libffi)-modulefile): $(modulefilesdir)/.markerfile $($(libffi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libffi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libffi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libffi)-description)\"" >>$@
	echo "module-whatis \"$($(libffi)-url)\"" >>$@
	printf "$(foreach prereq,$($(libffi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBFFI_ROOT $($(libffi)-prefix)" >>$@
	echo "setenv LIBFFI_INCDIR $($(libffi)-prefix)/include" >>$@
	echo "setenv LIBFFI_INCLUDEDIR $($(libffi)-prefix)/include" >>$@
	echo "setenv LIBFFI_LIBDIR $($(libffi)-prefix)/lib" >>$@
	echo "setenv LIBFFI_LIBRARYDIR $($(libffi)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libffi)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libffi)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libffi)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libffi)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libffi)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libffi)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libffi)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libffi)-prefix)/share/info" >>$@
	echo "set MSG \"$(libffi)\"" >>$@

$(libffi)-src: $$($(libffi)-src)
$(libffi)-unpack: $($(libffi)-prefix)/.pkgunpack
$(libffi)-patch: $($(libffi)-prefix)/.pkgpatch
$(libffi)-build: $($(libffi)-prefix)/.pkgbuild
$(libffi)-check: $($(libffi)-prefix)/.pkgcheck
$(libffi)-install: $($(libffi)-prefix)/.pkginstall
$(libffi)-modulefile: $($(libffi)-modulefile)
$(libffi)-clean:
	rm -rf $($(libffi)-modulefile)
	rm -rf $($(libffi)-prefix)
	rm -rf $($(libffi)-srcdir)
	rm -rf $($(libffi)-src)
$(libffi): $(libffi)-src $(libffi)-unpack $(libffi)-patch $(libffi)-build $(libffi)-check $(libffi)-install $(libffi)-modulefile
