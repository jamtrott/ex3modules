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
# openjpeg-2.4.0

openjpeg-version = 2.4.0
openjpeg = openjpeg-$(openjpeg-version)
$(openjpeg)-description = Open source JPEG 2000 codec
$(openjpeg)-url = https://www.openjpeg.org/
$(openjpeg)-srcurl = https://github.com/uclouvain/openjpeg/archive/refs/tags/v$(openjpeg-version).tar.gz
$(openjpeg)-builddeps = $(cmake) $(libpng) $(libtiff)
$(openjpeg)-prereqs =
$(openjpeg)-src = $(pkgsrcdir)/openjpeg-$(notdir $($(openjpeg)-srcurl))
$(openjpeg)-srcdir = $(pkgsrcdir)/$(openjpeg)
$(openjpeg)-builddir = $($(openjpeg)-srcdir)/build
$(openjpeg)-modulefile = $(modulefilesdir)/$(openjpeg)
$(openjpeg)-prefix = $(pkgdir)/$(openjpeg)

$($(openjpeg)-src): $(dir $($(openjpeg)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openjpeg)-srcurl)

$($(openjpeg)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openjpeg)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openjpeg)-prefix)/.pkgunpack: $$($(openjpeg)-src) $($(openjpeg)-srcdir)/.markerfile $($(openjpeg)-prefix)/.markerfile $$(foreach dep,$$($(openjpeg)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openjpeg)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openjpeg)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openjpeg)-builddeps),$(modulefilesdir)/$$(dep)) $($(openjpeg)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(openjpeg)-builddir),$($(openjpeg)-srcdir))
$($(openjpeg)-builddir)/.markerfile: $($(openjpeg)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(openjpeg)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openjpeg)-builddeps),$(modulefilesdir)/$$(dep)) $($(openjpeg)-builddir)/.markerfile $($(openjpeg)-prefix)/.pkgpatch
	cd $($(openjpeg)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openjpeg)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(openjpeg)-prefix) \
			-DCMAKE_BUILD_TYPE=release \
			-DBUILD_STATIC_LIBS=OFF && \
		$(MAKE)
	@touch $@

$($(openjpeg)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openjpeg)-builddeps),$(modulefilesdir)/$$(dep)) $($(openjpeg)-builddir)/.markerfile $($(openjpeg)-prefix)/.pkgbuild
	@touch $@

$($(openjpeg)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openjpeg)-builddeps),$(modulefilesdir)/$$(dep)) $($(openjpeg)-builddir)/.markerfile $($(openjpeg)-prefix)/.pkgcheck
	cd $($(openjpeg)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openjpeg)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(openjpeg)-modulefile): $(modulefilesdir)/.markerfile $($(openjpeg)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openjpeg)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openjpeg)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openjpeg)-description)\"" >>$@
	echo "module-whatis \"$($(openjpeg)-url)\"" >>$@
	printf "$(foreach prereq,$($(openjpeg)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENJPEG_ROOT $($(openjpeg)-prefix)" >>$@
	echo "setenv OPENJPEG_INCDIR $($(openjpeg)-prefix)/include" >>$@
	echo "setenv OPENJPEG_INCLUDEDIR $($(openjpeg)-prefix)/include" >>$@
	echo "setenv OPENJPEG_LIBDIR $($(openjpeg)-prefix)/lib" >>$@
	echo "setenv OPENJPEG_LIBRARYDIR $($(openjpeg)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(openjpeg)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openjpeg)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openjpeg)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openjpeg)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openjpeg)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openjpeg)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(openjpeg)-prefix)/lib/openjpeg-2.4" >>$@
	echo "set MSG \"$(openjpeg)\"" >>$@

$(openjpeg)-src: $$($(openjpeg)-src)
$(openjpeg)-unpack: $($(openjpeg)-prefix)/.pkgunpack
$(openjpeg)-patch: $($(openjpeg)-prefix)/.pkgpatch
$(openjpeg)-build: $($(openjpeg)-prefix)/.pkgbuild
$(openjpeg)-check: $($(openjpeg)-prefix)/.pkgcheck
$(openjpeg)-install: $($(openjpeg)-prefix)/.pkginstall
$(openjpeg)-modulefile: $($(openjpeg)-modulefile)
$(openjpeg)-clean:
	rm -rf $($(openjpeg)-modulefile)
	rm -rf $($(openjpeg)-prefix)
	rm -rf $($(openjpeg)-builddir)
	rm -rf $($(openjpeg)-srcdir)
	rm -rf $($(openjpeg)-src)
$(openjpeg): $(openjpeg)-src $(openjpeg)-unpack $(openjpeg)-patch $(openjpeg)-build $(openjpeg)-check $(openjpeg)-install $(openjpeg)-modulefile
