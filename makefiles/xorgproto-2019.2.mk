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
# xorgproto-2019.2

xorgproto-version = 2019.2
xorgproto = xorgproto-$(xorgproto-version)
$(xorgproto)-description = Header files for the X Window system
$(xorgproto)-url = https://x.org/
$(xorgproto)-srcurl = https://xorg.freedesktop.org/archive/individual/proto/xorgproto-$(xorgproto-version).tar.bz2
$(xorgproto)-src = $(pkgsrcdir)/$(xorgproto).tar.bz2
$(xorgproto)-srcdir = $(pkgsrcdir)/$(xorgproto)
$(xorgproto)-builddeps = $(xorg-util-macros) $(meson) $(ninja)
$(xorgproto)-prereqs =
$(xorgproto)-modulefile = $(modulefilesdir)/$(xorgproto)
$(xorgproto)-prefix = $(pkgdir)/$(xorgproto)

$($(xorgproto)-src): $(dir $($(xorgproto)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xorgproto)-srcurl)

$($(xorgproto)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xorgproto)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xorgproto)-prefix)/.pkgunpack: $($(xorgproto)-src) $($(xorgproto)-srcdir)/.markerfile $($(xorgproto)-prefix)/.markerfile $$(foreach dep,$$($(xorgproto)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(xorgproto)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(xorgproto)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorgproto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorgproto)-prefix)/.pkgunpack
	@touch $@

$($(xorgproto)-srcdir)/build/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(xorgproto)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorgproto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorgproto)-prefix)/.pkgpatch $($(xorgproto)-srcdir)/build/.markerfile
	cd $($(xorgproto)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xorgproto)-builddeps) && \
		meson --prefix=$($(xorgproto)-prefix) .. && \
		ninja
	@touch $@

$($(xorgproto)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorgproto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorgproto)-prefix)/.pkgbuild
	@touch $@

$($(xorgproto)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorgproto)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorgproto)-prefix)/.pkgcheck
	cd $($(xorgproto)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xorgproto)-builddeps) && \
		ninja install && \
		$(INSTALL) -vdm 755 "$($(xorgproto)-prefix)/share/doc/xorgproto-$(xorgproto-version)" && \
		$(INSTALL) -vm 644 ../[^m]*.txt ../PM_spec "$($(xorgproto)-prefix)/share/doc/xorgproto-$(xorgproto-version)"
	@touch $@

$($(xorgproto)-modulefile): $(modulefilesdir)/.markerfile $($(xorgproto)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xorgproto)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xorgproto)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xorgproto)-description)\"" >>$@
	echo "module-whatis \"$($(xorgproto)-url)\"" >>$@
	printf "$(foreach prereq,$($(xorgproto)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XORGPROTO_ROOT $($(xorgproto)-prefix)" >>$@
	echo "setenv XORGPROTO_INCDIR $($(xorgproto)-prefix)/include" >>$@
	echo "setenv XORGPROTO_INCLUDEDIR $($(xorgproto)-prefix)/include" >>$@
	echo "prepend-path PATH $($(xorgproto)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xorgproto)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xorgproto)-prefix)/include" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xorgproto)-prefix)/share/pkgconfig" >>$@
	echo "set MSG \"$(xorgproto)\"" >>$@

$(xorgproto)-src: $($(xorgproto)-src)
$(xorgproto)-unpack: $($(xorgproto)-prefix)/.pkgunpack
$(xorgproto)-patch: $($(xorgproto)-prefix)/.pkgpatch
$(xorgproto)-build: $($(xorgproto)-prefix)/.pkgbuild
$(xorgproto)-check: $($(xorgproto)-prefix)/.pkgcheck
$(xorgproto)-install: $($(xorgproto)-prefix)/.pkginstall
$(xorgproto)-modulefile: $($(xorgproto)-modulefile)
$(xorgproto)-clean:
	rm -rf $($(xorgproto)-modulefile)
	rm -rf $($(xorgproto)-prefix)
	rm -rf $($(xorgproto)-srcdir)
	rm -rf $($(xorgproto)-src)
$(xorgproto): $(xorgproto)-src $(xorgproto)-unpack $(xorgproto)-patch $(xorgproto)-build $(xorgproto)-check $(xorgproto)-install $(xorgproto)-modulefile
