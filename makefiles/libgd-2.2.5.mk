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
# libgd-2.2.5

libgd-version = 2.2.5
libgd = libgd-$(libgd-version)
$(libgd)-description = Library for the dynamic creation of images by programmers
$(libgd)-url = https://libgd.github.io/
$(libgd)-srcurl = https://github.com/libgd/libgd/releases/download/gd-$(libgd-version)/libgd-$(libgd-version).tar.gz
$(libgd)-src = $(pkgsrcdir)/$(notdir $($(libgd)-srcurl))
$(libgd)-srcdir = $(pkgsrcdir)/$(libgd)
$(libgd)-builddeps = $(libjpeg-turbo) $(libpng) $(libwebp) $(libxpm) $(freetype) $(fontconfig)
$(libgd)-prereqs = $(libjpeg-turbo) $(libpng) $(libwebp) $(libxpm) $(freetype) $(fontconfig)
$(libgd)-modulefile = $(modulefilesdir)/$(libgd)
$(libgd)-prefix = $(pkgdir)/$(libgd)

$($(libgd)-src): $(dir $($(libgd)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libgd)-srcurl)

$($(libgd)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libgd)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libgd)-prefix)/.pkgunpack: $($(libgd)-src) $($(libgd)-srcdir)/.markerfile $($(libgd)-prefix)/.markerfile $$(foreach dep,$$($(libgd)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libgd)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libgd)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgd)-prefix)/.pkgunpack
	@touch $@

$($(libgd)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgd)-prefix)/.pkgpatch
ifeq ($(ARCH),aarch64)
	cd $($(libgd)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgd)-builddeps) && \
		./configure --prefix=$($(libgd)-prefix) CFLAGS="-ffp-contract=off $(CFLAGS)" \
			--with-jpeg=$${LIBJPEG_TURBO_ROOT} && \
		$(MAKE)
else
	cd $($(libgd)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgd)-builddeps) && \
		./configure --prefix=$($(libgd)-prefix) \
			--with-jpeg=$${LIBJPEG_TURBO_ROOT} && \
		$(MAKE)
endif
	@touch $@

$($(libgd)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgd)-prefix)/.pkgbuild
	cd $($(libgd)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgd)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libgd)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgd)-prefix)/.pkgcheck
	$(MAKE) -C $($(libgd)-srcdir) install
	@touch $@

$($(libgd)-modulefile): $(modulefilesdir)/.markerfile $($(libgd)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libgd)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libgd)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libgd)-description)\"" >>$@
	echo "module-whatis \"$($(libgd)-url)\"" >>$@
	printf "$(foreach prereq,$($(libgd)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBGD_ROOT $($(libgd)-prefix)" >>$@
	echo "setenv LIBGD_INCDIR $($(libgd)-prefix)/include" >>$@
	echo "setenv LIBGD_INCLUDEDIR $($(libgd)-prefix)/include" >>$@
	echo "setenv LIBGD_LIBDIR $($(libgd)-prefix)/lib" >>$@
	echo "setenv LIBGD_LIBRARYDIR $($(libgd)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libgd)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libgd)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libgd)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgd)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgd)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libgd)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libgd)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libgd)-prefix)/share/info" >>$@
	echo "set MSG \"$(libgd)\"" >>$@

$(libgd)-src: $($(libgd)-src)
$(libgd)-unpack: $($(libgd)-prefix)/.pkgunpack
$(libgd)-patch: $($(libgd)-prefix)/.pkgpatch
$(libgd)-build: $($(libgd)-prefix)/.pkgbuild
$(libgd)-check: $($(libgd)-prefix)/.pkgcheck
$(libgd)-install: $($(libgd)-prefix)/.pkginstall
$(libgd)-modulefile: $($(libgd)-modulefile)
$(libgd)-clean:
	rm -rf $($(libgd)-modulefile)
	rm -rf $($(libgd)-prefix)
	rm -rf $($(libgd)-srcdir)
	rm -rf $($(libgd)-src)
$(libgd): $(libgd)-src $(libgd)-unpack $(libgd)-patch $(libgd)-build $(libgd)-check $(libgd)-install $(libgd)-modulefile
