# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# python-setuptools-47.1.1

python-setuptools-47.1.1-version = 47.1.1
python-setuptools-47.1.1 = python-setuptools-$(python-setuptools-47.1.1-version)
$(python-setuptools-47.1.1)-description = Easily download, build, install, upgrade, and uninstall Python packages
$(python-setuptools-47.1.1)-url = https://github.com/pypa/setuptools/
$(python-setuptools-47.1.1)-srcurl = https://github.com/pypa/setuptools/archive/v$(python-setuptools-47.1.1-version).tar.gz
$(python-setuptools-47.1.1)-src = $(pkgsrcdir)/python-setuptools-$(notdir $($(python-setuptools-47.1.1)-srcurl))
$(python-setuptools-47.1.1)-srcdir = $(pkgsrcdir)/$(python-setuptools-47.1.1)
$(python-setuptools-47.1.1)-builddeps = $(python)
$(python-setuptools-47.1.1)-prereqs = $(python)
$(python-setuptools-47.1.1)-modulefile = $(modulefilesdir)/$(python-setuptools-47.1.1)
$(python-setuptools-47.1.1)-prefix = $(pkgdir)/$(python-setuptools-47.1.1)
$(python-setuptools-47.1.1)-site-packages = $($(python-setuptools-47.1.1)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-setuptools-47.1.1)-src): $(dir $($(python-setuptools-47.1.1)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-setuptools-47.1.1)-srcurl)

$($(python-setuptools-47.1.1)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-setuptools-47.1.1)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-setuptools-47.1.1)-prefix)/.pkgunpack: $$($(python-setuptools-47.1.1)-src) $($(python-setuptools-47.1.1)-srcdir)/.markerfile $($(python-setuptools-47.1.1)-prefix)/.markerfile $$(foreach dep,$$($(python-setuptools-47.1.1)-builddeps),$(modulefilesdir)/$$(dep))
	$(INSTALL) -d $(dir $@) && tar -C $($(python-setuptools-47.1.1)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-setuptools-47.1.1)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools-47.1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools-47.1.1)-prefix)/.pkgunpack
	@touch $@

$($(python-setuptools-47.1.1)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-setuptools-47.1.1)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools-47.1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools-47.1.1)-prefix)/.pkgpatch
	cd $($(python-setuptools-47.1.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools-47.1.1)-builddeps) && \
		$(PYTHON) bootstrap.py && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-setuptools-47.1.1)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools-47.1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools-47.1.1)-prefix)/.pkgbuild
#	 Disable tests, because python-pytest has not been built yet.
#	 cd $($(python-setuptools-47.1.1)-srcdir) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(python-setuptools-47.1.1)-builddeps) && \
#	 	$(PYTHON) setup.py test
	@touch $@

$($(python-setuptools-47.1.1)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools-47.1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools-47.1.1)-prefix)/.pkgcheck $($(python-setuptools-47.1.1)-site-packages)/.markerfile
	cd $($(python-setuptools-47.1.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools-47.1.1)-builddeps) && \
		PYTHONPATH=$($(python-setuptools-47.1.1)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-setuptools-47.1.1)-prefix)
	@touch $@

$($(python-setuptools-47.1.1)-modulefile): $(modulefilesdir)/.markerfile $($(python-setuptools-47.1.1)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-setuptools-47.1.1)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-setuptools-47.1.1)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-setuptools-47.1.1)-description)\"" >>$@
	echo "module-whatis \"$($(python-setuptools-47.1.1)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-setuptools-47.1.1)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SETUPTOOLS_ROOT $($(python-setuptools-47.1.1)-prefix)" >>$@
	echo "prepend-path PATH $($(python-setuptools-47.1.1)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-setuptools-47.1.1)-site-packages)" >>$@
	echo "set MSG \"$(python-setuptools-47.1.1)\"" >>$@

$(python-setuptools-47.1.1)-src: $($(python-setuptools-47.1.1)-src)
$(python-setuptools-47.1.1)-unpack: $($(python-setuptools-47.1.1)-prefix)/.pkgunpack
$(python-setuptools-47.1.1)-patch: $($(python-setuptools-47.1.1)-prefix)/.pkgpatch
$(python-setuptools-47.1.1)-build: $($(python-setuptools-47.1.1)-prefix)/.pkgbuild
$(python-setuptools-47.1.1)-check: $($(python-setuptools-47.1.1)-prefix)/.pkgcheck
$(python-setuptools-47.1.1)-install: $($(python-setuptools-47.1.1)-prefix)/.pkginstall
$(python-setuptools-47.1.1)-modulefile: $($(python-setuptools-47.1.1)-modulefile)
$(python-setuptools-47.1.1)-clean:
	rm -rf $($(python-setuptools-47.1.1)-modulefile)
	rm -rf $($(python-setuptools-47.1.1)-prefix)
	rm -rf $($(python-setuptools-47.1.1)-srcdir)
	rm -rf $($(python-setuptools-47.1.1)-src)
$(python-setuptools-47.1.1): $(python-setuptools-47.1.1)-src $(python-setuptools-47.1.1)-unpack $(python-setuptools-47.1.1)-patch $(python-setuptools-47.1.1)-build $(python-setuptools-47.1.1)-check $(python-setuptools-47.1.1)-install $(python-setuptools-47.1.1)-modulefile
