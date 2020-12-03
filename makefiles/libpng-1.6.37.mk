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
# libpng-1.6.37

libpng-version = 1.6.37
libpng = libpng-$(libpng-version)
$(libpng)-description = Official Portable Network Graphics reference library for handling PNG images
$(libpng)-url = http://www.libpng.org/pub/png/libpng.html
$(libpng)-srcurl = https://download.sourceforge.net/libpng/libpng-$(libpng-version).tar.xz
$(libpng)-src = $(pkgsrcdir)/$(libpng).tar.xz
$(libpng)-srcdir = $(pkgsrcdir)/$(libpng)
$(libpng)-builddeps =
$(libpng)-prereqs =
$(libpng)-modulefile = $(modulefilesdir)/$(libpng)
$(libpng)-prefix = $(pkgdir)/$(libpng)

$($(libpng)-src): $(dir $($(libpng)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libpng)-srcurl)

$($(libpng)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpng)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpng)-prefix)/.pkgunpack: $($(libpng)-src) $($(libpng)-srcdir)/.markerfile $($(libpng)-prefix)/.markerfile
	tar -C $($(libpng)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libpng)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgunpack
	@touch $@

$($(libpng)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgpatch
	cd $($(libpng)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpng)-builddeps) && \
		./configure --prefix=$($(libpng)-prefix) && \
		$(MAKE)
	@touch $@

$($(libpng)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgbuild
	cd $($(libpng)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpng)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libpng)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(libpng)-prefix) -C $($(libpng)-srcdir) install
	@touch $@

$($(libpng)-modulefile): $(modulefilesdir)/.markerfile $($(libpng)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libpng)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libpng)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libpng)-description)\"" >>$@
	echo "module-whatis \"$($(libpng)-url)\"" >>$@
	printf "$(foreach prereq,$($(libpng)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBPNG_ROOT $($(libpng)-prefix)" >>$@
	echo "setenv LIBPNG_INCDIR $($(libpng)-prefix)/include" >>$@
	echo "setenv LIBPNG_INCLUDEDIR $($(libpng)-prefix)/include" >>$@
	echo "setenv LIBPNG_LIBDIR $($(libpng)-prefix)/lib" >>$@
	echo "setenv LIBPNG_LIBRARYDIR $($(libpng)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libpng)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libpng)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libpng)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libpng)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libpng)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libpng)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libpng)-prefix)/share/man" >>$@
	echo "set MSG \"$(libpng)\"" >>$@

$(libpng)-src: $($(libpng)-src)
$(libpng)-unpack: $($(libpng)-prefix)/.pkgunpack
$(libpng)-patch: $($(libpng)-prefix)/.pkgpatch
$(libpng)-build: $($(libpng)-prefix)/.pkgbuild
$(libpng)-check: $($(libpng)-prefix)/.pkgcheck
$(libpng)-install: $($(libpng)-prefix)/.pkginstall
$(libpng)-modulefile: $($(libpng)-modulefile)
$(libpng)-clean:
	rm -rf $($(libpng)-modulefile)
	rm -rf $($(libpng)-prefix)
	rm -rf $($(libpng)-srcdir)
	rm -rf $($(libpng)-src)
$(libpng): $(libpng)-src $(libpng)-unpack $(libpng)-patch $(libpng)-build $(libpng)-check $(libpng)-install $(libpng)-modulefile
