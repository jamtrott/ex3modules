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
# libxvmc-1.0.12

libxvmc-version = 1.0.12
libxvmc = libxvmc-$(libxvmc-version)
$(libxvmc)-description = X Window System libraries
$(libxvmc)-url = https://x.org/
$(libxvmc)-srcurl = https://x.org/pub/individual/lib/libXvMC-$(libxvmc-version).tar.bz2
$(libxvmc)-src = $(pkgsrcdir)/$(notdir $($(libxvmc)-srcurl))
$(libxvmc)-srcdir = $(pkgsrcdir)/libXvMC-$(libxvmc-version)
$(libxvmc)-builddeps = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(libxv) $(util-linux) $(xorg-util-macros)
$(libxvmc)-prereqs = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(libxv)
$(libxvmc)-modulefile = $(modulefilesdir)/$(libxvmc)
$(libxvmc)-prefix = $(pkgdir)/$(libxvmc)

$($(libxvmc)-src): $(dir $($(libxvmc)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxvmc)-srcurl)

$($(libxvmc)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxvmc)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxvmc)-prefix)/.pkgunpack: $($(libxvmc)-src) $($(libxvmc)-srcdir)/.markerfile $($(libxvmc)-prefix)/.markerfile
	tar -C $($(libxvmc)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxvmc)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxvmc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxvmc)-prefix)/.pkgunpack
	@touch $@

$($(libxvmc)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxvmc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxvmc)-prefix)/.pkgpatch
	cd $($(libxvmc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxvmc)-builddeps) && \
		./configure --prefix=$($(libxvmc)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxvmc)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxvmc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxvmc)-prefix)/.pkgbuild
	cd $($(libxvmc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxvmc)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxvmc)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxvmc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxvmc)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxvmc)-srcdir) install
	@touch $@

$($(libxvmc)-modulefile): $(modulefilesdir)/.markerfile $($(libxvmc)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxvmc)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxvmc)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxvmc)-description)\"" >>$@
	echo "module-whatis \"$($(libxvmc)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxvmc)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXVMC_ROOT $($(libxvmc)-prefix)" >>$@
	echo "setenv LIBXVMC_INCDIR $($(libxvmc)-prefix)/include" >>$@
	echo "setenv LIBXVMC_INCLUDEDIR $($(libxvmc)-prefix)/include" >>$@
	echo "setenv LIBXVMC_LIBDIR $($(libxvmc)-prefix)/lib" >>$@
	echo "setenv LIBXVMC_LIBRARYDIR $($(libxvmc)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxvmc)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxvmc)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxvmc)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxvmc)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxvmc)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxvmc)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxvmc)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxvmc)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxvmc)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxvmc)\"" >>$@

$(libxvmc)-src: $($(libxvmc)-src)
$(libxvmc)-unpack: $($(libxvmc)-prefix)/.pkgunpack
$(libxvmc)-patch: $($(libxvmc)-prefix)/.pkgpatch
$(libxvmc)-build: $($(libxvmc)-prefix)/.pkgbuild
$(libxvmc)-check: $($(libxvmc)-prefix)/.pkgcheck
$(libxvmc)-install: $($(libxvmc)-prefix)/.pkginstall
$(libxvmc)-modulefile: $($(libxvmc)-modulefile)
$(libxvmc)-clean:
	rm -rf $($(libxvmc)-modulefile)
	rm -rf $($(libxvmc)-prefix)
	rm -rf $($(libxvmc)-srcdir)
	rm -rf $($(libxvmc)-src)
$(libxvmc): $(libxvmc)-src $(libxvmc)-unpack $(libxvmc)-patch $(libxvmc)-build $(libxvmc)-check $(libxvmc)-install $(libxvmc)-modulefile
