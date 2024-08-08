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
# python-docutils-0.20.1

python-docutils-version = 0.20.1
python-docutils = python-docutils-$(python-docutils-version)
$(python-docutils)-description = Python Documentation Utilities
$(python-docutils)-url = http://docutils.sourceforge.net/
$(python-docutils)-srcurl = https://files.pythonhosted.org/packages/1f/53/a5da4f2c5739cf66290fac1431ee52aff6851c7c8ffd8264f13affd7bcdd/docutils-0.20.1.tar.gz
$(python-docutils)-src = $(pkgsrcdir)/$(notdir $($(python-docutils)-srcurl))
$(python-docutils)-srcdir = $(pkgsrcdir)/$(python-docutils)
$(python-docutils)-builddeps = $(python) $(python-pip)
$(python-docutils)-prereqs = $(python)
$(python-docutils)-modulefile = $(modulefilesdir)/$(python-docutils)
$(python-docutils)-prefix = $(pkgdir)/$(python-docutils)

$($(python-docutils)-src): $(dir $($(python-docutils)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-docutils)-srcurl)

$($(python-docutils)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-docutils)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-docutils)-prefix)/.pkgunpack: $$($(python-docutils)-src) $($(python-docutils)-srcdir)/.markerfile $($(python-docutils)-prefix)/.markerfile $$(foreach dep,$$($(python-docutils)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-docutils)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-docutils)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-docutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-docutils)-prefix)/.pkgunpack
	@touch $@

$($(python-docutils)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-docutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-docutils)-prefix)/.pkgpatch
	cd $($(python-docutils)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-docutils)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-docutils)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-docutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-docutils)-prefix)/.pkgbuild
	cd $($(python-docutils)-srcdir)/test && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-docutils)-builddeps) && \
		$(PYTHON) alltests.py
	@touch $@

$($(python-docutils)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-docutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-docutils)-prefix)/.pkgcheck
	cd $($(python-docutils)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-docutils)-builddeps) && \
		PYTHONPATH=$($(python-docutils)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-docutils)-prefix)
	@touch $@

$($(python-docutils)-modulefile): $(modulefilesdir)/.markerfile $($(python-docutils)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-docutils)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-docutils)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-docutils)-description)\"" >>$@
	echo "module-whatis \"$($(python-docutils)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-docutils)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_DOCUTILS_ROOT $($(python-docutils)-prefix)" >>$@
	echo "prepend-path PATH $($(python-docutils)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-docutils)-prefix)" >>$@
	echo "set MSG \"$(python-docutils)\"" >>$@

$(python-docutils)-src: $($(python-docutils)-src)
$(python-docutils)-unpack: $($(python-docutils)-prefix)/.pkgunpack
$(python-docutils)-patch: $($(python-docutils)-prefix)/.pkgpatch
$(python-docutils)-build: $($(python-docutils)-prefix)/.pkgbuild
$(python-docutils)-check: $($(python-docutils)-prefix)/.pkgcheck
$(python-docutils)-install: $($(python-docutils)-prefix)/.pkginstall
$(python-docutils)-modulefile: $($(python-docutils)-modulefile)
$(python-docutils)-clean:
	rm -rf $($(python-docutils)-modulefile)
	rm -rf $($(python-docutils)-prefix)
	rm -rf $($(python-docutils)-srcdir)
	rm -rf $($(python-docutils)-src)
$(python-docutils): $(python-docutils)-src $(python-docutils)-unpack $(python-docutils)-patch $(python-docutils)-build $(python-docutils)-check $(python-docutils)-install $(python-docutils)-modulefile
