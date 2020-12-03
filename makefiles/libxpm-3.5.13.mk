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
# libxpm-3.5.13

libxpm-version = 3.5.13
libxpm = libxpm-$(libxpm-version)
$(libxpm)-description = X Window System libraries
$(libxpm)-url = https://x.org/
$(libxpm)-srcurl = https://x.org/pub/individual/lib/libXpm-$(libxpm-version).tar.bz2
$(libxpm)-src = $(pkgsrcdir)/$(notdir $($(libxpm)-srcurl))
$(libxpm)-srcdir = $(pkgsrcdir)/libXpm-$(libxpm-version)
$(libxpm)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libxpm)-prereqs = $(fontconfig) $(libxcb)
$(libxpm)-modulefile = $(modulefilesdir)/$(libxpm)
$(libxpm)-prefix = $(pkgdir)/$(libxpm)

$($(libxpm)-src): $(dir $($(libxpm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxpm)-srcurl)

$($(libxpm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxpm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxpm)-prefix)/.pkgunpack: $($(libxpm)-src) $($(libxpm)-srcdir)/.markerfile $($(libxpm)-prefix)/.markerfile
	tar -C $($(libxpm)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxpm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxpm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxpm)-prefix)/.pkgunpack
	@touch $@

$($(libxpm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxpm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxpm)-prefix)/.pkgpatch
	cd $($(libxpm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxpm)-builddeps) && \
		./configure --prefix=$($(libxpm)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxpm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxpm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxpm)-prefix)/.pkgbuild
	cd $($(libxpm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxpm)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxpm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxpm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxpm)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxpm)-srcdir) install
	@touch $@

$($(libxpm)-modulefile): $(modulefilesdir)/.markerfile $($(libxpm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxpm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxpm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxpm)-description)\"" >>$@
	echo "module-whatis \"$($(libxpm)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxpm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXPM_ROOT $($(libxpm)-prefix)" >>$@
	echo "setenv LIBXPM_INCDIR $($(libxpm)-prefix)/include" >>$@
	echo "setenv LIBXPM_INCLUDEDIR $($(libxpm)-prefix)/include" >>$@
	echo "setenv LIBXPM_LIBDIR $($(libxpm)-prefix)/lib" >>$@
	echo "setenv LIBXPM_LIBRARYDIR $($(libxpm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxpm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxpm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxpm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxpm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxpm)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxpm)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxpm)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxpm)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxpm)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxpm)\"" >>$@

$(libxpm)-src: $($(libxpm)-src)
$(libxpm)-unpack: $($(libxpm)-prefix)/.pkgunpack
$(libxpm)-patch: $($(libxpm)-prefix)/.pkgpatch
$(libxpm)-build: $($(libxpm)-prefix)/.pkgbuild
$(libxpm)-check: $($(libxpm)-prefix)/.pkgcheck
$(libxpm)-install: $($(libxpm)-prefix)/.pkginstall
$(libxpm)-modulefile: $($(libxpm)-modulefile)
$(libxpm)-clean:
	rm -rf $($(libxpm)-modulefile)
	rm -rf $($(libxpm)-prefix)
	rm -rf $($(libxpm)-srcdir)
	rm -rf $($(libxpm)-src)
$(libxpm): $(libxpm)-src $(libxpm)-unpack $(libxpm)-patch $(libxpm)-build $(libxpm)-check $(libxpm)-install $(libxpm)-modulefile
