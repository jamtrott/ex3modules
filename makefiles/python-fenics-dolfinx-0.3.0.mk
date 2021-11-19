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
# python-fenics-dolfinx-0.3.0

python-fenics-dolfinx-0.3.0-version = 0.3.0
python-fenics-dolfinx-0.3.0 = python-fenics-dolfinx-$(python-fenics-dolfinx-0.3.0-version)
$(python-fenics-dolfinx-0.3.0)-description = FEniCS Project: Python interface for solving partial differential equations
$(python-fenics-dolfinx-0.3.0)-url = https://fenicsproject.org/
$(python-fenics-dolfinx-0.3.0)-srcurl =
$(python-fenics-dolfinx-0.3.0)-builddeps = $(python) $(cmake) $(blas) $(mpi) $(python-numpy) $(python-pkgconfig) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(python-cffi) $(fenics-dolfinx-0.3.0) $(gcc-10.1.0)
$(python-fenics-dolfinx-0.3.0)-prereqs = $(libstdcxx) $(python) $(python-numpy) $(python-pkgconfig) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(python-cffi) $(fenics-dolfinx-0.3.0)
$(python-fenics-dolfinx-0.3.0)-src = $($(fenics-dolfinx-src-0.3.0)-src)
$(python-fenics-dolfinx-0.3.0)-srcdir = $(pkgsrcdir)/$(python-fenics-dolfinx-0.3.0)
$(python-fenics-dolfinx-0.3.0)-builddir = $(python-fenics-dolfinx-0.3.0-srcdir)/python
$(python-fenics-dolfinx-0.3.0)-modulefile = $(modulefilesdir)/$(python-fenics-dolfinx-0.3.0)
$(python-fenics-dolfinx-0.3.0)-prefix = $(pkgdir)/$(python-fenics-dolfinx-0.3.0)
$(python-fenics-dolfinx-0.3.0)-site-packages = $($(python-fenics-dolfinx-0.3.0)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-fenics-dolfinx-0.3.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfinx-0.3.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgunpack: $$($(python-fenics-dolfinx-0.3.0)-src) $($(python-fenics-dolfinx-0.3.0)-srcdir)/.markerfile $($(python-fenics-dolfinx-0.3.0)-prefix)/.markerfile
	tar -C $($(python-fenics-dolfinx-0.3.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-dolfinx-0.3.0)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

ifneq ($($(python-fenics-dolfinx-0.3.0)-builddir),$($(python-fenics-dolfinx-0.3.0)-srcdir))
$($(python-fenics-dolfinx-0.3.0)-builddir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@
endif

$($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgpatch $($(python-fenics-dolfinx-0.3.0)-builddir)/.markerfile
	cd $($(python-fenics-dolfinx-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-0.3.0)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgbuild $($(python-fenics-dolfinx-0.3.0)-builddir)/.markerfile
	@touch $@

$($(python-fenics-dolfinx-0.3.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgcheck $($(python-fenics-dolfinx-0.3.0)-site-packages)/.markerfile $($(python-fenics-dolfinx-0.3.0)-builddir)/.markerfile
	cd $($(python-fenics-dolfinx-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-0.3.0)-builddeps) && \
		PYTHONPATH=$($(python-fenics-dolfinx-0.3.0)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-dolfinx-0.3.0)-prefix)
	@touch $@

$($(python-fenics-dolfinx-0.3.0)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-dolfinx-0.3.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-dolfinx-0.3.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-dolfinx-0.3.0)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-dolfinx-0.3.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-dolfinx-0.3.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_DOLFINX_ROOT $($(python-fenics-dolfinx-0.3.0)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-dolfinx-0.3.0)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-dolfinx-0.3.0)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-dolfinx-0.3.0)\"" >>$@

$(python-fenics-dolfinx-0.3.0)-src: $($(python-fenics-dolfinx-0.3.0)-src)
$(python-fenics-dolfinx-0.3.0)-unpack: $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgunpack
$(python-fenics-dolfinx-0.3.0)-patch: $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgpatch
$(python-fenics-dolfinx-0.3.0)-build: $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgbuild
$(python-fenics-dolfinx-0.3.0)-check: $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkgcheck
$(python-fenics-dolfinx-0.3.0)-install: $($(python-fenics-dolfinx-0.3.0)-prefix)/.pkginstall
$(python-fenics-dolfinx-0.3.0)-modulefile: $($(python-fenics-dolfinx-0.3.0)-modulefile)
$(python-fenics-dolfinx-0.3.0)-clean:
	rm -rf $($(python-fenics-dolfinx-0.3.0)-modulefile)
	rm -rf $($(python-fenics-dolfinx-0.3.0)-prefix)
	rm -rf $($(python-fenics-dolfinx-0.3.0)-srcdir)
$(python-fenics-dolfinx-0.3.0): $(python-fenics-dolfinx-0.3.0)-src $(python-fenics-dolfinx-0.3.0)-unpack $(python-fenics-dolfinx-0.3.0)-patch $(python-fenics-dolfinx-0.3.0)-build $(python-fenics-dolfinx-0.3.0)-check $(python-fenics-dolfinx-0.3.0)-install $(python-fenics-dolfinx-0.3.0)-modulefile
