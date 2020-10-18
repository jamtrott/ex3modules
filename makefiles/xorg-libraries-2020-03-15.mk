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
# xorg-libraries-2020-03-15

xorg-libraries-version = 2020-03-15
xorg-libraries = xorg-libraries-$(xorg-libraries-version)
$(xorg-libraries)-description = X Window System libraries
$(xorg-libraries)-url = https://x.org/
$(xorg-libraries)-srcurl =
$(xorg-libraries)-src =
$(xorg-libraries)-srcdir =
$(xorg-libraries)-builddeps = $(xtrans) $(libx11) $(libxext) $(libfs) $(libice) $(libsm) $(libxscrnsaver) $(libxt) $(libxmu) $(libxpm) $(libxaw) $(libxfixes) $(libxcomposite) $(libxrender) $(libxcursor) $(libxdamage) $(libfontenc) $(libxfont2) $(libxft) $(libxi) $(libxinerama) $(libxrandr) $(libxres) $(libxtst) $(libxv) $(libxvmc) $(libxxf86dga) $(libxxf86vm) $(libdmx) $(libpciaccess) $(libxkbfile) $(libxshmfence)
$(xorg-libraries)-prereqs = $(xtrans) $(libx11) $(libxext) $(libfs) $(libice) $(libsm) $(libxscrnsaver) $(libxt) $(libxmu) $(libxpm) $(libxaw) $(libxfixes) $(libxcomposite) $(libxrender) $(libxcursor) $(libxdamage) $(libfontenc) $(libxfont2) $(libxft) $(libxi) $(libxinerama) $(libxrandr) $(libxres) $(libxtst) $(libxv) $(libxvmc) $(libxxf86dga) $(libxxf86vm) $(libdmx) $(libpciaccess) $(libxkbfile) $(libxshmfence)
$(xorg-libraries)-modulefile = $(modulefilesdir)/$(xorg-libraries)
$(xorg-libraries)-prefix = $(pkgdir)/$(xorg-libraries)

$($(xorg-libraries)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(xorg-libraries)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(xorg-libraries)-prefix)/.pkgunpack: $($(xorg-libraries)-prefix)/.markerfile
	@touch $@

$($(xorg-libraries)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-libraries)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-libraries)-prefix)/.pkgunpack
	@touch $@

$($(xorg-libraries)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-libraries)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-libraries)-prefix)/.pkgpatch
	@touch $@

$($(xorg-libraries)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-libraries)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-libraries)-prefix)/.pkgbuild
	@touch $@

$($(xorg-libraries)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xorg-libraries)-builddeps),$(modulefilesdir)/$$(dep)) $($(xorg-libraries)-prefix)/.pkgcheck
	@touch $@

$($(xorg-libraries)-modulefile): $(modulefilesdir)/.markerfile $($(xorg-libraries)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xorg-libraries)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xorg-libraries)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xorg-libraries)-description)\"" >>$@
	echo "module-whatis \"$($(xorg-libraries)-url)\"" >>$@
	printf "$(foreach prereq,$($(xorg-libraries)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "set MSG \"$(xorg-libraries)\"" >>$@

$(xorg-libraries)-src:
$(xorg-libraries)-unpack: $($(xorg-libraries)-prefix)/.pkgunpack
$(xorg-libraries)-patch: $($(xorg-libraries)-prefix)/.pkgpatch
$(xorg-libraries)-build: $($(xorg-libraries)-prefix)/.pkgbuild
$(xorg-libraries)-check: $($(xorg-libraries)-prefix)/.pkgcheck
$(xorg-libraries)-install: $($(xorg-libraries)-prefix)/.pkginstall
$(xorg-libraries)-modulefile: $($(xorg-libraries)-modulefile)
$(xorg-libraries)-clean:
	rm -rf $($(xorg-libraries)-modulefile)
	rm -rf $($(xorg-libraries)-prefix)
$(xorg-libraries): $(xorg-libraries)-src $(xorg-libraries)-unpack $(xorg-libraries)-patch $(xorg-libraries)-build $(xorg-libraries)-check $(xorg-libraries)-install $(xorg-libraries)-modulefile
