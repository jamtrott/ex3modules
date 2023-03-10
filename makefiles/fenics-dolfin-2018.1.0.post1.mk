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
# fenics-dolfin-2018.1.0.post1

fenics-dolfin-2018-version = 2018.1.0.post1
fenics-dolfin-2018 = fenics-dolfin-$(fenics-dolfin-2018-version)
$(fenics-dolfin-2018)-description = C++ interface to the FEniCS computing platform for solving partial differential equations
$(fenics-dolfin-2018)-url = https://fenicsproject.org/
$(fenics-dolfin-2018)-srcurl = $($(fenics-dolfin-2018-src)-srcurl)
$(fenics-dolfin-2018)-builddeps = $(cmake) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-dijitso-2018) $(python-fenics-fiat-2018) $(python-fenics-ufl-2018) $(python-fenics-ffc-2018) $(python-pytest)
$(fenics-dolfin-2018)-prereqs = $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-dijitso-2018) $(python-fenics-fiat-2018) $(python-fenics-ufl-2018) $(python-fenics-ffc-2018)
$(fenics-dolfin-2018)-src = $($(fenics-dolfin-2018-src)-src)
$(fenics-dolfin-2018)-srcdir = $(pkgsrcdir)/$(fenics-dolfin-2018)
$(fenics-dolfin-2018)-builddir = $($(fenics-dolfin-2018)-srcdir)/build
$(fenics-dolfin-2018)-modulefile = $(modulefilesdir)/$(fenics-dolfin-2018)
$(fenics-dolfin-2018)-prefix = $(pkgdir)/$(fenics-dolfin-2018)

