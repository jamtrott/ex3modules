# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# superlu_dist-64-8.1.2

superlu_dist-64-8.1.2-version = 8.1.2
superlu_dist-64-8.1.2 = superlu_dist-64-$(superlu_dist-64-8.1.2-version)
$(superlu_dist-64-8.1.2)-description = MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory
$(superlu_dist-64-8.1.2)-url = https://github.com/xiaoyeli/superlu_dist/
$(superlu_dist-64-8.1.2)-srcurl = https://github.com/xiaoyeli/superlu_dist/archive/v$(superlu_dist-64-8.1.2-version).tar.gz
$(superlu_dist-64-8.1.2)-builddeps = $(cmake) $(blas) $(mpi) $(metis-64) $(parmetis-64) $(combblas) $(cuda-toolkit)
$(superlu_dist-64-8.1.2)-prereqs = $(blas) $(mpi) $(metis-64) $(parmetis-64) $(combblas) $(cuda-toolkit)
$(superlu_dist-64-8.1.2)-src = $($(superlu_dist-src-8.1.2)-src)
$(superlu_dist-64-8.1.2)-srcdir = $(pkgsrcdir)/$(superlu_dist-64-8.1.2)
$(superlu_dist-64-8.1.2)-builddir = $($(superlu_dist-64-8.1.2)-srcdir)/build
$(superlu_dist-64-8.1.2)-modulefile = $(modulefilesdir)/$(superlu_dist-64-8.1.2)
$(superlu_dist-64-8.1.2)-prefix = $(pkgdir)/$(superlu_dist-64-8.1.2)

