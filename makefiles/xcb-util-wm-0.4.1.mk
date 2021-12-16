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
# xcb-util-wm-0.4.1

xcb-util-wm-version = 0.4.1
xcb-util-wm = xcb-util-wm-$(xcb-util-wm-version)
$(xcb-util-wm)-description = X protocol C-language Binding (XCB) Utilities, Window Manager Utilities
$(xcb-util-wm)-url = https://xcb.freedesktop.org/
$(xcb-util-wm)-srcurl = https://xcb.freedesktop.org/dist/xcb-util-wm-$(xcb-util-wm-version).tar.gz
$(xcb-util-wm)-builddeps = $(libxcb) $(xcb-util)
$(xcb-util-wm)-prereqs = $(libxcb) $(xcb-util)
$(xcb-util-wm)-src = $(pkgsrcdir)/$(notdir $($(xcb-util-wm)-srcurl))
$(xcb-util-wm)-srcdir = $(pkgsrcdir)/$(xcb-util-wm)
$(xcb-util-wm)-builddir = $($(xcb-util-wm)-srcdir)
$(xcb-util-wm)-modulefile = $(modulefilesdir)/$(xcb-util-wm)
$(xcb-util-wm)-prefix = $(pkgdir)/$(xcb-util-wm)

$($(xcb-util-wm)-src): $(dir $($(xcb-util-wm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xcb-util-wm)-srcurl)

$($(xcb-util-wm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-wm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-wm)-prefix)/.pkgunpack: $$($(xcb-util-wm)-src) $($(xcb-util-wm)-srcdir)/.markerfile $($(xcb-util-wm)-prefix)/.markerfile $$(foreach dep,$$($(xcb-util-wm)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(xcb-util-wm)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xcb-util-wm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-wm)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-wm)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xcb-util-wm)-builddir),$($(xcb-util-wm)-srcdir))
$($(xcb-util-wm)-builddir)/.markerfile: $($(xcb-util-wm)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xcb-util-wm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-wm)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-wm)-builddir)/.markerfile $($(xcb-util-wm)-prefix)/.pkgpatch
	cd $($(xcb-util-wm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-wm)-builddeps) && \
		./configure --prefix=$($(xcb-util-wm)-prefix) && \
		$(MAKE)
	@touch $@

$($(xcb-util-wm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-wm)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-wm)-builddir)/.markerfile $($(xcb-util-wm)-prefix)/.pkgbuild
	cd $($(xcb-util-wm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-wm)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xcb-util-wm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-wm)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-wm)-builddir)/.markerfile $($(xcb-util-wm)-prefix)/.pkgcheck
	cd $($(xcb-util-wm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-wm)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xcb-util-wm)-modulefile): $(modulefilesdir)/.markerfile $($(xcb-util-wm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xcb-util-wm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xcb-util-wm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xcb-util-wm)-description)\"" >>$@
	echo "module-whatis \"$($(xcb-util-wm)-url)\"" >>$@
	printf "$(foreach prereq,$($(xcb-util-wm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XCB_UTIL_WM_ROOT $($(xcb-util-wm)-prefix)" >>$@
	echo "setenv XCB_UTIL_WM_INCDIR $($(xcb-util-wm)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_WM_INCLUDEDIR $($(xcb-util-wm)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_WM_LIBDIR $($(xcb-util-wm)-prefix)/lib" >>$@
	echo "setenv XCB_UTIL_WM_LIBRARYDIR $($(xcb-util-wm)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xcb-util-wm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xcb-util-wm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xcb-util-wm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xcb-util-wm)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xcb-util-wm)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(xcb-util-wm)\"" >>$@

$(xcb-util-wm)-src: $$($(xcb-util-wm)-src)
$(xcb-util-wm)-unpack: $($(xcb-util-wm)-prefix)/.pkgunpack
$(xcb-util-wm)-patch: $($(xcb-util-wm)-prefix)/.pkgpatch
$(xcb-util-wm)-build: $($(xcb-util-wm)-prefix)/.pkgbuild
$(xcb-util-wm)-check: $($(xcb-util-wm)-prefix)/.pkgcheck
$(xcb-util-wm)-install: $($(xcb-util-wm)-prefix)/.pkginstall
$(xcb-util-wm)-modulefile: $($(xcb-util-wm)-modulefile)
$(xcb-util-wm)-clean:
	rm -rf $($(xcb-util-wm)-modulefile)
	rm -rf $($(xcb-util-wm)-prefix)
	rm -rf $($(xcb-util-wm)-builddir)
	rm -rf $($(xcb-util-wm)-srcdir)
	rm -rf $($(xcb-util-wm)-src)
$(xcb-util-wm): $(xcb-util-wm)-src $(xcb-util-wm)-unpack $(xcb-util-wm)-patch $(xcb-util-wm)-build $(xcb-util-wm)-check $(xcb-util-wm)-install $(xcb-util-wm)-modulefile
