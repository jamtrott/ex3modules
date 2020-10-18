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
# python-coverage-5.1

python-coverage-version = 5.1
python-coverage = python-coverage-$(python-coverage-version)
$(python-coverage)-description = Code coverage measurement for Python
$(python-coverage)-url = https://github.com/nedbat/coveragepy
$(python-coverage)-srcurl = https://files.pythonhosted.org/packages/fe/4d/3d892bdd21acba6c9e9bec6dc93fbe619883a0967c62f976122f2c6366f3/coverage-5.1.tar.gz
$(python-coverage)-src = $(pkgsrcdir)/$(notdir $($(python-coverage)-srcurl))
$(python-coverage)-srcdir = $(pkgsrcdir)/$(python-coverage)
$(python-coverage)-builddeps = $(python)
$(python-coverage)-prereqs = $(python)
$(python-coverage)-modulefile = $(modulefilesdir)/$(python-coverage)
$(python-coverage)-prefix = $(pkgdir)/$(python-coverage)
$(python-coverage)-site-packages = $($(python-coverage)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-coverage)-src): $(dir $($(python-coverage)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-coverage)-srcurl)

$($(python-coverage)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-coverage)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-coverage)-prefix)/.pkgunpack: $$($(python-coverage)-src) $($(python-coverage)-srcdir)/.markerfile $($(python-coverage)-prefix)/.markerfile
	tar -C $($(python-coverage)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-coverage)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-coverage)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-coverage)-prefix)/.pkgunpack
	@touch $@

$($(python-coverage)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-coverage)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-coverage)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-coverage)-prefix)/.pkgpatch
	cd $($(python-coverage)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-coverage)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-coverage)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-coverage)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-coverage)-prefix)/.pkgbuild
	@touch $@

$($(python-coverage)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-coverage)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-coverage)-prefix)/.pkgcheck $($(python-coverage)-site-packages)/.markerfile
	cd $($(python-coverage)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-coverage)-builddeps) && \
		PYTHONPATH=$($(python-coverage)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-coverage)-prefix)
	@touch $@

$($(python-coverage)-modulefile): $(modulefilesdir)/.markerfile $($(python-coverage)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-coverage)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-coverage)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-coverage)-description)\"" >>$@
	echo "module-whatis \"$($(python-coverage)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-coverage)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_COVERAGE_ROOT $($(python-coverage)-prefix)" >>$@
	echo "prepend-path PATH $($(python-coverage)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-coverage)-site-packages)" >>$@
	echo "set MSG \"$(python-coverage)\"" >>$@

$(python-coverage)-src: $($(python-coverage)-src)
$(python-coverage)-unpack: $($(python-coverage)-prefix)/.pkgunpack
$(python-coverage)-patch: $($(python-coverage)-prefix)/.pkgpatch
$(python-coverage)-build: $($(python-coverage)-prefix)/.pkgbuild
$(python-coverage)-check: $($(python-coverage)-prefix)/.pkgcheck
$(python-coverage)-install: $($(python-coverage)-prefix)/.pkginstall
$(python-coverage)-modulefile: $($(python-coverage)-modulefile)
$(python-coverage)-clean:
	rm -rf $($(python-coverage)-modulefile)
	rm -rf $($(python-coverage)-prefix)
	rm -rf $($(python-coverage)-srcdir)
	rm -rf $($(python-coverage)-src)
$(python-coverage): $(python-coverage)-src $(python-coverage)-unpack $(python-coverage)-patch $(python-coverage)-build $(python-coverage)-check $(python-coverage)-install $(python-coverage)-modulefile
