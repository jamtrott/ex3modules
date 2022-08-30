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
# python-tqdm-4.64.0

python-tqdm-version = 4.64.0
python-tqdm = python-tqdm-$(python-tqdm-version)
$(python-tqdm)-description =
$(python-tqdm)-url =
$(python-tqdm)-srcurl = https://files.pythonhosted.org/packages/98/2a/838de32e09bd511cf69fe4ae13ffc748ac143449bfc24bb3fd172d53a84f/tqdm-4.64.0.tar.gz
$(python-tqdm)-src = $(pkgsrcdir)/$(notdir $($(python-tqdm)-srcurl))
$(python-tqdm)-builddeps = $(python) $(python-pip)
$(python-tqdm)-prereqs = $(python)
$(python-tqdm)-srcdir = $(pkgsrcdir)/$(python-tqdm)
$(python-tqdm)-modulefile = $(modulefilesdir)/$(python-tqdm)
$(python-tqdm)-prefix = $(pkgdir)/$(python-tqdm)
$(python-tqdm)-site-packages = $($(python-tqdm)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-tqdm)-src): $(dir $($(python-tqdm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-tqdm)-srcurl)

$($(python-tqdm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tqdm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tqdm)-prefix)/.pkgunpack: $$($(python-tqdm)-src) $($(python-tqdm)-srcdir)/.markerfile $($(python-tqdm)-prefix)/.markerfile $$(foreach dep,$$($(python-tqdm)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-tqdm)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-tqdm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tqdm)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tqdm)-prefix)/.pkgunpack
	@touch $@

$($(python-tqdm)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-tqdm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tqdm)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tqdm)-prefix)/.pkgpatch
	cd $($(python-tqdm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tqdm)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-tqdm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tqdm)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tqdm)-prefix)/.pkgbuild
	@touch $@

$($(python-tqdm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tqdm)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tqdm)-prefix)/.pkgcheck $($(python-tqdm)-site-packages)/.markerfile
	cd $($(python-tqdm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tqdm)-builddeps) && \
		PYTHONPATH=$($(python-tqdm)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-tqdm)-prefix)
	@touch $@

$($(python-tqdm)-modulefile): $(modulefilesdir)/.markerfile $($(python-tqdm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-tqdm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-tqdm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-tqdm)-description)\"" >>$@
	echo "module-whatis \"$($(python-tqdm)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-tqdm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TQDM_ROOT $($(python-tqdm)-prefix)" >>$@
	echo "prepend-path PATH $($(python-tqdm)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-tqdm)-site-packages)" >>$@
	echo "set MSG \"$(python-tqdm)\"" >>$@

$(python-tqdm)-src: $($(python-tqdm)-src)
$(python-tqdm)-unpack: $($(python-tqdm)-prefix)/.pkgunpack
$(python-tqdm)-patch: $($(python-tqdm)-prefix)/.pkgpatch
$(python-tqdm)-build: $($(python-tqdm)-prefix)/.pkgbuild
$(python-tqdm)-check: $($(python-tqdm)-prefix)/.pkgcheck
$(python-tqdm)-install: $($(python-tqdm)-prefix)/.pkginstall
$(python-tqdm)-modulefile: $($(python-tqdm)-modulefile)
$(python-tqdm)-clean:
	rm -rf $($(python-tqdm)-modulefile)
	rm -rf $($(python-tqdm)-prefix)
	rm -rf $($(python-tqdm)-srcdir)
	rm -rf $($(python-tqdm)-src)
$(python-tqdm): $(python-tqdm)-src $(python-tqdm)-unpack $(python-tqdm)-patch $(python-tqdm)-build $(python-tqdm)-check $(python-tqdm)-install $(python-tqdm)-modulefile