$($(fenics-dolfin-2018)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2018)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2018)-prefix)/.pkgunpack: $$($(fenics-dolfin-2018)-src) $($(fenics-dolfin-2018)-srcdir)/.markerfile $($(fenics-dolfin-2018)-prefix)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(fenics-dolfin-2018)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-dolfin-2018)-srcdir)/0001-SNESTEST-is-removed.patch: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From b3458a6243c8de5afb461d221c3992ba71d21681 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: Min RK <benjaminrk@gmail.com>' >>$@.tmp
	@echo 'Date: Thu, 7 Feb 2019 12:53:29 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] SNESTEST is removed' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'The symbol is removed in 3.10.3, which prevents compilation of dolfin,' >>$@.tmp
	@echo 'but the functionality was removed in 3.9' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' dolfin/nls/PETScSNESSolver.cpp | 4 ++++' >>$@.tmp
	@echo ' 1 file changed, 4 insertions(+)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/dolfin/nls/PETScSNESSolver.cpp b/dolfin/nls/PETScSNESSolver.cpp' >>$@.tmp
	@echo 'index b3e1d62..09238be 100644' >>$@.tmp
	@echo '--- a/dolfin/nls/PETScSNESSolver.cpp' >>$@.tmp
	@echo '+++ b/dolfin/nls/PETScSNESSolver.cpp' >>$@.tmp
	@echo '@@ -48,7 +48,11 @@ PETScSNESSolver::_methods' >>$@.tmp
	@echo ' = { {"default",      {"default SNES method", ""}},' >>$@.tmp
	@echo '     {"newtonls",     {"Line search method", SNESNEWTONLS}},' >>$@.tmp
	@echo '     {"newtontr",     {"Trust region method", SNESNEWTONTR}},' >>$@.tmp
	@echo '+#if PETSC_VERSION_LT(3,9,0)' >>$@.tmp
	@echo '+    // SNESTEST functionality removed in petsc 3.9,' >>$@.tmp
	@echo '+    // symbol removed in 3.10.3' >>$@.tmp
	@echo '     {"test",         {"Tool to verify Jacobian approximation", SNESTEST}},' >>$@.tmp
	@echo '+#endif' >>$@.tmp
	@echo '     {"ngmres",       {"Nonlinear generalised minimum residual method",' >>$@.tmp
	@echo '                       SNESNGMRES}},' >>$@.tmp
	@echo '     {"nrichardson",  {"Richardson nonlinear method (Picard iteration)",' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.10.5' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2018)-srcdir)/0002-io-Fix-include-of-boost-endian.hpp.patch: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 885920473521b4f861a65b5fc130800ce8dd65cc Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Sun, 7 Jun 2020 10:35:14 +0200' >>$@.tmp
	@echo 'Subject: [PATCH 1/3] io: Fix include of <boost/endian.hpp>' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' dolfin/io/VTKFile.cpp   | 2 +-' >>$@.tmp
	@echo ' dolfin/io/VTKWriter.cpp | 2 +-' >>$@.tmp
	@echo ' 2 files changed, 2 insertions(+), 2 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/dolfin/io/VTKFile.cpp b/dolfin/io/VTKFile.cpp' >>$@.tmp
	@echo 'index 2fee53b7b..9baebd938 100644' >>$@.tmp
	@echo '--- a/dolfin/io/VTKFile.cpp' >>$@.tmp
	@echo '+++ b/dolfin/io/VTKFile.cpp' >>$@.tmp
	@echo '@@ -20,7 +20,7 @@' >>$@.tmp
	@echo ' #include <vector>' >>$@.tmp
	@echo ' #include <iomanip>' >>$@.tmp
	@echo ' #include <boost/cstdint.hpp>' >>$@.tmp
	@echo '-#include <boost/detail/endian.hpp>' >>$@.tmp
	@echo '+#include <boost/endian.hpp>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' #include "pugixml.hpp"' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo 'diff --git a/dolfin/io/VTKWriter.cpp b/dolfin/io/VTKWriter.cpp' >>$@.tmp
	@echo 'index eff693472..2d9b57004 100644' >>$@.tmp
	@echo '--- a/dolfin/io/VTKWriter.cpp' >>$@.tmp
	@echo '+++ b/dolfin/io/VTKWriter.cpp' >>$@.tmp
	@echo '@@ -24,7 +24,7 @@' >>$@.tmp
	@echo ' #include <sstream>' >>$@.tmp
	@echo ' #include <vector>' >>$@.tmp
	@echo ' #include <iomanip>' >>$@.tmp
	@echo '-#include <boost/detail/endian.hpp>' >>$@.tmp
	@echo '+#include <boost/endian.hpp>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' #include <dolfin/fem/GenericDofMap.h>' >>$@.tmp
	@echo ' #include <dolfin/fem/FiniteElement.h>' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2018)-srcdir)/0003-Require-C-17.patch: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 737314d7d7c8e27ca85528360c3481d89fc751f6 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Sun, 7 Jun 2020 10:41:25 +0200' >>$@.tmp
	@echo 'Subject: [PATCH 2/3] Require C++17' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' CMakeLists.txt | 4 ++--' >>$@.tmp
	@echo ' 1 file changed, 2 insertions(+), 2 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/CMakeLists.txt b/CMakeLists.txt' >>$@.tmp
	@echo 'index fe4757422..85680ed22 100644' >>$@.tmp
	@echo '--- a/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/CMakeLists.txt' >>$@.tmp
	@echo '@@ -19,8 +19,8 @@ endif()' >>$@.tmp
	@echo ' #------------------------------------------------------------------------------' >>$@.tmp
	@echo ' # Require and use C++11' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-# Use C++11' >>$@.tmp
	@echo '-set(CMAKE_CXX_STANDARD 11)' >>$@.tmp
	@echo '+# Use C++17' >>$@.tmp
	@echo '+set(CMAKE_CXX_STANDARD 17)' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' # Require C++11' >>$@.tmp
	@echo ' set(CMAKE_CXX_STANDARD_REQUIRED ON)' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2018)-srcdir)/0004-dolfin-mesh-MeshFunction.h-Add-missing-algorithm-inc.patch: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 54b4511bcaa559efd4af7957e3129e07c3db6884 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Sat, 13 Jun 2020 11:42:28 +0200' >>$@.tmp
	@echo 'Subject: [PATCH 3/3] dolfin/mesh/MeshFunction.h: Add missing <algorithm>' >>$@.tmp
	@echo ' include' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' dolfin/mesh/MeshFunction.h | 1 +' >>$@.tmp
	@echo ' 1 file changed, 1 insertion(+)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/dolfin/mesh/MeshFunction.h b/dolfin/mesh/MeshFunction.h' >>$@.tmp
	@echo 'index d29c13b4a..25797b4d4 100644' >>$@.tmp
	@echo '--- a/dolfin/mesh/MeshFunction.h' >>$@.tmp
	@echo '+++ b/dolfin/mesh/MeshFunction.h' >>$@.tmp
	@echo '@@ -24,6 +24,7 @@' >>$@.tmp
	@echo ' #ifndef __MESH_FUNCTION_H' >>$@.tmp
	@echo ' #define __MESH_FUNCTION_H' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+#include <algorithm>' >>$@.tmp
	@echo ' #include <map>' >>$@.tmp
	@echo ' #include <vector>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2018)-srcdir)/0005-dolfin-la-Include-petscsys.h-instead-of-petscoptions.patch: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From ed6fde7a7dc6847c27f30c40523a7c93b0107569 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Sun, 14 Jun 2020 13:06:53 +0200' >>$@.tmp
	@echo 'Subject: [PATCH] dolfin/la: Include <petscsys.h> instead of <petscoptions.h>' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' dolfin/la/PETScOptions.h | 2 +-' >>$@.tmp
	@echo ' 1 file changed, 1 insertion(+), 1 deletion(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/dolfin/la/PETScOptions.h b/dolfin/la/PETScOptions.h' >>$@.tmp
	@echo 'index 37e5054b3..5ae24e6f5 100644' >>$@.tmp
	@echo '--- a/dolfin/la/PETScOptions.h' >>$@.tmp
	@echo '+++ b/dolfin/la/PETScOptions.h' >>$@.tmp
	@echo '@@ -22,7 +22,7 @@' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' #include <string>' >>$@.tmp
	@echo ' #include <boost/lexical_cast.hpp>' >>$@.tmp
	@echo '-#include <petscoptions.h>' >>$@.tmp
	@echo '+#include <petscsys.h>' >>$@.tmp
	@echo ' #include <dolfin/common/SubSystemsManager.h>' >>$@.tmp
	@echo ' #include <dolfin/log/log.h>' >>$@.tmp
	@echo ' #include "PETScObject.h"' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2018)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2018)-srcdir)/0001-SNESTEST-is-removed.patch $($(fenics-dolfin-2018)-srcdir)/0002-io-Fix-include-of-boost-endian.hpp.patch $($(fenics-dolfin-2018)-srcdir)/0003-Require-C-17.patch $($(fenics-dolfin-2018)-prefix)/.pkgunpack $($(fenics-dolfin-2018)-srcdir)/0004-dolfin-mesh-MeshFunction.h-Add-missing-algorithm-inc.patch $($(fenics-dolfin-2018)-srcdir)/0005-dolfin-la-Include-petscsys.h-instead-of-petscoptions.patch
	cd $($(fenics-dolfin-2018)-srcdir) && \
	patch -f -p1 <0001-SNESTEST-is-removed.patch && \
	patch -f -p1 <0002-io-Fix-include-of-boost-endian.hpp.patch && \
	patch -f -p1 <0003-Require-C-17.patch && \
	patch -f -p1 <0004-dolfin-mesh-MeshFunction.h-Add-missing-algorithm-inc.patch && \
	patch -f -p1 <0005-dolfin-la-Include-petscsys.h-instead-of-petscoptions.patch
	patch -d $($(fenics-dolfin-2018)-srcdir) -f -p0 <patches/fenics-dolfin-2018.1.0-private-eigenlusolver-fix.patch
	@touch $@

