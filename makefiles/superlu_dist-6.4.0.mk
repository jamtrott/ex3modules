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
# superlu_dist-6.4.0

superlu_dist-version = 6.4.0
superlu_dist = superlu_dist-$(superlu_dist-version)
$(superlu_dist)-description = MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory
$(superlu_dist)-url = https://github.com/xiaoyeli/superlu_dist/
$(superlu_dist)-srcurl = https://github.com/xiaoyeli/superlu_dist/archive/v$(superlu_dist-version).tar.gz
$(superlu_dist)-builddeps = $(cmake) $(blas) $(mpi) $(parmetis) $(combblas)
$(superlu_dist)-prereqs = $(blas) $(mpi) $(parmetis) $(combblas)
$(superlu_dist)-src = $(pkgsrcdir)/superlu_dist-$(notdir $($(superlu_dist)-srcurl))
$(superlu_dist)-srcdir = $(pkgsrcdir)/$(superlu_dist)
$(superlu_dist)-builddir = $($(superlu_dist)-srcdir)/build
$(superlu_dist)-modulefile = $(modulefilesdir)/$(superlu_dist)
$(superlu_dist)-prefix = $(pkgdir)/$(superlu_dist)

$($(superlu_dist)-src): $(dir $($(superlu_dist)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(superlu_dist)-srcurl)

$($(superlu_dist)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu_dist)-prefix)/.pkgunpack: $$($(superlu_dist)-src) $($(superlu_dist)-srcdir)/.markerfile $($(superlu_dist)-prefix)/.markerfile
	tar -C $($(superlu_dist)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(superlu_dist)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist)-prefix)/.pkgunpack
	sed -i 's,set(CMAKE_CXX_STANDARD 11),set(CMAKE_CXX_STANDARD 14),' $($(superlu_dist)-srcdir)/CMakeLists.txt
	@touch $@

ifneq ($($(superlu_dist)-builddir),$($(superlu_dist)-srcdir))
$($(superlu_dist)-builddir)/.markerfile: $($(superlu_dist)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(superlu_dist)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist)-builddir)/.markerfile $($(superlu_dist)-prefix)/.pkgpatch
	cd $($(superlu_dist)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(superlu_dist)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
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
			-DCMAKE_C_COMPILER=$${MPICC} \
			-DCMAKE_CXX_COMPILER=$${MPICXX} \
			-DCMAKE_FC_COMPILER=$${MPIFORT} && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(superlu_dist)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist)-builddir)/.markerfile $($(superlu_dist)-prefix)/.pkgbuild
	@touch $@

$($(superlu_dist)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu_dist)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu_dist)-builddir)/.markerfile $($(superlu_dist)-prefix)/.pkgcheck
	cd $($(superlu_dist)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu_dist)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(superlu_dist)-modulefile): $(modulefilesdir)/.markerfile $($(superlu_dist)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(superlu_dist)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(superlu_dist)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(superlu_dist)-description)\"" >>$@
	echo "module-whatis \"$($(superlu_dist)-url)\"" >>$@
	printf "$(foreach prereq,$($(superlu_dist)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUPERLU_DIST_ROOT $($(superlu_dist)-prefix)" >>$@
	echo "setenv SUPERLU_DIST_INCDIR $($(superlu_dist)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_INCLUDEDIR $($(superlu_dist)-prefix)/include" >>$@
	echo "setenv SUPERLU_DIST_LIBDIR $($(superlu_dist)-prefix)/lib" >>$@
	echo "setenv SUPERLU_DIST_LIBRARYDIR $($(superlu_dist)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(superlu_dist)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(superlu_dist)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(superlu_dist)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(superlu_dist)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(superlu_dist)-prefix)/lib" >>$@
	echo "set MSG \"$(superlu_dist)\"" >>$@

$(superlu_dist)-src: $$($(superlu_dist)-src)
$(superlu_dist)-unpack: $($(superlu_dist)-prefix)/.pkgunpack
$(superlu_dist)-patch: $($(superlu_dist)-prefix)/.pkgpatch
$(superlu_dist)-build: $($(superlu_dist)-prefix)/.pkgbuild
$(superlu_dist)-check: $($(superlu_dist)-prefix)/.pkgcheck
$(superlu_dist)-install: $($(superlu_dist)-prefix)/.pkginstall
$(superlu_dist)-modulefile: $($(superlu_dist)-modulefile)
$(superlu_dist)-clean:
	rm -rf $($(superlu_dist)-modulefile)
	rm -rf $($(superlu_dist)-prefix)
	rm -rf $($(superlu_dist)-builddir)
	rm -rf $($(superlu_dist)-srcdir)
	rm -rf $($(superlu_dist)-src)
$(superlu_dist): $(superlu_dist)-src $(superlu_dist)-unpack $(superlu_dist)-patch $(superlu_dist)-build $(superlu_dist)-check $(superlu_dist)-install $(superlu_dist)-modulefile