$($(superlu_dist-64-8.1.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist-64-8.1.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist-64-8.1.2)-prefix)/.pkgunpack: $$($(superlu_dist-64-8.1.2)-src) $($(superlu_dist-64-8.1.2)-srcdir)/.markerfile $($(superlu_dist-64-8.1.2)-prefix)/.markerfile $$(foreach dep,$$($(superlu_dist-64-8.1.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(superlu_dist-64-8.1.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(superlu_dist-64-8.1.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-64-8.1.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-64-8.1.2)-prefix)/.pkgunpack
	sed -i 's,set(CMAKE_CXX_STANDARD 11),set(CMAKE_CXX_STANDARD 14),' $($(superlu_dist-64-8.1.2)-srcdir)/CMakeLists.txt
	@touch $@

ifneq ($($(superlu_dist-64-8.1.2)-builddir),$($(superlu_dist-64-8.1.2)-srcdir))
$($(superlu_dist-64-8.1.2)-builddir)/.markerfile: $($(superlu_dist-64-8.1.2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(superlu_dist-64-8.1.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-64-8.1.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-64-8.1.2)-builddir)/.markerfile $($(superlu_dist-64-8.1.2)-prefix)/.pkgpatch
	cd $($(superlu_dist-64-8.1.2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist-64-8.1.2)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(superlu_dist-64-8.1.2)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Debug \
			-DBUILD_SHARED_LIBS=TRUE \
			-DXSDK_INDEX_SIZE=64 \
			-Denable_openmp=ON \
			-DTPL_ENABLE_INTERNAL_BLASLIB=OFF \
			-DTPL_BLAS_LIBRARIES="$${BLASDIR}/lib$${BLASLIB}.so" \
			-DTPL_LAPACK_LIBRARIES="$${BLASDIR}/lib$${BLASLIB}.so" \
			-DTPL_PARMETIS_INCLUDE_DIRS="$${PARMETIS_INCDIR};$${METIS_INCDIR}" \
			-DTPL_PARMETIS_LIBRARIES="$${PARMETIS_LIBDIR}/libparmetis.so;$${METIS_LIBDIR}/libmetis.so" \
			-DTPL_ENABLE_COMBBLASLIB=ON \
			-DTPL_COMBBLAS_INCLUDE_DIRS="$${COMBBLAS_INCDIR}/CombBLAS;$${COMBBLAS_INCDIR}/CombBLAS/BipartiteMatchings" \
			-DTPL_COMBBLAS_LIBRARIES="$${COMBBLAS_LIBDIR}/libCombBLAS.so" \
			$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo -DTPL_ENABLE_CUDALIB=ON -DCUDAToolkit_LIBRARY_ROOT="$${CUDA_TOOLKIT_LIBDIR}") \
			-DCMAKE_C_COMPILER=$${MPICC} \
			-DCMAKE_CXX_COMPILER=$${MPICXX} \
			-DCMAKE_C_FLAGS="-DPRNTlevel=1 -DDEBUGlevel=1" && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(superlu_dist-64-8.1.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-64-8.1.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-64-8.1.2)-builddir)/.markerfile $($(superlu_dist-64-8.1.2)-prefix)/.pkgbuild
	@touch $@

$($(superlu_dist-64-8.1.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-64-8.1.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-64-8.1.2)-builddir)/.markerfile $($(superlu_dist-64-8.1.2)-prefix)/.pkgcheck
	cd $($(superlu_dist-64-8.1.2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist-64-8.1.2)-builddeps) && \
		$(MAKE) install && \
	$(INSTALL) -d "$($(superlu_dist-64-8.1.2)-prefix)/bin"
	cd "$($(superlu_dist-64-8.1.2)-builddir)/EXAMPLE" && \
		$(INSTALL) pddrive pddrive1 pddrive1_ABglobal \
			pddrive2 pddrive2_ABglobal pddrive3 \
			pddrive3_ABglobal pddrive3d pddrive3d1 \
			pddrive3d2 pddrive3d3 pddrive4 pddrive4_ABglobal \
			pddrive_ABglobal pddrive_spawn psdrive psdrive1 \
			psdrive2 psdrive3 psdrive3d psdrive3d1 psdrive3d2 \
			psdrive3d3 psdrive4 pzdrive pzdrive1 pzdrive1_ABglobal \
			pzdrive2 pzdrive2_ABglobal pzdrive3 pzdrive3_ABglobal \
			pzdrive3d pzdrive3d1 pzdrive3d2 pzdrive3d3 pzdrive4 \
			pzdrive4_ABglobal pzdrive_ABglobal pzdrive_spawn \
			"$($(superlu_dist-64-8.1.2)-prefix)/bin"
	@touch $@

$($(superlu_dist-64-8.1.2)-modulefile): $(modulefilesdir)/.markerfile $($(superlu_dist-64-8.1.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(superlu_dist-64-8.1.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(superlu_dist-64-8.1.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(superlu_dist-64-8.1.2)-description)\"" >>$@
	echo "module-whatis \"$($(superlu_dist-64-8.1.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(superlu_dist-64-8.1.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUPERLU_DIST_ROOT $($(superlu_dist-64-8.1.2)-prefix)" >>$@
	echo "setenv SUPERLU_DIST_INCDIR $($(superlu_dist-64-8.1.2)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_INCLUDEDIR $($(superlu_dist-64-8.1.2)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_LIBDIR $($(superlu_dist-64-8.1.2)-prefix)/lib" >>$@
	echo "setenv SUPERLU_DIST_LIBRARYDIR $($(superlu_dist-64-8.1.2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(superlu_dist-64-8.1.2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(superlu_dist-64-8.1.2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(superlu_dist-64-8.1.2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(superlu_dist-64-8.1.2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(superlu_dist-64-8.1.2)-prefix)/lib" >>$@
	echo "set MSG \"$(superlu_dist-64-8.1.2)\"" >>$@

$(superlu_dist-64-8.1.2)-src: $$($(superlu_dist-64-8.1.2)-src)
$(superlu_dist-64-8.1.2)-unpack: $($(superlu_dist-64-8.1.2)-prefix)/.pkgunpack
$(superlu_dist-64-8.1.2)-patch: $($(superlu_dist-64-8.1.2)-prefix)/.pkgpatch
$(superlu_dist-64-8.1.2)-build: $($(superlu_dist-64-8.1.2)-prefix)/.pkgbuild
$(superlu_dist-64-8.1.2)-check: $($(superlu_dist-64-8.1.2)-prefix)/.pkgcheck
$(superlu_dist-64-8.1.2)-install: $($(superlu_dist-64-8.1.2)-prefix)/.pkginstall
$(superlu_dist-64-8.1.2)-modulefile: $($(superlu_dist-64-8.1.2)-modulefile)
$(superlu_dist-64-8.1.2)-clean:
	rm -rf $($(superlu_dist-64-8.1.2)-modulefile)
	rm -rf $($(superlu_dist-64-8.1.2)-prefix)
	rm -rf $($(superlu_dist-64-8.1.2)-builddir)
	rm -rf $($(superlu_dist-64-8.1.2)-srcdir)
	rm -rf $($(superlu_dist-64-8.1.2)-src)
$(superlu_dist-64-8.1.2): $(superlu_dist-64-8.1.2)-src $(superlu_dist-64-8.1.2)-unpack $(superlu_dist-64-8.1.2)-patch $(superlu_dist-64-8.1.2)-build $(superlu_dist-64-8.1.2)-check $(superlu_dist-64-8.1.2)-install $(superlu_dist-64-8.1.2)-modulefile
