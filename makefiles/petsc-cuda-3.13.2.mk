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
# petsc-cuda-3.13.2

petsc-cuda-version = 3.13.2
petsc-cuda = petsc-cuda-$(petsc-cuda-version)
$(petsc-cuda)-description = Portable, Extensible Toolkit for Scientific Computation (CUDA enabled)
$(petsc-cuda)-url = https://www.mcs.anl.gov/petsc/
$(petsc-cuda)-srcurl =
$(petsc-cuda)-builddeps = $(gcc) $(boost) $(blas) $(openmpi-cuda) $(hwloc) $(hypre-cuda) $(metis) $(mumps-cuda) $(parmetis-cuda) $(python) $(scalapack-cuda) $(scotch-cuda) $(suitesparse) $(superlu) $(superlu_dist-cuda) $(cuda-toolkit) $(patchelf)
$(petsc-cuda)-prereqs = $(gcc) $(boost) $(blas) $(openmpi-cuda) $(hwloc) $(hypre-cuda) $(metis) $(mumps-cuda) $(parmetis-cuda) $(scalapack-cuda) $(scotch-cuda) $(suitesparse) $(superlu) $(superlu_dist-cuda) $(cuda-toolkit)
$(petsc-cuda)-src = $($(petsc-src)-src)
$(petsc-cuda)-srcdir = $(pkgsrcdir)/$(petsc-cuda)
$(petsc-cuda)-modulefile = $(modulefilesdir)/$(petsc-cuda)
$(petsc-cuda)-prefix = $(pkgdir)/$(petsc-cuda)

