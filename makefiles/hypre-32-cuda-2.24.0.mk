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
# hypre-32-cuda-2.24.0

hypre-32-cuda-2.24-version = 2.24.0
hypre-32-cuda-2.24 = hypre-32-cuda-$(hypre-32-cuda-2.24-version)
$(hypre-32-cuda-2.24)-description = Scalable Linear Solvers and Multigrid Methods
$(hypre-32-cuda-2.24)-url = https://github.com/hypre-space/hypre/
$(hypre-32-cuda-2.24)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-32-cuda-2.24-version).tar.gz
$(hypre-32-cuda-2.24)-builddeps = $(blas) $(openmpi-cuda) $(cuda-toolkit)
$(hypre-32-cuda-2.24)-prereqs = $(blas) $(openmpi-cuda) $(cuda-toolkit)
$(hypre-32-cuda-2.24)-src = $($(hypre-src-2.24)-src)
$(hypre-32-cuda-2.24)-srcdir = $(pkgsrcdir)/$(hypre-32-cuda-2.24)
$(hypre-32-cuda-2.24)-modulefile = $(modulefilesdir)/$(hypre-32-cuda-2.24)
$(hypre-32-cuda-2.24)-prefix = $(pkgdir)/$(hypre-32-cuda-2.24)

$($(hypre-32-cuda-2.24)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-32-cuda-2.24)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-32-cuda-2.24)-prefix)/.pkgunpack: $$($(hypre-32-cuda-2.24)-src) $($(hypre-32-cuda-2.24)-srcdir)/.markerfile $($(hypre-32-cuda-2.24)-prefix)/.markerfile $$(foreach dep,$$($(hypre-32-cuda-2.24)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hypre-32-cuda-2.24)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hypre-32-cuda-2.24)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-cuda-2.24)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-cuda-2.24)-prefix)/.pkgunpack
	@touch $@

$($(hypre-32-cuda-2.24)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-cuda-2.24)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-cuda-2.24)-prefix)/.pkgpatch
	cd $($(hypre-32-cuda-2.24)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-32-cuda-2.24)-builddeps) && \
		./configure --prefix=$($(hypre-32-cuda-2.24)-prefix) \
			--enable-shared \
			--with-blas-lib-dirs="$${BLASDIR}" --with-blas-libs="$${BLASLIB}" \
			--with-lapack-lib-dirs="$${BLASDIR}" --with-lapack-libs="$${BLASLIB}" \
			--with-MPI \
			--with-MPI-include="$${MPI_HOME}/include" \
			--with-MPI-lib-dirs="$${MPI_HOME}/lib" \
			--with-MPI-libs=mpi \
			--enable-device-memory-pool \
			--with-cuda && \
		$(MAKE)
	@touch $@

$($(hypre-32-cuda-2.24)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-cuda-2.24)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-cuda-2.24)-prefix)/.pkgbuild
	cd $($(hypre-32-cuda-2.24)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-32-cuda-2.24)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hypre-32-cuda-2.24)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-cuda-2.24)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-cuda-2.24)-prefix)/.pkgcheck
	$(MAKE) -C $($(hypre-32-cuda-2.24)-srcdir)/src install
	@touch $@

$($(hypre-32-cuda-2.24)-modulefile): $(modulefilesdir)/.markerfile $($(hypre-32-cuda-2.24)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hypre-32-cuda-2.24)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hypre-32-cuda-2.24)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hypre-32-cuda-2.24)-description)\"" >>$@
	echo "module-whatis \"$($(hypre-32-cuda-2.24)-url)\"" >>$@
	printf "$(foreach prereq,$($(hypre-32-cuda-2.24)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HYPRE_ROOT $($(hypre-32-cuda-2.24)-prefix)" >>$@
	echo "setenv HYPRE_INCDIR $($(hypre-32-cuda-2.24)-prefix)/include" >>$@
	echo "setenv HYPRE_INCLUDEDIR $($(hypre-32-cuda-2.24)-prefix)/include" >>$@
	echo "setenv HYPRE_LIBDIR $($(hypre-32-cuda-2.24)-prefix)/lib" >>$@
	echo "setenv HYPRE_LIBRARYDIR $($(hypre-32-cuda-2.24)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hypre-32-cuda-2.24)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hypre-32-cuda-2.24)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hypre-32-cuda-2.24)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hypre-32-cuda-2.24)-prefix)/lib" >>$@
	echo "set MSG \"$(hypre-32-cuda-2.24)\"" >>$@

$(hypre-32-cuda-2.24)-src: $$($(hypre-32-cuda-2.24)-src)
$(hypre-32-cuda-2.24)-unpack: $($(hypre-32-cuda-2.24)-prefix)/.pkgunpack
$(hypre-32-cuda-2.24)-patch: $($(hypre-32-cuda-2.24)-prefix)/.pkgpatch
$(hypre-32-cuda-2.24)-build: $($(hypre-32-cuda-2.24)-prefix)/.pkgbuild
$(hypre-32-cuda-2.24)-check: $($(hypre-32-cuda-2.24)-prefix)/.pkgcheck
$(hypre-32-cuda-2.24)-install: $($(hypre-32-cuda-2.24)-prefix)/.pkginstall
$(hypre-32-cuda-2.24)-modulefile: $($(hypre-32-cuda-2.24)-modulefile)
$(hypre-32-cuda-2.24)-clean:
	rm -rf $($(hypre-32-cuda-2.24)-modulefile)
	rm -rf $($(hypre-32-cuda-2.24)-prefix)
	rm -rf $($(hypre-32-cuda-2.24)-srcdir)
	rm -rf $($(hypre-32-cuda-2.24)-src)
$(hypre-32-cuda-2.24): $(hypre-32-cuda-2.24)-src $(hypre-32-cuda-2.24)-unpack $(hypre-32-cuda-2.24)-patch $(hypre-32-cuda-2.24)-build $(hypre-32-cuda-2.24)-check $(hypre-32-cuda-2.24)-install $(hypre-32-cuda-2.24)-modulefile
