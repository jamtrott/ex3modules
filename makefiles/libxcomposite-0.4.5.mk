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
# libxcomposite-0.4.5

libxcomposite-version = 0.4.5
libxcomposite = libxcomposite-$(libxcomposite-version)
$(libxcomposite)-description = X Window System libraries
$(libxcomposite)-url = https://x.org/
$(libxcomposite)-srcurl = https://x.org/pub/individual/lib/libXcomposite-$(libxcomposite-version).tar.bz2
$(libxcomposite)-src = $(pkgsrcdir)/$(notdir $($(libxcomposite)-srcurl))
$(libxcomposite)-srcdir = $(pkgsrcdir)/libXcomposite-$(libxcomposite-version)
$(libxcomposite)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros) $(libxfixes)
$(libxcomposite)-prereqs = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros) $(libxfixes)
$(libxcomposite)-modulefile = $(modulefilesdir)/$(libxcomposite)
$(libxcomposite)-prefix = $(pkgdir)/$(libxcomposite)

$($(libxcomposite)-src): $(dir $($(libxcomposite)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxcomposite)-srcurl)

$($(libxcomposite)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxcomposite)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxcomposite)-prefix)/.pkgunpack: $($(libxcomposite)-src) $($(libxcomposite)-srcdir)/.markerfile $($(libxcomposite)-prefix)/.markerfile
	tar -C $($(libxcomposite)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxcomposite)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcomposite)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcomposite)-prefix)/.pkgunpack
	@touch $@

$($(libxcomposite)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcomposite)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcomposite)-prefix)/.pkgpatch
	cd $($(libxcomposite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxcomposite)-builddeps) && \
		./configure --prefix=$($(libxcomposite)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxcomposite)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcomposite)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcomposite)-prefix)/.pkgbuild
	cd $($(libxcomposite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxcomposite)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxcomposite)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxcomposite)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxcomposite)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxcomposite)-srcdir) install
	@touch $@

$($(libxcomposite)-modulefile): $(modulefilesdir)/.markerfile $($(libxcomposite)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxcomposite)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxcomposite)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxcomposite)-description)\"" >>$@
	echo "module-whatis \"$($(libxcomposite)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxcomposite)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXCOMPOSITE_ROOT $($(libxcomposite)-prefix)" >>$@
	echo "setenv LIBXCOMPOSITE_INCDIR $($(libxcomposite)-prefix)/include" >>$@
	echo "setenv LIBXCOMPOSITE_INCLUDEDIR $($(libxcomposite)-prefix)/include" >>$@
	echo "setenv LIBXCOMPOSITE_LIBDIR $($(libxcomposite)-prefix)/lib" >>$@
	echo "setenv LIBXCOMPOSITE_LIBRARYDIR $($(libxcomposite)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxcomposite)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxcomposite)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxcomposite)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxcomposite)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxcomposite)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxcomposite)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxcomposite)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxcomposite)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxcomposite)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxcomposite)\"" >>$@

$(libxcomposite)-src: $($(libxcomposite)-src)
$(libxcomposite)-unpack: $($(libxcomposite)-prefix)/.pkgunpack
$(libxcomposite)-patch: $($(libxcomposite)-prefix)/.pkgpatch
$(libxcomposite)-build: $($(libxcomposite)-prefix)/.pkgbuild
$(libxcomposite)-check: $($(libxcomposite)-prefix)/.pkgcheck
$(libxcomposite)-install: $($(libxcomposite)-prefix)/.pkginstall
$(libxcomposite)-modulefile: $($(libxcomposite)-modulefile)
$(libxcomposite)-clean:
	rm -rf $($(libxcomposite)-modulefile)
	rm -rf $($(libxcomposite)-prefix)
	rm -rf $($(libxcomposite)-srcdir)
	rm -rf $($(libxcomposite)-src)
$(libxcomposite): $(libxcomposite)-src $(libxcomposite)-unpack $(libxcomposite)-patch $(libxcomposite)-build $(libxcomposite)-check $(libxcomposite)-install $(libxcomposite)-modulefile
