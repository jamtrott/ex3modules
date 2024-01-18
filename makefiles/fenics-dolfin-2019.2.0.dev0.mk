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
# fenics-dolfin-2019.2.0.dev0

fenics-dolfin-2019.2.0.dev0-version = 2019.2.0.dev0
fenics-dolfin-2019.2.0.dev0 = fenics-dolfin-$(fenics-dolfin-2019.2.0.dev0-version)
$(fenics-dolfin-2019.2.0.dev0)-description = C++ interface to the FEniCS computing platform for solving partial differential equations
$(fenics-dolfin-2019.2.0.dev0)-url = https://fenicsproject.org/
$(fenics-dolfin-2019.2.0.dev0)-srcurl = $($(fenics-dolfin-src-2019.2.0.dev0)-srcurl)
$(fenics-dolfin-2019.2.0.dev0)-builddeps = $(cmake) $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(blas) $(gfortran) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019.2.0.dev0) $(python-fenics-ufl-legacy) $(python-fenics-ffc-2019.2.0.dev0) $(python-pytest)
$(fenics-dolfin-2019.2.0.dev0)-prereqs = $(boost) $(mpi) $(hdf5-parallel) $(parmetis) $(scotch) $(blas) $(suitesparse) $(metis) $(eigen) $(petsc) $(python) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019.2.0.dev0) $(python-fenics-ufl-legacy) $(python-fenics-ffc-2019.2.0.dev0)
$(fenics-dolfin-2019.2.0.dev0)-src = $($(fenics-dolfin-src-2019.2.0.dev0)-src)
$(fenics-dolfin-2019.2.0.dev0)-srcdir = $(pkgsrcdir)/$(fenics-dolfin-2019.2.0.dev0)
$(fenics-dolfin-2019.2.0.dev0)-builddir = $($(fenics-dolfin-2019.2.0.dev0)-srcdir)/build
$(fenics-dolfin-2019.2.0.dev0)-modulefile = $(modulefilesdir)/$(fenics-dolfin-2019.2.0.dev0)
$(fenics-dolfin-2019.2.0.dev0)-prefix = $(pkgdir)/$(fenics-dolfin-2019.2.0.dev0)

