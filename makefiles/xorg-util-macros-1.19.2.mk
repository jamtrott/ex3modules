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
# xorg-util-macros-1.19.2

xorg-util-macros-version = 1.19.2
xorg-util-macros = xorg-util-macros-$(xorg-util-macros-version)
$(xorg-util-macros)-description = Autoconf macros for Xorg packages
$(xorg-util-macros)-url = https://x.org/
$(xorg-util-macros)-srcurl = https://www.x.org/pub/individual/util/util-macros-$(xorg-util-macros-version).tar.bz2
$(xorg-util-macros)-src = $(pkgsrcdir)/$(xorg-util-macros).tar.gz
$(xorg-util-macros)-srcdir = $(pkgsrcdir)/util-macros-$(xorg-util-macros-version)
$(xorg-util-macros)-builddeps =
$(xorg-util-macros)-prereqs =
$(xorg-util-macros)-modulefile = $(modulefilesdir)/$(xorg-util-macros)
$(xorg-util-macros)-prefix = $(pkgdir)/$(xorg-util-macros)

$($(xorg-util-macros)-src): $(dir $($(xorg-util-macros)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xorg-util-macros)-srcurl)

$($(xorg-util-macros)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xorg-util-macros)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xorg-util-macros)-prefix)/.pkgunpack: $($(xorg-util-macros)-src) $($(xorg-util-macros)-srcdir)/.markerfile $($(xorg-util-macros)-prefix)/.markerfile $$(foreach dep,$$($(xorg-util-macros)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(xorg-util-macros)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(xorg-util-macros)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-util-macros)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-util-macros)-prefix)/.pkgunpack
	@touch $@

$($(xorg-util-macros)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-util-macros)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-util-macros)-prefix)/.pkgpatch
	cd $($(xorg-util-macros)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xorg-util-macros)-builddeps) && \
		./configure --prefix=$($(xorg-util-macros)-prefix) && \
		$(MAKE)
	@touch $@

$($(xorg-util-macros)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-util-macros)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-util-macros)-prefix)/.pkgbuild
	cd $($(xorg-util-macros)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xorg-util-macros)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xorg-util-macros)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-util-macros)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-util-macros)-prefix)/.pkgcheck
	$(MAKE) -C $($(xorg-util-macros)-srcdir) install
	@touch $@

$($(xorg-util-macros)-modulefile): $(modulefilesdir)/.markerfile $($(xorg-util-macros)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xorg-util-macros)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xorg-util-macros)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xorg-util-macros)-description)\"" >>$@
	echo "module-whatis \"$($(xorg-util-macros)-url)\"" >>$@
	echo "" >>$@
	echo "$(foreach prereq,$($(xorg-util-macros)-prereqs),$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "setenv XORG_UTIL_MACROS_ROOT $($(xorg-util-macros)-prefix)" >>$@
	echo "prepend-path ACLOCAL_PATH $($(xorg-util-macros)-prefix)/share/aclocal" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xorg-util-macros)-prefix)/share/pkgconfig" >>$@
	echo "set MSG \"$(xorg-util-macros)\"" >>$@

$(xorg-util-macros)-src: $($(xorg-util-macros)-src)
$(xorg-util-macros)-unpack: $($(xorg-util-macros)-prefix)/.pkgunpack
$(xorg-util-macros)-patch: $($(xorg-util-macros)-prefix)/.pkgpatch
$(xorg-util-macros)-build: $($(xorg-util-macros)-prefix)/.pkgbuild
$(xorg-util-macros)-check: $($(xorg-util-macros)-prefix)/.pkgcheck
$(xorg-util-macros)-install: $($(xorg-util-macros)-prefix)/.pkginstall
$(xorg-util-macros)-modulefile: $($(xorg-util-macros)-modulefile)
$(xorg-util-macros)-clean:
	rm -rf $($(xorg-util-macros)-modulefile)
	rm -rf $($(xorg-util-macros)-prefix)
	rm -rf $($(xorg-util-macros)-srcdir)
	rm -rf $($(xorg-util-macros)-src)
$(xorg-util-macros): $(xorg-util-macros)-src $(xorg-util-macros)-unpack $(xorg-util-macros)-patch $(xorg-util-macros)-build $(xorg-util-macros)-check $(xorg-util-macros)-install $(xorg-util-macros)-modulefile
