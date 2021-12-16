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
# vtk9-9.1.0

vtk9-version = 9.1.0
vtk9 = vtk9-$(vtk9-version)
$(vtk9)-description = The Visualization Toolkit (VTK) for manipulating and displaying scientific data
$(vtk9)-url = https://vtk.org/
$(vtk9)-srcurl = https://www.vtk.org/files/release/9.1/VTK-9.1.0.tar.gz
$(vtk9)-builddeps = $(cmake) $(ninja) $(python) $(qt5) $(mpi) $(mesa) $(expat) $(fmt) $(libpng) $(eigen) $(exprtk) $(freetype) $(libxml2) $(pugixml) $(libtiff) $(utf8cpp) $(hdf5-parallel) $(libjpeg) $(python-mpi4py) $(sqlite)
$(vtk9)-prereqs = $(python) $(qt5) $(mpi) $(mesa) $(expat) $(fmt) $(libpng) $(eigen) $(exprtk) $(freetype) $(libxml2) $(pugixml) $(libtiff) $(utf8cpp) $(hdf5-parallel) $(libjpeg) $(python-mpi4py) $(sqlite) # glew jsoncpp libproj lz4 netcdf theora vpic xdmf3 cli11 h5part ioss kissfft lzma ogg vtkm zfp diy2 exodusII fides gl2ps libharu loguru pegtl verdict xdmf2
$(vtk9)-src = $(pkgsrcdir)/$(notdir $($(vtk9)-srcurl))
$(vtk9)-srcdir = $(pkgsrcdir)/$(vtk9)
$(vtk9)-builddir = $($(vtk9)-srcdir)/build
$(vtk9)-modulefile = $(modulefilesdir)/$(vtk9)
$(vtk9)-prefix = $(pkgdir)/$(vtk9)

$($(vtk9)-src): $(dir $($(vtk9)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(vtk9)-srcurl)

$($(vtk9)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(vtk9)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(vtk9)-prefix)/.pkgunpack: $$($(vtk9)-src) $($(vtk9)-srcdir)/.markerfile $($(vtk9)-prefix)/.markerfile $$(foreach dep,$$($(vtk9)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(vtk9)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(vtk9)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk9)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk9)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(vtk9)-builddir),$($(vtk9)-srcdir))
$($(vtk9)-builddir)/.markerfile: $($(vtk9)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(vtk9)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk9)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk9)-builddir)/.markerfile $($(vtk9)-prefix)/.pkgpatch
	cd $($(vtk9)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(vtk9)-builddeps) && \
		cmake .. -G Ninja \
			-DCMAKE_INSTALL_PREFIX=$($(vtk9)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=ON \
			-DVTK_USE_MPI=ON \
			-DVTK_WRAP_PYTHON=ON \
			-Dutf8cpp_INCLUDE_DIR=$${UTF8CPP_INCDIR} \
			-DExprTk_INCLUDE_DIR=$${EXPRTK_INCDIR} \
			-Dpugixml_DIR=$${PUGIXML_ROOT} && \
		ninja
	@touch $@

$($(vtk9)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk9)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk9)-builddir)/.markerfile $($(vtk9)-prefix)/.pkgbuild
	@touch $@

$($(vtk9)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk9)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk9)-builddir)/.markerfile $($(vtk9)-prefix)/.pkgcheck
	cd $($(vtk9)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(vtk9)-builddeps) && \
		ninja install
	@touch $@

$($(vtk9)-modulefile): $(modulefilesdir)/.markerfile $($(vtk9)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(vtk9)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(vtk9)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(vtk9)-description)\"" >>$@
	echo "module-whatis \"$($(vtk9)-url)\"" >>$@
	printf "$(foreach prereq,$($(vtk9)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv VTK_ROOT $($(vtk9)-prefix)" >>$@
	echo "setenv VTK_INCDIR $($(vtk9)-prefix)/include" >>$@
	echo "setenv VTK_INCLUDEDIR $($(vtk9)-prefix)/include" >>$@
	echo "setenv VTK_LIBDIR $($(vtk9)-prefix)/lib" >>$@
	echo "setenv VTK_LIBRARYDIR $($(vtk9)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(vtk9)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(vtk9)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(vtk9)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(vtk9)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(vtk9)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(vtk9)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(vtk9)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(vtk9)-prefix)/share/info" >>$@
	echo "set MSG \"$(vtk9)\"" >>$@

$(vtk9)-src: $$($(vtk9)-src)
$(vtk9)-unpack: $($(vtk9)-prefix)/.pkgunpack
$(vtk9)-patch: $($(vtk9)-prefix)/.pkgpatch
$(vtk9)-build: $($(vtk9)-prefix)/.pkgbuild
$(vtk9)-check: $($(vtk9)-prefix)/.pkgcheck
$(vtk9)-install: $($(vtk9)-prefix)/.pkginstall
$(vtk9)-modulefile: $($(vtk9)-modulefile)
$(vtk9)-clean:
	rm -rf $($(vtk9)-modulefile)
	rm -rf $($(vtk9)-prefix)
	rm -rf $($(vtk9)-builddir)
	rm -rf $($(vtk9)-srcdir)
	rm -rf $($(vtk9)-src)
$(vtk9): $(vtk9)-src $(vtk9)-unpack $(vtk9)-patch $(vtk9)-build $(vtk9)-check $(vtk9)-install $(vtk9)-modulefile
