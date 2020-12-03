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
# libxi-1.7.10

libxi-version = 1.7.10
libxi = libxi-$(libxi-version)
$(libxi)-description = X Window System libraries
$(libxi)-url = https://x.org/
$(libxi)-srcurl = https://x.org/pub/individual/lib/libXi-$(libxi-version).tar.bz2
$(libxi)-src = $(pkgsrcdir)/$(notdir $($(libxi)-srcurl))
$(libxi)-srcdir = $(pkgsrcdir)/libXi-$(libxi-version)
$(libxi)-builddeps = $(fontconfig) $(libxcb) $(libxext) $(libxfixes) $(util-linux) $(xorg-util-macros)
$(libxi)-prereqs = $(fontconfig) $(libxcb) $(libxext) $(libxfixes)
$(libxi)-modulefile = $(modulefilesdir)/$(libxi)
$(libxi)-prefix = $(pkgdir)/$(libxi)

$($(libxi)-src): $(dir $($(libxi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxi)-srcurl)

$($(libxi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxi)-prefix)/.pkgunpack: $($(libxi)-src) $($(libxi)-srcdir)/.markerfile $($(libxi)-prefix)/.markerfile
	tar -C $($(libxi)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxi)-prefix)/.pkgunpack
	@touch $@

$($(libxi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxi)-prefix)/.pkgpatch
	cd $($(libxi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxi)-builddeps) && \
		./configure --prefix=$($(libxi)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxi)-prefix)/.pkgbuild
	cd $($(libxi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxi)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxi)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxi)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxi)-srcdir) install
	@touch $@

$($(libxi)-modulefile): $(modulefilesdir)/.markerfile $($(libxi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxi)-description)\"" >>$@
	echo "module-whatis \"$($(libxi)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXI_ROOT $($(libxi)-prefix)" >>$@
	echo "setenv LIBXI_INCDIR $($(libxi)-prefix)/include" >>$@
	echo "setenv LIBXI_INCLUDEDIR $($(libxi)-prefix)/include" >>$@
	echo "setenv LIBXI_LIBDIR $($(libxi)-prefix)/lib" >>$@
	echo "setenv LIBXI_LIBRARYDIR $($(libxi)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxi)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxi)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxi)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxi)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxi)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxi)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxi)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxi)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxi)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxi)\"" >>$@

$(libxi)-src: $($(libxi)-src)
$(libxi)-unpack: $($(libxi)-prefix)/.pkgunpack
$(libxi)-patch: $($(libxi)-prefix)/.pkgpatch
$(libxi)-build: $($(libxi)-prefix)/.pkgbuild
$(libxi)-check: $($(libxi)-prefix)/.pkgcheck
$(libxi)-install: $($(libxi)-prefix)/.pkginstall
$(libxi)-modulefile: $($(libxi)-modulefile)
$(libxi)-clean:
	rm -rf $($(libxi)-modulefile)
	rm -rf $($(libxi)-prefix)
	rm -rf $($(libxi)-srcdir)
	rm -rf $($(libxi)-src)
$(libxi): $(libxi)-src $(libxi)-unpack $(libxi)-patch $(libxi)-build $(libxi)-check $(libxi)-install $(libxi)-modulefile
