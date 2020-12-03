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
# libxfont2-2.0.4

libxfont2-version = 2.0.4
libxfont2 = libxfont2-$(libxfont2-version)
$(libxfont2)-description = X Window System libraries
$(libxfont2)-url = https://x.org/
$(libxfont2)-srcurl = https://x.org/pub/individual/lib/libXfont2-$(libxfont2-version).tar.bz2
$(libxfont2)-src = $(pkgsrcdir)/$(notdir $($(libxfont2)-srcurl))
$(libxfont2)-srcdir = $(pkgsrcdir)/libXfont2-$(libxfont2-version)
$(libxfont2)-builddeps = $(fontconfig) $(libxcb) $(xtrans) $(libfontenc) $(util-linux) $(xorgproto) $(xorg-util-macros)
$(libxfont2)-prereqs = $(fontconfig) $(libxcb) $(libfontenc)
$(libxfont2)-modulefile = $(modulefilesdir)/$(libxfont2)
$(libxfont2)-prefix = $(pkgdir)/$(libxfont2)

$($(libxfont2)-src): $(dir $($(libxfont2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxfont2)-srcurl)

$($(libxfont2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxfont2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxfont2)-prefix)/.pkgunpack: $($(libxfont2)-src) $($(libxfont2)-srcdir)/.markerfile $($(libxfont2)-prefix)/.markerfile
	tar -C $($(libxfont2)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxfont2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfont2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfont2)-prefix)/.pkgunpack
	@touch $@

$($(libxfont2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfont2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfont2)-prefix)/.pkgpatch
	cd $($(libxfont2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxfont2)-builddeps) && \
		./configure --prefix=$($(libxfont2)-prefix) --disable-devel-docs --disable-static && \
		$(MAKE)
	@touch $@

$($(libxfont2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfont2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfont2)-prefix)/.pkgbuild
	cd $($(libxfont2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxfont2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxfont2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfont2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfont2)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxfont2)-srcdir) install
	@touch $@

$($(libxfont2)-modulefile): $(modulefilesdir)/.markerfile $($(libxfont2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxfont2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxfont2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxfont2)-description)\"" >>$@
	echo "module-whatis \"$($(libxfont2)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxfont2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXFONT2_ROOT $($(libxfont2)-prefix)" >>$@
	echo "setenv LIBXFONT2_INCDIR $($(libxfont2)-prefix)/include" >>$@
	echo "setenv LIBXFONT2_INCLUDEDIR $($(libxfont2)-prefix)/include" >>$@
	echo "setenv LIBXFONT2_LIBDIR $($(libxfont2)-prefix)/lib" >>$@
	echo "setenv LIBXFONT2_LIBRARYDIR $($(libxfont2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxfont2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxfont2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxfont2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxfont2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxfont2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxfont2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxfont2)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxfont2)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxfont2)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxfont2)\"" >>$@

$(libxfont2)-src: $($(libxfont2)-src)
$(libxfont2)-unpack: $($(libxfont2)-prefix)/.pkgunpack
$(libxfont2)-patch: $($(libxfont2)-prefix)/.pkgpatch
$(libxfont2)-build: $($(libxfont2)-prefix)/.pkgbuild
$(libxfont2)-check: $($(libxfont2)-prefix)/.pkgcheck
$(libxfont2)-install: $($(libxfont2)-prefix)/.pkginstall
$(libxfont2)-modulefile: $($(libxfont2)-modulefile)
$(libxfont2)-clean:
	rm -rf $($(libxfont2)-modulefile)
	rm -rf $($(libxfont2)-prefix)
	rm -rf $($(libxfont2)-srcdir)
	rm -rf $($(libxfont2)-src)
$(libxfont2): $(libxfont2)-src $(libxfont2)-unpack $(libxfont2)-patch $(libxfont2)-build $(libxfont2)-check $(libxfont2)-install $(libxfont2)-modulefile
