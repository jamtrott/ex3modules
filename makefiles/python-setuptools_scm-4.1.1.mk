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
# python-setuptools_scm-4.1.1

python-setuptools_scm-version = 4.1.1
python-setuptools_scm = python-setuptools_scm-$(python-setuptools_scm-version)
$(python-setuptools_scm)-description = Managing Python package versions in SCM metadata
$(python-setuptools_scm)-url = https://github.com/pypa/setuptools_scm
$(python-setuptools_scm)-srcurl = https://files.pythonhosted.org/packages/e2/22/3c318bc7123014e032cd4c2ae90e030a5c9f864cd733aca0c991da2c978b/setuptools_scm-4.1.1.tar.gz
$(python-setuptools_scm)-src = $(pkgsrcdir)/$(notdir $($(python-setuptools_scm)-srcurl))
$(python-setuptools_scm)-srcdir = $(pkgsrcdir)/$(python-setuptools_scm)
$(python-setuptools_scm)-builddeps = $(python) $(python-setuptools)
$(python-setuptools_scm)-prereqs = $(python)  $(python-setuptools)
$(python-setuptools_scm)-modulefile = $(modulefilesdir)/$(python-setuptools_scm)
$(python-setuptools_scm)-prefix = $(pkgdir)/$(python-setuptools_scm)
$(python-setuptools_scm)-site-packages = $($(python-setuptools_scm)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-setuptools_scm)-src): $(dir $($(python-setuptools_scm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-setuptools_scm)-srcurl)

$($(python-setuptools_scm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-setuptools_scm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-setuptools_scm)-prefix)/.pkgunpack: $$($(python-setuptools_scm)-src) $($(python-setuptools_scm)-srcdir)/.markerfile $($(python-setuptools_scm)-prefix)/.markerfile $$(foreach dep,$$($(python-setuptools_scm)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-setuptools_scm)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-setuptools_scm)-prefix)/.pkgpatch: $($(python-setuptools_scm)-prefix)/.pkgunpack
	@touch $@

$($(python-setuptools_scm)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-setuptools_scm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools_scm)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools_scm)-prefix)/.pkgpatch
	cd $($(python-setuptools_scm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools_scm)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-setuptools_scm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-setuptools_scm)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-setuptools_scm)-prefix)/.pkgbuild
	cd $($(python-setuptools_scm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools_scm)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-setuptools_scm)-prefix)/.pkginstall: $($(python-setuptools_scm)-prefix)/.pkgcheck $($(python-setuptools_scm)-site-packages)/.markerfile
	cd $($(python-setuptools_scm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-setuptools_scm)-builddeps) && \
		PYTHONPATH=$($(python-setuptools_scm)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-setuptools_scm)-prefix)
	@touch $@

$($(python-setuptools_scm)-modulefile): $(modulefilesdir)/.markerfile $($(python-setuptools_scm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-setuptools_scm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-setuptools_scm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-setuptools_scm)-description)\"" >>$@
	echo "module-whatis \"$($(python-setuptools_scm)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-setuptools_scm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SETUPTOOLS_SCM_ROOT $($(python-setuptools_scm)-prefix)" >>$@
	echo "prepend-path PATH $($(python-setuptools_scm)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-setuptools_scm)-site-packages)" >>$@
	echo "set MSG \"$(python-setuptools_scm)\"" >>$@

$(python-setuptools_scm)-src: $($(python-setuptools_scm)-src)
$(python-setuptools_scm)-unpack: $($(python-setuptools_scm)-prefix)/.pkgunpack
$(python-setuptools_scm)-patch: $($(python-setuptools_scm)-prefix)/.pkgpatch
$(python-setuptools_scm)-build: $($(python-setuptools_scm)-prefix)/.pkgbuild
$(python-setuptools_scm)-check: $($(python-setuptools_scm)-prefix)/.pkgcheck
$(python-setuptools_scm)-install: $($(python-setuptools_scm)-prefix)/.pkginstall
$(python-setuptools_scm)-modulefile: $($(python-setuptools_scm)-modulefile)
$(python-setuptools_scm)-clean:
	rm -rf $($(python-setuptools_scm)-modulefile)
	rm -rf $($(python-setuptools_scm)-prefix)
	rm -rf $($(python-setuptools_scm)-srcdir)
	rm -rf $($(python-setuptools_scm)-src)
$(python-setuptools_scm): $(python-setuptools_scm)-src $(python-setuptools_scm)-unpack $(python-setuptools_scm)-patch $(python-setuptools_scm)-build $(python-setuptools_scm)-check $(python-setuptools_scm)-install $(python-setuptools_scm)-modulefile
