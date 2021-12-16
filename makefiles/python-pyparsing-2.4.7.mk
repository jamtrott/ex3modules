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
# python-pyparsing-2.4.7

python-pyparsing-version = 2.4.7
python-pyparsing = python-pyparsing-$(python-pyparsing-version)
$(python-pyparsing)-description = Python parsing module
$(python-pyparsing)-url = https://github.com/pyparsing/pyparsing/
$(python-pyparsing)-srcurl = https://files.pythonhosted.org/packages/c1/47/dfc9c342c9842bbe0036c7f763d2d6686bcf5eb1808ba3e170afdb282210/pyparsing-2.4.7.tar.gz
$(python-pyparsing)-src = $(pkgsrcdir)/$(notdir $($(python-pyparsing)-srcurl))
$(python-pyparsing)-srcdir = $(pkgsrcdir)/$(python-pyparsing)
$(python-pyparsing)-builddeps = $(python)
$(python-pyparsing)-prereqs = $(python)
$(python-pyparsing)-modulefile = $(modulefilesdir)/$(python-pyparsing)
$(python-pyparsing)-prefix = $(pkgdir)/$(python-pyparsing)
$(python-pyparsing)-site-packages = $($(python-pyparsing)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pyparsing)-src): $(dir $($(python-pyparsing)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pyparsing)-srcurl)

$($(python-pyparsing)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyparsing)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyparsing)-prefix)/.pkgunpack: $$($(python-pyparsing)-src) $($(python-pyparsing)-srcdir)/.markerfile $($(python-pyparsing)-prefix)/.markerfile $$(foreach dep,$$($(python-pyparsing)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pyparsing)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pyparsing)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyparsing)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyparsing)-prefix)/.pkgunpack
	@touch $@

$($(python-pyparsing)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pyparsing)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyparsing)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyparsing)-prefix)/.pkgpatch
	cd $($(python-pyparsing)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyparsing)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pyparsing)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyparsing)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyparsing)-prefix)/.pkgbuild
	cd $($(python-pyparsing)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyparsing)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pyparsing)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyparsing)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyparsing)-prefix)/.pkgcheck $($(python-pyparsing)-site-packages)/.markerfile
	cd $($(python-pyparsing)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyparsing)-builddeps) && \
		PYTHONPATH=$($(python-pyparsing)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pyparsing)-prefix)
	@touch $@

$($(python-pyparsing)-modulefile): $(modulefilesdir)/.markerfile $($(python-pyparsing)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pyparsing)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pyparsing)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pyparsing)-description)\"" >>$@
	echo "module-whatis \"$($(python-pyparsing)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pyparsing)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYPARSING_ROOT $($(python-pyparsing)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pyparsing)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pyparsing)-site-packages)" >>$@
	echo "set MSG \"$(python-pyparsing)\"" >>$@

$(python-pyparsing)-src: $($(python-pyparsing)-src)
$(python-pyparsing)-unpack: $($(python-pyparsing)-prefix)/.pkgunpack
$(python-pyparsing)-patch: $($(python-pyparsing)-prefix)/.pkgpatch
$(python-pyparsing)-build: $($(python-pyparsing)-prefix)/.pkgbuild
$(python-pyparsing)-check: $($(python-pyparsing)-prefix)/.pkgcheck
$(python-pyparsing)-install: $($(python-pyparsing)-prefix)/.pkginstall
$(python-pyparsing)-modulefile: $($(python-pyparsing)-modulefile)
$(python-pyparsing)-clean:
	rm -rf $($(python-pyparsing)-modulefile)
	rm -rf $($(python-pyparsing)-prefix)
	rm -rf $($(python-pyparsing)-srcdir)
	rm -rf $($(python-pyparsing)-src)
$(python-pyparsing): $(python-pyparsing)-src $(python-pyparsing)-unpack $(python-pyparsing)-patch $(python-pyparsing)-build $(python-pyparsing)-check $(python-pyparsing)-install $(python-pyparsing)-modulefile
