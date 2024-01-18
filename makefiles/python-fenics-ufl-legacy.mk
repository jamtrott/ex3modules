# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# python-fenics-ufl-legacy.1.0

python-fenics-ufl-legacy-version = 2022.3.0
python-fenics-ufl-legacy = python-fenics-ufl-$(python-fenics-ufl-legacy-version)
$(python-fenics-ufl-legacy)-description = FEniCS Project: Unified Form Language
$(python-fenics-ufl-legacy)-url = https://github.com/FEniCS/ufl-legacy
$(python-fenics-ufl-legacy)-srcurl = https://github.com/FEniCS/ufl-legacy/archive/refs/tags/2022.3.0.zip
$(python-fenics-ufl-legacy)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-ufl-legacy)-srcurl))
$(python-fenics-ufl-legacy)-srcdir = $(pkgsrcdir)/$(python-fenics-ufl-legacy)
$(python-fenics-ufl-legacy)-builddir = $($(python-fenics-ufl-legacy)-srcdir)/ufl-2022.3.0
$(python-fenics-ufl-legacy)-builddeps = $(python) $(python-numpy) $(python-cffi) $(python-setuptools) $(python-wheel) $(python-pip)
$(python-fenics-ufl-legacy)-prereqs = $(python) $(python-numpy)
$(python-fenics-ufl-legacy)-modulefile = $(modulefilesdir)/$(python-fenics-ufl-legacy)
$(python-fenics-ufl-legacy)-prefix = $(pkgdir)/$(python-fenics-ufl-legacy)
$(python-fenics-ufl-legacy)-site-packages = $($(python-fenics-ufl-legacy)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-ufl-legacy)-src): $(dir $($(python-fenics-ufl-legacy)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ufl-legacy)-srcurl)

$($(python-fenics-ufl-legacy)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-ufl-legacy)-builddir),$($(python-fenics-ufl-legacy)-srcdir))
$($(python-fenics-ufl-legacy)-builddir)/.markerfile: $($(python-fenics-ufl-legacy)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-ufl-legacy)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-legacy)-prefix)/.pkgunpack: $$($(python-fenics-ufl-legacy)-src) $($(python-fenics-ufl-legacy)-srcdir)/.markerfile $($(python-fenics-ufl-legacy)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-legacy)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(python-fenics-ufl-legacy)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-ufl-legacy)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-legacy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-legacy)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ufl-legacy)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ufl-legacy)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-legacy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-legacy)-prefix)/.pkgpatch
	cd $($(python-fenics-ufl-legacy)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-legacy)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-ufl-legacy)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-legacy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-legacy)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-ufl-legacy)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-legacy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-legacy)-prefix)/.pkgcheck $($(python-fenics-ufl-legacy)-site-packages)/.markerfile
	cd $($(python-fenics-ufl-legacy)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-legacy)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ufl-legacy)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-ufl-legacy)-prefix)
	@touch $@

$($(python-fenics-ufl-legacy)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ufl-legacy)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ufl-legacy)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ufl-legacy)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-legacy)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-legacy)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ufl-legacy)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_UFL_2021_ROOT $($(python-fenics-ufl-legacy)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ufl-legacy)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ufl-legacy)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ufl-legacy)\"" >>$@

$(python-fenics-ufl-legacy)-src: $($(python-fenics-ufl-legacy)-src)
$(python-fenics-ufl-legacy)-unpack: $($(python-fenics-ufl-legacy)-prefix)/.pkgunpack
$(python-fenics-ufl-legacy)-patch: $($(python-fenics-ufl-legacy)-prefix)/.pkgpatch
$(python-fenics-ufl-legacy)-build: $($(python-fenics-ufl-legacy)-prefix)/.pkgbuild
$(python-fenics-ufl-legacy)-check: $($(python-fenics-ufl-legacy)-prefix)/.pkgcheck
$(python-fenics-ufl-legacy)-install: $($(python-fenics-ufl-legacy)-prefix)/.pkginstall
$(python-fenics-ufl-legacy)-modulefile: $($(python-fenics-ufl-legacy)-modulefile)
$(python-fenics-ufl-legacy)-clean:
	rm -rf $($(python-fenics-ufl-legacy)-modulefile)
	rm -rf $($(python-fenics-ufl-legacy)-prefix)
	rm -rf $($(python-fenics-ufl-legacy)-builddir)
	rm -rf $($(python-fenics-ufl-legacy)-srcdir)
	rm -rf $($(python-fenics-ufl-legacy)-src)
$(python-fenics-ufl-legacy): $(python-fenics-ufl-legacy)-src $(python-fenics-ufl-legacy)-unpack $(python-fenics-ufl-legacy)-patch $(python-fenics-ufl-legacy)-build $(python-fenics-ufl-legacy)-check $(python-fenics-ufl-legacy)-install $(python-fenics-ufl-legacy)-modulefile
