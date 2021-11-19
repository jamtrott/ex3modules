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
# vmtk-1.4.0

vmtk-version = 1.4.0
vmtk = vmtk-$(vmtk-version)
$(vmtk)-description = The Vascular Modeling Toolkit
$(vmtk)-url = http://www.vmtk.org/
$(vmtk)-srcurl = https://github.com/vmtk/vmtk/archive/refs/tags/v$(vmtk-version).tar.gz
$(vmtk)-builddeps = $(cmake) $(ninja) $(itk) $(vtk8) $(python) $(python-numpy) $(hdf5-parallel)
$(vmtk)-prereqs = $(itk) $(vtk8) $(python) $(python-numpy) $(hdf5-parallel)
$(vmtk)-src = $(pkgsrcdir)/vmtk-$(notdir $($(vmtk)-srcurl))
$(vmtk)-srcdir = $(pkgsrcdir)/$(vmtk)
$(vmtk)-builddir = $($(vmtk)-srcdir)/build
$(vmtk)-modulefile = $(modulefilesdir)/$(vmtk)
$(vmtk)-prefix = $(pkgdir)/$(vmtk)

$($(vmtk)-src): $(dir $($(vmtk)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(vmtk)-srcurl)

$($(vmtk)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(vmtk)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(vmtk)-prefix)/.pkgunpack: $$($(vmtk)-src) $($(vmtk)-srcdir)/.markerfile $($(vmtk)-prefix)/.markerfile
	tar -C $($(vmtk)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(vmtk)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vmtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(vmtk)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(vmtk)-builddir),$($(vmtk)-srcdir))
$($(vmtk)-builddir)/.markerfile: $($(vmtk)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(vmtk)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vmtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(vmtk)-builddir)/.markerfile $($(vmtk)-prefix)/.pkgpatch
	cd $($(vmtk)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(vmtk)-builddeps) && \
		cmake .. -G Ninja \
			-DCMAKE_INSTALL_PREFIX="$($(vmtk)-prefix)" \
			-DVMTK_INSTALL_LIB_DIR=lib \
			-DVMTK_MODULE_INSTALL_LIB_DIR="lib/python$${PYTHON_VERSION_SHORT}/site-packages/vmtk" \
			-DBUILD_SHARED_LIBS=ON \
			-DUSE_SYSTEM_VTK=ON \
			-DVTK_DIR="$${VTK_ROOT}" \
			-DUSE_SYSTEM_ITK=ON \
			-DITK_DIR="$${ITK_ROOT}" \
			-DPYTHON_EXECUTABLE="$${PYTHON_ROOT}/bin/python$${PYTHON_VERSION_SHORT}" \
			-DPYTHON_INCLUDE_DIR="$${PYTHON_INCDIR}/python$${PYTHON_VERSION_SHORT}m" \
			-DPYTHON_LIBRARY="$${PYTHON_LIBDIR}/libpython3.so" \
			-DPYTHON_SHEBANG="$${PYTHON_ROOT}/bin/python$${PYTHON_VERSION_SHORT}" \
			-DVMTK_PYTHON_VERSION="$${PYTHON_VERSION_SHORT}" \
			-DVTK_VMTK_WRAP_PYTHON:BOOL=ON \
			-DVTK_ENABLE_VTKPYTHON:BOOL=ON \
			-DVMTK_MINIMAL_INSTALL:BOOL=OFF \
			-DVMTK_ENABLE_DISTRIBUTION:BOOL=ON \
			-DVMTK_USE_RENDERING:STRING=ON \
			-DVMTK_USE_X:STRING=ON && \
		ninja
	@touch $@

$($(vmtk)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vmtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(vmtk)-builddir)/.markerfile $($(vmtk)-prefix)/.pkgbuild
	@touch $@

$($(vmtk)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(vmtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(vmtk)-builddir)/.markerfile $($(vmtk)-prefix)/.pkgcheck
	find $($(vmtk)-builddir)/Install/ -type f -exec sed -i 's,#!/usr/bin/env python$$,#!/usr/bin/env python3,' {} \;
	rsync -avr $($(vmtk)-builddir)/Install/ $($(vmtk)-prefix)/
	@touch $@

$($(vmtk)-modulefile): $(modulefilesdir)/.markerfile $($(vmtk)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(vmtk)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(vmtk)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(vmtk)-description)\"" >>$@
	echo "module-whatis \"$($(vmtk)-url)\"" >>$@
	printf "$(foreach prereq,$($(vmtk)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv VMTK_ROOT $($(vmtk)-prefix)" >>$@
	echo "setenv VMTK_INCDIR $($(vmtk)-prefix)/include" >>$@
	echo "setenv VMTK_INCLUDEDIR $($(vmtk)-prefix)/include" >>$@
	echo "setenv VMTK_LIBDIR $($(vmtk)-prefix)/lib" >>$@
	echo "setenv VMTK_LIBRARYDIR $($(vmtk)-prefix)/lib" >>$@
	echo "setenv VMTKHOME $($(vmtk)-prefix)" >>$@
	echo "prepend-path PATH $($(vmtk)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(vmtk)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(vmtk)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(vmtk)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(vmtk)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(vmtk)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path PYTHONPATH $($(vmtk)-prefix)/lib/python$(python-version-short)/site-packages" >>$@
	echo "prepend-path MANPATH $($(vmtk)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(vmtk)-prefix)/share/info" >>$@
	echo "set MSG \"$(vmtk)\"" >>$@

$(vmtk)-src: $$($(vmtk)-src)
$(vmtk)-unpack: $($(vmtk)-prefix)/.pkgunpack
$(vmtk)-patch: $($(vmtk)-prefix)/.pkgpatch
$(vmtk)-build: $($(vmtk)-prefix)/.pkgbuild
$(vmtk)-check: $($(vmtk)-prefix)/.pkgcheck
$(vmtk)-install: $($(vmtk)-prefix)/.pkginstall
$(vmtk)-modulefile: $($(vmtk)-modulefile)
$(vmtk)-clean:
	rm -rf $($(vmtk)-modulefile)
	rm -rf $($(vmtk)-prefix)
	rm -rf $($(vmtk)-builddir)
	rm -rf $($(vmtk)-srcdir)
	rm -rf $($(vmtk)-src)
$(vmtk): $(vmtk)-src $(vmtk)-unpack $(vmtk)-patch $(vmtk)-build $(vmtk)-check $(vmtk)-install $(vmtk)-modulefile
