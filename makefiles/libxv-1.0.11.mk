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
# libxv-1.0.11

libxv-version = 1.0.11
libxv = libxv-$(libxv-version)
$(libxv)-description = X Window System libraries
$(libxv)-url = https://x.org/
$(libxv)-srcurl = https://x.org/pub/individual/lib/libXv-$(libxv-version).tar.bz2
$(libxv)-src = $(pkgsrcdir)/$(notdir $($(libxv)-srcurl))
$(libxv)-srcdir = $(pkgsrcdir)/libXv-$(libxv-version)
$(libxv)-builddeps = $(fontconfig) $(libxcb) $(libx11) $(libxext) $(util-linux) $(xorg-util-macros)
$(libxv)-prereqs = $(fontconfig) $(libxcb) $(libx11) $(libxext)
$(libxv)-modulefile = $(modulefilesdir)/$(libxv)
$(libxv)-prefix = $(pkgdir)/$(libxv)

$($(libxv)-src): $(dir $($(libxv)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxv)-srcurl)

$($(libxv)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxv)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxv)-prefix)/.pkgunpack: $($(libxv)-src) $($(libxv)-srcdir)/.markerfile $($(libxv)-prefix)/.markerfile
	tar -C $($(libxv)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxv)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxv)-prefix)/.pkgunpack
	@touch $@

$($(libxv)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxv)-prefix)/.pkgpatch
	cd $($(libxv)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxv)-builddeps) && \
		./configure --prefix=$($(libxv)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxv)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxv)-prefix)/.pkgbuild
	cd $($(libxv)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxv)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxv)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxv)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxv)-srcdir) install
	@touch $@

$($(libxv)-modulefile): $(modulefilesdir)/.markerfile $($(libxv)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxv)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxv)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxv)-description)\"" >>$@
	echo "module-whatis \"$($(libxv)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxv)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXV_ROOT $($(libxv)-prefix)" >>$@
	echo "setenv LIBXV_INCDIR $($(libxv)-prefix)/include" >>$@
	echo "setenv LIBXV_INCLUDEDIR $($(libxv)-prefix)/include" >>$@
	echo "setenv LIBXV_LIBDIR $($(libxv)-prefix)/lib" >>$@
	echo "setenv LIBXV_LIBRARYDIR $($(libxv)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxv)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxv)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxv)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxv)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxv)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxv)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxv)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxv)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxv)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxv)\"" >>$@

$(libxv)-src: $($(libxv)-src)
$(libxv)-unpack: $($(libxv)-prefix)/.pkgunpack
$(libxv)-patch: $($(libxv)-prefix)/.pkgpatch
$(libxv)-build: $($(libxv)-prefix)/.pkgbuild
$(libxv)-check: $($(libxv)-prefix)/.pkgcheck
$(libxv)-install: $($(libxv)-prefix)/.pkginstall
$(libxv)-modulefile: $($(libxv)-modulefile)
$(libxv)-clean:
	rm -rf $($(libxv)-modulefile)
	rm -rf $($(libxv)-prefix)
	rm -rf $($(libxv)-srcdir)
	rm -rf $($(libxv)-src)
$(libxv): $(libxv)-src $(libxv)-unpack $(libxv)-patch $(libxv)-build $(libxv)-check $(libxv)-install $(libxv)-modulefile
