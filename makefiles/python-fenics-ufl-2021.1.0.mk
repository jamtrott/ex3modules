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
# python-fenics-ufl-2021.1.0

python-fenics-ufl-2021-version = 2021.1.0
python-fenics-ufl-2021 = python-fenics-ufl-$(python-fenics-ufl-2021-version)
$(python-fenics-ufl-2021)-description = FEniCS Project: Unified Form Language
$(python-fenics-ufl-2021)-url = https://github.com/FEniCS/ufl
$(python-fenics-ufl-2021)-srcurl = https://github.com/FEniCS/ufl/archive/1cf2c90ffa4a3329c5b74ad0cc030aee83c24a06.zip
$(python-fenics-ufl-2021)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-ufl-2021)-srcurl))
$(python-fenics-ufl-2021)-srcdir = $(pkgsrcdir)/$(python-fenics-ufl-2021)
$(python-fenics-ufl-2021)-builddir = $($(python-fenics-ufl-2021)-srcdir)/ufl-1cf2c90ffa4a3329c5b74ad0cc030aee83c24a06
$(python-fenics-ufl-2021)-builddeps = $(python) $(python-numpy) $(python-cffi) $(python-setuptools) $(python-wheel) $(python-pip)
$(python-fenics-ufl-2021)-prereqs = $(python) $(python-numpy)
$(python-fenics-ufl-2021)-modulefile = $(modulefilesdir)/$(python-fenics-ufl-2021)
$(python-fenics-ufl-2021)-prefix = $(pkgdir)/$(python-fenics-ufl-2021)
$(python-fenics-ufl-2021)-site-packages = $($(python-fenics-ufl-2021)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-ufl-2021)-src): $(dir $($(python-fenics-ufl-2021)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ufl-2021)-srcurl)

$($(python-fenics-ufl-2021)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-ufl-2021)-builddir),$($(python-fenics-ufl-2021)-srcdir))
$($(python-fenics-ufl-2021)-builddir)/.markerfile: $($(python-fenics-ufl-2021)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-ufl-2021)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-2021)-prefix)/.pkgunpack: $$($(python-fenics-ufl-2021)-src) $($(python-fenics-ufl-2021)-srcdir)/.markerfile $($(python-fenics-ufl-2021)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(python-fenics-ufl-2021)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-ufl-2021)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ufl-2021)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ufl-2021)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021)-prefix)/.pkgpatch
	cd $($(python-fenics-ufl-2021)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2021)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-ufl-2021)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-ufl-2021)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021)-prefix)/.pkgcheck $($(python-fenics-ufl-2021)-site-packages)/.markerfile
	cd $($(python-fenics-ufl-2021)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2021)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ufl-2021)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-ufl-2021)-prefix)
	@touch $@

$($(python-fenics-ufl-2021)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ufl-2021)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ufl-2021)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ufl-2021)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2021)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2021)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ufl-2021)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_UFL_2021_ROOT $($(python-fenics-ufl-2021)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ufl-2021)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ufl-2021)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ufl-2021)\"" >>$@

$(python-fenics-ufl-2021)-src: $($(python-fenics-ufl-2021)-src)
$(python-fenics-ufl-2021)-unpack: $($(python-fenics-ufl-2021)-prefix)/.pkgunpack
$(python-fenics-ufl-2021)-patch: $($(python-fenics-ufl-2021)-prefix)/.pkgpatch
$(python-fenics-ufl-2021)-build: $($(python-fenics-ufl-2021)-prefix)/.pkgbuild
$(python-fenics-ufl-2021)-check: $($(python-fenics-ufl-2021)-prefix)/.pkgcheck
$(python-fenics-ufl-2021)-install: $($(python-fenics-ufl-2021)-prefix)/.pkginstall
$(python-fenics-ufl-2021)-modulefile: $($(python-fenics-ufl-2021)-modulefile)
$(python-fenics-ufl-2021)-clean:
	rm -rf $($(python-fenics-ufl-2021)-modulefile)
	rm -rf $($(python-fenics-ufl-2021)-prefix)
	rm -rf $($(python-fenics-ufl-2021)-builddir)
	rm -rf $($(python-fenics-ufl-2021)-srcdir)
	rm -rf $($(python-fenics-ufl-2021)-src)
$(python-fenics-ufl-2021): $(python-fenics-ufl-2021)-src $(python-fenics-ufl-2021)-unpack $(python-fenics-ufl-2021)-patch $(python-fenics-ufl-2021)-build $(python-fenics-ufl-2021)-check $(python-fenics-ufl-2021)-install $(python-fenics-ufl-2021)-modulefile
