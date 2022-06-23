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
# petsc-64-3.16.5

petsc-64-3.16.5-version = 3.16.5
petsc-64-3.16.5 = petsc-64-$(petsc-64-3.16.5-version)
$(petsc-64-3.16.5)-description = Portable, Extensible Toolkit for Scientific Computation
$(petsc-64-3.16.5)-url = https://www.mcs.anl.gov/petsc/
$(petsc-64-3.16.5)-srcurl =
$(petsc-64-3.16.5)-builddeps = $(boost) $(blas) $(mpi) $(hwloc) $(hypre-64) $(metis-64) $(mumps-64) $(parmetis-64) $(python) $(scalapack) $(scotch) $(suitesparse-64) $(superlu_dist-64)
$(petsc-64-3.16.5)-prereqs = $(boost) $(blas) $(mpi) $(hwloc) $(hypre-64) $(metis-64) $(mumps-64) $(parmetis-64) $(scalapack) $(scotch) $(suitesparse-64) $(superlu_dist-64)
$(petsc-64-3.16.5)-src = $($(petsc-src-3.16.5)-src)
$(petsc-64-3.16.5)-srcdir = $(pkgsrcdir)/$(petsc-64-3.16.5)
$(petsc-64-3.16.5)-modulefile = $(modulefilesdir)/$(petsc-64-3.16.5)
$(petsc-64-3.16.5)-prefix = $(pkgdir)/$(petsc-64-3.16.5)

$($(petsc-64-3.16.5)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-64-3.16.5)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc-64-3.16.5)-prefix)/.pkgunpack: $$($(petsc-64-3.16.5)-src) $($(petsc-64-3.16.5)-srcdir)/.markerfile $($(petsc-64-3.16.5)-prefix)/.markerfile $$(foreach dep,$$($(petsc-64-3.16.5)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(petsc-64-3.16.5)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc-64-3.16.5)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-64-3.16.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-64-3.16.5)-prefix)/.pkgunpack
	@touch $@

$($(petsc-64-3.16.5)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-64-3.16.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-64-3.16.5)-prefix)/.pkgpatch
	cd $($(petsc-64-3.16.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-64-3.16.5)-builddeps) && \
		$(PYTHON) ./configure MAKEFLAGS="$(MAKEFLAGS)" \
			--prefix=$($(petsc-64-3.16.5)-prefix) \
			--with-openmp=1 \
			--with-64-bit-indices \
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
			--with-superlu_dist --with-superlu_dist-dir="$${SUPERLU_DIST_ROOT}" \
			--with-cuda=0 --with-hip=0 --with-x=0 \
			--with-debugging=0 \
			COPTFLAGS="-O3 -g" CXXOPTFLAGS="-O3 -g" FOPTFLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(petsc-64-3.16.5)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-64-3.16.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-64-3.16.5)-prefix)/.pkgbuild
	cd $($(petsc-64-3.16.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-64-3.16.5)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc-64-3.16.5)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc-64-3.16.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc-64-3.16.5)-prefix)/.pkgcheck
	cd $($(petsc-64-3.16.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc-64-3.16.5)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(petsc-64-3.16.5)-modulefile): $(modulefilesdir)/.markerfile $($(petsc-64-3.16.5)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc-64-3.16.5)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc-64-3.16.5)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc-64-3.16.5)-description)\"" >>$@
	echo "module-whatis \"$($(petsc-64-3.16.5)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc-64-3.16.5)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc-64-3.16.5)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc-64-3.16.5)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc-64-3.16.5)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc-64-3.16.5)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc-64-3.16.5)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc-64-3.16.5)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc-64-3.16.5)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc-64-3.16.5)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc-64-3.16.5)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc-64-3.16.5)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc-64-3.16.5)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc-64-3.16.5)\"" >>$@

$(petsc-64-3.16.5)-src: $$($(petsc-64-3.16.5)-src)
$(petsc-64-3.16.5)-unpack: $($(petsc-64-3.16.5)-prefix)/.pkgunpack
$(petsc-64-3.16.5)-patch: $($(petsc-64-3.16.5)-prefix)/.pkgpatch
$(petsc-64-3.16.5)-build: $($(petsc-64-3.16.5)-prefix)/.pkgbuild
$(petsc-64-3.16.5)-check: $($(petsc-64-3.16.5)-prefix)/.pkgcheck
$(petsc-64-3.16.5)-install: $($(petsc-64-3.16.5)-prefix)/.pkginstall
$(petsc-64-3.16.5)-modulefile: $($(petsc-64-3.16.5)-modulefile)
$(petsc-64-3.16.5)-clean:
	rm -rf $($(petsc-64-3.16.5)-modulefile)
	rm -rf $($(petsc-64-3.16.5)-prefix)
	rm -rf $($(petsc-64-3.16.5)-srcdir)
$(petsc-64-3.16.5): $(petsc-64-3.16.5)-src $(petsc-64-3.16.5)-unpack $(petsc-64-3.16.5)-patch $(petsc-64-3.16.5)-build $(petsc-64-3.16.5)-check $(petsc-64-3.16.5)-install $(petsc-64-3.16.5)-modulefile
