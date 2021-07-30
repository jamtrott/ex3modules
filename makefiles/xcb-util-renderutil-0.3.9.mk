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
# xcb-util-renderutil-0.3.9

xcb-util-renderutil-version = 0.3.9
xcb-util-renderutil = xcb-util-renderutil-$(xcb-util-renderutil-version)
$(xcb-util-renderutil)-description = X protocol C-language Binding (XCB) Utilities, Convenience functions for the Render extension
$(xcb-util-renderutil)-url = https://xcb.freedesktop.org/
$(xcb-util-renderutil)-srcurl = https://xcb.freedesktop.org/dist/xcb-util-renderutil-$(xcb-util-renderutil-version).tar.gz
$(xcb-util-renderutil)-builddeps = $(libxcb) $(xcb-util)
$(xcb-util-renderutil)-prereqs = $(libxcb) $(xcb-util)
$(xcb-util-renderutil)-src = $(pkgsrcdir)/$(notdir $($(xcb-util-renderutil)-srcurl))
$(xcb-util-renderutil)-srcdir = $(pkgsrcdir)/$(xcb-util-renderutil)
$(xcb-util-renderutil)-builddir = $($(xcb-util-renderutil)-srcdir)
$(xcb-util-renderutil)-modulefile = $(modulefilesdir)/$(xcb-util-renderutil)
$(xcb-util-renderutil)-prefix = $(pkgdir)/$(xcb-util-renderutil)

$($(xcb-util-renderutil)-src): $(dir $($(xcb-util-renderutil)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xcb-util-renderutil)-srcurl)

$($(xcb-util-renderutil)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-renderutil)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-renderutil)-prefix)/.pkgunpack: $$($(xcb-util-renderutil)-src) $($(xcb-util-renderutil)-srcdir)/.markerfile $($(xcb-util-renderutil)-prefix)/.markerfile
	tar -C $($(xcb-util-renderutil)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xcb-util-renderutil)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-renderutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-renderutil)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xcb-util-renderutil)-builddir),$($(xcb-util-renderutil)-srcdir))
$($(xcb-util-renderutil)-builddir)/.markerfile: $($(xcb-util-renderutil)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xcb-util-renderutil)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-renderutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-renderutil)-builddir)/.markerfile $($(xcb-util-renderutil)-prefix)/.pkgpatch
	cd $($(xcb-util-renderutil)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-renderutil)-builddeps) && \
		./configure --prefix=$($(xcb-util-renderutil)-prefix) && \
		$(MAKE)
	@touch $@

$($(xcb-util-renderutil)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-renderutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-renderutil)-builddir)/.markerfile $($(xcb-util-renderutil)-prefix)/.pkgbuild
	cd $($(xcb-util-renderutil)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-renderutil)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xcb-util-renderutil)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-renderutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-renderutil)-builddir)/.markerfile $($(xcb-util-renderutil)-prefix)/.pkgcheck
	cd $($(xcb-util-renderutil)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-renderutil)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xcb-util-renderutil)-modulefile): $(modulefilesdir)/.markerfile $($(xcb-util-renderutil)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xcb-util-renderutil)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xcb-util-renderutil)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xcb-util-renderutil)-description)\"" >>$@
	echo "module-whatis \"$($(xcb-util-renderutil)-url)\"" >>$@
	printf "$(foreach prereq,$($(xcb-util-renderutil)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XCB_UTIL_RENDERUTIL_ROOT $($(xcb-util-renderutil)-prefix)" >>$@
	echo "setenv XCB_UTIL_RENDERUTIL_INCDIR $($(xcb-util-renderutil)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_RENDERUTIL_INCLUDEDIR $($(xcb-util-renderutil)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_RENDERUTIL_LIBDIR $($(xcb-util-renderutil)-prefix)/lib" >>$@
	echo "setenv XCB_UTIL_RENDERUTIL_LIBRARYDIR $($(xcb-util-renderutil)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xcb-util-renderutil)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xcb-util-renderutil)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xcb-util-renderutil)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xcb-util-renderutil)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xcb-util-renderutil)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(xcb-util-renderutil)\"" >>$@

$(xcb-util-renderutil)-src: $$($(xcb-util-renderutil)-src)
$(xcb-util-renderutil)-unpack: $($(xcb-util-renderutil)-prefix)/.pkgunpack
$(xcb-util-renderutil)-patch: $($(xcb-util-renderutil)-prefix)/.pkgpatch
$(xcb-util-renderutil)-build: $($(xcb-util-renderutil)-prefix)/.pkgbuild
$(xcb-util-renderutil)-check: $($(xcb-util-renderutil)-prefix)/.pkgcheck
$(xcb-util-renderutil)-install: $($(xcb-util-renderutil)-prefix)/.pkginstall
$(xcb-util-renderutil)-modulefile: $($(xcb-util-renderutil)-modulefile)
$(xcb-util-renderutil)-clean:
	rm -rf $($(xcb-util-renderutil)-modulefile)
	rm -rf $($(xcb-util-renderutil)-prefix)
	rm -rf $($(xcb-util-renderutil)-builddir)
	rm -rf $($(xcb-util-renderutil)-srcdir)
	rm -rf $($(xcb-util-renderutil)-src)
$(xcb-util-renderutil): $(xcb-util-renderutil)-src $(xcb-util-renderutil)-unpack $(xcb-util-renderutil)-patch $(xcb-util-renderutil)-build $(xcb-util-renderutil)-check $(xcb-util-renderutil)-install $(xcb-util-renderutil)-modulefile
