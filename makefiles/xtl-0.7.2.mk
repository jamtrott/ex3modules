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
# xtl-0.7.2

xtl-version = 0.7.2
xtl = xtl-$(xtl-version)
$(xtl)-description = C++ library for numerical analysis with multi-dimensional array expressions
$(xtl)-url = https://github.com/xtensor-stack/xtl
$(xtl)-srcurl = https://github.com/xtensor-stack/xtl/archive/refs/tags/0.7.2.tar.gz
$(xtl)-builddeps = $(cmake)
$(xtl)-prereqs =
$(xtl)-src = $(pkgsrcdir)/$(notdir $($(xtl)-srcurl))
$(xtl)-srcdir = $(pkgsrcdir)/$(xtl)
$(xtl)-builddir = $($(xtl)-srcdir)/build
$(xtl)-modulefile = $(modulefilesdir)/$(xtl)
$(xtl)-prefix = $(pkgdir)/$(xtl)

$($(xtl)-src): $(dir $($(xtl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xtl)-srcurl)

$($(xtl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xtl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xtl)-prefix)/.pkgunpack: $$($(xtl)-src) $($(xtl)-srcdir)/.markerfile $($(xtl)-prefix)/.markerfile
	tar -C $($(xtl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xtl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtl)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xtl)-builddir),$($(xtl)-srcdir))
$($(xtl)-builddir)/.markerfile: $($(xtl)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xtl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtl)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtl)-builddir)/.markerfile $($(xtl)-prefix)/.pkgpatch
	cd $($(xtl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtl)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(xtl)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib && \
		$(MAKE)
	@touch $@

$($(xtl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtl)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtl)-builddir)/.markerfile $($(xtl)-prefix)/.pkgbuild
	@touch $@

$($(xtl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xtl)-builddeps),$(modulefilesdir)/$$(dep)) $($(xtl)-builddir)/.markerfile $($(xtl)-prefix)/.pkgcheck
	cd $($(xtl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xtl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(xtl)-modulefile): $(modulefilesdir)/.markerfile $($(xtl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xtl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xtl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xtl)-description)\"" >>$@
	echo "module-whatis \"$($(xtl)-url)\"" >>$@
	printf "$(foreach prereq,$($(xtl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XTL_ROOT $($(xtl)-prefix)" >>$@
	echo "setenv XTL_INCDIR $($(xtl)-prefix)/include" >>$@
	echo "setenv XTL_INCLUDEDIR $($(xtl)-prefix)/include" >>$@
	echo "prepend-path PATH $($(xtl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xtl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xtl)-prefix)/include" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xtl)-prefix)/share/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(xtl)-prefix)/share/cmake" >>$@
	echo "set MSG \"$(xtl)\"" >>$@

$(xtl)-src: $$($(xtl)-src)
$(xtl)-unpack: $($(xtl)-prefix)/.pkgunpack
$(xtl)-patch: $($(xtl)-prefix)/.pkgpatch
$(xtl)-build: $($(xtl)-prefix)/.pkgbuild
$(xtl)-check: $($(xtl)-prefix)/.pkgcheck
$(xtl)-install: $($(xtl)-prefix)/.pkginstall
$(xtl)-modulefile: $($(xtl)-modulefile)
$(xtl)-clean:
	rm -rf $($(xtl)-modulefile)
	rm -rf $($(xtl)-prefix)
	rm -rf $($(xtl)-builddir)
	rm -rf $($(xtl)-srcdir)
	rm -rf $($(xtl)-src)
$(xtl): $(xtl)-src $(xtl)-unpack $(xtl)-patch $(xtl)-build $(xtl)-check $(xtl)-install $(xtl)-modulefile
