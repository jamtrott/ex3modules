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
# python-fenics-fiat-2019.1.0

python-fenics-fiat-2019-version = 2019.1.0
python-fenics-fiat-2019 = python-fenics-fiat-$(python-fenics-fiat-2019-version)
$(python-fenics-fiat-2019)-description = FEniCS Project: FInite element Automatic Tabulator
$(python-fenics-fiat-2019)-url = https://bitbucket.org/fenics-project/fiat/
$(python-fenics-fiat-2019)-srcurl = https://files.pythonhosted.org/packages/df/3d/4fa91f26cd1cfccb40ce5516ea79cfe193e0ce4f11b9b8e4f24999d2a4cf/fenics-fiat-2019.1.0.tar.gz
$(python-fenics-fiat-2019)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-fiat-2019)-srcurl))
$(python-fenics-fiat-2019)-srcdir = $(pkgsrcdir)/$(python-fenics-fiat-2019)
$(python-fenics-fiat-2019)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpmath) $(python-sympy-1.4)
$(python-fenics-fiat-2019)-prereqs = $(python) $(python-numpy) $(python-mpmath) $(python-sympy-1.4)
$(python-fenics-fiat-2019)-modulefile = $(modulefilesdir)/$(python-fenics-fiat-2019)
$(python-fenics-fiat-2019)-prefix = $(pkgdir)/$(python-fenics-fiat-2019)
$(python-fenics-fiat-2019)-site-packages = $($(python-fenics-fiat-2019)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-fenics-fiat-2019)-src): $(dir $($(python-fenics-fiat-2019)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-fiat-2019)-srcurl)

$($(python-fenics-fiat-2019)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-fenics-fiat-2019)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-fenics-fiat-2019)-prefix)/.pkgunpack: $$($(python-fenics-fiat-2019)-src) $($(python-fenics-fiat-2019)-srcdir)/.markerfile $($(python-fenics-fiat-2019)-prefix)/.markerfile
	tar -C $($(python-fenics-fiat-2019)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-fiat-2019)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-fiat-2019)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-fenics-fiat-2019)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019)-prefix)/.pkgpatch
	cd $($(python-fenics-fiat-2019)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-2019)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-fiat-2019)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-fiat-2019)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019)-prefix)/.pkgcheck $($(python-fenics-fiat-2019)-site-packages)/.markerfile
	cd $($(python-fenics-fiat-2019)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-2019)-builddeps) && \
		PYTHONPATH=$($(python-fenics-fiat-2019)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-fiat-2019)-prefix)
	@touch $@

$($(python-fenics-fiat-2019)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-fiat-2019)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-fiat-2019)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-fiat-2019)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-2019)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-2019)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-fiat-2019)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_FIAT_2019_ROOT $($(python-fenics-fiat-2019)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-fiat-2019)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-fiat-2019)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-fiat-2019)\"" >>$@

$(python-fenics-fiat-2019)-src: $($(python-fenics-fiat-2019)-src)
$(python-fenics-fiat-2019)-unpack: $($(python-fenics-fiat-2019)-prefix)/.pkgunpack
$(python-fenics-fiat-2019)-patch: $($(python-fenics-fiat-2019)-prefix)/.pkgpatch
$(python-fenics-fiat-2019)-build: $($(python-fenics-fiat-2019)-prefix)/.pkgbuild
$(python-fenics-fiat-2019)-check: $($(python-fenics-fiat-2019)-prefix)/.pkgcheck
$(python-fenics-fiat-2019)-install: $($(python-fenics-fiat-2019)-prefix)/.pkginstall
$(python-fenics-fiat-2019)-modulefile: $($(python-fenics-fiat-2019)-modulefile)
$(python-fenics-fiat-2019)-clean:
	rm -rf $($(python-fenics-fiat-2019)-modulefile)
	rm -rf $($(python-fenics-fiat-2019)-prefix)
	rm -rf $($(python-fenics-fiat-2019)-srcdir)
	rm -rf $($(python-fenics-fiat-2019)-src)
$(python-fenics-fiat-2019): $(python-fenics-fiat-2019)-src $(python-fenics-fiat-2019)-unpack $(python-fenics-fiat-2019)-patch $(python-fenics-fiat-2019)-build $(python-fenics-fiat-2019)-check $(python-fenics-fiat-2019)-install $(python-fenics-fiat-2019)-modulefile
