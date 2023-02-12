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
# python-fenics-ufl-2022.2.0

python-fenics-ufl-2022-version = 2022.2.0
python-fenics-ufl-2022 = python-fenics-ufl-$(python-fenics-ufl-2022-version)
$(python-fenics-ufl-2022)-description = FEniCS Project: Unified Form Language
$(python-fenics-ufl-2022)-url = https://github.com/FEniCS/ufl
$(python-fenics-ufl-2022)-srcurl = https://files.pythonhosted.org/packages/30/14/089d7402e3e2b3286dc469badebc6adb2aaae1eafbdc44eee500ac7e9360/fenics-ufl-2022.2.0.tar.gz
$(python-fenics-ufl-2022)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-ufl-2022)-srcurl))
$(python-fenics-ufl-2022)-srcdir = $(pkgsrcdir)/$(python-fenics-ufl-2022)
$(python-fenics-ufl-2022)-builddeps = $(python) $(python-numpy) $(python-cffi) $(python-setuptools) $(python-wheel) $(python-fenics-basix) $(python-fenics-ufl) $(python-numpy) $(python-cffi) $(python-setuptools) $(python-wheel) $(python-fenics-basix) $(python-fenics-ufl) $(python-pip)
$(python-fenics-ufl-2022)-prereqs = $(python) $(python-numpy)
$(python-fenics-ufl-2022)-modulefile = $(modulefilesdir)/$(python-fenics-ufl-2022)
$(python-fenics-ufl-2022)-prefix = $(pkgdir)/$(python-fenics-ufl-2022)
$(python-fenics-ufl-2022)-site-packages = $($(python-fenics-ufl-2022)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-ufl-2022)-src): $(dir $($(python-fenics-ufl-2022)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ufl-2022)-srcurl)

$($(python-fenics-ufl-2022)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-2022)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-2022)-prefix)/.pkgunpack: $$($(python-fenics-ufl-2022)-src) $($(python-fenics-ufl-2022)-srcdir)/.markerfile $($(python-fenics-ufl-2022)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2022)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-ufl-2022)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-ufl-2022)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2022)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2022)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ufl-2022)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ufl-2022)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2022)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2022)-prefix)/.pkgpatch
	cd $($(python-fenics-ufl-2022)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2022)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-ufl-2022)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2022)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2022)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-ufl-2022)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2022)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2022)-prefix)/.pkgcheck $($(python-fenics-ufl-2022)-site-packages)/.markerfile
	cd $($(python-fenics-ufl-2022)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2022)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ufl-2022)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-ufl-2022)-prefix)
	@touch $@

$($(python-fenics-ufl-2022)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ufl-2022)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ufl-2022)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ufl-2022)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2022)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2022)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ufl-2022)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_UFL_2022_ROOT $($(python-fenics-ufl-2022)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ufl-2022)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ufl-2022)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ufl-2022)\"" >>$@

$(python-fenics-ufl-2022)-src: $($(python-fenics-ufl-2022)-src)
$(python-fenics-ufl-2022)-unpack: $($(python-fenics-ufl-2022)-prefix)/.pkgunpack
$(python-fenics-ufl-2022)-patch: $($(python-fenics-ufl-2022)-prefix)/.pkgpatch
$(python-fenics-ufl-2022)-build: $($(python-fenics-ufl-2022)-prefix)/.pkgbuild
$(python-fenics-ufl-2022)-check: $($(python-fenics-ufl-2022)-prefix)/.pkgcheck
$(python-fenics-ufl-2022)-install: $($(python-fenics-ufl-2022)-prefix)/.pkginstall
$(python-fenics-ufl-2022)-modulefile: $($(python-fenics-ufl-2022)-modulefile)
$(python-fenics-ufl-2022)-clean:
	rm -rf $($(python-fenics-ufl-2022)-modulefile)
	rm -rf $($(python-fenics-ufl-2022)-prefix)
	rm -rf $($(python-fenics-ufl-2022)-srcdir)
	rm -rf $($(python-fenics-ufl-2022)-src)
$(python-fenics-ufl-2022): $(python-fenics-ufl-2022)-src $(python-fenics-ufl-2022)-unpack $(python-fenics-ufl-2022)-patch $(python-fenics-ufl-2022)-build $(python-fenics-ufl-2022)-check $(python-fenics-ufl-2022)-install $(python-fenics-ufl-2022)-modulefile
