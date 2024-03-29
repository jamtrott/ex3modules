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
# python-pytest-cov-2.12.1

python-pytest-cov-version = 2.12.1
python-pytest-cov = python-pytest-cov-$(python-pytest-cov-version)
$(python-pytest-cov)-description = Pytest plugin for measuring coverage
$(python-pytest-cov)-url = https://github.com/pytest-dev/pytest-cov/
$(python-pytest-cov)-srcurl = https://files.pythonhosted.org/packages/63/3a/747e953051fd6eb5fb297907a825aad43d94c556d3b9938fc21f3172879f/pytest-cov-2.12.1.tar.gz
$(python-pytest-cov)-src = $(pkgsrcdir)/$(notdir $($(python-pytest-cov)-srcurl))
$(python-pytest-cov)-srcdir = $(pkgsrcdir)/$(python-pytest-cov)
$(python-pytest-cov)-builddeps = $(python) $(python-pytest) $(python-importlib_metadata) $(python-zipp) $(python-attrs) $(python-six) $(python-more-itertools) $(python-wcwidth) $(python-py) $(python-pluggy) $(python-packaging) $(python-atomicwrites) $(python-coverage) $(python-wheel) $(python-pip)
$(python-pytest-cov)-prereqs = $(python) $(python-pytest) $(python-importlib_metadata) $(python-zipp) $(python-attrs) $(python-six) $(python-more-itertools) $(python-wcwidth) $(python-py) $(python-pluggy) $(python-packaging) $(python-atomicwrites) $(python-coverage)
$(python-pytest-cov)-modulefile = $(modulefilesdir)/$(python-pytest-cov)
$(python-pytest-cov)-prefix = $(pkgdir)/$(python-pytest-cov)
$(python-pytest-cov)-site-packages = $($(python-pytest-cov)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pytest-cov)-src): $(dir $($(python-pytest-cov)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pytest-cov)-srcurl)

$($(python-pytest-cov)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytest-cov)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytest-cov)-prefix)/.pkgunpack: $$($(python-pytest-cov)-src) $($(python-pytest-cov)-srcdir)/.markerfile $($(python-pytest-cov)-prefix)/.markerfile $$(foreach dep,$$($(python-pytest-cov)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pytest-cov)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pytest-cov)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-cov)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-cov)-prefix)/.pkgunpack
	@touch $@

$($(python-pytest-cov)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pytest-cov)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-cov)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-cov)-prefix)/.pkgpatch
	cd $($(python-pytest-cov)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-cov)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pytest-cov)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-cov)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-cov)-prefix)/.pkgbuild
	cd $($(python-pytest-cov)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-cov)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-pytest-cov)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-cov)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-cov)-prefix)/.pkgcheck $($(python-pytest-cov)-site-packages)/.markerfile
	cd $($(python-pytest-cov)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-cov)-builddeps) && \
		PYTHONPATH=$($(python-pytest-cov)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-pytest-cov)-prefix)
	@touch $@

$($(python-pytest-cov)-modulefile): $(modulefilesdir)/.markerfile $($(python-pytest-cov)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pytest-cov)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pytest-cov)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pytest-cov)-description)\"" >>$@
	echo "module-whatis \"$($(python-pytest-cov)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pytest-cov)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYTEST_COV_ROOT $($(python-pytest-cov)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pytest-cov)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pytest-cov)-site-packages)" >>$@
	echo "set MSG \"$(python-pytest-cov)\"" >>$@

$(python-pytest-cov)-src: $($(python-pytest-cov)-src)
$(python-pytest-cov)-unpack: $($(python-pytest-cov)-prefix)/.pkgunpack
$(python-pytest-cov)-patch: $($(python-pytest-cov)-prefix)/.pkgpatch
$(python-pytest-cov)-build: $($(python-pytest-cov)-prefix)/.pkgbuild
$(python-pytest-cov)-check: $($(python-pytest-cov)-prefix)/.pkgcheck
$(python-pytest-cov)-install: $($(python-pytest-cov)-prefix)/.pkginstall
$(python-pytest-cov)-modulefile: $($(python-pytest-cov)-modulefile)
$(python-pytest-cov)-clean:
	rm -rf $($(python-pytest-cov)-modulefile)
	rm -rf $($(python-pytest-cov)-prefix)
	rm -rf $($(python-pytest-cov)-srcdir)
	rm -rf $($(python-pytest-cov)-src)
$(python-pytest-cov): $(python-pytest-cov)-src $(python-pytest-cov)-unpack $(python-pytest-cov)-patch $(python-pytest-cov)-build $(python-pytest-cov)-check $(python-pytest-cov)-install $(python-pytest-cov)-modulefile
