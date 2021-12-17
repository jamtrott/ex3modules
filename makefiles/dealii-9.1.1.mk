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
	$(INSTALL) -d $(dir $@) && touch $@

$($(dealii)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(dealii)-prefix)/.pkgunpack: $($(dealii)-src) $($(dealii)-srcdir)/.markerfile $($(dealii)-prefix)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep))
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

$($(dealii)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep)) $($(dealii)-prefix)/.pkgunpack $($(dealii)-srcdir)/0001-remove-boost-include-to-fix-compilation.patch
	cd $($(dealii)-srcdir) && \
		patch -f -p1 <0001-remove-boost-include-to-fix-compilation.patch
	@touch $@

ifneq ($($(dealii)-builddir),$($(dealii)-srcdir))
$($(dealii)-builddir)/.markerfile: $($(dealii)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(dealii)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(dealii)-builddeps),$(modulefilesdir)/$$(dep)) $($(dealii)-builddir)/.markerfile $($(dealii)-prefix)/.pkgpatch
	cd $($(dealii)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(dealii)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(dealii)-prefix) \
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
