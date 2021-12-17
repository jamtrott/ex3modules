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
# python-alabaster-0.7.12

python-alabaster-version = 0.7.12
python-alabaster = python-alabaster-$(python-alabaster-version)
$(python-alabaster)-description = A configurable sidebar-enabled Sphinx theme
$(python-alabaster)-url = https://alabaster.readthedocs.io/
$(python-alabaster)-srcurl = https://files.pythonhosted.org/packages/cc/b4/ed8dcb0d67d5cfb7f83c4d5463a7614cb1d078ad7ae890c9143edebbf072/alabaster-0.7.12.tar.gz
$(python-alabaster)-src = $(pkgsrcdir)/$(notdir $($(python-alabaster)-srcurl))
$(python-alabaster)-srcdir = $(pkgsrcdir)/$(python-alabaster)
$(python-alabaster)-builddeps = $(python) $(python-pygments)
$(python-alabaster)-prereqs = $(python)
$(python-alabaster)-modulefile = $(modulefilesdir)/$(python-alabaster)
$(python-alabaster)-prefix = $(pkgdir)/$(python-alabaster)
$(python-alabaster)-site-packages = $($(python-alabaster)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-alabaster)-src): $(dir $($(python-alabaster)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-alabaster)-srcurl)

$($(python-alabaster)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-alabaster)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-alabaster)-prefix)/.pkgunpack: $$($(python-alabaster)-src) $($(python-alabaster)-srcdir)/.markerfile $($(python-alabaster)-prefix)/.markerfile $$(foreach dep,$$($(python-alabaster)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-alabaster)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-alabaster)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-alabaster)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-alabaster)-prefix)/.pkgunpack
	@touch $@

$($(python-alabaster)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-alabaster)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-alabaster)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-alabaster)-prefix)/.pkgpatch
	cd $($(python-alabaster)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-alabaster)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-alabaster)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-alabaster)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-alabaster)-prefix)/.pkgbuild
	cd $($(python-alabaster)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-alabaster)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-alabaster)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-alabaster)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-alabaster)-prefix)/.pkgcheck $($(python-alabaster)-site-packages)/.markerfile
	cd $($(python-alabaster)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-alabaster)-builddeps) && \
		PYTHONPATH=$($(python-alabaster)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-alabaster)-prefix)
	@touch $@

$($(python-alabaster)-modulefile): $(modulefilesdir)/.markerfile $($(python-alabaster)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-alabaster)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-alabaster)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-alabaster)-description)\"" >>$@
	echo "module-whatis \"$($(python-alabaster)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-alabaster)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ALABASTER_ROOT $($(python-alabaster)-prefix)" >>$@
	echo "prepend-path PATH $($(python-alabaster)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-alabaster)-site-packages)" >>$@
	echo "set MSG \"$(python-alabaster)\"" >>$@

$(python-alabaster)-src: $($(python-alabaster)-src)
$(python-alabaster)-unpack: $($(python-alabaster)-prefix)/.pkgunpack
$(python-alabaster)-patch: $($(python-alabaster)-prefix)/.pkgpatch
$(python-alabaster)-build: $($(python-alabaster)-prefix)/.pkgbuild
$(python-alabaster)-check: $($(python-alabaster)-prefix)/.pkgcheck
$(python-alabaster)-install: $($(python-alabaster)-prefix)/.pkginstall
$(python-alabaster)-modulefile: $($(python-alabaster)-modulefile)
$(python-alabaster)-clean:
	rm -rf $($(python-alabaster)-modulefile)
	rm -rf $($(python-alabaster)-prefix)
	rm -rf $($(python-alabaster)-srcdir)
	rm -rf $($(python-alabaster)-src)
$(python-alabaster): $(python-alabaster)-src $(python-alabaster)-unpack $(python-alabaster)-patch $(python-alabaster)-build $(python-alabaster)-check $(python-alabaster)-install $(python-alabaster)-modulefile
