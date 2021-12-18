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
# python-fenics-fiat-2018.1.0

python-fenics-fiat-2018-version = 2018.1.0
python-fenics-fiat-2018 = python-fenics-fiat-$(python-fenics-fiat-2018-version)
$(python-fenics-fiat-2018)-description = FEniCS Project: FInite element Automatic Tabulator
$(python-fenics-fiat-2018)-url = https://bitbucket.org/fenics-project/fiat/
$(python-fenics-fiat-2018)-srcurl = https://files.pythonhosted.org/packages/68/27/8975b85ff9bf7fed9c81841fe8736e671e6dce9869f79462a833376d9208/fenics-fiat-2018.1.0.tar.gz
$(python-fenics-fiat-2018)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-fiat-2018)-srcurl))
$(python-fenics-fiat-2018)-srcdir = $(pkgsrcdir)/$(python-fenics-fiat-2018)
$(python-fenics-fiat-2018)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpmath) $(python-sympy-1.1)
$(python-fenics-fiat-2018)-prereqs = $(python) $(python-numpy) $(python-mpmath) $(python-sympy-1.1)
$(python-fenics-fiat-2018)-modulefile = $(modulefilesdir)/$(python-fenics-fiat-2018)
$(python-fenics-fiat-2018)-prefix = $(pkgdir)/$(python-fenics-fiat-2018)
$(python-fenics-fiat-2018)-site-packages = $($(python-fenics-fiat-2018)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-fiat-2018)-src): $(dir $($(python-fenics-fiat-2018)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-fiat-2018)-srcurl)

$($(python-fenics-fiat-2018)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-fiat-2018)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-fiat-2018)-prefix)/.pkgunpack: $$($(python-fenics-fiat-2018)-src) $($(python-fenics-fiat-2018)-srcdir)/.markerfile $($(python-fenics-fiat-2018)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2018)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-fiat-2018)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-fiat-2018)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2018)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-fiat-2018)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-fiat-2018)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2018)-prefix)/.pkgpatch
	cd $($(python-fenics-fiat-2018)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-2018)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-fiat-2018)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2018)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-fiat-2018)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2018)-prefix)/.pkgcheck $($(python-fenics-fiat-2018)-site-packages)/.markerfile
	cd $($(python-fenics-fiat-2018)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-2018)-builddeps) && \
		PYTHONPATH=$($(python-fenics-fiat-2018)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-fenics-fiat-2018)-prefix)
	@touch $@

$($(python-fenics-fiat-2018)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-fiat-2018)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-fiat-2018)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-fiat-2018)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-2018)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-2018)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-fiat-2018)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_FIAT_2018_ROOT $($(python-fenics-fiat-2018)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-fiat-2018)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-fiat-2018)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-fiat-2018)\"" >>$@

$(python-fenics-fiat-2018)-src: $($(python-fenics-fiat-2018)-src)
$(python-fenics-fiat-2018)-unpack: $($(python-fenics-fiat-2018)-prefix)/.pkgunpack
$(python-fenics-fiat-2018)-patch: $($(python-fenics-fiat-2018)-prefix)/.pkgpatch
$(python-fenics-fiat-2018)-build: $($(python-fenics-fiat-2018)-prefix)/.pkgbuild
$(python-fenics-fiat-2018)-check: $($(python-fenics-fiat-2018)-prefix)/.pkgcheck
$(python-fenics-fiat-2018)-install: $($(python-fenics-fiat-2018)-prefix)/.pkginstall
$(python-fenics-fiat-2018)-modulefile: $($(python-fenics-fiat-2018)-modulefile)
$(python-fenics-fiat-2018)-clean:
	rm -rf $($(python-fenics-fiat-2018)-modulefile)
	rm -rf $($(python-fenics-fiat-2018)-prefix)
	rm -rf $($(python-fenics-fiat-2018)-srcdir)
	rm -rf $($(python-fenics-fiat-2018)-src)
$(python-fenics-fiat-2018): $(python-fenics-fiat-2018)-src $(python-fenics-fiat-2018)-unpack $(python-fenics-fiat-2018)-patch $(python-fenics-fiat-2018)-build $(python-fenics-fiat-2018)-check $(python-fenics-fiat-2018)-install $(python-fenics-fiat-2018)-modulefile
