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
# libxcursor-1.2.0

libxcursor-version = 1.2.0
libxcursor = libxcursor-$(libxcursor-version)
$(libxcursor)-description = X Window System libraries
$(libxcursor)-url = https://x.org/
$(libxcursor)-srcurl = https://x.org/pub/individual/lib/libXcursor-$(libxcursor-version).tar.bz2
$(libxcursor)-src = $(pkgsrcdir)/$(notdir $($(libxcursor)-srcurl))
$(libxcursor)-srcdir = $(pkgsrcdir)/libXcursor-$(libxcursor-version)
$(libxcursor)-builddeps = $(fontconfig) $(libxcb) $(libxrender) $(libxfixes) $(util-linux) $(xorg-util-macros)
$(libxcursor)-prereqs = $(fontconfig) $(libxcb) $(libxrender) $(libxfixes)
$(libxcursor)-modulefile = $(modulefilesdir)/$(libxcursor)
$(libxcursor)-prefix = $(pkgdir)/$(libxcursor)

$($(libxcursor)-src): $(dir $($(libxcursor)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxcursor)-srcurl)

$($(libxcursor)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxcursor)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxcursor)-prefix)/.pkgunpack: $($(libxcursor)-src) $($(libxcursor)-srcdir)/.markerfile $($(libxcursor)-prefix)/.markerfile $$(foreach dep,$$($(libxcursor)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxcursor)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxcursor)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcursor)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcursor)-prefix)/.pkgunpack
	@touch $@

$($(libxcursor)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcursor)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcursor)-prefix)/.pkgpatch
	cd $($(libxcursor)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxcursor)-builddeps) && \
		./configure --prefix=$($(libxcursor)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxcursor)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcursor)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcursor)-prefix)/.pkgbuild
	cd $($(libxcursor)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxcursor)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxcursor)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcursor)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcursor)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxcursor)-srcdir) install
	@touch $@

$($(libxcursor)-modulefile): $(modulefilesdir)/.markerfile $($(libxcursor)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxcursor)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxcursor)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxcursor)-description)\"" >>$@
	echo "module-whatis \"$($(libxcursor)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxcursor)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXCURSOR_ROOT $($(libxcursor)-prefix)" >>$@
	echo "setenv LIBXCURSOR_INCDIR $($(libxcursor)-prefix)/include" >>$@
	echo "setenv LIBXCURSOR_INCLUDEDIR $($(libxcursor)-prefix)/include" >>$@
	echo "setenv LIBXCURSOR_LIBDIR $($(libxcursor)-prefix)/lib" >>$@
	echo "setenv LIBXCURSOR_LIBRARYDIR $($(libxcursor)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxcursor)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxcursor)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxcursor)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxcursor)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxcursor)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxcursor)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxcursor)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxcursor)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxcursor)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxcursor)\"" >>$@

$(libxcursor)-src: $($(libxcursor)-src)
$(libxcursor)-unpack: $($(libxcursor)-prefix)/.pkgunpack
$(libxcursor)-patch: $($(libxcursor)-prefix)/.pkgpatch
$(libxcursor)-build: $($(libxcursor)-prefix)/.pkgbuild
$(libxcursor)-check: $($(libxcursor)-prefix)/.pkgcheck
$(libxcursor)-install: $($(libxcursor)-prefix)/.pkginstall
$(libxcursor)-modulefile: $($(libxcursor)-modulefile)
$(libxcursor)-clean:
	rm -rf $($(libxcursor)-modulefile)
	rm -rf $($(libxcursor)-prefix)
	rm -rf $($(libxcursor)-srcdir)
	rm -rf $($(libxcursor)-src)
$(libxcursor): $(libxcursor)-src $(libxcursor)-unpack $(libxcursor)-patch $(libxcursor)-build $(libxcursor)-check $(libxcursor)-install $(libxcursor)-modulefile
