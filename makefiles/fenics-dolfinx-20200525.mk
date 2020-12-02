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
# fenics-dolfinx-20200525

fenics-dolfinx-20200525-version = 20200525
fenics-dolfinx-20200525 = fenics-dolfinx-$(fenics-dolfinx-20200525-version)
$(fenics-dolfinx-20200525)-description = C++ interface to the FEniCS computing platform for solving partial differential equations (Experimental)
$(fenics-dolfinx-20200525)-url = https://fenicsproject.org/
$(fenics-dolfinx-20200525)-srcurl =
$(fenics-dolfinx-20200525)-builddeps = $(gcc-10.1.0) $(cmake) $(ninja) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-fiat-20200518) $(python-fenics-ufl-20200512) $(python-fenics-ffcx-20200522) $(python-pytest)
$(fenics-dolfinx-20200525)-prereqs = $(libstdcxx) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python)  $(python-fenics-fiat-20200518) $(python-fenics-ufl-20200512) $(python-fenics-ffcx-20200522)
$(fenics-dolfinx-20200525)-src = $($(fenics-dolfinx-src)-src)
$(fenics-dolfinx-20200525)-srcdir = $(pkgsrcdir)/$(fenics-dolfinx-20200525)
$(fenics-dolfinx-20200525)-builddir = $($(fenics-dolfinx-20200525)-srcdir)/dolfinx-29274633248cfbce175599ad2127d0949afdb166/cpp/build
$(fenics-dolfinx-20200525)-modulefile = $(modulefilesdir)/$(fenics-dolfinx-20200525)
$(fenics-dolfinx-20200525)-prefix = $(pkgdir)/$(fenics-dolfinx-20200525)

$($(fenics-dolfinx-20200525)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(fenics-dolfinx-20200525)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(fenics-dolfinx-20200525)-prefix)/.pkgunpack: $$($(fenics-dolfinx-20200525)-src) $($(fenics-dolfinx-20200525)-srcdir)/.markerfile $($(fenics-dolfinx-20200525)-prefix)/.markerfile
	cd $($(fenics-dolfinx-20200525)-srcdir) && unzip -o $<
	@touch $@

$($(fenics-dolfinx-20200525)-srcdir)/0001-Fix-install-directory-permissions.patch: $($(fenics-dolfinx-20200525)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 2d65dc56727ecc8b22e3b03a89650397672d04fa Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Wed, 2 Dec 2020 10:53:41 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Fix install directory permissions' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' dolfinx-29274633248cfbce175599ad2127d0949afdb166/cpp/CMakeLists.txt | 1 +' >>$@.tmp
	@echo ' 1 file changed, 1 insertion(+)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/dolfinx-29274633248cfbce175599ad2127d0949afdb166/cpp/CMakeLists.txt b/cpp/CMakeLists.txt' >>$@.tmp
	@echo 'index 03db9a6..c0e7254 100644' >>$@.tmp
	@echo '--- a/dolfinx-29274633248cfbce175599ad2127d0949afdb166/cpp/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/dolfinx-29274633248cfbce175599ad2127d0949afdb166/cpp/CMakeLists.txt' >>$@.tmp
	@echo '@@ -337,6 +337,7 @@ endif()' >>$@.tmp
	@echo ' #------------------------------------------------------------------------------' >>$@.tmp
	@echo ' # Install the demo source files' >>$@.tmp
	@echo ' install(DIRECTORY $${CMAKE_CURRENT_BINARY_DIR}/demo DESTINATION $${CMAKE_INSTALL_DATAROOTDIR}/dolfinx' >>$@.tmp
	@echo '+  DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '   FILES_MATCHING' >>$@.tmp
	@echo '   PATTERN "CMakeLists.txt"' >>$@.tmp
	@echo '   PATTERN "*.h"' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '1.8.3.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfinx-20200525)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-20200525)-srcdir)/0001-Fix-install-directory-permissions.patch
	cd $($(fenics-dolfinx-20200525)-srcdir) && patch -t -p1 <0001-Fix-install-directory-permissions.patch
	@touch $@

$($(fenics-dolfinx-20200525)-builddir)/.markerfile: $($(fenics-dolfinx-20200525)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(fenics-dolfinx-20200525)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-20200525)-builddir)/.markerfile $($(fenics-dolfinx-20200525)-prefix)/.pkgpatch
	cd $($(fenics-dolfinx-20200525)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfinx-20200525)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-dolfinx-20200525)-prefix) \
			-DCMAKE_INSTALL_DEFAULT_DIRECTORY_PERMISSIONS=OWNER_READ\;OWNER_EXECUTE\;OWNER_WRITE\;GROUP_READ\;GROUP_EXECUTE\;SETGID\;WORLD_READ\;WORLD_EXECUTE \
			-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
			-DBUILD_SHARED_LIBS=TRUE \
			-DDOLFINX_SKIP_BUILD_TESTS=TRUE \
			-DEIGEN3_INCLUDE_DIR="$${EIGEN_INCDIR}" && \
		$(MAKE)
	@touch $@

