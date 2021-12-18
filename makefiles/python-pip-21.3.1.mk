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
# python-pip-21.3.1

python-pip-version = 21.3.1
python-pip = python-pip-$(python-pip-version)
$(python-pip)-description = Package installer for Python
$(python-pip)-url = https://pip.pypa.io/
$(python-pip)-srcurl = https://files.pythonhosted.org/packages/da/f6/c83229dcc3635cdeb51874184241a9508ada15d8baa337a41093fab58011/pip-21.3.1.tar.gz
$(python-pip)-src = $(pkgsrcdir)/$(notdir $($(python-pip)-srcurl))
$(python-pip)-srcdir = $(pkgsrcdir)/$(python-pip)
$(python-pip)-builddeps = $(python) $(python-setuptools)
$(python-pip)-prereqs = $(python)
$(python-pip)-modulefile = $(modulefilesdir)/$(python-pip)
$(python-pip)-prefix = $(pkgdir)/$(python-pip)
$(python-pip)-site-packages = $($(python-pip)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pip)-src): $(dir $($(python-pip)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pip)-srcurl)

$($(python-pip)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pip)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pip)-prefix)/.pkgunpack: $$($(python-pip)-src) $($(python-pip)-srcdir)/.markerfile $($(python-pip)-prefix)/.markerfile $$(foreach dep,$$($(python-pip)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pip)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pip)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pip)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pip)-prefix)/.pkgunpack
	@touch $@

$($(python-pip)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pip)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pip)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pip)-prefix)/.pkgpatch
	cd $($(python-pip)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pip)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pip)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pip)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pip)-prefix)/.pkgbuild
	cd $($(python-pip)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pip)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-pip)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pip)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pip)-prefix)/.pkgcheck $($(python-pip)-site-packages)/.markerfile
	cd $($(python-pip)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pip)-builddeps) && \
		PYTHONPATH=$($(python-pip)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-pip)-prefix)
	@touch $@

$($(python-pip)-modulefile): $(modulefilesdir)/.markerfile $($(python-pip)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pip)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pip)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pip)-description)\"" >>$@
	echo "module-whatis \"$($(python-pip)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pip)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PIP_ROOT $($(python-pip)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pip)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pip)-site-packages)" >>$@
	echo "set MSG \"$(python-pip)\"" >>$@

$(python-pip)-src: $($(python-pip)-src)
$(python-pip)-unpack: $($(python-pip)-prefix)/.pkgunpack
$(python-pip)-patch: $($(python-pip)-prefix)/.pkgpatch
$(python-pip)-build: $($(python-pip)-prefix)/.pkgbuild
$(python-pip)-check: $($(python-pip)-prefix)/.pkgcheck
$(python-pip)-install: $($(python-pip)-prefix)/.pkginstall
$(python-pip)-modulefile: $($(python-pip)-modulefile)
$(python-pip)-clean:
	rm -rf $($(python-pip)-modulefile)
	rm -rf $($(python-pip)-prefix)
	rm -rf $($(python-pip)-srcdir)
	rm -rf $($(python-pip)-src)
$(python-pip): $(python-pip)-src $(python-pip)-unpack $(python-pip)-patch $(python-pip)-build $(python-pip)-check $(python-pip)-install $(python-pip)-modulefile
