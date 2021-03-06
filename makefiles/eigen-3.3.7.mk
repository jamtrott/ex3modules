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
# eigen-3.3.7

eigen-version = 3.3.7
eigen = eigen-$(eigen-version)
$(eigen)-description = C++ template library for linear algebra
$(eigen)-url = http://eigen.tuxfamily.org/
$(eigen)-srcurl = https://gitlab.com/libeigen/eigen/-/archive/$(eigen-version)/eigen-$(eigen-version).tar.gz
$(eigen)-builddeps = $(gcc) $(cmake) $(boost) $(mpfr) $(gmp) $(blas) $(suitesparse) $(superlu)
$(eigen)-prereqs = $(libstdcxx) $(boost) $(mpfr) $(gmp) $(suitesparse) $(blas) $(superlu)
$(eigen)-src = $(pkgsrcdir)/$(notdir $($(eigen)-srcurl))
$(eigen)-srcdir = $(pkgsrcdir)/$(eigen)
$(eigen)-builddir = $($(eigen)-srcdir)/build
$(eigen)-modulefile = $(modulefilesdir)/$(eigen)
$(eigen)-prefix = $(pkgdir)/$(eigen)

$($(eigen)-src): $(dir $($(eigen)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(eigen)-srcurl)

$($(eigen)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(eigen)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(eigen)-prefix)/.pkgunpack: $$($(eigen)-src) $($(eigen)-srcdir)/.markerfile $($(eigen)-prefix)/.markerfile
	tar -C $($(eigen)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(eigen)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(eigen)-builddeps),$(modulefilesdir)/$$(dep)) $($(eigen)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(eigen)-builddir),$($(eigen)-srcdir))
$($(eigen)-builddir)/.markerfile: $($(eigen)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(eigen)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(eigen)-builddeps),$(modulefilesdir)/$$(dep)) $($(eigen)-builddir)/.markerfile $($(eigen)-prefix)/.pkgpatch
	cd $($(eigen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(eigen)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(eigen)-prefix) -Wno-dev \
			-DINCLUDE_INSTALL_DIR:string="include" \
			-DMPFR_INCLUDES="$${MPFRDIR}/include" \
			-DMPFR_LIBRARIES="$${MPFRLIB}/libmpfr.so" \
			-DGMP_INCLUDES="$${GMPDIR}/include" \
			-DGMP_LIBRARIES="$${GMPLIB}/libgmp.so" \
			-DCHOLMOD_INCLUDES="$${SUITESPARSE_INCDIR}" \
			-DCHOLMOD_LIBRARIES="$${SUITESPARSE_LIBDIR}/libcholmod.so" \
			-DUMFPACK_INCLUDES="$${SUITESPARSE_INCDIR}" \
			-DUMFPACK_LIBRARIES="$${SUITESPARSE_LIBDIR}/libumfpack.so" \
			-DSUPERLU_INCLUDES="$${SUPERLU_INCDIR}" \
			-DSUPERLU_LIBRARIES="$${SUPERLU_LIBDIR}/libsuperlu.so" \
			-DCMAKE_CXX_FLAGS="-O3" && \
		$(MAKE)
	@touch $@

$($(eigen)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(eigen)-builddeps),$(modulefilesdir)/$$(dep)) $($(eigen)-builddir)/.markerfile $($(eigen)-prefix)/.pkgbuild
# 	cd $($(eigen)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(eigen)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(eigen)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(eigen)-builddeps),$(modulefilesdir)/$$(dep)) $($(eigen)-builddir)/.markerfile $($(eigen)-prefix)/.pkgcheck
	cd $($(eigen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(eigen)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(eigen)-modulefile): $(modulefilesdir)/.markerfile $($(eigen)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(eigen)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(eigen)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(eigen)-description)\"" >>$@
	echo "module-whatis \"$($(eigen)-url)\"" >>$@
	printf "$(foreach prereq,$($(eigen)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv EIGEN_ROOT $($(eigen)-prefix)" >>$@
	echo "setenv EIGEN_INCDIR $($(eigen)-prefix)/include" >>$@
	echo "setenv EIGEN_INCLUDEDIR $($(eigen)-prefix)/include" >>$@
	echo "prepend-path PATH $($(eigen)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(eigen)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(eigen)-prefix)/include" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(eigen)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(eigen)-prefix)/share/eigen3/cmake" >>$@
	echo "set MSG \"$(eigen)\"" >>$@

$(eigen)-src: $$($(eigen)-src)
$(eigen)-unpack: $($(eigen)-prefix)/.pkgunpack
$(eigen)-patch: $($(eigen)-prefix)/.pkgpatch
$(eigen)-build: $($(eigen)-prefix)/.pkgbuild
$(eigen)-check: $($(eigen)-prefix)/.pkgcheck
$(eigen)-install: $($(eigen)-prefix)/.pkginstall
$(eigen)-modulefile: $($(eigen)-modulefile)
$(eigen)-clean:
	rm -rf $($(eigen)-modulefile)
	rm -rf $($(eigen)-prefix)
	rm -rf $($(eigen)-srcdir)
	rm -rf $($(eigen)-src)
$(eigen): $(eigen)-src $(eigen)-unpack $(eigen)-patch $(eigen)-build $(eigen)-check $(eigen)-install $(eigen)-modulefile