$($(fenics-dolfin-2018)-builddir)/.markerfile: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2018)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2018)-builddir)/.markerfile $($(fenics-dolfin-2018)-prefix)/.pkgpatch
	cd $($(fenics-dolfin-2018)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfin-2018)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-dolfin-2018)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
			-DBUILD_SHARED_LIBS=TRUE \
			-DSKIP_BUILD_TESTS=TRUE \
			-DEIGEN3_INCLUDE_DIR="$${EIGEN_INCDIR}" \
			-DPARMETIS_DIR="$${PARMETIS_ROOT}" \
			-DSCOTCH_DIR="$${SCOTCH_ROOT}" \
			-DAMD_DIR="$${SUITESPARSE_ROOT}" \
			-DCHOLMOD_DIR="$${SUITESPARSE_ROOT}" \
			-DUMFPACK_DIR="$${SUITESPARSE_ROOT}" && \
		$(MAKE)
	@touch $@

$($(fenics-dolfin-2018)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2018)-builddir)/.markerfile $($(fenics-dolfin-2018)-prefix)/.pkgbuild
	@touch $@

$($(fenics-dolfin-2018)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2018)-builddir)/.markerfile $($(fenics-dolfin-2018)-prefix)/.pkgcheck
	cd $($(fenics-dolfin-2018)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfin-2018)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fenics-dolfin-2018)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-dolfin-2018)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-dolfin-2018)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-dolfin-2018)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-dolfin-2018)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-dolfin-2018)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-dolfin-2018)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_DOLFIN_2018_ROOT $($(fenics-dolfin-2018)-prefix)" >>$@
	echo "setenv FENICS_DOLFIN_2018_INCDIR $($(fenics-dolfin-2018)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFIN_2018_INCLUDEDIR $($(fenics-dolfin-2018)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFIN_2018_LIBDIR $($(fenics-dolfin-2018)-prefix)/lib" >>$@
	echo "setenv FENICS_DOLFIN_2018_LIBRARYDIR $($(fenics-dolfin-2018)-prefix)/lib" >>$@
	echo "setenv DOLFIN_DIR $($(fenics-dolfin-2018)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-dolfin-2018)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-dolfin-2018)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-dolfin-2018)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-dolfin-2018)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-dolfin-2018)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-dolfin-2018)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-dolfin-2018)-prefix)/share/dolfin/cmake" >>$@
	echo "set MSG \"$(fenics-dolfin-2018)\"" >>$@

