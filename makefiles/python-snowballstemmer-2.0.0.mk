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
# python-snowballstemmer-2.0.0

python-snowballstemmer-version = 2.0.0
python-snowballstemmer = python-snowballstemmer-$(python-snowballstemmer-version)
$(python-snowballstemmer)-description = This package provides 26 stemmers for 25 languages generated from Snowball algorithms
$(python-snowballstemmer)-url = https://github.com/snowballstem/snowball
$(python-snowballstemmer)-srcurl = https://files.pythonhosted.org/packages/21/1b/6b8bbee253195c61aeaa61181bb41d646363bdaa691d0b94b304d4901193/snowballstemmer-2.0.0.tar.gz
$(python-snowballstemmer)-src = $(pkgsrcdir)/$(notdir $($(python-snowballstemmer)-srcurl))
$(python-snowballstemmer)-srcdir = $(pkgsrcdir)/$(python-snowballstemmer)
$(python-snowballstemmer)-builddeps = $(python)
$(python-snowballstemmer)-prereqs = $(python)
$(python-snowballstemmer)-modulefile = $(modulefilesdir)/$(python-snowballstemmer)
$(python-snowballstemmer)-prefix = $(pkgdir)/$(python-snowballstemmer)
$(python-snowballstemmer)-site-packages = $($(python-snowballstemmer)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-snowballstemmer)-src): $(dir $($(python-snowballstemmer)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-snowballstemmer)-srcurl)

$($(python-snowballstemmer)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-snowballstemmer)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-snowballstemmer)-prefix)/.pkgunpack: $$($(python-snowballstemmer)-src) $($(python-snowballstemmer)-srcdir)/.markerfile $($(python-snowballstemmer)-prefix)/.markerfile $$(foreach dep,$$($(python-snowballstemmer)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-snowballstemmer)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-snowballstemmer)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-snowballstemmer)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-snowballstemmer)-prefix)/.pkgunpack
	@touch $@

$($(python-snowballstemmer)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-snowballstemmer)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-snowballstemmer)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-snowballstemmer)-prefix)/.pkgpatch
	cd $($(python-snowballstemmer)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-snowballstemmer)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-snowballstemmer)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-snowballstemmer)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-snowballstemmer)-prefix)/.pkgbuild
	cd $($(python-snowballstemmer)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-snowballstemmer)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-snowballstemmer)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-snowballstemmer)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-snowballstemmer)-prefix)/.pkgcheck $($(python-snowballstemmer)-site-packages)/.markerfile
	cd $($(python-snowballstemmer)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-snowballstemmer)-builddeps) && \
		PYTHONPATH=$($(python-snowballstemmer)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-snowballstemmer)-prefix)
	@touch $@

$($(python-snowballstemmer)-modulefile): $(modulefilesdir)/.markerfile $($(python-snowballstemmer)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-snowballstemmer)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-snowballstemmer)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-snowballstemmer)-description)\"" >>$@
	echo "module-whatis \"$($(python-snowballstemmer)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-snowballstemmer)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SNOWBALLSTEMMER_ROOT $($(python-snowballstemmer)-prefix)" >>$@
	echo "prepend-path PATH $($(python-snowballstemmer)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-snowballstemmer)-site-packages)" >>$@
	echo "set MSG \"$(python-snowballstemmer)\"" >>$@

$(python-snowballstemmer)-src: $($(python-snowballstemmer)-src)
$(python-snowballstemmer)-unpack: $($(python-snowballstemmer)-prefix)/.pkgunpack
$(python-snowballstemmer)-patch: $($(python-snowballstemmer)-prefix)/.pkgpatch
$(python-snowballstemmer)-build: $($(python-snowballstemmer)-prefix)/.pkgbuild
$(python-snowballstemmer)-check: $($(python-snowballstemmer)-prefix)/.pkgcheck
$(python-snowballstemmer)-install: $($(python-snowballstemmer)-prefix)/.pkginstall
$(python-snowballstemmer)-modulefile: $($(python-snowballstemmer)-modulefile)
$(python-snowballstemmer)-clean:
	rm -rf $($(python-snowballstemmer)-modulefile)
	rm -rf $($(python-snowballstemmer)-prefix)
	rm -rf $($(python-snowballstemmer)-srcdir)
	rm -rf $($(python-snowballstemmer)-src)
$(python-snowballstemmer): $(python-snowballstemmer)-src $(python-snowballstemmer)-unpack $(python-snowballstemmer)-patch $(python-snowballstemmer)-build $(python-snowballstemmer)-check $(python-snowballstemmer)-install $(python-snowballstemmer)-modulefile
