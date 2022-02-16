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
# virtualgl-2.6.5

virtualgl-version = 2.6.5
virtualgl = virtualgl-$(virtualgl-version)
$(virtualgl)-description = Hardware-accelerated remote OpenGL rendering
$(virtualgl)-url = https://virtualgl.org/
$(virtualgl)-srcurl = https://sourceforge.net/projects/virtualgl/files/$(virtualgl-version)/VirtualGL-$(virtualgl-version).tar.gz/download
$(virtualgl)-builddeps = $(cmake) $(openssl) $(libjpeg-turbo) $(libx11) $(libxext) $(libxtst) $(mesa) $(libxcb) $(xcb-util-keysyms) $(libxv)
$(virtualgl)-prereqs = $(openssl) $(libjpeg-turbo) $(libx11) $(libxext) $(libxtst) $(mesa) $(libxcb) $(xcb-util-keysyms) $(libxv)
$(virtualgl)-src = $(pkgsrcdir)/$(notdir $($(virtualgl)-srcurl))
$(virtualgl)-srcdir = $(pkgsrcdir)/$(virtualgl)
$(virtualgl)-builddir = $($(virtualgl)-srcdir)/build
$(virtualgl)-modulefile = $(modulefilesdir)/$(virtualgl)
$(virtualgl)-prefix = $(pkgdir)/$(virtualgl)

$($(virtualgl)-src): $(dir $($(virtualgl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(virtualgl)-srcurl)

$($(virtualgl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(virtualgl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(virtualgl)-prefix)/.pkgunpack: $$($(virtualgl)-src) $($(virtualgl)-srcdir)/.markerfile $($(virtualgl)-prefix)/.markerfile $$(foreach dep,$$($(virtualgl)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(virtualgl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(virtualgl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(virtualgl)-builddeps),$(modulefilesdir)/$$(dep)) $($(virtualgl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(virtualgl)-builddir),$($(virtualgl)-srcdir))
$($(virtualgl)-builddir)/.markerfile: $($(virtualgl)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(virtualgl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(virtualgl)-builddeps),$(modulefilesdir)/$$(dep)) $($(virtualgl)-builddir)/.markerfile $($(virtualgl)-prefix)/.pkgpatch
	cd $($(virtualgl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(virtualgl)-builddeps) && \
		$(CMAKE) -DCMAKE_INSTALL_PREFIX=$($(virtualgl)-prefix) \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DVGL_FAKEOPENCL=0 \
		-DVGL_USESSL=1 \
		-DVGL_USEXV=1 \
		-DTJPEG_INCLUDE_DIR="$${LIBJPEG_TURBO_INCDIR}" \
		-DX11_Xtst_INCLUDE_PATH="$${LIBXTST_INCDIR}" \
		-DX11_Xtst_LIB="$${LIBXTST_LIBDIR}/libXtst.so" \
		.. && \
		$(MAKE)
	@touch $@

$($(virtualgl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(virtualgl)-builddeps),$(modulefilesdir)/$$(dep)) $($(virtualgl)-builddir)/.markerfile $($(virtualgl)-prefix)/.pkgbuild
	@touch $@

$($(virtualgl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(virtualgl)-builddeps),$(modulefilesdir)/$$(dep)) $($(virtualgl)-builddir)/.markerfile $($(virtualgl)-prefix)/.pkgcheck
	cd $($(virtualgl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(virtualgl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(virtualgl)-modulefile): $(modulefilesdir)/.markerfile $($(virtualgl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(virtualgl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(virtualgl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(virtualgl)-description)\"" >>$@
	echo "module-whatis \"$($(virtualgl)-url)\"" >>$@
	printf "$(foreach prereq,$($(virtualgl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv VIRTUALGL_ROOT $($(virtualgl)-prefix)" >>$@
	echo "setenv VIRTUALGL_INCDIR $($(virtualgl)-prefix)/include" >>$@
	echo "setenv VIRTUALGL_INCLUDEDIR $($(virtualgl)-prefix)/include" >>$@
	echo "setenv VIRTUALGL_LIBDIR $($(virtualgl)-prefix)/lib" >>$@
	echo "setenv VIRTUALGL_LIBRARYDIR $($(virtualgl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(virtualgl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(virtualgl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(virtualgl)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(virtualgl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(virtualgl)-prefix)/lib" >>$@
	echo "set MSG \"$(virtualgl)\"" >>$@

$(virtualgl)-src: $$($(virtualgl)-src)
$(virtualgl)-unpack: $($(virtualgl)-prefix)/.pkgunpack
$(virtualgl)-patch: $($(virtualgl)-prefix)/.pkgpatch
$(virtualgl)-build: $($(virtualgl)-prefix)/.pkgbuild
$(virtualgl)-check: $($(virtualgl)-prefix)/.pkgcheck
$(virtualgl)-install: $($(virtualgl)-prefix)/.pkginstall
$(virtualgl)-modulefile: $($(virtualgl)-modulefile)
$(virtualgl)-clean:
	rm -rf $($(virtualgl)-modulefile)
	rm -rf $($(virtualgl)-prefix)
	rm -rf $($(virtualgl)-builddir)
	rm -rf $($(virtualgl)-srcdir)
	rm -rf $($(virtualgl)-src)
$(virtualgl): $(virtualgl)-src $(virtualgl)-unpack $(virtualgl)-patch $(virtualgl)-build $(virtualgl)-check $(virtualgl)-install $(virtualgl)-modulefile
