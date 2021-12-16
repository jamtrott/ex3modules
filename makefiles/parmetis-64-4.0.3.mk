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
# parmetis-64-4.0.3

parmetis-64-version = 4.0.3
parmetis-64 = parmetis-64-$(parmetis-64-version)
$(parmetis-64)-description = Parallel Graph Partitioning and Fill-reducing Matrix Ordering
$(parmetis-64)-url = http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview
$(parmetis-64)-srcurl = $($(parmetis-src)-srcurl)
$(parmetis-64)-builddeps = $(cmake) $(mpi) $(metis-64) $(gklib)
$(parmetis-64)-prereqs = $(mpi) $(metis-64)
$(parmetis-64)-src = $($(parmetis-src)-src)
$(parmetis-64)-srcdir = $(pkgsrcdir)/$(parmetis-64)
$(parmetis-64)-builddir = $($(parmetis-64)-srcdir)/build
$(parmetis-64)-modulefile = $(modulefilesdir)/$(parmetis-64)
$(parmetis-64)-prefix = $(pkgdir)/$(parmetis-64)

$($(parmetis-64)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis-64)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis-64)-prefix)/.pkgunpack: $$($(parmetis-64)-src) $($(parmetis-64)-srcdir)/.markerfile $($(parmetis-64)-prefix)/.markerfile $$(foreach dep,$$($(parmetis-64)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(parmetis-64)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(parmetis-64)-srcdir)/0001-enable_external_metis.patch: $($(parmetis-64)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'diff --git a/CMakeLists.txt b/CMakeLists.txt' >>$@.tmp
	@echo 'index ca945dd..aff8b5f 100644' >>$@.tmp
	@echo '--- a/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/CMakeLists.txt' >>$@.tmp
	@echo '@@ -23,7 +23,7 @@ else()' >>$@.tmp
	@echo '   set(ParMETIS_LIBRARY_TYPE STATIC)' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-include($${GKLIB_PATH}/GKlibSystem.cmake)' >>$@.tmp
	@echo '+include_directories($${GKLIB_PATH})' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' # List of paths that the compiler will search for header files.' >>$@.tmp
	@echo ' # i.e., the -I equivalent' >>$@.tmp
	@echo '@@ -33,7 +33,7 @@ include_directories($${GKLIB_PATH})' >>$@.tmp
	@echo ' include_directories($${METIS_PATH}/include)' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' # List of directories that cmake will look for CMakeLists.txt' >>$@.tmp
	@echo '-add_subdirectory($${METIS_PATH}/libmetis $${CMAKE_BINARY_DIR}/libmetis)' >>$@.tmp
	@echo '+find_library(METIS_LIBRARY metis PATHS $${METIS_PATH}/lib)' >>$@.tmp
	@echo ' add_subdirectory(include)' >>$@.tmp
	@echo ' add_subdirectory(libparmetis)' >>$@.tmp
	@echo ' add_subdirectory(programs)' >>$@.tmp
	@echo 'diff --git a/libparmetis/CMakeLists.txt b/libparmetis/CMakeLists.txt' >>$@.tmp
	@echo 'index 9cfc8a7..e0c4de7 100644' >>$@.tmp
	@echo '--- a/libparmetis/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/libparmetis/CMakeLists.txt' >>$@.tmp
	@echo '@@ -5,7 +5,10 @@ file(GLOB parmetis_sources *.c)' >>$@.tmp
	@echo ' # Create libparmetis' >>$@.tmp
	@echo ' add_library(parmetis $${ParMETIS_LIBRARY_TYPE} $${parmetis_sources})' >>$@.tmp
	@echo ' # Link with metis and MPI libraries.' >>$@.tmp
	@echo '-target_link_libraries(parmetis metis $${MPI_LIBRARIES})' >>$@.tmp
	@echo '+target_link_libraries(parmetis $${METIS_LIBRARY} $${MPI_LIBRARIES})' >>$@.tmp
	@echo '+if(UNIX)' >>$@.tmp
	@echo '+  target_link_libraries(parmetis m)' >>$@.tmp
	@echo '+endif()' >>$@.tmp
	@echo ' set_target_properties(parmetis PROPERTIES LINK_FLAGS "$${MPI_LINK_FLAGS}")' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' install(TARGETS parmetis' >>$@.tmp
	@echo 'diff --git a/libparmetis/parmetislib.h b/libparmetis/parmetislib.h' >>$@.tmp
	@echo 'index c1daeeb..07511f6 100644' >>$@.tmp
	@echo '--- a/libparmetis/parmetislib.h' >>$@.tmp
	@echo '+++ b/libparmetis/parmetislib.h' >>$@.tmp
	@echo '@@ -20,13 +20,12 @@' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' #include <parmetis.h>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-#include "../metis/libmetis/gklib_defs.h"' >>$@.tmp
	@echo '+#include <gklib_defs.h>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-#include <mpi.h> ' >>$@.tmp
	@echo '+#include <mpi.h>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' #include <rename.h>' >>$@.tmp
	@echo ' #include <defs.h>' >>$@.tmp
	@echo ' #include <struct.h>' >>$@.tmp
	@echo ' #include <macros.h>' >>$@.tmp
	@echo ' #include <proto.h>' >>$@.tmp
	@echo '-' >>$@.tmp
	@echo 'diff --git a/programs/parmetisbin.h b/programs/parmetisbin.h' >>$@.tmp
	@echo 'index e26cd2d..d156480 100644' >>$@.tmp
	@echo '--- a/programs/parmetisbin.h' >>$@.tmp
	@echo '+++ b/programs/parmetisbin.h' >>$@.tmp
	@echo '@@ -19,7 +19,7 @@' >>$@.tmp
	@echo ' #include <GKlib.h>' >>$@.tmp
	@echo ' #include <parmetis.h>' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-#include "../metis/libmetis/gklib_defs.h"' >>$@.tmp
	@echo '+#include <gklib_defs.h>' >>$@.tmp
	@echo ' #include "../libparmetis/rename.h"' >>$@.tmp
	@echo ' #include "../libparmetis/defs.h"' >>$@.tmp
	@echo ' #include "../libparmetis/struct.h"' >>$@.tmp
	@mv $@.tmp $@

$($(parmetis-64)-srcdir)/0002-petsc-bugfix-1.patch: $($(parmetis-64)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 1c1a9fd0f408dc4d42c57f5c3ee6ace411eb222b Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: Jed Brown <jed@59A2.org>' >>$@.tmp
	@echo 'Date: Fri, 12 Oct 2012 15:45:10 -0500' >>$@.tmp
	@echo 'Subject: [PATCH] ParMetis bug fixes reported by John Fettig [petsc-maint' >>$@.tmp
	@echo ' #133631]' >>$@.tmp
	@echo '' >>$@.tmp
	@echo "'''" >>$@.tmp
	@echo "I have also reported to to Karypis but have received zero" >>$@.tmp
	@echo "response and he hasn't released any updates to the original release" >>$@.tmp
	@echo "either.  At least he approved my forum posting so that other people" >>$@.tmp
	@echo "can see the bug and the fix." >>$@.tmp
	@echo "http://glaros.dtc.umn.edu/gkhome/node/837" >>$@.tmp
	@echo "'''" >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Hg-commit: 1c2b9fe39201d404b493885093b5992028b9b8d4' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' libparmetis/xyzpart.c | 12 ++++++------' >>$@.tmp
	@echo ' 1 file changed, 6 insertions(+), 6 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/libparmetis/xyzpart.c b/libparmetis/xyzpart.c' >>$@.tmp
	@echo 'index 3a2c289..63abfcb 100644' >>$@.tmp
	@echo '--- a/libparmetis/xyzpart.c' >>$@.tmp
	@echo '+++ b/libparmetis/xyzpart.c' >>$@.tmp
	@echo '@@ -104,7 +104,7 @@ void IRBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '     for (i=0; i<nbins; i++)' >>$@.tmp
	@echo '       emarkers[i] = gmin + (gmax-gmin)*i/nbins;' >>$@.tmp
	@echo '-    emarkers[nbins] = gmax*(1.0+2.0*REAL_EPSILON);' >>$@.tmp
	@echo '+    emarkers[nbins] = gmax*(1.0+copysign(1.0,gmax)*2.0*REAL_EPSILON);' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '     /* get into a iterative backet boundary refinement */' >>$@.tmp
	@echo '     for (l=0; l<5; l++) {' >>$@.tmp
	@echo '@@ -152,7 +152,7 @@ void IRBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo '         }' >>$@.tmp
	@echo '       }' >>$@.tmp
	@echo '       nemarkers[0]     = gmin;' >>$@.tmp
	@echo '-      nemarkers[nbins] = gmax*(1.0+2.0*REAL_EPSILON);' >>$@.tmp
	@echo '+      nemarkers[nbins] = gmax*(1.0+copysign(1.0,gmax)*2.0*REAL_EPSILON);' >>$@.tmp
	@echo '       rcopy(nbins+1, nemarkers, emarkers);' >>$@.tmp
	@echo '     }' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '@@ -218,7 +218,7 @@ void RBBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '     emarkers[0] = gmin;' >>$@.tmp
	@echo '     emarkers[1] = gsum/gnvtxs;' >>$@.tmp
	@echo '-    emarkers[2] = gmax*(1.0+2.0*REAL_EPSILON);' >>$@.tmp
	@echo '+    emarkers[2] = gmax*(1.0+(gmax < 0 ? -1. : 1.)*2.0*REAL_EPSILON);' >>$@.tmp
	@echo '     cnbins = 2;' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '     /* get into a iterative backet boundary refinement */' >>$@.tmp
	@echo '@@ -227,7 +227,7 @@ void RBBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo '       iset(cnbins, 0, lcounts);' >>$@.tmp
	@echo '       rset(cnbins, 0, lsums);' >>$@.tmp
	@echo '       for (j=0, i=0; i<nvtxs;) {' >>$@.tmp
	@echo '-        if (cand[i].key < emarkers[j+1]) {' >>$@.tmp
	@echo '+        if (cand[i].key <= emarkers[j+1]) {' >>$@.tmp
	@echo '           lcounts[j]++;' >>$@.tmp
	@echo '           lsums[j] += cand[i].key;' >>$@.tmp
	@echo '           i++;' >>$@.tmp
	@echo '@@ -272,12 +272,12 @@ void RBBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo '       ' >>$@.tmp
	@echo '       rsorti(cnbins, nemarkers);' >>$@.tmp
	@echo '       rcopy(cnbins, nemarkers, emarkers);' >>$@.tmp
	@echo '-      emarkers[cnbins] = gmax*(1.0+2.0*REAL_EPSILON);' >>$@.tmp
	@echo '+      emarkers[cnbins] = gmax*(1.0+(gmax < 0 ? -1. : 1.)*2.0*REAL_EPSILON);' >>$@.tmp
	@echo '     }' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '     /* assign the coordinate to the appropriate bin */' >>$@.tmp
	@echo '     for (j=0, i=0; i<nvtxs;) {' >>$@.tmp
	@echo '-      if (cand[i].key < emarkers[j+1]) {' >>$@.tmp
	@echo '+      if (cand[i].key <= emarkers[j+1]) {' >>$@.tmp
	@echo '         bxyz[cand[i].val*ndims+k] = j;' >>$@.tmp
	@echo '         i++;' >>$@.tmp
	@echo '       }' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.1.1.1.g1fb337f' >>$@.tmp
	@mv $@.tmp $@

$($(parmetis-64)-srcdir)/0003-petsc-bugfix-2.patch: $($(parmetis-64)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo 'From 82409d68aa1d6cbc70740d0f35024aae17f7d5cb Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: Sean Farley <sean@mcs.anl.gov>' >>$@.tmp
	@echo 'Date: Tue, 20 Mar 2012 11:59:44 -0500' >>$@.tmp
	@echo "Subject: [PATCH] parmetis: fix bug reported by jfettig; '<' to '<=' in xyzpart" >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Hg-commit: 2dd2eae596acaabbc80e0ef875182616f868dbc2' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' libparmetis/xyzpart.c | 4 ++--' >>$@.tmp
	@echo ' 1 file changed, 2 insertions(+), 2 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/libparmetis/xyzpart.c b/libparmetis/xyzpart.c' >>$@.tmp
	@echo 'index 307aed9..3a2c289 100644' >>$@.tmp
	@echo '--- a/libparmetis/xyzpart.c' >>$@.tmp
	@echo '+++ b/libparmetis/xyzpart.c' >>$@.tmp
	@echo '@@ -111,7 +111,7 @@ void IRBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo '       /* determine bucket counts */' >>$@.tmp
	@echo '       iset(nbins, 0, lcounts);' >>$@.tmp
	@echo '       for (j=0, i=0; i<nvtxs;) {' >>$@.tmp
	@echo '-        if (cand[i].key < emarkers[j+1]) {' >>$@.tmp
	@echo '+        if (cand[i].key <= emarkers[j+1]) {' >>$@.tmp
	@echo '           lcounts[j]++;' >>$@.tmp
	@echo '           i++;' >>$@.tmp
	@echo '         }' >>$@.tmp
	@echo '@@ -158,7 +158,7 @@ void IRBinCoordinates(ctrl_t *ctrl, graph_t *graph, idx_t ndims, real_t *xyz,' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '     /* assign the coordinate to the appropriate bin */' >>$@.tmp
	@echo '     for (j=0, i=0; i<nvtxs;) {' >>$@.tmp
	@echo '-      if (cand[i].key < emarkers[j+1]) {' >>$@.tmp
	@echo '+      if (cand[i].key <= emarkers[j+1]) {' >>$@.tmp
	@echo '         bxyz[cand[i].val*ndims+k] = j;' >>$@.tmp
	@echo '         i++;' >>$@.tmp
	@echo '       }' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.1.1.1.g1fb337f' >>$@.tmp
	@mv $@.tmp $@

$($(parmetis-64)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-64)-prefix)/.pkgunpack $($(parmetis-64)-srcdir)/0001-enable_external_metis.patch $($(parmetis-64)-srcdir)/0002-petsc-bugfix-1.patch $($(parmetis-64)-srcdir)/0003-petsc-bugfix-2.patch
	cd $($(parmetis-64)-srcdir) && \
		patch -f -p1 <0001-enable_external_metis.patch && \
		patch -f -p1 <0002-petsc-bugfix-1.patch && \
		patch -f -p1 <0003-petsc-bugfix-2.patch
	sed -i 's,IDXTYPEWIDTH 32,IDXTYPEWIDTH 64,' $($(parmetis-64)-srcdir)/metis/include/metis.h
	@touch $@

ifneq ($($(parmetis-64)-builddir),$($(parmetis-64)-srcdir))
$($(parmetis-64)-builddir)/.markerfile: $($(parmetis-64)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(parmetis-64)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-64)-builddir)/.markerfile $($(parmetis-64)-prefix)/.pkgpatch
	cd $($(parmetis-64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis-64)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(parmetis-64)-prefix) \
			-DCMAKE_C_COMPILER=mpicc \
			-DCMAKE_CXX_COMPILER=mpicxx \
			-DSHARED=1 \
			-DMETIS_PATH=$${METIS_ROOT} \
			-DGKLIB_PATH=$${GKLIB_ROOT} && \
		$(MAKE)
	@touch $@

$($(parmetis-64)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-64)-builddir)/.markerfile $($(parmetis-64)-prefix)/.pkgbuild
	@touch $@

