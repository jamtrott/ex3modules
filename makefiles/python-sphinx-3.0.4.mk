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
# python-sphinx-3.0.4

python-sphinx-version = 3.0.4
python-sphinx = python-sphinx-$(python-sphinx-version)
$(python-sphinx)-description = Python documentation generator
$(python-sphinx)-url = https://www.sphinx-doc.org/
$(python-sphinx)-srcurl = https://files.pythonhosted.org/packages/74/20/2909215d83e4bf925afd875fd995b71e4b34cee6ad1c7eba5d1ce74bd14c/Sphinx-3.0.4.tar.gz
$(python-sphinx)-src = $(pkgsrcdir)/$(notdir $($(python-sphinx)-srcurl))
$(python-sphinx)-srcdir = $(pkgsrcdir)/$(python-sphinx)
$(python-sphinx)-builddeps = $(python) $(python-sphinxcontrib-applehelp) $(python-sphinxcontrib-devhelp) $(python-sphinxcontrib-jsmath) $(python-sphinxcontrib-htmlhelp) $(python-sphinxcontrib-serializinghtml) $(python-sphinxcontrib-qthelp) $(python-jinja2) $(python-pygments) $(python-docutils) $(python-snowballstemmer) $(python-babel) $(python-alabaster) $(python-imagesize) $(python-requests) $(python-setuptools) $(python-packaging)
$(python-sphinx)-prereqs = $(python) $(python-sphinxcontrib-applehelp) $(python-sphinxcontrib-devhelp) $(python-sphinxcontrib-jsmath) $(python-sphinxcontrib-htmlhelp) $(python-sphinxcontrib-serializinghtml) $(python-sphinxcontrib-qthelp) $(python-jinja2) $(python-pygments) $(python-docutils) $(python-snowballstemmer) $(python-babel) $(python-alabaster) $(python-imagesize) $(python-requests) $(python-setuptools) $(python-packaging)
$(python-sphinx)-modulefile = $(modulefilesdir)/$(python-sphinx)
$(python-sphinx)-prefix = $(pkgdir)/$(python-sphinx)
$(python-sphinx)-site-packages = $($(python-sphinx)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sphinx)-src): $(dir $($(python-sphinx)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinx)-srcurl)

$($(python-sphinx)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinx)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinx)-prefix)/.pkgunpack: $$($(python-sphinx)-src) $($(python-sphinx)-srcdir)/.markerfile $($(python-sphinx)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinx)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinx)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinx)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinx)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinx)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinx)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinx)-prefix)/.pkgpatch
	cd $($(python-sphinx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinx)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sphinx)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinx)-prefix)/.pkgbuild
	@touch $@

$($(python-sphinx)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinx)-prefix)/.pkgcheck $($(python-sphinx)-site-packages)/.markerfile
	cd $($(python-sphinx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinx)-builddeps) && \
		PYTHONPATH=$($(python-sphinx)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-sphinx)-prefix)
	@touch $@

$($(python-sphinx)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinx)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinx)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinx)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinx)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinx)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinx)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINX_ROOT $($(python-sphinx)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinx)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinx)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinx)\"" >>$@

$(python-sphinx)-src: $($(python-sphinx)-src)
$(python-sphinx)-unpack: $($(python-sphinx)-prefix)/.pkgunpack
$(python-sphinx)-patch: $($(python-sphinx)-prefix)/.pkgpatch
$(python-sphinx)-build: $($(python-sphinx)-prefix)/.pkgbuild
$(python-sphinx)-check: $($(python-sphinx)-prefix)/.pkgcheck
$(python-sphinx)-install: $($(python-sphinx)-prefix)/.pkginstall
$(python-sphinx)-modulefile: $($(python-sphinx)-modulefile)
$(python-sphinx)-clean:
	rm -rf $($(python-sphinx)-modulefile)
	rm -rf $($(python-sphinx)-prefix)
	rm -rf $($(python-sphinx)-srcdir)
	rm -rf $($(python-sphinx)-src)
$(python-sphinx): $(python-sphinx)-src $(python-sphinx)-unpack $(python-sphinx)-patch $(python-sphinx)-build $(python-sphinx)-check $(python-sphinx)-install $(python-sphinx)-modulefile