$($(fenics-dolfin-2019.2.0.dev0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2019.2.0.dev0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack: $$($(fenics-dolfin-2019.2.0.dev0)-src) $($(fenics-dolfin-2019.2.0.dev0)-srcdir)/.markerfile $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(fenics-dolfin-2019.2.0.dev0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-dolfin-2019.2.0.dev0)-srcdir)/0002-Require-C-17.patch: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack
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
	@echo '@@ -19,8 +19,8 @@\n' >>$@.tmp
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

$($(fenics-dolfin-2019.2.0.dev0)-srcdir)/0004-Look-for-metis-in-METIS_DIR.patch: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 63d1947072406de28aefe249bef6cff5742223fb Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Wed, 1 Sep 2021 11:44:02 +0200' >>$@.tmp
	@echo 'Subject: [PATCH] Look for metis in METIS_DIR' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' cmake/modules/FindParMETIS.cmake | 2 +-' >>$@.tmp
	@echo ' 1 file changed, 1 insertion(+), 1 deletion(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/cmake/modules/FindParMETIS.cmake b/cmake/modules/FindParMETIS.cmake' >>$@.tmp
	@echo 'index c88e59a..489891f 100644' >>$@.tmp
	@echo '--- a/cmake/modules/FindParMETIS.cmake' >>$@.tmp
	@echo '+++ b/cmake/modules/FindParMETIS.cmake' >>$@.tmp
	@echo '@@ -51,7 +51,7 @@ if (MPI_CXX_FOUND)' >>$@.tmp
	@echo '   )' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '   find_library(METIS_LIBRARY metis' >>$@.tmp
	@echo '-    HINTS $${PARMETIS_DIR}/lib $$ENV{PARMETIS_DIR}/lib $${PETSC_LIBRARY_DIRS}' >>$@.tmp
	@echo '+    HINTS $${METIS_DIR}/lib $$ENV{METIS_DIR}/lib $${PARMETIS_DIR}/lib $$ENV{PARMETIS_DIR}/lib $${PETSC_LIBRARY_DIRS}' >>$@.tmp
	@echo '     NO_DEFAULT_PATH' >>$@.tmp
	@echo '     DOC "Directory where the METIS library is located"' >>$@.tmp
	@echo '   )' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@mv $@.tmp $@


$($(fenics-dolfin-2019.2.0.dev0)-srcdir)/0005-Allow-overriding-Fortran-compiler.patch: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 83781875acd6478be6f06d629c30df1b84349b56 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Mon, 13 Sep 2021 19:43:48 +0200' >>$@.tmp
	@echo 'Subject: [PATCH] Allow overriding Fortran compiler' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' cmake/modules/FindCHOLMOD.cmake | 4 +++-' >>$@.tmp
	@echo ' cmake/modules/FindUMFPACK.cmake | 4 +++-' >>$@.tmp
	@echo ' 2 files changed, 6 insertions(+), 2 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/cmake/modules/FindCHOLMOD.cmake b/cmake/modules/FindCHOLMOD.cmake' >>$@.tmp
	@echo 'index 011c343..60d3f55 100644' >>$@.tmp
	@echo '--- a/cmake/modules/FindCHOLMOD.cmake' >>$@.tmp
	@echo '+++ b/cmake/modules/FindCHOLMOD.cmake' >>$@.tmp
	@echo '@@ -130,7 +130,9 @@ if (BLAS_FOUND)' >>$@.tmp
	@echo '   set(CHOLMOD_LIBRARIES $${CHOLMOD_LIBRARIES} $${BLAS_LIBRARIES})' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '-find_program(GFORTRAN_EXECUTABLE gfortran)' >>$@.tmp
	@echo '+if (NOT GFORTRAN_EXECUTABLE)' >>$@.tmp
	@echo '+  find_program(GFORTRAN_EXECUTABLE gfortran)' >>$@.tmp
	@echo '+endif()' >>$@.tmp
	@echo ' if (GFORTRAN_EXECUTABLE)' >>$@.tmp
	@echo '   execute_process(COMMAND $${GFORTRAN_EXECUTABLE} -print-file-name=libgfortran.so' >>$@.tmp
	@echo '   OUTPUT_VARIABLE GFORTRAN_LIBRARY' >>$@.tmp
	@echo 'diff --git a/cmake/modules/FindUMFPACK.cmake b/cmake/modules/FindUMFPACK.cmake' >>$@.tmp
	@echo 'index 33a3800..bafa910 100644' >>$@.tmp
	@echo '--- a/cmake/modules/FindUMFPACK.cmake' >>$@.tmp
	@echo '+++ b/cmake/modules/FindUMFPACK.cmake' >>$@.tmp
	@echo '@@ -58,7 +58,9 @@ if (SUITESPARSECONFIG_LIBRARY)' >>$@.tmp
	@echo '   set(UMFPACK_LIBRARIES $${UMFPACK_LIBRARIES} $${SUITESPARSECONFIG_LIBRARY})' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '-find_program(GFORTRAN_EXECUTABLE gfortran)' >>$@.tmp
	@echo '+if (NOT GFORTRAN_EXECUTABLE)' >>$@.tmp
	@echo '+  find_program(GFORTRAN_EXECUTABLE gfortran)' >>$@.tmp
	@echo '+endif()' >>$@.tmp
	@echo ' if (GFORTRAN_EXECUTABLE)' >>$@.tmp
	@echo '   execute_process(COMMAND $${GFORTRAN_EXECUTABLE} -print-file-name=libgfortran.so' >>$@.tmp
	@echo '   OUTPUT_VARIABLE GFORTRAN_LIBRARY' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019.2.0.dev0)-srcdir)/0002-Require-C-17.patch $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack $($(fenics-dolfin-2019.2.0.dev0)-srcdir)/0004-Look-for-metis-in-METIS_DIR.patch $($(fenics-dolfin-2019.2.0.dev0)-srcdir)/0005-Allow-overriding-Fortran-compiler.patch
	cd $($(fenics-dolfin-2019.2.0.dev0)-srcdir) && \
		patch -f -p1 <0002-Require-C-17.patch && \
		patch -f -p1 <0004-Look-for-metis-in-METIS_DIR.patch && \
		patch -f -p1 <0005-Allow-overriding-Fortran-compiler.patch
	@touch $@