$($(parmetis-64)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-64)-builddir)/.markerfile $($(parmetis-64)-prefix)/.pkgcheck
	cd $($(parmetis-64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis-64)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(parmetis-64)-modulefile): $(modulefilesdir)/.markerfile $($(parmetis-64)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(parmetis-64)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(parmetis-64)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(parmetis-64)-description)\"" >>$@
	echo "module-whatis \"$($(parmetis-64)-url)\"" >>$@
	printf "$(foreach prereq,$($(parmetis-64)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PARMETIS_ROOT $($(parmetis-64)-prefix)" >>$@
	echo "setenv PARMETIS_INCDIR $($(parmetis-64)-prefix)/include" >>$@
	echo "setenv PARMETIS_INCLUDEDIR $($(parmetis-64)-prefix)/include" >>$@
	echo "setenv PARMETIS_LIBDIR $($(parmetis-64)-prefix)/lib" >>$@
	echo "setenv PARMETIS_LIBRARYDIR $($(parmetis-64)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(parmetis-64)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(parmetis-64)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(parmetis-64)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(parmetis-64)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(parmetis-64)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(parmetis-64)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(parmetis-64)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(parmetis-64)-prefix)/share/info" >>$@
	echo "set MSG \"$(parmetis-64)\"" >>$@

$(parmetis-64)-src: $($(parmetis-64)-src)
$(parmetis-64)-unpack: $($(parmetis-64)-prefix)/.pkgunpack
$(parmetis-64)-patch: $($(parmetis-64)-prefix)/.pkgpatch
$(parmetis-64)-build: $($(parmetis-64)-prefix)/.pkgbuild
$(parmetis-64)-check: $($(parmetis-64)-prefix)/.pkgcheck
$(parmetis-64)-install: $($(parmetis-64)-prefix)/.pkginstall
$(parmetis-64)-modulefile: $($(parmetis-64)-modulefile)
$(parmetis-64)-clean:
	rm -rf $($(parmetis-64)-modulefile)
	rm -rf $($(parmetis-64)-prefix)
	rm -rf $($(parmetis-64)-srcdir)
	rm -rf $($(parmetis-64)-src)
$(parmetis-64): $(parmetis-64)-src $(parmetis-64)-unpack $(parmetis-64)-patch $(parmetis-64)-build $(parmetis-64)-check $(parmetis-64)-install $(parmetis-64)-modulefile
