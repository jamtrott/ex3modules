# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-hypothesis-5.37.4

python-hypothesis-version = 5.37.4
python-hypothesis = python-hypothesis-$(python-hypothesis-version)
$(python-hypothesis)-description = Library for property-based testing
$(python-hypothesis)-url = https://github.com/HypothesisWorks/hypothesis/tree/master/hypothesis-python
$(python-hypothesis)-srcurl = https://files.pythonhosted.org/packages/3b/e3/27952aaeb1c889ef7d04c86d411899b11d37cfae2be22e8c3db14745d1e8/hypothesis-5.37.4.tar.gz
$(python-hypothesis)-src = $(pkgsrcdir)/$(notdir $($(python-hypothesis)-srcurl))
$(python-hypothesis)-srcdir = $(pkgsrcdir)/$(python-hypothesis)
$(python-hypothesis)-builddeps = $(python) $(python-attrs) $(python-sortedcontainers) $(python-pip)
$(python-hypothesis)-prereqs = $(python) $(python-attrs) $(python-sortedcontainers)
$(python-hypothesis)-modulefile = $(modulefilesdir)/$(python-hypothesis)
$(python-hypothesis)-prefix = $(pkgdir)/$(python-hypothesis)
$(python-hypothesis)-site-packages = $($(python-hypothesis)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-hypothesis)-src): $(dir $($(python-hypothesis)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-hypothesis)-srcurl)

$($(python-hypothesis)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-hypothesis)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-hypothesis)-prefix)/.pkgunpack: $$($(python-hypothesis)-src) $($(python-hypothesis)-srcdir)/.markerfile $($(python-hypothesis)-prefix)/.markerfile $$(foreach dep,$$($(python-hypothesis)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-hypothesis)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-hypothesis)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-hypothesis)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-hypothesis)-prefix)/.pkgunpack
	@touch $@

$($(python-hypothesis)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-hypothesis)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-hypothesis)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-hypothesis)-prefix)/.pkgpatch
	cd $($(python-hypothesis)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-hypothesis)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-hypothesis)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-hypothesis)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-hypothesis)-prefix)/.pkgbuild
	@touch $@

$($(python-hypothesis)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-hypothesis)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-hypothesis)-prefix)/.pkgcheck $($(python-hypothesis)-site-packages)/.markerfile
	cd $($(python-hypothesis)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-hypothesis)-builddeps) && \
		PYTHONPATH=$($(python-hypothesis)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-hypothesis)-prefix)
	@touch $@

$($(python-hypothesis)-modulefile): $(modulefilesdir)/.markerfile $($(python-hypothesis)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-hypothesis)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-hypothesis)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-hypothesis)-description)\"" >>$@
	echo "module-whatis \"$($(python-hypothesis)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-hypothesis)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_HYPOTHESIS_ROOT $($(python-hypothesis)-prefix)" >>$@
	echo "prepend-path PATH $($(python-hypothesis)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-hypothesis)-site-packages)" >>$@
	echo "set MSG \"$(python-hypothesis)\"" >>$@

$(python-hypothesis)-src: $($(python-hypothesis)-src)
$(python-hypothesis)-unpack: $($(python-hypothesis)-prefix)/.pkgunpack
$(python-hypothesis)-patch: $($(python-hypothesis)-prefix)/.pkgpatch
$(python-hypothesis)-build: $($(python-hypothesis)-prefix)/.pkgbuild
$(python-hypothesis)-check: $($(python-hypothesis)-prefix)/.pkgcheck
$(python-hypothesis)-install: $($(python-hypothesis)-prefix)/.pkginstall
$(python-hypothesis)-modulefile: $($(python-hypothesis)-modulefile)
$(python-hypothesis)-clean:
	rm -rf $($(python-hypothesis)-modulefile)
	rm -rf $($(python-hypothesis)-prefix)
	rm -rf $($(python-hypothesis)-srcdir)
	rm -rf $($(python-hypothesis)-src)
$(python-hypothesis): $(python-hypothesis)-src $(python-hypothesis)-unpack $(python-hypothesis)-patch $(python-hypothesis)-build $(python-hypothesis)-check $(python-hypothesis)-install $(python-hypothesis)-modulefile
