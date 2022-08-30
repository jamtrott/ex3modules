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
# python-pycubexr-1.2.0

python-pycubexr-version = 1.2.0
python-pycubexr = python-pycubexr-$(python-pycubexr-version)
$(python-pycubexr)-description =
$(python-pycubexr)-url =
$(python-pycubexr)-srcurl = https://files.pythonhosted.org/packages/c4/e9/45795c23359222989bb1deaee5c2eae2f41a4370459bbf7574cb22b1d2d2/pycubexr-1.2.0.tar.gz
$(python-pycubexr)-src = $(pkgsrcdir)/$(notdir $($(python-pycubexr)-srcurl))
$(python-pycubexr)-builddeps = $(python) $(python-pip)
$(python-pycubexr)-prereqs = $(python)
$(python-pycubexr)-srcdir = $(pkgsrcdir)/$(python-pycubexr)
$(python-pycubexr)-modulefile = $(modulefilesdir)/$(python-pycubexr)
$(python-pycubexr)-prefix = $(pkgdir)/$(python-pycubexr)
$(python-pycubexr)-site-packages = $($(python-pycubexr)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pycubexr)-src): $(dir $($(python-pycubexr)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pycubexr)-srcurl)

$($(python-pycubexr)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pycubexr)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pycubexr)-prefix)/.pkgunpack: $$($(python-pycubexr)-src) $($(python-pycubexr)-srcdir)/.markerfile $($(python-pycubexr)-prefix)/.markerfile $$(foreach dep,$$($(python-pycubexr)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pycubexr)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pycubexr)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycubexr)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycubexr)-prefix)/.pkgunpack
	@touch $@

$($(python-pycubexr)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pycubexr)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycubexr)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycubexr)-prefix)/.pkgpatch
	cd $($(python-pycubexr)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pycubexr)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pycubexr)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycubexr)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycubexr)-prefix)/.pkgbuild
	@touch $@

$($(python-pycubexr)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycubexr)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycubexr)-prefix)/.pkgcheck $($(python-pycubexr)-site-packages)/.markerfile
	cd $($(python-pycubexr)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pycubexr)-builddeps) && \
		PYTHONPATH=$($(python-pycubexr)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-pycubexr)-prefix)
	@touch $@

$($(python-pycubexr)-modulefile): $(modulefilesdir)/.markerfile $($(python-pycubexr)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pycubexr)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pycubexr)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pycubexr)-description)\"" >>$@
	echo "module-whatis \"$($(python-pycubexr)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pycubexr)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYCUBEXR_ROOT $($(python-pycubexr)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pycubexr)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pycubexr)-site-packages)" >>$@
	echo "set MSG \"$(python-pycubexr)\"" >>$@

$(python-pycubexr)-src: $($(python-pycubexr)-src)
$(python-pycubexr)-unpack: $($(python-pycubexr)-prefix)/.pkgunpack
$(python-pycubexr)-patch: $($(python-pycubexr)-prefix)/.pkgpatch
$(python-pycubexr)-build: $($(python-pycubexr)-prefix)/.pkgbuild
$(python-pycubexr)-check: $($(python-pycubexr)-prefix)/.pkgcheck
$(python-pycubexr)-install: $($(python-pycubexr)-prefix)/.pkginstall
$(python-pycubexr)-modulefile: $($(python-pycubexr)-modulefile)
$(python-pycubexr)-clean:
	rm -rf $($(python-pycubexr)-modulefile)
	rm -rf $($(python-pycubexr)-prefix)
	rm -rf $($(python-pycubexr)-srcdir)
	rm -rf $($(python-pycubexr)-src)
$(python-pycubexr): $(python-pycubexr)-src $(python-pycubexr)-unpack $(python-pycubexr)-patch $(python-pycubexr)-build $(python-pycubexr)-check $(python-pycubexr)-install $(python-pycubexr)-modulefile
