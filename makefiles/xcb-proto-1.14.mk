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
# xcb-proto-1.14

xcb-proto-version = 1.14
xcb-proto = xcb-proto-$(xcb-proto-version)
$(xcb-proto)-description = X protocol descriptions for XCB
$(xcb-proto)-url = https://x.org/
$(xcb-proto)-srcurl = https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-$(xcb-proto-version).tar.xz
$(xcb-proto)-src = $(pkgsrcdir)/$(xcb-proto).tar.xz
$(xcb-proto)-srcdir = $(pkgsrcdir)/$(xcb-proto)
$(xcb-proto)-builddeps =
$(xcb-proto)-prereqs =
$(xcb-proto)-modulefile = $(modulefilesdir)/$(xcb-proto)
$(xcb-proto)-prefix = $(pkgdir)/$(xcb-proto)

$($(xcb-proto)-src): $(dir $($(xcb-proto)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xcb-proto)-srcurl)

$($(xcb-proto)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(xcb-proto)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(xcb-proto)-prefix)/.pkgunpack: $($(xcb-proto)-src) $($(xcb-proto)-srcdir)/.markerfile $($(xcb-proto)-prefix)/.markerfile
	tar -C $($(xcb-proto)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(xcb-proto)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-proto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-proto)-prefix)/.pkgunpack
	@touch $@

$($(xcb-proto)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-proto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-proto)-prefix)/.pkgpatch
	cd $($(xcb-proto)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-proto)-builddeps) && \
		./configure --prefix=$($(xcb-proto)-prefix) && \
		$(MAKE) MAKEFLAGS=
	@touch $@

$($(xcb-proto)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-proto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-proto)-prefix)/.pkgbuild
	cd $($(xcb-proto)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xcb-proto)-builddeps) && \
		$(MAKE) MAKEFLAGS= check
	@touch $@

$($(xcb-proto)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xcb-proto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xcb-proto)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(xcb-proto)-prefix) -C $($(xcb-proto)-srcdir) install
	@touch $@

$($(xcb-proto)-modulefile): $(modulefilesdir)/.markerfile $($(xcb-proto)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xcb-proto)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xcb-proto)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xcb-proto)-description)\"" >>$@
	echo "module-whatis \"$($(xcb-proto)-url)\"" >>$@
	printf "$(foreach prereq,$($(xcb-proto)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XCB_PROTO_ROOT $($(xcb-proto)-prefix)" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xcb-proto)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(xcb-proto)\"" >>$@

$(xcb-proto)-src: $($(xcb-proto)-src)
$(xcb-proto)-unpack: $($(xcb-proto)-prefix)/.pkgunpack
$(xcb-proto)-patch: $($(xcb-proto)-prefix)/.pkgpatch
$(xcb-proto)-build: $($(xcb-proto)-prefix)/.pkgbuild
$(xcb-proto)-check: $($(xcb-proto)-prefix)/.pkgcheck
$(xcb-proto)-install: $($(xcb-proto)-prefix)/.pkginstall
$(xcb-proto)-modulefile: $($(xcb-proto)-modulefile)
$(xcb-proto)-clean:
	rm -rf $($(xcb-proto)-modulefile)
	rm -rf $($(xcb-proto)-prefix)
	rm -rf $($(xcb-proto)-srcdir)
	rm -rf $($(xcb-proto)-src)
$(xcb-proto): $(xcb-proto)-src $(xcb-proto)-unpack $(xcb-proto)-patch $(xcb-proto)-build $(xcb-proto)-check $(xcb-proto)-install $(xcb-proto)-modulefile
