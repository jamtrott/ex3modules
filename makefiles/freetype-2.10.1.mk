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
# freetype-2.10.1

freetype-version = 2.10.1
freetype = freetype-$(freetype-version)
$(freetype)-description = Font rendering library
$(freetype)-url = https://www.freetype.org/
$(freetype)-srcurl = https://download.savannah.gnu.org/releases/freetype/freetype-$(freetype-version).tar.gz
$(freetype)-src = $(pkgsrcdir)/$(freetype).tar.gz
$(freetype)-srcdir = $(pkgsrcdir)/$(freetype)
$(freetype)-builddeps = $(libpng)
$(freetype)-prereqs = $(libpng)
$(freetype)-modulefile = $(modulefilesdir)/$(freetype)
$(freetype)-prefix = $(pkgdir)/$(freetype)

$($(freetype)-src): $(dir $($(freetype)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(freetype)-srcurl)

$($(freetype)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(freetype)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(freetype)-prefix)/.pkgunpack: $($(freetype)-src) $($(freetype)-srcdir)/.markerfile $($(freetype)-prefix)/.markerfile
	tar -C $($(freetype)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(freetype)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freetype)-builddeps),$(modulefilesdir)/$$(dep)) $($(freetype)-prefix)/.pkgunpack
	@touch $@

$($(freetype)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freetype)-builddeps),$(modulefilesdir)/$$(dep)) $($(freetype)-prefix)/.pkgpatch
	cd $($(freetype)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(freetype)-builddeps) && \
		./configure --prefix=$($(freetype)-prefix) && \
		$(MAKE) MAKEFLAGS=
	@touch $@

$($(freetype)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freetype)-builddeps),$(modulefilesdir)/$$(dep)) $($(freetype)-prefix)/.pkgbuild
	cd $($(freetype)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(freetype)-builddeps) && \
		$(MAKE) MAKEFLAGS= check
	@touch $@

$($(freetype)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freetype)-builddeps),$(modulefilesdir)/$$(dep)) $($(freetype)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(freetype)-prefix) -C $($(freetype)-srcdir) install
	@touch $@

$($(freetype)-modulefile): $(modulefilesdir)/.markerfile $($(freetype)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(freetype)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(freetype)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(freetype)-description)\"" >>$@
	echo "module-whatis \"$($(freetype)-url)\"" >>$@
	printf "$(foreach prereq,$($(freetype)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FREETYPE_ROOT $($(freetype)-prefix)" >>$@
	echo "setenv FREETYPE_INCDIR $($(freetype)-prefix)/include" >>$@
	echo "setenv FREETYPE_INCLUDEDIR $($(freetype)-prefix)/include" >>$@
	echo "setenv FREETYPE_LIBDIR $($(freetype)-prefix)/lib" >>$@
	echo "setenv FREETYPE_LIBRARYDIR $($(freetype)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(freetype)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(freetype)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(freetype)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(freetype)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(freetype)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(freetype)-prefix)/share/aclocal" >>$@
	echo "set MSG \"$(freetype)\"" >>$@

$(freetype)-src: $($(freetype)-src)
$(freetype)-unpack: $($(freetype)-prefix)/.pkgunpack
$(freetype)-patch: $($(freetype)-prefix)/.pkgpatch
$(freetype)-build: $($(freetype)-prefix)/.pkgbuild
$(freetype)-check: $($(freetype)-prefix)/.pkgcheck
$(freetype)-install: $($(freetype)-prefix)/.pkginstall
$(freetype)-modulefile: $($(freetype)-modulefile)
$(freetype)-clean:
	rm -rf $($(freetype)-modulefile)
	rm -rf $($(freetype)-prefix)
	rm -rf $($(freetype)-srcdir)
	rm -rf $($(freetype)-src)
$(freetype): $(freetype)-src $(freetype)-unpack $(freetype)-patch $(freetype)-build $(freetype)-check $(freetype)-install $(freetype)-modulefile
