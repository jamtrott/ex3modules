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
# python-pytest-6.1.1

python-pytest-version = 6.1.1
python-pytest = python-pytest-$(python-pytest-version)
$(python-pytest)-description = Python testing framework
$(python-pytest)-url = https://docs.pytest.org/
$(python-pytest)-srcurl = https://files.pythonhosted.org/packages/c8/a7/b3bdcc52e6143c056e5a42fa1b3e73abc11927c6c58e1667884559d7ddee/pytest-6.1.1.tar.gz
$(python-pytest)-src = $(pkgsrcdir)/$(notdir $($(python-pytest)-srcurl))
$(python-pytest)-srcdir = $(pkgsrcdir)/$(python-pytest)
$(python-pytest)-builddeps = $(python) $(python-atomicwrites) $(python-pluggy) $(python-wcwidth) $(python-importlib_metadata) $(python-packaging) $(python-py) $(python-more-itertools) $(python-attrs) $(python-zipp) $(python-pyparsing) $(python-six) $(python-toml) $(python-iniconfig) $(python-pip) $(python-wheel) $(python-setuptools) $(python-pip)
$(python-pytest)-prereqs = $(python) $(python-atomicwrites) $(python-pluggy) $(python-wcwidth) $(python-importlib_metadata) $(python-packaging) $(python-py) $(python-more-itertools) $(python-attrs) $(python-zipp) $(python-pyparsing) $(python-six) $(python-toml) $(python-iniconfig)
$(python-pytest)-modulefile = $(modulefilesdir)/$(python-pytest)
$(python-pytest)-prefix = $(pkgdir)/$(python-pytest)
$(python-pytest)-site-packages = $($(python-pytest)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pytest)-src): $(dir $($(python-pytest)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pytest)-srcurl)

$($(python-pytest)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytest)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytest)-prefix)/.pkgunpack: $$($(python-pytest)-src) $($(python-pytest)-srcdir)/.markerfile $($(python-pytest)-prefix)/.markerfile $$(foreach dep,$$($(python-pytest)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pytest)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pytest)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest)-prefix)/.pkgunpack
	@touch $@

$($(python-pytest)-site-packages)/.markerfile:
	$(INSTALL) -d  $(dir $@)
	@touch $@

$($(python-pytest)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest)-prefix)/.pkgpatch
	cd $($(python-pytest)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pytest)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest)-prefix)/.pkgbuild
	cd $($(python-pytest)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-pytest)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest)-prefix)/.pkgcheck $($(python-pytest)-site-packages)/.markerfile
	cd $($(python-pytest)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest)-builddeps) && \
		PYTHONPATH=$($(python-pytest)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-pytest)-prefix)
	@touch $@

$($(python-pytest)-modulefile): $(modulefilesdir)/.markerfile $($(python-pytest)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pytest)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pytest)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pytest)-description)\"" >>$@
	echo "module-whatis \"$($(python-pytest)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pytest)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYTEST_ROOT $($(python-pytest)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pytest)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pytest)-site-packages)" >>$@
	echo "set MSG \"$(python-pytest)\"" >>$@

$(python-pytest)-src: $($(python-pytest)-src)
$(python-pytest)-unpack: $($(python-pytest)-prefix)/.pkgunpack
$(python-pytest)-patch: $($(python-pytest)-prefix)/.pkgpatch
$(python-pytest)-build: $($(python-pytest)-prefix)/.pkgbuild
$(python-pytest)-check: $($(python-pytest)-prefix)/.pkgcheck
$(python-pytest)-install: $($(python-pytest)-prefix)/.pkginstall
$(python-pytest)-modulefile: $($(python-pytest)-modulefile)
$(python-pytest)-clean:
	rm -rf $($(python-pytest)-modulefile)
	rm -rf $($(python-pytest)-prefix)
	rm -rf $($(python-pytest)-srcdir)
	rm -rf $($(python-pytest)-src)
$(python-pytest): $(python-pytest)-src $(python-pytest)-unpack $(python-pytest)-patch $(python-pytest)-build $(python-pytest)-check $(python-pytest)-install $(python-pytest)-modulefile
