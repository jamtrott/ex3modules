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
# python-sphinxcontrib-applehelp-1.0.2

python-sphinxcontrib-applehelp-version = 1.0.2
python-sphinxcontrib-applehelp = python-sphinxcontrib-applehelp-$(python-sphinxcontrib-applehelp-version)
$(python-sphinxcontrib-applehelp)-description = Sphinx extension which outputs Apple help books
$(python-sphinxcontrib-applehelp)-url = http://sphinx-doc.org/
$(python-sphinxcontrib-applehelp)-srcurl = https://files.pythonhosted.org/packages/9f/01/ad9d4ebbceddbed9979ab4a89ddb78c9760e74e6757b1880f1b2760e8295/sphinxcontrib-applehelp-1.0.2.tar.gz
$(python-sphinxcontrib-applehelp)-src = $(pkgsrcdir)/$(notdir $($(python-sphinxcontrib-applehelp)-srcurl))
$(python-sphinxcontrib-applehelp)-srcdir = $(pkgsrcdir)/$(python-sphinxcontrib-applehelp)
$(python-sphinxcontrib-applehelp)-builddeps = $(python)
$(python-sphinxcontrib-applehelp)-prereqs = $(python)
$(python-sphinxcontrib-applehelp)-modulefile = $(modulefilesdir)/$(python-sphinxcontrib-applehelp)
$(python-sphinxcontrib-applehelp)-prefix = $(pkgdir)/$(python-sphinxcontrib-applehelp)
$(python-sphinxcontrib-applehelp)-site-packages = $($(python-sphinxcontrib-applehelp)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sphinxcontrib-applehelp)-src): $(dir $($(python-sphinxcontrib-applehelp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinxcontrib-applehelp)-srcurl)

$($(python-sphinxcontrib-applehelp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-applehelp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-applehelp)-prefix)/.pkgunpack: $$($(python-sphinxcontrib-applehelp)-src) $($(python-sphinxcontrib-applehelp)-srcdir)/.markerfile $($(python-sphinxcontrib-applehelp)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-applehelp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinxcontrib-applehelp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinxcontrib-applehelp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-applehelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-applehelp)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinxcontrib-applehelp)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinxcontrib-applehelp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-applehelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-applehelp)-prefix)/.pkgpatch
	cd $($(python-sphinxcontrib-applehelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-applehelp)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sphinxcontrib-applehelp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-applehelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-applehelp)-prefix)/.pkgbuild
	# cd $($(python-sphinxcontrib-applehelp)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sphinxcontrib-applehelp)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-sphinxcontrib-applehelp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-applehelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-applehelp)-prefix)/.pkgcheck $($(python-sphinxcontrib-applehelp)-site-packages)/.markerfile
	cd $($(python-sphinxcontrib-applehelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-applehelp)-builddeps) && \
		PYTHONPATH=$($(python-sphinxcontrib-applehelp)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-sphinxcontrib-applehelp)-prefix)
	@touch $@

$($(python-sphinxcontrib-applehelp)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinxcontrib-applehelp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinxcontrib-applehelp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinxcontrib-applehelp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-applehelp)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-applehelp)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinxcontrib-applehelp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINXCONTRIB_APPLEHELP_ROOT $($(python-sphinxcontrib-applehelp)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinxcontrib-applehelp)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinxcontrib-applehelp)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinxcontrib-applehelp)\"" >>$@

$(python-sphinxcontrib-applehelp)-src: $($(python-sphinxcontrib-applehelp)-src)
$(python-sphinxcontrib-applehelp)-unpack: $($(python-sphinxcontrib-applehelp)-prefix)/.pkgunpack
$(python-sphinxcontrib-applehelp)-patch: $($(python-sphinxcontrib-applehelp)-prefix)/.pkgpatch
$(python-sphinxcontrib-applehelp)-build: $($(python-sphinxcontrib-applehelp)-prefix)/.pkgbuild
$(python-sphinxcontrib-applehelp)-check: $($(python-sphinxcontrib-applehelp)-prefix)/.pkgcheck
$(python-sphinxcontrib-applehelp)-install: $($(python-sphinxcontrib-applehelp)-prefix)/.pkginstall
$(python-sphinxcontrib-applehelp)-modulefile: $($(python-sphinxcontrib-applehelp)-modulefile)
$(python-sphinxcontrib-applehelp)-clean:
	rm -rf $($(python-sphinxcontrib-applehelp)-modulefile)
	rm -rf $($(python-sphinxcontrib-applehelp)-prefix)
	rm -rf $($(python-sphinxcontrib-applehelp)-srcdir)
	rm -rf $($(python-sphinxcontrib-applehelp)-src)
$(python-sphinxcontrib-applehelp): $(python-sphinxcontrib-applehelp)-src $(python-sphinxcontrib-applehelp)-unpack $(python-sphinxcontrib-applehelp)-patch $(python-sphinxcontrib-applehelp)-build $(python-sphinxcontrib-applehelp)-check $(python-sphinxcontrib-applehelp)-install $(python-sphinxcontrib-applehelp)-modulefile
