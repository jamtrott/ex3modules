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
# petsc-32-3.17.4

petsc-32-3.17.4-version = 3.17.4
petsc-32-3.17.4 = petsc-32-$(petsc-32-3.17.4-version)
$(petsc-32-3.17.4)-description = Portable, Extensible Toolkit for Scientific Computation
$(petsc-32-3.17.4)-url = https://www.mcs.anl.gov/petsc/
$(petsc-32-3.17.4)-srcurl =
$(petsc-32-3.17.4)-builddeps = $(boost) $(blas) $(mpi) $(hwloc) $(hypre-32) $(metis-32) $(mumps-32) $(parmetis-32) $(python) $(scalapack) $(scotch) $(suitesparse-32) $(superlu) $(superlu_dist-32) $(cuda-toolkit) $(kokkos) $(kokkos-kernels) $(tetgen)
$(petsc-32-3.17.4)-prereqs = $(boost) $(blas) $(mpi) $(hwloc) $(hypre-32) $(metis-32) $(mumps-32) $(parmetis-32) $(scalapack) $(scotch) $(suitesparse-32) $(superlu) $(superlu_dist-32) $(cuda-toolkit) $(kokkos) $(kokkos-kernels) $(tetgen)
$(petsc-32-3.17.4)-src = $($(petsc-src-3.17.4)-src)
$(petsc-32-3.17.4)-srcdir = $(pkgsrcdir)/$(petsc-32-3.17.4)
$(petsc-32-3.17.4)-modulefile = $(modulefilesdir)/$(petsc-32-3.17.4)
$(petsc-32-3.17.4)-prefix = $(pkgdir)/$(petsc-32-3.17.4)

$($(petsc-32-3.17.4)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-32-3.17.4)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-32-3.17.4)-prefix)/.pkgunpack: $$($(petsc-32-3.17.4)-src) $($(petsc-32-3.17.4)-srcdir)/.markerfile $($(petsc-32-3.17.4)-prefix)/.markerfile $$(foreach dep,$$($(petsc-32-3.17.4)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(petsc-32-3.17.4)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc-32-3.17.4)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-32-3.17.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-32-3.17.4)-prefix)/.pkgunpack
	@touch $@

$($(petsc-32-3.17.4)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-32-3.17.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-32-3.17.4)-prefix)/.pkgpatch
	cd $($(petsc-32-3.17.4)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-32-3.17.4)-builddeps) && \
		$(PYTHON) ./configure MAKEFLAGS="${MAKEFLAGS}" \
			--prefix=$($(petsc-32-3.17.4)-prefix) \
			--with-debugging=0 \
			--with-openmp=1 \
			--with-blaslapack-lib="$${BLASDIR}/lib$${BLASLIB}.so" \
			--with-boost --with-boost-dir="$${BOOST_ROOT}" \
			$$([ ! -z "$${HWLOC_ROOT}" ] && echo --with-hwloc --with-hwloc-dir="$${HWLOC_ROOT}") \
			--with-hypre --with-hypre-dir="$${HYPRE_ROOT}" \
			--with-metis --with-metis-dir="$${METIS_ROOT}" \
			--with-mpi --with-mpi-dir="$${MPI_HOME}" \
			--with-mumps --with-mumps-dir="$${MUMPS_ROOT}" \
			--with-parmetis --with-parmetis-dir="$${PARMETIS_ROOT}" \
			--with-ptscotch --with-ptscotch-dir="$${SCOTCH_ROOT}" --with-ptscotch-libs=libz.so \
			--with-scalapack --with-scalapack-dir="$${SCALAPACK_ROOT}" \
			--with-suitesparse --with-suitesparse-dir="$${SUITESPARSE_ROOT}" \
			--with-superlu --with-superlu-dir="$${SUPERLU_ROOT}" \
			--with-superlu_dist --with-superlu_dist-dir="$${SUPERLU_DIST_ROOT}" \
			--with-tetgen --with-tetgen-dir="$${TETGEN_ROOT}" \
			--with-kokkos --with-kokkos-dir="$${KOKKOS_ROOT}" \
			--with-kokkos-kernels --with-kokkos-kernels-dir="$${KOKKOS_KERNELS_ROOT}" \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --with-cuda=1 --with-cuda-arch="$${PETSC_CUDA_ARCH}" --with-cuda-dir="$${CUDA_TOOLKIT_ROOT}" CUDAOPTFLAGS="-O3 -g" || echo --with-cuda=0) \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo --with-hip=1 --with-hip-dir="$${ROCM_ROOT}" --with-hipc="$${HIPCC}" || echo --with-hip=0) \
			COPTFLAGS="-O3 -g" CXXOPTFLAGS="-O3 -g" FOPTFLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(petsc-32-3.17.4)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-32-3.17.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-32-3.17.4)-prefix)/.pkgbuild
	cd $($(petsc-32-3.17.4)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-32-3.17.4)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc-32-3.17.4)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-32-3.17.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-32-3.17.4)-prefix)/.pkgcheck
	cd $($(petsc-32-3.17.4)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-32-3.17.4)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(petsc-32-3.17.4)-modulefile): $(modulefilesdir)/.markerfile $($(petsc-32-3.17.4)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc-32-3.17.4)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc-32-3.17.4)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc-32-3.17.4)-description)\"" >>$@
	echo "module-whatis \"$($(petsc-32-3.17.4)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc-32-3.17.4)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc-32-3.17.4)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc-32-3.17.4)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc-32-3.17.4)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc-32-3.17.4)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc-32-3.17.4)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc-32-3.17.4)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc-32-3.17.4)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc-32-3.17.4)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc-32-3.17.4)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc-32-3.17.4)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc-32-3.17.4)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc-32-3.17.4)\"" >>$@

$(petsc-32-3.17.4)-src: $$($(petsc)-src)
$(petsc-32-3.17.4)-unpack: $($(petsc-32-3.17.4)-prefix)/.pkgunpack
$(petsc-32-3.17.4)-patch: $($(petsc-32-3.17.4)-prefix)/.pkgpatch
$(petsc-32-3.17.4)-build: $($(petsc-32-3.17.4)-prefix)/.pkgbuild
$(petsc-32-3.17.4)-check: $($(petsc-32-3.17.4)-prefix)/.pkgcheck
$(petsc-32-3.17.4)-install: $($(petsc-32-3.17.4)-prefix)/.pkginstall
$(petsc-32-3.17.4)-modulefile: $($(petsc-32-3.17.4)-modulefile)
$(petsc-32-3.17.4)-clean:
	rm -rf $($(petsc-32-3.17.4)-modulefile)
	rm -rf $($(petsc-32-3.17.4)-prefix)
	rm -rf $($(petsc-32-3.17.4)-srcdir)
$(petsc-32-3.17.4): $(petsc-32-3.17.4)-src $(petsc-32-3.17.4)-unpack $(petsc-32-3.17.4)-patch $(petsc-32-3.17.4)-build $(petsc-32-3.17.4)-check $(petsc-32-3.17.4)-install $(petsc-32-3.17.4)-modulefile
