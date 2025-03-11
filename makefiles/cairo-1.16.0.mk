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
# cairo-1.16.0

cairo-version = 1.16.0
cairo = cairo-$(cairo-version)
$(cairo)-description = 2D graphics library
$(cairo)-url = https://www.cairographics.org/
$(cairo)-srcurl = https://www.cairographics.org/releases/cairo-$(cairo-version).tar.xz
$(cairo)-src = $(pkgsrcdir)/$(notdir $($(cairo)-srcurl))
$(cairo)-srcdir = $(pkgsrcdir)/$(cairo)
$(cairo)-builddeps = $(libbsd) $(libpng) $(freetype) $(fontconfig) $(pixman) $(xorg-libraries)
$(cairo)-prereqs = $(libbsd) $(libpng) $(freetype) $(fontconfig) $(pixman) $(xorg-libraries)
$(cairo)-modulefile = $(modulefilesdir)/$(cairo)
$(cairo)-prefix = $(pkgdir)/$(cairo)

$($(cairo)-src): $(dir $($(cairo)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cairo)-srcurl)

$($(cairo)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cairo)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cairo)-prefix)/.pkgunpack: $($(cairo)-src) $($(cairo)-srcdir)/.markerfile $($(cairo)-prefix)/.markerfile $$(foreach dep,$$($(cairo)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cairo)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(cairo)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(cairo)-prefix)/.pkgunpack
	@touch $@

$($(cairo)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(cairo)-prefix)/.pkgpatch
	cd $($(cairo)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cairo)-builddeps) && \
		./configure --prefix=$($(cairo)-prefix) && \
		$(MAKE)
	@touch $@

$($(cairo)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(cairo)-prefix)/.pkgbuild
# 	Disable failing test suite
# 	cd $($(cairo)-srcdir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(cairo)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(cairo)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(cairo)-prefix)/.pkgcheck
	$(MAKE) -C $($(cairo)-srcdir) install
	@touch $@

$($(cairo)-modulefile): $(modulefilesdir)/.markerfile $($(cairo)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cairo)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cairo)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cairo)-description)\"" >>$@
	echo "module-whatis \"$($(cairo)-url)\"" >>$@
	printf "$(foreach prereq,$($(cairo)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CAIRO_ROOT $($(cairo)-prefix)" >>$@
	echo "setenv CAIRO_INCDIR $($(cairo)-prefix)/include" >>$@
	echo "setenv CAIRO_INCLUDEDIR $($(cairo)-prefix)/include" >>$@
	echo "setenv CAIRO_LIBDIR $($(cairo)-prefix)/lib" >>$@
	echo "setenv CAIRO_LIBRARYDIR $($(cairo)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(cairo)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cairo)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cairo)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cairo)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cairo)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cairo)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(cairo)\"" >>$@

$(cairo)-src: $($(cairo)-src)
$(cairo)-unpack: $($(cairo)-prefix)/.pkgunpack
$(cairo)-patch: $($(cairo)-prefix)/.pkgpatch
$(cairo)-build: $($(cairo)-prefix)/.pkgbuild
$(cairo)-check: $($(cairo)-prefix)/.pkgcheck
$(cairo)-install: $($(cairo)-prefix)/.pkginstall
$(cairo)-modulefile: $($(cairo)-modulefile)
$(cairo)-clean:
	rm -rf $($(cairo)-modulefile)
	rm -rf $($(cairo)-prefix)
	rm -rf $($(cairo)-srcdir)
	rm -rf $($(cairo)-src)
$(cairo): $(cairo)-src $(cairo)-unpack $(cairo)-patch $(cairo)-build $(cairo)-check $(cairo)-install $(cairo)-modulefile
