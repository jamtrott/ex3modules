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
# fenics-dolfinx-0.3.0

fenics-dolfinx-0.3.0-version = 0.3.0
fenics-dolfinx-0.3.0 = fenics-dolfinx-$(fenics-dolfinx-0.3.0-version)
$(fenics-dolfinx-0.3.0)-description = C++ interface to the FEniCS computing platform for solving partial differential equations (Experimental)
$(fenics-dolfinx-0.3.0)-url = https://fenicsproject.org/
$(fenics-dolfinx-0.3.0)-srcurl =
$(fenics-dolfinx-0.3.0)-builddeps = $(cmake) $(ninja) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-ufl-2021.1.0) $(python-fenics-ffcx-0.3.0) $(python-pytest) $(xtensor) $(xtensor-blas) $(fenics-basix-0.3.0) $(gcc-10.1.0)
$(fenics-dolfinx-0.3.0)-prereqs = $(libstdcxx) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-ufl-2021.1.0) $(python-fenics-ffcx-0.3.0) $(xtensor) $(xtensor-blas) $(fenics-basix-0.3.0)
$(fenics-dolfinx-0.3.0)-src = $($(fenics-dolfinx-src-0.3.0)-src)
$(fenics-dolfinx-0.3.0)-srcdir = $(pkgsrcdir)/$(fenics-dolfinx-0.3.0)
$(fenics-dolfinx-0.3.0)-builddir = $($(fenics-dolfinx-0.3.0)-srcdir)/cpp/build
$(fenics-dolfinx-0.3.0)-modulefile = $(modulefilesdir)/$(fenics-dolfinx-0.3.0)
$(fenics-dolfinx-0.3.0)-prefix = $(pkgdir)/$(fenics-dolfinx-0.3.0)

$($(fenics-dolfinx-0.3.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfinx-0.3.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfinx-0.3.0)-prefix)/.pkgunpack: $$($(fenics-dolfinx-0.3.0)-src) $($(fenics-dolfinx-0.3.0)-srcdir)/.markerfile $($(fenics-dolfinx-0.3.0)-prefix)/.markerfile
	tar -C $($(fenics-dolfinx-0.3.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-dolfinx-0.3.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep))
	@touch $@

$($(fenics-dolfinx-0.3.0)-builddir)/.markerfile: $($(fenics-dolfinx-0.3.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfinx-0.3.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-0.3.0)-builddir)/.markerfile $($(fenics-dolfinx-0.3.0)-prefix)/.pkgpatch
	cd $($(fenics-dolfinx-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfinx-0.3.0)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-dolfinx-0.3.0)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
			-DBUILD_SHARED_LIBS=TRUE \
			-DDOLFINX_SKIP_BUILD_TESTS=TRUE \
			-DEIGEN3_INCLUDE_DIR="$${EIGEN_INCDIR}" && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(fenics-dolfinx-0.3.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-0.3.0)-builddir)/.markerfile $($(fenics-dolfinx-0.3.0)-prefix)/.pkgbuild
	@touch $@

$($(fenics-dolfinx-0.3.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-0.3.0)-builddir)/.markerfile $($(fenics-dolfinx-0.3.0)-prefix)/.pkgcheck
	cd $($(fenics-dolfinx-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfinx-0.3.0)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fenics-dolfinx-0.3.0)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-dolfinx-0.3.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-dolfinx-0.3.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-dolfinx-0.3.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-dolfinx-0.3.0)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-dolfinx-0.3.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-dolfinx-0.3.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_DOLFINX_0.3.0_ROOT $($(fenics-dolfinx-0.3.0)-prefix)" >>$@
	echo "setenv FENICS_DOLFINX_0.3.0_INCDIR $($(fenics-dolfinx-0.3.0)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFINX_0.3.0_INCLUDEDIR $($(fenics-dolfinx-0.3.0)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFINX_0.3.0_LIBDIR $($(fenics-dolfinx-0.3.0)-prefix)/lib" >>$@
	echo "setenv FENICS_DOLFINX_0.3.0_LIBRARYDIR $($(fenics-dolfinx-0.3.0)-prefix)/lib" >>$@
	echo "setenv DOLFINX_DIR $($(fenics-dolfinx-0.3.0)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-dolfinx-0.3.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-dolfinx-0.3.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-dolfinx-0.3.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-dolfinx-0.3.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-dolfinx-0.3.0)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-dolfinx-0.3.0)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-dolfinx-0.3.0)-prefix)/share/dolfinx/cmake" >>$@
	echo "set MSG \"$(fenics-dolfinx-0.3.0)\"" >>$@

$(fenics-dolfinx-0.3.0)-src: $($(fenics-dolfinx-0.3.0)-src)
$(fenics-dolfinx-0.3.0)-unpack: $($(fenics-dolfinx-0.3.0)-prefix)/.pkgunpack
$(fenics-dolfinx-0.3.0)-patch: $($(fenics-dolfinx-0.3.0)-prefix)/.pkgpatch
$(fenics-dolfinx-0.3.0)-build: $($(fenics-dolfinx-0.3.0)-prefix)/.pkgbuild
$(fenics-dolfinx-0.3.0)-check: $($(fenics-dolfinx-0.3.0)-prefix)/.pkgcheck
$(fenics-dolfinx-0.3.0)-install: $($(fenics-dolfinx-0.3.0)-prefix)/.pkginstall
$(fenics-dolfinx-0.3.0)-modulefile: $($(fenics-dolfinx-0.3.0)-modulefile)
$(fenics-dolfinx-0.3.0)-clean:
	rm -rf $($(fenics-dolfinx-0.3.0)-modulefile)
	rm -rf $($(fenics-dolfinx-0.3.0)-prefix)
	rm -rf $($(fenics-dolfinx-0.3.0)-builddir)
	rm -rf $($(fenics-dolfinx-0.3.0)-srcdir)
$(fenics-dolfinx-0.3.0): $(fenics-dolfinx-0.3.0)-src $(fenics-dolfinx-0.3.0)-unpack $(fenics-dolfinx-0.3.0)-patch $(fenics-dolfinx-0.3.0)-build $(fenics-dolfinx-0.3.0)-check $(fenics-dolfinx-0.3.0)-install $(fenics-dolfinx-0.3.0)-modulefile
