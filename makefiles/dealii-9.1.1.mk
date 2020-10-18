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
# dealii-9.1.1

dealii-version = 9.1.1
dealii = dealii-$(dealii-version)
$(dealii)-description = Open source finite element library
$(dealii)-url = https://www.dealii.org/
$(dealii)-srcurl = https://dealii.43-1.org/downloads/dealii-$(dealii-version).tar.gz
$(dealii)-builddeps = $(cmake) $(boost) $(blas) $(mpi) $(gsl) $(hdf5-parallel) $(metis) $(petsc) $(suitesparse) $(gmsh) $(scalapack)
$(dealii)-prereqs = $(boost) $(blas) $(mpi) $(gsl) $(hdf5-parallel) $(metis) $(petsc) $(suitesparse) $(gmsh) $(scalapack)
$(dealii)-src = $(pkgsrcdir)/$(notdir $($(dealii)-srcurl))
$(dealii)-srcdir = $(pkgsrcdir)/$(dealii)
$(dealii)-builddir = $($(dealii)-srcdir)/build
$(dealii)-modulefile = $(modulefilesdir)/$(dealii)
$(dealii)-prefix = $(pkgdir)/$(dealii)

$($(dealii)-src): $(dir $($(dealii)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(dealii)-srcurl)

$($(dealii)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(dealii)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(dealii)-prefix)/.pkgunpack: $($(dealii)-src) $($(dealii)-srcdir)/.markerfile $($(dealii)-prefix)/.markerfile
	tar -C $($(dealii)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(dealii)-srcdir)/0001-remove-boost-include-to-fix-compilation.patch: $($(dealii)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo '' >>$@.tmp
	@echo 'From 35c7dbdacb3042833cd2fd0aea616d02110e1a97 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: Timo Heister <timo.heister@gmail.com>' >>$@.tmp
	@echo 'Date: Fri, 8 May 2020 10:30:27 -0400' >>$@.tmp
	@echo 'Subject: [PATCH] remove boost include to fix compilation' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'fixes #10088' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' include/deal.II/grid/grid_tools.h | 1 -' >>$@.tmp
	@echo ' 1 file changed, 1 deletion(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/include/deal.II/grid/grid_tools.h b/include/deal.II/grid/grid_tools.h' >>$@.tmp
	@echo 'index 4bbc47a11c2..45da52d05b1 100644' >>$@.tmp
	@echo '--- a/include/deal.II/grid/grid_tools.h' >>$@.tmp
	@echo '+++ b/include/deal.II/grid/grid_tools.h' >>$@.tmp
	@echo '@@ -44,7 +44,6 @@' >>$@.tmp
	@echo '' >>$@.tmp
	@echo ' #  include <boost/archive/binary_iarchive.hpp>' >>$@.tmp
	@echo ' #  include <boost/archive/binary_oarchive.hpp>' >>$@.tmp
	@echo '-#  include <boost/geometry/index/detail/serialization.hpp>' >>$@.tmp
	@echo ' #  include <boost/geometry/index/rtree.hpp>' >>$@.tmp
	@echo ' #  include <boost/serialization/array.hpp>' >>$@.tmp
	@echo ' #  include <boost/serialization/vector.hpp>' >>$@.tmp
	@echo ' ' >>$@.tmp
	mv $@.tmp $@

$($(dealii)-srcdir)/0002-Fix-install-directory-permissions.patch: $($(dealii)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From d5127b4c8524a49b48c22183d7963c4a48e1994a Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Fri, 27 Nov 2020 20:32:52 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Fix install directory permissions' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' bundled/CMakeLists.txt  | 3 +++' >>$@.tmp
	@echo ' examples/CMakeLists.txt | 1 +' >>$@.tmp
	@echo ' include/CMakeLists.txt  | 3 +++' >>$@.tmp
	@echo ' 3 files changed, 7 insertions(+)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/bundled/CMakeLists.txt b/bundled/CMakeLists.txt' >>$@.tmp
	@echo 'index a99cc2e..4ef79d7 100644' >>$@.tmp
	@echo '--- a/bundled/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/bundled/CMakeLists.txt' >>$@.tmp
	@echo '@@ -24,6 +24,7 @@ IF(FEATURE_BOOST_BUNDLED_CONFIGURED)' >>$@.tmp
	@echo '   INSTALL(DIRECTORY $${BOOST_FOLDER}/include/boost' >>$@.tmp
	@echo '     DESTINATION $${DEAL_II_INCLUDE_RELDIR}/deal.II/bundled' >>$@.tmp
	@echo '     COMPONENT library' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     )' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '   ADD_SUBDIRECTORY($${BOOST_FOLDER}/libs/serialization/src)' >>$@.tmp
	@echo '@@ -41,6 +42,7 @@ IF(FEATURE_THREADS_BUNDLED_CONFIGURED)' >>$@.tmp
	@echo '   INSTALL(DIRECTORY $${TBB_FOLDER}/include/tbb' >>$@.tmp
	@echo '     DESTINATION $${DEAL_II_INCLUDE_RELDIR}/deal.II/bundled' >>$@.tmp
	@echo '     COMPONENT library' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     FILES_MATCHING PATTERN "*.h"' >>$@.tmp
	@echo '     )' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '@@ -57,6 +59,7 @@ IF(FEATURE_UMFPACK_BUNDLED_CONFIGURED)' >>$@.tmp
	@echo '       $${UMFPACK_FOLDER}/AMD/Include/' >>$@.tmp
	@echo '     DESTINATION $${DEAL_II_INCLUDE_RELDIR}/deal.II/bundled' >>$@.tmp
	@echo '     COMPONENT library' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     FILES_MATCHING PATTERN "*.h"' >>$@.tmp
	@echo '     )' >>$@.tmp
	@echo ' ENDIF()' >>$@.tmp
	@echo 'diff --git a/examples/CMakeLists.txt b/examples/CMakeLists.txt' >>$@.tmp
	@echo 'index 7ea0ea5..1a6d0ae 100644' >>$@.tmp
	@echo '--- a/examples/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/examples/CMakeLists.txt' >>$@.tmp
	@echo '@@ -19,6 +19,7 @@ IF(DEAL_II_COMPONENT_EXAMPLES)' >>$@.tmp
	@echo '   INSTALL(DIRECTORY $${CMAKE_CURRENT_SOURCE_DIR}/' >>$@.tmp
	@echo '     DESTINATION $${DEAL_II_EXAMPLES_RELDIR}' >>$@.tmp
	@echo '     COMPONENT examples' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     FILES_MATCHING' >>$@.tmp
	@echo '     #' >>$@.tmp
	@echo '     # Exclude folder structures: doc, doxygen, CMakeFiles,...' >>$@.tmp
	@echo 'diff --git a/include/CMakeLists.txt b/include/CMakeLists.txt' >>$@.tmp
	@echo 'index c144778..e745f5d 100644' >>$@.tmp
	@echo '--- a/include/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/include/CMakeLists.txt' >>$@.tmp
	@echo '@@ -31,6 +31,7 @@ CONFIGURE_FILE(' >>$@.tmp
	@echo ' INSTALL(DIRECTORY deal.II' >>$@.tmp
	@echo '   DESTINATION $${DEAL_II_INCLUDE_RELDIR}' >>$@.tmp
	@echo '   COMPONENT library' >>$@.tmp
	@echo '+  DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '   FILES_MATCHING PATTERN "*.h"' >>$@.tmp
	@echo '   )' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '@@ -38,6 +39,7 @@ IF(DEAL_II_WITH_CUDA)' >>$@.tmp
	@echo '   INSTALL(DIRECTORY deal.II' >>$@.tmp
	@echo '     DESTINATION $${DEAL_II_INCLUDE_RELDIR}' >>$@.tmp
	@echo '     COMPONENT library' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     FILES_MATCHING PATTERN "*.cuh"' >>$@.tmp
	@echo '     )' >>$@.tmp
	@echo ' ENDIF()' >>$@.tmp
	@echo '@@ -48,6 +50,7 @@ ENDIF()' >>$@.tmp
	@echo ' INSTALL(DIRECTORY $${CMAKE_CURRENT_BINARY_DIR}/deal.II' >>$@.tmp
	@echo '   DESTINATION $${DEAL_II_INCLUDE_RELDIR}' >>$@.tmp
	@echo '   COMPONENT library' >>$@.tmp
	@echo '+  DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '   FILES_MATCHING PATTERN "*.h"' >>$@.tmp
	@echo '   )' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(dealii)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep)) $($(dealii)-prefix)/.pkgunpack $($(dealii)-srcdir)/0001-remove-boost-include-to-fix-compilation.patch $($(dealii)-srcdir)/0002-Fix-install-directory-permissions.patch
	cd $($(dealii)-srcdir) && \
		patch -t -p1 <0001-remove-boost-include-to-fix-compilation.patch && \
		patch -t -p1 <0002-Fix-install-directory-permissions.patch
	@touch $@

