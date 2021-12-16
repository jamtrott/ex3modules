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
# libxau-1.0.9

libxau-version = 1.0.9
libxau = libxau-$(libxau-version)
$(libxau)-description = X authorization file management libary
$(libxau)-url = https://x.org/
$(libxau)-srcurl = https://www.x.org/pub/individual/lib/libXau-$(libxau-version).tar.bz2
$(libxau)-src = $(pkgsrcdir)/$(libxau).tar.bz2
$(libxau)-srcdir = $(pkgsrcdir)/libXau-$(libxau-version)
$(libxau)-builddeps = $(xorgproto) $(xorg-util-macros)
$(libxau)-prereqs =
$(libxau)-modulefile = $(modulefilesdir)/$(libxau)
$(libxau)-prefix = $(pkgdir)/$(libxau)

$($(libxau)-src): $(dir $($(libxau)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxau)-srcurl)

$($(libxau)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxau)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxau)-prefix)/.pkgunpack: $($(libxau)-src) $($(libxau)-srcdir)/.markerfile $($(libxau)-prefix)/.markerfile $$(foreach dep,$$($(libxau)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxau)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxau)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxau)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxau)-prefix)/.pkgunpack
	@touch $@

$($(libxau)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxau)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxau)-prefix)/.pkgpatch
	cd $($(libxau)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxau)-builddeps) && \
		./configure --prefix=$($(libxau)-prefix) && \
		$(MAKE) MAKEFLAGS=
	@touch $@

$($(libxau)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxau)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxau)-prefix)/.pkgbuild
	cd $($(libxau)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxau)-builddeps) && \
		$(MAKE) MAKEFLAGS= check
	@touch $@

$($(libxau)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxau)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxau)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(libxau)-prefix) -C $($(libxau)-srcdir) install
	@touch $@

$($(libxau)-modulefile): $(modulefilesdir)/.markerfile $($(libxau)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxau)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxau)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxau)-description)\"" >>$@
	echo "module-whatis \"$($(libxau)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxau)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXAU_ROOT $($(libxau)-prefix)" >>$@
	echo "setenv LIBXAU_INCDIR $($(libxau)-prefix)/include" >>$@
	echo "setenv LIBXAU_INCLUDEDIR $($(libxau)-prefix)/include" >>$@
	echo "setenv LIBXAU_LIBDIR $($(libxau)-prefix)/lib" >>$@
	echo "setenv LIBXAU_LIBRARYDIR $($(libxau)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxau)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxau)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxau)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxau)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxau)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxau)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libxau)-prefix)/share/man" >>$@
	echo "set MSG \"$(libxau)\"" >>$@

$(libxau)-src: $($(libxau)-src)
$(libxau)-unpack: $($(libxau)-prefix)/.pkgunpack
$(libxau)-patch: $($(libxau)-prefix)/.pkgpatch
$(libxau)-build: $($(libxau)-prefix)/.pkgbuild
$(libxau)-check: $($(libxau)-prefix)/.pkgcheck
$(libxau)-install: $($(libxau)-prefix)/.pkginstall
$(libxau)-modulefile: $($(libxau)-modulefile)
$(libxau)-clean:
	rm -rf $($(libxau)-modulefile)
	rm -rf $($(libxau)-prefix)
	rm -rf $($(libxau)-srcdir)
	rm -rf $($(libxau)-src)
$(libxau): $(libxau)-src $(libxau)-unpack $(libxau)-patch $(libxau)-build $(libxau)-check $(libxau)-install $(libxau)-modulefile
