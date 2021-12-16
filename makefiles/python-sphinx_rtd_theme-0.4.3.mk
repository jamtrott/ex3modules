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
# python-sphinx_rtd_theme-0.4.3

python-sphinx_rtd_theme-version = 0.4.3
python-sphinx_rtd_theme = python-sphinx_rtd_theme-$(python-sphinx_rtd_theme-version)
$(python-sphinx_rtd_theme)-description = Read the Docs theme for Sphinx
$(python-sphinx_rtd_theme)-url = https://github.com/rtfd/sphinx_rtd_theme/
$(python-sphinx_rtd_theme)-srcurl = https://files.pythonhosted.org/packages/ed/73/7e550d6e4cf9f78a0e0b60b9d93dba295389c3d271c034bf2ea3463a79f9/sphinx_rtd_theme-0.4.3.tar.gz
$(python-sphinx_rtd_theme)-src = $(pkgsrcdir)/$(notdir $($(python-sphinx_rtd_theme)-srcurl))
$(python-sphinx_rtd_theme)-srcdir = $(pkgsrcdir)/$(python-sphinx_rtd_theme)
$(python-sphinx_rtd_theme)-builddeps = $(python) $(python-sphinx)
$(python-sphinx_rtd_theme)-prereqs = $(python) $(python-sphinx)
$(python-sphinx_rtd_theme)-modulefile = $(modulefilesdir)/$(python-sphinx_rtd_theme)
$(python-sphinx_rtd_theme)-prefix = $(pkgdir)/$(python-sphinx_rtd_theme)
$(python-sphinx_rtd_theme)-site-packages = $($(python-sphinx_rtd_theme)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-sphinx_rtd_theme)-src): $(dir $($(python-sphinx_rtd_theme)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinx_rtd_theme)-srcurl)

$($(python-sphinx_rtd_theme)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinx_rtd_theme)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinx_rtd_theme)-prefix)/.pkgunpack: $$($(python-sphinx_rtd_theme)-src) $($(python-sphinx_rtd_theme)-srcdir)/.markerfile $($(python-sphinx_rtd_theme)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinx_rtd_theme)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinx_rtd_theme)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinx_rtd_theme)-prefix)/.pkgpatch: $($(python-sphinx_rtd_theme)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinx_rtd_theme)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinx_rtd_theme)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinx_rtd_theme)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinx_rtd_theme)-prefix)/.pkgpatch
	cd $($(python-sphinx_rtd_theme)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinx_rtd_theme)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-sphinx_rtd_theme)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinx_rtd_theme)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinx_rtd_theme)-prefix)/.pkgbuild
	cd $($(python-sphinx_rtd_theme)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinx_rtd_theme)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-sphinx_rtd_theme)-prefix)/.pkginstall: $($(python-sphinx_rtd_theme)-prefix)/.pkgcheck $($(python-sphinx_rtd_theme)-site-packages)/.markerfile
	cd $($(python-sphinx_rtd_theme)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinx_rtd_theme)-builddeps) && \
		PYTHONPATH=$($(python-sphinx_rtd_theme)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-sphinx_rtd_theme)-prefix)
	@touch $@

$($(python-sphinx_rtd_theme)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinx_rtd_theme)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinx_rtd_theme)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinx_rtd_theme)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinx_rtd_theme)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinx_rtd_theme)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinx_rtd_theme)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINX_RTD_THEME_ROOT $($(python-sphinx_rtd_theme)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinx_rtd_theme)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinx_rtd_theme)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinx_rtd_theme)\"" >>$@

$(python-sphinx_rtd_theme)-src: $($(python-sphinx_rtd_theme)-src)
$(python-sphinx_rtd_theme)-unpack: $($(python-sphinx_rtd_theme)-prefix)/.pkgunpack
$(python-sphinx_rtd_theme)-patch: $($(python-sphinx_rtd_theme)-prefix)/.pkgpatch
$(python-sphinx_rtd_theme)-build: $($(python-sphinx_rtd_theme)-prefix)/.pkgbuild
$(python-sphinx_rtd_theme)-check: $($(python-sphinx_rtd_theme)-prefix)/.pkgcheck
$(python-sphinx_rtd_theme)-install: $($(python-sphinx_rtd_theme)-prefix)/.pkginstall
$(python-sphinx_rtd_theme)-modulefile: $($(python-sphinx_rtd_theme)-modulefile)
$(python-sphinx_rtd_theme)-clean:
	rm -rf $($(python-sphinx_rtd_theme)-modulefile)
	rm -rf $($(python-sphinx_rtd_theme)-prefix)
	rm -rf $($(python-sphinx_rtd_theme)-srcdir)
	rm -rf $($(python-sphinx_rtd_theme)-src)
$(python-sphinx_rtd_theme): $(python-sphinx_rtd_theme)-src $(python-sphinx_rtd_theme)-unpack $(python-sphinx_rtd_theme)-patch $(python-sphinx_rtd_theme)-build $(python-sphinx_rtd_theme)-check $(python-sphinx_rtd_theme)-install $(python-sphinx_rtd_theme)-modulefile
