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
# libxinerama-1.1.4

libxinerama-version = 1.1.4
libxinerama = libxinerama-$(libxinerama-version)
$(libxinerama)-description = X Window System libraries
$(libxinerama)-url = https://x.org/
$(libxinerama)-srcurl = https://x.org/pub/individual/lib/libXinerama-$(libxinerama-version).tar.bz2
$(libxinerama)-src = $(pkgsrcdir)/$(notdir $($(libxinerama)-srcurl))
$(libxinerama)-srcdir = $(pkgsrcdir)/libXinerama-$(libxinerama-version)
$(libxinerama)-builddeps = $(fontconfig) $(libxcb) $(libxext) $(util-linux) $(xorg-util-macros)
$(libxinerama)-prereqs = $(fontconfig) $(libxcb) $(libxext)
$(libxinerama)-modulefile = $(modulefilesdir)/$(libxinerama)
$(libxinerama)-prefix = $(pkgdir)/$(libxinerama)

$($(libxinerama)-src): $(dir $($(libxinerama)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxinerama)-srcurl)

$($(libxinerama)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxinerama)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxinerama)-prefix)/.pkgunpack: $($(libxinerama)-src) $($(libxinerama)-srcdir)/.markerfile $($(libxinerama)-prefix)/.markerfile $$(foreach dep,$$($(libxinerama)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxinerama)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxinerama)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxinerama)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxinerama)-prefix)/.pkgunpack
	@touch $@

$($(libxinerama)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxinerama)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxinerama)-prefix)/.pkgpatch
	cd $($(libxinerama)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxinerama)-builddeps) && \
		./configure --prefix=$($(libxinerama)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxinerama)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxinerama)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxinerama)-prefix)/.pkgbuild
	cd $($(libxinerama)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxinerama)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxinerama)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxinerama)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxinerama)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxinerama)-srcdir) install
	@touch $@

$($(libxinerama)-modulefile): $(modulefilesdir)/.markerfile $($(libxinerama)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxinerama)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxinerama)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxinerama)-description)\"" >>$@
	echo "module-whatis \"$($(libxinerama)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxinerama)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXINERAMA_ROOT $($(libxinerama)-prefix)" >>$@
	echo "setenv LIBXINERAMA_INCDIR $($(libxinerama)-prefix)/include" >>$@
	echo "setenv LIBXINERAMA_INCLUDEDIR $($(libxinerama)-prefix)/include" >>$@
	echo "setenv LIBXINERAMA_LIBDIR $($(libxinerama)-prefix)/lib" >>$@
	echo "setenv LIBXINERAMA_LIBRARYDIR $($(libxinerama)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxinerama)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxinerama)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxinerama)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxinerama)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxinerama)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxinerama)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxinerama)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxinerama)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxinerama)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxinerama)\"" >>$@

$(libxinerama)-src: $($(libxinerama)-src)
$(libxinerama)-unpack: $($(libxinerama)-prefix)/.pkgunpack
$(libxinerama)-patch: $($(libxinerama)-prefix)/.pkgpatch
$(libxinerama)-build: $($(libxinerama)-prefix)/.pkgbuild
$(libxinerama)-check: $($(libxinerama)-prefix)/.pkgcheck
$(libxinerama)-install: $($(libxinerama)-prefix)/.pkginstall
$(libxinerama)-modulefile: $($(libxinerama)-modulefile)
$(libxinerama)-clean:
	rm -rf $($(libxinerama)-modulefile)
	rm -rf $($(libxinerama)-prefix)
	rm -rf $($(libxinerama)-srcdir)
	rm -rf $($(libxinerama)-src)
$(libxinerama): $(libxinerama)-src $(libxinerama)-unpack $(libxinerama)-patch $(libxinerama)-build $(libxinerama)-check $(libxinerama)-install $(libxinerama)-modulefile
