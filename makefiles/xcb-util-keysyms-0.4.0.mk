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
# xcb-util-keysyms-0.4.0

xcb-util-keysyms-version = 0.4.0
xcb-util-keysyms = xcb-util-keysyms-$(xcb-util-keysyms-version)
$(xcb-util-keysyms)-description = X protocol C-language Binding (XCB) Utilities, Standard X key constants and conversion to/from keycodes
$(xcb-util-keysyms)-url = https://xcb.freedesktop.org/
$(xcb-util-keysyms)-srcurl = https://xcb.freedesktop.org/dist/xcb-util-keysyms-$(xcb-util-keysyms-version).tar.gz
$(xcb-util-keysyms)-builddeps = $(libxcb) $(xcb-util)
$(xcb-util-keysyms)-prereqs = $(libxcb) $(xcb-util)
$(xcb-util-keysyms)-src = $(pkgsrcdir)/$(notdir $($(xcb-util-keysyms)-srcurl))
$(xcb-util-keysyms)-srcdir = $(pkgsrcdir)/$(xcb-util-keysyms)
$(xcb-util-keysyms)-builddir = $($(xcb-util-keysyms)-srcdir)
$(xcb-util-keysyms)-modulefile = $(modulefilesdir)/$(xcb-util-keysyms)
$(xcb-util-keysyms)-prefix = $(pkgdir)/$(xcb-util-keysyms)

$($(xcb-util-keysyms)-src): $(dir $($(xcb-util-keysyms)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xcb-util-keysyms)-srcurl)

$($(xcb-util-keysyms)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-keysyms)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-keysyms)-prefix)/.pkgunpack: $$($(xcb-util-keysyms)-src) $($(xcb-util-keysyms)-srcdir)/.markerfile $($(xcb-util-keysyms)-prefix)/.markerfile
	tar -C $($(xcb-util-keysyms)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xcb-util-keysyms)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-keysyms)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-keysyms)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xcb-util-keysyms)-builddir),$($(xcb-util-keysyms)-srcdir))
$($(xcb-util-keysyms)-builddir)/.markerfile: $($(xcb-util-keysyms)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xcb-util-keysyms)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-keysyms)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-keysyms)-builddir)/.markerfile $($(xcb-util-keysyms)-prefix)/.pkgpatch
	cd $($(xcb-util-keysyms)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-keysyms)-builddeps) && \
		./configure --prefix=$($(xcb-util-keysyms)-prefix) && \
		$(MAKE)
	@touch $@

$($(xcb-util-keysyms)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-keysyms)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-keysyms)-builddir)/.markerfile $($(xcb-util-keysyms)-prefix)/.pkgbuild
	cd $($(xcb-util-keysyms)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-keysyms)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xcb-util-keysyms)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-keysyms)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-keysyms)-builddir)/.markerfile $($(xcb-util-keysyms)-prefix)/.pkgcheck
	cd $($(xcb-util-keysyms)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-keysyms)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xcb-util-keysyms)-modulefile): $(modulefilesdir)/.markerfile $($(xcb-util-keysyms)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xcb-util-keysyms)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xcb-util-keysyms)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xcb-util-keysyms)-description)\"" >>$@
	echo "module-whatis \"$($(xcb-util-keysyms)-url)\"" >>$@
	printf "$(foreach prereq,$($(xcb-util-keysyms)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XCB_UTIL_KEYSYMS_ROOT $($(xcb-util-keysyms)-prefix)" >>$@
	echo "setenv XCB_UTIL_KEYSYMS_INCDIR $($(xcb-util-keysyms)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_KEYSYMS_INCLUDEDIR $($(xcb-util-keysyms)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_KEYSYMS_LIBDIR $($(xcb-util-keysyms)-prefix)/lib" >>$@
	echo "setenv XCB_UTIL_KEYSYMS_LIBRARYDIR $($(xcb-util-keysyms)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xcb-util-keysyms)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xcb-util-keysyms)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xcb-util-keysyms)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xcb-util-keysyms)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xcb-util-keysyms)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(xcb-util-keysyms)\"" >>$@

$(xcb-util-keysyms)-src: $$($(xcb-util-keysyms)-src)
$(xcb-util-keysyms)-unpack: $($(xcb-util-keysyms)-prefix)/.pkgunpack
$(xcb-util-keysyms)-patch: $($(xcb-util-keysyms)-prefix)/.pkgpatch
$(xcb-util-keysyms)-build: $($(xcb-util-keysyms)-prefix)/.pkgbuild
$(xcb-util-keysyms)-check: $($(xcb-util-keysyms)-prefix)/.pkgcheck
$(xcb-util-keysyms)-install: $($(xcb-util-keysyms)-prefix)/.pkginstall
$(xcb-util-keysyms)-modulefile: $($(xcb-util-keysyms)-modulefile)
$(xcb-util-keysyms)-clean:
	rm -rf $($(xcb-util-keysyms)-modulefile)
	rm -rf $($(xcb-util-keysyms)-prefix)
	rm -rf $($(xcb-util-keysyms)-builddir)
	rm -rf $($(xcb-util-keysyms)-srcdir)
	rm -rf $($(xcb-util-keysyms)-src)
$(xcb-util-keysyms): $(xcb-util-keysyms)-src $(xcb-util-keysyms)-unpack $(xcb-util-keysyms)-patch $(xcb-util-keysyms)-build $(xcb-util-keysyms)-check $(xcb-util-keysyms)-install $(xcb-util-keysyms)-modulefile
