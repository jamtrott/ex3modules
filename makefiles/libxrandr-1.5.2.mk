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
# libxrandr-1.5.2

libxrandr-version = 1.5.2
libxrandr = libxrandr-$(libxrandr-version)
$(libxrandr)-description = X Window System libraries
$(libxrandr)-url = https://x.org/
$(libxrandr)-srcurl = https://x.org/pub/individual/lib/libXrandr-$(libxrandr-version).tar.bz2
$(libxrandr)-src = $(pkgsrcdir)/$(notdir $($(libxrandr)-srcurl))
$(libxrandr)-srcdir = $(pkgsrcdir)/libXrandr-$(libxrandr-version)
$(libxrandr)-builddeps = $(fontconfig) $(libxcb) $(libxext) $(libxrender) $(util-linux) $(xorg-util-macros)
$(libxrandr)-prereqs = $(fontconfig) $(libxcb) $(libxext) $(libxrender)
$(libxrandr)-modulefile = $(modulefilesdir)/$(libxrandr)
$(libxrandr)-prefix = $(pkgdir)/$(libxrandr)

$($(libxrandr)-src): $(dir $($(libxrandr)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxrandr)-srcurl)

$($(libxrandr)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxrandr)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxrandr)-prefix)/.pkgunpack: $($(libxrandr)-src) $($(libxrandr)-srcdir)/.markerfile $($(libxrandr)-prefix)/.markerfile
	tar -C $($(libxrandr)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxrandr)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrandr)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrandr)-prefix)/.pkgunpack
	@touch $@

$($(libxrandr)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrandr)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrandr)-prefix)/.pkgpatch
	cd $($(libxrandr)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxrandr)-builddeps) && \
		./configure --prefix=$($(libxrandr)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxrandr)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrandr)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrandr)-prefix)/.pkgbuild
	cd $($(libxrandr)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxrandr)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxrandr)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrandr)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrandr)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxrandr)-srcdir) install
	@touch $@

$($(libxrandr)-modulefile): $(modulefilesdir)/.markerfile $($(libxrandr)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxrandr)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxrandr)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxrandr)-description)\"" >>$@
	echo "module-whatis \"$($(libxrandr)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxrandr)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXRANDR_ROOT $($(libxrandr)-prefix)" >>$@
	echo "setenv LIBXRANDR_INCDIR $($(libxrandr)-prefix)/include" >>$@
	echo "setenv LIBXRANDR_INCLUDEDIR $($(libxrandr)-prefix)/include" >>$@
	echo "setenv LIBXRANDR_LIBDIR $($(libxrandr)-prefix)/lib" >>$@
	echo "setenv LIBXRANDR_LIBRARYDIR $($(libxrandr)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxrandr)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxrandr)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxrandr)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxrandr)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxrandr)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxrandr)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxrandr)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxrandr)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxrandr)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxrandr)\"" >>$@

$(libxrandr)-src: $($(libxrandr)-src)
$(libxrandr)-unpack: $($(libxrandr)-prefix)/.pkgunpack
$(libxrandr)-patch: $($(libxrandr)-prefix)/.pkgpatch
$(libxrandr)-build: $($(libxrandr)-prefix)/.pkgbuild
$(libxrandr)-check: $($(libxrandr)-prefix)/.pkgcheck
$(libxrandr)-install: $($(libxrandr)-prefix)/.pkginstall
$(libxrandr)-modulefile: $($(libxrandr)-modulefile)
$(libxrandr)-clean:
	rm -rf $($(libxrandr)-modulefile)
	rm -rf $($(libxrandr)-prefix)
	rm -rf $($(libxrandr)-srcdir)
	rm -rf $($(libxrandr)-src)
$(libxrandr): $(libxrandr)-src $(libxrandr)-unpack $(libxrandr)-patch $(libxrandr)-build $(libxrandr)-check $(libxrandr)-install $(libxrandr)-modulefile
