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
# libdrm-2.4.107

libdrm-version = 2.4.107
libdrm = libdrm-$(libdrm-version)
$(libdrm)-description = Direct Rendering Manager library and headers
$(libdrm)-url = https://gitlab.freedesktop.org/mesa/drm
$(libdrm)-srcurl = https://dri.freedesktop.org/libdrm/libdrm-$(libdrm-version).tar.xz
$(libdrm)-builddeps = $(meson) $(ninja) $(libatomic_ops) $(libpciaccess) $(cairo)
$(libdrm)-prereqs = $(libatomic_ops) $(libpciaccess) $(cairo)
$(libdrm)-src = $(pkgsrcdir)/$(notdir $($(libdrm)-srcurl))
$(libdrm)-srcdir = $(pkgsrcdir)/$(libdrm)
$(libdrm)-builddir = $($(libdrm)-srcdir)/build
$(libdrm)-modulefile = $(modulefilesdir)/$(libdrm)
$(libdrm)-prefix = $(pkgdir)/$(libdrm)

$($(libdrm)-src): $(dir $($(libdrm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libdrm)-srcurl)

$($(libdrm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libdrm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libdrm)-prefix)/.pkgunpack: $$($(libdrm)-src) $($(libdrm)-srcdir)/.markerfile $($(libdrm)-prefix)/.markerfile $$(foreach dep,$$($(libdrm)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libdrm)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libdrm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdrm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdrm)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libdrm)-builddir),$($(libdrm)-srcdir))
$($(libdrm)-builddir)/.markerfile: $($(libdrm)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libdrm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdrm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdrm)-builddir)/.markerfile $($(libdrm)-prefix)/.pkgpatch
	cd $($(libdrm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdrm)-builddeps) && \
		meson .. --prefix=$($(libdrm)-prefix) \
			--libdir=$($(libdrm)-prefix)/lib && \
		ninja
	@touch $@

$($(libdrm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdrm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdrm)-builddir)/.markerfile $($(libdrm)-prefix)/.pkgbuild
	@touch $@

$($(libdrm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdrm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdrm)-builddir)/.markerfile $($(libdrm)-prefix)/.pkgcheck
	cd $($(libdrm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdrm)-builddeps) && \
		ninja install
	@touch $@

$($(libdrm)-modulefile): $(modulefilesdir)/.markerfile $($(libdrm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libdrm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libdrm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libdrm)-description)\"" >>$@
	echo "module-whatis \"$($(libdrm)-url)\"" >>$@
	printf "$(foreach prereq,$($(libdrm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBDRM_ROOT $($(libdrm)-prefix)" >>$@
	echo "setenv LIBDRM_INCDIR $($(libdrm)-prefix)/include" >>$@
	echo "setenv LIBDRM_INCLUDEDIR $($(libdrm)-prefix)/include" >>$@
	echo "setenv LIBDRM_LIBDIR $($(libdrm)-prefix)/lib" >>$@
	echo "setenv LIBDRM_LIBRARYDIR $($(libdrm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libdrm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libdrm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libdrm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libdrm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libdrm)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libdrm)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libdrm)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libdrm)-prefix)/share/info" >>$@
	echo "set MSG \"$(libdrm)\"" >>$@

$(libdrm)-src: $$($(libdrm)-src)
$(libdrm)-unpack: $($(libdrm)-prefix)/.pkgunpack
$(libdrm)-patch: $($(libdrm)-prefix)/.pkgpatch
$(libdrm)-build: $($(libdrm)-prefix)/.pkgbuild
$(libdrm)-check: $($(libdrm)-prefix)/.pkgcheck
$(libdrm)-install: $($(libdrm)-prefix)/.pkginstall
$(libdrm)-modulefile: $($(libdrm)-modulefile)
$(libdrm)-clean:
	rm -rf $($(libdrm)-modulefile)
	rm -rf $($(libdrm)-prefix)
	rm -rf $($(libdrm)-builddir)
	rm -rf $($(libdrm)-srcdir)
	rm -rf $($(libdrm)-src)
$(libdrm): $(libdrm)-src $(libdrm)-unpack $(libdrm)-patch $(libdrm)-build $(libdrm)-check $(libdrm)-install $(libdrm)-modulefile
