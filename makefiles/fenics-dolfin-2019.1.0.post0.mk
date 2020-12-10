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
# fenics-dolfin-2019.1.0.post0

fenics-dolfin-2019-version = 2019.1.0.post0
fenics-dolfin-2019 = fenics-dolfin-$(fenics-dolfin-2019-version)
$(fenics-dolfin-2019)-description = C++ interface to the FEniCS computing platform for solving partial differential equations
$(fenics-dolfin-2019)-url = https://fenicsproject.org/
$(fenics-dolfin-2019)-srcurl = $($(fenics-dolfin-2019-src)-srcurl)
$(fenics-dolfin-2019)-builddeps = $(gcc-10.1.0) $(cmake) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019) $(python-fenics-ufl-2019) $(python-fenics-ffc-2019) $(python-pytest)
$(fenics-dolfin-2019)-prereqs = $(libstdcxx) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019) $(python-fenics-ufl-2019) $(python-fenics-ffc-2019)
$(fenics-dolfin-2019)-src = $($(fenics-dolfin-2019-src)-src)
$(fenics-dolfin-2019)-srcdir = $(pkgsrcdir)/$(fenics-dolfin-2019)
$(fenics-dolfin-2019)-builddir = $($(fenics-dolfin-2019)-srcdir)/build
$(fenics-dolfin-2019)-modulefile = $(modulefilesdir)/$(fenics-dolfin-2019)
$(fenics-dolfin-2019)-prefix = $(pkgdir)/$(fenics-dolfin-2019)

$($(fenics-dolfin-2019)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2019)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2019)-prefix)/.pkgunpack: $$($(fenics-dolfin-2019)-src) $($(fenics-dolfin-2019)-srcdir)/.markerfile $($(fenics-dolfin-2019)-prefix)/.markerfile
	tar -C $($(fenics-dolfin-2019)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-dolfin-2019)-srcdir)/0001-io-Fix-include-of-boost-endian.hpp.patch: $($(fenics-dolfin-2019)-prefix)/.pkgunpack
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

$($(fenics-dolfin-2019)-srcdir)/0002-Require-C-17.patch: $($(fenics-dolfin-2019)-prefix)/.pkgunpack
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
	@echo '@@ -19,8 +19,8 @@\n'
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

$($(fenics-dolfin-2019)-srcdir)/0003-Add-missing-algorithm-include.patch: $($(fenics-dolfin-2019)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 569bbc7f0d218432e76e68137b3f647b4b8faa6f Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>' >>$@.tmp
	@echo 'Date: Thu, 15 Oct 2020 16:09:19 +0200' >>$@.tmp
	@echo 'Subject: [PATCH] Add missing algorithm include for std::min_element/count' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'algorithm is no longer pulled in implicitly by current boost versions,' >>$@.tmp
	@echo 'do it explicitly.' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' dolfin/geometry/IntersectionConstruction.cpp | 1 +' >>$@.tmp
	@echo ' dolfin/mesh/MeshFunction.h                   | 1 +' >>$@.tmp
	@echo ' 2 files changed, 2 insertions(+)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/dolfin/geometry/IntersectionConstruction.cpp b/dolfin/geometry/IntersectionConstruction.cpp' >>$@.tmp
	@echo 'index 765dbb6..7ba99a8 100644' >>$@.tmp
	@echo '--- a/dolfin/geometry/IntersectionConstruction.cpp' >>$@.tmp
	@echo '+++ b/dolfin/geometry/IntersectionConstruction.cpp' >>$@.tmp
	@echo '@@ -18,6 +18,7 @@' >>$@.tmp
	@echo ' // First added:  2014-02-03' >>$@.tmp
	@echo ' // Last changed: 2017-12-12' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+#include <algorithm>' >>$@.tmp
	@echo ' #include <iomanip>' >>$@.tmp
	@echo ' #include <dolfin/mesh/MeshEntity.h>' >>$@.tmp
	@echo ' #include "predicates.h"' >>$@.tmp
	@echo 'diff --git a/dolfin/mesh/MeshFunction.h b/dolfin/mesh/MeshFunction.h' >>$@.tmp
	@echo 'index 08cbc82..4e68324 100644' >>$@.tmp
	@echo '--- a/dolfin/mesh/MeshFunction.h' >>$@.tmp
	@echo '+++ b/dolfin/mesh/MeshFunction.h' >>$@.tmp
	@echo '@@ -27,6 +27,7 @@' >>$@.tmp
	@echo ' #include <map>' >>$@.tmp
	@echo ' #include <vector>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+#include <algorithm>' >>$@.tmp
	@echo ' #include <memory>' >>$@.tmp
	@echo ' #include <unordered_set>' >>$@.tmp
	@echo ' #include <dolfin/common/Hierarchical.h>' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.28.0' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2019)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019)-srcdir)/0001-io-Fix-include-of-boost-endian.hpp.patch $($(fenics-dolfin-2019)-srcdir)/0002-Require-C-17.patch $($(fenics-dolfin-2019)-prefix)/.pkgunpack $($(fenics-dolfin-2019)-srcdir)/0003-Add-missing-algorithm-include.patch
	cd $($(fenics-dolfin-2019)-srcdir) && \
		patch -t -p1 <0001-io-Fix-include-of-boost-endian.hpp.patch && \
		patch -t -p1 <0002-Require-C-17.patch && \
		patch -t -p1 <0003-Add-missing-algorithm-include.patch
	@touch $@

$($(fenics-dolfin-2019)-builddir)/.markerfile: $($(fenics-dolfin-2019)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2019)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019)-builddir)/.markerfile $($(fenics-dolfin-2019)-prefix)/.pkgpatch
	cd $($(fenics-dolfin-2019)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfin-2019)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-dolfin-2019)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
			-DBUILD_SHARED_LIBS=TRUE \
			-DDOLFIN_SKIP_BUILD_TESTS=TRUE \
			-DEIGEN3_INCLUDE_DIR="$${EIGEN_INCDIR}" \
			-DPARMETIS_DIR="$${PARMETIS_ROOT}" \
			-DSCOTCH_DIR="$${SCOTCH_ROOT}" \
			-DAMD_DIR="$${SUITESPARSE_ROOT}" \
			-DCHOLMOD_DIR="$${SUITESPARSE_ROOT}" \
			-DUMFPACK_DIR="$${SUITESPARSE_ROOT}" && \
		$(MAKE)
	@touch $@

