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
# python-virtualenv-20.0.35

python-virtualenv-version = 20.0.35
python-virtualenv = python-virtualenv-$(python-virtualenv-version)
$(python-virtualenv)-description = Virtual Python Environment builder
$(python-virtualenv)-url = https://virtualenv.pypa.io/
$(python-virtualenv)-srcurl = https://files.pythonhosted.org/packages/28/a8/96e411bfe45092f8aeebc5c154b2f0892bd9ea462d6934b534c1ce7b7402/virtualenv-20.0.35.tar.gz
$(python-virtualenv)-src = $(pkgsrcdir)/$(notdir $($(python-virtualenv)-srcurl))
$(python-virtualenv)-srcdir = $(pkgsrcdir)/$(python-virtualenv)
$(python-virtualenv)-builddeps = $(python) $(python-setuptools) $(python-setuptools_scm) $(python-importlib_metadata) $(python-six) $(python-filelock) $(python-distlib) $(python-appdirs) $(python-zipp) $(python-wheel) $(python-pip)
$(python-virtualenv)-prereqs = $(python) $(python-importlib_metadata) $(python-six) $(python-filelock) $(python-distlib) $(python-appdirs) $(python-zipp)
$(python-virtualenv)-modulefile = $(modulefilesdir)/$(python-virtualenv)
$(python-virtualenv)-prefix = $(pkgdir)/$(python-virtualenv)
$(python-virtualenv)-site-packages = $($(python-virtualenv)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-virtualenv)-src): $(dir $($(python-virtualenv)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-virtualenv)-srcurl)

$($(python-virtualenv)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-virtualenv)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-virtualenv)-prefix)/.pkgunpack: $$($(python-virtualenv)-src) $($(python-virtualenv)-srcdir)/.markerfile $($(python-virtualenv)-prefix)/.markerfile $$(foreach dep,$$($(python-virtualenv)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-virtualenv)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-virtualenv)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-virtualenv)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-virtualenv)-prefix)/.pkgunpack
	@touch $@

$($(python-virtualenv)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-virtualenv)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-virtualenv)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-virtualenv)-prefix)/.pkgpatch
	cd $($(python-virtualenv)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-virtualenv)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-virtualenv)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-virtualenv)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-virtualenv)-prefix)/.pkgbuild
	cd $($(python-virtualenv)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-virtualenv)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-virtualenv)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-virtualenv)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-virtualenv)-prefix)/.pkgcheck $($(python-virtualenv)-site-packages)/.markerfile
	cd $($(python-virtualenv)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-virtualenv)-builddeps) && \
		PYTHONPATH=$($(python-virtualenv)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-virtualenv)-prefix)
	@touch $@

$($(python-virtualenv)-modulefile): $(modulefilesdir)/.markerfile $($(python-virtualenv)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-virtualenv)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-virtualenv)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-virtualenv)-description)\"" >>$@
	echo "module-whatis \"$($(python-virtualenv)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-virtualenv)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_VIRTUALENV_ROOT $($(python-virtualenv)-prefix)" >>$@
	echo "prepend-path PATH $($(python-virtualenv)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-virtualenv)-site-packages)" >>$@
	echo "set MSG \"$(python-virtualenv)\"" >>$@

$(python-virtualenv)-src: $($(python-virtualenv)-src)
$(python-virtualenv)-unpack: $($(python-virtualenv)-prefix)/.pkgunpack
$(python-virtualenv)-patch: $($(python-virtualenv)-prefix)/.pkgpatch
$(python-virtualenv)-build: $($(python-virtualenv)-prefix)/.pkgbuild
$(python-virtualenv)-check: $($(python-virtualenv)-prefix)/.pkgcheck
$(python-virtualenv)-install: $($(python-virtualenv)-prefix)/.pkginstall
$(python-virtualenv)-modulefile: $($(python-virtualenv)-modulefile)
$(python-virtualenv)-clean:
	rm -rf $($(python-virtualenv)-modulefile)
	rm -rf $($(python-virtualenv)-prefix)
	rm -rf $($(python-virtualenv)-srcdir)
	rm -rf $($(python-virtualenv)-src)
$(python-virtualenv): $(python-virtualenv)-src $(python-virtualenv)-unpack $(python-virtualenv)-patch $(python-virtualenv)-build $(python-virtualenv)-check $(python-virtualenv)-install $(python-virtualenv)-modulefile
