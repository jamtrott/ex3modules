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
# libtiff-4.1.0

libtiff-version = 4.1.0
libtiff = libtiff-$(libtiff-version)
$(libtiff)-description = Library and tools for the Tag Image File Format (TIFF)
$(libtiff)-url = http://www.simplesystems.org/libtiff/
$(libtiff)-srcurl = https://download.osgeo.org/libtiff/tiff-$(libtiff-version).tar.gz
$(libtiff)-src = $(pkgsrcdir)/$(notdir $($(libtiff)-srcurl))
$(libtiff)-srcdir = $(pkgsrcdir)/$(libtiff)
$(libtiff)-builddeps = 
$(libtiff)-prereqs =
$(libtiff)-modulefile = $(modulefilesdir)/$(libtiff)
$(libtiff)-prefix = $(pkgdir)/$(libtiff)

$($(libtiff)-src): $(dir $($(libtiff)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libtiff)-srcurl)

$($(libtiff)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libtiff)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libtiff)-prefix)/.pkgunpack: $($(libtiff)-src) $($(libtiff)-srcdir)/.markerfile $($(libtiff)-prefix)/.markerfile $$(foreach dep,$$($(libtiff)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libtiff)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libtiff)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtiff)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtiff)-prefix)/.pkgunpack
	@touch $@

$($(libtiff)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtiff)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtiff)-prefix)/.pkgpatch
	cd $($(libtiff)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libtiff)-builddeps) && \
		./configure --prefix=$($(libtiff)-prefix) && \
		$(MAKE)
	@touch $@

$($(libtiff)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtiff)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtiff)-prefix)/.pkgbuild
	cd $($(libtiff)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libtiff)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libtiff)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtiff)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtiff)-prefix)/.pkgcheck
	$(MAKE) -C $($(libtiff)-srcdir) install
	@touch $@

$($(libtiff)-modulefile): $(modulefilesdir)/.markerfile $($(libtiff)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libtiff)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libtiff)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libtiff)-description)\"" >>$@
	echo "module-whatis \"$($(libtiff)-url)\"" >>$@
	printf "$(foreach prereq,$($(libtiff)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBTIFF_ROOT $($(libtiff)-prefix)" >>$@
	echo "setenv LIBTIFF_INCDIR $($(libtiff)-prefix)/include" >>$@
	echo "setenv LIBTIFF_INCLUDEDIR $($(libtiff)-prefix)/include" >>$@
	echo "setenv LIBTIFF_LIBDIR $($(libtiff)-prefix)/lib" >>$@
	echo "setenv LIBTIFF_LIBRARYDIR $($(libtiff)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libtiff)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libtiff)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libtiff)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libtiff)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libtiff)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libtiff)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libtiff)-prefix)/share/man" >>$@
	echo "set MSG \"$(libtiff)\"" >>$@

$(libtiff)-src: $($(libtiff)-src)
$(libtiff)-unpack: $($(libtiff)-prefix)/.pkgunpack
$(libtiff)-patch: $($(libtiff)-prefix)/.pkgpatch
$(libtiff)-build: $($(libtiff)-prefix)/.pkgbuild
$(libtiff)-check: $($(libtiff)-prefix)/.pkgcheck
$(libtiff)-install: $($(libtiff)-prefix)/.pkginstall
$(libtiff)-modulefile: $($(libtiff)-modulefile)
$(libtiff)-clean:
	rm -rf $($(libtiff)-modulefile)
	rm -rf $($(libtiff)-prefix)
	rm -rf $($(libtiff)-srcdir)
	rm -rf $($(libtiff)-src)
$(libtiff): $(libtiff)-src $(libtiff)-unpack $(libtiff)-patch $(libtiff)-build $(libtiff)-check $(libtiff)-install $(libtiff)-modulefile