$($(fenics-dolfin-2019)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019)-builddir)/.markerfile $($(fenics-dolfin-2019)-prefix)/.pkgbuild
	@touch $@

$($(fenics-dolfin-2019)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019)-builddir)/.markerfile $($(fenics-dolfin-2019)-prefix)/.pkgcheck
	cd $($(fenics-dolfin-2019)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfin-2019)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fenics-dolfin-2019)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-dolfin-2019)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-dolfin-2019)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-dolfin-2019)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-dolfin-2019)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-dolfin-2019)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-dolfin-2019)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_DOLFIN_2019_ROOT $($(fenics-dolfin-2019)-prefix)" >>$@
	echo "setenv FENICS_DOLFIN_2019_INCDIR $($(fenics-dolfin-2019)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFIN_2019_INCLUDEDIR $($(fenics-dolfin-2019)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFIN_2019_LIBDIR $($(fenics-dolfin-2019)-prefix)/lib" >>$@
	echo "setenv FENICS_DOLFIN_2019_LIBRARYDIR $($(fenics-dolfin-2019)-prefix)/lib" >>$@
	echo "setenv DOLFIN_DIR $($(fenics-dolfin-2019)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-dolfin-2019)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-dolfin-2019)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-dolfin-2019)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-dolfin-2019)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-dolfin-2019)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-dolfin-2019)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-dolfin-2019)-prefix)/share/dolfin/cmake" >>$@
	echo "set MSG \"$(fenics-dolfin-2019)\"" >>$@

$(fenics-dolfin-2019)-src: $($(fenics-dolfin-2019)-src)
$(fenics-dolfin-2019)-unpack: $($(fenics-dolfin-2019)-prefix)/.pkgunpack
$(fenics-dolfin-2019)-patch: $($(fenics-dolfin-2019)-prefix)/.pkgpatch
$(fenics-dolfin-2019)-build: $($(fenics-dolfin-2019)-prefix)/.pkgbuild
$(fenics-dolfin-2019)-check: $($(fenics-dolfin-2019)-prefix)/.pkgcheck
$(fenics-dolfin-2019)-install: $($(fenics-dolfin-2019)-prefix)/.pkginstall
$(fenics-dolfin-2019)-modulefile: $($(fenics-dolfin-2019)-modulefile)
$(fenics-dolfin-2019)-clean:
	rm -rf $($(fenics-dolfin-2019)-modulefile)
	rm -rf $($(fenics-dolfin-2019)-prefix)
	rm -rf $($(fenics-dolfin-2019)-srcdir)
$(fenics-dolfin-2019): $(fenics-dolfin-2019)-src $(fenics-dolfin-2019)-unpack $(fenics-dolfin-2019)-patch $(fenics-dolfin-2019)-build $(fenics-dolfin-2019)-check $(fenics-dolfin-2019)-install $(fenics-dolfin-2019)-modulefile
