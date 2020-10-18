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
# python-flake8-3.8.2

python-flake8-version = 3.8.2
python-flake8 = python-flake8-$(python-flake8-version)
$(python-flake8)-description = Python source code checker
$(python-flake8)-url = https://gitlab.com/pycqa/flake8
$(python-flake8)-srcurl = https://files.pythonhosted.org/packages/10/b1/ef9620afac4a8794e631e54bbcd2f70257dee04693ea8fd959d57b89714e/flake8-$(python-flake8-version).tar.gz
$(python-flake8)-src = $(pkgsrcdir)/$(notdir $($(python-flake8)-srcurl))
$(python-flake8)-srcdir = $(pkgsrcdir)/$(python-flake8)
$(python-flake8)-builddeps = $(python) $(python-importlib_metadata) $(python-pyflakes) $(python-pycodestyle) $(python-mccabe)
$(python-flake8)-prereqs = $(python) $(python-importlib_metadata) $(python-pyflakes) $(python-pycodestyle) $(python-mccabe)
$(python-flake8)-modulefile = $(modulefilesdir)/$(python-flake8)
$(python-flake8)-prefix = $(pkgdir)/$(python-flake8)
$(python-flake8)-site-packages = $($(python-flake8)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-flake8)-src): $(dir $($(python-flake8)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-flake8)-srcurl)

$($(python-flake8)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-flake8)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-flake8)-prefix)/.pkgunpack: $$($(python-flake8)-src) $($(python-flake8)-srcdir)/.markerfile $($(python-flake8)-prefix)/.markerfile
	tar -C $($(python-flake8)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-flake8)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flake8)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flake8)-prefix)/.pkgunpack
	@touch $@

$($(python-flake8)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-flake8)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flake8)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flake8)-prefix)/.pkgpatch
	cd $($(python-flake8)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-flake8)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-flake8)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flake8)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flake8)-prefix)/.pkgbuild
	cd $($(python-flake8)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-flake8)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-flake8)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flake8)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flake8)-prefix)/.pkgcheck $($(python-flake8)-site-packages)/.markerfile
	cd $($(python-flake8)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-flake8)-builddeps) && \
		PYTHONPATH=$($(python-flake8)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-flake8)-prefix)
	@touch $@

$($(python-flake8)-modulefile): $(modulefilesdir)/.markerfile $($(python-flake8)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-flake8)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-flake8)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-flake8)-description)\"" >>$@
	echo "module-whatis \"$($(python-flake8)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-flake8)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FLAKE8_ROOT $($(python-flake8)-prefix)" >>$@
	echo "prepend-path PATH $($(python-flake8)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-flake8)-site-packages)" >>$@
	echo "set MSG \"$(python-flake8)\"" >>$@

$(python-flake8)-src: $($(python-flake8)-src)
$(python-flake8)-unpack: $($(python-flake8)-prefix)/.pkgunpack
$(python-flake8)-patch: $($(python-flake8)-prefix)/.pkgpatch
$(python-flake8)-build: $($(python-flake8)-prefix)/.pkgbuild
$(python-flake8)-check: $($(python-flake8)-prefix)/.pkgcheck
$(python-flake8)-install: $($(python-flake8)-prefix)/.pkginstall
$(python-flake8)-modulefile: $($(python-flake8)-modulefile)
$(python-flake8)-clean:
	rm -rf $($(python-flake8)-modulefile)
	rm -rf $($(python-flake8)-prefix)
	rm -rf $($(python-flake8)-srcdir)
	rm -rf $($(python-flake8)-src)
$(python-flake8): $(python-flake8)-src $(python-flake8)-unpack $(python-flake8)-patch $(python-flake8)-build $(python-flake8)-check $(python-flake8)-install $(python-flake8)-modulefile
