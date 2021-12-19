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
# superlu_dist-32-cuda-6.4.0

superlu_dist-32-cuda-version = 6.4.0
superlu_dist-32-cuda = superlu_dist-32-cuda-$(superlu_dist-32-cuda-version)
$(superlu_dist-32-cuda)-description = MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory
$(superlu_dist-32-cuda)-url = https://github.com/xiaoyeli/superlu_dist/
$(superlu_dist-32-cuda)-srcurl = https://github.com/xiaoyeli/superlu_dist/archive/v$(superlu_dist-32-cuda-version).tar.gz
$(superlu_dist-32-cuda)-builddeps = $(cmake) $(blas) $(openmpi-cuda) $(parmetis-cuda) $(combblas-cuda)
$(superlu_dist-32-cuda)-prereqs = $(blas) $(openmpi-cuda) $(parmetis-cuda) $(combblas-cuda)
$(superlu_dist-32-cuda)-src = $($(superlu_dist-src)-src)
$(superlu_dist-32-cuda)-srcdir = $(pkgsrcdir)/$(superlu_dist-32-cuda)
$(superlu_dist-32-cuda)-builddir = $($(superlu_dist-32-cuda)-srcdir)/build
$(superlu_dist-32-cuda)-modulefile = $(modulefilesdir)/$(superlu_dist-32-cuda)
$(superlu_dist-32-cuda)-prefix = $(pkgdir)/$(superlu_dist-32-cuda)

$($(superlu_dist-32-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist-32-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist-32-cuda)-prefix)/.pkgunpack: $$($(superlu_dist-32-cuda)-src) $($(superlu_dist-32-cuda)-srcdir)/.markerfile $($(superlu_dist-32-cuda)-prefix)/.markerfile $$(foreach dep,$$($(superlu_dist-32-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(superlu_dist-32-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(superlu_dist-32-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-cuda)-prefix)/.pkgunpack
	sed -i 's,set(CMAKE_CXX_STANDARD 11),set(CMAKE_CXX_STANDARD 14),' $($(superlu_dist-32-cuda)-srcdir)/CMakeLists.txt
	@touch $@

ifneq ($($(superlu_dist-32-cuda)-builddir),$($(superlu_dist-32-cuda)-srcdir))
$($(superlu_dist-32-cuda)-builddir)/.markerfile: $($(superlu_dist-32-cuda)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(superlu_dist-32-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-cuda)-builddir)/.markerfile $($(superlu_dist-32-cuda)-prefix)/.pkgpatch
	cd $($(superlu_dist-32-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist-32-cuda)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(superlu_dist-32-cuda)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=DEBUG \
			-DBUILD_SHARED_LIBS=TRUE \
			-Denable_openmp=OFF \
			-DTPL_ENABLE_BLASLIB=OFF \
			-DTPL_BLAS_LIBRARIES="$${BLASDIR}/lib$${BLASLIB}.so" \
			-DTPL_LAPACK_LIBRARIES="$${BLASDIR}/lib$${BLASLIB}.so" \
			-DTPL_PARMETIS_INCLUDE_DIRS="$${PARMETIS_INCDIR}" \
			-DTPL_PARMETIS_LIBRARIES="$${PARMETIS_LIBDIR}/libparmetis.so" \
			-DTPL_ENABLE_COMBBLASLIB=ON \
			-DTPL_COMBBLAS_INCLUDE_DIRS="$${COMBBLAS_INCDIR}/CombBLAS;$${COMBBLAS_INCDIR}/CombBLAS/BipartiteMatchings" \
			-DTPL_COMBBLAS_LIBRARIES="$${COMBBLAS_LIBDIR}/libCombBLAS.so" \
			-DHAVE_CUDA=TRUE \
			-DINCS+="$${CUDA_TOOLKIT_INCDIR}" \
			-DLIBS+="-L$${CUDA_TOOLKIT_LIBDIR} -lcublas -lcudart" \
			-DCMAKE_C_COMPILER=$${MPICC} \
			-DCMAKE_CXX_COMPILER=$${MPICXX} \
			-DCMAKE_FC_COMPILER=$${MPIFORT} && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(superlu_dist-32-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-cuda)-builddir)/.markerfile $($(superlu_dist-32-cuda)-prefix)/.pkgbuild
	@touch $@

$($(superlu_dist-32-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist-32-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist-32-cuda)-builddir)/.markerfile $($(superlu_dist-32-cuda)-prefix)/.pkgcheck
	cd $($(superlu_dist-32-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist-32-cuda)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(superlu_dist-32-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(superlu_dist-32-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(superlu_dist-32-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(superlu_dist-32-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(superlu_dist-32-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(superlu_dist-32-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(superlu_dist-32-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUPERLU_DIST_ROOT $($(superlu_dist-32-cuda)-prefix)" >>$@
	echo "setenv SUPERLU_DIST_INCDIR $($(superlu_dist-32-cuda)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_INCLUDEDIR $($(superlu_dist-32-cuda)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_LIBDIR $($(superlu_dist-32-cuda)-prefix)/lib" >>$@
	echo "setenv SUPERLU_DIST_LIBRARYDIR $($(superlu_dist-32-cuda)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(superlu_dist-32-cuda)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(superlu_dist-32-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(superlu_dist-32-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(superlu_dist-32-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(superlu_dist-32-cuda)-prefix)/lib" >>$@
	echo "set MSG \"$(superlu_dist-32-cuda)\"" >>$@

$(superlu_dist-32-cuda)-src: $$($(superlu_dist-32-cuda)-src)
$(superlu_dist-32-cuda)-unpack: $($(superlu_dist-32-cuda)-prefix)/.pkgunpack
$(superlu_dist-32-cuda)-patch: $($(superlu_dist-32-cuda)-prefix)/.pkgpatch
$(superlu_dist-32-cuda)-build: $($(superlu_dist-32-cuda)-prefix)/.pkgbuild
$(superlu_dist-32-cuda)-check: $($(superlu_dist-32-cuda)-prefix)/.pkgcheck
$(superlu_dist-32-cuda)-install: $($(superlu_dist-32-cuda)-prefix)/.pkginstall
$(superlu_dist-32-cuda)-modulefile: $($(superlu_dist-32-cuda)-modulefile)
$(superlu_dist-32-cuda)-clean:
	rm -rf $($(superlu_dist-32-cuda)-modulefile)
	rm -rf $($(superlu_dist-32-cuda)-prefix)
	rm -rf $($(superlu_dist-32-cuda)-builddir)
	rm -rf $($(superlu_dist-32-cuda)-srcdir)
	rm -rf $($(superlu_dist-32-cuda)-src)
$(superlu_dist-32-cuda): $(superlu_dist-32-cuda)-src $(superlu_dist-32-cuda)-unpack $(superlu_dist-32-cuda)-patch $(superlu_dist-32-cuda)-build $(superlu_dist-32-cuda)-check $(superlu_dist-32-cuda)-install $(superlu_dist-32-cuda)-modulefile