$(fenics-dolfin-2018)-src: $($(fenics-dolfin-2018)-src)
$(fenics-dolfin-2018)-unpack: $($(fenics-dolfin-2018)-prefix)/.pkgunpack
$(fenics-dolfin-2018)-patch: $($(fenics-dolfin-2018)-prefix)/.pkgpatch
$(fenics-dolfin-2018)-build: $($(fenics-dolfin-2018)-prefix)/.pkgbuild
$(fenics-dolfin-2018)-check: $($(fenics-dolfin-2018)-prefix)/.pkgcheck
$(fenics-dolfin-2018)-install: $($(fenics-dolfin-2018)-prefix)/.pkginstall
$(fenics-dolfin-2018)-modulefile: $($(fenics-dolfin-2018)-modulefile)
$(fenics-dolfin-2018)-clean:
	rm -rf $($(fenics-dolfin-2018)-modulefile)
	rm -rf $($(fenics-dolfin-2018)-prefix)
	rm -rf $($(fenics-dolfin-2018)-srcdir)
$(fenics-dolfin-2018): $(fenics-dolfin-2018)-src $(fenics-dolfin-2018)-unpack $(fenics-dolfin-2018)-patch $(fenics-dolfin-2018)-build $(fenics-dolfin-2018)-check $(fenics-dolfin-2018)-install $(fenics-dolfin-2018)-modulefile
