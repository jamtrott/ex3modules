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
# petsc-3.13.2

petsc-3.13.2-version = 3.13.2
petsc-3.13.2 = petsc-$(petsc-3.13.2-version)
$(petsc-3.13.2)-description = Portable, Extensible Toolkit for Scientific Computation
$(petsc-3.13.2)-url = https://www.mcs.anl.gov/petsc/
$(petsc-3.13.2)-srcurl =
$(petsc-3.13.2)-builddeps = $(boost) $(blas) $(mpi) $(hwloc) $(hypre) $(metis) $(mumps) $(parmetis) $(python) $(scalapack) $(scotch) $(suitesparse) $(superlu) $(superlu_dist)
$(petsc-3.13.2)-prereqs = $(boost) $(blas) $(mpi) $(hwloc) $(hypre) $(metis) $(mumps) $(parmetis) $(scalapack) $(scotch) $(suitesparse) $(superlu) $(superlu_dist)
$(petsc-3.13.2)-src = $($(petsc-src)-src)
$(petsc-3.13.2)-srcdir = $(pkgsrcdir)/$(petsc-3.13.2)
$(petsc-3.13.2)-modulefile = $(modulefilesdir)/$(petsc-3.13.2)
$(petsc-3.13.2)-prefix = $(pkgdir)/$(petsc-3.13.2)

$($(petsc-3.13.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-3.13.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-3.13.2)-prefix)/.pkgunpack: $$($(petsc-3.13.2)-src) $($(petsc-3.13.2)-srcdir)/.markerfile $($(petsc-3.13.2)-prefix)/.markerfile $$(foreach dep,$$($(petsc-3.13.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(petsc-3.13.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc-3.13.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-3.13.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-3.13.2)-prefix)/.pkgunpack
	@touch $@

$($(petsc-3.13.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-3.13.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-3.13.2)-prefix)/.pkgpatch
	cd $($(petsc-3.13.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-3.13.2)-builddeps) && \
		$(PYTHON) ./configure MAKEFLAGS="$(MAKEFLAGS)" \
			--prefix=$($(petsc-3.13.2)-prefix) \
			--with-openmp=1 \
			--with-blaslapack-lib="$${BLASDIR}/lib$${BLASLIB}.so" \
			--with-boost --with-boost-dir="$${BOOST_ROOT}" \
			$$([[ ! -z "$${HWLOC_ROOT}" ]] && echo --with-hwloc --with-hwloc-dir="$${HWLOC_ROOT}") \
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
			--with-cuda=0 \
			--with-x=0 \
			--with-debugging=0 \
			COPTFLAGS="-O3 -g" CXXOPTFLAGS="-O3 -g" FOPTFLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(petsc-3.13.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-3.13.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-3.13.2)-prefix)/.pkgbuild
	cd $($(petsc-3.13.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-3.13.2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc-3.13.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-3.13.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-3.13.2)-prefix)/.pkgcheck
	cd $($(petsc-3.13.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-3.13.2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(petsc-3.13.2)-modulefile): $(modulefilesdir)/.markerfile $($(petsc-3.13.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc-3.13.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc-3.13.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc-3.13.2)-description)\"" >>$@
	echo "module-whatis \"$($(petsc-3.13.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc-3.13.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc-3.13.2)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc-3.13.2)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc-3.13.2)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc-3.13.2)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc-3.13.2)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc-3.13.2)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc-3.13.2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc-3.13.2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc-3.13.2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc-3.13.2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc-3.13.2)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc-3.13.2)\"" >>$@

$(petsc-3.13.2)-src: $$($(petsc-3.13.2)-src)
$(petsc-3.13.2)-unpack: $($(petsc-3.13.2)-prefix)/.pkgunpack
$(petsc-3.13.2)-patch: $($(petsc-3.13.2)-prefix)/.pkgpatch
$(petsc-3.13.2)-build: $($(petsc-3.13.2)-prefix)/.pkgbuild
$(petsc-3.13.2)-check: $($(petsc-3.13.2)-prefix)/.pkgcheck
$(petsc-3.13.2)-install: $($(petsc-3.13.2)-prefix)/.pkginstall
$(petsc-3.13.2)-modulefile: $($(petsc-3.13.2)-modulefile)
$(petsc-3.13.2)-clean:
	rm -rf $($(petsc-3.13.2)-modulefile)
	rm -rf $($(petsc-3.13.2)-prefix)
	rm -rf $($(petsc-3.13.2)-srcdir)
$(petsc-3.13.2): $(petsc-3.13.2)-src $(petsc-3.13.2)-unpack $(petsc-3.13.2)-patch $(petsc-3.13.2)-build $(petsc-3.13.2)-check $(petsc-3.13.2)-install $(petsc-3.13.2)-modulefile
