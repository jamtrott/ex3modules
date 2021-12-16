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
# libxdmcp-1.1.3

libxdmcp-version = 1.1.3
libxdmcp = libxdmcp-$(libxdmcp-version)
$(libxdmcp)-description = X Display Manager Control Protocol library
$(libxdmcp)-url = https://x.org/
$(libxdmcp)-srcurl = https://www.x.org/pub/individual/lib/libXdmcp-$(libxdmcp-version).tar.bz2
$(libxdmcp)-src = $(pkgsrcdir)/libXdmcp-$(libxdmcp-version).tar.bz2
$(libxdmcp)-srcdir = $(pkgsrcdir)/libXdmcp-$(libxdmcp-version)
$(libxdmcp)-builddeps = $(xorgproto) $(xorg-util-macros)
$(libxdmcp)-prereqs =
$(libxdmcp)-modulefile = $(modulefilesdir)/$(libxdmcp)
$(libxdmcp)-prefix = $(pkgdir)/$(libxdmcp)

$($(libxdmcp)-src): $(dir $($(libxdmcp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxdmcp)-srcurl)

$($(libxdmcp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxdmcp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxdmcp)-prefix)/.pkgunpack: $($(libxdmcp)-src) $($(libxdmcp)-srcdir)/.markerfile $($(libxdmcp)-prefix)/.markerfile $$(foreach dep,$$($(libxdmcp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxdmcp)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxdmcp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdmcp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdmcp)-prefix)/.pkgunpack
	@touch $@

$($(libxdmcp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdmcp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdmcp)-prefix)/.pkgpatch
	cd $($(libxdmcp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxdmcp)-builddeps) && \
		./configure --prefix=$($(libxdmcp)-prefix) && \
		$(MAKE) MAKEFLAGS=
	@touch $@

$($(libxdmcp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdmcp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdmcp)-prefix)/.pkgbuild
	cd $($(libxdmcp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxdmcp)-builddeps) && \
		$(MAKE) MAKEFLAGS= check
	@touch $@

$($(libxdmcp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxdmcp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxdmcp)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(libxdmcp)-prefix) -C $($(libxdmcp)-srcdir) install
	@touch $@

$($(libxdmcp)-modulefile): $(modulefilesdir)/.markerfile $($(libxdmcp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxdmcp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxdmcp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxdmcp)-description)\"" >>$@
	echo "module-whatis \"$($(libxdmcp)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxdmcp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXDMCP_ROOT $($(libxdmcp)-prefix)" >>$@
	echo "setenv LIBXDMCP_INCDIR $($(libxdmcp)-prefix)/include" >>$@
	echo "setenv LIBXDMCP_INCLUDEDIR $($(libxdmcp)-prefix)/include" >>$@
	echo "setenv LIBXDMCP_LIBDIR $($(libxdmcp)-prefix)/lib" >>$@
	echo "setenv LIBXDMCP_LIBRARYDIR $($(libxdmcp)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxdmcp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxdmcp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxdmcp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxdmcp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxdmcp)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxdmcp)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(libxdmcp)\"" >>$@

$(libxdmcp)-src: $($(libxdmcp)-src)
$(libxdmcp)-unpack: $($(libxdmcp)-prefix)/.pkgunpack
$(libxdmcp)-patch: $($(libxdmcp)-prefix)/.pkgpatch
$(libxdmcp)-build: $($(libxdmcp)-prefix)/.pkgbuild
$(libxdmcp)-check: $($(libxdmcp)-prefix)/.pkgcheck
$(libxdmcp)-install: $($(libxdmcp)-prefix)/.pkginstall
$(libxdmcp)-modulefile: $($(libxdmcp)-modulefile)
$(libxdmcp)-clean:
	rm -rf $($(libxdmcp)-modulefile)
	rm -rf $($(libxdmcp)-prefix)
	rm -rf $($(libxdmcp)-srcdir)
	rm -rf $($(libxdmcp)-src)
$(libxdmcp): $(libxdmcp)-src $(libxdmcp)-unpack $(libxdmcp)-patch $(libxdmcp)-build $(libxdmcp)-check $(libxdmcp)-install $(libxdmcp)-modulefile
