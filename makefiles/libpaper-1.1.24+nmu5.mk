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
# libpaper-1.1.24+nmu5

libpaper-version = 1.1.24+nmu5
libpaper = libpaper-$(libpaper-version)
$(libpaper)-description = Library for handling paper characteristics
$(libpaper)-url = https://github.com/naota/libpaper
$(libpaper)-srcurl = http://ftp.debian.org/debian/pool/main/libp/libpaper/libpaper_1.1.24+nmu5.tar.gz
$(libpaper)-builddeps = 
$(libpaper)-prereqs =
$(libpaper)-src = $(pkgsrcdir)/$(notdir $($(libpaper)-srcurl))
$(libpaper)-srcdir = $(pkgsrcdir)/$(libpaper)
$(libpaper)-builddir = $($(libpaper)-srcdir)
$(libpaper)-modulefile = $(modulefilesdir)/$(libpaper)
$(libpaper)-prefix = $(pkgdir)/$(libpaper)

$($(libpaper)-src): $(dir $($(libpaper)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libpaper)-srcurl)

$($(libpaper)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpaper)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpaper)-prefix)/.pkgunpack: $$($(libpaper)-src) $($(libpaper)-srcdir)/.markerfile $($(libpaper)-prefix)/.markerfile $$(foreach dep,$$($(libpaper)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libpaper)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libpaper)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpaper)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpaper)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libpaper)-builddir),$($(libpaper)-srcdir))
$($(libpaper)-builddir)/.markerfile: $($(libpaper)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libpaper)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpaper)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpaper)-builddir)/.markerfile $($(libpaper)-prefix)/.pkgpatch
	cd $($(libpaper)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpaper)-builddeps) && \
		autoreconf -fi && \
		./configure --prefix=$($(libpaper)-prefix) \
			--disable-static && \
		$(MAKE)
	@touch $@

$($(libpaper)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpaper)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpaper)-builddir)/.markerfile $($(libpaper)-prefix)/.pkgbuild
	cd $($(libpaper)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpaper)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libpaper)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpaper)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpaper)-builddir)/.markerfile $($(libpaper)-prefix)/.pkgcheck
	cd $($(libpaper)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpaper)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libpaper)-modulefile): $(modulefilesdir)/.markerfile $($(libpaper)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libpaper)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libpaper)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libpaper)-description)\"" >>$@
	echo "module-whatis \"$($(libpaper)-url)\"" >>$@
	printf "$(foreach prereq,$($(libpaper)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBPAPER_ROOT $($(libpaper)-prefix)" >>$@
	echo "setenv LIBPAPER_INCDIR $($(libpaper)-prefix)/include" >>$@
	echo "setenv LIBPAPER_INCLUDEDIR $($(libpaper)-prefix)/include" >>$@
	echo "setenv LIBPAPER_LIBDIR $($(libpaper)-prefix)/lib" >>$@
	echo "setenv LIBPAPER_LIBRARYDIR $($(libpaper)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libpaper)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libpaper)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libpaper)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libpaper)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libpaper)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(libpaper)-prefix)/share/man" >>$@
	echo "set MSG \"$(libpaper)\"" >>$@

$(libpaper)-src: $$($(libpaper)-src)
$(libpaper)-unpack: $($(libpaper)-prefix)/.pkgunpack
$(libpaper)-patch: $($(libpaper)-prefix)/.pkgpatch
$(libpaper)-build: $($(libpaper)-prefix)/.pkgbuild
$(libpaper)-check: $($(libpaper)-prefix)/.pkgcheck
$(libpaper)-install: $($(libpaper)-prefix)/.pkginstall
$(libpaper)-modulefile: $($(libpaper)-modulefile)
$(libpaper)-clean:
	rm -rf $($(libpaper)-modulefile)
	rm -rf $($(libpaper)-prefix)
	rm -rf $($(libpaper)-builddir)
	rm -rf $($(libpaper)-srcdir)
	rm -rf $($(libpaper)-src)
$(libpaper): $(libpaper)-src $(libpaper)-unpack $(libpaper)-patch $(libpaper)-build $(libpaper)-check $(libpaper)-install $(libpaper)-modulefile