$($(fenics-dolfinx-20200525)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-20200525)-builddir)/.markerfile $($(fenics-dolfinx-20200525)-prefix)/.pkgbuild
	@touch $@

$($(fenics-dolfinx-20200525)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfinx-20200525)-builddir)/.markerfile $($(fenics-dolfinx-20200525)-prefix)/.pkgcheck
	cd $($(fenics-dolfinx-20200525)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfinx-20200525)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fenics-dolfinx-20200525)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-dolfinx-20200525)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-dolfinx-20200525)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-dolfinx-20200525)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-dolfinx-20200525)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-dolfinx-20200525)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-dolfinx-20200525)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_DOLFINX_20200525_ROOT $($(fenics-dolfinx-20200525)-prefix)" >>$@
	echo "setenv FENICS_DOLFINX_20200525_INCDIR $($(fenics-dolfinx-20200525)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFINX_20200525_INCLUDEDIR $($(fenics-dolfinx-20200525)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFINX_20200525_LIBDIR $($(fenics-dolfinx-20200525)-prefix)/lib" >>$@
	echo "setenv FENICS_DOLFINX_20200525_LIBRARYDIR $($(fenics-dolfinx-20200525)-prefix)/lib" >>$@
	echo "setenv DOLFINX_DIR $($(fenics-dolfinx-20200525)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-dolfinx-20200525)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-dolfinx-20200525)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-dolfinx-20200525)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-dolfinx-20200525)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-dolfinx-20200525)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-dolfinx-20200525)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-dolfinx-20200525)-prefix)/share/dolfinx/cmake" >>$@
	echo "set MSG \"$(fenics-dolfinx-20200525)\"" >>$@

$(fenics-dolfinx-20200525)-src: $($(fenics-dolfinx-20200525)-src)
$(fenics-dolfinx-20200525)-unpack: $($(fenics-dolfinx-20200525)-prefix)/.pkgunpack
$(fenics-dolfinx-20200525)-patch: $($(fenics-dolfinx-20200525)-prefix)/.pkgpatch
$(fenics-dolfinx-20200525)-build: $($(fenics-dolfinx-20200525)-prefix)/.pkgbuild
$(fenics-dolfinx-20200525)-check: $($(fenics-dolfinx-20200525)-prefix)/.pkgcheck
$(fenics-dolfinx-20200525)-install: $($(fenics-dolfinx-20200525)-prefix)/.pkginstall
$(fenics-dolfinx-20200525)-modulefile: $($(fenics-dolfinx-20200525)-modulefile)
$(fenics-dolfinx-20200525)-clean:
	rm -rf $($(fenics-dolfinx-20200525)-modulefile)
	rm -rf $($(fenics-dolfinx-20200525)-prefix)
	rm -rf $($(fenics-dolfinx-20200525)-builddir)
	rm -rf $($(fenics-dolfinx-20200525)-srcdir)
$(fenics-dolfinx-20200525): $(fenics-dolfinx-20200525)-src $(fenics-dolfinx-20200525)-unpack $(fenics-dolfinx-20200525)-patch $(fenics-dolfinx-20200525)-build $(fenics-dolfinx-20200525)-check $(fenics-dolfinx-20200525)-install $(fenics-dolfinx-20200525)-modulefile
