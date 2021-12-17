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
# python-fenics-dolfin-2019.1.0.post0

python-fenics-dolfin-2019-version = 2019.1.0.post0
python-fenics-dolfin-2019 = python-fenics-dolfin-$(python-fenics-dolfin-2019-version)
$(python-fenics-dolfin-2019)-description = FEniCS Project: Python interface for solving partial differential equations
$(python-fenics-dolfin-2019)-url = https://fenicsproject.org/
$(python-fenics-dolfin-2019)-srcurl = $($(fenics-dolfin-2019-src)-srcurl)
$(python-fenics-dolfin-2019)-src = $($(fenics-dolfin-2019-src)-src)
$(python-fenics-dolfin-2019)-srcdir = $(pkgsrcdir)/$(python-fenics-dolfin-2019)
$(python-fenics-dolfin-2019)-builddir = $(pkgsrcdir)/$(python-fenics-dolfin-2019)/python
$(python-fenics-dolfin-2019)-builddeps = $(python) $(cmake) $(blas) $(mpi) $(python-numpy) $(python-pkgconfig) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019) $(python-fenics-ufl-2019) $(python-fenics-ffc-2019) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(fenics-dolfin-2019)
$(python-fenics-dolfin-2019)-prereqs = $(python) $(python-numpy) $(python-pkgconfig) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019) $(python-fenics-ufl-2019) $(python-fenics-ffc-2019) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(fenics-dolfin-2019)
$(python-fenics-dolfin-2019)-modulefile = $(modulefilesdir)/$(python-fenics-dolfin-2019)
$(python-fenics-dolfin-2019)-prefix = $(pkgdir)/$(python-fenics-dolfin-2019)
$(python-fenics-dolfin-2019)-site-packages = $($(python-fenics-dolfin-2019)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-dolfin-2019)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfin-2019)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfin-2019)-prefix)/.pkgunpack: $$($(python-fenics-dolfin-2019)-src) $($(python-fenics-dolfin-2019)-srcdir)/.markerfile $($(python-fenics-dolfin-2019)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-dolfin-2019)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-dolfin-2019)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2019)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-dolfin-2019)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfin-2019)-builddir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfin-2019)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2019)-prefix)/.pkgpatch $($(python-fenics-dolfin-2019)-builddir)/.markerfile
	cd $($(python-fenics-dolfin-2019)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfin-2019)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-dolfin-2019)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2019)-prefix)/.pkgbuild $($(python-fenics-dolfin-2019)-builddir)/.markerfile
	@touch $@

$($(python-fenics-dolfin-2019)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2019)-prefix)/.pkgcheck $($(python-fenics-dolfin-2019)-site-packages)/.markerfile $($(python-fenics-dolfin-2019)-builddir)/.markerfile
	cd $($(python-fenics-dolfin-2019)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfin-2019)-builddeps) && \
		PYTHONPATH=$($(python-fenics-dolfin-2019)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-fenics-dolfin-2019)-prefix)
	@touch $@

$($(python-fenics-dolfin-2019)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-dolfin-2019)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-dolfin-2019)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-dolfin-2019)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-dolfin-2019)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-dolfin-2019)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-dolfin-2019)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_DOLFIN_2019_ROOT $($(python-fenics-dolfin-2019)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-dolfin-2019)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-dolfin-2019)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-dolfin-2019)\"" >>$@

$(python-fenics-dolfin-2019)-src: $($(python-fenics-dolfin-2019)-src)
$(python-fenics-dolfin-2019)-unpack: $($(python-fenics-dolfin-2019)-prefix)/.pkgunpack
$(python-fenics-dolfin-2019)-patch: $($(python-fenics-dolfin-2019)-prefix)/.pkgpatch
$(python-fenics-dolfin-2019)-build: $($(python-fenics-dolfin-2019)-prefix)/.pkgbuild
$(python-fenics-dolfin-2019)-check: $($(python-fenics-dolfin-2019)-prefix)/.pkgcheck
$(python-fenics-dolfin-2019)-install: $($(python-fenics-dolfin-2019)-prefix)/.pkginstall
$(python-fenics-dolfin-2019)-modulefile: $($(python-fenics-dolfin-2019)-modulefile)
$(python-fenics-dolfin-2019)-clean:
	rm -rf $($(python-fenics-dolfin-2019)-modulefile)
	rm -rf $($(python-fenics-dolfin-2019)-prefix)
	rm -rf $($(python-fenics-dolfin-2019)-srcdir)
$(python-fenics-dolfin-2019): $(python-fenics-dolfin-2019)-src $(python-fenics-dolfin-2019)-unpack $(python-fenics-dolfin-2019)-patch $(python-fenics-dolfin-2019)-build $(python-fenics-dolfin-2019)-check $(python-fenics-dolfin-2019)-install $(python-fenics-dolfin-2019)-modulefile
