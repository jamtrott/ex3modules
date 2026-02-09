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
# superlu_dist-32-8.1.0

superlu_dist-32-8.1.0-version = 8.1.0
superlu_dist-32-8.1.0 = superlu_dist-32-$(superlu_dist-32-8.1.0-version)
$(superlu_dist-32-8.1.0)-description = MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory
$(superlu_dist-32-8.1.0)-url = https://github.com/xiaoyeli/superlu_dist/
$(superlu_dist-32-8.1.0)-srcurl = https://github.com/xiaoyeli/superlu_dist/archive/v$(superlu_dist-32-8.1.0-version).tar.gz
$(superlu_dist-32-8.1.0)-builddeps = $(cmake) $(blas) $(mpi) $(parmetis) $(combblas) $(cuda-toolkit)
$(superlu_dist-32-8.1.0)-prereqs = $(blas) $(mpi) $(parmetis) $(combblas) $(cuda-toolkit)
$(superlu_dist-32-8.1.0)-src = $($(superlu_dist-src-8.1.0)-src)
$(superlu_dist-32-8.1.0)-srcdir = $(pkgsrcdir)/$(superlu_dist-32-8.1.0)
$(superlu_dist-32-8.1.0)-builddir = $($(superlu_dist-32-8.1.0)-srcdir)/build
$(superlu_dist-32-8.1.0)-modulefile = $(modulefilesdir)/$(superlu_dist-32-8.1.0)
$(superlu_dist-32-8.1.0)-prefix = $(pkgdir)/$(superlu_dist-32-8.1.0)

$($(superlu_dist-32-8.1.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist-32-8.1.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist-32-8.1.0)-prefix)/.pkgunpack: $$($(superlu_dist-32-8.1.0)-src) $($(superlu_dist-32-8.1.0)-srcdir)/.markerfile $($(superlu_dist-32-8.1.0)-prefix)/.markerfile $$(foreach dep,$$($(superlu_dist-32-8.1.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(superlu_dist-32-8.1.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(superlu_dist-32-8.1.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-8.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-8.1.0)-prefix)/.pkgunpack
	sed -i 's,set(CMAKE_CXX_STANDARD 11),set(CMAKE_CXX_STANDARD 14),' $($(superlu_dist-32-8.1.0)-srcdir)/CMakeLists.txt
	@touch $@

ifneq ($($(superlu_dist-32-8.1.0)-builddir),$($(superlu_dist-32-8.1.0)-srcdir))
$($(superlu_dist-32-8.1.0)-builddir)/.markerfile: $($(superlu_dist-32-8.1.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(superlu_dist-32-8.1.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-8.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-8.1.0)-builddir)/.markerfile $($(superlu_dist-32-8.1.0)-prefix)/.pkgpatch
	cd $($(superlu_dist-32-8.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist-32-8.1.0)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(superlu_dist-32-8.1.0)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=TRUE \
			-Denable_openmp=ON \
			-DTPL_ENABLE_INTERNAL_BLASLIB=OFF \
			-DTPL_BLAS_LIBRARIES="$${BLASDIR}/lib$${BLASLIB}.so" \
			-DTPL_LAPACK_LIBRARIES="$${BLASDIR}/lib$${BLASLIB}.so" \
			-DTPL_PARMETIS_INCLUDE_DIRS="$${PARMETIS_INCDIR}" \
			-DTPL_PARMETIS_LIBRARIES="$${PARMETIS_LIBDIR}/libparmetis.so" \
			-DTPL_ENABLE_COMBBLASLIB=ON \
			-DTPL_COMBBLAS_INCLUDE_DIRS="$${COMBBLAS_INCDIR}/CombBLAS;$${COMBBLAS_INCDIR}/CombBLAS/BipartiteMatchings" \
			-DTPL_COMBBLAS_LIBRARIES="$${COMBBLAS_LIBDIR}/libCombBLAS.so" \
			$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo -DTPL_ENABLE_CUDALIB=ON -DCUDAToolkit_LIBRARY_ROOT="$${CUDA_TOOLKIT_LIBDIR}") \
			-DCMAKE_C_COMPILER=$${MPICC} \
			-DCMAKE_CXX_COMPILER=$${MPICXX} && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(superlu_dist-32-8.1.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-8.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-8.1.0)-builddir)/.markerfile $($(superlu_dist-32-8.1.0)-prefix)/.pkgbuild
	@touch $@

$($(superlu_dist-32-8.1.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-8.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-8.1.0)-builddir)/.markerfile $($(superlu_dist-32-8.1.0)-prefix)/.pkgcheck
	cd $($(superlu_dist-32-8.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist-32-8.1.0)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(superlu_dist-32-8.1.0)-modulefile): $(modulefilesdir)/.markerfile $($(superlu_dist-32-8.1.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(superlu_dist-32-8.1.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(superlu_dist-32-8.1.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(superlu_dist-32-8.1.0)-description)\"" >>$@
	echo "module-whatis \"$($(superlu_dist-32-8.1.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(superlu_dist-32-8.1.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUPERLU_DIST_ROOT $($(superlu_dist-32-8.1.0)-prefix)" >>$@
	echo "setenv SUPERLU_DIST_INCDIR $($(superlu_dist-32-8.1.0)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_INCLUDEDIR $($(superlu_dist-32-8.1.0)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_LIBDIR $($(superlu_dist-32-8.1.0)-prefix)/lib" >>$@
	echo "setenv SUPERLU_DIST_LIBRARYDIR $($(superlu_dist-32-8.1.0)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(superlu_dist-32-8.1.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(superlu_dist-32-8.1.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(superlu_dist-32-8.1.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(superlu_dist-32-8.1.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(superlu_dist-32-8.1.0)-prefix)/lib" >>$@
	echo "set MSG \"$(superlu_dist-32-8.1.0)\"" >>$@

$(superlu_dist-32-8.1.0)-src: $$($(superlu_dist-32-8.1.0)-src)
$(superlu_dist-32-8.1.0)-unpack: $($(superlu_dist-32-8.1.0)-prefix)/.pkgunpack
$(superlu_dist-32-8.1.0)-patch: $($(superlu_dist-32-8.1.0)-prefix)/.pkgpatch
$(superlu_dist-32-8.1.0)-build: $($(superlu_dist-32-8.1.0)-prefix)/.pkgbuild
$(superlu_dist-32-8.1.0)-check: $($(superlu_dist-32-8.1.0)-prefix)/.pkgcheck
$(superlu_dist-32-8.1.0)-install: $($(superlu_dist-32-8.1.0)-prefix)/.pkginstall
$(superlu_dist-32-8.1.0)-modulefile: $($(superlu_dist-32-8.1.0)-modulefile)
$(superlu_dist-32-8.1.0)-clean:
	rm -rf $($(superlu_dist-32-8.1.0)-modulefile)
	rm -rf $($(superlu_dist-32-8.1.0)-prefix)
	rm -rf $($(superlu_dist-32-8.1.0)-builddir)
	rm -rf $($(superlu_dist-32-8.1.0)-srcdir)
	rm -rf $($(superlu_dist-32-8.1.0)-src)
$(superlu_dist-32-8.1.0): $(superlu_dist-32-8.1.0)-src $(superlu_dist-32-8.1.0)-unpack $(superlu_dist-32-8.1.0)-patch $(superlu_dist-32-8.1.0)-build $(superlu_dist-32-8.1.0)-check $(superlu_dist-32-8.1.0)-install $(superlu_dist-32-8.1.0)-modulefile
