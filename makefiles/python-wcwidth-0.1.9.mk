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
# python-wcwidth-0.1.9

python-wcwidth-version = 0.1.9
python-wcwidth = python-wcwidth-$(python-wcwidth-version)
$(python-wcwidth)-description = Measures number of Terminal column cells of wide-character codes
$(python-wcwidth)-url = https://github.com/jquast/wcwidth/
$(python-wcwidth)-srcurl = https://files.pythonhosted.org/packages/25/9d/0acbed6e4a4be4fc99148f275488580968f44ddb5e69b8ceb53fc9df55a0/wcwidth-0.1.9.tar.gz
$(python-wcwidth)-src = $(pkgsrcdir)/$(notdir $($(python-wcwidth)-srcurl))
$(python-wcwidth)-srcdir = $(pkgsrcdir)/$(python-wcwidth)
$(python-wcwidth)-builddeps = $(python) $(python-setuptools)
$(python-wcwidth)-prereqs = $(python)
$(python-wcwidth)-modulefile = $(modulefilesdir)/$(python-wcwidth)
$(python-wcwidth)-prefix = $(pkgdir)/$(python-wcwidth)
$(python-wcwidth)-site-packages = $($(python-wcwidth)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-wcwidth)-src): $(dir $($(python-wcwidth)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-wcwidth)-srcurl)

$($(python-wcwidth)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-wcwidth)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-wcwidth)-prefix)/.pkgunpack: $$($(python-wcwidth)-src) $($(python-wcwidth)-srcdir)/.markerfile $($(python-wcwidth)-prefix)/.markerfile $$(foreach dep,$$($(python-wcwidth)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-wcwidth)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-wcwidth)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wcwidth)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wcwidth)-prefix)/.pkgunpack
	@touch $@

$($(python-wcwidth)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-wcwidth)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wcwidth)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wcwidth)-prefix)/.pkgpatch
	cd $($(python-wcwidth)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wcwidth)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-wcwidth)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wcwidth)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wcwidth)-prefix)/.pkgbuild
	cd $($(python-wcwidth)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wcwidth)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-wcwidth)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wcwidth)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wcwidth)-prefix)/.pkgcheck $($(python-wcwidth)-site-packages)/.markerfile
	cd $($(python-wcwidth)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wcwidth)-builddeps) && \
		PYTHONPATH=$($(python-wcwidth)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-wcwidth)-prefix)
	@touch $@

$($(python-wcwidth)-modulefile): $(modulefilesdir)/.markerfile $($(python-wcwidth)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-wcwidth)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-wcwidth)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-wcwidth)-description)\"" >>$@
	echo "module-whatis \"$($(python-wcwidth)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-wcwidth)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_WCWIDTH_ROOT $($(python-wcwidth)-prefix)" >>$@
	echo "prepend-path PATH $($(python-wcwidth)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-wcwidth)-site-packages)" >>$@
	echo "set MSG \"$(python-wcwidth)\"" >>$@

$(python-wcwidth)-src: $($(python-wcwidth)-src)
$(python-wcwidth)-unpack: $($(python-wcwidth)-prefix)/.pkgunpack
$(python-wcwidth)-patch: $($(python-wcwidth)-prefix)/.pkgpatch
$(python-wcwidth)-build: $($(python-wcwidth)-prefix)/.pkgbuild
$(python-wcwidth)-check: $($(python-wcwidth)-prefix)/.pkgcheck
$(python-wcwidth)-install: $($(python-wcwidth)-prefix)/.pkginstall
$(python-wcwidth)-modulefile: $($(python-wcwidth)-modulefile)
$(python-wcwidth)-clean:
	rm -rf $($(python-wcwidth)-modulefile)
	rm -rf $($(python-wcwidth)-prefix)
	rm -rf $($(python-wcwidth)-srcdir)
	rm -rf $($(python-wcwidth)-src)
$(python-wcwidth): $(python-wcwidth)-src $(python-wcwidth)-unpack $(python-wcwidth)-patch $(python-wcwidth)-build $(python-wcwidth)-check $(python-wcwidth)-install $(python-wcwidth)-modulefile