ifneq ($($(dealii)-builddir),$($(dealii)-srcdir))
$($(dealii)-builddir)/.markerfile: $($(dealii)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(dealii)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep)) $($(dealii)-builddir)/.markerfile $($(dealii)-prefix)/.pkgpatch
	cd $($(dealii)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(dealii)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(dealii)-prefix) \
			-DDEAL_II_WITH_THREADS=OFF \
			-DDEAL_II_WITH_MPI=ON \
			-DGSL_LIBRARY="$${GSL_LIBDIR}/libgsl.so" \
			-DGSL_INCLUDE_DIR="$${GSL_INCDIR}" \
			-DHDF5_LIBRARY="$${HDF5_LIBDIR}/libhdf5.so" \
			-DHDF5_HL_LIBRARY="$${HDF5_LIBDIR}/libhdf5_hl.so" \
			-DHDF5_INCLUDE_DIR="$${HDF5_INCDIR}" \
			-DMETIS_LIBRARY="$${METIS_LIBDIR}/libmetis.so" \
			-DMETIS_INCLUDE_DIR="$${METIS_INCDIR}" \
			-DUMFPACK_LIBRARY="$${SUITESPARSE_LIBDIR}/libumfpack.so" \
			-DUMFPACK_INCLUDE_DIR="$${SUITESPARSE_INCDIR}"  \
			-DAMD_LIBRARY="$${SUITESPARSE_LIBDIR}/libamd.so" \
			-DAMD_INCLUDE_DIR="$${SUITESPARSE_INCDIR}" \
			-DCHOLMOD_LIBRARY="$${SUITESPARSE_LIBDIR}/libcholmod.so" \
			-DCHOLMOD_INCLUDE_DIR="$${SUITESPARSE_INCDIR}" \
			-DCOLAMD_LIBRARY="$${SUITESPARSE_LIBDIR}/libcolamd.so" \
			-DCOLAMD_INCLUDE_DIR="$${SUITESPARSE_INCDIR}" \
			-DCCOLAMD_LIBRARY="$${SUITESPARSE_LIBDIR}/libccolamd.so" \
			-DCCOLAMD_INCLUDE_DIR="$${SUITESPARSE_INCDIR}" \
			-DCAMD_LIBRARY="$${SUITESPARSE_LIBDIR}/libcamd.so" \
			-DCAMD_INCLUDE_DIR="$${SUITESPARSE_INCDIR}" \
			-DSuiteSparse_config_LIBRARY="$${SUITESPARSE_LIBDIR}/libsuitesparseconfig.so" \
			-DSuiteSparse_config_INCLUDE_DIR="$${SUITESPARSE_INCDIR}" \
			-DSCALAPACK_LIBRARY="$${SCALAPACK_LIBDIR}/libscalapack.so" && \
		$(MAKE)
	@touch $@

