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
# hypre-32-2.25.0

hypre-32-2.25-gfx90a-version = 2.25.0
hypre-32-2.25-gfx90a = hypre-32-$(hypre-32-2.25-gfx90a-version)-gfx90a
$(hypre-32-2.25-gfx90a)-description = Scalable Linear Solvers and Multigrid Methods
$(hypre-32-2.25-gfx90a)-url = https://github.com/hypre-space/hypre/
$(hypre-32-2.25-gfx90a)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-32-2.25-gfx90a-version).tar.gz
$(hypre-32-2.25-gfx90a)-builddeps = $(blas) $(mpi)
$(hypre-32-2.25-gfx90a)-prereqs = $(blas) $(mpi)
$(hypre-32-2.25-gfx90a)-src = $($(hypre-src-2.25)-src)
$(hypre-32-2.25-gfx90a)-srcdir = $(pkgsrcdir)/$(hypre-32-2.25-gfx90a)
$(hypre-32-2.25-gfx90a)-modulefile = $(modulefilesdir)/$(hypre-32-2.25-gfx90a)
$(hypre-32-2.25-gfx90a)-prefix = $(pkgdir)/$(hypre-32-2.25-gfx90a)

$($(hypre-32-2.25-gfx90a)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-32-2.25-gfx90a)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-32-2.25-gfx90a)-prefix)/.pkgunpack: $$($(hypre-32-2.25-gfx90a)-src) $($(hypre-32-2.25-gfx90a)-srcdir)/.markerfile $($(hypre-32-2.25-gfx90a)-prefix)/.markerfile $$(foreach dep,$$($(hypre-32-2.25-gfx90a)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hypre-32-2.25-gfx90a)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hypre-32-2.25-gfx90a)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-2.25-gfx90a)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-2.25-gfx90a)-prefix)/.pkgunpack
	@touch $@

$($(hypre-32-2.25-gfx90a)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-2.25-gfx90a)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-2.25-gfx90a)-prefix)/.pkgpatch
	cd $($(hypre-32-2.25-gfx90a)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-32-2.25-gfx90a)-builddeps) && \
		./configure --prefix=$($(hypre-32-2.25-gfx90a)-prefix) \
			--enable-shared \
			--disable-fortran \
			--with-blas-lib-dirs="$${BLASDIR}" --with-blas-libs="$${BLASLIB}" \
			--with-lapack-lib-dirs="$${BLASDIR}" --with-lapack-libs="$${BLASLIB}" \
			--with-MPI \
			--with-MPI-include="$${MPI_HOME}/include" \
			--with-MPI-lib-dirs="$${MPI_HOME}/lib" \
			--with-MPI-libs=mpi \
			--enable-device-memory-pool --with-hip --with-gpu-arch=gfx90a && \
		$(MAKE)
	@touch $@

$($(hypre-32-2.25-gfx90a)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-2.25-gfx90a)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-2.25-gfx90a)-prefix)/.pkgbuild
	cd $($(hypre-32-2.25-gfx90a)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-32-2.25-gfx90a)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hypre-32-2.25-gfx90a)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-32-2.25-gfx90a)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-32-2.25-gfx90a)-prefix)/.pkgcheck
	$(MAKE) -C $($(hypre-32-2.25-gfx90a)-srcdir)/src install
	@touch $@

$($(hypre-32-2.25-gfx90a)-modulefile): $(modulefilesdir)/.markerfile $($(hypre-32-2.25-gfx90a)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hypre-32-2.25-gfx90a)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hypre-32-2.25-gfx90a)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hypre-32-2.25-gfx90a)-description)\"" >>$@
	echo "module-whatis \"$($(hypre-32-2.25-gfx90a)-url)\"" >>$@
	printf "$(foreach prereq,$($(hypre-32-2.25-gfx90a)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HYPRE_ROOT $($(hypre-32-2.25-gfx90a)-prefix)" >>$@
	echo "setenv HYPRE_INCDIR $($(hypre-32-2.25-gfx90a)-prefix)/include" >>$@
	echo "setenv HYPRE_INCLUDEDIR $($(hypre-32-2.25-gfx90a)-prefix)/include" >>$@
	echo "setenv HYPRE_LIBDIR $($(hypre-32-2.25-gfx90a)-prefix)/lib" >>$@
	echo "setenv HYPRE_LIBRARYDIR $($(hypre-32-2.25-gfx90a)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hypre-32-2.25-gfx90a)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hypre-32-2.25-gfx90a)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hypre-32-2.25-gfx90a)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hypre-32-2.25-gfx90a)-prefix)/lib" >>$@
	echo "set MSG \"$(hypre-32-2.25-gfx90a)\"" >>$@

$(hypre-32-2.25-gfx90a)-src: $$($(hypre-32-2.25-gfx90a)-src)
$(hypre-32-2.25-gfx90a)-unpack: $($(hypre-32-2.25-gfx90a)-prefix)/.pkgunpack
$(hypre-32-2.25-gfx90a)-patch: $($(hypre-32-2.25-gfx90a)-prefix)/.pkgpatch
$(hypre-32-2.25-gfx90a)-build: $($(hypre-32-2.25-gfx90a)-prefix)/.pkgbuild
$(hypre-32-2.25-gfx90a)-check: $($(hypre-32-2.25-gfx90a)-prefix)/.pkgcheck
$(hypre-32-2.25-gfx90a)-install: $($(hypre-32-2.25-gfx90a)-prefix)/.pkginstall
$(hypre-32-2.25-gfx90a)-modulefile: $($(hypre-32-2.25-gfx90a)-modulefile)
$(hypre-32-2.25-gfx90a)-clean:
	rm -rf $($(hypre-32-2.25-gfx90a)-modulefile)
	rm -rf $($(hypre-32-2.25-gfx90a)-prefix)
	rm -rf $($(hypre-32-2.25-gfx90a)-srcdir)
	rm -rf $($(hypre-32-2.25-gfx90a)-src)
$(hypre-32-2.25-gfx90a): $(hypre-32-2.25-gfx90a)-src $(hypre-32-2.25-gfx90a)-unpack $(hypre-32-2.25-gfx90a)-patch $(hypre-32-2.25-gfx90a)-build $(hypre-32-2.25-gfx90a)-check $(hypre-32-2.25-gfx90a)-install $(hypre-32-2.25-gfx90a)-modulefile
