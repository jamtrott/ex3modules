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
# hypre-cuda-2.17.0

hypre-cuda-version = 2.17.0
hypre-cuda = hypre-cuda-$(hypre-cuda-version)
$(hypre-cuda)-description = Scalable Linear Solvers and Multigrid Methods
$(hypre-cuda)-url = https://github.com/hypre-space/hypre/
$(hypre-cuda)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-cuda-version).tar.gz
$(hypre-cuda)-builddeps = $(blas) $(openmpi-cuda)
$(hypre-cuda)-prereqs = $(blas) $(openmpi-cuda)
$(hypre-cuda)-src = $($(hypre-src)-src)
$(hypre-cuda)-srcdir = $(pkgsrcdir)/$(hypre-cuda)
$(hypre-cuda)-modulefile = $(modulefilesdir)/$(hypre-cuda)
$(hypre-cuda)-prefix = $(pkgdir)/$(hypre-cuda)

$($(hypre-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hypre-cuda)-prefix)/.pkgunpack: $($(hypre-cuda)-src) $($(hypre-cuda)-srcdir)/.markerfile $($(hypre-cuda)-prefix)/.markerfile
	tar -C $($(hypre-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hypre-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-cuda)-prefix)/.pkgunpack
	@touch $@

$($(hypre-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-cuda)-prefix)/.pkgpatch
	cd $($(hypre-cuda)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-cuda)-builddeps) && \
		./configure --prefix=$($(hypre-cuda)-prefix) \
			--enable-shared \
			--with-blas-lib-dirs="$${BLASDIR}" --with-blas-libs="$${BLASLIB}" \
			--with-lapack-lib-dirs="$${BLASDIR}" --with-lapack-libs="$${BLASLIB}" \
			--with-MPI-include="$${OPENMPI_INCDIR}" \
			--with-MPI-lib-dirs="$${OPENMPI_LIBDIR}" \
			--with-MPI-libs="$$(pkg-config --libs-only-l ompi)" \
			--with-MPI-flags="$$(pkg-config --cflags-only-other --libs-only-other ompi)" \
			CFLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(hypre-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-cuda)-prefix)/.pkgbuild
	cd $($(hypre-cuda)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hypre-cuda)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hypre-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hypre-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(hypre-cuda)-prefix)/.pkgcheck
	$(MAKE) -C $($(hypre-cuda)-srcdir)/src install
	@touch $@

$($(hypre-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(hypre-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hypre-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hypre-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hypre-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(hypre-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(hypre-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HYPRE_ROOT $($(hypre-cuda)-prefix)" >>$@
	echo "setenv HYPRE_INCDIR $($(hypre-cuda)-prefix)/include" >>$@
	echo "setenv HYPRE_INCLUDEDIR $($(hypre-cuda)-prefix)/include" >>$@
	echo "setenv HYPRE_LIBDIR $($(hypre-cuda)-prefix)/lib" >>$@
	echo "setenv HYPRE_LIBRARYDIR $($(hypre-cuda)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hypre-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hypre-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hypre-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hypre-cuda)-prefix)/lib" >>$@
	echo "set MSG \"$(hypre-cuda)\"" >>$@

$(hypre-cuda)-src: $($(hypre-cuda)-src)
$(hypre-cuda)-unpack: $($(hypre-cuda)-prefix)/.pkgunpack
$(hypre-cuda)-patch: $($(hypre-cuda)-prefix)/.pkgpatch
$(hypre-cuda)-build: $($(hypre-cuda)-prefix)/.pkgbuild
$(hypre-cuda)-check: $($(hypre-cuda)-prefix)/.pkgcheck
$(hypre-cuda)-install: $($(hypre-cuda)-prefix)/.pkginstall
$(hypre-cuda)-modulefile: $($(hypre-cuda)-modulefile)
$(hypre-cuda)-clean:
	rm -rf $($(hypre-cuda)-modulefile)
	rm -rf $($(hypre-cuda)-prefix)
	rm -rf $($(hypre-cuda)-srcdir)
	rm -rf $($(hypre-cuda)-src)
$(hypre-cuda): $(hypre-cuda)-src $(hypre-cuda)-unpack $(hypre-cuda)-patch $(hypre-cuda)-build $(hypre-cuda)-check $(hypre-cuda)-install $(hypre-cuda)-modulefile
