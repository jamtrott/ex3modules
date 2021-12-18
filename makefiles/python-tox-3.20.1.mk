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
# python-tox-3.20.1

python-tox-version = 3.20.1
python-tox = python-tox-$(python-tox-version)
$(python-tox)-description = Generic virtualenv management and test command line tool
$(python-tox)-url = http://tox.readthedocs.org/
$(python-tox)-srcurl = https://files.pythonhosted.org/packages/fe/66/7206a6c69a5f717fb80cd3a532c0639bc183ad2aa1f23a943ca93b0814bd/tox-3.20.1.tar.gz
$(python-tox)-src = $(pkgsrcdir)/$(notdir $($(python-tox)-srcurl))
$(python-tox)-srcdir = $(pkgsrcdir)/$(python-tox)
$(python-tox)-builddeps = $(python) $(python-filelock) $(python-packaging) $(python-pluggy) $(python-py) $(python-six) $(python-toml) $(python-virtualenv) $(python-colorama) $(python-importlib-metadata) $(python-pathlib2) $(python-pytest) $(python-flaky)
$(python-tox)-prereqs = $(python) $(python-filelock) $(python-packaging) $(python-pluggy) $(python-py) $(python-six) $(python-toml) $(python-virtualenv) $(python-colorama) $(python-importlib-metadata)
$(python-tox)-modulefile = $(modulefilesdir)/$(python-tox)
$(python-tox)-prefix = $(pkgdir)/$(python-tox)
$(python-tox)-site-packages = $($(python-tox)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-tox)-src): $(dir $($(python-tox)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-tox)-srcurl)

$($(python-tox)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tox)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tox)-prefix)/.pkgunpack: $$($(python-tox)-src) $($(python-tox)-srcdir)/.markerfile $($(python-tox)-prefix)/.markerfile $$(foreach dep,$$($(python-tox)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-tox)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-tox)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tox)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tox)-prefix)/.pkgunpack
	@touch $@

$($(python-tox)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-tox)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tox)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tox)-prefix)/.pkgpatch
	cd $($(python-tox)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tox)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-tox)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tox)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tox)-prefix)/.pkgbuild
	cd $($(python-tox)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tox)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-tox)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tox)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tox)-prefix)/.pkgcheck $($(python-tox)-site-packages)/.markerfile
	cd $($(python-tox)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tox)-builddeps) && \
		PYTHONPATH=$($(python-tox)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-tox)-prefix)
	@touch $@

$($(python-tox)-modulefile): $(modulefilesdir)/.markerfile $($(python-tox)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-tox)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-tox)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-tox)-description)\"" >>$@
	echo "module-whatis \"$($(python-tox)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-tox)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TOX_ROOT $($(python-tox)-prefix)" >>$@
	echo "prepend-path PATH $($(python-tox)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-tox)-site-packages)" >>$@
	echo "set MSG \"$(python-tox)\"" >>$@

$(python-tox)-src: $($(python-tox)-src)
$(python-tox)-unpack: $($(python-tox)-prefix)/.pkgunpack
$(python-tox)-patch: $($(python-tox)-prefix)/.pkgpatch
$(python-tox)-build: $($(python-tox)-prefix)/.pkgbuild
$(python-tox)-check: $($(python-tox)-prefix)/.pkgcheck
$(python-tox)-install: $($(python-tox)-prefix)/.pkginstall
$(python-tox)-modulefile: $($(python-tox)-modulefile)
$(python-tox)-clean:
	rm -rf $($(python-tox)-modulefile)
	rm -rf $($(python-tox)-prefix)
	rm -rf $($(python-tox)-srcdir)
	rm -rf $($(python-tox)-src)
$(python-tox): $(python-tox)-src $(python-tox)-unpack $(python-tox)-patch $(python-tox)-build $(python-tox)-check $(python-tox)-install $(python-tox)-modulefile
