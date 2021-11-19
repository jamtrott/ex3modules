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
# fenics-basix-0.3.0

fenics-basix-0.3.0-version = 0.3.0
fenics-basix-0.3.0 = fenics-basix-$(fenics-basix-0.3.0-version)
$(fenics-basix-0.3.0)-description = Finite element definition and tabulation runtime library
$(fenics-basix-0.3.0)-url = https://fenicsproject.org/
$(fenics-basix-0.3.0)-srcurl =
$(fenics-basix-0.3.0)-builddeps = $(gcc) $(cmake) $(ninja) $(xtl) $(xtensor) $(xtensor-blas) $(xsimd) $(openblas)
$(fenics-basix-0.3.0)-prereqs = $(libstdcxx) $(xtl) $(xtensor) $(xtensor-blas) $(xsimd) $(openblas)
$(fenics-basix-0.3.0)-src = $($(fenics-basix-src-0.3.0)-src)
$(fenics-basix-0.3.0)-srcdir = $(pkgsrcdir)/$(fenics-basix-0.3.0)
$(fenics-basix-0.3.0)-builddir = $($(fenics-basix-0.3.0)-srcdir)/build
$(fenics-basix-0.3.0)-modulefile = $(modulefilesdir)/$(fenics-basix-0.3.0)
$(fenics-basix-0.3.0)-prefix = $(pkgdir)/$(fenics-basix-0.3.0)

$($(fenics-basix-0.3.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-basix-0.3.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-basix-0.3.0)-prefix)/.pkgunpack: $$($(fenics-basix-0.3.0)-src) $($(fenics-basix-0.3.0)-srcdir)/.markerfile $($(fenics-basix-0.3.0)-prefix)/.markerfile
	tar -C $($(fenics-basix-0.3.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fenics-basix-0.3.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep))
	@touch $@

$($(fenics-basix-0.3.0)-builddir)/.markerfile: $($(fenics-basix-0.3.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(fenics-basix-0.3.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-basix-0.3.0)-builddir)/.markerfile $($(fenics-basix-0.3.0)-prefix)/.pkgpatch
	cd $($(fenics-basix-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-basix-0.3.0)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(fenics-basix-0.3.0)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DXTENSOR_USE_XSIMD=YES && \
		$(MAKE)
	@touch $@

$($(fenics-basix-0.3.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-basix-0.3.0)-builddir)/.markerfile $($(fenics-basix-0.3.0)-prefix)/.pkgbuild
	@touch $@

$($(fenics-basix-0.3.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(fenics-basix-0.3.0)-builddir)/.markerfile $($(fenics-basix-0.3.0)-prefix)/.pkgcheck
	cd $($(fenics-basix-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fenics-basix-0.3.0)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fenics-basix-0.3.0)-modulefile): $(modulefilesdir)/.markerfile $($(fenics-basix-0.3.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fenics-basix-0.3.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fenics-basix-0.3.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fenics-basix-0.3.0)-description)\"" >>$@
	echo "module-whatis \"$($(fenics-basix-0.3.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(fenics-basix-0.3.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FENICS_BASIX_ROOT $($(fenics-basix-0.3.0)-prefix)" >>$@
	echo "setenv FENICS_BASIX_INCDIR $($(fenics-basix-0.3.0)-prefix)/include" >>$@
	echo "setenv FENICS_BASIX_INCLUDEDIR $($(fenics-basix-0.3.0)-prefix)/include" >>$@
	echo "setenv FENICS_BASIX_LIBDIR $($(fenics-basix-0.3.0)-prefix)/lib" >>$@
	echo "setenv FENICS_BASIX_LIBRARYDIR $($(fenics-basix-0.3.0)-prefix)/lib" >>$@
	echo "setenv BASIX_DIR $($(fenics-basix-0.3.0)-prefix)" >>$@
	echo "prepend-path PATH $($(fenics-basix-0.3.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fenics-basix-0.3.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fenics-basix-0.3.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fenics-basix-0.3.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fenics-basix-0.3.0)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fenics-basix-0.3.0)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(fenics-basix-0.3.0)-prefix)/share/basix/cmake" >>$@
	echo "set MSG \"$(fenics-basix-0.3.0)\"" >>$@

$(fenics-basix-0.3.0)-src: $($(fenics-basix-0.3.0)-src)
$(fenics-basix-0.3.0)-unpack: $($(fenics-basix-0.3.0)-prefix)/.pkgunpack
$(fenics-basix-0.3.0)-patch: $($(fenics-basix-0.3.0)-prefix)/.pkgpatch
$(fenics-basix-0.3.0)-build: $($(fenics-basix-0.3.0)-prefix)/.pkgbuild
$(fenics-basix-0.3.0)-check: $($(fenics-basix-0.3.0)-prefix)/.pkgcheck
$(fenics-basix-0.3.0)-install: $($(fenics-basix-0.3.0)-prefix)/.pkginstall
$(fenics-basix-0.3.0)-modulefile: $($(fenics-basix-0.3.0)-modulefile)
$(fenics-basix-0.3.0)-clean:
	rm -rf $($(fenics-basix-0.3.0)-modulefile)
	rm -rf $($(fenics-basix-0.3.0)-prefix)
	rm -rf $($(fenics-basix-0.3.0)-builddir)
	rm -rf $($(fenics-basix-0.3.0)-srcdir)
$(fenics-basix-0.3.0): $(fenics-basix-0.3.0)-src $(fenics-basix-0.3.0)-unpack $(fenics-basix-0.3.0)-patch $(fenics-basix-0.3.0)-build $(fenics-basix-0.3.0)-check $(fenics-basix-0.3.0)-install $(fenics-basix-0.3.0)-modulefile
