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
# fmt-8.0.1

fmt-version = 8.0.1
fmt = fmt-$(fmt-version)
$(fmt)-description = Open-source formatting library providing a fast and safe alternative to C stdio and C++ iostreams
$(fmt)-url = https://fmt.dev/
$(fmt)-srcurl = https://github.com/fmtlib/fmt/releases/download/${fmt-version}/fmt-${fmt-version}.zip
$(fmt)-builddeps =
$(fmt)-prereqs =
$(fmt)-src = $(pkgsrcdir)/$(notdir $($(fmt)-srcurl))
$(fmt)-srcdir = $(pkgsrcdir)/$(fmt)
$(fmt)-builddir = $($(fmt)-srcdir)/fmt-$(fmt-version)/build
$(fmt)-modulefile = $(modulefilesdir)/$(fmt)
$(fmt)-prefix = $(pkgdir)/$(fmt)

$($(fmt)-src): $(dir $($(fmt)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fmt)-srcurl)

$($(fmt)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fmt)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fmt)-prefix)/.pkgunpack: $$($(fmt)-src) $($(fmt)-srcdir)/.markerfile $($(fmt)-prefix)/.markerfile $$(foreach dep,$$($(fmt)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(fmt)-srcdir) && unzip -o $<
	@touch $@

$($(fmt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fmt)-builddeps),$(modulefilesdir)/$$(dep)) $($(fmt)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(fmt)-builddir),$($(fmt)-srcdir))
$($(fmt)-builddir)/.markerfile: $($(fmt)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(fmt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fmt)-builddeps),$(modulefilesdir)/$$(dep)) $($(fmt)-builddir)/.markerfile $($(fmt)-prefix)/.pkgpatch
	cd $($(fmt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fmt)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(fmt)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE)
	@touch $@

$($(fmt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fmt)-builddeps),$(modulefilesdir)/$$(dep)) $($(fmt)-builddir)/.markerfile $($(fmt)-prefix)/.pkgbuild
	@touch $@

$($(fmt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fmt)-builddeps),$(modulefilesdir)/$$(dep)) $($(fmt)-builddir)/.markerfile $($(fmt)-prefix)/.pkgcheck
	cd $($(fmt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fmt)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fmt)-modulefile): $(modulefilesdir)/.markerfile $($(fmt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fmt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fmt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fmt)-description)\"" >>$@
	echo "module-whatis \"$($(fmt)-url)\"" >>$@
	printf "$(foreach prereq,$($(fmt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FMT_ROOT $($(fmt)-prefix)" >>$@
	echo "setenv FMT_INCDIR $($(fmt)-prefix)/include" >>$@
	echo "setenv FMT_INCLUDEDIR $($(fmt)-prefix)/include" >>$@
	echo "setenv FMT_LIBDIR $($(fmt)-prefix)/lib" >>$@
	echo "setenv FMT_LIBRARYDIR $($(fmt)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(fmt)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fmt)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fmt)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fmt)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fmt)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fmt)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_PREFIX_PATH $($(fmt)-prefix)/lib/cmake" >>$@
	echo "set MSG \"$(fmt)\"" >>$@

$(fmt)-src: $$($(fmt)-src)
$(fmt)-unpack: $($(fmt)-prefix)/.pkgunpack
$(fmt)-patch: $($(fmt)-prefix)/.pkgpatch
$(fmt)-build: $($(fmt)-prefix)/.pkgbuild
$(fmt)-check: $($(fmt)-prefix)/.pkgcheck
$(fmt)-install: $($(fmt)-prefix)/.pkginstall
$(fmt)-modulefile: $($(fmt)-modulefile)
$(fmt)-clean:
	rm -rf $($(fmt)-modulefile)
	rm -rf $($(fmt)-prefix)
	rm -rf $($(fmt)-builddir)
	rm -rf $($(fmt)-srcdir)
	rm -rf $($(fmt)-src)
$(fmt): $(fmt)-src $(fmt)-unpack $(fmt)-patch $(fmt)-build $(fmt)-check $(fmt)-install $(fmt)-modulefile
