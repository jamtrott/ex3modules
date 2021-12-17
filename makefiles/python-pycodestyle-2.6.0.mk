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
# python-pycodestyle-2.6.0

python-pycodestyle-version = 2.6.0
python-pycodestyle = python-pycodestyle-$(python-pycodestyle-version)
$(python-pycodestyle)-description = Python style guide checker
$(python-pycodestyle)-url = https://pycodestyle.readthedocs.io/
$(python-pycodestyle)-srcurl = https://files.pythonhosted.org/packages/bb/82/0df047a5347d607be504ad5faa255caa7919562962b934f9372b157e8a70/pycodestyle-2.6.0.tar.gz
$(python-pycodestyle)-src = $(pkgsrcdir)/$(notdir $($(python-pycodestyle)-srcurl))
$(python-pycodestyle)-srcdir = $(pkgsrcdir)/$(python-pycodestyle)
$(python-pycodestyle)-builddeps = $(python)
$(python-pycodestyle)-prereqs = $(python)
$(python-pycodestyle)-modulefile = $(modulefilesdir)/$(python-pycodestyle)
$(python-pycodestyle)-prefix = $(pkgdir)/$(python-pycodestyle)
$(python-pycodestyle)-site-packages = $($(python-pycodestyle)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pycodestyle)-src): $(dir $($(python-pycodestyle)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pycodestyle)-srcurl)

$($(python-pycodestyle)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pycodestyle)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pycodestyle)-prefix)/.pkgunpack: $$($(python-pycodestyle)-src) $($(python-pycodestyle)-srcdir)/.markerfile $($(python-pycodestyle)-prefix)/.markerfile $$(foreach dep,$$($(python-pycodestyle)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pycodestyle)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pycodestyle)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycodestyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycodestyle)-prefix)/.pkgunpack
	@touch $@

$($(python-pycodestyle)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pycodestyle)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycodestyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycodestyle)-prefix)/.pkgpatch
	cd $($(python-pycodestyle)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pycodestyle)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pycodestyle)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycodestyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycodestyle)-prefix)/.pkgbuild
	@touch $@

$($(python-pycodestyle)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycodestyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycodestyle)-prefix)/.pkgcheck $($(python-pycodestyle)-site-packages)/.markerfile
	cd $($(python-pycodestyle)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pycodestyle)-builddeps) && \
		PYTHONPATH=$($(python-pycodestyle)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-pycodestyle)-prefix)
	@touch $@

$($(python-pycodestyle)-modulefile): $(modulefilesdir)/.markerfile $($(python-pycodestyle)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pycodestyle)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pycodestyle)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pycodestyle)-description)\"" >>$@
	echo "module-whatis \"$($(python-pycodestyle)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pycodestyle)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYCODESTYLE_ROOT $($(python-pycodestyle)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pycodestyle)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pycodestyle)-site-packages)" >>$@
	echo "set MSG \"$(python-pycodestyle)\"" >>$@

$(python-pycodestyle)-src: $($(python-pycodestyle)-src)
$(python-pycodestyle)-unpack: $($(python-pycodestyle)-prefix)/.pkgunpack
$(python-pycodestyle)-patch: $($(python-pycodestyle)-prefix)/.pkgpatch
$(python-pycodestyle)-build: $($(python-pycodestyle)-prefix)/.pkgbuild
$(python-pycodestyle)-check: $($(python-pycodestyle)-prefix)/.pkgcheck
$(python-pycodestyle)-install: $($(python-pycodestyle)-prefix)/.pkginstall
$(python-pycodestyle)-modulefile: $($(python-pycodestyle)-modulefile)
$(python-pycodestyle)-clean:
	rm -rf $($(python-pycodestyle)-modulefile)
	rm -rf $($(python-pycodestyle)-prefix)
	rm -rf $($(python-pycodestyle)-srcdir)
	rm -rf $($(python-pycodestyle)-src)
$(python-pycodestyle): $(python-pycodestyle)-src $(python-pycodestyle)-unpack $(python-pycodestyle)-patch $(python-pycodestyle)-build $(python-pycodestyle)-check $(python-pycodestyle)-install $(python-pycodestyle)-modulefile
