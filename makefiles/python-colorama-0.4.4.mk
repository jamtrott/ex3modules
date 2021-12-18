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
# python-colorama-0.4.4

python-colorama-version = 0.4.4
python-colorama = python-colorama-$(python-colorama-version)
$(python-colorama)-description = Cross-platform colored terminal text
$(python-colorama)-url = https://github.com/tartley/colorama/
$(python-colorama)-srcurl = https://files.pythonhosted.org/packages/1f/bb/5d3246097ab77fa083a61bd8d3d527b7ae063c7d8e8671b1cf8c4ec10cbe/colorama-0.4.4.tar.gz
$(python-colorama)-src = $(pkgsrcdir)/$(notdir $($(python-colorama)-srcurl))
$(python-colorama)-srcdir = $(pkgsrcdir)/$(python-colorama)
$(python-colorama)-builddeps = $(python)
$(python-colorama)-prereqs = $(python)
$(python-colorama)-modulefile = $(modulefilesdir)/$(python-colorama)
$(python-colorama)-prefix = $(pkgdir)/$(python-colorama)
$(python-colorama)-site-packages = $($(python-colorama)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-colorama)-src): $(dir $($(python-colorama)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-colorama)-srcurl)

$($(python-colorama)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-colorama)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-colorama)-prefix)/.pkgunpack: $$($(python-colorama)-src) $($(python-colorama)-srcdir)/.markerfile $($(python-colorama)-prefix)/.markerfile $$(foreach dep,$$($(python-colorama)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-colorama)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-colorama)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-colorama)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-colorama)-prefix)/.pkgunpack
	@touch $@

$($(python-colorama)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-colorama)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-colorama)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-colorama)-prefix)/.pkgpatch
	cd $($(python-colorama)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-colorama)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-colorama)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-colorama)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-colorama)-prefix)/.pkgbuild
	cd $($(python-colorama)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-colorama)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-colorama)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-colorama)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-colorama)-prefix)/.pkgcheck $($(python-colorama)-site-packages)/.markerfile
	cd $($(python-colorama)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-colorama)-builddeps) && \
		PYTHONPATH=$($(python-colorama)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-colorama)-prefix)
	@touch $@

$($(python-colorama)-modulefile): $(modulefilesdir)/.markerfile $($(python-colorama)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-colorama)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-colorama)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-colorama)-description)\"" >>$@
	echo "module-whatis \"$($(python-colorama)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-colorama)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_COLORAMA_ROOT $($(python-colorama)-prefix)" >>$@
	echo "prepend-path PATH $($(python-colorama)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-colorama)-site-packages)" >>$@
	echo "set MSG \"$(python-colorama)\"" >>$@

$(python-colorama)-src: $($(python-colorama)-src)
$(python-colorama)-unpack: $($(python-colorama)-prefix)/.pkgunpack
$(python-colorama)-patch: $($(python-colorama)-prefix)/.pkgpatch
$(python-colorama)-build: $($(python-colorama)-prefix)/.pkgbuild
$(python-colorama)-check: $($(python-colorama)-prefix)/.pkgcheck
$(python-colorama)-install: $($(python-colorama)-prefix)/.pkginstall
$(python-colorama)-modulefile: $($(python-colorama)-modulefile)
$(python-colorama)-clean:
	rm -rf $($(python-colorama)-modulefile)
	rm -rf $($(python-colorama)-prefix)
	rm -rf $($(python-colorama)-srcdir)
	rm -rf $($(python-colorama)-src)
$(python-colorama): $(python-colorama)-src $(python-colorama)-unpack $(python-colorama)-patch $(python-colorama)-build $(python-colorama)-check $(python-colorama)-install $(python-colorama)-modulefile
