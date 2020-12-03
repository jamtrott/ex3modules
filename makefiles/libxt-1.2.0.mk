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
# libxt-1.2.0

libxt-version = 1.2.0
libxt = libxt-$(libxt-version)
$(libxt)-description = X Window System libraries
$(libxt)-url = https://x.org/
$(libxt)-srcurl = https://x.org/pub/individual/lib/libXt-$(libxt-version).tar.bz2
$(libxt)-src = $(pkgsrcdir)/$(notdir $($(libxt)-srcurl))
$(libxt)-srcdir = $(pkgsrcdir)/libXt-$(libxt-version)
$(libxt)-builddeps = $(fontconfig) $(libxcb) $(libsm) $(libice) $(util-linux) $(xorg-util-macros) $(glib)
$(libxt)-prereqs = $(fontconfig) $(libxcb) $(libsm) $(libice) $(util-linux)
$(libxt)-modulefile = $(modulefilesdir)/$(libxt)
$(libxt)-prefix = $(pkgdir)/$(libxt)

$($(libxt)-src): $(dir $($(libxt)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxt)-srcurl)

$($(libxt)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxt)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxt)-prefix)/.pkgunpack: $($(libxt)-src) $($(libxt)-srcdir)/.markerfile $($(libxt)-prefix)/.markerfile
	tar -C $($(libxt)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxt)-prefix)/.pkgunpack
	@touch $@

$($(libxt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxt)-prefix)/.pkgpatch
	cd $($(libxt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxt)-builddeps) && \
		./configure --prefix=$($(libxt)-prefix) --with-appdefaultdir=$($(libxt)-prefix)/etc/X11/app-defaults --disable-static && \
		$(MAKE)
	@touch $@

$($(libxt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxt)-prefix)/.pkgbuild
	cd $($(libxt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxt)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxt)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxt)-srcdir) install
	@touch $@

$($(libxt)-modulefile): $(modulefilesdir)/.markerfile $($(libxt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxt)-description)\"" >>$@
	echo "module-whatis \"$($(libxt)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXT_ROOT $($(libxt)-prefix)" >>$@
	echo "setenv LIBXT_INCDIR $($(libxt)-prefix)/include" >>$@
	echo "setenv LIBXT_INCLUDEDIR $($(libxt)-prefix)/include" >>$@
	echo "setenv LIBXT_LIBDIR $($(libxt)-prefix)/lib" >>$@
	echo "setenv LIBXT_LIBRARYDIR $($(libxt)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxt)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxt)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxt)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxt)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxt)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxt)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxt)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxt)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxt)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxt)\"" >>$@

$(libxt)-src: $($(libxt)-src)
$(libxt)-unpack: $($(libxt)-prefix)/.pkgunpack
$(libxt)-patch: $($(libxt)-prefix)/.pkgpatch
$(libxt)-build: $($(libxt)-prefix)/.pkgbuild
$(libxt)-check: $($(libxt)-prefix)/.pkgcheck
$(libxt)-install: $($(libxt)-prefix)/.pkginstall
$(libxt)-modulefile: $($(libxt)-modulefile)
$(libxt)-clean:
	rm -rf $($(libxt)-modulefile)
	rm -rf $($(libxt)-prefix)
	rm -rf $($(libxt)-srcdir)
	rm -rf $($(libxt)-src)
$(libxt): $(libxt)-src $(libxt)-unpack $(libxt)-patch $(libxt)-build $(libxt)-check $(libxt)-install $(libxt)-modulefile
