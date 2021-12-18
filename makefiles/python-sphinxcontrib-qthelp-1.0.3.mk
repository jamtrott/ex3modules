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
# python-sphinxcontrib-qthelp-1.0.3

python-sphinxcontrib-qthelp-version = 1.0.3
python-sphinxcontrib-qthelp = python-sphinxcontrib-qthelp-$(python-sphinxcontrib-qthelp-version)
$(python-sphinxcontrib-qthelp)-description = Sphinx extension which outputs QtHelp document
$(python-sphinxcontrib-qthelp)-url = http://sphinx-doc.org/
$(python-sphinxcontrib-qthelp)-srcurl = https://files.pythonhosted.org/packages/b1/8e/c4846e59f38a5f2b4a0e3b27af38f2fcf904d4bfd82095bf92de0b114ebd/sphinxcontrib-qthelp-1.0.3.tar.gz
$(python-sphinxcontrib-qthelp)-src = $(pkgsrcdir)/$(notdir $($(python-sphinxcontrib-qthelp)-srcurl))
$(python-sphinxcontrib-qthelp)-srcdir = $(pkgsrcdir)/$(python-sphinxcontrib-qthelp)
$(python-sphinxcontrib-qthelp)-builddeps = $(python)
$(python-sphinxcontrib-qthelp)-prereqs = $(python)
$(python-sphinxcontrib-qthelp)-modulefile = $(modulefilesdir)/$(python-sphinxcontrib-qthelp)
$(python-sphinxcontrib-qthelp)-prefix = $(pkgdir)/$(python-sphinxcontrib-qthelp)
$(python-sphinxcontrib-qthelp)-site-packages = $($(python-sphinxcontrib-qthelp)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sphinxcontrib-qthelp)-src): $(dir $($(python-sphinxcontrib-qthelp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinxcontrib-qthelp)-srcurl)

$($(python-sphinxcontrib-qthelp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-qthelp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-qthelp)-prefix)/.pkgunpack: $$($(python-sphinxcontrib-qthelp)-src) $($(python-sphinxcontrib-qthelp)-srcdir)/.markerfile $($(python-sphinxcontrib-qthelp)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-qthelp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinxcontrib-qthelp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinxcontrib-qthelp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-qthelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-qthelp)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinxcontrib-qthelp)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinxcontrib-qthelp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-qthelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-qthelp)-prefix)/.pkgpatch
	cd $($(python-sphinxcontrib-qthelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-qthelp)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sphinxcontrib-qthelp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-qthelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-qthelp)-prefix)/.pkgbuild
	# cd $($(python-sphinxcontrib-qthelp)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sphinxcontrib-qthelp)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-sphinxcontrib-qthelp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-qthelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-qthelp)-prefix)/.pkgcheck $($(python-sphinxcontrib-qthelp)-site-packages)/.markerfile
	cd $($(python-sphinxcontrib-qthelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-qthelp)-builddeps) && \
		PYTHONPATH=$($(python-sphinxcontrib-qthelp)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-sphinxcontrib-qthelp)-prefix)
	@touch $@

$($(python-sphinxcontrib-qthelp)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinxcontrib-qthelp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinxcontrib-qthelp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinxcontrib-qthelp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-qthelp)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-qthelp)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinxcontrib-qthelp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINXCONTRIB_QTHELP_ROOT $($(python-sphinxcontrib-qthelp)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinxcontrib-qthelp)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinxcontrib-qthelp)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinxcontrib-qthelp)\"" >>$@

$(python-sphinxcontrib-qthelp)-src: $($(python-sphinxcontrib-qthelp)-src)
$(python-sphinxcontrib-qthelp)-unpack: $($(python-sphinxcontrib-qthelp)-prefix)/.pkgunpack
$(python-sphinxcontrib-qthelp)-patch: $($(python-sphinxcontrib-qthelp)-prefix)/.pkgpatch
$(python-sphinxcontrib-qthelp)-build: $($(python-sphinxcontrib-qthelp)-prefix)/.pkgbuild
$(python-sphinxcontrib-qthelp)-check: $($(python-sphinxcontrib-qthelp)-prefix)/.pkgcheck
$(python-sphinxcontrib-qthelp)-install: $($(python-sphinxcontrib-qthelp)-prefix)/.pkginstall
$(python-sphinxcontrib-qthelp)-modulefile: $($(python-sphinxcontrib-qthelp)-modulefile)
$(python-sphinxcontrib-qthelp)-clean:
	rm -rf $($(python-sphinxcontrib-qthelp)-modulefile)
	rm -rf $($(python-sphinxcontrib-qthelp)-prefix)
	rm -rf $($(python-sphinxcontrib-qthelp)-srcdir)
	rm -rf $($(python-sphinxcontrib-qthelp)-src)
$(python-sphinxcontrib-qthelp): $(python-sphinxcontrib-qthelp)-src $(python-sphinxcontrib-qthelp)-unpack $(python-sphinxcontrib-qthelp)-patch $(python-sphinxcontrib-qthelp)-build $(python-sphinxcontrib-qthelp)-check $(python-sphinxcontrib-qthelp)-install $(python-sphinxcontrib-qthelp)-modulefile
