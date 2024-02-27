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
# mfem-4.5

mfem-4.5-version = 4.5
mfem-4.5 = mfem-$(mfem-4.5-version)
$(mfem-4.5)-description = Lightweight, general, scalable C++ library for finite element methods
$(mfem-4.5)-url = https://mfem.org/
$(mfem-4.5)-srcurl = https://mfem.github.io/releases/mfem-4.5.tgz
$(mfem-4.5)-builddeps = $(cmake) $(metis) $(parmetis) $(hypre) $(mpi) $(suitesparse) $(superlu_dist) $(mumps) $(petsc) $(mpfr) $(libceed)
$(mfem-4.5)-prereqs = $(metis) $(parmetis) $(hypre) $(mpi) $(suitesparse) $(superlu_dist) $(mumps) $(petsc) $(mpfr) $(libceed)
$(mfem-4.5)-src = $(pkgsrcdir)/$(notdir $($(mfem-4.5)-srcurl))
$(mfem-4.5)-srcdir = $(pkgsrcdir)/$(mfem-4.5)
$(mfem-4.5)-builddir = $($(mfem-4.5)-srcdir)/build
$(mfem-4.5)-modulefile = $(modulefilesdir)/$(mfem-4.5)
$(mfem-4.5)-prefix = $(pkgdir)/$(mfem-4.5)

$($(mfem-4.5)-src): $(dir $($(mfem-4.5)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mfem-4.5)-srcurl)

$($(mfem-4.5)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mfem-4.5)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mfem-4.5)-prefix)/.pkgunpack: $$($(mfem-4.5)-src) $($(mfem-4.5)-srcdir)/.markerfile $($(mfem-4.5)-prefix)/.markerfile $$(foreach dep,$$($(mfem-4.5)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mfem-4.5)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mfem-4.5)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem-4.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem-4.5)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(mfem-4.5)-builddir),$($(mfem-4.5)-srcdir))
$($(mfem-4.5)-builddir)/.markerfile: $($(mfem-4.5)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(mfem-4.5)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem-4.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem-4.5)-builddir)/.markerfile $($(mfem-4.5)-prefix)/.pkgpatch
	cd $($(mfem-4.5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mfem-4.5)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(mfem-4.5)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=1 \
			-DMFEM_ENABLE_EXAMPLES=YES \
			-DHYPRE_DIR="$${HYPRE_ROOT}" \
			-DMFEM_USE_MPI=YES \
			-DMFEM_USE_METIS=YES -DMFEM_USE_METIS_5=YES -DMETIS_DIR="$${METIS_ROOT}" \
			-DParMETIS_DIR="$${PARMETIS_ROOT}" \
			-DMFEM_USE_LAPACK=YES -DLAPACK_DIR="$${LAPACKDIR}" \
			-DMFEM_USE_OPENMP=YES \
			-DMFEM_USE_SUITESPARSE=YES -DSuiteSparse_DIR="$${SUITESPARSE_ROOT}" \
			-DMFEM_USE_SUPERLU=YES -DSuperLUDist_DIR="$${SUPERLU_DIST_ROOT}" \
			-DMFEM_USE_MUMPS=YES -DMUMPS_DIR="$${MUMPS_ROOT}" \
			-DMFEM_USE_PETSC=YES -DPETSC_DIR="$${PETSC_ROOT}" -DPETSC_ARCH= \
			-DMFEM_USE_MPFR=YES \
			-DMFEM_USE_CEED=YES -DCEED_DIR="$${LIBCEED_ROOT}" \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo -DMFEM_USE_CUDA=YES -DCUDA_ARCH=${MFEM_CUDA_ARCH}) \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo -DMFEM_USE_HIP=YES -DHIP_ARCH=gfx90a) && \
		$(MAKE)
	@touch $@

$($(mfem-4.5)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem-4.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem-4.5)-builddir)/.markerfile $($(mfem-4.5)-prefix)/.pkgbuild
	cd $($(mfem-4.5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mfem-4.5)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(mfem-4.5)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem-4.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem-4.5)-builddir)/.markerfile $($(mfem-4.5)-prefix)/.pkgcheck
	cd $($(mfem-4.5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mfem-4.5)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(mfem-4.5)-modulefile): $(modulefilesdir)/.markerfile $($(mfem-4.5)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mfem-4.5)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mfem-4.5)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mfem-4.5)-description)\"" >>$@
	echo "module-whatis \"$($(mfem-4.5)-url)\"" >>$@
	printf "$(foreach prereq,$($(mfem-4.5)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MFEM_ROOT $($(mfem-4.5)-prefix)" >>$@
	echo "setenv MFEM_INCDIR $($(mfem-4.5)-prefix)/include" >>$@
	echo "setenv MFEM_INCLUDEDIR $($(mfem-4.5)-prefix)/include" >>$@
	echo "setenv MFEM_LIBDIR $($(mfem-4.5)-prefix)/lib" >>$@
	echo "setenv MFEM_LIBRARYDIR $($(mfem-4.5)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(mfem-4.5)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mfem-4.5)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mfem-4.5)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mfem-4.5)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mfem-4.5)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mfem-4.5)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(mfem-4.5)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(mfem-4.5)-prefix)/share/info" >>$@
	echo "set MSG \"$(mfem-4.5)\"" >>$@

$(mfem-4.5)-src: $$($(mfem-4.5)-src)
$(mfem-4.5)-unpack: $($(mfem-4.5)-prefix)/.pkgunpack
$(mfem-4.5)-patch: $($(mfem-4.5)-prefix)/.pkgpatch
$(mfem-4.5)-build: $($(mfem-4.5)-prefix)/.pkgbuild
$(mfem-4.5)-check: $($(mfem-4.5)-prefix)/.pkgcheck
$(mfem-4.5)-install: $($(mfem-4.5)-prefix)/.pkginstall
$(mfem-4.5)-modulefile: $($(mfem-4.5)-modulefile)
$(mfem-4.5)-clean:
	rm -rf $($(mfem-4.5)-modulefile)
	rm -rf $($(mfem-4.5)-prefix)
	rm -rf $($(mfem-4.5)-builddir)
	rm -rf $($(mfem-4.5)-srcdir)
	rm -rf $($(mfem-4.5)-src)
$(mfem-4.5): $(mfem-4.5)-src $(mfem-4.5)-unpack $(mfem-4.5)-patch $(mfem-4.5)-build $(mfem-4.5)-check $(mfem-4.5)-install $(mfem-4.5)-modulefile
