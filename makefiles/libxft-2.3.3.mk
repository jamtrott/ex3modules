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
# libxft-2.3.3

libxft-version = 2.3.3
libxft = libxft-$(libxft-version)
$(libxft)-description = X Window System libraries
$(libxft)-url = https://x.org/
$(libxft)-srcurl = https://x.org/pub/individual/lib/libXft-$(libxft-version).tar.bz2
$(libxft)-src = $(pkgsrcdir)/$(notdir $($(libxft)-srcurl))
$(libxft)-srcdir = $(pkgsrcdir)/libXft-$(libxft-version)
$(libxft)-builddeps = $(fontconfig) $(libxcb) $(libxrender) $(util-linux) $(xorg-util-macros)
$(libxft)-prereqs = $(fontconfig) $(libxcb) $(libxrender)
$(libxft)-modulefile = $(modulefilesdir)/$(libxft)
$(libxft)-prefix = $(pkgdir)/$(libxft)

$($(libxft)-src): $(dir $($(libxft)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxft)-srcurl)

$($(libxft)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxft)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxft)-prefix)/.pkgunpack: $($(libxft)-src) $($(libxft)-srcdir)/.markerfile $($(libxft)-prefix)/.markerfile $$(foreach dep,$$($(libxft)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxft)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxft)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxft)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxft)-prefix)/.pkgunpack
	@touch $@

$($(libxft)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxft)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxft)-prefix)/.pkgpatch
	cd $($(libxft)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxft)-builddeps) && \
		./configure --prefix=$($(libxft)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxft)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxft)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxft)-prefix)/.pkgbuild
	cd $($(libxft)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxft)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxft)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxft)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxft)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxft)-srcdir) install
	@touch $@

$($(libxft)-modulefile): $(modulefilesdir)/.markerfile $($(libxft)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxft)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxft)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxft)-description)\"" >>$@
	echo "module-whatis \"$($(libxft)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxft)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXFT_ROOT $($(libxft)-prefix)" >>$@
	echo "setenv LIBXFT_INCDIR $($(libxft)-prefix)/include" >>$@
	echo "setenv LIBXFT_INCLUDEDIR $($(libxft)-prefix)/include" >>$@
	echo "setenv LIBXFT_LIBDIR $($(libxft)-prefix)/lib" >>$@
	echo "setenv LIBXFT_LIBRARYDIR $($(libxft)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxft)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxft)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxft)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxft)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxft)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxft)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxft)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxft)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxft)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxft)\"" >>$@

$(libxft)-src: $($(libxft)-src)
$(libxft)-unpack: $($(libxft)-prefix)/.pkgunpack
$(libxft)-patch: $($(libxft)-prefix)/.pkgpatch
$(libxft)-build: $($(libxft)-prefix)/.pkgbuild
$(libxft)-check: $($(libxft)-prefix)/.pkgcheck
$(libxft)-install: $($(libxft)-prefix)/.pkginstall
$(libxft)-modulefile: $($(libxft)-modulefile)
$(libxft)-clean:
	rm -rf $($(libxft)-modulefile)
	rm -rf $($(libxft)-prefix)
	rm -rf $($(libxft)-srcdir)
	rm -rf $($(libxft)-src)
$(libxft): $(libxft)-src $(libxft)-unpack $(libxft)-patch $(libxft)-build $(libxft)-check $(libxft)-install $(libxft)-modulefile
