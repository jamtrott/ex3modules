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
# xtensor-blas-0.20.0

xtensor-blas-version = 0.20.0
xtensor-blas = xtensor-blas-$(xtensor-blas-version)
$(xtensor-blas)-description = Extension to the xtensor library, offering bindings to BLAS and LAPACK libraries
$(xtensor-blas)-url = https://github.com/xtensor-stack/xtensor-blas
$(xtensor-blas)-srcurl = https://github.com/xtensor-stack/xtensor-blas/archive/refs/tags/0.20.0.tar.gz
$(xtensor-blas)-builddeps = $(cmake) $(xtl) $(xtensor)
$(xtensor-blas)-prereqs = $(xtl) $(xtensor)
$(xtensor-blas)-src = $(pkgsrcdir)/$(notdir $($(xtensor-blas)-srcurl))
$(xtensor-blas)-srcdir = $(pkgsrcdir)/$(xtensor-blas)
$(xtensor-blas)-builddir = $($(xtensor-blas)-srcdir)/build
$(xtensor-blas)-modulefile = $(modulefilesdir)/$(xtensor-blas)
$(xtensor-blas)-prefix = $(pkgdir)/$(xtensor-blas)

$($(xtensor-blas)-src): $(dir $($(xtensor-blas)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xtensor-blas)-srcurl)

$($(xtensor-blas)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xtensor-blas)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xtensor-blas)-prefix)/.pkgunpack: $$($(xtensor-blas)-src) $($(xtensor-blas)-srcdir)/.markerfile $($(xtensor-blas)-prefix)/.markerfile
	tar -C $($(xtensor-blas)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xtensor-blas)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor-blas)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xtensor-blas)-builddir),$($(xtensor-blas)-srcdir))
$($(xtensor-blas)-builddir)/.markerfile: $($(xtensor-blas)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xtensor-blas)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor-blas)-builddir)/.markerfile $($(xtensor-blas)-prefix)/.pkgpatch
	cd $($(xtensor-blas)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtensor-blas)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(xtensor-blas)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib && \
		$(MAKE)
	@touch $@

$($(xtensor-blas)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor-blas)-builddir)/.markerfile $($(xtensor-blas)-prefix)/.pkgbuild
	@touch $@

$($(xtensor-blas)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor-blas)-builddir)/.markerfile $($(xtensor-blas)-prefix)/.pkgcheck
	cd $($(xtensor-blas)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtensor-blas)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xtensor-blas)-modulefile): $(modulefilesdir)/.markerfile $($(xtensor-blas)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xtensor-blas)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xtensor-blas)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xtensor-blas)-description)\"" >>$@
	echo "module-whatis \"$($(xtensor-blas)-url)\"" >>$@
	printf "$(foreach prereq,$($(xtensor-blas)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XTENSOR_BLAS_ROOT $($(xtensor-blas)-prefix)" >>$@
	echo "setenv XTENSOR_BLAS_INCDIR $($(xtensor-blas)-prefix)/include" >>$@
	echo "setenv XTENSOR_BLAS_INCLUDEDIR $($(xtensor-blas)-prefix)/include" >>$@
	echo "prepend-path PATH $($(xtensor-blas)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xtensor-blas)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xtensor-blas)-prefix)/include" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xtensor-blas)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(xtensor-blas)-prefix)/lib/cmake" >>$@
	echo "set MSG \"$(xtensor-blas)\"" >>$@

$(xtensor-blas)-src: $$($(xtensor-blas)-src)
$(xtensor-blas)-unpack: $($(xtensor-blas)-prefix)/.pkgunpack
$(xtensor-blas)-patch: $($(xtensor-blas)-prefix)/.pkgpatch
$(xtensor-blas)-build: $($(xtensor-blas)-prefix)/.pkgbuild
$(xtensor-blas)-check: $($(xtensor-blas)-prefix)/.pkgcheck
$(xtensor-blas)-install: $($(xtensor-blas)-prefix)/.pkginstall
$(xtensor-blas)-modulefile: $($(xtensor-blas)-modulefile)
$(xtensor-blas)-clean:
	rm -rf $($(xtensor-blas)-modulefile)
	rm -rf $($(xtensor-blas)-prefix)
	rm -rf $($(xtensor-blas)-builddir)
	rm -rf $($(xtensor-blas)-srcdir)
	rm -rf $($(xtensor-blas)-src)
$(xtensor-blas): $(xtensor-blas)-src $(xtensor-blas)-unpack $(xtensor-blas)-patch $(xtensor-blas)-build $(xtensor-blas)-check $(xtensor-blas)-install $(xtensor-blas)-modulefile
