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
# python-pytest-forked-1.1.3

python-pytest-forked-version = 1.1.3
python-pytest-forked = python-pytest-forked-$(python-pytest-forked-version)
$(python-pytest-forked)-description = Run tests in isolated forked subprocesses
$(python-pytest-forked)-url = https://github.com/pytest-dev/pytest-forked
$(python-pytest-forked)-srcurl = https://files.pythonhosted.org/packages/43/b4/d0efa1748880e24aaaf8343825138ed5460b8e260e84ac73ef4415e1d1d4/pytest-forked-1.1.3.tar.gz
$(python-pytest-forked)-src = $(pkgsrcdir)/$(notdir $($(python-pytest-forked)-srcurl))
$(python-pytest-forked)-srcdir = $(pkgsrcdir)/$(python-pytest-forked)
$(python-pytest-forked)-builddeps = $(python) $(python-pytest) $(python-atomicwrites) $(python-pluggy) $(python-wcwidth) $(python-importlib_metadata) $(python-packaging) $(python-py) $(python-more-itertools) $(python-attrs) $(python-zipp) $(python-pyparsing) $(python-six)
$(python-pytest-forked)-prereqs = $(python) $(python-pytest) $(python-atomicwrites) $(python-pluggy) $(python-wcwidth) $(python-importlib_metadata) $(python-packaging) $(python-py) $(python-more-itertools) $(python-attrs) $(python-zipp) $(python-pyparsing) $(python-six)
$(python-pytest-forked)-modulefile = $(modulefilesdir)/$(python-pytest-forked)
$(python-pytest-forked)-prefix = $(pkgdir)/$(python-pytest-forked)
$(python-pytest-forked)-site-packages = $($(python-pytest-forked)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pytest-forked)-src): $(dir $($(python-pytest-forked)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pytest-forked)-srcurl)

$($(python-pytest-forked)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytest-forked)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytest-forked)-prefix)/.pkgunpack: $$($(python-pytest-forked)-src) $($(python-pytest-forked)-srcdir)/.markerfile $($(python-pytest-forked)-prefix)/.markerfile $$(foreach dep,$$($(python-pytest-forked)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pytest-forked)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pytest-forked)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-forked)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-forked)-prefix)/.pkgunpack
	@touch $@

$($(python-pytest-forked)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pytest-forked)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-forked)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-forked)-prefix)/.pkgpatch
	cd $($(python-pytest-forked)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-forked)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pytest-forked)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-forked)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-forked)-prefix)/.pkgbuild
	cd $($(python-pytest-forked)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-forked)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pytest-forked)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-forked)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-forked)-prefix)/.pkgcheck $($(python-pytest-forked)-site-packages)/.markerfile
	cd $($(python-pytest-forked)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-forked)-builddeps) && \
		PYTHONPATH=$($(python-pytest-forked)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pytest-forked)-prefix)
	@touch $@

$($(python-pytest-forked)-modulefile): $(modulefilesdir)/.markerfile $($(python-pytest-forked)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pytest-forked)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pytest-forked)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pytest-forked)-description)\"" >>$@
	echo "module-whatis \"$($(python-pytest-forked)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pytest-forked)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYTEST_FORKED_ROOT $($(python-pytest-forked)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pytest-forked)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pytest-forked)-site-packages)" >>$@
	echo "set MSG \"$(python-pytest-forked)\"" >>$@

$(python-pytest-forked)-src: $($(python-pytest-forked)-src)
$(python-pytest-forked)-unpack: $($(python-pytest-forked)-prefix)/.pkgunpack
$(python-pytest-forked)-patch: $($(python-pytest-forked)-prefix)/.pkgpatch
$(python-pytest-forked)-build: $($(python-pytest-forked)-prefix)/.pkgbuild
$(python-pytest-forked)-check: $($(python-pytest-forked)-prefix)/.pkgcheck
$(python-pytest-forked)-install: $($(python-pytest-forked)-prefix)/.pkginstall
$(python-pytest-forked)-modulefile: $($(python-pytest-forked)-modulefile)
$(python-pytest-forked)-clean:
	rm -rf $($(python-pytest-forked)-modulefile)
	rm -rf $($(python-pytest-forked)-prefix)
	rm -rf $($(python-pytest-forked)-srcdir)
	rm -rf $($(python-pytest-forked)-src)
$(python-pytest-forked): $(python-pytest-forked)-src $(python-pytest-forked)-unpack $(python-pytest-forked)-patch $(python-pytest-forked)-build $(python-pytest-forked)-check $(python-pytest-forked)-install $(python-pytest-forked)-modulefile
