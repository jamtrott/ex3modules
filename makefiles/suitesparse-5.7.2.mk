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
# suitesparse-5.7.2

suitesparse-version = 5.7.2
suitesparse = suitesparse-$(suitesparse-version)
$(suitesparse)-description = A suite of sparse matrix software
$(suitesparse)-url = http://faculty.cse.tamu.edu/davis/suitesparse.html
$(suitesparse)-srcurl = https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v$(suitesparse-version).tar.gz
$(suitesparse)-src = $(pkgsrcdir)/suitesparse-$(notdir $($(suitesparse)-srcurl))
$(suitesparse)-srcdir = $(pkgsrcdir)/$(suitesparse)
$(suitesparse)-builddeps = $(cmake) $(gcc) $(blas) $(metis)
$(suitesparse)-prereqs = $(libstdcxx) $(blas) $(metis)
$(suitesparse)-modulefile = $(modulefilesdir)/$(suitesparse)
$(suitesparse)-prefix = $(pkgdir)/$(suitesparse)

$($(suitesparse)-src): $(dir $($(suitesparse)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(suitesparse)-srcurl)

$($(suitesparse)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(suitesparse)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(suitesparse)-prefix)/.pkgunpack: $($(suitesparse)-src) $($(suitesparse)-srcdir)/.markerfile $($(suitesparse)-prefix)/.markerfile
	tar -C $($(suitesparse)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(suitesparse)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse)-prefix)/.pkgunpack
	sed -i 's,CUDA = auto,CUDA = no,' $($(suitesparse)-srcdir)/SuiteSparse_config/SuiteSparse_config.mk
	@touch $@

$($(suitesparse)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse)-prefix)/.pkgpatch
	cd $($(suitesparse)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(suitesparse)-builddeps) && \
		$(MAKE) \
			BLAS="-L$${BLASDIR} -l$${BLASLIB}" \
			LAPACK="" \
			MY_METIS_LIB="$${METIS_LIBDIR}/libmetis.so" \
			MY_METIS_INC="$${METIS_INCDIR}" \
			CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$($(suitesparse)-prefix) -DCMAKE_INSTALL_LIBDIR=lib"
	@touch $@

$($(suitesparse)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse)-prefix)/.pkgbuild
	@touch $@

$($(suitesparse)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(suitesparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(suitesparse)-prefix)/.pkgcheck
	cd $($(suitesparse)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(suitesparse)-builddeps) && \
		$(MAKE) install \
			BLAS="-L$${BLASDIR} -l$${BLASLIB}" \
			LAPACK="" \
			MY_METIS_LIB="$${METIS_LIBDIR}/libmetis.so" \
			MY_METIS_INC="$${METIS_INCDIR}" \
			INSTALL=$($(suitesparse)-prefix) \
			CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$($(suitesparse)-prefix) -DCMAKE_INSTALL_LIBDIR=lib"
	@touch $@

$($(suitesparse)-modulefile): $(modulefilesdir)/.markerfile $($(suitesparse)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(suitesparse)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(suitesparse)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(suitesparse)-description)\"" >>$@
	echo "module-whatis \"$($(suitesparse)-url)\"" >>$@
	printf "$(foreach prereq,$($(suitesparse)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUITESPARSE_ROOT $($(suitesparse)-prefix)" >>$@
	echo "setenv SUITESPARSE_INCDIR $($(suitesparse)-prefix)/include" >>$@
	echo "setenv SUITESPARSE_INCLUDEDIR $($(suitesparse)-prefix)/include" >>$@
	echo "setenv SUITESPARSE_LIBDIR $($(suitesparse)-prefix)/lib" >>$@
	echo "setenv SUITESPARSE_LIBRARYDIR $($(suitesparse)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(suitesparse)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(suitesparse)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(suitesparse)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(suitesparse)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(suitesparse)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(suitesparse)-prefix)/lib64" >>$@
	echo "set MSG \"$(suitesparse)\"" >>$@

$(suitesparse)-src: $($(suitesparse)-src)
$(suitesparse)-unpack: $($(suitesparse)-prefix)/.pkgunpack
$(suitesparse)-patch: $($(suitesparse)-prefix)/.pkgpatch
$(suitesparse)-build: $($(suitesparse)-prefix)/.pkgbuild
$(suitesparse)-check: $($(suitesparse)-prefix)/.pkgcheck
$(suitesparse)-install: $($(suitesparse)-prefix)/.pkginstall
$(suitesparse)-modulefile: $($(suitesparse)-modulefile)
$(suitesparse)-clean:
	rm -rf $($(suitesparse)-modulefile)
	rm -rf $($(suitesparse)-prefix)
	rm -rf $($(suitesparse)-srcdir)
	rm -rf $($(suitesparse)-src)
$(suitesparse): $(suitesparse)-src $(suitesparse)-unpack $(suitesparse)-patch $(suitesparse)-build $(suitesparse)-check $(suitesparse)-install $(suitesparse)-modulefile
