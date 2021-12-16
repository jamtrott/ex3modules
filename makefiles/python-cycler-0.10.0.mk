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
# python-cycler-0.10.0

python-cycler-version = 0.10.0
python-cycler = python-cycler-$(python-cycler-version)
$(python-cycler)-description = Composable style cycles
$(python-cycler)-url = http://github.com/matplotlib/cycler/
$(python-cycler)-srcurl = https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz
$(python-cycler)-src = $(pkgsrcdir)/$(notdir $($(python-cycler)-srcurl))
$(python-cycler)-srcdir = $(pkgsrcdir)/$(python-cycler)
$(python-cycler)-builddeps = $(python) $(python-pytest) $(python-nose) $(python-six)
$(python-cycler)-prereqs = $(python) $(python-six)
$(python-cycler)-modulefile = $(modulefilesdir)/$(python-cycler)
$(python-cycler)-prefix = $(pkgdir)/$(python-cycler)
$(python-cycler)-site-packages = $($(python-cycler)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-cycler)-src): $(dir $($(python-cycler)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-cycler)-srcurl)

$($(python-cycler)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cycler)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cycler)-prefix)/.pkgunpack: $$($(python-cycler)-src) $($(python-cycler)-srcdir)/.markerfile $($(python-cycler)-prefix)/.markerfile $$(foreach dep,$$($(python-cycler)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-cycler)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-cycler)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cycler)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cycler)-prefix)/.pkgunpack
	@touch $@

$($(python-cycler)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-cycler)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cycler)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cycler)-prefix)/.pkgpatch
	cd $($(python-cycler)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cycler)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-cycler)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cycler)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cycler)-prefix)/.pkgbuild
	cd $($(python-cycler)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cycler)-builddeps) && \
		python3 run_tests.py
	@touch $@

$($(python-cycler)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cycler)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cycler)-prefix)/.pkgcheck $($(python-cycler)-site-packages)/.markerfile
	cd $($(python-cycler)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cycler)-builddeps) && \
		PYTHONPATH=$($(python-cycler)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-cycler)-prefix)
	@touch $@

$($(python-cycler)-modulefile): $(modulefilesdir)/.markerfile $($(python-cycler)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-cycler)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-cycler)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-cycler)-description)\"" >>$@
	echo "module-whatis \"$($(python-cycler)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-cycler)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CYCLER_ROOT $($(python-cycler)-prefix)" >>$@
	echo "prepend-path PATH $($(python-cycler)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-cycler)-site-packages)" >>$@
	echo "set MSG \"$(python-cycler)\"" >>$@

$(python-cycler)-src: $($(python-cycler)-src)
$(python-cycler)-unpack: $($(python-cycler)-prefix)/.pkgunpack
$(python-cycler)-patch: $($(python-cycler)-prefix)/.pkgpatch
$(python-cycler)-build: $($(python-cycler)-prefix)/.pkgbuild
$(python-cycler)-check: $($(python-cycler)-prefix)/.pkgcheck
$(python-cycler)-install: $($(python-cycler)-prefix)/.pkginstall
$(python-cycler)-modulefile: $($(python-cycler)-modulefile)
$(python-cycler)-clean:
	rm -rf $($(python-cycler)-modulefile)
	rm -rf $($(python-cycler)-prefix)
	rm -rf $($(python-cycler)-srcdir)
	rm -rf $($(python-cycler)-src)
$(python-cycler): $(python-cycler)-src $(python-cycler)-unpack $(python-cycler)-patch $(python-cycler)-build $(python-cycler)-check $(python-cycler)-install $(python-cycler)-modulefile
