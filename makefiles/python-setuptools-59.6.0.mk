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
# python-setuptools-59.6.0

python-setuptools-version = 59.6.0
python-setuptools = python-setuptools-$(python-setuptools-version)
$(python-setuptools)-description = Easily download, build, install, upgrade, and uninstall Python packages
$(python-setuptools)-url = https://github.com/pypa/setuptools/
$(python-setuptools)-srcurl = https://files.pythonhosted.org/packages/6a/fa/5ec0fa9095c9b72cb1c31a8175c4c6745bf5927d1045d7a70df35d54944f/setuptools-59.6.0.tar.gz
$(python-setuptools)-src = $(pkgsrcdir)/python-setuptools-$(notdir $($(python-setuptools)-srcurl))
$(python-setuptools)-srcdir = $(pkgsrcdir)/$(python-setuptools)
$(python-setuptools)-builddeps = $(python)
$(python-setuptools)-prereqs = $(python)
$(python-setuptools)-modulefile = $(modulefilesdir)/$(python-setuptools)
$(python-setuptools)-prefix = $(pkgdir)/$(python-setuptools)
$(python-setuptools)-site-packages = $($(python-setuptools)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-setuptools)-src): $(dir $($(python-setuptools)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-setuptools)-srcurl)

$($(python-setuptools)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-setuptools)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-setuptools)-prefix)/.pkgunpack: $$($(python-setuptools)-src) $($(python-setuptools)-srcdir)/.markerfile $($(python-setuptools)-prefix)/.markerfile $$(foreach dep,$$($(python-setuptools)-builddeps),$(modulefilesdir)/$$(dep))
	$(INSTALL) -d $(dir $@) && tar -C $($(python-setuptools)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-setuptools)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools)-prefix)/.pkgunpack
	@touch $@

$($(python-setuptools)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-setuptools)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools)-prefix)/.pkgpatch
	cd $($(python-setuptools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-setuptools)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools)-prefix)/.pkgbuild
	# Disable tests, because python-pytest has not been built yet.
	# cd $($(python-setuptools)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-setuptools)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-setuptools)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools)-prefix)/.pkgcheck $($(python-setuptools)-site-packages)/.markerfile
	cd $($(python-setuptools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools)-builddeps) && \
		PYTHONPATH=$($(python-setuptools)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-setuptools)-prefix)
	@touch $@

$($(python-setuptools)-modulefile): $(modulefilesdir)/.markerfile $($(python-setuptools)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-setuptools)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-setuptools)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-setuptools)-description)\"" >>$@
	echo "module-whatis \"$($(python-setuptools)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-setuptools)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SETUPTOOLS_ROOT $($(python-setuptools)-prefix)" >>$@
	echo "prepend-path PATH $($(python-setuptools)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-setuptools)-site-packages)" >>$@
	echo "set MSG \"$(python-setuptools)\"" >>$@

$(python-setuptools)-src: $($(python-setuptools)-src)
$(python-setuptools)-unpack: $($(python-setuptools)-prefix)/.pkgunpack
$(python-setuptools)-patch: $($(python-setuptools)-prefix)/.pkgpatch
$(python-setuptools)-build: $($(python-setuptools)-prefix)/.pkgbuild
$(python-setuptools)-check: $($(python-setuptools)-prefix)/.pkgcheck
$(python-setuptools)-install: $($(python-setuptools)-prefix)/.pkginstall
$(python-setuptools)-modulefile: $($(python-setuptools)-modulefile)
$(python-setuptools)-clean:
	rm -rf $($(python-setuptools)-modulefile)
	rm -rf $($(python-setuptools)-prefix)
	rm -rf $($(python-setuptools)-srcdir)
	rm -rf $($(python-setuptools)-src)
$(python-setuptools): $(python-setuptools)-src $(python-setuptools)-unpack $(python-setuptools)-patch $(python-setuptools)-build $(python-setuptools)-check $(python-setuptools)-install $(python-setuptools)-modulefile
