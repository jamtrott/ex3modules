# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
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
# python-h5py-2.10.0

python-h5py-version = 2.10.0
python-h5py = python-h5py-$(python-h5py-version)
$(python-h5py)-description = The h5py package is a Pythonic interface to the HDF5 binary data format
$(python-h5py)-url = https://www.h5py.org/
$(python-h5py)-srcurl = https://github.com/h5py/h5py/archive/$(python-h5py-version).tar.gz
$(python-h5py)-src = $(pkgsrcdir)/python-h5py-$(notdir $($(python-h5py)-srcurl))
$(python-h5py)-srcdir = $(pkgsrcdir)/$(python-h5py)
$(python-h5py)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-cython) $(python-mpi4py) $(python-six) $(hdf5-parallel) $(python-pytest)
$(python-h5py)-prereqs = $(python) $(python-numpy) $(python-cython) $(python-mpi4py) $(python-six) $(hdf5-parallel)
$(python-h5py)-modulefile = $(modulefilesdir)/$(python-h5py)
$(python-h5py)-prefix = $(pkgdir)/$(python-h5py)
$(python-h5py)-site-packages = $($(python-h5py)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-h5py)-src): $(dir $($(python-h5py)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-h5py)-srcurl)

$($(python-h5py)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-h5py)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-h5py)-prefix)/.pkgunpack: $$($(python-h5py)-src) $($(python-h5py)-srcdir)/.markerfile $($(python-h5py)-prefix)/.markerfile $$(foreach dep,$$($(python-h5py)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-h5py)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-h5py)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h5py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h5py)-prefix)/.pkgunpack
	@touch $@

$($(python-h5py)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-h5py)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h5py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h5py)-prefix)/.pkgpatch
	cd $($(python-h5py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-h5py)-builddeps) && \
		HDF5_DIR="$${HDF5_ROOT}" HDF5_MPI="ON" CC="$${MPICC}" python3 setup.py build
	@touch $@

$($(python-h5py)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h5py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h5py)-prefix)/.pkgbuild
	# cd $($(python-h5py)-srcdir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-h5py)-builddeps) && \
	# 	HDF5_DIR="$${HDF5_ROOT}" HDF5_MPI="ON" CC="$${MPICC}" PYTHONDONTWRITEBYTECODE=1 python3 setup.py test
	@touch $@

$($(python-h5py)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h5py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h5py)-prefix)/.pkgcheck $($(python-h5py)-site-packages)/.markerfile
	cd $($(python-h5py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-h5py)-builddeps) && \
		PYTHONPATH=$($(python-h5py)-site-packages):$${PYTHONPATH} \
		HDF5_DIR="$${HDF5_ROOT}" HDF5_MPI="ON" CC="$${MPICC}" python3 setup.py install --prefix=$($(python-h5py)-prefix)
	@touch $@

$($(python-h5py)-modulefile): $(modulefilesdir)/.markerfile $($(python-h5py)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-h5py)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-h5py)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-h5py)-description)\"" >>$@
	echo "module-whatis \"$($(python-h5py)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-h5py)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_H5PY_ROOT $($(python-h5py)-prefix)" >>$@
	echo "prepend-path PATH $($(python-h5py)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-h5py)-site-packages)" >>$@
	echo "set MSG \"$(python-h5py)\"" >>$@

$(python-h5py)-src: $($(python-h5py)-src)
$(python-h5py)-unpack: $($(python-h5py)-prefix)/.pkgunpack
$(python-h5py)-patch: $($(python-h5py)-prefix)/.pkgpatch
$(python-h5py)-build: $($(python-h5py)-prefix)/.pkgbuild
$(python-h5py)-check: $($(python-h5py)-prefix)/.pkgcheck
$(python-h5py)-install: $($(python-h5py)-prefix)/.pkginstall
$(python-h5py)-modulefile: $($(python-h5py)-modulefile)
$(python-h5py)-clean:
	rm -rf $($(python-h5py)-modulefile)
	rm -rf $($(python-h5py)-prefix)
	rm -rf $($(python-h5py)-srcdir)
	rm -rf $($(python-h5py)-src)
$(python-h5py): $(python-h5py)-src $(python-h5py)-unpack $(python-h5py)-patch $(python-h5py)-build $(python-h5py)-check $(python-h5py)-install $(python-h5py)-modulefile
