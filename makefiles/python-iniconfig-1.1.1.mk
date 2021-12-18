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
# python-iniconfig-1.1.1

python-iniconfig-version = 1.1.1
python-iniconfig = python-iniconfig-$(python-iniconfig-version)
$(python-iniconfig)-description = Parsing of ini files
$(python-iniconfig)-url = http://github.com/RonnyPfannschmidt/iniconfig/
$(python-iniconfig)-srcurl = https://files.pythonhosted.org/packages/23/a2/97899f6bd0e873fed3a7e67ae8d3a08b21799430fb4da15cfedf10d6e2c2/iniconfig-1.1.1.tar.gz
$(python-iniconfig)-src = $(pkgsrcdir)/$(notdir $($(python-iniconfig)-srcurl))
$(python-iniconfig)-srcdir = $(pkgsrcdir)/$(python-iniconfig)
$(python-iniconfig)-builddeps = $(python) $(python-wheel)
$(python-iniconfig)-prereqs = $(python)
$(python-iniconfig)-modulefile = $(modulefilesdir)/$(python-iniconfig)
$(python-iniconfig)-prefix = $(pkgdir)/$(python-iniconfig)
$(python-iniconfig)-site-packages = $($(python-iniconfig)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-iniconfig)-src): $(dir $($(python-iniconfig)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-iniconfig)-srcurl)

$($(python-iniconfig)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-iniconfig)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-iniconfig)-prefix)/.pkgunpack: $$($(python-iniconfig)-src) $($(python-iniconfig)-srcdir)/.markerfile $($(python-iniconfig)-prefix)/.markerfile $$(foreach dep,$$($(python-iniconfig)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-iniconfig)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-iniconfig)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-iniconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-iniconfig)-prefix)/.pkgunpack
	@touch $@

$($(python-iniconfig)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-iniconfig)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-iniconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-iniconfig)-prefix)/.pkgpatch
	cd $($(python-iniconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-iniconfig)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-iniconfig)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-iniconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-iniconfig)-prefix)/.pkgbuild
	cd $($(python-iniconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-iniconfig)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-iniconfig)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-iniconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-iniconfig)-prefix)/.pkgcheck $($(python-iniconfig)-site-packages)/.markerfile
	cd $($(python-iniconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-iniconfig)-builddeps) && \
		PYTHONPATH=$($(python-iniconfig)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-iniconfig)-prefix)
	@touch $@

$($(python-iniconfig)-modulefile): $(modulefilesdir)/.markerfile $($(python-iniconfig)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-iniconfig)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-iniconfig)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-iniconfig)-description)\"" >>$@
	echo "module-whatis \"$($(python-iniconfig)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-iniconfig)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_INICONFIG_ROOT $($(python-iniconfig)-prefix)" >>$@
	echo "prepend-path PATH $($(python-iniconfig)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-iniconfig)-site-packages)" >>$@
	echo "set MSG \"$(python-iniconfig)\"" >>$@

$(python-iniconfig)-src: $($(python-iniconfig)-src)
$(python-iniconfig)-unpack: $($(python-iniconfig)-prefix)/.pkgunpack
$(python-iniconfig)-patch: $($(python-iniconfig)-prefix)/.pkgpatch
$(python-iniconfig)-build: $($(python-iniconfig)-prefix)/.pkgbuild
$(python-iniconfig)-check: $($(python-iniconfig)-prefix)/.pkgcheck
$(python-iniconfig)-install: $($(python-iniconfig)-prefix)/.pkginstall
$(python-iniconfig)-modulefile: $($(python-iniconfig)-modulefile)
$(python-iniconfig)-clean:
	rm -rf $($(python-iniconfig)-modulefile)
	rm -rf $($(python-iniconfig)-prefix)
	rm -rf $($(python-iniconfig)-srcdir)
	rm -rf $($(python-iniconfig)-src)
$(python-iniconfig): $(python-iniconfig)-src $(python-iniconfig)-unpack $(python-iniconfig)-patch $(python-iniconfig)-build $(python-iniconfig)-check $(python-iniconfig)-install $(python-iniconfig)-modulefile
