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
# python-toml-0.10.1

python-toml-version = 0.10.1
python-toml = python-toml-$(python-toml-version)
$(python-toml)-description = A Python library for parsing and creating TOML
$(python-toml)-url = https://pypi.org/project/toml/
$(python-toml)-srcurl = https://files.pythonhosted.org/packages/da/24/84d5c108e818ca294efe7c1ce237b42118643ce58a14d2462b3b2e3800d5/toml-0.10.1.tar.gz
$(python-toml)-src = $(pkgsrcdir)/$(notdir $($(python-toml)-srcurl))
$(python-toml)-srcdir = $(pkgsrcdir)/$(python-toml)
$(python-toml)-builddeps = $(python)
$(python-toml)-prereqs = $(python)
$(python-toml)-modulefile = $(modulefilesdir)/$(python-toml)
$(python-toml)-prefix = $(pkgdir)/$(python-toml)
$(python-toml)-site-packages = $($(python-toml)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-toml)-src): $(dir $($(python-toml)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-toml)-srcurl)

$($(python-toml)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-toml)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-toml)-prefix)/.pkgunpack: $$($(python-toml)-src) $($(python-toml)-srcdir)/.markerfile $($(python-toml)-prefix)/.markerfile
	tar -C $($(python-toml)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-toml)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toml)-prefix)/.pkgunpack
	@touch $@

$($(python-toml)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-toml)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toml)-prefix)/.pkgpatch
	cd $($(python-toml)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-toml)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-toml)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toml)-prefix)/.pkgbuild
	@touch $@

$($(python-toml)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toml)-prefix)/.pkgcheck $($(python-toml)-site-packages)/.markerfile
	cd $($(python-toml)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-toml)-builddeps) && \
		PYTHONPATH=$($(python-toml)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-toml)-prefix)
	@touch $@

$($(python-toml)-modulefile): $(modulefilesdir)/.markerfile $($(python-toml)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-toml)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-toml)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-toml)-description)\"" >>$@
	echo "module-whatis \"$($(python-toml)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-toml)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TOML_ROOT $($(python-toml)-prefix)" >>$@
	echo "prepend-path PATH $($(python-toml)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-toml)-site-packages)" >>$@
	echo "set MSG \"$(python-toml)\"" >>$@

$(python-toml)-src: $($(python-toml)-src)
$(python-toml)-unpack: $($(python-toml)-prefix)/.pkgunpack
$(python-toml)-patch: $($(python-toml)-prefix)/.pkgpatch
$(python-toml)-build: $($(python-toml)-prefix)/.pkgbuild
$(python-toml)-check: $($(python-toml)-prefix)/.pkgcheck
$(python-toml)-install: $($(python-toml)-prefix)/.pkginstall
$(python-toml)-modulefile: $($(python-toml)-modulefile)
$(python-toml)-clean:
	rm -rf $($(python-toml)-modulefile)
	rm -rf $($(python-toml)-prefix)
	rm -rf $($(python-toml)-srcdir)
	rm -rf $($(python-toml)-src)
$(python-toml): $(python-toml)-src $(python-toml)-unpack $(python-toml)-patch $(python-toml)-build $(python-toml)-check $(python-toml)-install $(python-toml)-modulefile
