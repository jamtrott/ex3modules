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
# xtensor-0.24.0

xtensor-version = 0.24.0
xtensor = xtensor-$(xtensor-version)
$(xtensor)-description = C++ library for numerical analysis with multi-dimensional array expressions
$(xtensor)-url = https://github.com/xtensor-stack/xtensor
$(xtensor)-srcurl = https://github.com/xtensor-stack/xtensor/archive/refs/tags/0.24.0.tar.gz
$(xtensor)-builddeps = $(cmake) $(xtl)
$(xtensor)-prereqs = $(xtl)
$(xtensor)-src = $(pkgsrcdir)/$(notdir $($(xtensor)-srcurl))
$(xtensor)-srcdir = $(pkgsrcdir)/$(xtensor)
$(xtensor)-builddir = $($(xtensor)-srcdir)/build
$(xtensor)-modulefile = $(modulefilesdir)/$(xtensor)
$(xtensor)-prefix = $(pkgdir)/$(xtensor)

$($(xtensor)-src): $(dir $($(xtensor)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xtensor)-srcurl)

$($(xtensor)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xtensor)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xtensor)-prefix)/.pkgunpack: $$($(xtensor)-src) $($(xtensor)-srcdir)/.markerfile $($(xtensor)-prefix)/.markerfile
	tar -C $($(xtensor)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xtensor)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xtensor)-builddir),$($(xtensor)-srcdir))
$($(xtensor)-builddir)/.markerfile: $($(xtensor)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xtensor)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor)-builddir)/.markerfile $($(xtensor)-prefix)/.pkgpatch
	cd $($(xtensor)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtensor)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(xtensor)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib && \
		$(MAKE)
	@touch $@

$($(xtensor)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor)-builddir)/.markerfile $($(xtensor)-prefix)/.pkgbuild
	@touch $@

$($(xtensor)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtensor)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtensor)-builddir)/.markerfile $($(xtensor)-prefix)/.pkgcheck
	cd $($(xtensor)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtensor)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xtensor)-modulefile): $(modulefilesdir)/.markerfile $($(xtensor)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xtensor)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xtensor)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xtensor)-description)\"" >>$@
	echo "module-whatis \"$($(xtensor)-url)\"" >>$@
	printf "$(foreach prereq,$($(xtensor)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XTENSOR_ROOT $($(xtensor)-prefix)" >>$@
	echo "setenv XTENSOR_INCDIR $($(xtensor)-prefix)/include" >>$@
	echo "setenv XTENSOR_INCLUDEDIR $($(xtensor)-prefix)/include" >>$@
	echo "prepend-path PATH $($(xtensor)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xtensor)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xtensor)-prefix)/include" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xtensor)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(xtensor)-prefix)/lib/cmake" >>$@
	echo "set MSG \"$(xtensor)\"" >>$@

$(xtensor)-src: $$($(xtensor)-src)
$(xtensor)-unpack: $($(xtensor)-prefix)/.pkgunpack
$(xtensor)-patch: $($(xtensor)-prefix)/.pkgpatch
$(xtensor)-build: $($(xtensor)-prefix)/.pkgbuild
$(xtensor)-check: $($(xtensor)-prefix)/.pkgcheck
$(xtensor)-install: $($(xtensor)-prefix)/.pkginstall
$(xtensor)-modulefile: $($(xtensor)-modulefile)
$(xtensor)-clean:
	rm -rf $($(xtensor)-modulefile)
	rm -rf $($(xtensor)-prefix)
	rm -rf $($(xtensor)-builddir)
	rm -rf $($(xtensor)-srcdir)
	rm -rf $($(xtensor)-src)
$(xtensor): $(xtensor)-src $(xtensor)-unpack $(xtensor)-patch $(xtensor)-build $(xtensor)-check $(xtensor)-install $(xtensor)-modulefile
