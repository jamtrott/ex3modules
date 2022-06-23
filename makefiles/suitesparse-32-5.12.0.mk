# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# suitesparse-32-5.12.0

suitesparse-32-version = 5.12.0
suitesparse-32 = suitesparse-32-$(suitesparse-32-version)
$(suitesparse-32)-description = A suite of sparse matrix software
$(suitesparse-32)-url = http://faculty.cse.tamu.edu/davis/suitesparse.html
$(suitesparse-32)-srcurl =
$(suitesparse-32)-src = $($(suitesparse-src)-src)
$(suitesparse-32)-srcdir = $(pkgsrcdir)/$(suitesparse-32)
$(suitesparse-32)-builddeps = $(cmake) $(blas) $(metis) $(gmp) $(mpfr)
$(suitesparse-32)-prereqs = $(blas) $(metis) $(gmp) $(mpfr)
$(suitesparse-32)-modulefile = $(modulefilesdir)/$(suitesparse-32)
$(suitesparse-32)-prefix = $(pkgdir)/$(suitesparse-32)

$($(suitesparse-32)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(suitesparse-32)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(suitesparse-32)-prefix)/.pkgunpack: $$($(suitesparse-32)-src) $($(suitesparse-32)-srcdir)/.markerfile $($(suitesparse-32)-prefix)/.markerfile $$(foreach dep,$$($(suitesparse-32)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(suitesparse-32)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(suitesparse-32)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-32)-prefix)/.pkgunpack
	sed -i 's,cd build ; cmake,cd build ; $(CMAKE),' $($(suitesparse-32)-srcdir)/GraphBLAS/Makefile
	sed -i 's,cd build ; cmake,cd build ; $(CMAKE),' $($(suitesparse-32)-srcdir)/Mongoose/Makefile
	sed -i '/-gencode=arch=compute_30,code=sm_30/d' $($(suitesparse-32)-srcdir)/SuiteSparse_config/SuiteSparse_config.mk
	sed -i 's,CUDA = auto,CUDA = no,' $($(suitesparse-32)-srcdir)/SuiteSparse_config/SuiteSparse_config.mk
	@touch $@

$($(suitesparse-32)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-32)-prefix)/.pkgpatch
	cd $($(suitesparse-32)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(suitesparse-32)-builddeps) && \
		$(MAKE) \
			BLAS="-L$${BLASDIR} -l$${BLASLIB}" \
			LAPACK="" \
			MY_METIS_LIB="$${METIS_LIBDIR}/libmetis.so" \
			MY_METIS_INC="$${METIS_INCDIR}" \
			CUDA=no CUDA_PATH= \
			CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$($(suitesparse-32)-prefix) -DCMAKE_INSTALL_LIBDIR=lib"
	@touch $@

$($(suitesparse-32)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-32)-prefix)/.pkgbuild
	@touch $@

$($(suitesparse-32)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-32)-prefix)/.pkgcheck
	cd $($(suitesparse-32)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(suitesparse-32)-builddeps) && \
		$(MAKE) install \
			BLAS="-L$${BLASDIR} -l$${BLASLIB}" \
			LAPACK="" \
			MY_METIS_LIB="$${METIS_LIBDIR}/libmetis.so" \
			MY_METIS_INC="$${METIS_INCDIR}" \
			INSTALL=$($(suitesparse-32)-prefix) \
			CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$($(suitesparse-32)-prefix) -DCMAKE_INSTALL_LIBDIR=lib"
	@touch $@

$($(suitesparse-32)-modulefile): $(modulefilesdir)/.markerfile $($(suitesparse-32)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(suitesparse-32)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(suitesparse-32)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(suitesparse-32)-description)\"" >>$@
	echo "module-whatis \"$($(suitesparse-32)-url)\"" >>$@
	printf "$(foreach prereq,$($(suitesparse-32)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUITESPARSE_ROOT $($(suitesparse-32)-prefix)" >>$@
	echo "setenv SUITESPARSE_INCDIR $($(suitesparse-32)-prefix)/include" >>$@
	echo "setenv SUITESPARSE_INCLUDEDIR $($(suitesparse-32)-prefix)/include" >>$@
	echo "setenv SUITESPARSE_LIBDIR $($(suitesparse-32)-prefix)/lib" >>$@
	echo "setenv SUITESPARSE_LIBRARYDIR $($(suitesparse-32)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(suitesparse-32)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(suitesparse-32)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(suitesparse-32)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(suitesparse-32)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(suitesparse-32)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(suitesparse-32)-prefix)/lib64" >>$@
	echo "set MSG \"$(suitesparse-32)\"" >>$@

$(suitesparse-32)-src: $$($(suitesparse-32)-src)
$(suitesparse-32)-unpack: $($(suitesparse-32)-prefix)/.pkgunpack
$(suitesparse-32)-patch: $($(suitesparse-32)-prefix)/.pkgpatch
$(suitesparse-32)-build: $($(suitesparse-32)-prefix)/.pkgbuild
$(suitesparse-32)-check: $($(suitesparse-32)-prefix)/.pkgcheck
$(suitesparse-32)-install: $($(suitesparse-32)-prefix)/.pkginstall
$(suitesparse-32)-modulefile: $($(suitesparse-32)-modulefile)
$(suitesparse-32)-clean:
	rm -rf $($(suitesparse-32)-modulefile)
	rm -rf $($(suitesparse-32)-prefix)
	rm -rf $($(suitesparse-32)-srcdir)
	rm -rf $($(suitesparse-32)-src)
$(suitesparse-32): $(suitesparse-32)-src $(suitesparse-32)-unpack $(suitesparse-32)-patch $(suitesparse-32)-build $(suitesparse-32)-check $(suitesparse-32)-install $(suitesparse-32)-modulefile
