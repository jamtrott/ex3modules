# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# poppler-21.04.0

poppler-version = 21.04.0
poppler = poppler-$(poppler-version)
$(poppler)-description = PDF rendering library
$(poppler)-url = https://poppler.freedesktop.org/
$(poppler)-srcurl = https://poppler.freedesktop.org/poppler-$(poppler-version).tar.xz
$(poppler)-builddeps = $(cmake) $(python) $(fontconfig) $(cairo) $(libjpeg-turbo) $(libpng) $(openjpeg) $(boost) $(curl) $(libtiff) $(nss) $(lcms2)
$(poppler)-prereqs = $(fontconfig) $(cairo) $(libjpeg-turbo) $(libpng) $(openjpeg) $(boost) $(curl) $(libtiff) $(nss) $(lcms2)
$(poppler)-src = $(pkgsrcdir)/$(notdir $($(poppler)-srcurl))
$(poppler)-srcdir = $(pkgsrcdir)/$(poppler)
$(poppler)-builddir = $($(poppler)-srcdir)/build
$(poppler)-modulefile = $(modulefilesdir)/$(poppler)
$(poppler)-prefix = $(pkgdir)/$(poppler)

$($(poppler)-src): $(dir $($(poppler)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(poppler)-srcurl)

$($(poppler)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(poppler)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(poppler)-prefix)/.pkgunpack: $$($(poppler)-src) $($(poppler)-srcdir)/.markerfile $($(poppler)-prefix)/.markerfile
	tar -C $($(poppler)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(poppler)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(poppler)-builddeps),$(modulefilesdir)/$$(dep)) $($(poppler)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(poppler)-builddir),$($(poppler)-srcdir))
$($(poppler)-builddir)/.markerfile: $($(poppler)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(poppler)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(poppler)-builddeps),$(modulefilesdir)/$$(dep)) $($(poppler)-builddir)/.markerfile $($(poppler)-prefix)/.pkgpatch
	cd $($(poppler)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(poppler)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(poppler)-prefix) \
			-DCMAKE_BUILD_TYPE=Release \
			-DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
			-DTIFF_INCLUDE_DIR="$${LIBTIFF_INCDIR}" -DTIFF_LIBRARY="$${LIBTIFF_LIBDIR}/libtiff.so" \
			-DFontconfig_INCLUDE_DIR="$${FONTCONFIG_INCDIR}" -DFontconfig_LIBRARY="$${FONTCONFIG_LIBDIR}/libfontconfig.so" \
			-DFREETYPE_INCLUDE_DIRS="$${FREETYPE_INCDIR}" -DFREETYPE_LIBRARY="$${FREETYPE_LIBDIR}/libfreetype.so" \
			-DJPEG_INCLUDE_DIR="$${LIBJPEG_TURBO_INCDIR}" -DJPEG_LIBRARY="$${LIBJPEG_TURBO_LIBDIR}/libjpeg.so" \
			-DPNG_PNG_INCLUDE_DIR="$${LIBPNG_INCDIR}" -DPNG_LIBRARY="$${LIBPNG_LIBDIR}/libpng.so" \
			-DNSS3_CFLAGS="$$(pkg-config --cflags nss)" && \
		$(MAKE)
	@touch $@

$($(poppler)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(poppler)-builddeps),$(modulefilesdir)/$$(dep)) $($(poppler)-builddir)/.markerfile $($(poppler)-prefix)/.pkgbuild
	@touch $@

$($(poppler)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(poppler)-builddeps),$(modulefilesdir)/$$(dep)) $($(poppler)-builddir)/.markerfile $($(poppler)-prefix)/.pkgcheck
	cd $($(poppler)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(poppler)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(poppler)-modulefile): $(modulefilesdir)/.markerfile $($(poppler)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(poppler)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(poppler)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(poppler)-description)\"" >>$@
	echo "module-whatis \"$($(poppler)-url)\"" >>$@
	printf "$(foreach prereq,$($(poppler)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv POPPLER_ROOT $($(poppler)-prefix)" >>$@
	echo "setenv POPPLER_INCDIR $($(poppler)-prefix)/include" >>$@
	echo "setenv POPPLER_INCLUDEDIR $($(poppler)-prefix)/include" >>$@
	echo "setenv POPPLER_LIBDIR $($(poppler)-prefix)/lib" >>$@
	echo "setenv POPPLER_LIBRARYDIR $($(poppler)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(poppler)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(poppler)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(poppler)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(poppler)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(poppler)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(poppler)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(poppler)-prefix)/share/man" >>$@
	echo "set MSG \"$(poppler)\"" >>$@

$(poppler)-src: $$($(poppler)-src)
$(poppler)-unpack: $($(poppler)-prefix)/.pkgunpack
$(poppler)-patch: $($(poppler)-prefix)/.pkgpatch
$(poppler)-build: $($(poppler)-prefix)/.pkgbuild
$(poppler)-check: $($(poppler)-prefix)/.pkgcheck
$(poppler)-install: $($(poppler)-prefix)/.pkginstall
$(poppler)-modulefile: $($(poppler)-modulefile)
$(poppler)-clean:
	rm -rf $($(poppler)-modulefile)
	rm -rf $($(poppler)-prefix)
	rm -rf $($(poppler)-builddir)
	rm -rf $($(poppler)-srcdir)
	rm -rf $($(poppler)-src)
$(poppler): $(poppler)-src $(poppler)-unpack $(poppler)-patch $(poppler)-build $(poppler)-check $(poppler)-install $(poppler)-modulefile
