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
# python-breathe-4.13.1

python-breathe-version = 4.13.1
python-breathe = python-breathe-$(python-breathe-version)
$(python-breathe)-description = Bridge between the Sphinx and Doxygen documentation systems
$(python-breathe)-url = https://breathe.readthedocs.io/
$(python-breathe)-srcurl = https://files.pythonhosted.org/packages/b5/ad/d68d2ae28ae555a89bc98f87638d7e1c26e3826fe9fb8909077ee74aacca/breathe-4.13.1.tar.gz
$(python-breathe)-src = $(pkgsrcdir)/$(notdir $($(python-breathe)-srcurl))
$(python-breathe)-srcdir = $(pkgsrcdir)/$(python-breathe)
$(python-breathe)-builddeps = $(python) $(python-six) $(python-docutils) $(python-sphinx) $(python-sphinxcontrib-serializinghtml) $(python-sphinxcontrib-qthelp) $(python-sphinxcontrib-jsmath) $(python-sphinxcontrib-htmlhelp) $(python-sphinxcontrib-devhelp) $(python-sphinxcontrib-applehelp) $(python-snowballstemmer) $(python-requests) $(python-packaging) $(python-imagesize) $(python-babel) $(python-alabaster) $(python-pygments) $(python-jinja2) $(python-urllib3) $(python-idna) $(python-chardet) $(python-certifi) $(python-pyparsing) $(python-pytz) $(python-markupsafe) $(python-tox)
$(python-breathe)-prereqs = $(python) $(python-six) $(python-docutils) $(python-sphinx) $(python-sphinxcontrib-serializinghtml) $(python-sphinxcontrib-qthelp) $(python-sphinxcontrib-jsmath) $(python-sphinxcontrib-htmlhelp) $(python-sphinxcontrib-devhelp) $(python-sphinxcontrib-applehelp) $(python-snowballstemmer) $(python-requests) $(python-packaging) $(python-imagesize) $(python-babel) $(python-alabaster) $(python-pygments) $(python-jinja2) $(python-urllib3) $(python-idna) $(python-chardet) $(python-certifi) $(python-pyparsing) $(python-pytz) $(python-markupsafe)
$(python-breathe)-modulefile = $(modulefilesdir)/$(python-breathe)
$(python-breathe)-prefix = $(pkgdir)/$(python-breathe)
$(python-breathe)-site-packages = $($(python-breathe)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages
$($(python-breathe)-src): $(dir $($(python-breathe)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-breathe)-srcurl)

$($(python-breathe)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-breathe)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-breathe)-prefix)/.pkgunpack: $$($(python-breathe)-src) $($(python-breathe)-srcdir)/.markerfile $($(python-breathe)-prefix)/.markerfile $$(foreach dep,$$($(python-breathe)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-breathe)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-breathe)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-breathe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-breathe)-prefix)/.pkgunpack
	@touch $@

$($(python-breathe)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-breathe)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-breathe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-breathe)-prefix)/.pkgpatch
	cd $($(python-breathe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-breathe)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-breathe)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-breathe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-breathe)-prefix)/.pkgbuild
	@touch $@

$($(python-breathe)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-breathe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-breathe)-prefix)/.pkgcheck $($(python-breathe)-site-packages)/.markerfile
	cd $($(python-breathe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-breathe)-builddeps) && \
		PYTHONPATH=$($(python-breathe)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-breathe)-prefix)
	@touch $@

$($(python-breathe)-modulefile): $(modulefilesdir)/.markerfile $($(python-breathe)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-breathe)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-breathe)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-breathe)-description)\"" >>$@
	echo "module-whatis \"$($(python-breathe)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-breathe)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_BREATHE_ROOT $($(python-breathe)-prefix)" >>$@
	echo "prepend-path PATH $($(python-breathe)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-breathe)-site-packages)" >>$@
	echo "set MSG \"$(python-breathe)\"" >>$@

$(python-breathe)-src: $($(python-breathe)-src)
$(python-breathe)-unpack: $($(python-breathe)-prefix)/.pkgunpack
$(python-breathe)-patch: $($(python-breathe)-prefix)/.pkgpatch
$(python-breathe)-build: $($(python-breathe)-prefix)/.pkgbuild
$(python-breathe)-check: $($(python-breathe)-prefix)/.pkgcheck
$(python-breathe)-install: $($(python-breathe)-prefix)/.pkginstall
$(python-breathe)-modulefile: $($(python-breathe)-modulefile)
$(python-breathe)-clean:
	rm -rf $($(python-breathe)-modulefile)
	rm -rf $($(python-breathe)-prefix)
	rm -rf $($(python-breathe)-srcdir)
	rm -rf $($(python-breathe)-src)
$(python-breathe): $(python-breathe)-src $(python-breathe)-unpack $(python-breathe)-patch $(python-breathe)-build $(python-breathe)-check $(python-breathe)-install $(python-breathe)-modulefile
