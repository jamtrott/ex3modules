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
# python-pytest-xdist-1.32.0

python-pytest-xdist-version = 1.32.0
python-pytest-xdist = python-pytest-xdist-$(python-pytest-xdist-version)
$(python-pytest-xdist)-description = pytest xdist plugin for distributed testing and loop-on-failing modes
$(python-pytest-xdist)-url = https://github.com/pytest-dev/pytest-xdist/
$(python-pytest-xdist)-srcurl = https://files.pythonhosted.org/packages/2f/4c/906cd21f4ca1afed6636de0a40d1ffdd64e8b6990223f0c2dd094cf8396a/pytest-xdist-1.32.0.tar.gz
$(python-pytest-xdist)-src = $(pkgsrcdir)/$(notdir $($(python-pytest-xdist)-srcurl))
$(python-pytest-xdist)-srcdir = $(pkgsrcdir)/$(python-pytest-xdist)
$(python-pytest-xdist)-builddeps = $(python) $(python-six) $(python-pytest-forked) $(python-pytest) $(python-execnet) $(python-wcwidth) $(python-py) $(python-pluggy) $(python-packaging) $(python-more-itertools) $(python-importlib_metadata) $(python-attrs) $(python-apipkg) $(python-pyparsing) $(python-zipp)
$(python-pytest-xdist)-prereqs = $(python) $(python-six) $(python-pytest-forked) $(python-pytest) $(python-execnet) $(python-wcwidth) $(python-py) $(python-pluggy) $(python-packaging) $(python-more-itertools) $(python-importlib_metadata) $(python-attrs) $(python-apipkg) $(python-pyparsing) $(python-zipp)
$(python-pytest-xdist)-modulefile = $(modulefilesdir)/$(python-pytest-xdist)
$(python-pytest-xdist)-prefix = $(pkgdir)/$(python-pytest-xdist)
$(python-pytest-xdist)-site-packages = $($(python-pytest-xdist)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pytest-xdist)-src): $(dir $($(python-pytest-xdist)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pytest-xdist)-srcurl)

$($(python-pytest-xdist)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-pytest-xdist)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-pytest-xdist)-prefix)/.pkgunpack: $$($(python-pytest-xdist)-src) $($(python-pytest-xdist)-srcdir)/.markerfile $($(python-pytest-xdist)-prefix)/.markerfile
	tar -C $($(python-pytest-xdist)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pytest-xdist)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-xdist)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-xdist)-prefix)/.pkgunpack
	@touch $@

$($(python-pytest-xdist)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-pytest-xdist)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-xdist)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-xdist)-prefix)/.pkgpatch
	cd $($(python-pytest-xdist)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-xdist)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pytest-xdist)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-xdist)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-xdist)-prefix)/.pkgbuild
	cd $($(python-pytest-xdist)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-xdist)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pytest-xdist)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytest-xdist)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytest-xdist)-prefix)/.pkgcheck $($(python-pytest-xdist)-site-packages)/.markerfile
	cd $($(python-pytest-xdist)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytest-xdist)-builddeps) && \
		PYTHONPATH=$($(python-pytest-xdist)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pytest-xdist)-prefix)
	@touch $@

$($(python-pytest-xdist)-modulefile): $(modulefilesdir)/.markerfile $($(python-pytest-xdist)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pytest-xdist)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pytest-xdist)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pytest-xdist)-description)\"" >>$@
	echo "module-whatis \"$($(python-pytest-xdist)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pytest-xdist)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYTEST_XDIST_ROOT $($(python-pytest-xdist)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pytest-xdist)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pytest-xdist)-site-packages)" >>$@
	echo "set MSG \"$(python-pytest-xdist)\"" >>$@

$(python-pytest-xdist)-src: $($(python-pytest-xdist)-src)
$(python-pytest-xdist)-unpack: $($(python-pytest-xdist)-prefix)/.pkgunpack
$(python-pytest-xdist)-patch: $($(python-pytest-xdist)-prefix)/.pkgpatch
$(python-pytest-xdist)-build: $($(python-pytest-xdist)-prefix)/.pkgbuild
$(python-pytest-xdist)-check: $($(python-pytest-xdist)-prefix)/.pkgcheck
$(python-pytest-xdist)-install: $($(python-pytest-xdist)-prefix)/.pkginstall
$(python-pytest-xdist)-modulefile: $($(python-pytest-xdist)-modulefile)
$(python-pytest-xdist)-clean:
	rm -rf $($(python-pytest-xdist)-modulefile)
	rm -rf $($(python-pytest-xdist)-prefix)
	rm -rf $($(python-pytest-xdist)-srcdir)
	rm -rf $($(python-pytest-xdist)-src)
$(python-pytest-xdist): $(python-pytest-xdist)-src $(python-pytest-xdist)-unpack $(python-pytest-xdist)-patch $(python-pytest-xdist)-build $(python-pytest-xdist)-check $(python-pytest-xdist)-install $(python-pytest-xdist)-modulefile
