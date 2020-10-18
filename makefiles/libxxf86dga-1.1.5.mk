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
# libxxf86dga-1.1.5

libxxf86dga-version = 1.1.5
libxxf86dga = libxxf86dga-$(libxxf86dga-version)
$(libxxf86dga)-description = X Window System libraries
$(libxxf86dga)-url = https://x.org/
$(libxxf86dga)-srcurl = https://x.org/pub/individual/lib/libXxf86dga-$(libxxf86dga-version).tar.bz2
$(libxxf86dga)-src = $(pkgsrcdir)/$(notdir $($(libxxf86dga)-srcurl))
$(libxxf86dga)-srcdir = $(pkgsrcdir)/libXxf86dga-$(libxxf86dga-version)
$(libxxf86dga)-builddeps = $(libxcb) $(libx11) $(libxext) $(xorg-util-macros)
$(libxxf86dga)-prereqs = $(libxcb) $(libx11) $(libxext)
$(libxxf86dga)-modulefile = $(modulefilesdir)/$(libxxf86dga)
$(libxxf86dga)-prefix = $(pkgdir)/$(libxxf86dga)

$($(libxxf86dga)-src): $(dir $($(libxxf86dga)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxxf86dga)-srcurl)

$($(libxxf86dga)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxxf86dga)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxxf86dga)-prefix)/.pkgunpack: $($(libxxf86dga)-src) $($(libxxf86dga)-srcdir)/.markerfile $($(libxxf86dga)-prefix)/.markerfile
	tar -C $($(libxxf86dga)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxxf86dga)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86dga)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86dga)-prefix)/.pkgunpack
	@touch $@

$($(libxxf86dga)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86dga)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86dga)-prefix)/.pkgpatch
	cd $($(libxxf86dga)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxxf86dga)-builddeps) && \
		./configure --prefix=$($(libxxf86dga)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxxf86dga)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86dga)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86dga)-prefix)/.pkgbuild
	cd $($(libxxf86dga)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxxf86dga)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxxf86dga)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86dga)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86dga)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxxf86dga)-srcdir) install
	@touch $@

$($(libxxf86dga)-modulefile): $(modulefilesdir)/.markerfile $($(libxxf86dga)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxxf86dga)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxxf86dga)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxxf86dga)-description)\"" >>$@
	echo "module-whatis \"$($(libxxf86dga)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxxf86dga)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXXF86DGA_ROOT $($(libxxf86dga)-prefix)" >>$@
	echo "setenv LIBXXF86DGA_INCDIR $($(libxxf86dga)-prefix)/include" >>$@
	echo "setenv LIBXXF86DGA_INCLUDEDIR $($(libxxf86dga)-prefix)/include" >>$@
	echo "setenv LIBXXF86DGA_LIBDIR $($(libxxf86dga)-prefix)/lib" >>$@
	echo "setenv LIBXXF86DGA_LIBRARYDIR $($(libxxf86dga)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxxf86dga)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxxf86dga)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxxf86dga)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxxf86dga)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxxf86dga)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxxf86dga)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxxf86dga)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxxf86dga)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxxf86dga)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxxf86dga)\"" >>$@

$(libxxf86dga)-src: $($(libxxf86dga)-src)
$(libxxf86dga)-unpack: $($(libxxf86dga)-prefix)/.pkgunpack
$(libxxf86dga)-patch: $($(libxxf86dga)-prefix)/.pkgpatch
$(libxxf86dga)-build: $($(libxxf86dga)-prefix)/.pkgbuild
$(libxxf86dga)-check: $($(libxxf86dga)-prefix)/.pkgcheck
$(libxxf86dga)-install: $($(libxxf86dga)-prefix)/.pkginstall
$(libxxf86dga)-modulefile: $($(libxxf86dga)-modulefile)
$(libxxf86dga)-clean:
	rm -rf $($(libxxf86dga)-modulefile)
	rm -rf $($(libxxf86dga)-prefix)
	rm -rf $($(libxxf86dga)-srcdir)
	rm -rf $($(libxxf86dga)-src)
$(libxxf86dga): $(libxxf86dga)-src $(libxxf86dga)-unpack $(libxxf86dga)-patch $(libxxf86dga)-build $(libxxf86dga)-check $(libxxf86dga)-install $(libxxf86dga)-modulefile
