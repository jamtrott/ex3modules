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
# libxrender-0.9.10

libxrender-version = 0.9.10
libxrender = libxrender-$(libxrender-version)
$(libxrender)-description = X Window System libraries
$(libxrender)-url = https://x.org/
$(libxrender)-srcurl = https://x.org/pub/individual/lib/libXrender-$(libxrender-version).tar.bz2
$(libxrender)-src = $(pkgsrcdir)/$(notdir $($(libxrender)-srcurl))
$(libxrender)-srcdir = $(pkgsrcdir)/libXrender-$(libxrender-version)
$(libxrender)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libxrender)-prereqs = $(fontconfig) $(libxcb)
$(libxrender)-modulefile = $(modulefilesdir)/$(libxrender)
$(libxrender)-prefix = $(pkgdir)/$(libxrender)

$($(libxrender)-src): $(dir $($(libxrender)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxrender)-srcurl)

$($(libxrender)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxrender)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxrender)-prefix)/.pkgunpack: $($(libxrender)-src) $($(libxrender)-srcdir)/.markerfile $($(libxrender)-prefix)/.markerfile $$(foreach dep,$$($(libxrender)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxrender)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxrender)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrender)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrender)-prefix)/.pkgunpack
	@touch $@

$($(libxrender)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrender)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrender)-prefix)/.pkgpatch
	cd $($(libxrender)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxrender)-builddeps) && \
		./configure --prefix=$($(libxrender)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxrender)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrender)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrender)-prefix)/.pkgbuild
	cd $($(libxrender)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxrender)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxrender)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxrender)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxrender)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxrender)-srcdir) install
	@touch $@

$($(libxrender)-modulefile): $(modulefilesdir)/.markerfile $($(libxrender)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxrender)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxrender)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxrender)-description)\"" >>$@
	echo "module-whatis \"$($(libxrender)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxrender)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXRENDER_ROOT $($(libxrender)-prefix)" >>$@
	echo "setenv LIBXRENDER_INCDIR $($(libxrender)-prefix)/include" >>$@
	echo "setenv LIBXRENDER_INCLUDEDIR $($(libxrender)-prefix)/include" >>$@
	echo "setenv LIBXRENDER_LIBDIR $($(libxrender)-prefix)/lib" >>$@
	echo "setenv LIBXRENDER_LIBRARYDIR $($(libxrender)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxrender)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxrender)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxrender)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxrender)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxrender)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxrender)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxrender)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxrender)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxrender)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxrender)\"" >>$@

$(libxrender)-src: $($(libxrender)-src)
$(libxrender)-unpack: $($(libxrender)-prefix)/.pkgunpack
$(libxrender)-patch: $($(libxrender)-prefix)/.pkgpatch
$(libxrender)-build: $($(libxrender)-prefix)/.pkgbuild
$(libxrender)-check: $($(libxrender)-prefix)/.pkgcheck
$(libxrender)-install: $($(libxrender)-prefix)/.pkginstall
$(libxrender)-modulefile: $($(libxrender)-modulefile)
$(libxrender)-clean:
	rm -rf $($(libxrender)-modulefile)
	rm -rf $($(libxrender)-prefix)
	rm -rf $($(libxrender)-srcdir)
	rm -rf $($(libxrender)-src)
$(libxrender): $(libxrender)-src $(libxrender)-unpack $(libxrender)-patch $(libxrender)-build $(libxrender)-check $(libxrender)-install $(libxrender)-modulefile
