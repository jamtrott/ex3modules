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
# xsimd-8.0.3

xsimd-version = 8.0.3
xsimd = xsimd-$(xsimd-version)
$(xsimd)-description = C++ wrappers for SIMD intrinsics
$(xsimd)-url = https://github.com/xsimd-stack/xsimd
$(xsimd)-srcurl = https://github.com/xtensor-stack/xsimd/archive/refs/tags/8.0.3.tar.gz
$(xsimd)-builddeps = $(cmake) $(xtl)
$(xsimd)-prereqs = $(xtl)
$(xsimd)-src = $(pkgsrcdir)/$(notdir $($(xsimd)-srcurl))
$(xsimd)-srcdir = $(pkgsrcdir)/$(xsimd)
$(xsimd)-builddir = $($(xsimd)-srcdir)/build
$(xsimd)-modulefile = $(modulefilesdir)/$(xsimd)
$(xsimd)-prefix = $(pkgdir)/$(xsimd)

$($(xsimd)-src): $(dir $($(xsimd)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xsimd)-srcurl)

$($(xsimd)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xsimd)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xsimd)-prefix)/.pkgunpack: $$($(xsimd)-src) $($(xsimd)-srcdir)/.markerfile $($(xsimd)-prefix)/.markerfile
	tar -C $($(xsimd)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xsimd)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xsimd)-builddeps),$(modulefilesdir)/$$(dep)) $($(xsimd)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xsimd)-builddir),$($(xsimd)-srcdir))
$($(xsimd)-builddir)/.markerfile: $($(xsimd)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xsimd)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xsimd)-builddeps),$(modulefilesdir)/$$(dep)) $($(xsimd)-builddir)/.markerfile $($(xsimd)-prefix)/.pkgpatch
	cd $($(xsimd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xsimd)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(xsimd)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib && \
		$(MAKE)
	@touch $@

$($(xsimd)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xsimd)-builddeps),$(modulefilesdir)/$$(dep)) $($(xsimd)-builddir)/.markerfile $($(xsimd)-prefix)/.pkgbuild
	@touch $@

$($(xsimd)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xsimd)-builddeps),$(modulefilesdir)/$$(dep)) $($(xsimd)-builddir)/.markerfile $($(xsimd)-prefix)/.pkgcheck
	cd $($(xsimd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xsimd)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xsimd)-modulefile): $(modulefilesdir)/.markerfile $($(xsimd)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xsimd)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xsimd)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xsimd)-description)\"" >>$@
	echo "module-whatis \"$($(xsimd)-url)\"" >>$@
	printf "$(foreach prereq,$($(xsimd)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XSIMD_ROOT $($(xsimd)-prefix)" >>$@
	echo "setenv XSIMD_INCDIR $($(xsimd)-prefix)/include" >>$@
	echo "setenv XSIMD_INCLUDEDIR $($(xsimd)-prefix)/include" >>$@
	echo "prepend-path PATH $($(xsimd)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xsimd)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xsimd)-prefix)/include" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xsimd)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(xsimd)-prefix)/lib/cmake" >>$@
	echo "set MSG \"$(xsimd)\"" >>$@

$(xsimd)-src: $$($(xsimd)-src)
$(xsimd)-unpack: $($(xsimd)-prefix)/.pkgunpack
$(xsimd)-patch: $($(xsimd)-prefix)/.pkgpatch
$(xsimd)-build: $($(xsimd)-prefix)/.pkgbuild
$(xsimd)-check: $($(xsimd)-prefix)/.pkgcheck
$(xsimd)-install: $($(xsimd)-prefix)/.pkginstall
$(xsimd)-modulefile: $($(xsimd)-modulefile)
$(xsimd)-clean:
	rm -rf $($(xsimd)-modulefile)
	rm -rf $($(xsimd)-prefix)
	rm -rf $($(xsimd)-builddir)
	rm -rf $($(xsimd)-srcdir)
	rm -rf $($(xsimd)-src)
$(xsimd): $(xsimd)-src $(xsimd)-unpack $(xsimd)-patch $(xsimd)-build $(xsimd)-check $(xsimd)-install $(xsimd)-modulefile
