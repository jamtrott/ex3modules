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
# python-extrap-4.0.4

python-extrap-version = 4.0.4
python-extrap = python-extrap-$(python-extrap-version)
$(python-extrap)-description = automated performance modeling for HPC applications
$(python-extrap)-url =
$(python-extrap)-srcurl = https://files.pythonhosted.org/packages/d7/df/13c32ba899e148d1a7a7def14b702632896a2e6607efe430b39b7d46ff95/extrap-4.0.4.tar.gz
$(python-extrap)-src = $(pkgsrcdir)/$(notdir $($(python-extrap)-srcurl))
$(python-extrap)-builddeps = $(python) $(python-pip) $(python-numpy) $(python-pycubexr) $(python-marshmallow) $(python-packaging) $(python-tqdm)
$(python-extrap)-prereqs = $(python) $(python-numpy) $(python-pycubexr) $(python-marshmallow) $(python-packaging) $(python-tqdm)
$(python-extrap)-srcdir = $(pkgsrcdir)/$(python-extrap)
$(python-extrap)-modulefile = $(modulefilesdir)/$(python-extrap)
$(python-extrap)-prefix = $(pkgdir)/$(python-extrap)
$(python-extrap)-site-packages = $($(python-extrap)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-extrap)-src): $(dir $($(python-extrap)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-extrap)-srcurl)

$($(python-extrap)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-extrap)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-extrap)-prefix)/.pkgunpack: $$($(python-extrap)-src) $($(python-extrap)-srcdir)/.markerfile $($(python-extrap)-prefix)/.markerfile $$(foreach dep,$$($(python-extrap)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-extrap)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-extrap)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-extrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-extrap)-prefix)/.pkgunpack
	@touch $@

$($(python-extrap)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-extrap)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-extrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-extrap)-prefix)/.pkgpatch
	cd $($(python-extrap)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-extrap)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-extrap)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-extrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-extrap)-prefix)/.pkgbuild
	@touch $@

$($(python-extrap)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-extrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-extrap)-prefix)/.pkgcheck $($(python-extrap)-site-packages)/.markerfile
	cd $($(python-extrap)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-extrap)-builddeps) && \
		PYTHONPATH=$($(python-extrap)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-extrap)-prefix)
	@touch $@

$($(python-extrap)-modulefile): $(modulefilesdir)/.markerfile $($(python-extrap)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-extrap)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-extrap)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-extrap)-description)\"" >>$@
	echo "module-whatis \"$($(python-extrap)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-extrap)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_EXTRAP_ROOT $($(python-extrap)-prefix)" >>$@
	echo "prepend-path PATH $($(python-extrap)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-extrap)-site-packages)" >>$@
	echo "set MSG \"$(python-extrap)\"" >>$@

$(python-extrap)-src: $($(python-extrap)-src)
$(python-extrap)-unpack: $($(python-extrap)-prefix)/.pkgunpack
$(python-extrap)-patch: $($(python-extrap)-prefix)/.pkgpatch
$(python-extrap)-build: $($(python-extrap)-prefix)/.pkgbuild
$(python-extrap)-check: $($(python-extrap)-prefix)/.pkgcheck
$(python-extrap)-install: $($(python-extrap)-prefix)/.pkginstall
$(python-extrap)-modulefile: $($(python-extrap)-modulefile)
$(python-extrap)-clean:
	rm -rf $($(python-extrap)-modulefile)
	rm -rf $($(python-extrap)-prefix)
	rm -rf $($(python-extrap)-srcdir)
	rm -rf $($(python-extrap)-src)
$(python-extrap): $(python-extrap)-src $(python-extrap)-unpack $(python-extrap)-patch $(python-extrap)-build $(python-extrap)-check $(python-extrap)-install $(python-extrap)-modulefile