$($(fenics-dolfin-2019.2.0.dev0)-builddir)/.markerfile: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019.2.0.dev0)-builddir)/.markerfile $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgpatch
	cd $($(fenics-dolfin-2019.2.0.dev0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfin-2019.2.0.dev0)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-dolfin-2019.2.0.dev0)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
			-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
			-DCMAKE_POLICY_DEFAULT_CMP0060=NEW \
			-DBUILD_SHARED_LIBS=TRUE \
			-DCMAKE_RULE_MESSAGES:BOOL=OFF \
			-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
			-DDOLFIN_SKIP_BUILD_TESTS=YES \
			-DBLAS_LIBRARIES="-L$${BLASDIR} -l$${BLASLIB}" \
			-DLAPACK_LIBRARIES="-L$${LAPACKDIR} -l$${LAPACKLIB}" \
			-DGFORTRAN_EXECUTABLE="$${FC}" \
			-DEIGEN3_INCLUDE_DIR="$${EIGEN_INCDIR}" \
			-DDOLFIN_ENABLE_PARMETIS=YES \
			-DPARMETIS_DIR="$${PARMETIS_ROOT}" \
			-DMETIS_DIR="$${METIS_ROOT}" \
			-DDOLFIN_ENABLE_PETSC=YES \
			-DPETSC_DIR="$${PETSC_DIR}" \
			-DDOLFIN_ENABLE_SLEPC=NO \
			-DDOLFIN_ENABLE_SCOTCH=YES \
			-DSCOTCH_DIR="$${SCOTCH_ROOT}" \
			-DSCOTCH_DEBUG=ON \
			-DDOLFIN_ENABLE_CHOLMOD=YES \
			-DCHOLMOD_DIR="$${SUITESPARSE_ROOT}" \
			-DDOLFIN_ENABLE_UMFPACK=YES \
			-DAMD_DIR="$${SUITESPARSE_ROOT}" \
			-DUMFPACK_DIR="$${SUITESPARSE_ROOT}" \
			-DDOLFIN_ENABLE_TRILINOS=NO \
			-DDOLFIN_ENABLE_SUNDIALS=NO \
			&& \
		$(MAKE)
	@touch $@

$($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019.2.0.dev0)-builddir)/.markerfile $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgbuild
	@touch $@

$($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-dolfin-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-dolfin-2019.2.0.dev0)-builddir)/.markerfile $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgcheck
	cd $($(fenics-dolfin-2019.2.0.dev0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-dolfin-2019.2.0.dev0)-builddeps) && \
		$(MAKE) install
	sed -i '/INTERFACE_LINK_LIBRARIES/d' $($(fenics-dolfin-2019.2.0.dev0)-prefix)/share/dolfin/cmake/DOLFINTargets.cmake
	@touch $@

$($(fenics-dolfin-2019.2.0.dev0)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-dolfin-2019.2.0.dev0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-dolfin-2019.2.0.dev0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-dolfin-2019.2.0.dev0)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-dolfin-2019.2.0.dev0)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-dolfin-2019.2.0.dev0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_DOLFIN_2019_ROOT $($(fenics-dolfin-2019.2.0.dev0)-prefix)" >>$@
	echo "setenv FENICS_DOLFIN_2019_INCDIR $($(fenics-dolfin-2019.2.0.dev0)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFIN_2019_INCLUDEDIR $($(fenics-dolfin-2019.2.0.dev0)-prefix)/include" >>$@
	echo "setenv FENICS_DOLFIN_2019_LIBDIR $($(fenics-dolfin-2019.2.0.dev0)-prefix)/lib" >>$@
	echo "setenv FENICS_DOLFIN_2019_LIBRARYDIR $($(fenics-dolfin-2019.2.0.dev0)-prefix)/lib" >>$@
	echo "setenv DOLFIN_DIR $($(fenics-dolfin-2019.2.0.dev0)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-dolfin-2019.2.0.dev0)-prefix)/share/dolfin/cmake" >>$@
	echo "set MSG \"$(fenics-dolfin-2019.2.0.dev0)\"" >>$@

$(fenics-dolfin-2019.2.0.dev0)-src: $($(fenics-dolfin-2019.2.0.dev0)-src)
$(fenics-dolfin-2019.2.0.dev0)-unpack: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgunpack
$(fenics-dolfin-2019.2.0.dev0)-patch: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgpatch
$(fenics-dolfin-2019.2.0.dev0)-build: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgbuild
$(fenics-dolfin-2019.2.0.dev0)-check: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkgcheck
$(fenics-dolfin-2019.2.0.dev0)-install: $($(fenics-dolfin-2019.2.0.dev0)-prefix)/.pkginstall
$(fenics-dolfin-2019.2.0.dev0)-modulefile: $($(fenics-dolfin-2019.2.0.dev0)-modulefile)
$(fenics-dolfin-2019.2.0.dev0)-clean:
	rm -rf $($(fenics-dolfin-2019.2.0.dev0)-modulefile)
	rm -rf $($(fenics-dolfin-2019.2.0.dev0)-prefix)
	rm -rf $($(fenics-dolfin-2019.2.0.dev0)-srcdir)
$(fenics-dolfin-2019.2.0.dev0): $(fenics-dolfin-2019.2.0.dev0)-src $(fenics-dolfin-2019.2.0.dev0)-unpack $(fenics-dolfin-2019.2.0.dev0)-patch $(fenics-dolfin-2019.2.0.dev0)-build $(fenics-dolfin-2019.2.0.dev0)-check $(fenics-dolfin-2019.2.0.dev0)-install $(fenics-dolfin-2019.2.0.dev0)-modulefile
