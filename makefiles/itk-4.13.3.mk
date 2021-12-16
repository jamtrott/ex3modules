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
# itk-4.13.3

itk-version = 4.13.3
itk = itk-$(itk-version)
$(itk)-description = Open-source, cross-platform library of software tools for image analysis
$(itk)-url = https://itk.org/
$(itk)-srcurl = https://github.com/InsightSoftwareConsortium/ITK/releases/download/v4.13.3/InsightToolkit-4.13.3.tar.gz
$(itk)-builddeps = $(cmake) $(ninja) $(vtk) $(libjpeg) $(libpng) $(libtiff) $(hdf5-parallel)
$(itk)-prereqs = $(vtk) $(libjpeg) $(libpng) $(libtiff) $(hdf5-parallel)
$(itk)-src = $(pkgsrcdir)/$(notdir $($(itk)-srcurl))
$(itk)-srcdir = $(pkgsrcdir)/$(itk)
$(itk)-builddir = $($(itk)-srcdir)/build
$(itk)-modulefile = $(modulefilesdir)/$(itk)
$(itk)-prefix = $(pkgdir)/$(itk)

$($(itk)-src): $(dir $($(itk)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(itk)-srcurl)

$($(itk)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(itk)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(itk)-prefix)/.pkgunpack: $$($(itk)-src) $($(itk)-srcdir)/.markerfile $($(itk)-prefix)/.markerfile $$(foreach dep,$$($(itk)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(itk)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(itk)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(itk)-builddeps),$(modulefilesdir)/$$(dep)) $($(itk)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(itk)-builddir),$($(itk)-srcdir))
$($(itk)-builddir)/.markerfile: $($(itk)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(itk)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(itk)-builddeps),$(modulefilesdir)/$$(dep)) $($(itk)-builddir)/.markerfile $($(itk)-prefix)/.pkgpatch
	cd $($(itk)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(itk)-builddeps) && \
		cmake .. -G Ninja \
			-DCMAKE_INSTALL_PREFIX=$($(itk)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=ON \
			-DModule_ITKReview=ON && \
		ninja
	@touch $@

$($(itk)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(itk)-builddeps),$(modulefilesdir)/$$(dep)) $($(itk)-builddir)/.markerfile $($(itk)-prefix)/.pkgbuild
	@touch $@

$($(itk)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(itk)-builddeps),$(modulefilesdir)/$$(dep)) $($(itk)-builddir)/.markerfile $($(itk)-prefix)/.pkgcheck
	cd $($(itk)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(itk)-builddeps) && \
		ninja install
	@touch $@

$($(itk)-modulefile): $(modulefilesdir)/.markerfile $($(itk)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(itk)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(itk)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(itk)-description)\"" >>$@
	echo "module-whatis \"$($(itk)-url)\"" >>$@
	printf "$(foreach prereq,$($(itk)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv ITK_ROOT $($(itk)-prefix)" >>$@
	echo "setenv ITK_INCDIR $($(itk)-prefix)/include" >>$@
	echo "setenv ITK_INCLUDEDIR $($(itk)-prefix)/include" >>$@
	echo "setenv ITK_LIBDIR $($(itk)-prefix)/lib" >>$@
	echo "setenv ITK_LIBRARYDIR $($(itk)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(itk)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(itk)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(itk)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(itk)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(itk)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(itk)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(itk)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(itk)-prefix)/share/info" >>$@
	echo "set MSG \"$(itk)\"" >>$@

$(itk)-src: $$($(itk)-src)
$(itk)-unpack: $($(itk)-prefix)/.pkgunpack
$(itk)-patch: $($(itk)-prefix)/.pkgpatch
$(itk)-build: $($(itk)-prefix)/.pkgbuild
$(itk)-check: $($(itk)-prefix)/.pkgcheck
$(itk)-install: $($(itk)-prefix)/.pkginstall
$(itk)-modulefile: $($(itk)-modulefile)
$(itk)-clean:
	rm -rf $($(itk)-modulefile)
	rm -rf $($(itk)-prefix)
	rm -rf $($(itk)-builddir)
	rm -rf $($(itk)-srcdir)
	rm -rf $($(itk)-src)
$(itk): $(itk)-src $(itk)-unpack $(itk)-patch $(itk)-build $(itk)-check $(itk)-install $(itk)-modulefile
