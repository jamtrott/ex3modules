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
# kokkos-3.6.01

kokkos-version = 3.6.01
kokkos = kokkos-$(kokkos-version)
$(kokkos)-description = C++ Performance Portability Programming EcoSystem
$(kokkos)-url = https://github.com/kokkos/kokkos
$(kokkos)-srcurl = https://github.com/kokkos/kokkos/archive/refs/tags/$(kokkos-version).tar.gz
$(kokkos)-builddeps = $(cmake) $(hwloc)
$(kokkos)-prereqs = $(hwloc)
$(kokkos)-src = $(pkgsrcdir)/kokkos-$(notdir $($(kokkos)-srcurl))
$(kokkos)-srcdir = $(pkgsrcdir)/$(kokkos)
$(kokkos)-builddir = $($(kokkos)-srcdir)/build
$(kokkos)-modulefile = $(modulefilesdir)/$(kokkos)
$(kokkos)-prefix = $(pkgdir)/$(kokkos)

$($(kokkos)-src): $(dir $($(kokkos)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(kokkos)-srcurl)

$($(kokkos)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(kokkos)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(kokkos)-prefix)/.pkgunpack: $$($(kokkos)-src) $($(kokkos)-srcdir)/.markerfile $($(kokkos)-prefix)/.markerfile $$(foreach dep,$$($(kokkos)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(kokkos)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(kokkos)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(kokkos)-builddir),$($(kokkos)-srcdir))
$($(kokkos)-builddir)/.markerfile: $($(kokkos)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(kokkos)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos)-builddir)/.markerfile $($(kokkos)-prefix)/.pkgpatch
	cd $($(kokkos)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(kokkos)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(kokkos)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=ON \
			-DKokkos_ENABLE_SERIAL=On \
			-DKokkos_ENABLE_HWLOC=On \
			-DKokkos_HWLOC_DIR="$${HWLOC_ROOT}" \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo -DKokkos_ENABLE_CUDA=On -DKokkos_CUDA_DIR="$${CUDA_TOOKIT_ROOT}" -DKokkos_ENABLE_CUDA_LAMBDA=On) \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo -DKokkos_ENABLE_HIP=On) && \
		$(MAKE)
	@touch $@

$($(kokkos)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos)-builddir)/.markerfile $($(kokkos)-prefix)/.pkgbuild
	@touch $@

$($(kokkos)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(kokkos)-builddeps),$(modulefilesdir)/$$(dep)) $($(kokkos)-builddir)/.markerfile $($(kokkos)-prefix)/.pkgcheck
	cd $($(kokkos)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(kokkos)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(kokkos)-modulefile): $(modulefilesdir)/.markerfile $($(kokkos)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(kokkos)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(kokkos)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(kokkos)-description)\"" >>$@
	echo "module-whatis \"$($(kokkos)-url)\"" >>$@
	printf "$(foreach prereq,$($(kokkos)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv KOKKOS_ROOT $($(kokkos)-prefix)" >>$@
	echo "setenv KOKKOS_INCDIR $($(kokkos)-prefix)/include" >>$@
	echo "setenv KOKKOS_INCLUDEDIR $($(kokkos)-prefix)/include" >>$@
	echo "setenv KOKKOS_LIBDIR $($(kokkos)-prefix)/lib" >>$@
	echo "setenv KOKKOS_LIBRARYDIR $($(kokkos)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(kokkos)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(kokkos)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(kokkos)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(kokkos)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(kokkos)-prefix)/lib/cmake/Kokkos" >>$@
	echo "set MSG \"$(kokkos)\"" >>$@

$(kokkos)-src: $$($(kokkos)-src)
$(kokkos)-unpack: $($(kokkos)-prefix)/.pkgunpack
$(kokkos)-patch: $($(kokkos)-prefix)/.pkgpatch
$(kokkos)-build: $($(kokkos)-prefix)/.pkgbuild
$(kokkos)-check: $($(kokkos)-prefix)/.pkgcheck
$(kokkos)-install: $($(kokkos)-prefix)/.pkginstall
$(kokkos)-modulefile: $($(kokkos)-modulefile)
$(kokkos)-clean:
	rm -rf $($(kokkos)-modulefile)
	rm -rf $($(kokkos)-prefix)
	rm -rf $($(kokkos)-builddir)
	rm -rf $($(kokkos)-srcdir)
	rm -rf $($(kokkos)-src)
$(kokkos): $(kokkos)-src $(kokkos)-unpack $(kokkos)-patch $(kokkos)-build $(kokkos)-check $(kokkos)-install $(kokkos)-modulefile
