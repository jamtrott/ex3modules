# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# python-tomli-1.2.3

python-tomli-version = 1.2.3
python-tomli = python-tomli-$(python-tomli-version)
$(python-tomli)-description = TOML parser
$(python-tomli)-url = https://github.com/hukkin/tomli
$(python-tomli)-srcurl = https://files.pythonhosted.org/packages/fb/2e/d0a8276b0cf9b9e34fd0660c330acc59656f53bb2209adc75af863a3582d/tomli-1.2.3.tar.gz
$(python-tomli)-src = $(pkgsrcdir)/$(notdir $($(python-tomli)-srcurl))
$(python-tomli)-builddeps = $(python) $(python-pip)
$(python-tomli)-prereqs = $(python)
$(python-tomli)-srcdir = $(pkgsrcdir)/$(python-tomli)
$(python-tomli)-modulefile = $(modulefilesdir)/$(python-tomli)
$(python-tomli)-prefix = $(pkgdir)/$(python-tomli)
$(python-tomli)-site-packages = $($(python-tomli)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-tomli)-src): $(dir $($(python-tomli)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-tomli)-srcurl)

$($(python-tomli)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tomli)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tomli)-prefix)/.pkgunpack: $$($(python-tomli)-src) $($(python-tomli)-srcdir)/.markerfile $($(python-tomli)-prefix)/.markerfile $$(foreach dep,$$($(python-tomli)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-tomli)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-tomli)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tomli)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tomli)-prefix)/.pkgunpack
	@touch $@

$($(python-tomli)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-tomli)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tomli)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tomli)-prefix)/.pkgpatch
	@touch $@

$($(python-tomli)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tomli)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tomli)-prefix)/.pkgbuild
	@touch $@

$($(python-tomli)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tomli)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tomli)-prefix)/.pkgcheck $($(python-tomli)-site-packages)/.markerfile
	cd $($(python-tomli)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tomli)-builddeps) && \
		PYTHONPATH=$($(python-tomli)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-tomli)-prefix)
	@touch $@

$($(python-tomli)-modulefile): $(modulefilesdir)/.markerfile $($(python-tomli)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-tomli)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-tomli)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-tomli)-description)\"" >>$@
	echo "module-whatis \"$($(python-tomli)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-tomli)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TOMLI_ROOT $($(python-tomli)-prefix)" >>$@
	echo "prepend-path PATH $($(python-tomli)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-tomli)-site-packages)" >>$@
	echo "set MSG \"$(python-tomli)\"" >>$@

$(python-tomli)-src: $($(python-tomli)-src)
$(python-tomli)-unpack: $($(python-tomli)-prefix)/.pkgunpack
$(python-tomli)-patch: $($(python-tomli)-prefix)/.pkgpatch
$(python-tomli)-build: $($(python-tomli)-prefix)/.pkgbuild
$(python-tomli)-check: $($(python-tomli)-prefix)/.pkgcheck
$(python-tomli)-install: $($(python-tomli)-prefix)/.pkginstall
$(python-tomli)-modulefile: $($(python-tomli)-modulefile)
$(python-tomli)-clean:
	rm -rf $($(python-tomli)-modulefile)
	rm -rf $($(python-tomli)-prefix)
	rm -rf $($(python-tomli)-srcdir)
	rm -rf $($(python-tomli)-src)
$(python-tomli): $(python-tomli)-src $(python-tomli)-unpack $(python-tomli)-patch $(python-tomli)-build $(python-tomli)-check $(python-tomli)-install $(python-tomli)-modulefile
