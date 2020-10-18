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
# libwebp-1.1.0

libwebp-version = 1.1.0
libwebp = libwebp-$(libwebp-version)
$(libwebp)-description = Library to encode and decode images in WebP format
$(libwebp)-url = https://developers.google.com/speed/webp/
$(libwebp)-srcurl = https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$(libwebp-version).tar.gz
$(libwebp)-src = $(pkgsrcdir)/$(notdir $($(libwebp)-srcurl))
$(libwebp)-srcdir = $(pkgsrcdir)/$(libwebp)
$(libwebp)-builddeps = $(libjpeg-turbo) $(libpng) $(giflib) $(libtiff)
$(libwebp)-prereqs = $(libjpeg-turbo) $(libpng) $(giflib) $(libtiff)
$(libwebp)-modulefile = $(modulefilesdir)/$(libwebp)
$(libwebp)-prefix = $(pkgdir)/$(libwebp)

$($(libwebp)-src): $(dir $($(libwebp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libwebp)-srcurl)

$($(libwebp)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libwebp)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libwebp)-prefix)/.pkgunpack: $($(libwebp)-src) $($(libwebp)-srcdir)/.markerfile $($(libwebp)-prefix)/.markerfile
	tar -C $($(libwebp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libwebp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libwebp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libwebp)-prefix)/.pkgunpack
	@touch $@

$($(libwebp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libwebp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libwebp)-prefix)/.pkgpatch
	cd $($(libwebp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libwebp)-builddeps) && \
		./configure --prefix=$($(libwebp)-prefix) \
			--enable-libwebpmux     \
			--enable-libwebpdemux   \
			--enable-libwebpdecoder \
			--enable-libwebpextras  \
			--enable-swap-16bit-csp \
			--disable-static && \
		$(MAKE)
	@touch $@

$($(libwebp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libwebp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libwebp)-prefix)/.pkgbuild
	cd $($(libwebp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libwebp)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libwebp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libwebp)-builddeps),$(modulefilesdir)/$$(dep)) $($(libwebp)-prefix)/.pkgcheck
	$(MAKE) -C $($(libwebp)-srcdir) install
	@touch $@

$($(libwebp)-modulefile): $(modulefilesdir)/.markerfile $($(libwebp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libwebp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libwebp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libwebp)-description)\"" >>$@
	echo "module-whatis \"$($(libwebp)-url)\"" >>$@
	printf "$(foreach prereq,$($(libwebp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBWEBP_ROOT $($(libwebp)-prefix)" >>$@
	echo "setenv LIBWEBP_INCDIR $($(libwebp)-prefix)/include" >>$@
	echo "setenv LIBWEBP_INCLUDEDIR $($(libwebp)-prefix)/include" >>$@
	echo "setenv LIBWEBP_LIBDIR $($(libwebp)-prefix)/lib" >>$@
	echo "setenv LIBWEBP_LIBRARYDIR $($(libwebp)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libwebp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libwebp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libwebp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libwebp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libwebp)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libwebp)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libwebp)-prefix)/share/man" >>$@
	echo "set MSG \"$(libwebp)\"" >>$@

$(libwebp)-src: $($(libwebp)-src)
$(libwebp)-unpack: $($(libwebp)-prefix)/.pkgunpack
$(libwebp)-patch: $($(libwebp)-prefix)/.pkgpatch
$(libwebp)-build: $($(libwebp)-prefix)/.pkgbuild
$(libwebp)-check: $($(libwebp)-prefix)/.pkgcheck
$(libwebp)-install: $($(libwebp)-prefix)/.pkginstall
$(libwebp)-modulefile: $($(libwebp)-modulefile)
$(libwebp)-clean:
	rm -rf $($(libwebp)-modulefile)
	rm -rf $($(libwebp)-prefix)
	rm -rf $($(libwebp)-srcdir)
	rm -rf $($(libwebp)-src)
$(libwebp): $(libwebp)-src $(libwebp)-unpack $(libwebp)-patch $(libwebp)-build $(libwebp)-check $(libwebp)-install $(libwebp)-modulefile
