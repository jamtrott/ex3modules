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
# libxaw-1.0.13

libxaw-version = 1.0.13
libxaw = libxaw-$(libxaw-version)
$(libxaw)-description = X Window System libraries
$(libxaw)-url = https://x.org/
$(libxaw)-srcurl = https://x.org/pub/individual/lib/libXaw-$(libxaw-version).tar.bz2
$(libxaw)-src = $(pkgsrcdir)/$(notdir $($(libxaw)-srcurl))
$(libxaw)-srcdir = $(pkgsrcdir)/libXaw-$(libxaw-version)
$(libxaw)-builddeps = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(libxt) $(libxmu) $(libxpm) $(util-linux) $(xorgproto) $(xorg-util-macros)
$(libxaw)-prereqs = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(libxt) $(libxmu) $(libxpm)
$(libxaw)-modulefile = $(modulefilesdir)/$(libxaw)
$(libxaw)-prefix = $(pkgdir)/$(libxaw)

$($(libxaw)-src): $(dir $($(libxaw)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxaw)-srcurl)

$($(libxaw)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxaw)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxaw)-prefix)/.pkgunpack: $($(libxaw)-src) $($(libxaw)-srcdir)/.markerfile $($(libxaw)-prefix)/.markerfile
	tar -C $($(libxaw)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxaw)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxaw)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxaw)-prefix)/.pkgunpack
	@touch $@

$($(libxaw)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxaw)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxaw)-prefix)/.pkgpatch
	cd $($(libxaw)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxaw)-builddeps) && \
		./configure --prefix=$($(libxaw)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxaw)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxaw)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxaw)-prefix)/.pkgbuild
	cd $($(libxaw)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxaw)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxaw)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxaw)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxaw)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxaw)-srcdir) install
	@touch $@

$($(libxaw)-modulefile): $(modulefilesdir)/.markerfile $($(libxaw)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxaw)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxaw)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxaw)-description)\"" >>$@
	echo "module-whatis \"$($(libxaw)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxaw)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXAW_ROOT $($(libxaw)-prefix)" >>$@
	echo "setenv LIBXAW_INCDIR $($(libxaw)-prefix)/include" >>$@
	echo "setenv LIBXAW_INCLUDEDIR $($(libxaw)-prefix)/include" >>$@
	echo "setenv LIBXAW_LIBDIR $($(libxaw)-prefix)/lib" >>$@
	echo "setenv LIBXAW_LIBRARYDIR $($(libxaw)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxaw)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxaw)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxaw)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxaw)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxaw)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxaw)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxaw)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxaw)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxaw)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxaw)\"" >>$@

$(libxaw)-src: $($(libxaw)-src)
$(libxaw)-unpack: $($(libxaw)-prefix)/.pkgunpack
$(libxaw)-patch: $($(libxaw)-prefix)/.pkgpatch
$(libxaw)-build: $($(libxaw)-prefix)/.pkgbuild
$(libxaw)-check: $($(libxaw)-prefix)/.pkgcheck
$(libxaw)-install: $($(libxaw)-prefix)/.pkginstall
$(libxaw)-modulefile: $($(libxaw)-modulefile)
$(libxaw)-clean:
	rm -rf $($(libxaw)-modulefile)
	rm -rf $($(libxaw)-prefix)
	rm -rf $($(libxaw)-srcdir)
	rm -rf $($(libxaw)-src)
$(libxaw): $(libxaw)-src $(libxaw)-unpack $(libxaw)-patch $(libxaw)-build $(libxaw)-check $(libxaw)-install $(libxaw)-modulefile
