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
# graphite2-1.3.14

graphite2-version = 1.3.14
graphite2 = graphite2-$(graphite2-version)
$(graphite2)-description = Rendering engine for graphite fonts
$(graphite2)-url = https://graphite.sil.org
$(graphite2)-srcurl = https://github.com/silnrsi/graphite/archive/refs/tags/$(graphite2-version).tar.gz
$(graphite2)-builddeps = $(freetype) $(harfbuzz)
$(graphite2)-prereqs =
$(graphite2)-src = $(pkgsrcdir)/graphite2-$(notdir $($(graphite2)-srcurl))
$(graphite2)-srcdir = $(pkgsrcdir)/$(graphite2)
$(graphite2)-builddir = $($(graphite2)-srcdir)/build
$(graphite2)-modulefile = $(modulefilesdir)/$(graphite2)
$(graphite2)-prefix = $(pkgdir)/$(graphite2)

$($(graphite2)-src): $(dir $($(graphite2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(graphite2)-srcurl)

$($(graphite2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(graphite2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(graphite2)-prefix)/.pkgunpack: $$($(graphite2)-src) $($(graphite2)-srcdir)/.markerfile $($(graphite2)-prefix)/.markerfile $$(foreach dep,$$($(graphite2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(graphite2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(graphite2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphite2)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphite2)-prefix)/.pkgunpack
	cd $($(graphite2)-srcdir) && \
	sed -i '/cmptest/d' tests/CMakeLists.txt # Disable tests that require FontTools
	@touch $@

ifneq ($($(graphite2)-builddir),$($(graphite2)-srcdir))
$($(graphite2)-builddir)/.markerfile: $($(graphite2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(graphite2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphite2)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphite2)-builddir)/.markerfile $($(graphite2)-prefix)/.pkgpatch
	cd $($(graphite2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(graphite2)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(graphite2)-prefix) && \
		$(MAKE)
	@touch $@

$($(graphite2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphite2)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphite2)-builddir)/.markerfile $($(graphite2)-prefix)/.pkgbuild
	@touch $@

$($(graphite2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphite2)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphite2)-builddir)/.markerfile $($(graphite2)-prefix)/.pkgcheck
	cd $($(graphite2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(graphite2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(graphite2)-modulefile): $(modulefilesdir)/.markerfile $($(graphite2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(graphite2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(graphite2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(graphite2)-description)\"" >>$@
	echo "module-whatis \"$($(graphite2)-url)\"" >>$@
	printf "$(foreach prereq,$($(graphite2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GRAPHITE2_ROOT $($(graphite2)-prefix)" >>$@
	echo "setenv GRAPHITE2_INCDIR $($(graphite2)-prefix)/include" >>$@
	echo "setenv GRAPHITE2_INCLUDEDIR $($(graphite2)-prefix)/include" >>$@
	echo "setenv GRAPHITE2_LIBDIR $($(graphite2)-prefix)/lib" >>$@
	echo "setenv GRAPHITE2_LIBRARYDIR $($(graphite2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(graphite2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(graphite2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(graphite2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(graphite2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(graphite2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(graphite2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(graphite2)-prefix)/share/graphite2" >>$@
	echo "set MSG \"$(graphite2)\"" >>$@

$(graphite2)-src: $$($(graphite2)-src)
$(graphite2)-unpack: $($(graphite2)-prefix)/.pkgunpack
$(graphite2)-patch: $($(graphite2)-prefix)/.pkgpatch
$(graphite2)-build: $($(graphite2)-prefix)/.pkgbuild
$(graphite2)-check: $($(graphite2)-prefix)/.pkgcheck
$(graphite2)-install: $($(graphite2)-prefix)/.pkginstall
$(graphite2)-modulefile: $($(graphite2)-modulefile)
$(graphite2)-clean:
	rm -rf $($(graphite2)-modulefile)
	rm -rf $($(graphite2)-prefix)
	rm -rf $($(graphite2)-builddir)
	rm -rf $($(graphite2)-srcdir)
	rm -rf $($(graphite2)-src)
$(graphite2): $(graphite2)-src $(graphite2)-unpack $(graphite2)-patch $(graphite2)-build $(graphite2)-check $(graphite2)-install $(graphite2)-modulefile
