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
# libxdamage-1.1.5

libxdamage-version = 1.1.5
libxdamage = libxdamage-$(libxdamage-version)
$(libxdamage)-description = X Window System libraries
$(libxdamage)-url = https://x.org/
$(libxdamage)-srcurl = https://x.org/pub/individual/lib/libXdamage-$(libxdamage-version).tar.bz2
$(libxdamage)-src = $(pkgsrcdir)/$(notdir $($(libxdamage)-srcurl))
$(libxdamage)-srcdir = $(pkgsrcdir)/libXdamage-$(libxdamage-version)
$(libxdamage)-builddeps = $(fontconfig) $(libxcb) $(libxfixes) $(libx11) $(util-linux) $(xorg-util-macros)
$(libxdamage)-prereqs = $(fontconfig) $(libxcb) $(libxfixes) $(libx11)
$(libxdamage)-modulefile = $(modulefilesdir)/$(libxdamage)
$(libxdamage)-prefix = $(pkgdir)/$(libxdamage)

$($(libxdamage)-src): $(dir $($(libxdamage)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxdamage)-srcurl)

$($(libxdamage)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxdamage)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxdamage)-prefix)/.pkgunpack: $($(libxdamage)-src) $($(libxdamage)-srcdir)/.markerfile $($(libxdamage)-prefix)/.markerfile
	tar -C $($(libxdamage)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxdamage)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdamage)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdamage)-prefix)/.pkgunpack
	@touch $@

$($(libxdamage)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdamage)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdamage)-prefix)/.pkgpatch
	cd $($(libxdamage)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxdamage)-builddeps) && \
		./configure --prefix=$($(libxdamage)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxdamage)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdamage)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdamage)-prefix)/.pkgbuild
	cd $($(libxdamage)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxdamage)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxdamage)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdamage)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdamage)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxdamage)-srcdir) install
	@touch $@

$($(libxdamage)-modulefile): $(modulefilesdir)/.markerfile $($(libxdamage)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxdamage)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxdamage)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxdamage)-description)\"" >>$@
	echo "module-whatis \"$($(libxdamage)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxdamage)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXDAMAGE_ROOT $($(libxdamage)-prefix)" >>$@
	echo "setenv LIBXDAMAGE_INCDIR $($(libxdamage)-prefix)/include" >>$@
	echo "setenv LIBXDAMAGE_INCLUDEDIR $($(libxdamage)-prefix)/include" >>$@
	echo "setenv LIBXDAMAGE_LIBDIR $($(libxdamage)-prefix)/lib" >>$@
	echo "setenv LIBXDAMAGE_LIBRARYDIR $($(libxdamage)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxdamage)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxdamage)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxdamage)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxdamage)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxdamage)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxdamage)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxdamage)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxdamage)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxdamage)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxdamage)\"" >>$@

$(libxdamage)-src: $($(libxdamage)-src)
$(libxdamage)-unpack: $($(libxdamage)-prefix)/.pkgunpack
$(libxdamage)-patch: $($(libxdamage)-prefix)/.pkgpatch
$(libxdamage)-build: $($(libxdamage)-prefix)/.pkgbuild
$(libxdamage)-check: $($(libxdamage)-prefix)/.pkgcheck
$(libxdamage)-install: $($(libxdamage)-prefix)/.pkginstall
$(libxdamage)-modulefile: $($(libxdamage)-modulefile)
$(libxdamage)-clean:
	rm -rf $($(libxdamage)-modulefile)
	rm -rf $($(libxdamage)-prefix)
	rm -rf $($(libxdamage)-srcdir)
	rm -rf $($(libxdamage)-src)
$(libxdamage): $(libxdamage)-src $(libxdamage)-unpack $(libxdamage)-patch $(libxdamage)-build $(libxdamage)-check $(libxdamage)-install $(libxdamage)-modulefile
