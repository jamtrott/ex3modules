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
# xcb-util-0.4.0

xcb-util-version = 0.4.0
xcb-util = xcb-util-$(xcb-util-version)
$(xcb-util)-description = X protocol C-language Binding (XCB) Utilities
$(xcb-util)-url = https://xcb.freedesktop.org/
$(xcb-util)-srcurl = https://xcb.freedesktop.org/dist/xcb-util-$(xcb-util-version).tar.gz
$(xcb-util)-builddeps = $(libxcb)
$(xcb-util)-prereqs = $(libxcb)
$(xcb-util)-src = $(pkgsrcdir)/$(notdir $($(xcb-util)-srcurl))
$(xcb-util)-srcdir = $(pkgsrcdir)/$(xcb-util)
$(xcb-util)-builddir = $($(xcb-util)-srcdir)
$(xcb-util)-modulefile = $(modulefilesdir)/$(xcb-util)
$(xcb-util)-prefix = $(pkgdir)/$(xcb-util)

$($(xcb-util)-src): $(dir $($(xcb-util)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xcb-util)-srcurl)

$($(xcb-util)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util)-prefix)/.pkgunpack: $$($(xcb-util)-src) $($(xcb-util)-srcdir)/.markerfile $($(xcb-util)-prefix)/.markerfile $$(foreach dep,$$($(xcb-util)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(xcb-util)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xcb-util)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xcb-util)-builddir),$($(xcb-util)-srcdir))
$($(xcb-util)-builddir)/.markerfile: $($(xcb-util)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xcb-util)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util)-builddir)/.markerfile $($(xcb-util)-prefix)/.pkgpatch
	cd $($(xcb-util)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util)-builddeps) && \
		./configure --prefix=$($(xcb-util)-prefix) && \
		$(MAKE)
	@touch $@

$($(xcb-util)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util)-builddir)/.markerfile $($(xcb-util)-prefix)/.pkgbuild
	cd $($(xcb-util)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xcb-util)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util)-builddir)/.markerfile $($(xcb-util)-prefix)/.pkgcheck
	cd $($(xcb-util)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xcb-util)-modulefile): $(modulefilesdir)/.markerfile $($(xcb-util)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xcb-util)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xcb-util)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xcb-util)-description)\"" >>$@
	echo "module-whatis \"$($(xcb-util)-url)\"" >>$@
	printf "$(foreach prereq,$($(xcb-util)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XCB_UTIL_ROOT $($(xcb-util)-prefix)" >>$@
	echo "setenv XCB_UTIL_INCDIR $($(xcb-util)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_INCLUDEDIR $($(xcb-util)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_LIBDIR $($(xcb-util)-prefix)/lib" >>$@
	echo "setenv XCB_UTIL_LIBRARYDIR $($(xcb-util)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xcb-util)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xcb-util)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xcb-util)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xcb-util)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xcb-util)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(xcb-util)\"" >>$@

$(xcb-util)-src: $$($(xcb-util)-src)
$(xcb-util)-unpack: $($(xcb-util)-prefix)/.pkgunpack
$(xcb-util)-patch: $($(xcb-util)-prefix)/.pkgpatch
$(xcb-util)-build: $($(xcb-util)-prefix)/.pkgbuild
$(xcb-util)-check: $($(xcb-util)-prefix)/.pkgcheck
$(xcb-util)-install: $($(xcb-util)-prefix)/.pkginstall
$(xcb-util)-modulefile: $($(xcb-util)-modulefile)
$(xcb-util)-clean:
	rm -rf $($(xcb-util)-modulefile)
	rm -rf $($(xcb-util)-prefix)
	rm -rf $($(xcb-util)-builddir)
	rm -rf $($(xcb-util)-srcdir)
	rm -rf $($(xcb-util)-src)
$(xcb-util): $(xcb-util)-src $(xcb-util)-unpack $(xcb-util)-patch $(xcb-util)-build $(xcb-util)-check $(xcb-util)-install $(xcb-util)-modulefile
