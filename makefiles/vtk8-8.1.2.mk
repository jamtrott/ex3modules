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
# vtk8-8.1.2

vtk8-version = 8.1.2
vtk8 = vtk8-$(vtk8-version)
$(vtk8)-description = The Visualization Toolkit (VTK) for manipulating and displaying scientific data
$(vtk8)-url = https://vtk.org/
$(vtk8)-srcurl = https://www.vtk.org/files/release/8.1/VTK-8.1.2.tar.gz
$(vtk8)-builddeps = $(cmake) $(ninja) $(python) $(qt5) $(mpi) $(mesa) $(expat) $(fmt) $(libpng) $(eigen) $(exprtk) $(freetype) $(libxml2) $(pugixml) $(libtiff) $(utf8cpp) $(hdf5-parallel) $(libjpeg) $(python-mpi4py) $(sqlite)
$(vtk8)-prereqs = $(python) $(qt5) $(mpi) $(mesa) $(expat) $(fmt) $(libpng) $(eigen) $(exprtk) $(freetype) $(libxml2) $(pugixml) $(libtiff) $(utf8cpp) $(hdf5-parallel) $(libjpeg) $(python-mpi4py) $(sqlite) # glew jsoncpp libproj lz4 netcdf theora vpic xdmf3 cli11 h5part ioss kissfft lzma ogg vtkm zfp diy2 exodusII fides gl2ps libharu loguru pegtl verdict xdmf2
$(vtk8)-src = $(pkgsrcdir)/$(notdir $($(vtk8)-srcurl))
$(vtk8)-srcdir = $(pkgsrcdir)/$(vtk8)
$(vtk8)-builddir = $($(vtk8)-srcdir)/build
$(vtk8)-modulefile = $(modulefilesdir)/$(vtk8)
$(vtk8)-prefix = $(pkgdir)/$(vtk8)

$($(vtk8)-src): $(dir $($(vtk8)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(vtk8)-srcurl)

$($(vtk8)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(vtk8)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(vtk8)-prefix)/.pkgunpack: $$($(vtk8)-src) $($(vtk8)-srcdir)/.markerfile $($(vtk8)-prefix)/.markerfile $$(foreach dep,$$($(vtk8)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(vtk8)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(vtk8)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk8)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk8)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(vtk8)-builddir),$($(vtk8)-srcdir))
$($(vtk8)-builddir)/.markerfile: $($(vtk8)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(vtk8)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk8)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk8)-builddir)/.markerfile $($(vtk8)-prefix)/.pkgpatch
	cd $($(vtk8)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(vtk8)-builddeps) && \
		$(CMAKE) .. -G Ninja \
			-DCMAKE_INSTALL_PREFIX="$($(vtk8)-prefix)" \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=ON \
			-DVTK_USE_MPI=ON \
			-DVTK_WRAP_PYTHON=ON \
			-DVTK_PYTHON_VERSION="$${PYTHON_VERSION_MAJOR}" \
			-DVTK_PYTHON_EXECUTABLE="$${PYTHON_ROOT}/bin/python$${PYTHON_VERSION_SHORT}" \
			-DVTK_PYTHON_INCLUDE_DIR="$${PYTHON_INCDIR}/python$${PYTHON_VERSION_SHORT}m" \
			-DVTK_PYTHON_LIBRARY="$${PYTHON_LIBDIR}/libpython3.so" \
			-Dutf8cpp_INCLUDE_DIR="$${UTF8CPP_INCDIR}" \
			-DExprTk_INCLUDE_DIR="$${EXPRTK_INCDIR}" \
			-Dpugixml_DIR="$${PUGIXML_ROOT}" && \
		ninja
	@touch $@

$($(vtk8)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk8)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk8)-builddir)/.markerfile $($(vtk8)-prefix)/.pkgbuild
	@touch $@

$($(vtk8)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vtk8)-builddeps),$(modulefilesdir)/$$(dep)) $($(vtk8)-builddir)/.markerfile $($(vtk8)-prefix)/.pkgcheck
	cd $($(vtk8)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(vtk8)-builddeps) && \
		ninja install
	@touch $@

$($(vtk8)-modulefile): $(modulefilesdir)/.markerfile $($(vtk8)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(vtk8)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(vtk8)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(vtk8)-description)\"" >>$@
	echo "module-whatis \"$($(vtk8)-url)\"" >>$@
	printf "$(foreach prereq,$($(vtk8)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv VTK_ROOT $($(vtk8)-prefix)" >>$@
	echo "setenv VTK_INCDIR $($(vtk8)-prefix)/include" >>$@
	echo "setenv VTK_INCLUDEDIR $($(vtk8)-prefix)/include" >>$@
	echo "setenv VTK_LIBDIR $($(vtk8)-prefix)/lib" >>$@
	echo "setenv VTK_LIBRARYDIR $($(vtk8)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(vtk8)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(vtk8)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(vtk8)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(vtk8)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(vtk8)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(vtk8)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path PYTHONPATH $($(vtk8)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages" >>$@
	echo "prepend-path PYTHONPATH $($(vtk8)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages/vtk" >>$@
	echo "prepend-path MANPATH $($(vtk8)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(vtk8)-prefix)/share/info" >>$@
	echo "set MSG \"$(vtk8)\"" >>$@

$(vtk8)-src: $$($(vtk8)-src)
$(vtk8)-unpack: $($(vtk8)-prefix)/.pkgunpack
$(vtk8)-patch: $($(vtk8)-prefix)/.pkgpatch
$(vtk8)-build: $($(vtk8)-prefix)/.pkgbuild
$(vtk8)-check: $($(vtk8)-prefix)/.pkgcheck
$(vtk8)-install: $($(vtk8)-prefix)/.pkginstall
$(vtk8)-modulefile: $($(vtk8)-modulefile)
$(vtk8)-clean:
	rm -rf $($(vtk8)-modulefile)
	rm -rf $($(vtk8)-prefix)
	rm -rf $($(vtk8)-builddir)
	rm -rf $($(vtk8)-srcdir)
	rm -rf $($(vtk8)-src)
$(vtk8): $(vtk8)-src $(vtk8)-unpack $(vtk8)-patch $(vtk8)-build $(vtk8)-check $(vtk8)-install $(vtk8)-modulefile
