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
# libxscrnsaver-1.2.3

libxscrnsaver-version = 1.2.3
libxscrnsaver = libxscrnsaver-$(libxscrnsaver-version)
$(libxscrnsaver)-description = X Window System libraries
$(libxscrnsaver)-url = https://x.org/
$(libxscrnsaver)-srcurl = https://x.org/pub/individual/lib/libXScrnSaver-$(libxscrnsaver-version).tar.bz2
$(libxscrnsaver)-src = $(pkgsrcdir)/$(notdir $($(libxscrnsaver)-srcurl))
$(libxscrnsaver)-srcdir = $(pkgsrcdir)/libXScrnSaver-$(libxscrnsaver-version)
$(libxscrnsaver)-builddeps = $(fontconfig) $(libxcb) $(libxext) $(util-linux) $(xorg-util-macros)
$(libxscrnsaver)-prereqs = $(fontconfig) $(libxcb) $(libxext) $(util-linux)
$(libxscrnsaver)-modulefile = $(modulefilesdir)/$(libxscrnsaver)
$(libxscrnsaver)-prefix = $(pkgdir)/$(libxscrnsaver)

$($(libxscrnsaver)-src): $(dir $($(libxscrnsaver)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxscrnsaver)-srcurl)

$($(libxscrnsaver)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxscrnsaver)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxscrnsaver)-prefix)/.pkgunpack: $($(libxscrnsaver)-src) $($(libxscrnsaver)-srcdir)/.markerfile $($(libxscrnsaver)-prefix)/.markerfile $$(foreach dep,$$($(libxscrnsaver)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxscrnsaver)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxscrnsaver)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxscrnsaver)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxscrnsaver)-prefix)/.pkgunpack
	@touch $@

$($(libxscrnsaver)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxscrnsaver)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxscrnsaver)-prefix)/.pkgpatch
	cd $($(libxscrnsaver)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxscrnsaver)-builddeps) && \
		./configure --prefix=$($(libxscrnsaver)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxscrnsaver)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxscrnsaver)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxscrnsaver)-prefix)/.pkgbuild
	cd $($(libxscrnsaver)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxscrnsaver)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxscrnsaver)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxscrnsaver)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxscrnsaver)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxscrnsaver)-srcdir) install
	@touch $@

$($(libxscrnsaver)-modulefile): $(modulefilesdir)/.markerfile $($(libxscrnsaver)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxscrnsaver)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxscrnsaver)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxscrnsaver)-description)\"" >>$@
	echo "module-whatis \"$($(libxscrnsaver)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxscrnsaver)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXSCRNSAVER_ROOT $($(libxscrnsaver)-prefix)" >>$@
	echo "setenv LIBXSCRNSAVER_INCDIR $($(libxscrnsaver)-prefix)/include" >>$@
	echo "setenv LIBXSCRNSAVER_INCLUDEDIR $($(libxscrnsaver)-prefix)/include" >>$@
	echo "setenv LIBXSCRNSAVER_LIBDIR $($(libxscrnsaver)-prefix)/lib" >>$@
	echo "setenv LIBXSCRNSAVER_LIBRARYDIR $($(libxscrnsaver)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxscrnsaver)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxscrnsaver)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxscrnsaver)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxscrnsaver)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxscrnsaver)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxscrnsaver)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxscrnsaver)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxscrnsaver)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxscrnsaver)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxscrnsaver)\"" >>$@

$(libxscrnsaver)-src: $($(libxscrnsaver)-src)
$(libxscrnsaver)-unpack: $($(libxscrnsaver)-prefix)/.pkgunpack
$(libxscrnsaver)-patch: $($(libxscrnsaver)-prefix)/.pkgpatch
$(libxscrnsaver)-build: $($(libxscrnsaver)-prefix)/.pkgbuild
$(libxscrnsaver)-check: $($(libxscrnsaver)-prefix)/.pkgcheck
$(libxscrnsaver)-install: $($(libxscrnsaver)-prefix)/.pkginstall
$(libxscrnsaver)-modulefile: $($(libxscrnsaver)-modulefile)
$(libxscrnsaver)-clean:
	rm -rf $($(libxscrnsaver)-modulefile)
	rm -rf $($(libxscrnsaver)-prefix)
	rm -rf $($(libxscrnsaver)-srcdir)
	rm -rf $($(libxscrnsaver)-src)
$(libxscrnsaver): $(libxscrnsaver)-src $(libxscrnsaver)-unpack $(libxscrnsaver)-patch $(libxscrnsaver)-build $(libxscrnsaver)-check $(libxscrnsaver)-install $(libxscrnsaver)-modulefile
