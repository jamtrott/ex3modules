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
# libxres-1.2.0

libxres-version = 1.2.0
libxres = libxres-$(libxres-version)
$(libxres)-description = X Window System libraries
$(libxres)-url = https://x.org/
$(libxres)-srcurl = https://x.org/pub/individual/lib/libXres-$(libxres-version).tar.bz2
$(libxres)-src = $(pkgsrcdir)/$(notdir $($(libxres)-srcurl))
$(libxres)-srcdir = $(pkgsrcdir)/libXres-$(libxres-version)
$(libxres)-builddeps = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(util-linux) $(xorg-util-macros)
$(libxres)-prereqs = $(fontconfig) $(libxcb) $(libx11) $(libxext)
$(libxres)-modulefile = $(modulefilesdir)/$(libxres)
$(libxres)-prefix = $(pkgdir)/$(libxres)

$($(libxres)-src): $(dir $($(libxres)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxres)-srcurl)

$($(libxres)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxres)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxres)-prefix)/.pkgunpack: $($(libxres)-src) $($(libxres)-srcdir)/.markerfile $($(libxres)-prefix)/.markerfile $$(foreach dep,$$($(libxres)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxres)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxres)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxres)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxres)-prefix)/.pkgunpack
	@touch $@

$($(libxres)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxres)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxres)-prefix)/.pkgpatch
	cd $($(libxres)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxres)-builddeps) && \
		./configure --prefix=$($(libxres)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxres)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxres)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxres)-prefix)/.pkgbuild
	cd $($(libxres)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxres)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxres)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxres)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxres)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxres)-srcdir) install
	@touch $@

$($(libxres)-modulefile): $(modulefilesdir)/.markerfile $($(libxres)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxres)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxres)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxres)-description)\"" >>$@
	echo "module-whatis \"$($(libxres)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxres)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXRES_ROOT $($(libxres)-prefix)" >>$@
	echo "setenv LIBXRES_INCDIR $($(libxres)-prefix)/include" >>$@
	echo "setenv LIBXRES_INCLUDEDIR $($(libxres)-prefix)/include" >>$@
	echo "setenv LIBXRES_LIBDIR $($(libxres)-prefix)/lib" >>$@
	echo "setenv LIBXRES_LIBRARYDIR $($(libxres)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxres)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxres)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxres)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxres)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxres)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxres)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxres)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxres)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxres)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxres)\"" >>$@

$(libxres)-src: $($(libxres)-src)
$(libxres)-unpack: $($(libxres)-prefix)/.pkgunpack
$(libxres)-patch: $($(libxres)-prefix)/.pkgpatch
$(libxres)-build: $($(libxres)-prefix)/.pkgbuild
$(libxres)-check: $($(libxres)-prefix)/.pkgcheck
$(libxres)-install: $($(libxres)-prefix)/.pkginstall
$(libxres)-modulefile: $($(libxres)-modulefile)
$(libxres)-clean:
	rm -rf $($(libxres)-modulefile)
	rm -rf $($(libxres)-prefix)
	rm -rf $($(libxres)-srcdir)
	rm -rf $($(libxres)-src)
$(libxres): $(libxres)-src $(libxres)-unpack $(libxres)-patch $(libxres)-build $(libxres)-check $(libxres)-install $(libxres)-modulefile
