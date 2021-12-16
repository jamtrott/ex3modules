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
# fenics-mshr-2019.1.0

fenics-mshr-2019-version = 2019.1.0
fenics-mshr-2019 = fenics-mshr-$(fenics-mshr-2019-version)
$(fenics-mshr-2019)-description = FEniCS Project: Mesh generation
$(fenics-mshr-2019)-url = https://fenicsproject.org/
$(fenics-mshr-2019)-srcurl = $($(fenics-mshr-2019-src)-srcurl)
$(fenics-mshr-2019)-builddeps = $(cmake) $(boost) $(gmp) $(mpfr) $(eigen) $(python) $(python-fenics-dolfin-2019) $(cgal-4.12) $(patchelf)
$(fenics-mshr-2019)-prereqs = $(python) $(boost) $(gmp) $(mpfr) $(python-fenics-dolfin-2019) $(cgal-4.12)
$(fenics-mshr-2019)-src = $($(fenics-mshr-2019-src)-src)
$(fenics-mshr-2019)-srcdir = $(pkgsrcdir)/$(fenics-mshr-2019)
$(fenics-mshr-2019)-builddir = $($(fenics-mshr-2019)-srcdir)/build
$(fenics-mshr-2019)-modulefile = $(modulefilesdir)/$(fenics-mshr-2019)
$(fenics-mshr-2019)-prefix = $(pkgdir)/$(fenics-mshr-2019)

$($(fenics-mshr-2019)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-mshr-2019)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-mshr-2019)-prefix)/.pkgunpack: $$($(fenics-mshr-2019)-src) $($(fenics-mshr-2019)-srcdir)/.markerfile $($(fenics-mshr-2019)-prefix)/.markerfile
	tar -C $($(fenics-mshr-2019)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-mshr-2019)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-mshr-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-mshr-2019)-prefix)/.pkgunpack
	@touch $@

$($(fenics-mshr-2019)-builddir)/.markerfile: $($(fenics-mshr-2019)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-mshr-2019)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-mshr-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-mshr-2019)-builddir)/.markerfile $($(fenics-mshr-2019)-prefix)/.pkgpatch
	cd $($(fenics-mshr-2019)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-mshr-2019)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-mshr-2019)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
			-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
			-DCMAKE_POLICY_DEFAULT_CMP0060=NEW \
			-DBUILD_SHARED_LIBS=TRUE \
			-DCMAKE_RULE_MESSAGES:BOOL=OFF \
			-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
			-DGMP_LIBRARIES="$${GMP_LIBDIR}" \
			-DGMP_INCLUDE_DIR="$${GMP_INCDIR}" \
			-DMPFR_LIBRARIES="$${MPFR_LIBDIR}" \
			-DMPFR_INCLUDE_DIR="$${MPFR_INCDIR}" \
			-DEIGEN3_INCLUDE_DIR="$${EIGEN_INCDIR}" \
			-DUSE_SYSTEM_CGAL=TRUE \
			-DCGAL_ROOT="$${CGAL_ROOT}" && \
		$(MAKE)
	@touch $@

$($(fenics-mshr-2019)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-mshr-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-mshr-2019)-builddir)/.markerfile $($(fenics-mshr-2019)-prefix)/.pkgbuild
	@touch $@

$($(fenics-mshr-2019)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-mshr-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-mshr-2019)-builddir)/.markerfile $($(fenics-mshr-2019)-prefix)/.pkgcheck
	cd $($(fenics-mshr-2019)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-mshr-2019)-builddeps) && \
		$(MAKE) install && \
		patchelf  $($(fenics-mshr-2019)-prefix)/lib/libmshr.so --add-needed $${CGAL_LIBDIR}/libCGAL.so
	@touch $@

$($(fenics-mshr-2019)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-mshr-2019)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-mshr-2019)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-mshr-2019)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-mshr-2019)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-mshr-2019)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-mshr-2019)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_MSHR_2019_ROOT $($(fenics-mshr-2019)-prefix)" >>$@
	echo "setenv FENICS_MSHR_2019_INCDIR $($(fenics-mshr-2019)-prefix)/include" >>$@
	echo "setenv FENICS_MSHR_2019_INCLUDEDIR $($(fenics-mshr-2019)-prefix)/include" >>$@
	echo "setenv FENICS_MSHR_2019_LIBDIR $($(fenics-mshr-2019)-prefix)/lib" >>$@
	echo "setenv FENICS_MSHR_2019_LIBRARYDIR $($(fenics-mshr-2019)-prefix)/lib" >>$@
	echo "setenv MSHR_DIR $($(fenics-mshr-2019)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-mshr-2019)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-mshr-2019)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-mshr-2019)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-mshr-2019)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-mshr-2019)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-mshr-2019)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-mshr-2019)-prefix)/share/mshr/cmake" >>$@
	echo "set MSG \"$(fenics-mshr-2019)\"" >>$@

$(fenics-mshr-2019)-src: $($(fenics-mshr-2019)-src)
$(fenics-mshr-2019)-unpack: $($(fenics-mshr-2019)-prefix)/.pkgunpack
$(fenics-mshr-2019)-patch: $($(fenics-mshr-2019)-prefix)/.pkgpatch
$(fenics-mshr-2019)-build: $($(fenics-mshr-2019)-prefix)/.pkgbuild
$(fenics-mshr-2019)-check: $($(fenics-mshr-2019)-prefix)/.pkgcheck
$(fenics-mshr-2019)-install: $($(fenics-mshr-2019)-prefix)/.pkginstall
$(fenics-mshr-2019)-modulefile: $($(fenics-mshr-2019)-modulefile)
$(fenics-mshr-2019)-clean:
	rm -rf $($(fenics-mshr-2019)-modulefile)
	rm -rf $($(fenics-mshr-2019)-prefix)
	rm -rf $($(fenics-mshr-2019)-srcdir)
$(fenics-mshr-2019): $(fenics-mshr-2019)-src $(fenics-mshr-2019)-unpack $(fenics-mshr-2019)-patch $(fenics-mshr-2019)-build $(fenics-mshr-2019)-check $(fenics-mshr-2019)-install $(fenics-mshr-2019)-modulefile
