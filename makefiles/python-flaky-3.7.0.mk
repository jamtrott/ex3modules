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
# python-flaky-3.7.0

python-flaky-version = 3.7.0
python-flaky = python-flaky-$(python-flaky-version)
$(python-flaky)-description = Plugin for nose or pytest that automatically reruns flaky tests
$(python-flaky)-url = https://github.com/box/flaky/
$(python-flaky)-srcurl = https://files.pythonhosted.org/packages/d5/dd/422c7c5c8c9f4982f3045c73d0571ed4a4faa5754699cc6a6384035fbd80/flaky-3.7.0.tar.gz
$(python-flaky)-src = $(pkgsrcdir)/$(notdir $($(python-flaky)-srcurl))
$(python-flaky)-srcdir = $(pkgsrcdir)/$(python-flaky)
$(python-flaky)-builddeps = $(python)
$(python-flaky)-prereqs = $(python)
$(python-flaky)-modulefile = $(modulefilesdir)/$(python-flaky)
$(python-flaky)-prefix = $(pkgdir)/$(python-flaky)
$(python-flaky)-site-packages = $($(python-flaky)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-flaky)-src): $(dir $($(python-flaky)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-flaky)-srcurl)

$($(python-flaky)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-flaky)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-flaky)-prefix)/.pkgunpack: $$($(python-flaky)-src) $($(python-flaky)-srcdir)/.markerfile $($(python-flaky)-prefix)/.markerfile
	tar -C $($(python-flaky)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-flaky)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flaky)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flaky)-prefix)/.pkgunpack
	@touch $@

$($(python-flaky)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-flaky)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flaky)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flaky)-prefix)/.pkgpatch
	cd $($(python-flaky)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-flaky)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-flaky)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flaky)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flaky)-prefix)/.pkgbuild
	@touch $@

$($(python-flaky)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-flaky)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-flaky)-prefix)/.pkgcheck $($(python-flaky)-site-packages)/.markerfile
	cd $($(python-flaky)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-flaky)-builddeps) && \
		PYTHONPATH=$($(python-flaky)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-flaky)-prefix)
	@touch $@

$($(python-flaky)-modulefile): $(modulefilesdir)/.markerfile $($(python-flaky)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-flaky)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-flaky)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-flaky)-description)\"" >>$@
	echo "module-whatis \"$($(python-flaky)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-flaky)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FLAKY_ROOT $($(python-flaky)-prefix)" >>$@
	echo "prepend-path PATH $($(python-flaky)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-flaky)-site-packages)" >>$@
	echo "set MSG \"$(python-flaky)\"" >>$@

$(python-flaky)-src: $($(python-flaky)-src)
$(python-flaky)-unpack: $($(python-flaky)-prefix)/.pkgunpack
$(python-flaky)-patch: $($(python-flaky)-prefix)/.pkgpatch
$(python-flaky)-build: $($(python-flaky)-prefix)/.pkgbuild
$(python-flaky)-check: $($(python-flaky)-prefix)/.pkgcheck
$(python-flaky)-install: $($(python-flaky)-prefix)/.pkginstall
$(python-flaky)-modulefile: $($(python-flaky)-modulefile)
$(python-flaky)-clean:
	rm -rf $($(python-flaky)-modulefile)
	rm -rf $($(python-flaky)-prefix)
	rm -rf $($(python-flaky)-srcdir)
	rm -rf $($(python-flaky)-src)
$(python-flaky): $(python-flaky)-src $(python-flaky)-unpack $(python-flaky)-patch $(python-flaky)-build $(python-flaky)-check $(python-flaky)-install $(python-flaky)-modulefile
