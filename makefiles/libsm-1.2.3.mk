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
# libsm-1.2.3

libsm-version = 1.2.3
libsm = libsm-$(libsm-version)
$(libsm)-description = X Window System libraries
$(libsm)-url = https://x.org/
$(libsm)-srcurl = https://x.org/pub/individual/lib/libSM-$(libsm-version).tar.bz2
$(libsm)-src = $(pkgsrcdir)/$(notdir $($(libsm)-srcurl))
$(libsm)-srcdir = $(pkgsrcdir)/libSM-$(libsm-version)
$(libsm)-builddeps = $(fontconfig) $(libxcb) $(xtrans) $(libice) $(util-linux) $(xorg-util-macros)
$(libsm)-prereqs = $(fontconfig) $(libxcb) $(libice) $(util-linux)
$(libsm)-modulefile = $(modulefilesdir)/$(libsm)
$(libsm)-prefix = $(pkgdir)/$(libsm)

$($(libsm)-src): $(dir $($(libsm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libsm)-srcurl)

$($(libsm)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libsm)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libsm)-prefix)/.pkgunpack: $($(libsm)-src) $($(libsm)-srcdir)/.markerfile $($(libsm)-prefix)/.markerfile
	tar -C $($(libsm)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libsm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libsm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libsm)-prefix)/.pkgunpack
	@touch $@

$($(libsm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libsm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libsm)-prefix)/.pkgpatch
	cd $($(libsm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libsm)-builddeps) && \
		./configure --prefix=$($(libsm)-prefix) LIBUUID_CFLAGS="-I$${UTIL_LINUX_INCLUDEDIR}" --disable-static && \
		$(MAKE)
	@touch $@

$($(libsm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libsm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libsm)-prefix)/.pkgbuild
	cd $($(libsm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libsm)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libsm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libsm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libsm)-prefix)/.pkgcheck
	$(MAKE) -C $($(libsm)-srcdir) install
	@touch $@

$($(libsm)-modulefile): $(modulefilesdir)/.markerfile $($(libsm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libsm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libsm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libsm)-description)\"" >>$@
	echo "module-whatis \"$($(libsm)-url)\"" >>$@
	printf "$(foreach prereq,$($(libsm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBSM_ROOT $($(libsm)-prefix)" >>$@
	echo "setenv LIBSM_INCDIR $($(libsm)-prefix)/include" >>$@
	echo "setenv LIBSM_INCLUDEDIR $($(libsm)-prefix)/include" >>$@
	echo "setenv LIBSM_LIBDIR $($(libsm)-prefix)/lib" >>$@
	echo "setenv LIBSM_LIBRARYDIR $($(libsm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libsm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libsm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libsm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libsm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libsm)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libsm)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libsm)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libsm)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libsm)-prefix)/share/info" >>$@
	echo "set MSG \"$(libsm)\"" >>$@

$(libsm)-src: $($(libsm)-src)
$(libsm)-unpack: $($(libsm)-prefix)/.pkgunpack
$(libsm)-patch: $($(libsm)-prefix)/.pkgpatch
$(libsm)-build: $($(libsm)-prefix)/.pkgbuild
$(libsm)-check: $($(libsm)-prefix)/.pkgcheck
$(libsm)-install: $($(libsm)-prefix)/.pkginstall
$(libsm)-modulefile: $($(libsm)-modulefile)
$(libsm)-clean:
	rm -rf $($(libsm)-modulefile)
	rm -rf $($(libsm)-prefix)
	rm -rf $($(libsm)-srcdir)
	rm -rf $($(libsm)-src)
$(libsm): $(libsm)-src $(libsm)-unpack $(libsm)-patch $(libsm)-build $(libsm)-check $(libsm)-install $(libsm)-modulefile
