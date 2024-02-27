# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# pastix-32-6.3.2

pastix-32-6.3.2-version = 6.3.2
pastix-32-6.3.2 = pastix-32-$(pastix-32-6.3.2-version)
$(pastix-32-6.3.2)-description = Parallel sparse direct Solver
$(pastix-32-6.3.2)-url = https://gitlab.inria.fr/solverstack/pastix
$(pastix-32-6.3.2)-srcurl =
$(pastix-32-6.3.2)-builddeps = $(cmake) $(mpi) $(scotch-32) $(metis-32) $(blas) $(lapack) $(hwloc)
$(pastix-32-6.3.2)-prereqs = $(scotch-32) $(mpi) $(metis-32) $(blas) $(lapack) $(hwloc)
$(pastix-32-6.3.2)-src = $($(pastix-src-6.3.2)-src)
$(pastix-32-6.3.2)-srcdir = $(pkgsrcdir)/$(pastix-32-6.3.2)
$(pastix-32-6.3.2)-builddir = $($(pastix-32-6.3.2)-srcdir)/build
$(pastix-32-6.3.2)-modulefile = $(modulefilesdir)/$(pastix-32-6.3.2)
$(pastix-32-6.3.2)-prefix = $(pkgdir)/$(pastix-32-6.3.2)

$($(pastix-32-6.3.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pastix-32-6.3.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pastix-32-6.3.2)-prefix)/.pkgunpack: $$($(pastix-32-6.3.2)-src) $($(pastix-32-6.3.2)-srcdir)/.markerfile $($(pastix-32-6.3.2)-prefix)/.markerfile $$(foreach dep,$$($(pastix-32-6.3.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(pastix-32-6.3.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pastix-32-6.3.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix-32-6.3.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix-32-6.3.2)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(pastix-32-6.3.2)-builddir),$($(pastix-32-6.3.2)-srcdir))
$($(pastix-32-6.3.2)-builddir)/.markerfile: $($(pastix-32-6.3.2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pastix-32-6.3.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix-32-6.3.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix-32-6.3.2)-builddir)/.markerfile $($(pastix-32-6.3.2)-prefix)/.pkgpatch
	cd $($(pastix-32-6.3.2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pastix-32-6.3.2)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(pastix-32-6.3.2)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=On \
			-DPASTIX_INT64=Off \
			-DPASTIX_ORDERING_SCOTCH=On \
			-DPASTIX_ORDERING_METIS=On \
			-DPASTIX_WITH_MPI=On && \
		$(MAKE)
	@touch $@

$($(pastix-32-6.3.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix-32-6.3.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix-32-6.3.2)-builddir)/.markerfile $($(pastix-32-6.3.2)-prefix)/.pkgbuild
	# cd $($(pastix-32-6.3.2)-builddir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(pastix-32-6.3.2)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(pastix-32-6.3.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix-32-6.3.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix-32-6.3.2)-builddir)/.markerfile $($(pastix-32-6.3.2)-prefix)/.pkgcheck
	cd $($(pastix-32-6.3.2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pastix-32-6.3.2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(pastix-32-6.3.2)-modulefile): $(modulefilesdir)/.markerfile $($(pastix-32-6.3.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pastix-32-6.3.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pastix-32-6.3.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pastix-32-6.3.2)-description)\"" >>$@
	echo "module-whatis \"$($(pastix-32-6.3.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(pastix-32-6.3.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PASTIX_ROOT $($(pastix-32-6.3.2)-prefix)" >>$@
	echo "setenv PASTIX_INCDIR $($(pastix-32-6.3.2)-prefix)/include" >>$@
	echo "setenv PASTIX_INCLUDEDIR $($(pastix-32-6.3.2)-prefix)/include" >>$@
	echo "setenv PASTIX_LIBDIR $($(pastix-32-6.3.2)-prefix)/lib" >>$@
	echo "setenv PASTIX_LIBRARYDIR $($(pastix-32-6.3.2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pastix-32-6.3.2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pastix-32-6.3.2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pastix-32-6.3.2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pastix-32-6.3.2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pastix-32-6.3.2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pastix-32-6.3.2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pastix-32-6.3.2)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(pastix-32-6.3.2)-prefix)/share/info" >>$@
	echo "set MSG \"$(pastix-32-6.3.2)\"" >>$@

$(pastix-32-6.3.2)-src: $$($(pastix-32-6.3.2)-src)
$(pastix-32-6.3.2)-unpack: $($(pastix-32-6.3.2)-prefix)/.pkgunpack
$(pastix-32-6.3.2)-patch: $($(pastix-32-6.3.2)-prefix)/.pkgpatch
$(pastix-32-6.3.2)-build: $($(pastix-32-6.3.2)-prefix)/.pkgbuild
$(pastix-32-6.3.2)-check: $($(pastix-32-6.3.2)-prefix)/.pkgcheck
$(pastix-32-6.3.2)-install: $($(pastix-32-6.3.2)-prefix)/.pkginstall
$(pastix-32-6.3.2)-modulefile: $($(pastix-32-6.3.2)-modulefile)
$(pastix-32-6.3.2)-clean:
	rm -rf $($(pastix-32-6.3.2)-modulefile)
	rm -rf $($(pastix-32-6.3.2)-prefix)
	rm -rf $($(pastix-32-6.3.2)-builddir)
	rm -rf $($(pastix-32-6.3.2)-srcdir)
	rm -rf $($(pastix-32-6.3.2)-src)
$(pastix-32-6.3.2): $(pastix-32-6.3.2)-src $(pastix-32-6.3.2)-unpack $(pastix-32-6.3.2)-patch $(pastix-32-6.3.2)-build $(pastix-32-6.3.2)-check $(pastix-32-6.3.2)-install $(pastix-32-6.3.2)-modulefile
