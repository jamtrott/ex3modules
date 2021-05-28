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
# texlive-20210325

texlive-version = 20210325
texlive = texlive-$(texlive-version)
$(texlive)-description = TeX Live distribution of the TeX document production system
$(texlive)-url = https://tug.org/texlive/
$(texlive)-srcurl = ftp://tug.org/texlive/historic/2021/texlive-$(texlive-version)-source.tar.xz
$(texlive)-texmf-srcurl = ftp://tug.org/texlive/historic/2021/texlive-$(texlive-version)-texmf.tar.xz
$(texlive)-tlpdb-srcurl = ftp://tug.org/texlive/historic/2021/texlive-$(texlive-version)-tlpdb-full.tar.gz
$(texlive)-builddeps = $(ghostscript) $(cairo) $(fontconfig) $(freetype) $(gmp) $(graphite) $(harfbuzz-graphite) $(icu) $(libgs) $(libpaper) $(libpng) $(mpfr) $(pixman) $(poppler)
$(texlive)-prereqs = $(ghostscript) $(cairo) $(fontconfig) $(freetype) $(gmp) $(graphite) $(harfbuzz-graphite) $(icu) $(libgs) $(libpaper) $(libpng) $(mpfr) $(pixman) $(poppler)
$(texlive)-src = $(pkgsrcdir)/$(notdir $($(texlive)-srcurl))
$(texlive)-texmf-src = $(pkgsrcdir)/$(notdir $($(texlive)-texmf-srcurl))
$(texlive)-tlpdb-src = $(pkgsrcdir)/$(notdir $($(texlive)-tlpdb-srcurl))
$(texlive)-srcdir = $(pkgsrcdir)/$(texlive)
$(texlive)-builddir = $($(texlive)-srcdir)/build
$(texlive)-modulefile = $(modulefilesdir)/$(texlive)
$(texlive)-prefix = $(pkgdir)/$(texlive)

$($(texlive)-src): $(dir $($(texlive)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(texlive)-srcurl)

$($(texlive)-texmf-src): $(dir $($(texlive)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(texlive)-texmf-srcurl)

$($(texlive)-tlpdb-src): $(dir $($(texlive)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(texlive)-tlpdb-srcurl)

$($(texlive)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(texlive)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(texlive)-prefix)/.pkgunpack: $$($(texlive)-src) $$($(texlive)-texmf-src) $$($(texlive)-tlpdb-src) $($(texlive)-srcdir)/.markerfile $($(texlive)-prefix)/.markerfile
	tar -C $($(texlive)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(texlive)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texlive)-builddeps),$(modulefilesdir)/$$(dep)) $($(texlive)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(texlive)-builddir),$($(texlive)-srcdir))
$($(texlive)-builddir)/.markerfile: $($(texlive)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(texlive)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texlive)-builddeps),$(modulefilesdir)/$$(dep)) $($(texlive)-builddir)/.markerfile $($(texlive)-prefix)/.pkgpatch
	export TEXARCH=$$(uname -m | sed -e s/i.86/i386/ -e s/$$/-linux/) && \
	export PATH=$${PATH}:$($(texlive)-prefix)/bin/$${TEXARCH} \
		TEXMFDIST=$($(texlive)-prefix)/texmf-dist \
		TEXMFLOCAL=$($(texlive)-prefix)/texmf \
		TEXMFSYSVAR=$($(texlive)-prefix)/texmf-var \
		TEXMFSYSCONFIG=$($(texlive)-prefix)/etc/texmf \
		TEXMFHOME=$($(texlive)-prefix)/texmf \
		TEXMFVAR=$($(texlive)-prefix)/texmf-var \
		TEXMFCONFIG=$($(texlive)-prefix)/texmf-config \
		TEXMFCACHE=$($(texlive)-prefix)/texmf-var && \
	cd $($(texlive)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(texlive)-builddeps) && \
		../configure \
			--prefix=$($(texlive)-prefix) \
			--bindir=$($(texlive)-prefix)/bin/$${TEXARCH} \
			--datarootdir=$($(texlive)-prefix) \
			--includedir=$($(texlive)-prefix)/include \
			--infodir=$($(texlive)-prefix)/texmf-dist/doc/info \
			--libdir=$($(texlive)-prefix)/lib \
			--mandir=$($(texlive)-prefix)/texmf-dist/doc/man \
			--disable-native-texlive-build \
			--disable-static --enable-shared \
			--disable-dvisvgm \
			--with-system-cairo \
			--with-system-fontconfig \
			--with-system-freetype2 \
			--with-system-gmp \
			--with-system-graphite2 \
			--with-system-harfbuzz \
			--with-system-icu \
			--with-system-libgs \
			--with-system-libpaper \
			--with-system-libpng \
			--with-system-mpfr \
			--with-system-pixman \
			--with-system-zlib \
			--with-system-poppler && \
		$(MAKE)
	@touch $@

$($(texlive)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texlive)-builddeps),$(modulefilesdir)/$$(dep)) $($(texlive)-builddir)/.markerfile $($(texlive)-prefix)/.pkgbuild
ifneq ($(ARCH),aarch64)
	cd $($(texlive)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(texlive)-builddeps) && \
		$(MAKE) -k check
