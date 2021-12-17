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
# python-more-itertools-8.3.0

python-more-itertools-version = 8.3.0
python-more-itertools = python-more-itertools-$(python-more-itertools-version)
$(python-more-itertools)-description = More routines for operating on iterables, beyond itertools
$(python-more-itertools)-url = https://github.com/more-itertools/more-itertools/
$(python-more-itertools)-srcurl = https://files.pythonhosted.org/packages/16/e8/b371710ad458e56b6c74b82352fdf1625e75c03511c66a75314f1084f057/more-itertools-8.3.0.tar.gz
$(python-more-itertools)-src = $(pkgsrcdir)/$(notdir $($(python-more-itertools)-srcurl))
$(python-more-itertools)-srcdir = $(pkgsrcdir)/$(python-more-itertools)
$(python-more-itertools)-builddeps = $(python) $(python-setuptools)
$(python-more-itertools)-prereqs = $(python)
$(python-more-itertools)-modulefile = $(modulefilesdir)/$(python-more-itertools)
$(python-more-itertools)-prefix = $(pkgdir)/$(python-more-itertools)
$(python-more-itertools)-site-packages = $($(python-more-itertools)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-more-itertools)-src): $(dir $($(python-more-itertools)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-more-itertools)-srcurl)

$($(python-more-itertools)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-more-itertools)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-more-itertools)-prefix)/.pkgunpack: $$($(python-more-itertools)-src) $($(python-more-itertools)-srcdir)/.markerfile $($(python-more-itertools)-prefix)/.markerfile $$(foreach dep,$$($(python-more-itertools)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-more-itertools)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-more-itertools)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-more-itertools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-more-itertools)-prefix)/.pkgunpack
	@touch $@

$($(python-more-itertools)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-more-itertools)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-more-itertools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-more-itertools)-prefix)/.pkgpatch
	cd $($(python-more-itertools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-more-itertools)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-more-itertools)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-more-itertools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-more-itertools)-prefix)/.pkgbuild
	cd $($(python-more-itertools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-more-itertools)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-more-itertools)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-more-itertools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-more-itertools)-prefix)/.pkgcheck $($(python-more-itertools)-site-packages)/.markerfile
	cd $($(python-more-itertools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-more-itertools)-builddeps) && \
		PYTHONPATH=$($(python-more-itertools)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-more-itertools)-prefix)
	@touch $@

$($(python-more-itertools)-modulefile): $(modulefilesdir)/.markerfile $($(python-more-itertools)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-more-itertools)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-more-itertools)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-more-itertools)-description)\"" >>$@
	echo "module-whatis \"$($(python-more-itertools)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-more-itertools)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MORE_ITERTOOLS_ROOT $($(python-more-itertools)-prefix)" >>$@
	echo "prepend-path PATH $($(python-more-itertools)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-more-itertools)-site-packages)" >>$@
	echo "set MSG \"$(python-more-itertools)\"" >>$@

$(python-more-itertools)-src: $($(python-more-itertools)-src)
$(python-more-itertools)-unpack: $($(python-more-itertools)-prefix)/.pkgunpack
$(python-more-itertools)-patch: $($(python-more-itertools)-prefix)/.pkgpatch
$(python-more-itertools)-build: $($(python-more-itertools)-prefix)/.pkgbuild
$(python-more-itertools)-check: $($(python-more-itertools)-prefix)/.pkgcheck
$(python-more-itertools)-install: $($(python-more-itertools)-prefix)/.pkginstall
$(python-more-itertools)-modulefile: $($(python-more-itertools)-modulefile)
$(python-more-itertools)-clean:
	rm -rf $($(python-more-itertools)-modulefile)
	rm -rf $($(python-more-itertools)-prefix)
	rm -rf $($(python-more-itertools)-srcdir)
	rm -rf $($(python-more-itertools)-src)
$(python-more-itertools): $(python-more-itertools)-src $(python-more-itertools)-unpack $(python-more-itertools)-patch $(python-more-itertools)-build $(python-more-itertools)-check $(python-more-itertools)-install $(python-more-itertools)-modulefile
