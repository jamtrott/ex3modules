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
# libx11-1.6.9

libx11-version = 1.6.9
libx11 = libx11-$(libx11-version)
$(libx11)-description = X Window System libraries
$(libx11)-url = https://x.org/
$(libx11)-srcurl = https://x.org/pub/individual/lib/libX11-$(libx11-version).tar.bz2
$(libx11)-src = $(pkgsrcdir)/$(notdir $($(libx11)-srcurl))
$(libx11)-srcdir = $(pkgsrcdir)/libX11-$(libx11-version)
$(libx11)-builddeps = $(fontconfig) $(libxcb) $(xtrans) $(util-linux) $(xorg-util-macros)
$(libx11)-prereqs = $(fontconfig) $(libxcb) $(util-linux)
$(libx11)-modulefile = $(modulefilesdir)/$(libx11)
$(libx11)-prefix = $(pkgdir)/$(libx11)

$($(libx11)-src): $(dir $($(libx11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libx11)-srcurl)

$($(libx11)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libx11)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libx11)-prefix)/.pkgunpack: $($(libx11)-src) $($(libx11)-srcdir)/.markerfile $($(libx11)-prefix)/.markerfile
	tar -C $($(libx11)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libx11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libx11)-builddeps),$(modulefilesdir)/$$(dep)) $($(libx11)-prefix)/.pkgunpack
	@touch $@

$($(libx11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libx11)-builddeps),$(modulefilesdir)/$$(dep)) $($(libx11)-prefix)/.pkgpatch
	cd $($(libx11)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libx11)-builddeps) && \
		./configure --prefix=$($(libx11)-prefix) && \
		$(MAKE)
	@touch $@

$($(libx11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libx11)-builddeps),$(modulefilesdir)/$$(dep)) $($(libx11)-prefix)/.pkgbuild
	cd $($(libx11)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libx11)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libx11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libx11)-builddeps),$(modulefilesdir)/$$(dep)) $($(libx11)-prefix)/.pkgcheck
	$(MAKE) -C $($(libx11)-srcdir) install
	@touch $@

$($(libx11)-modulefile): $(modulefilesdir)/.markerfile $($(libx11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libx11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libx11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libx11)-description)\"" >>$@
	echo "module-whatis \"$($(libx11)-url)\"" >>$@
	printf "$(foreach prereq,$($(libx11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBX11_ROOT $($(libx11)-prefix)" >>$@
	echo "setenv LIBX11_INCDIR $($(libx11)-prefix)/include" >>$@
	echo "setenv LIBX11_INCLUDEDIR $($(libx11)-prefix)/include" >>$@
	echo "setenv LIBX11_LIBDIR $($(libx11)-prefix)/lib" >>$@
	echo "setenv LIBX11_LIBRARYDIR $($(libx11)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libx11)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libx11)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libx11)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libx11)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libx11)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libx11)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libx11)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libx11)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libx11)-prefix)/share/info" >>$@
	echo "set MSG \"$(libx11)\"" >>$@

$(libx11)-src: $($(libx11)-src)
$(libx11)-unpack: $($(libx11)-prefix)/.pkgunpack
$(libx11)-patch: $($(libx11)-prefix)/.pkgpatch
$(libx11)-build: $($(libx11)-prefix)/.pkgbuild
$(libx11)-check: $($(libx11)-prefix)/.pkgcheck
$(libx11)-install: $($(libx11)-prefix)/.pkginstall
$(libx11)-modulefile: $($(libx11)-modulefile)
$(libx11)-clean:
	rm -rf $($(libx11)-modulefile)
	rm -rf $($(libx11)-prefix)
	rm -rf $($(libx11)-srcdir)
	rm -rf $($(libx11)-src)
$(libx11): $(libx11)-src $(libx11)-unpack $(libx11)-patch $(libx11)-build $(libx11)-check $(libx11)-install $(libx11)-modulefile
