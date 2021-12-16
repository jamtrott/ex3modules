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
# libxfixes-5.0.3

libxfixes-version = 5.0.3
libxfixes = libxfixes-$(libxfixes-version)
$(libxfixes)-description = X Window System libraries
$(libxfixes)-url = https://x.org/
$(libxfixes)-srcurl = https://x.org/pub/individual/lib/libXfixes-$(libxfixes-version).tar.bz2
$(libxfixes)-src = $(pkgsrcdir)/$(notdir $($(libxfixes)-srcurl))
$(libxfixes)-srcdir = $(pkgsrcdir)/libXfixes-$(libxfixes-version)
$(libxfixes)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libxfixes)-prereqs = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libxfixes)-modulefile = $(modulefilesdir)/$(libxfixes)
$(libxfixes)-prefix = $(pkgdir)/$(libxfixes)

$($(libxfixes)-src): $(dir $($(libxfixes)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxfixes)-srcurl)

$($(libxfixes)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxfixes)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxfixes)-prefix)/.pkgunpack: $($(libxfixes)-src) $($(libxfixes)-srcdir)/.markerfile $($(libxfixes)-prefix)/.markerfile $$(foreach dep,$$($(libxfixes)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxfixes)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxfixes)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfixes)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfixes)-prefix)/.pkgunpack
	@touch $@

$($(libxfixes)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfixes)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfixes)-prefix)/.pkgpatch
	cd $($(libxfixes)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxfixes)-builddeps) && \
		./configure --prefix=$($(libxfixes)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxfixes)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfixes)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfixes)-prefix)/.pkgbuild
	cd $($(libxfixes)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxfixes)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxfixes)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxfixes)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxfixes)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxfixes)-srcdir) install
	@touch $@

$($(libxfixes)-modulefile): $(modulefilesdir)/.markerfile $($(libxfixes)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxfixes)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxfixes)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxfixes)-description)\"" >>$@
	echo "module-whatis \"$($(libxfixes)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxfixes)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXFIXES_ROOT $($(libxfixes)-prefix)" >>$@
	echo "setenv LIBXFIXES_INCDIR $($(libxfixes)-prefix)/include" >>$@
	echo "setenv LIBXFIXES_INCLUDEDIR $($(libxfixes)-prefix)/include" >>$@
	echo "setenv LIBXFIXES_LIBDIR $($(libxfixes)-prefix)/lib" >>$@
	echo "setenv LIBXFIXES_LIBRARYDIR $($(libxfixes)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxfixes)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxfixes)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxfixes)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxfixes)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxfixes)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxfixes)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxfixes)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxfixes)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxfixes)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxfixes)\"" >>$@

$(libxfixes)-src: $($(libxfixes)-src)
$(libxfixes)-unpack: $($(libxfixes)-prefix)/.pkgunpack
$(libxfixes)-patch: $($(libxfixes)-prefix)/.pkgpatch
$(libxfixes)-build: $($(libxfixes)-prefix)/.pkgbuild
$(libxfixes)-check: $($(libxfixes)-prefix)/.pkgcheck
$(libxfixes)-install: $($(libxfixes)-prefix)/.pkginstall
$(libxfixes)-modulefile: $($(libxfixes)-modulefile)
$(libxfixes)-clean:
	rm -rf $($(libxfixes)-modulefile)
	rm -rf $($(libxfixes)-prefix)
	rm -rf $($(libxfixes)-srcdir)
	rm -rf $($(libxfixes)-src)
$(libxfixes): $(libxfixes)-src $(libxfixes)-unpack $(libxfixes)-patch $(libxfixes)-build $(libxfixes)-check $(libxfixes)-install $(libxfixes)-modulefile
