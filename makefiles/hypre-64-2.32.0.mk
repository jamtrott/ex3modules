# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# hypre-64-2.32.0

hypre-64-2.32.0-version = 2.32.0
hypre-64-2.32.0 = hypre-64-$(hypre-64-2.32.0-version)
$(hypre-64-2.32.0)-description = Scalable Linear Solvers and Multigrid Methods
$(hypre-64-2.32.0)-url = https://github.com/hypre-space/hypre/
$(hypre-64-2.32.0)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-64-2.32.0-version).tar.gz
$(hypre-64-2.32.0)-builddeps = $(blas) $(mpi)
$(hypre-64-2.32.0)-prereqs = $(blas) $(mpi)
$(hypre-64-2.32.0)-src = $($(hypre-src-2.32.0)-src)
$(hypre-64-2.32.0)-srcdir = $(pkgsrcdir)/$(hypre-64-2.32.0)
$(hypre-64-2.32.0)-modulefile = $(modulefilesdir)/$(hypre-64-2.32.0)
$(hypre-64-2.32.0)-prefix = $(pkgdir)/$(hypre-64-2.32.0)

$($(hypre-64-2.32.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-64-2.32.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-64-2.32.0)-prefix)/.pkgunpack: $$($(hypre-64-2.32.0)-src) $($(hypre-64-2.32.0)-srcdir)/.markerfile $($(hypre-64-2.32.0)-prefix)/.markerfile $$(foreach dep,$$($(hypre-64-2.32.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hypre-64-2.32.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hypre-64-2.32.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-64-2.32.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-64-2.32.0)-prefix)/.pkgunpack
	@touch $@

$($(hypre-64-2.32.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-64-2.32.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-64-2.32.0)-prefix)/.pkgpatch
	cd $($(hypre-64-2.32.0)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-64-2.32.0)-builddeps) && \
		./configure --prefix=$($(hypre-64-2.32.0)-prefix) \
			--enable-shared \
			--disable-fortran \
			--with-openmp \
			--enable-mixedint \
			--with-blas-lib-dirs="$${BLASDIR}" --with-blas-libs="$${BLASLIB}" \
			--with-lapack-lib-dirs="$${BLASDIR}" --with-lapack-libs="$${BLASLIB}" \
			--with-MPI \
			--with-MPI-include="$${MPI_HOME}/include" \
			--with-MPI-lib-dirs="$${MPI_HOME}/lib" \
			--with-MPI-libs=mpi \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --enable-device-memory-pool --with-cuda CUDA_HOME="$${CUDA_TOOLKIT_ROOT}") --with-gpu-arch='70 80' \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo --enable-device-memory-pool --with-hip) && \
		$(MAKE)
	@touch $@

$($(hypre-64-2.32.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-64-2.32.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-64-2.32.0)-prefix)/.pkgbuild
	cd $($(hypre-64-2.32.0)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-64-2.32.0)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hypre-64-2.32.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-64-2.32.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-64-2.32.0)-prefix)/.pkgcheck
	$(MAKE) -C $($(hypre-64-2.32.0)-srcdir)/src install
	@touch $@

$($(hypre-64-2.32.0)-modulefile): $(modulefilesdir)/.markerfile $($(hypre-64-2.32.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hypre-64-2.32.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hypre-64-2.32.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hypre-64-2.32.0)-description)\"" >>$@
	echo "module-whatis \"$($(hypre-64-2.32.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(hypre-64-2.32.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HYPRE_ROOT $($(hypre-64-2.32.0)-prefix)" >>$@
	echo "setenv HYPRE_INCDIR $($(hypre-64-2.32.0)-prefix)/include" >>$@
	echo "setenv HYPRE_INCLUDEDIR $($(hypre-64-2.32.0)-prefix)/include" >>$@
	echo "setenv HYPRE_LIBDIR $($(hypre-64-2.32.0)-prefix)/lib" >>$@
	echo "setenv HYPRE_LIBRARYDIR $($(hypre-64-2.32.0)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hypre-64-2.32.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hypre-64-2.32.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hypre-64-2.32.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hypre-64-2.32.0)-prefix)/lib" >>$@
	echo "set MSG \"$(hypre-64-2.32.0)\"" >>$@

$(hypre-64-2.32.0)-src: $$($(hypre-64-2.32.0)-src)
$(hypre-64-2.32.0)-unpack: $($(hypre-64-2.32.0)-prefix)/.pkgunpack
$(hypre-64-2.32.0)-patch: $($(hypre-64-2.32.0)-prefix)/.pkgpatch
$(hypre-64-2.32.0)-build: $($(hypre-64-2.32.0)-prefix)/.pkgbuild
$(hypre-64-2.32.0)-check: $($(hypre-64-2.32.0)-prefix)/.pkgcheck
$(hypre-64-2.32.0)-install: $($(hypre-64-2.32.0)-prefix)/.pkginstall
$(hypre-64-2.32.0)-modulefile: $($(hypre-64-2.32.0)-modulefile)
$(hypre-64-2.32.0)-clean:
	rm -rf $($(hypre-64-2.32.0)-modulefile)
	rm -rf $($(hypre-64-2.32.0)-prefix)
	rm -rf $($(hypre-64-2.32.0)-srcdir)
	rm -rf $($(hypre-64-2.32.0)-src)
$(hypre-64-2.32.0): $(hypre-64-2.32.0)-src $(hypre-64-2.32.0)-unpack $(hypre-64-2.32.0)-patch $(hypre-64-2.32.0)-build $(hypre-64-2.32.0)-check $(hypre-64-2.32.0)-install $(hypre-64-2.32.0)-modulefile
