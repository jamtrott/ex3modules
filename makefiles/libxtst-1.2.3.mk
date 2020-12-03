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
# libxtst-1.2.3

libxtst-version = 1.2.3
libxtst = libxtst-$(libxtst-version)
$(libxtst)-description = X Window System libraries
$(libxtst)-url = https://x.org/
$(libxtst)-srcurl = https://x.org/pub/individual/lib/libXtst-$(libxtst-version).tar.bz2
$(libxtst)-src = $(pkgsrcdir)/$(notdir $($(libxtst)-srcurl))
$(libxtst)-srcdir = $(pkgsrcdir)/libXtst-$(libxtst-version)
$(libxtst)-builddeps = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(libxi) $(util-linux) $(xorg-util-macros)
$(libxtst)-prereqs = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(libxi)
$(libxtst)-modulefile = $(modulefilesdir)/$(libxtst)
$(libxtst)-prefix = $(pkgdir)/$(libxtst)

$($(libxtst)-src): $(dir $($(libxtst)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxtst)-srcurl)

$($(libxtst)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxtst)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxtst)-prefix)/.pkgunpack: $($(libxtst)-src) $($(libxtst)-srcdir)/.markerfile $($(libxtst)-prefix)/.markerfile
	tar -C $($(libxtst)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxtst)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxtst)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxtst)-prefix)/.pkgunpack
	@touch $@

$($(libxtst)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxtst)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxtst)-prefix)/.pkgpatch
	cd $($(libxtst)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxtst)-builddeps) && \
		./configure --prefix=$($(libxtst)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxtst)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxtst)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxtst)-prefix)/.pkgbuild
	cd $($(libxtst)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxtst)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxtst)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxtst)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxtst)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxtst)-srcdir) install
	@touch $@

$($(libxtst)-modulefile): $(modulefilesdir)/.markerfile $($(libxtst)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxtst)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxtst)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxtst)-description)\"" >>$@
	echo "module-whatis \"$($(libxtst)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxtst)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXTST_ROOT $($(libxtst)-prefix)" >>$@
	echo "setenv LIBXTST_INCDIR $($(libxtst)-prefix)/include" >>$@
	echo "setenv LIBXTST_INCLUDEDIR $($(libxtst)-prefix)/include" >>$@
	echo "setenv LIBXTST_LIBDIR $($(libxtst)-prefix)/lib" >>$@
	echo "setenv LIBXTST_LIBRARYDIR $($(libxtst)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxtst)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxtst)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxtst)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxtst)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxtst)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxtst)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxtst)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxtst)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxtst)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxtst)\"" >>$@

$(libxtst)-src: $($(libxtst)-src)
$(libxtst)-unpack: $($(libxtst)-prefix)/.pkgunpack
$(libxtst)-patch: $($(libxtst)-prefix)/.pkgpatch
$(libxtst)-build: $($(libxtst)-prefix)/.pkgbuild
$(libxtst)-check: $($(libxtst)-prefix)/.pkgcheck
$(libxtst)-install: $($(libxtst)-prefix)/.pkginstall
$(libxtst)-modulefile: $($(libxtst)-modulefile)
$(libxtst)-clean:
	rm -rf $($(libxtst)-modulefile)
	rm -rf $($(libxtst)-prefix)
	rm -rf $($(libxtst)-srcdir)
	rm -rf $($(libxtst)-src)
$(libxtst): $(libxtst)-src $(libxtst)-unpack $(libxtst)-patch $(libxtst)-build $(libxtst)-check $(libxtst)-install $(libxtst)-modulefile
