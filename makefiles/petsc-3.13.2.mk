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
# petsc-3.13.2

petsc-version = 3.13.2
petsc = petsc-$(petsc-version)
$(petsc)-description = Portable, Extensible Toolkit for Scientific Computation
$(petsc)-url = https://www.mcs.anl.gov/petsc/
$(petsc)-srcurl = http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-$(petsc-version).tar.gz
$(petsc)-src = $(pkgsrcdir)/$(notdir $($(petsc)-srcurl))
$(petsc)-srcdir = $(pkgsrcdir)/$(petsc)
$(petsc)-builddeps = $(boost) $(blas) $(mpi) $(hwloc) $(hypre) $(metis) $(mumps) $(parmetis) $(python) $(scalapack) $(scotch) $(suitesparse) $(superlu) $(superlu_dist)
$(petsc)-prereqs = $(boost) $(blas) $(mpi) $(hwloc) $(hypre) $(metis) $(mumps) $(parmetis) $(scalapack) $(scotch) $(suitesparse) $(superlu) $(superlu_dist)
$(petsc)-modulefile = $(modulefilesdir)/$(petsc)
$(petsc)-prefix = $(pkgdir)/$(petsc)

$($(petsc)-src): $(dir $($(petsc)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(petsc)-srcurl)

$($(petsc)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(petsc)-prefix)/.pkgunpack: $($(petsc)-src) $($(petsc)-srcdir)/.markerfile $($(petsc)-prefix)/.markerfile
	tar -C $($(petsc)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(petsc)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc)-prefix)/.pkgunpack
	@touch $@

$($(petsc)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc)-prefix)/.pkgpatch
	cd $($(petsc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc)-builddeps) && \
		python3 ./configure MAKEFLAGS="$(MAKEFLAGS)" \
			--prefix=$($(petsc)-prefix) \
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
			--with-debugging=1 \
			COPTFLAGS="-O3 -g" CXXOPTFLAGS="-O3 -g" FOPTFLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(petsc)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc)-prefix)/.pkgbuild
	cd $($(petsc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(petsc)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(petsc)-builddeps),$(modulefilesdir)/$$(dep)) $($(petsc)-prefix)/.pkgcheck
	cd $($(petsc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(petsc)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(petsc)-modulefile): $(modulefilesdir)/.markerfile $($(petsc)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(petsc)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(petsc)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(petsc)-description)\"" >>$@
	echo "module-whatis \"$($(petsc)-url)\"" >>$@
	printf "$(foreach prereq,$($(petsc)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PETSC_ROOT $($(petsc)-prefix)" >>$@
	echo "setenv PETSC_DIR $($(petsc)-prefix)" >>$@
	echo "setenv PETSC_INCDIR $($(petsc)-prefix)/include" >>$@
	echo "setenv PETSC_INCLUDEDIR $($(petsc)-prefix)/include" >>$@
	echo "setenv PETSC_LIBDIR $($(petsc)-prefix)/lib" >>$@
	echo "setenv PETSC_LIBRARYDIR $($(petsc)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(petsc)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(petsc)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(petsc)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(petsc)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(petsc)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(petsc)\"" >>$@

$(petsc)-src: $($(petsc)-src)
$(petsc)-unpack: $($(petsc)-prefix)/.pkgunpack
$(petsc)-patch: $($(petsc)-prefix)/.pkgpatch
$(petsc)-build: $($(petsc)-prefix)/.pkgbuild
$(petsc)-check: $($(petsc)-prefix)/.pkgcheck
$(petsc)-install: $($(petsc)-prefix)/.pkginstall
$(petsc)-modulefile: $($(petsc)-modulefile)
$(petsc)-clean:
	rm -rf $($(petsc)-modulefile)
	rm -rf $($(petsc)-prefix)
	rm -rf $($(petsc)-srcdir)
	rm -rf $($(petsc)-src)
$(petsc): $(petsc)-src $(petsc)-unpack $(petsc)-patch $(petsc)-build $(petsc)-check $(petsc)-install $(petsc)-modulefile
