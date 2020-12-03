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
# libxext-1.3.4

libxext-version = 1.3.4
libxext = libxext-$(libxext-version)
$(libxext)-description = X Window System libraries
$(libxext)-url = https://x.org/
$(libxext)-srcurl = https://x.org/pub/individual/lib/libXext-$(libxext-version).tar.bz2
$(libxext)-src = $(pkgsrcdir)/$(notdir $($(libxext)-srcurl))
$(libxext)-srcdir = $(pkgsrcdir)/libXext-$(libxext-version)
$(libxext)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libxext)-prereqs = $(fontconfig) $(libxcb) $(util-linux)
$(libxext)-modulefile = $(modulefilesdir)/$(libxext)
$(libxext)-prefix = $(pkgdir)/$(libxext)

$($(libxext)-src): $(dir $($(libxext)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxext)-srcurl)

$($(libxext)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxext)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxext)-prefix)/.pkgunpack: $($(libxext)-src) $($(libxext)-srcdir)/.markerfile $($(libxext)-prefix)/.markerfile
	tar -C $($(libxext)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxext)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxext)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxext)-prefix)/.pkgunpack
	@touch $@

$($(libxext)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxext)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxext)-prefix)/.pkgpatch
	cd $($(libxext)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxext)-builddeps) && \
		./configure --prefix=$($(libxext)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxext)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxext)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxext)-prefix)/.pkgbuild
	cd $($(libxext)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxext)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxext)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxext)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxext)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxext)-srcdir) install
	@touch $@

$($(libxext)-modulefile): $(modulefilesdir)/.markerfile $($(libxext)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxext)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxext)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxext)-description)\"" >>$@
	echo "module-whatis \"$($(libxext)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxext)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXEXT_ROOT $($(libxext)-prefix)" >>$@
	echo "setenv LIBXEXT_INCDIR $($(libxext)-prefix)/include" >>$@
	echo "setenv LIBXEXT_INCLUDEDIR $($(libxext)-prefix)/include" >>$@
	echo "setenv LIBXEXT_LIBDIR $($(libxext)-prefix)/lib" >>$@
	echo "setenv LIBXEXT_LIBRARYDIR $($(libxext)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxext)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxext)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxext)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxext)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxext)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxext)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxext)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxext)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxext)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxext)\"" >>$@

$(libxext)-src: $($(libxext)-src)
$(libxext)-unpack: $($(libxext)-prefix)/.pkgunpack
$(libxext)-patch: $($(libxext)-prefix)/.pkgpatch
$(libxext)-build: $($(libxext)-prefix)/.pkgbuild
$(libxext)-check: $($(libxext)-prefix)/.pkgcheck
$(libxext)-install: $($(libxext)-prefix)/.pkginstall
$(libxext)-modulefile: $($(libxext)-modulefile)
$(libxext)-clean:
	rm -rf $($(libxext)-modulefile)
	rm -rf $($(libxext)-prefix)
	rm -rf $($(libxext)-srcdir)
	rm -rf $($(libxext)-src)
$(libxext): $(libxext)-src $(libxext)-unpack $(libxext)-patch $(libxext)-build $(libxext)-check $(libxext)-install $(libxext)-modulefile
