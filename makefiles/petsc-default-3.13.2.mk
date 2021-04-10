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
# petsc-default-3.13.2

petsc-default-version = 3.13.2
petsc-default = petsc-default-$(petsc-default-version)
$(petsc-default)-description = Portable, Extensible Toolkit for Scientific Computation
$(petsc-default)-url = https://www.mcs.anl.gov/petsc/
$(petsc-default)-srcurl =
$(petsc-default)-builddeps = $(boost) $(blas) $(mpi) $(hwloc) $(hypre) $(metis) $(mumps) $(parmetis) $(python) $(scalapack) $(scotch) $(suitesparse) $(superlu) $(superlu_dist)
$(petsc-default)-prereqs = $(boost) $(blas) $(mpi) $(hwloc) $(hypre) $(metis) $(mumps) $(parmetis) $(scalapack) $(scotch) $(suitesparse) $(superlu) $(superlu_dist)
$(petsc-default)-src = $($(petsc-src)-src)
$(petsc-default)-srcdir = $(pkgsrcdir)/$(petsc-default)
$(petsc-default)-modulefile = $(modulefilesdir)/$(petsc-default)
$(petsc-default)-prefix = $(pkgdir)/$(petsc-default)

$($(petsc-default)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-default)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-default)-prefix)/.pkgunpack: $$($(petsc)-src) $($(petsc-default)-srcdir)/.markerfile $($(petsc-default)-prefix)/.markerfile
	tar -C $($(petsc-default)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc-default)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-default)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-default)-prefix)/.pkgunpack
	@touch $@

$($(petsc-default)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-default)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-default)-prefix)/.pkgpatch
	cd $($(petsc-default)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-default)-builddeps) && \
		python3 ./configure MAKEFLAGS="$(MAKEFLAGS)" \
			--prefix=$($(petsc-default)-prefix) \
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
			--with-x=0 \
			--with-debugging=0 \
			COPTFLAGS="-O3 -g" CXXOPTFLAGS="-O3 -g" FOPTFLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(petsc-default)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-default)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-default)-prefix)/.pkgbuild
	cd $($(petsc-default)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-default)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc-default)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-default)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-default)-prefix)/.pkgcheck
	cd $($(petsc-default)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-default)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(petsc-default)-modulefile): $(modulefilesdir)/.markerfile $($(petsc-default)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc-default)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc-default)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc-default)-description)\"" >>$@
	echo "module-whatis \"$($(petsc-default)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc-default)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc-default)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc-default)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc-default)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc-default)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc-default)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc-default)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc-default)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc-default)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc-default)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc-default)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc-default)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc-default)\"" >>$@

$(petsc-default)-src: $$($(petsc)-src)
$(petsc-default)-unpack: $($(petsc-default)-prefix)/.pkgunpack
$(petsc-default)-patch: $($(petsc-default)-prefix)/.pkgpatch
$(petsc-default)-build: $($(petsc-default)-prefix)/.pkgbuild
$(petsc-default)-check: $($(petsc-default)-prefix)/.pkgcheck
$(petsc-default)-install: $($(petsc-default)-prefix)/.pkginstall
$(petsc-default)-modulefile: $($(petsc-default)-modulefile)
$(petsc-default)-clean:
	rm -rf $($(petsc-default)-modulefile)
	rm -rf $($(petsc-default)-prefix)
	rm -rf $($(petsc-default)-srcdir)
$(petsc-default): $(petsc-default)-src $(petsc-default)-unpack $(petsc-default)-patch $(petsc-default)-build $(petsc-default)-check $(petsc-default)-install $(petsc-default)-modulefile
