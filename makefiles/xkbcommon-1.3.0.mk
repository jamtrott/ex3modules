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
# xkbcommon-1.3.0

xkbcommon-version = 1.3.0
xkbcommon = xkbcommon-$(xkbcommon-version)
$(xkbcommon)-description = Library for handling of keyboard descriptions
$(xkbcommon)-url = https://xkbcommon.org/
$(xkbcommon)-srcurl = https://xkbcommon.org/download/libxkbcommon-$(xkbcommon-version).tar.xz
$(xkbcommon)-builddeps = $(meson) $(ninja) $(cmake) $(bison) $(libxcb) $(libxml2)
$(xkbcommon)-prereqs = $(libxcb) $(libxml2)
$(xkbcommon)-src = $(pkgsrcdir)/$(notdir $($(xkbcommon)-srcurl))
$(xkbcommon)-srcdir = $(pkgsrcdir)/$(xkbcommon)
$(xkbcommon)-builddir = $($(xkbcommon)-srcdir)/build
$(xkbcommon)-modulefile = $(modulefilesdir)/$(xkbcommon)
$(xkbcommon)-prefix = $(pkgdir)/$(xkbcommon)

$($(xkbcommon)-src): $(dir $($(xkbcommon)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xkbcommon)-srcurl)

$($(xkbcommon)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xkbcommon)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xkbcommon)-prefix)/.pkgunpack: $$($(xkbcommon)-src) $($(xkbcommon)-srcdir)/.markerfile $($(xkbcommon)-prefix)/.markerfile $$(foreach dep,$$($(xkbcommon)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(xkbcommon)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(xkbcommon)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xkbcommon)-builddeps),$(modulefilesdir)/$$(dep)) $($(xkbcommon)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(xkbcommon)-builddir),$($(xkbcommon)-srcdir))
$($(xkbcommon)-builddir)/.markerfile: $($(xkbcommon)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(xkbcommon)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xkbcommon)-builddeps),$(modulefilesdir)/$$(dep)) $($(xkbcommon)-builddir)/.markerfile $($(xkbcommon)-prefix)/.pkgpatch
	cd $($(xkbcommon)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xkbcommon)-builddeps) && \
		meson --prefix=$($(xkbcommon)-prefix) \
			--libdir=$($(xkbcommon)-prefix)/lib \
			-Denable-docs=false \
			-Denable-wayland=false \
			.. && \
		ninja
	@touch $@

$($(xkbcommon)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xkbcommon)-builddeps),$(modulefilesdir)/$$(dep)) $($(xkbcommon)-builddir)/.markerfile $($(xkbcommon)-prefix)/.pkgbuild
	cd $($(xkbcommon)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xkbcommon)-builddeps) && \
		ninja test
	@touch $@

$($(xkbcommon)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xkbcommon)-builddeps),$(modulefilesdir)/$$(dep)) $($(xkbcommon)-builddir)/.markerfile $($(xkbcommon)-prefix)/.pkgcheck
	cd $($(xkbcommon)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(xkbcommon)-builddeps) && \
		ninja install
	@touch $@

$($(xkbcommon)-modulefile): $(modulefilesdir)/.markerfile $($(xkbcommon)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xkbcommon)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xkbcommon)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xkbcommon)-description)\"" >>$@
	echo "module-whatis \"$($(xkbcommon)-url)\"" >>$@
	printf "$(foreach prereq,$($(xkbcommon)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv XKBCOMMON_ROOT $($(xkbcommon)-prefix)" >>$@
	echo "setenv XKBCOMMON_INCDIR $($(xkbcommon)-prefix)/include" >>$@
	echo "setenv XKBCOMMON_INCLUDEDIR $($(xkbcommon)-prefix)/include" >>$@
	echo "setenv XKBCOMMON_LIBDIR $($(xkbcommon)-prefix)/lib" >>$@
	echo "setenv XKBCOMMON_LIBRARYDIR $($(xkbcommon)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(xkbcommon)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xkbcommon)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xkbcommon)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xkbcommon)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xkbcommon)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xkbcommon)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(xkbcommon)-prefix)/share/man" >>$@
	echo "set MSG \"$(xkbcommon)\"" >>$@

$(xkbcommon)-src: $$($(xkbcommon)-src)
$(xkbcommon)-unpack: $($(xkbcommon)-prefix)/.pkgunpack
$(xkbcommon)-patch: $($(xkbcommon)-prefix)/.pkgpatch
$(xkbcommon)-build: $($(xkbcommon)-prefix)/.pkgbuild
$(xkbcommon)-check: $($(xkbcommon)-prefix)/.pkgcheck
$(xkbcommon)-install: $($(xkbcommon)-prefix)/.pkginstall
$(xkbcommon)-modulefile: $($(xkbcommon)-modulefile)
$(xkbcommon)-clean:
	rm -rf $($(xkbcommon)-modulefile)
	rm -rf $($(xkbcommon)-prefix)
	rm -rf $($(xkbcommon)-builddir)
	rm -rf $($(xkbcommon)-srcdir)
	rm -rf $($(xkbcommon)-src)
$(xkbcommon): $(xkbcommon)-src $(xkbcommon)-unpack $(xkbcommon)-patch $(xkbcommon)-build $(xkbcommon)-check $(xkbcommon)-install $(xkbcommon)-modulefile