$($(petsc-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-cuda)-prefix)/.pkgunpack: $$($(petsc-cuda)-src) $($(petsc-cuda)-srcdir)/.markerfile $($(petsc-cuda)-prefix)/.markerfile
	tar -C $($(petsc-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc-cuda)-srcdir)/0001-configure-Don-t-require-libcuda.patch: $($(petsc-cuda)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo "From 9fc691131e85e7ecd7a35e34b09e4a959ba013eb Mon Sep 17 00:00:00 2001" >>$@.tmp
	@echo "From: "James D. Trotter" <james@simula.no>" >>$@.tmp
	@echo "Date: Sat, 13 Jun 2020 16:56:23 +0200" >>$@.tmp
	@echo "Subject: [PATCH] configure: Don't require libcuda" >>$@.tmp
	@echo "" >>$@.tmp
	@echo "---" >>$@.tmp
	@echo " config/BuildSystem/config/packages/cuda.py | 8 ++++----" >>$@.tmp
	@echo " 1 file changed, 4 insertions(+), 4 deletions(-)" >>$@.tmp
	@echo "" >>$@.tmp
	@echo "diff --git a/config/BuildSystem/config/packages/cuda.py b/config/BuildSystem/config/packages/cuda.py" >>$@.tmp
	@echo "index 733c8c23f7..4c88798fce 100644" >>$@.tmp
	@echo "--- a/config/BuildSystem/config/packages/cuda.py" >>$@.tmp
	@echo "+++ b/config/BuildSystem/config/packages/cuda.py" >>$@.tmp
	@echo "@@ -8,10 +8,10 @@ class Configure(config.package.Package):" >>$@.tmp
	@echo "     self.versionname      = 'CUDA_VERSION'" >>$@.tmp
	@echo "     self.versioninclude   = 'cuda.h'" >>$@.tmp
	@echo "     self.requiresversion  = 1" >>$@.tmp
	@echo "-    self.functions        = ['cublasInit', 'cufftDestroy','cuInit']" >>$@.tmp
	@echo "-    self.includes         = ['cublas.h','cufft.h','cusparse.h','cusolverDn.h','thrust/version.h']" >>$@.tmp
	@echo "-    self.liblist          = [['libcufft.a', 'libcublas.a','libcudart.a','libcusparse.a','libcusolver.a','libcuda.a']," >>$@.tmp
	@echo "-                             ['cufft.lib','cublas.lib','cudart.lib','cusparse.lib','cusolver.lib','cuda.lib']]" >>$@.tmp
	@echo "+    self.functions        = ['cublasInit', 'cufftDestroy','cudaSetDevice']" >>$@.tmp
	@echo "+    self.includes         = ['cuda_runtime.h', 'cublas.h','cufft.h','cusparse.h','cusolverDn.h','thrust/version.h']" >>$@.tmp
	@echo "+    self.liblist          = [['libcufft.a', 'libcublas.a','libcudart.a','libcusparse.a','libcusolver.a']," >>$@.tmp
	@echo "+                             ['cufft.lib','cublas.lib','cudart.lib','cusparse.lib','cusolver.lib']]" >>$@.tmp
	@echo "     self.precisions       = ['single','double']" >>$@.tmp
	@echo "     self.cxx              = 0" >>$@.tmp
	@echo "     self.complex          = 1" >>$@.tmp
	@echo "-- " >>$@.tmp
	@echo "2.17.1" >>$@.tmp
	@mv $@.tmp $@

$($(petsc-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda)-prefix)/.pkgunpack $($(petsc-cuda)-srcdir)/0001-configure-Don-t-require-libcuda.patch
	cd $($(petsc-cuda)-srcdir) && \
		patch -f -p1 <0001-configure-Don-t-require-libcuda.patch
	@touch $@

$($(petsc-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda)-prefix)/.pkgpatch
	cd $($(petsc-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-cuda)-builddeps) && \
		python3 ./configure MAKEFLAGS="$(MAKEFLAGS)" \
			--prefix=$($(petsc-cuda)-prefix) \
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
			--with-cuda=1 --with-cuda-dir="$${CUDA_TOOLKIT_ROOT}" \
			--with-x=0 \
			--with-debugging=0 \
			COPTFLAGS="-O3 -g" \
			CXXOPTFLAGS="-O3 -g" \
			FOPTFLAGS="-O3" \
			CUDAFLAGS="--compiler-bindir=$${CC}" && \
		$(MAKE)
	@touch $@

$($(petsc-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda)-prefix)/.pkgbuild
	cd $($(petsc-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-cuda)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-cuda)-prefix)/.pkgcheck
	cd $($(petsc-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-cuda)-builddeps) && \
		$(MAKE) install && \
		patchelf --add-needed libcuda.so "$($(petsc-cuda)-prefix)/lib/libpetsc.so"
	@touch $@

$($(petsc-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(petsc-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(petsc-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc-cuda)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc-cuda)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc-cuda)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc-cuda)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc-cuda)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc-cuda)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc-cuda)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc-cuda)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc-cuda)\"" >>$@

$(petsc-cuda)-src: $$($(petsc)-src)
$(petsc-cuda)-unpack: $($(petsc-cuda)-prefix)/.pkgunpack
$(petsc-cuda)-patch: $($(petsc-cuda)-prefix)/.pkgpatch
$(petsc-cuda)-build: $($(petsc-cuda)-prefix)/.pkgbuild
$(petsc-cuda)-check: $($(petsc-cuda)-prefix)/.pkgcheck
$(petsc-cuda)-install: $($(petsc-cuda)-prefix)/.pkginstall
$(petsc-cuda)-modulefile: $($(petsc-cuda)-modulefile)
$(petsc-cuda)-clean:
	rm -rf $($(petsc-cuda)-modulefile)
	rm -rf $($(petsc-cuda)-prefix)
	rm -rf $($(petsc-cuda)-srcdir)
$(petsc-cuda): $(petsc-cuda)-src $(petsc-cuda)-unpack $(petsc-cuda)-patch $(petsc-cuda)-build $(petsc-cuda)-check $(petsc-cuda)-install $(petsc-cuda)-modulefile
