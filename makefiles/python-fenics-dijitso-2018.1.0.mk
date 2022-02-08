# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-fenics-dijitso-2018.1.0

python-fenics-dijitso-2018-version = 2018.1.0
python-fenics-dijitso-2018 = python-fenics-dijitso-$(python-fenics-dijitso-2018-version)
$(python-fenics-dijitso-2018)-description = FEniCS Project: Distributed just-in-time compilation
$(python-fenics-dijitso-2018)-url = https://bitbucket.org/fenics-project/dijitso/
$(python-fenics-dijitso-2018)-srcurl = https://files.pythonhosted.org/packages/c4/a2/44d9062b392c1f42533e3afc32a74cd6c1fc48a14ee793a74a4231ff55dd/fenics-dijitso-2018.1.0.tar.gz
$(python-fenics-dijitso-2018)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-dijitso-2018)-srcurl))
$(python-fenics-dijitso-2018)-srcdir = $(pkgsrcdir)/$(python-fenics-dijitso-2018)
$(python-fenics-dijitso-2018)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-pip)
$(python-fenics-dijitso-2018)-prereqs = $(python) $(python-numpy)
$(python-fenics-dijitso-2018)-modulefile = $(modulefilesdir)/$(python-fenics-dijitso-2018)
$(python-fenics-dijitso-2018)-prefix = $(pkgdir)/$(python-fenics-dijitso-2018)
$(python-fenics-dijitso-2018)-site-packages = $($(python-fenics-dijitso-2018)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-dijitso-2018)-src): $(dir $($(python-fenics-dijitso-2018)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-dijitso-2018)-srcurl)

$($(python-fenics-dijitso-2018)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dijitso-2018)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dijitso-2018)-prefix)/.pkgunpack: $$($(python-fenics-dijitso-2018)-src) $($(python-fenics-dijitso-2018)-srcdir)/.markerfile $($(python-fenics-dijitso-2018)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-dijitso-2018)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-dijitso-2018)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-dijitso-2018)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dijitso-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dijitso-2018)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-dijitso-2018)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dijitso-2018)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dijitso-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dijitso-2018)-prefix)/.pkgpatch
	cd $($(python-fenics-dijitso-2018)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dijitso-2018)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-dijitso-2018)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dijitso-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dijitso-2018)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-dijitso-2018)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dijitso-2018)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dijitso-2018)-prefix)/.pkgcheck $($(python-fenics-dijitso-2018)-site-packages)/.markerfile
	cd $($(python-fenics-dijitso-2018)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dijitso-2018)-builddeps) && \
		PYTHONPATH=$($(python-fenics-dijitso-2018)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-dijitso-2018)-prefix)
	@touch $@

$($(python-fenics-dijitso-2018)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-dijitso-2018)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-dijitso-2018)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-dijitso-2018)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-dijitso-2018)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-dijitso-2018)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-dijitso-2018)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_DIJITSO_2018_ROOT $($(python-fenics-dijitso-2018)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-dijitso-2018)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-dijitso-2018)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-dijitso-2018)\"" >>$@

$(python-fenics-dijitso-2018)-src: $($(python-fenics-dijitso-2018)-src)
$(python-fenics-dijitso-2018)-unpack: $($(python-fenics-dijitso-2018)-prefix)/.pkgunpack
$(python-fenics-dijitso-2018)-patch: $($(python-fenics-dijitso-2018)-prefix)/.pkgpatch
$(python-fenics-dijitso-2018)-build: $($(python-fenics-dijitso-2018)-prefix)/.pkgbuild
$(python-fenics-dijitso-2018)-check: $($(python-fenics-dijitso-2018)-prefix)/.pkgcheck
$(python-fenics-dijitso-2018)-install: $($(python-fenics-dijitso-2018)-prefix)/.pkginstall
$(python-fenics-dijitso-2018)-modulefile: $($(python-fenics-dijitso-2018)-modulefile)
$(python-fenics-dijitso-2018)-clean:
	rm -rf $($(python-fenics-dijitso-2018)-modulefile)
	rm -rf $($(python-fenics-dijitso-2018)-prefix)
	rm -rf $($(python-fenics-dijitso-2018)-srcdir)
	rm -rf $($(python-fenics-dijitso-2018)-src)
$(python-fenics-dijitso-2018): $(python-fenics-dijitso-2018)-src $(python-fenics-dijitso-2018)-unpack $(python-fenics-dijitso-2018)-patch $(python-fenics-dijitso-2018)-build $(python-fenics-dijitso-2018)-check $(python-fenics-dijitso-2018)-install $(python-fenics-dijitso-2018)-modulefile
