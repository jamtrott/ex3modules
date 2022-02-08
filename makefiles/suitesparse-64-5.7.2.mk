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
# suitesparse-64-5.7.2

suitesparse-64-version = 5.7.2
suitesparse-64 = suitesparse-64-$(suitesparse-64-version)
$(suitesparse-64)-description = A suite of sparse matrix software
$(suitesparse-64)-url = http://faculty.cse.tamu.edu/davis/suitesparse.html
$(suitesparse-64)-srcurl =
$(suitesparse-64)-src = $($(suitesparse-src)-src)
$(suitesparse-64)-srcdir = $(pkgsrcdir)/$(suitesparse-64)
$(suitesparse-64)-builddeps = $(cmake) $(blas) $(metis-64)
$(suitesparse-64)-prereqs = $(blas) $(metis-64)
$(suitesparse-64)-modulefile = $(modulefilesdir)/$(suitesparse-64)
$(suitesparse-64)-prefix = $(pkgdir)/$(suitesparse-64)

$($(suitesparse-64)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(suitesparse-64)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(suitesparse-64)-prefix)/.pkgunpack: $$($(suitesparse-64)-src) $($(suitesparse-64)-srcdir)/.markerfile $($(suitesparse-64)-prefix)/.markerfile $$(foreach dep,$$($(suitesparse-64)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(suitesparse-64)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(suitesparse-64)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-64)-prefix)/.pkgunpack
	sed -i 's,cd build ; cmake,cd build ; $(CMAKE),' $($(suitesparse-64)-srcdir)/GraphBLAS/Makefile
	sed -i 's,cd build ; cmake,cd build ; $(CMAKE),' $($(suitesparse-64)-srcdir)/Mongoose/Makefile
	sed -i 's,CUDA = auto,CUDA = no,' $($(suitesparse-64)-srcdir)/SuiteSparse_config/SuiteSparse_config.mk
	@touch $@

$($(suitesparse-64)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-64)-prefix)/.pkgpatch
	cd $($(suitesparse-64)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(suitesparse-64)-builddeps) && \
		$(MAKE) \
			BLAS="-L$${BLASDIR} -l$${BLASLIB}" \
			LAPACK="" \
			MY_METIS_LIB="$${METIS_LIBDIR}/libmetis.so" \
			MY_METIS_INC="$${METIS_INCDIR}" \
			CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$($(suitesparse-64)-prefix) -DCMAKE_INSTALL_LIBDIR=lib"
	@touch $@

$($(suitesparse-64)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-64)-prefix)/.pkgbuild
	@touch $@

$($(suitesparse-64)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse-64)-prefix)/.pkgcheck
	cd $($(suitesparse-64)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(suitesparse-64)-builddeps) && \
		$(MAKE) install \
			BLAS="-L$${BLASDIR} -l$${BLASLIB}" \
			LAPACK="" \
			MY_METIS_LIB="$${METIS_LIBDIR}/libmetis.so" \
			MY_METIS_INC="$${METIS_INCDIR}" \
			INSTALL=$($(suitesparse-64)-prefix) \
			CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$($(suitesparse-64)-prefix) -DCMAKE_INSTALL_LIBDIR=lib"
	@touch $@

$($(suitesparse-64)-modulefile): $(modulefilesdir)/.markerfile $($(suitesparse-64)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(suitesparse-64)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(suitesparse-64)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(suitesparse-64)-description)\"" >>$@
	echo "module-whatis \"$($(suitesparse-64)-url)\"" >>$@
	printf "$(foreach prereq,$($(suitesparse-64)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUITESPARSE_ROOT $($(suitesparse-64)-prefix)" >>$@
	echo "setenv SUITESPARSE_INCDIR $($(suitesparse-64)-prefix)/include" >>$@
	echo "setenv SUITESPARSE_INCLUDEDIR $($(suitesparse-64)-prefix)/include" >>$@
	echo "setenv SUITESPARSE_LIBDIR $($(suitesparse-64)-prefix)/lib" >>$@
	echo "setenv SUITESPARSE_LIBRARYDIR $($(suitesparse-64)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(suitesparse-64)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(suitesparse-64)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(suitesparse-64)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(suitesparse-64)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(suitesparse-64)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(suitesparse-64)-prefix)/lib64" >>$@
	echo "set MSG \"$(suitesparse-64)\"" >>$@

$(suitesparse-64)-src: $$($(suitesparse-64)-src)
$(suitesparse-64)-unpack: $($(suitesparse-64)-prefix)/.pkgunpack
$(suitesparse-64)-patch: $($(suitesparse-64)-prefix)/.pkgpatch
$(suitesparse-64)-build: $($(suitesparse-64)-prefix)/.pkgbuild
$(suitesparse-64)-check: $($(suitesparse-64)-prefix)/.pkgcheck
$(suitesparse-64)-install: $($(suitesparse-64)-prefix)/.pkginstall
$(suitesparse-64)-modulefile: $($(suitesparse-64)-modulefile)
$(suitesparse-64)-clean:
	rm -rf $($(suitesparse-64)-modulefile)
	rm -rf $($(suitesparse-64)-prefix)
	rm -rf $($(suitesparse-64)-srcdir)
	rm -rf $($(suitesparse-64)-src)
$(suitesparse-64): $(suitesparse-64)-src $(suitesparse-64)-unpack $(suitesparse-64)-patch $(suitesparse-64)-build $(suitesparse-64)-check $(suitesparse-64)-install $(suitesparse-64)-modulefile
