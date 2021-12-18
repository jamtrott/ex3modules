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
# python-jinja2-2.11.2

python-jinja2-version = 2.11.2
python-jinja2 = python-jinja2-$(python-jinja2-version)
$(python-jinja2)-description = A very fast and expressive template engine
$(python-jinja2)-url = https://palletsprojects.com/p/jinja/
$(python-jinja2)-srcurl = https://files.pythonhosted.org/packages/64/a7/45e11eebf2f15bf987c3bc11d37dcc838d9dc81250e67e4c5968f6008b6c/Jinja2-2.11.2.tar.gz
$(python-jinja2)-src = $(pkgsrcdir)/$(notdir $($(python-jinja2)-srcurl))
$(python-jinja2)-srcdir = $(pkgsrcdir)/$(python-jinja2)
$(python-jinja2)-builddeps = $(python)
$(python-jinja2)-prereqs = $(python)
$(python-jinja2)-modulefile = $(modulefilesdir)/$(python-jinja2)
$(python-jinja2)-prefix = $(pkgdir)/$(python-jinja2)
$(python-jinja2)-site-packages = $($(python-jinja2)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-jinja2)-src): $(dir $($(python-jinja2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-jinja2)-srcurl)

$($(python-jinja2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-jinja2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-jinja2)-prefix)/.pkgunpack: $$($(python-jinja2)-src) $($(python-jinja2)-srcdir)/.markerfile $($(python-jinja2)-prefix)/.markerfile $$(foreach dep,$$($(python-jinja2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-jinja2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-jinja2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-jinja2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-jinja2)-prefix)/.pkgunpack
	@touch $@

$($(python-jinja2)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-jinja2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-jinja2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-jinja2)-prefix)/.pkgpatch
	cd $($(python-jinja2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-jinja2)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-jinja2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-jinja2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-jinja2)-prefix)/.pkgbuild
	cd $($(python-jinja2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-jinja2)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-jinja2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-jinja2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-jinja2)-prefix)/.pkgcheck $($(python-jinja2)-site-packages)/.markerfile
	cd $($(python-jinja2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-jinja2)-builddeps) && \
		PYTHONPATH=$($(python-jinja2)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(python-jinja2)-prefix)
	@touch $@

$($(python-jinja2)-modulefile): $(modulefilesdir)/.markerfile $($(python-jinja2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-jinja2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-jinja2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-jinja2)-description)\"" >>$@
	echo "module-whatis \"$($(python-jinja2)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-jinja2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_JINJA2_ROOT $($(python-jinja2)-prefix)" >>$@
	echo "prepend-path PATH $($(python-jinja2)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-jinja2)-site-packages)" >>$@
	echo "set MSG \"$(python-jinja2)\"" >>$@

$(python-jinja2)-src: $($(python-jinja2)-src)
$(python-jinja2)-unpack: $($(python-jinja2)-prefix)/.pkgunpack
$(python-jinja2)-patch: $($(python-jinja2)-prefix)/.pkgpatch
$(python-jinja2)-build: $($(python-jinja2)-prefix)/.pkgbuild
$(python-jinja2)-check: $($(python-jinja2)-prefix)/.pkgcheck
$(python-jinja2)-install: $($(python-jinja2)-prefix)/.pkginstall
$(python-jinja2)-modulefile: $($(python-jinja2)-modulefile)
$(python-jinja2)-clean:
	rm -rf $($(python-jinja2)-modulefile)
	rm -rf $($(python-jinja2)-prefix)
	rm -rf $($(python-jinja2)-srcdir)
	rm -rf $($(python-jinja2)-src)
$(python-jinja2): $(python-jinja2)-src $(python-jinja2)-unpack $(python-jinja2)-patch $(python-jinja2)-build $(python-jinja2)-check $(python-jinja2)-install $(python-jinja2)-modulefile
