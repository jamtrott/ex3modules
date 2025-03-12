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
# mesa-21.1.5

mesa-version = 21.1.5
mesa = mesa-$(mesa-version)
$(mesa)-description = Open source implementations of OpenGL, OpenGL ES, Vulkan, OpenCL, and more
$(mesa)-url = https://www.mesa3d.org/
$(mesa)-srcurl = https://archive.mesa3d.org/older-versions/21.x/mesa-$(mesa-version).tar.xz
$(mesa)-builddeps = $(meson) $(ninja) $(python) $(python-mako) $(llvm-12) $(libxv) $(libxvmc) $(flex) $(bison) $(libunwind) $(libdrm) $(expat) $(libx11) $(libxext) $(libxfixes) $(libxrandr) $(libxshmfence) $(libxxf86vm) $(xcb-proto)
$(mesa)-prereqs = $(llvm-12) $(libxv) $(libxvmc) $(libunwind) $(libdrm) $(expat) $(libx11) $(libxext) $(libxfixes) $(libxrandr) $(libxshmfence) $(libxxf86vm) $(xcb-proto)
$(mesa)-src = $(pkgsrcdir)/$(notdir $($(mesa)-srcurl))
$(mesa)-srcdir = $(pkgsrcdir)/$(mesa)
$(mesa)-builddir = $($(mesa)-srcdir)/build
$(mesa)-modulefile = $(modulefilesdir)/$(mesa)
$(mesa)-prefix = $(pkgdir)/$(mesa)

$($(mesa)-src): $(dir $($(mesa)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mesa)-srcurl)

$($(mesa)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mesa)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mesa)-prefix)/.pkgunpack: $$($(mesa)-src) $($(mesa)-srcdir)/.markerfile $($(mesa)-prefix)/.markerfile $$(foreach dep,$$($(mesa)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mesa)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(mesa)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mesa)-builddeps),$(modulefilesdir)/$$(dep)) $($(mesa)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(mesa)-builddir),$($(mesa)-srcdir))
$($(mesa)-builddir)/.markerfile: $($(mesa)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(mesa)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mesa)-builddeps),$(modulefilesdir)/$$(dep)) $($(mesa)-builddir)/.markerfile $($(mesa)-prefix)/.pkgpatch
	cd $($(mesa)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mesa)-builddeps) && \
		meson .. --prefix=$($(mesa)-prefix) \
			--libdir=$($(mesa)-prefix)/lib \
			--sysconfdir=$($(mesa)-prefix)/etc \
			-Dplatforms=x11 \
			-Ddri-drivers=[] \
			-Dgallium-drivers=swrast \
			-Dvulkan-drivers=swrast && \
		ninja
	@touch $@

$($(mesa)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mesa)-builddeps),$(modulefilesdir)/$$(dep)) $($(mesa)-builddir)/.markerfile $($(mesa)-prefix)/.pkgbuild
	@touch $@

$($(mesa)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mesa)-builddeps),$(modulefilesdir)/$$(dep)) $($(mesa)-builddir)/.markerfile $($(mesa)-prefix)/.pkgcheck
	cd $($(mesa)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mesa)-builddeps) && \
		ninja install
	@touch $@

$($(mesa)-modulefile): $(modulefilesdir)/.markerfile $($(mesa)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mesa)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mesa)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mesa)-description)\"" >>$@
	echo "module-whatis \"$($(mesa)-url)\"" >>$@
	printf "$(foreach prereq,$($(mesa)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MESA_ROOT $($(mesa)-prefix)" >>$@
	echo "setenv MESA_INCDIR $($(mesa)-prefix)/include" >>$@
	echo "setenv MESA_INCLUDEDIR $($(mesa)-prefix)/include" >>$@
	echo "setenv MESA_LIBDIR $($(mesa)-prefix)/lib" >>$@
	echo "setenv MESA_LIBRARYDIR $($(mesa)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mesa)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mesa)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mesa)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mesa)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mesa)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(mesa)\"" >>$@

$(mesa)-src: $$($(mesa)-src)
$(mesa)-unpack: $($(mesa)-prefix)/.pkgunpack
$(mesa)-patch: $($(mesa)-prefix)/.pkgpatch
$(mesa)-build: $($(mesa)-prefix)/.pkgbuild
$(mesa)-check: $($(mesa)-prefix)/.pkgcheck
$(mesa)-install: $($(mesa)-prefix)/.pkginstall
$(mesa)-modulefile: $($(mesa)-modulefile)
$(mesa)-clean:
	rm -rf $($(mesa)-modulefile)
	rm -rf $($(mesa)-prefix)
	rm -rf $($(mesa)-builddir)
	rm -rf $($(mesa)-srcdir)
	rm -rf $($(mesa)-src)
$(mesa): $(mesa)-src $(mesa)-unpack $(mesa)-patch $(mesa)-build $(mesa)-check $(mesa)-install $(mesa)-modulefile
