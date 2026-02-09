# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# ncurses-6.1

ncurses-version = 6.1
ncurses = ncurses-$(ncurses-version)
$(ncurses)-description = Library for text-based user interfaces
$(ncurses)-url = https://www.gnu.org/software/ncurses/
$(ncurses)-srcurl = ftp://ftp.gnu.org/gnu/ncurses/$(ncurses).tar.gz
$(ncurses)-builddeps =
$(ncurses)-prereqs =
$(ncurses)-src = $(pkgsrcdir)/$(notdir $($(ncurses)-srcurl))
$(ncurses)-srcdir = $(pkgsrcdir)/$(ncurses)
$(ncurses)-builddir = $($(ncurses)-srcdir)
$(ncurses)-modulefile = $(modulefilesdir)/$(ncurses)
$(ncurses)-prefix = $(pkgdir)/$(ncurses)

$($(ncurses)-src): $(dir $($(ncurses)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ncurses)-srcurl)

$($(ncurses)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ncurses)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ncurses)-prefix)/.pkgunpack: $$($(ncurses)-src) $($(ncurses)-srcdir)/.markerfile $($(ncurses)-prefix)/.markerfile $$(foreach dep,$$($(ncurses)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(ncurses)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ncurses)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ncurses)-builddeps),$(modulefilesdir)/$$(dep)) $($(ncurses)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(ncurses)-builddir),$($(ncurses)-srcdir))
$($(ncurses)-builddir)/.markerfile: $($(ncurses)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(ncurses)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ncurses)-builddeps),$(modulefilesdir)/$$(dep)) $($(ncurses)-builddir)/.markerfile $($(ncurses)-prefix)/.pkgpatch
	cd $($(ncurses)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ncurses)-builddeps) && \
		./configure --prefix=$($(ncurses)-prefix) \
			--with-shared \
			--without-normal \
			--enable-pc-files \
			--with-pkg-config-libdir="$($(ncurses)-prefix)/lib/pkgconfig" \
			--enable-widec \
			--with-versioned-syms && \
		$(MAKE)
	@touch $@

$($(ncurses)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ncurses)-builddeps),$(modulefilesdir)/$$(dep)) $($(ncurses)-builddir)/.markerfile $($(ncurses)-prefix)/.pkgbuild
	@touch $@

$($(ncurses)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ncurses)-builddeps),$(modulefilesdir)/$$(dep)) $($(ncurses)-builddir)/.markerfile $($(ncurses)-prefix)/.pkgcheck
	cd $($(ncurses)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ncurses)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(ncurses)-modulefile): $(modulefilesdir)/.markerfile $($(ncurses)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ncurses)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ncurses)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ncurses)-description)\"" >>$@
	echo "module-whatis \"$($(ncurses)-url)\"" >>$@
	printf "$(foreach prereq,$($(ncurses)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NCURSES_ROOT $($(ncurses)-prefix)" >>$@
	echo "setenv NCURSES_INCDIR $($(ncurses)-prefix)/include" >>$@
	echo "setenv NCURSES_INCLUDEDIR $($(ncurses)-prefix)/include" >>$@
	echo "setenv NCURSES_LIBDIR $($(ncurses)-prefix)/lib" >>$@
	echo "setenv NCURSES_LIBRARYDIR $($(ncurses)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(ncurses)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ncurses)-prefix)/include" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ncurses)-prefix)/include/ncursesw" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ncurses)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ncurses)-prefix)/include/ncursesw" >>$@
	echo "prepend-path LIBRARY_PATH $($(ncurses)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ncurses)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(ncurses)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(ncurses)-prefix)/share/man" >>$@
	echo "set MSG \"$(ncurses)\"" >>$@

$(ncurses)-src: $$($(ncurses)-src)
$(ncurses)-unpack: $($(ncurses)-prefix)/.pkgunpack
$(ncurses)-patch: $($(ncurses)-prefix)/.pkgpatch
$(ncurses)-build: $($(ncurses)-prefix)/.pkgbuild
$(ncurses)-check: $($(ncurses)-prefix)/.pkgcheck
$(ncurses)-install: $($(ncurses)-prefix)/.pkginstall
$(ncurses)-modulefile: $($(ncurses)-modulefile)
$(ncurses)-clean:
	rm -rf $($(ncurses)-modulefile)
	rm -rf $($(ncurses)-prefix)
	rm -rf $($(ncurses)-srcdir)
	rm -rf $($(ncurses)-src)
$(ncurses): $(ncurses)-src $(ncurses)-unpack $(ncurses)-patch $(ncurses)-build $(ncurses)-check $(ncurses)-install $(ncurses)-modulefile
