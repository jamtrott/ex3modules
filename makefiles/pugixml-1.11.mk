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
# pugixml-1.11

pugixml-version = 1.11
pugixml = pugixml-$(pugixml-version)
$(pugixml)-description = Light-weight, simple and fast XML parser for C++ with XPath support
$(pugixml)-url = https://pugixml.org/
$(pugixml)-srcurl = http://github.com/zeux/pugixml/releases/download/v1.11/pugixml-1.11.tar.gz
$(pugixml)-builddeps =
$(pugixml)-prereqs =
$(pugixml)-src = $(pkgsrcdir)/$(notdir $($(pugixml)-srcurl))
$(pugixml)-srcdir = $(pkgsrcdir)/$(pugixml)
$(pugixml)-builddir = $($(pugixml)-srcdir)/build
$(pugixml)-modulefile = $(modulefilesdir)/$(pugixml)
$(pugixml)-prefix = $(pkgdir)/$(pugixml)

$($(pugixml)-src): $(dir $($(pugixml)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pugixml)-srcurl)

$($(pugixml)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pugixml)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pugixml)-prefix)/.pkgunpack: $$($(pugixml)-src) $($(pugixml)-srcdir)/.markerfile $($(pugixml)-prefix)/.markerfile
	tar -C $($(pugixml)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pugixml)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pugixml)-builddeps),$(modulefilesdir)/$$(dep)) $($(pugixml)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(pugixml)-builddir),$($(pugixml)-srcdir))
$($(pugixml)-builddir)/.markerfile: $($(pugixml)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pugixml)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pugixml)-builddeps),$(modulefilesdir)/$$(dep)) $($(pugixml)-builddir)/.markerfile $($(pugixml)-prefix)/.pkgpatch
	cd $($(pugixml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pugixml)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(pugixml)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE)
	@touch $@

$($(pugixml)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pugixml)-builddeps),$(modulefilesdir)/$$(dep)) $($(pugixml)-builddir)/.markerfile $($(pugixml)-prefix)/.pkgbuild
	@touch $@

$($(pugixml)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pugixml)-builddeps),$(modulefilesdir)/$$(dep)) $($(pugixml)-builddir)/.markerfile $($(pugixml)-prefix)/.pkgcheck
	cd $($(pugixml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pugixml)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(pugixml)-modulefile): $(modulefilesdir)/.markerfile $($(pugixml)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pugixml)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pugixml)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pugixml)-description)\"" >>$@
	echo "module-whatis \"$($(pugixml)-url)\"" >>$@
	printf "$(foreach prereq,$($(pugixml)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PUGIXML_ROOT $($(pugixml)-prefix)" >>$@
	echo "setenv PUGIXML_INCDIR $($(pugixml)-prefix)/include" >>$@
	echo "setenv PUGIXML_INCLUDEDIR $($(pugixml)-prefix)/include" >>$@
	echo "setenv PUGIXML_LIBDIR $($(pugixml)-prefix)/lib" >>$@
	echo "setenv PUGIXML_LIBRARYDIR $($(pugixml)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pugixml)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pugixml)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pugixml)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pugixml)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pugixml)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pugixml)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_PREFIX_PATH $($(pugixml)-prefix)/lib/cmake" >>$@
	echo "set MSG \"$(pugixml)\"" >>$@

$(pugixml)-src: $$($(pugixml)-src)
$(pugixml)-unpack: $($(pugixml)-prefix)/.pkgunpack
$(pugixml)-patch: $($(pugixml)-prefix)/.pkgpatch
$(pugixml)-build: $($(pugixml)-prefix)/.pkgbuild
$(pugixml)-check: $($(pugixml)-prefix)/.pkgcheck
$(pugixml)-install: $($(pugixml)-prefix)/.pkginstall
$(pugixml)-modulefile: $($(pugixml)-modulefile)
$(pugixml)-clean:
	rm -rf $($(pugixml)-modulefile)
	rm -rf $($(pugixml)-prefix)
	rm -rf $($(pugixml)-builddir)
	rm -rf $($(pugixml)-srcdir)
	rm -rf $($(pugixml)-src)
$(pugixml): $(pugixml)-src $(pugixml)-unpack $(pugixml)-patch $(pugixml)-build $(pugixml)-check $(pugixml)-install $(pugixml)-modulefile