$($(dealii)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep)) $($(dealii)-builddir)/.markerfile $($(dealii)-prefix)/.pkgbuild
	@touch $@

$($(dealii)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep)) $($(dealii)-builddir)/.markerfile $($(dealii)-prefix)/.pkgcheck
	cd $($(dealii)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(dealii)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(dealii)-modulefile): $(modulefilesdir)/.markerfile $($(dealii)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(dealii)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(dealii)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(dealii)-description)\"" >>$@
	echo "module-whatis \"$($(dealii)-url)\"" >>$@
	printf "$(foreach prereq,$($(dealii)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv DEALII_ROOT $($(dealii)-prefix)" >>$@
	echo "setenv DEALII_INCDIR $($(dealii)-prefix)/include" >>$@
	echo "setenv DEALII_INCLUDEDIR $($(dealii)-prefix)/include" >>$@
	echo "setenv DEALII_LIBDIR $($(dealii)-prefix)/lib" >>$@
	echo "setenv DEALII_LIBRARYDIR $($(dealii)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(dealii)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(dealii)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(dealii)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(dealii)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(dealii)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(dealii)\"" >>$@

$(dealii)-src: $($(dealii)-src)
$(dealii)-unpack: $($(dealii)-prefix)/.pkgunpack
$(dealii)-patch: $($(dealii)-prefix)/.pkgpatch
$(dealii)-build: $($(dealii)-prefix)/.pkgbuild
$(dealii)-check: $($(dealii)-prefix)/.pkgcheck
$(dealii)-install: $($(dealii)-prefix)/.pkginstall
$(dealii)-modulefile: $($(dealii)-modulefile)
$(dealii)-clean:
	rm -rf $($(dealii)-modulefile)
	rm -rf $($(dealii)-prefix)
	rm -rf $($(dealii)-srcdir)
	rm -rf $($(dealii)-src)
$(dealii): $(dealii)-src $(dealii)-unpack $(dealii)-patch $(dealii)-build $(dealii)-check $(dealii)-install $(dealii)-modulefile
