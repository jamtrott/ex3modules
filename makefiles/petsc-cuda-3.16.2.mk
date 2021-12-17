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
# petsc-cuda-3.16.2

petsc-cuda-3.16.2-version = 3.16.2
petsc-cuda-3.16.2 = petsc-cuda-$(petsc-cuda-3.16.2-version)
$(petsc-cuda-3.16.2)-description = Portable, Extensible Toolkit for Scientific Computation (CUDA enabled)
$(petsc-cuda-3.16.2)-url = https://www.mcs.anl.gov/petsc/
$(petsc-cuda-3.16.2)-srcurl =
$(petsc-cuda-3.16.2)-builddeps = $(boost) $(blas) $(openmpi-cuda) $(hwloc) $(hypre-cuda) $(metis) $(mumps-cuda) $(parmetis-cuda) $(python) $(scalapack-cuda) $(scotch-cuda) $(suitesparse) $(superlu) $(superlu_dist-cuda) $(cuda-toolkit) $(patchelf)
$(petsc-cuda-3.16.2)-prereqs = $(boost) $(blas) $(openmpi-cuda) $(hwloc) $(hypre-cuda) $(metis) $(mumps-cuda) $(parmetis-cuda) $(scalapack-cuda) $(scotch-cuda) $(suitesparse) $(superlu) $(superlu_dist-cuda) $(cuda-toolkit)
$(petsc-cuda-3.16.2)-src = $($(petsc-src-3.16.2)-src)
$(petsc-cuda-3.16.2)-srcdir = $(pkgsrcdir)/$(petsc-cuda-3.16.2)
$(petsc-cuda-3.16.2)-modulefile = $(modulefilesdir)/$(petsc-cuda-3.16.2)
$(petsc-cuda-3.16.2)-prefix = $(pkgdir)/$(petsc-cuda-3.16.2)

$($(petsc-cuda-3.16.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-cuda-3.16.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-cuda-3.16.2)-prefix)/.pkgunpack: $$($(petsc-3.16.2)-src) $($(petsc-cuda-3.16.2)-srcdir)/.markerfile $($(petsc-cuda-3.16.2)-prefix)/.markerfile $$(foreach dep,$$($(petsc-cuda-3.16.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(petsc-cuda-3.16.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc-cuda-3.16.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda-3.16.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda-3.16.2)-prefix)/.pkgunpack
	@touch $@

$($(petsc-cuda-3.16.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda-3.16.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda-3.16.2)-prefix)/.pkgpatch
	cd $($(petsc-cuda-3.16.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-cuda-3.16.2)-builddeps) && \
		python3 ./configure MAKEFLAGS="$(MAKEFLAGS)" \
			--prefix=$($(petsc-cuda-3.16.2)-prefix) \
			--with-openmp=1 \
			--with-blaslapack-lib="$${BLASDIR}/lib$${BLASLIB}.so" \
			--with-boost --with-boost-dir="$${BOOST_ROOT}" \
			--with-hwloc --with-hwloc-dir="$${HWLOC_ROOT}" \
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
			--with-cuda=1 with-cuda-arch=sm_70 --with-cuda-dir="$${CUDA_TOOLKIT_ROOT}" \
			--with-x=0 \
			--with-debugging=0 \
			COPTFLAGS="-O3 -g" \
			CXXOPTFLAGS="-O3 -g" \
			FOPTFLAGS="-O3" \
			CUDAFLAGS="--compiler-bindir=$${CC}" && \
		$(MAKE)
	@touch $@

$($(petsc-cuda-3.16.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda-3.16.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda-3.16.2)-prefix)/.pkgbuild
	cd $($(petsc-cuda-3.16.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-cuda-3.16.2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc-cuda-3.16.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda-3.16.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda-3.16.2)-prefix)/.pkgcheck
	cd $($(petsc-cuda-3.16.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-cuda-3.16.2)-builddeps) && \
		$(MAKE) install && \
		patchelf --add-needed libcuda.so "$($(petsc-cuda-3.16.2)-prefix)/lib/libpetsc.so"
	@touch $@

$($(petsc-cuda-3.16.2)-modulefile): $(modulefilesdir)/.markerfile $($(petsc-cuda-3.16.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc-cuda-3.16.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc-cuda-3.16.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc-cuda-3.16.2)-description)\"" >>$@
	echo "module-whatis \"$($(petsc-cuda-3.16.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc-cuda-3.16.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc-cuda-3.16.2)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc-cuda-3.16.2)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc-cuda-3.16.2)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc-cuda-3.16.2)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc-cuda-3.16.2)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc-cuda-3.16.2)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc-cuda-3.16.2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc-cuda-3.16.2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc-cuda-3.16.2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc-cuda-3.16.2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc-cuda-3.16.2)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc-cuda-3.16.2)\"" >>$@

$(petsc-cuda-3.16.2)-src: $$($(petsc)-src)
$(petsc-cuda-3.16.2)-unpack: $($(petsc-cuda-3.16.2)-prefix)/.pkgunpack
$(petsc-cuda-3.16.2)-patch: $($(petsc-cuda-3.16.2)-prefix)/.pkgpatch
$(petsc-cuda-3.16.2)-build: $($(petsc-cuda-3.16.2)-prefix)/.pkgbuild
$(petsc-cuda-3.16.2)-check: $($(petsc-cuda-3.16.2)-prefix)/.pkgcheck
$(petsc-cuda-3.16.2)-install: $($(petsc-cuda-3.16.2)-prefix)/.pkginstall
$(petsc-cuda-3.16.2)-modulefile: $($(petsc-cuda-3.16.2)-modulefile)
$(petsc-cuda-3.16.2)-clean:
	rm -rf $($(petsc-cuda-3.16.2)-modulefile)
	rm -rf $($(petsc-cuda-3.16.2)-prefix)
	rm -rf $($(petsc-cuda-3.16.2)-srcdir)
$(petsc-cuda-3.16.2): $(petsc-cuda-3.16.2)-src $(petsc-cuda-3.16.2)-unpack $(petsc-cuda-3.16.2)-patch $(petsc-cuda-3.16.2)-build $(petsc-cuda-3.16.2)-check $(petsc-cuda-3.16.2)-install $(petsc-cuda-3.16.2)-modulefile
