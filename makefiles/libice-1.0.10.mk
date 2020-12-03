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
# libice-1.0.10

libice-version = 1.0.10
libice = libice-$(libice-version)
$(libice)-description = X Window System libraries
$(libice)-url = https://x.org/
$(libice)-srcurl = https://x.org/pub/individual/lib/libICE-$(libice-version).tar.bz2
$(libice)-src = $(pkgsrcdir)/$(notdir $($(libice)-srcurl))
$(libice)-srcdir = $(pkgsrcdir)/libICE-$(libice-version)
$(libice)-builddeps = $(fontconfig) $(libxcb) $(xtrans) $(util-linux) $(xorg-util-macros)
$(libice)-prereqs = $(fontconfig) $(libxcb) $(util-linux)
$(libice)-modulefile = $(modulefilesdir)/$(libice)
$(libice)-prefix = $(pkgdir)/$(libice)

$($(libice)-src): $(dir $($(libice)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libice)-srcurl)

$($(libice)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libice)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libice)-prefix)/.pkgunpack: $($(libice)-src) $($(libice)-srcdir)/.markerfile $($(libice)-prefix)/.markerfile
	tar -C $($(libice)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libice)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libice)-builddeps),$(modulefilesdir)/$$(dep)) $($(libice)-prefix)/.pkgunpack
	@touch $@

$($(libice)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libice)-builddeps),$(modulefilesdir)/$$(dep)) $($(libice)-prefix)/.pkgpatch
	cd $($(libice)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libice)-builddeps) && \
		./configure --prefix=$($(libice)-prefix) ICE_LIBS=-lpthread --disable-static && \
		$(MAKE)
	@touch $@

$($(libice)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libice)-builddeps),$(modulefilesdir)/$$(dep)) $($(libice)-prefix)/.pkgbuild
	cd $($(libice)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libice)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libice)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libice)-builddeps),$(modulefilesdir)/$$(dep)) $($(libice)-prefix)/.pkgcheck
	$(MAKE) -C $($(libice)-srcdir) install
	@touch $@

$($(libice)-modulefile): $(modulefilesdir)/.markerfile $($(libice)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libice)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libice)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libice)-description)\"" >>$@
	echo "module-whatis \"$($(libice)-url)\"" >>$@
	printf "$(foreach prereq,$($(libice)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBICE_ROOT $($(libice)-prefix)" >>$@
	echo "setenv LIBICE_INCDIR $($(libice)-prefix)/include" >>$@
	echo "setenv LIBICE_INCLUDEDIR $($(libice)-prefix)/include" >>$@
	echo "setenv LIBICE_LIBDIR $($(libice)-prefix)/lib" >>$@
	echo "setenv LIBICE_LIBRARYDIR $($(libice)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libice)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libice)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libice)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libice)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libice)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libice)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libice)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libice)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libice)-prefix)/share/info" >>$@
	echo "set MSG \"$(libice)\"" >>$@

$(libice)-src: $($(libice)-src)
$(libice)-unpack: $($(libice)-prefix)/.pkgunpack
$(libice)-patch: $($(libice)-prefix)/.pkgpatch
$(libice)-build: $($(libice)-prefix)/.pkgbuild
$(libice)-check: $($(libice)-prefix)/.pkgcheck
$(libice)-install: $($(libice)-prefix)/.pkginstall
$(libice)-modulefile: $($(libice)-modulefile)
$(libice)-clean:
	rm -rf $($(libice)-modulefile)
	rm -rf $($(libice)-prefix)
	rm -rf $($(libice)-srcdir)
	rm -rf $($(libice)-src)
$(libice): $(libice)-src $(libice)-unpack $(libice)-patch $(libice)-build $(libice)-check $(libice)-install $(libice)-modulefile
