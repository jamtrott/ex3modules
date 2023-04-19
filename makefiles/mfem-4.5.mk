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

mfem-version = 4.5
mfem = mfem-$(mfem-version)
$(mfem)-description = Lightweight, general, scalable C++ library for finite element methods
$(mfem)-url = https://mfem.org/
$(mfem)-srcurl = https://mfem.github.io/releases/mfem-4.5.tgz
$(mfem)-builddeps = $(cmake) $(metis) $(hypre) $(mpi) $(suitesparse) $(superlu_dist) $(mumps) $(petsc) $(mpfr)
$(mfem)-prereqs = $(metis) $(hypre) $(mpi) $(suitesparse) $(superlu_dist) $(mumps) $(petsc) $(mpfr)
$(mfem)-src = $(pkgsrcdir)/$(notdir $($(mfem)-srcurl))
$(mfem)-srcdir = $(pkgsrcdir)/$(mfem)
$(mfem)-builddir = $($(mfem)-srcdir)/build
$(mfem)-modulefile = $(modulefilesdir)/$(mfem)
$(mfem)-prefix = $(pkgdir)/$(mfem)

$($(mfem)-src): $(dir $($(mfem)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mfem)-srcurl)

$($(mfem)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mfem)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mfem)-prefix)/.pkgunpack: $$($(mfem)-src) $($(mfem)-srcdir)/.markerfile $($(mfem)-prefix)/.markerfile $$(foreach dep,$$($(mfem)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mfem)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mfem)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(mfem)-builddir),$($(mfem)-srcdir))
$($(mfem)-builddir)/.markerfile: $($(mfem)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(mfem)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem)-builddir)/.markerfile $($(mfem)-prefix)/.pkgpatch
	cd $($(mfem)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mfem)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(mfem)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=1 \
			-DHYPRE_DIR="$${HYPRE_ROOT}" \
			-DMFEM_USE_MPI=YES \
			-DMFEM_USE_METIS=YES -DMFEM_USE_METIS_5=YES -DMETIS_DIR="$${METIS_ROOT}" \
			-DMFEM_USE_LAPACK=YES -DLAPACK_DIR="$${LAPACKDIR}" \
			-DMFEM_USE_OPENMP=YES \
			-DMFEM_USE_SUITESPARSE=YES -DSuiteSparse_DIR="$${SUITESPARSE_ROOT}" \
			-DMFEM_USE_SUPERLU=YES -DSuperLUDist_DIR="$${SUPERLU_DIST_ROOT}" \
			-DMFEM_USE_MUMPS=YES -DMUMPS_DIR="$${MUMPS_ROOT}" \
			-DMFEM_USE_PETSC=YES -DPETSC_DIR="$${PETSC_ROOT}" -DPETSC_ARCH= \
			-DMFEM_USE_MPFR=YES \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo -DMFEM_USE_CUDA=YES -DCUDA_ARCH=sm_70) \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo -DMFEM_USE_HIP=YES -DHIP_ARCH=gfx90a) && \
		$(MAKE)
	@touch $@

$($(mfem)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem)-builddir)/.markerfile $($(mfem)-prefix)/.pkgbuild
	cd $($(mfem)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mfem)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(mfem)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mfem)-builddeps),$(modulefilesdir)/$$(dep)) $($(mfem)-builddir)/.markerfile $($(mfem)-prefix)/.pkgcheck
	cd $($(mfem)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mfem)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(mfem)-modulefile): $(modulefilesdir)/.markerfile $($(mfem)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mfem)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mfem)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mfem)-description)\"" >>$@
	echo "module-whatis \"$($(mfem)-url)\"" >>$@
	printf "$(foreach prereq,$($(mfem)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MFEM_ROOT $($(mfem)-prefix)" >>$@
	echo "setenv MFEM_INCDIR $($(mfem)-prefix)/include" >>$@
	echo "setenv MFEM_INCLUDEDIR $($(mfem)-prefix)/include" >>$@
	echo "setenv MFEM_LIBDIR $($(mfem)-prefix)/lib" >>$@
	echo "setenv MFEM_LIBRARYDIR $($(mfem)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(mfem)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mfem)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mfem)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mfem)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mfem)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mfem)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(mfem)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(mfem)-prefix)/share/info" >>$@
	echo "set MSG \"$(mfem)\"" >>$@

$(mfem)-src: $$($(mfem)-src)
$(mfem)-unpack: $($(mfem)-prefix)/.pkgunpack
$(mfem)-patch: $($(mfem)-prefix)/.pkgpatch
$(mfem)-build: $($(mfem)-prefix)/.pkgbuild
$(mfem)-check: $($(mfem)-prefix)/.pkgcheck
$(mfem)-install: $($(mfem)-prefix)/.pkginstall
$(mfem)-modulefile: $($(mfem)-modulefile)
$(mfem)-clean:
	rm -rf $($(mfem)-modulefile)
	rm -rf $($(mfem)-prefix)
	rm -rf $($(mfem)-builddir)
	rm -rf $($(mfem)-srcdir)
	rm -rf $($(mfem)-src)
$(mfem): $(mfem)-src $(mfem)-unpack $(mfem)-patch $(mfem)-build $(mfem)-check $(mfem)-install $(mfem)-modulefile
