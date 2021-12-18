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
# python-sphinxcontrib-htmlhelp-1.0.3

python-sphinxcontrib-htmlhelp-version = 1.0.3
python-sphinxcontrib-htmlhelp = python-sphinxcontrib-htmlhelp-$(python-sphinxcontrib-htmlhelp-version)
$(python-sphinxcontrib-htmlhelp)-description = Sphinx extension which renders HTML help files
$(python-sphinxcontrib-htmlhelp)-url = http://sphinx-doc.org/
$(python-sphinxcontrib-htmlhelp)-srcurl = https://files.pythonhosted.org/packages/c9/2e/a7a5fef38327b7f643ed13646321d19903a2f54b0a05868e4bc34d729e1f/sphinxcontrib-htmlhelp-1.0.3.tar.gz
$(python-sphinxcontrib-htmlhelp)-src = $(pkgsrcdir)/$(notdir $($(python-sphinxcontrib-htmlhelp)-srcurl))
$(python-sphinxcontrib-htmlhelp)-srcdir = $(pkgsrcdir)/$(python-sphinxcontrib-htmlhelp)
$(python-sphinxcontrib-htmlhelp)-builddeps = $(python)
$(python-sphinxcontrib-htmlhelp)-prereqs = $(python)
$(python-sphinxcontrib-htmlhelp)-modulefile = $(modulefilesdir)/$(python-sphinxcontrib-htmlhelp)
$(python-sphinxcontrib-htmlhelp)-prefix = $(pkgdir)/$(python-sphinxcontrib-htmlhelp)
$(python-sphinxcontrib-htmlhelp)-site-packages = $($(python-sphinxcontrib-htmlhelp)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sphinxcontrib-htmlhelp)-src): $(dir $($(python-sphinxcontrib-htmlhelp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinxcontrib-htmlhelp)-srcurl)

$($(python-sphinxcontrib-htmlhelp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-htmlhelp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgunpack: $$($(python-sphinxcontrib-htmlhelp)-src) $($(python-sphinxcontrib-htmlhelp)-srcdir)/.markerfile $($(python-sphinxcontrib-htmlhelp)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-htmlhelp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinxcontrib-htmlhelp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-htmlhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinxcontrib-htmlhelp)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-htmlhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgpatch
	cd $($(python-sphinxcontrib-htmlhelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-htmlhelp)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-htmlhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgbuild
	# cd $($(python-sphinxcontrib-htmlhelp)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sphinxcontrib-htmlhelp)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-sphinxcontrib-htmlhelp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-htmlhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgcheck $($(python-sphinxcontrib-htmlhelp)-site-packages)/.markerfile
	cd $($(python-sphinxcontrib-htmlhelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-htmlhelp)-builddeps) && \
		PYTHONPATH=$($(python-sphinxcontrib-htmlhelp)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-sphinxcontrib-htmlhelp)-prefix)
	@touch $@

$($(python-sphinxcontrib-htmlhelp)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinxcontrib-htmlhelp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinxcontrib-htmlhelp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-htmlhelp)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-htmlhelp)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinxcontrib-htmlhelp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINXCONTRIB_HTMLHELP_ROOT $($(python-sphinxcontrib-htmlhelp)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinxcontrib-htmlhelp)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinxcontrib-htmlhelp)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinxcontrib-htmlhelp)\"" >>$@

$(python-sphinxcontrib-htmlhelp)-src: $($(python-sphinxcontrib-htmlhelp)-src)
$(python-sphinxcontrib-htmlhelp)-unpack: $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgunpack
$(python-sphinxcontrib-htmlhelp)-patch: $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgpatch
$(python-sphinxcontrib-htmlhelp)-build: $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgbuild
$(python-sphinxcontrib-htmlhelp)-check: $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkgcheck
$(python-sphinxcontrib-htmlhelp)-install: $($(python-sphinxcontrib-htmlhelp)-prefix)/.pkginstall
$(python-sphinxcontrib-htmlhelp)-modulefile: $($(python-sphinxcontrib-htmlhelp)-modulefile)
$(python-sphinxcontrib-htmlhelp)-clean:
	rm -rf $($(python-sphinxcontrib-htmlhelp)-modulefile)
	rm -rf $($(python-sphinxcontrib-htmlhelp)-prefix)
	rm -rf $($(python-sphinxcontrib-htmlhelp)-srcdir)
	rm -rf $($(python-sphinxcontrib-htmlhelp)-src)
$(python-sphinxcontrib-htmlhelp): $(python-sphinxcontrib-htmlhelp)-src $(python-sphinxcontrib-htmlhelp)-unpack $(python-sphinxcontrib-htmlhelp)-patch $(python-sphinxcontrib-htmlhelp)-build $(python-sphinxcontrib-htmlhelp)-check $(python-sphinxcontrib-htmlhelp)-install $(python-sphinxcontrib-htmlhelp)-modulefile
