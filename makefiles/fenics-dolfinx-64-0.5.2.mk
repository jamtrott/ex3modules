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
# fenics-dolfinx-64-0.5.2

fenics-dolfinx-64-0.5.2-version = 0.5.2
fenics-dolfinx-64-0.5.2 = fenics-dolfinx-64-$(fenics-dolfinx-64-0.5.2-version)
$(fenics-dolfinx-64-0.5.2)-description = Next generation FEniCS problem solving environment
$(fenics-dolfinx-64-0.5.2)-url = https://github.com/FEniCS/dolfinx
$(fenics-dolfinx-64-0.5.2)-srcurl = 
$(fenics-dolfinx-64-0.5.2)-builddeps = $(cmake) $(ninja) $(boost) $(mpi) $(hdf5-parallel) $(parmetis-64) $(scotch-64) $(suitesparse-64) $(metis-64) $(petsc-64) $(python) $(python-fenics-basix-0.5.0) $(python-fenics-ufl-2022) $(python-fenics-ffcx-0.5.0) $(python-pytest) $(pugixml) $(xtensor)
$(fenics-dolfinx-64-0.5.2)-prereqs = $(boost) $(mpi) $(hdf5-parallel) $(parmetis-64) $(scotch-64) $(suitesparse-64) $(metis-64) $(petsc-64) $(python) $(python-fenics-basix-0.5.0) $(python-fenics-ufl-2022) $(python-fenics-ffcx-0.5.0) $(pugixml) $(xtensor)
$(fenics-dolfinx-64-0.5.2)-src = $($(fenics-dolfinx-src-0.5.2)-src)
$(fenics-dolfinx-64-0.5.2)-srcdir = $(pkgsrcdir)/$(fenics-dolfinx-64-0.5.2)
$(fenics-dolfinx-64-0.5.2)-builddir = $($(fenics-dolfinx-64-0.5.2)-srcdir)/cpp/build
$(fenics-dolfinx-64-0.5.2)-modulefile = $(modulefilesdir)/$(fenics-dolfinx-64-0.5.2)
$(fenics-dolfinx-64-0.5.2)-prefix = $(pkgdir)/$(fenics-dolfinx-64-0.5.2)

$($(fenics-dolfinx-64-0.5.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfinx-64-0.5.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgunpack: $$($(fenics-dolfinx-64-0.5.2)-src) $($(fenics-dolfinx-64-0.5.2)-srcdir)/.markerfile $($(fenics-dolfinx-64-0.5.2)-prefix)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-64-0.5.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(fenics-dolfinx-64-0.5.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-64-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(fenics-dolfinx-64-0.5.2)-builddir),$($(fenics-dolfinx-64-0.5.2)-srcdir))
$($(fenics-dolfinx-64-0.5.2)-builddir)/.markerfile: $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-64-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-64-0.5.2)-builddir)/.markerfile $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgpatch
	cd $($(fenics-dolfinx-64-0.5.2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfinx-64-0.5.2)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-dolfinx-64-0.5.2)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE) VERBOSE=1
	@touch $@

$($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-64-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-64-0.5.2)-builddir)/.markerfile $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgbuild
	@touch $@

$($(fenics-dolfinx-64-0.5.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-64-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-64-0.5.2)-builddir)/.markerfile $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgcheck
	cd $($(fenics-dolfinx-64-0.5.2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfinx-64-0.5.2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fenics-dolfinx-64-0.5.2)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-dolfinx-64-0.5.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-dolfinx-64-0.5.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-dolfinx-64-0.5.2)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-dolfinx-64-0.5.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-dolfinx-64-0.5.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_DOLFINX_ROOT $($(fenics-dolfinx-64-0.5.2)-prefix)" >>$@
	echo "setenv FENICS_DOLFINX_INCDIR $($(fenics-dolfinx-64-0.5.2)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFINX_INCLUDEDIR $($(fenics-dolfinx-64-0.5.2)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFINX_LIBDIR $($(fenics-dolfinx-64-0.5.2)-prefix)/lib" >>$@
	echo "setenv FENICS_DOLFINX_LIBRARYDIR $($(fenics-dolfinx-64-0.5.2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(fenics-dolfinx-64-0.5.2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-dolfinx-64-0.5.2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-dolfinx-64-0.5.2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-dolfinx-64-0.5.2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-dolfinx-64-0.5.2)-prefix)/lib" >>$@
	echo "set MSG \"$(fenics-dolfinx-64-0.5.2)\"" >>$@

$(fenics-dolfinx-64-0.5.2)-src: $$($(fenics-dolfinx-64-0.5.2)-src)
$(fenics-dolfinx-64-0.5.2)-unpack: $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgunpack
$(fenics-dolfinx-64-0.5.2)-patch: $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgpatch
$(fenics-dolfinx-64-0.5.2)-build: $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgbuild
$(fenics-dolfinx-64-0.5.2)-check: $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkgcheck
$(fenics-dolfinx-64-0.5.2)-install: $($(fenics-dolfinx-64-0.5.2)-prefix)/.pkginstall
$(fenics-dolfinx-64-0.5.2)-modulefile: $($(fenics-dolfinx-64-0.5.2)-modulefile)
$(fenics-dolfinx-64-0.5.2)-clean:
	rm -rf $($(fenics-dolfinx-64-0.5.2)-modulefile)
	rm -rf $($(fenics-dolfinx-64-0.5.2)-prefix)
	rm -rf $($(fenics-dolfinx-64-0.5.2)-builddir)
	rm -rf $($(fenics-dolfinx-64-0.5.2)-srcdir)
	rm -rf $($(fenics-dolfinx-64-0.5.2)-src)
$(fenics-dolfinx-64-0.5.2): $(fenics-dolfinx-64-0.5.2)-src $(fenics-dolfinx-64-0.5.2)-unpack $(fenics-dolfinx-64-0.5.2)-patch $(fenics-dolfinx-64-0.5.2)-build $(fenics-dolfinx-64-0.5.2)-check $(fenics-dolfinx-64-0.5.2)-install $(fenics-dolfinx-64-0.5.2)-modulefile
