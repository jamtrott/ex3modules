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
# python-fenics-dolfin-2018.1.0.post1

python-fenics-dolfin-2018-version = 2018.1.0.post1
python-fenics-dolfin-2018 = python-fenics-dolfin-$(python-fenics-dolfin-2018-version)
$(python-fenics-dolfin-2018)-description = FEniCS Project: Python interface for solving partial differential equations
$(python-fenics-dolfin-2018)-url = https://fenicsproject.org/
$(python-fenics-dolfin-2018)-srcurl = $($(fenics-dolfin-2018-src)-srcurl)
$(python-fenics-dolfin-2018)-src = $($(fenics-dolfin-2018-src)-src)
$(python-fenics-dolfin-2018)-srcdir = $(pkgsrcdir)/$(python-fenics-dolfin-2018)
$(python-fenics-dolfin-2018)-builddir = $(pkgsrcdir)/$(python-fenics-dolfin-2018)/python
$(python-fenics-dolfin-2018)-builddeps = $(python) $(cmake) $(blas) $(mpi) $(python-numpy) $(python-pkgconfig) $(python-fenics-dijitso-2018) $(python-fenics-fiat-2018) $(python-fenics-ufl-2018) $(python-fenics-ffc-2018) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(fenics-dolfin-2018)
$(python-fenics-dolfin-2018)-prereqs = $(python) $(python-numpy) $(python-pkgconfig) $(python-fenics-dijitso-2018) $(python-fenics-fiat-2018) $(python-fenics-ufl-2018) $(python-fenics-ffc-2018) $(pybind11) $(python-ply) $(python-mpi4py) $(python-petsc4py) $(fenics-dolfin-2018)
$(python-fenics-dolfin-2018)-modulefile = $(modulefilesdir)/$(python-fenics-dolfin-2018)
$(python-fenics-dolfin-2018)-prefix = $(pkgdir)/$(python-fenics-dolfin-2018)
$(python-fenics-dolfin-2018)-site-packages = $($(python-fenics-dolfin-2018)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-dolfin-2018)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfin-2018)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfin-2018)-prefix)/.pkgunpack: $$($(python-fenics-dolfin-2018)-src) $($(python-fenics-dolfin-2018)-srcdir)/.markerfile $($(python-fenics-dolfin-2018)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-dolfin-2018)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-dolfin-2018)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2018)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-dolfin-2018)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfin-2018)-builddir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfin-2018)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2018)-prefix)/.pkgpatch $($(python-fenics-dolfin-2018)-builddir)/.markerfile
	cd $($(python-fenics-dolfin-2018)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfin-2018)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-dolfin-2018)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2018)-prefix)/.pkgbuild $($(python-fenics-dolfin-2018)-builddir)/.markerfile
	@touch $@

$($(python-fenics-dolfin-2018)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfin-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfin-2018)-prefix)/.pkgcheck $($(python-fenics-dolfin-2018)-site-packages)/.markerfile $($(python-fenics-dolfin-2018)-builddir)/.markerfile
	cd $($(python-fenics-dolfin-2018)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfin-2018)-builddeps) && \
		PYTHONPATH=$($(python-fenics-dolfin-2018)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-dolfin-2018)-prefix)
	@touch $@

$($(python-fenics-dolfin-2018)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-dolfin-2018)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-dolfin-2018)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-dolfin-2018)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-dolfin-2018)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-dolfin-2018)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-dolfin-2018)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_DOLFIN_2018_ROOT $($(python-fenics-dolfin-2018)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-dolfin-2018)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-dolfin-2018)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-dolfin-2018)\"" >>$@

$(python-fenics-dolfin-2018)-src: $($(python-fenics-dolfin-2018)-src)
$(python-fenics-dolfin-2018)-unpack: $($(python-fenics-dolfin-2018)-prefix)/.pkgunpack
$(python-fenics-dolfin-2018)-patch: $($(python-fenics-dolfin-2018)-prefix)/.pkgpatch
$(python-fenics-dolfin-2018)-build: $($(python-fenics-dolfin-2018)-prefix)/.pkgbuild
$(python-fenics-dolfin-2018)-check: $($(python-fenics-dolfin-2018)-prefix)/.pkgcheck
$(python-fenics-dolfin-2018)-install: $($(python-fenics-dolfin-2018)-prefix)/.pkginstall
$(python-fenics-dolfin-2018)-modulefile: $($(python-fenics-dolfin-2018)-modulefile)
$(python-fenics-dolfin-2018)-clean:
	rm -rf $($(python-fenics-dolfin-2018)-modulefile)
	rm -rf $($(python-fenics-dolfin-2018)-prefix)
	rm -rf $($(python-fenics-dolfin-2018)-srcdir)
$(python-fenics-dolfin-2018): $(python-fenics-dolfin-2018)-src $(python-fenics-dolfin-2018)-unpack $(python-fenics-dolfin-2018)-patch $(python-fenics-dolfin-2018)-build $(python-fenics-dolfin-2018)-check $(python-fenics-dolfin-2018)-install $(python-fenics-dolfin-2018)-modulefile
