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
# python-fenics-ufl-2018.1.0

python-fenics-ufl-2018-version = 2018.1.0
python-fenics-ufl-2018 = python-fenics-ufl-$(python-fenics-ufl-2018-version)
$(python-fenics-ufl-2018)-description = FEniCS Project: Unified Form Language
$(python-fenics-ufl-2018)-url = https://bitbucket.org/fenics-project/ufl/
$(python-fenics-ufl-2018)-srcurl = https://files.pythonhosted.org/packages/ec/ff/4de14f0e30f570b6d46439ae35907f36384c73498e2d56691d33a18672ae/fenics-ufl-2018.1.0.tar.gz
$(python-fenics-ufl-2018)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-ufl-2018)-srcurl))
$(python-fenics-ufl-2018)-srcdir = $(pkgsrcdir)/$(python-fenics-ufl-2018)
$(python-fenics-ufl-2018)-builddeps = $(python) $(blas) $(mpi) $(python-numpy)
$(python-fenics-ufl-2018)-prereqs = $(python) $(python-numpy)
$(python-fenics-ufl-2018)-modulefile = $(modulefilesdir)/$(python-fenics-ufl-2018)
$(python-fenics-ufl-2018)-prefix = $(pkgdir)/$(python-fenics-ufl-2018)
$(python-fenics-ufl-2018)-site-packages = $($(python-fenics-ufl-2018)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-ufl-2018)-src): $(dir $($(python-fenics-ufl-2018)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ufl-2018)-srcurl)

$($(python-fenics-ufl-2018)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-2018)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-2018)-prefix)/.pkgunpack: $$($(python-fenics-ufl-2018)-src) $($(python-fenics-ufl-2018)-srcdir)/.markerfile $($(python-fenics-ufl-2018)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2018)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-ufl-2018)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-ufl-2018)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2018)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ufl-2018)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ufl-2018)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2018)-prefix)/.pkgpatch
	cd $($(python-fenics-ufl-2018)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2018)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-ufl-2018)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2018)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-ufl-2018)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2018)-prefix)/.pkgcheck $($(python-fenics-ufl-2018)-site-packages)/.markerfile
	cd $($(python-fenics-ufl-2018)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2018)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ufl-2018)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-fenics-ufl-2018)-prefix)
	@touch $@

$($(python-fenics-ufl-2018)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ufl-2018)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ufl-2018)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ufl-2018)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2018)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2018)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ufl-2018)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_UFL_2018_ROOT $($(python-fenics-ufl-2018)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ufl-2018)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ufl-2018)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ufl-2018)\"" >>$@

$(python-fenics-ufl-2018)-src: $($(python-fenics-ufl-2018)-src)
$(python-fenics-ufl-2018)-unpack: $($(python-fenics-ufl-2018)-prefix)/.pkgunpack
$(python-fenics-ufl-2018)-patch: $($(python-fenics-ufl-2018)-prefix)/.pkgpatch
$(python-fenics-ufl-2018)-build: $($(python-fenics-ufl-2018)-prefix)/.pkgbuild
$(python-fenics-ufl-2018)-check: $($(python-fenics-ufl-2018)-prefix)/.pkgcheck
$(python-fenics-ufl-2018)-install: $($(python-fenics-ufl-2018)-prefix)/.pkginstall
$(python-fenics-ufl-2018)-modulefile: $($(python-fenics-ufl-2018)-modulefile)
$(python-fenics-ufl-2018)-clean:
	rm -rf $($(python-fenics-ufl-2018)-modulefile)
	rm -rf $($(python-fenics-ufl-2018)-prefix)
	rm -rf $($(python-fenics-ufl-2018)-srcdir)
	rm -rf $($(python-fenics-ufl-2018)-src)
$(python-fenics-ufl-2018): $(python-fenics-ufl-2018)-src $(python-fenics-ufl-2018)-unpack $(python-fenics-ufl-2018)-patch $(python-fenics-ufl-2018)-build $(python-fenics-ufl-2018)-check $(python-fenics-ufl-2018)-install $(python-fenics-ufl-2018)-modulefile
