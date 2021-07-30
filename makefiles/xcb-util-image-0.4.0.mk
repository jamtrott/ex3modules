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
# xcb-util-image-0.4.0

xcb-util-image-version = 0.4.0
xcb-util-image = xcb-util-image-$(xcb-util-image-version)
$(xcb-util-image)-description = X protocol C-language Binding (XCB) Utilities, Port of Xlib\'s XImage and XShmImage functions
$(xcb-util-image)-url = https://xcb.freedesktop.org/
$(xcb-util-image)-srcurl = https://xcb.freedesktop.org/dist/xcb-util-image-$(xcb-util-image-version).tar.gz
$(xcb-util-image)-builddeps = $(libxcb) $(xcb-util)
$(xcb-util-image)-prereqs = $(libxcb) $(xcb-util)
$(xcb-util-image)-src = $(pkgsrcdir)/$(notdir $($(xcb-util-image)-srcurl))
$(xcb-util-image)-srcdir = $(pkgsrcdir)/$(xcb-util-image)
$(xcb-util-image)-builddir = $($(xcb-util-image)-srcdir)
$(xcb-util-image)-modulefile = $(modulefilesdir)/$(xcb-util-image)
$(xcb-util-image)-prefix = $(pkgdir)/$(xcb-util-image)

$($(xcb-util-image)-src): $(dir $($(xcb-util-image)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xcb-util-image)-srcurl)

$($(xcb-util-image)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-image)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xcb-util-image)-prefix)/.pkgunpack: $$($(xcb-util-image)-src) $($(xcb-util-image)-srcdir)/.markerfile $($(xcb-util-image)-prefix)/.markerfile
	tar -C $($(xcb-util-image)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xcb-util-image)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-image)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-image)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xcb-util-image)-builddir),$($(xcb-util-image)-srcdir))
$($(xcb-util-image)-builddir)/.markerfile: $($(xcb-util-image)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xcb-util-image)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-image)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-image)-builddir)/.markerfile $($(xcb-util-image)-prefix)/.pkgpatch
	cd $($(xcb-util-image)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-image)-builddeps) && \
		./configure --prefix=$($(xcb-util-image)-prefix) && \
		$(MAKE)
	@touch $@

$($(xcb-util-image)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-image)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-image)-builddir)/.markerfile $($(xcb-util-image)-prefix)/.pkgbuild
	cd $($(xcb-util-image)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-image)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xcb-util-image)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-util-image)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-util-image)-builddir)/.markerfile $($(xcb-util-image)-prefix)/.pkgcheck
	cd $($(xcb-util-image)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-util-image)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xcb-util-image)-modulefile): $(modulefilesdir)/.markerfile $($(xcb-util-image)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xcb-util-image)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xcb-util-image)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xcb-util-image)-description)\"" >>$@
	echo "module-whatis \"$($(xcb-util-image)-url)\"" >>$@
	printf "$(foreach prereq,$($(xcb-util-image)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XCB_UTIL_IMAGE_ROOT $($(xcb-util-image)-prefix)" >>$@
	echo "setenv XCB_UTIL_IMAGE_INCDIR $($(xcb-util-image)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_IMAGE_INCLUDEDIR $($(xcb-util-image)-prefix)/include" >>$@
	echo "setenv XCB_UTIL_IMAGE_LIBDIR $($(xcb-util-image)-prefix)/lib" >>$@
	echo "setenv XCB_UTIL_IMAGE_LIBRARYDIR $($(xcb-util-image)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(xcb-util-image)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xcb-util-image)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xcb-util-image)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xcb-util-image)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xcb-util-image)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xcb-util-image)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(xcb-util-image)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(xcb-util-image)-prefix)/share/info" >>$@
	echo "set MSG \"$(xcb-util-image)\"" >>$@

$(xcb-util-image)-src: $$($(xcb-util-image)-src)
$(xcb-util-image)-unpack: $($(xcb-util-image)-prefix)/.pkgunpack
$(xcb-util-image)-patch: $($(xcb-util-image)-prefix)/.pkgpatch
$(xcb-util-image)-build: $($(xcb-util-image)-prefix)/.pkgbuild
$(xcb-util-image)-check: $($(xcb-util-image)-prefix)/.pkgcheck
$(xcb-util-image)-install: $($(xcb-util-image)-prefix)/.pkginstall
$(xcb-util-image)-modulefile: $($(xcb-util-image)-modulefile)
$(xcb-util-image)-clean:
	rm -rf $($(xcb-util-image)-modulefile)
	rm -rf $($(xcb-util-image)-prefix)
	rm -rf $($(xcb-util-image)-builddir)
	rm -rf $($(xcb-util-image)-srcdir)
	rm -rf $($(xcb-util-image)-src)
$(xcb-util-image): $(xcb-util-image)-src $(xcb-util-image)-unpack $(xcb-util-image)-patch $(xcb-util-image)-build $(xcb-util-image)-check $(xcb-util-image)-install $(xcb-util-image)-modulefile
