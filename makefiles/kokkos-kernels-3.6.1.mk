# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# kokkos-kernels-3.6.1

kokkos-kernels-version = 3.6.1
kokkos-kernels = kokkos-kernels-$(kokkos-kernels-version)
$(kokkos-kernels)-description = Math Kernels for Kokkos C++ Performance Portability Programming EcoSystem
$(kokkos-kernels)-url = https://github.com/kokkos/kokkos-kernels
$(kokkos-kernels)-srcurl = https://github.com/kokkos/kokkos-kernels/archive/refs/tags/3.6.01.tar.gz
$(kokkos-kernels)-builddeps = $(cmake) $(kokkos)
$(kokkos-kernels)-prereqs = $(kokkos)
$(kokkos-kernels)-src = $(pkgsrcdir)/kokkos-kernels-$(notdir $($(kokkos-kernels)-srcurl))
$(kokkos-kernels)-srcdir = $(pkgsrcdir)/$(kokkos-kernels)
$(kokkos-kernels)-builddir = $($(kokkos-kernels)-srcdir)/build
$(kokkos-kernels)-modulefile = $(modulefilesdir)/$(kokkos-kernels)
$(kokkos-kernels)-prefix = $(pkgdir)/$(kokkos-kernels)

$($(kokkos-kernels)-src): $(dir $($(kokkos-kernels)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(kokkos-kernels)-srcurl)

$($(kokkos-kernels)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(kokkos-kernels)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(kokkos-kernels)-prefix)/.pkgunpack: $$($(kokkos-kernels)-src) $($(kokkos-kernels)-srcdir)/.markerfile $($(kokkos-kernels)-prefix)/.markerfile $$(foreach dep,$$($(kokkos-kernels)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(kokkos-kernels)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(kokkos-kernels)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos-kernels)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos-kernels)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(kokkos-kernels)-builddir),$($(kokkos-kernels)-srcdir))
$($(kokkos-kernels)-builddir)/.markerfile: $($(kokkos-kernels)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(kokkos-kernels)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos-kernels)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos-kernels)-builddir)/.markerfile $($(kokkos-kernels)-prefix)/.pkgpatch
	cd $($(kokkos-kernels)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(kokkos-kernels)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(kokkos-kernels)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(kokkos-kernels)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos-kernels)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos-kernels)-builddir)/.markerfile $($(kokkos-kernels)-prefix)/.pkgbuild
	@touch $@

$($(kokkos-kernels)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos-kernels)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos-kernels)-builddir)/.markerfile $($(kokkos-kernels)-prefix)/.pkgcheck
	cd $($(kokkos-kernels)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(kokkos-kernels)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(kokkos-kernels)-modulefile): $(modulefilesdir)/.markerfile $($(kokkos-kernels)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(kokkos-kernels)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(kokkos-kernels)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(kokkos-kernels)-description)\"" >>$@
	echo "module-whatis \"$($(kokkos-kernels)-url)\"" >>$@
	printf "$(foreach prereq,$($(kokkos-kernels)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv KOKKOS_KERNELS_ROOT $($(kokkos-kernels)-prefix)" >>$@
	echo "setenv KOKKOS_KERNELS_INCDIR $($(kokkos-kernels)-prefix)/include" >>$@
	echo "setenv KOKKOS_KERNELS_INCLUDEDIR $($(kokkos-kernels)-prefix)/include" >>$@
	echo "setenv KOKKOS_KERNELS_LIBDIR $($(kokkos-kernels)-prefix)/lib" >>$@
	echo "setenv KOKKOS_KERNELS_LIBRARYDIR $($(kokkos-kernels)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(kokkos-kernels)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(kokkos-kernels)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(kokkos-kernels)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(kokkos-kernels)-prefix)/lib/cmake/KokkosKernels" >>$@
	echo "set MSG \"$(kokkos-kernels)\"" >>$@

$(kokkos-kernels)-src: $$($(kokkos-kernels)-src)
$(kokkos-kernels)-unpack: $($(kokkos-kernels)-prefix)/.pkgunpack
$(kokkos-kernels)-patch: $($(kokkos-kernels)-prefix)/.pkgpatch
$(kokkos-kernels)-build: $($(kokkos-kernels)-prefix)/.pkgbuild
$(kokkos-kernels)-check: $($(kokkos-kernels)-prefix)/.pkgcheck
$(kokkos-kernels)-install: $($(kokkos-kernels)-prefix)/.pkginstall
$(kokkos-kernels)-modulefile: $($(kokkos-kernels)-modulefile)
$(kokkos-kernels)-clean:
	rm -rf $($(kokkos-kernels)-modulefile)
	rm -rf $($(kokkos-kernels)-prefix)
	rm -rf $($(kokkos-kernels)-builddir)
	rm -rf $($(kokkos-kernels)-srcdir)
	rm -rf $($(kokkos-kernels)-src)
$(kokkos-kernels): $(kokkos-kernels)-src $(kokkos-kernels)-unpack $(kokkos-kernels)-patch $(kokkos-kernels)-build $(kokkos-kernels)-check $(kokkos-kernels)-install $(kokkos-kernels)-modulefile
