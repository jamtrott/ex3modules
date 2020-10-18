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
# xtrans-1.4.0

xtrans-version = 1.4.0
xtrans = xtrans-$(xtrans-version)
$(xtrans)-description = X Window System libraries
$(xtrans)-url = https://x.org/
$(xtrans)-srcurl = https://x.org/pub/individual/lib/$(xtrans).tar.bz2
$(xtrans)-src = $(pkgsrcdir)/$(notdir $($(xtrans)-srcurl))
$(xtrans)-srcdir = $(pkgsrcdir)/$(xtrans)
$(xtrans)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(xtrans)-prereqs = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(xtrans)-modulefile = $(modulefilesdir)/$(xtrans)
$(xtrans)-prefix = $(pkgdir)/$(xtrans)

$($(xtrans)-src): $(dir $($(xtrans)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xtrans)-srcurl)

$($(xtrans)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(xtrans)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(xtrans)-prefix)/.pkgunpack: $($(xtrans)-src) $($(xtrans)-srcdir)/.markerfile $($(xtrans)-prefix)/.markerfile
	tar -C $($(xtrans)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(xtrans)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtrans)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtrans)-prefix)/.pkgunpack
	@touch $@

$($(xtrans)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtrans)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtrans)-prefix)/.pkgpatch
	cd $($(xtrans)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtrans)-builddeps) && \
		./configure --prefix=$($(xtrans)-prefix) && \
		$(MAKE)
	@touch $@

$($(xtrans)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtrans)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtrans)-prefix)/.pkgbuild
	cd $($(xtrans)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtrans)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(xtrans)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtrans)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtrans)-prefix)/.pkgcheck
	$(MAKE) -C $($(xtrans)-srcdir) install
	@touch $@

$($(xtrans)-modulefile): $(modulefilesdir)/.markerfile $($(xtrans)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xtrans)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xtrans)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xtrans)-description)\"" >>$@
	echo "module-whatis \"$($(xtrans)-url)\"" >>$@
	printf "$(foreach prereq,$($(xtrans)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XTRANS_ROOT $($(xtrans)-prefix)" >>$@
	echo "setenv XTRANS_INCDIR $($(xtrans)-prefix)/include" >>$@
	echo "setenv XTRANS_INCLUDEDIR $($(xtrans)-prefix)/include" >>$@
	echo "setenv XTRANS_LIBDIR $($(xtrans)-prefix)/lib" >>$@
	echo "setenv XTRANS_LIBRARYDIR $($(xtrans)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(xtrans)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xtrans)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xtrans)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xtrans)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xtrans)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xtrans)-prefix)/share/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(xtrans)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(xtrans)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(xtrans)-prefix)/share/info" >>$@
	echo "set MSG \"$(xtrans)\"" >>$@

$(xtrans)-src: $($(xtrans)-src)
$(xtrans)-unpack: $($(xtrans)-prefix)/.pkgunpack
$(xtrans)-patch: $($(xtrans)-prefix)/.pkgpatch
$(xtrans)-build: $($(xtrans)-prefix)/.pkgbuild
$(xtrans)-check: $($(xtrans)-prefix)/.pkgcheck
$(xtrans)-install: $($(xtrans)-prefix)/.pkginstall
$(xtrans)-modulefile: $($(xtrans)-modulefile)
$(xtrans)-clean:
	rm -rf $($(xtrans)-modulefile)
	rm -rf $($(xtrans)-prefix)
	rm -rf $($(xtrans)-srcdir)
	rm -rf $($(xtrans)-src)
$(xtrans): $(xtrans)-src $(xtrans)-unpack $(xtrans)-patch $(xtrans)-build $(xtrans)-check $(xtrans)-install $(xtrans)-modulefile
