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
# hypre-2.17.0

hypre-version = 2.17.0
hypre = hypre-$(hypre-version)
$(hypre)-description = Scalable Linear Solvers and Multigrid Methods
$(hypre)-url = https://github.com/hypre-space/hypre/
$(hypre)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-version).tar.gz
$(hypre)-builddeps = $(blas) $(mpi)
$(hypre)-prereqs = $(blas) $(mpi)
$(hypre)-src = $($(hypre-src)-src)
$(hypre)-srcdir = $(pkgsrcdir)/$(hypre)
$(hypre)-modulefile = $(modulefilesdir)/$(hypre)
$(hypre)-prefix = $(pkgdir)/$(hypre)

$($(hypre)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre)-prefix)/.pkgunpack: $$($(hypre)-src) $($(hypre)-srcdir)/.markerfile $($(hypre)-prefix)/.markerfile
	tar -C $($(hypre)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hypre)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre)-prefix)/.pkgunpack
	@touch $@

$($(hypre)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre)-prefix)/.pkgpatch
	cd $($(hypre)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre)-builddeps) && \
		./configure --prefix=$($(hypre)-prefix) \
			--enable-shared \
			--with-blas-lib-dirs="$${BLASDIR}" --with-blas-libs="$${BLASLIB}" \
			--with-lapack-lib-dirs="$${BLASDIR}" --with-lapack-libs="$${BLASLIB}" \
			--with-MPI \
			--with-MPI-include="$${MPI_HOME}/include" \
			--with-MPI-lib-dirs="$${MPI_HOME}/lib" \
			--with-MPI-libs=mpi && \
		$(MAKE)
	@touch $@

$($(hypre)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre)-prefix)/.pkgbuild
	cd $($(hypre)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hypre)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre)-prefix)/.pkgcheck
	$(MAKE) -C $($(hypre)-srcdir)/src install
	@touch $@

$($(hypre)-modulefile): $(modulefilesdir)/.markerfile $($(hypre)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hypre)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hypre)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hypre)-description)\"" >>$@
	echo "module-whatis \"$($(hypre)-url)\"" >>$@
	printf "$(foreach prereq,$($(hypre)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HYPRE_ROOT $($(hypre)-prefix)" >>$@
	echo "setenv HYPRE_INCDIR $($(hypre)-prefix)/include" >>$@
	echo "setenv HYPRE_INCLUDEDIR $($(hypre)-prefix)/include" >>$@
	echo "setenv HYPRE_LIBDIR $($(hypre)-prefix)/lib" >>$@
	echo "setenv HYPRE_LIBRARYDIR $($(hypre)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hypre)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hypre)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hypre)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hypre)-prefix)/lib" >>$@
	echo "set MSG \"$(hypre)\"" >>$@

$(hypre)-src: $($(hypre)-src)
$(hypre)-unpack: $($(hypre)-prefix)/.pkgunpack
$(hypre)-patch: $($(hypre)-prefix)/.pkgpatch
$(hypre)-build: $($(hypre)-prefix)/.pkgbuild
$(hypre)-check: $($(hypre)-prefix)/.pkgcheck
$(hypre)-install: $($(hypre)-prefix)/.pkginstall
$(hypre)-modulefile: $($(hypre)-modulefile)
$(hypre)-clean:
	rm -rf $($(hypre)-modulefile)
	rm -rf $($(hypre)-prefix)
	rm -rf $($(hypre)-srcdir)
	rm -rf $($(hypre)-src)
$(hypre): $(hypre)-src $(hypre)-unpack $(hypre)-patch $(hypre)-build $(hypre)-check $(hypre)-install $(hypre)-modulefile