endif
	@touch $@

$($(texlive)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texlive)-builddeps),$(modulefilesdir)/$$(dep)) $($(texlive)-builddir)/.markerfile $($(texlive)-prefix)/.pkgcheck $$($(texlive)-texmf-src) $$($(texlive)-tlpdb-src)
	export TEXARCH=$$(uname -m | sed -e s/i.86/i386/ -e s/$$/-linux/) && \
	export PATH=$${PATH}:$($(texlive)-prefix)/bin/$${TEXARCH} \
		TEXMFDIST=$($(texlive)-prefix)/texmf-dist \
		TEXMFLOCAL=$($(texlive)-prefix)/texmf \
		TEXMFSYSVAR=$($(texlive)-prefix)/texmf-var \
		TEXMFSYSCONFIG=$($(texlive)-prefix)/etc/texmf \
		TEXMFHOME=$($(texlive)-prefix)/texmf \
		TEXMFVAR=$($(texlive)-prefix)/texmf-var \
		TEXMFCONFIG=$($(texlive)-prefix)/texmf-config \
		TEXMFCACHE=$($(texlive)-prefix)/texmf-var && \
	cd $($(texlive)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(texlive)-builddeps) && \
		$(MAKE) install && \
		$(MAKE) texlinks && \
		mkdir -pv $($(texlive)-prefix)/tlpkg/TeXLive/ && \
		$(INSTALL) -v -m644 ../texk/tests/TeXLive/* $($(texlive)-prefix)/tlpkg/TeXLive/ && \
		tar --verbose -C $($(texlive)-prefix) -x -f $($(texlive)-tlpdb-src) && \
		tar --verbose -C $($(texlive)-prefix) --strip-components 1 -x -f $($(texlive)-texmf-src) && \
		mktexlsr && \
		fmtutil-sys --all --no-strict && \
		mtxrun --generate
	@touch $@

$($(texlive)-modulefile): $(modulefilesdir)/.markerfile $($(texlive)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(texlive)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(texlive)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(texlive)-description)\"" >>$@
	echo "module-whatis \"$($(texlive)-url)\"" >>$@
	printf "$(foreach prereq,$($(texlive)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv TEXLIVE_ROOT $($(texlive)-prefix)" >>$@
	echo "setenv TEXLIVE_INCDIR $($(texlive)-prefix)/include" >>$@
	echo "setenv TEXLIVE_INCLUDEDIR $($(texlive)-prefix)/include" >>$@
	echo "setenv TEXLIVE_LIBDIR $($(texlive)-prefix)/lib" >>$@
	echo "setenv TEXLIVE_LIBRARYDIR $($(texlive)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(texlive)-prefix)/bin/$$(uname -m | sed -e 's/i.86/i386/' -e 's/$$/-linux/')" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(texlive)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(texlive)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(texlive)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(texlive)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(texlive)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(texlive)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(texlive)-prefix)/share/info" >>$@
	echo "setenv TEXMFDIST $($(texlive)-prefix)/texmf-dist" >>$@
	echo "setenv TEXMFLOCAL $($(texlive)-prefix)/texmf" >>$@
	echo "setenv TEXMFSYSVAR $($(texlive)-prefix)/texmf-var" >>$@
	echo "setenv TEXMFSYSCONFIG $($(texlive)-prefix)/etc/texmf" >>$@
	echo "setenv TEXMFHOME $($(texlive)-prefix)/texmf" >>$@
	echo "setenv TEXMFVAR $($(texlive)-prefix)/texmf-var" >>$@
	echo "setenv TEXMFCONFIG $($(texlive)-prefix)/texmf-config" >>$@
	echo "setenv TEXMFCACHE $($(texlive)-prefix)/texmf-var" >>$@
	echo "prepend-path TEXINPUTS $($(texlive)-prefix)/texmf-dist/tex/texinfo/" >>$@
	echo "set MSG \"$(texlive)\"" >>$@

$(texlive)-src: $$($(texlive)-src) $$($(texlive)-texmf-src) $$($(texlive)-tlpdb-src)
$(texlive)-unpack: $($(texlive)-prefix)/.pkgunpack
$(texlive)-patch: $($(texlive)-prefix)/.pkgpatch
$(texlive)-build: $($(texlive)-prefix)/.pkgbuild
$(texlive)-check: $($(texlive)-prefix)/.pkgcheck
$(texlive)-install: $($(texlive)-prefix)/.pkginstall
$(texlive)-modulefile: $($(texlive)-modulefile)
$(texlive)-clean:
	rm -rf $($(texlive)-modulefile)
	rm -rf $($(texlive)-prefix)
	rm -rf $($(texlive)-builddir)
	rm -rf $($(texlive)-srcdir)
	rm -rf $($(texlive)-src)
	rm -rf $($(texlive)-texmf-src)
	rm -rf $($(texlive)-tlpdb-src)
$(texlive): $(texlive)-src $(texlive)-unpack $(texlive)-patch $(texlive)-build $(texlive)-check $(texlive)-install $(texlive)-modulefile
