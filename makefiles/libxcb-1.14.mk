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
# libxcb-1.14

libxcb-version = 1.14
libxcb = libxcb-$(libxcb-version)
$(libxcb)-description = X Window System protocol library
$(libxcb)-url = https://x.org/
$(libxcb)-srcurl = https://xorg.freedesktop.org/archive/individual/lib/libxcb-$(libxcb-version).tar.xz
$(libxcb)-src = $(pkgsrcdir)/$(notdir $($(libxcb)-srcurl))
$(libxcb)-srcdir = $(pkgsrcdir)/$(libxcb)
$(libxcb)-builddeps = $(libxau) $(libxdmcp) $(xcb-proto) $(xorgproto) $(xorg-util-macros) $(doxygen)
$(libxcb)-prereqs = $(libxau) $(libxdmcp)
$(libxcb)-modulefile = $(modulefilesdir)/$(libxcb)
$(libxcb)-prefix = $(pkgdir)/$(libxcb)

$($(libxcb)-src): $(dir $($(libxcb)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxcb)-srcurl)

$($(libxcb)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxcb)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxcb)-prefix)/.pkgunpack: $($(libxcb)-src) $($(libxcb)-srcdir)/.markerfile $($(libxcb)-prefix)/.markerfile
	tar -C $($(libxcb)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libxcb)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcb)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcb)-prefix)/.pkgunpack
	cd $($(libxcb)-srcdir) && sed -i "s/pthread-stubs//" configure
	@touch $@

$($(libxcb)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcb)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcb)-prefix)/.pkgpatch
	cd $($(libxcb)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxcb)-builddeps) && \
		./configure --prefix=$($(libxcb)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxcb)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcb)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcb)-prefix)/.pkgbuild
	cd $($(libxcb)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxcb)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxcb)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcb)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcb)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxcb)-srcdir) install
	@touch $@

$($(libxcb)-modulefile): $(modulefilesdir)/.markerfile $($(libxcb)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxcb)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxcb)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxcb)-description)\"" >>$@
	echo "module-whatis \"$($(libxcb)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxcb)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXCB_ROOT $($(libxcb)-prefix)" >>$@
	echo "setenv LIBXCB_INCDIR $($(libxcb)-prefix)/include" >>$@
	echo "setenv LIBXCB_INCLUDEDIR $($(libxcb)-prefix)/include" >>$@
	echo "setenv LIBXCB_LIBDIR $($(libxcb)-prefix)/lib" >>$@
	echo "setenv LIBXCB_LIBRARYDIR $($(libxcb)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxcb)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxcb)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxcb)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxcb)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxcb)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxcb)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libxcb)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxcb)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxcb)\"" >>$@

$(libxcb)-src: $($(libxcb)-src)
$(libxcb)-unpack: $($(libxcb)-prefix)/.pkgunpack
$(libxcb)-patch: $($(libxcb)-prefix)/.pkgpatch
$(libxcb)-build: $($(libxcb)-prefix)/.pkgbuild
$(libxcb)-check: $($(libxcb)-prefix)/.pkgcheck
$(libxcb)-install: $($(libxcb)-prefix)/.pkginstall
$(libxcb)-modulefile: $($(libxcb)-modulefile)
$(libxcb)-clean:
	rm -rf $($(libxcb)-modulefile)
	rm -rf $($(libxcb)-prefix)
	rm -rf $($(libxcb)-srcdir)
	rm -rf $($(libxcb)-src)
$(libxcb): $(libxcb)-src $(libxcb)-unpack $(libxcb)-patch $(libxcb)-build $(libxcb)-check $(libxcb)-install $(libxcb)-modulefile
