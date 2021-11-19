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
# python-fenics-dolfinx-20200525

python-fenics-dolfinx-20200525-version = 20200525
python-fenics-dolfinx-20200525 = python-fenics-dolfinx-$(python-fenics-dolfinx-20200525-version)
$(python-fenics-dolfinx-20200525)-description = FEniCS Project: Python interface for solving partial differential equations
$(python-fenics-dolfinx-20200525)-url = https://fenicsproject.org/
$(python-fenics-dolfinx-20200525)-srcurl =
$(python-fenics-dolfinx-20200525)-builddeps = $(gcc) $(python) $(cmake) $(blas) $(mpi) $(python-numpy) $(python-pkgconfig) $(python-fenics-fiat-20200518) $(python-fenics-ufl-20200512) $(python-fenics-ffcx-20200522) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(fenics-dolfinx-20200525)
$(python-fenics-dolfinx-20200525)-prereqs = $(libstdcxx) $(python) $(python-numpy) $(python-pkgconfig) $(python-fenics-fiat-20200518) $(python-fenics-ufl-20200512) $(python-fenics-ffcx-20200522) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(fenics-dolfinx-20200525)
$(python-fenics-dolfinx-20200525)-src = $($(fenics-dolfinx-src)-src)
$(python-fenics-dolfinx-20200525)-srcdir = $(pkgsrcdir)/$(python-fenics-dolfinx-20200525)
$(python-fenics-dolfinx-20200525)-builddir = $(python-fenics-dolfinx-20200525-srcdir)/dolfinx-29274633248cfbce175599ad2127d0949afdb166/python
$(python-fenics-dolfinx-20200525)-modulefile = $(modulefilesdir)/$(python-fenics-dolfinx-20200525)
$(python-fenics-dolfinx-20200525)-prefix = $(pkgdir)/$(python-fenics-dolfinx-20200525)
$(python-fenics-dolfinx-20200525)-site-packages = $($(python-fenics-dolfinx-20200525)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-fenics-dolfinx-20200525)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfinx-20200525)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfinx-20200525)-prefix)/.pkgunpack: $$($(python-fenics-dolfinx-20200525)-src) $($(python-fenics-dolfinx-20200525)-srcdir)/.markerfile $($(python-fenics-dolfinx-20200525)-prefix)/.markerfile
	cd $($(python-fenics-dolfinx-20200525)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-dolfinx-20200525)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-20200525)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-dolfinx-20200525)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfinx-20200525)-builddir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfinx-20200525)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-20200525)-prefix)/.pkgpatch $($(python-fenics-dolfinx-20200525)-builddir)/.markerfile
	cd $($(python-fenics-dolfinx-20200525)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-20200525)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-dolfinx-20200525)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-20200525)-prefix)/.pkgbuild $($(python-fenics-dolfinx-20200525)-builddir)/.markerfile
	@touch $@

$($(python-fenics-dolfinx-20200525)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-20200525)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-20200525)-prefix)/.pkgcheck $($(python-fenics-dolfinx-20200525)-site-packages)/.markerfile $($(python-fenics-dolfinx-20200525)-builddir)/.markerfile
	cd $($(python-fenics-dolfinx-20200525)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-20200525)-builddeps) && \
		PYTHONPATH=$($(python-fenics-dolfinx-20200525)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-dolfinx-20200525)-prefix)
	@touch $@

$($(python-fenics-dolfinx-20200525)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-dolfinx-20200525)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-dolfinx-20200525)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-dolfinx-20200525)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-dolfinx-20200525)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-dolfinx-20200525)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-dolfinx-20200525)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_DOLFINX_20200525_ROOT $($(python-fenics-dolfinx-20200525)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-dolfinx-20200525)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-dolfinx-20200525)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-dolfinx-20200525)\"" >>$@

$(python-fenics-dolfinx-20200525)-src: $($(python-fenics-dolfinx-20200525)-src)
$(python-fenics-dolfinx-20200525)-unpack: $($(python-fenics-dolfinx-20200525)-prefix)/.pkgunpack
$(python-fenics-dolfinx-20200525)-patch: $($(python-fenics-dolfinx-20200525)-prefix)/.pkgpatch
$(python-fenics-dolfinx-20200525)-build: $($(python-fenics-dolfinx-20200525)-prefix)/.pkgbuild
$(python-fenics-dolfinx-20200525)-check: $($(python-fenics-dolfinx-20200525)-prefix)/.pkgcheck
$(python-fenics-dolfinx-20200525)-install: $($(python-fenics-dolfinx-20200525)-prefix)/.pkginstall
$(python-fenics-dolfinx-20200525)-modulefile: $($(python-fenics-dolfinx-20200525)-modulefile)
$(python-fenics-dolfinx-20200525)-clean:
	rm -rf $($(python-fenics-dolfinx-20200525)-modulefile)
	rm -rf $($(python-fenics-dolfinx-20200525)-prefix)
	rm -rf $($(python-fenics-dolfinx-20200525)-srcdir)
$(python-fenics-dolfinx-20200525): $(python-fenics-dolfinx-20200525)-src $(python-fenics-dolfinx-20200525)-unpack $(python-fenics-dolfinx-20200525)-patch $(python-fenics-dolfinx-20200525)-build $(python-fenics-dolfinx-20200525)-check $(python-fenics-dolfinx-20200525)-install $(python-fenics-dolfinx-20200525)-modulefile
