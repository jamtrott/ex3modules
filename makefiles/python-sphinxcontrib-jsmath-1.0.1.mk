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
# python-sphinxcontrib-jsmath-1.0.1

python-sphinxcontrib-jsmath-version = 1.0.1
python-sphinxcontrib-jsmath = python-sphinxcontrib-jsmath-$(python-sphinxcontrib-jsmath-version)
$(python-sphinxcontrib-jsmath)-description = Sphinx extension which renders display math in HTML via JavaScript
$(python-sphinxcontrib-jsmath)-url = http://sphinx-doc.org/
$(python-sphinxcontrib-jsmath)-srcurl = https://files.pythonhosted.org/packages/b2/e8/9ed3830aeed71f17c026a07a5097edcf44b692850ef215b161b8ad875729/sphinxcontrib-jsmath-1.0.1.tar.gz
$(python-sphinxcontrib-jsmath)-src = $(pkgsrcdir)/$(notdir $($(python-sphinxcontrib-jsmath)-srcurl))
$(python-sphinxcontrib-jsmath)-srcdir = $(pkgsrcdir)/$(python-sphinxcontrib-jsmath)
$(python-sphinxcontrib-jsmath)-builddeps = $(python)
$(python-sphinxcontrib-jsmath)-prereqs = $(python)
$(python-sphinxcontrib-jsmath)-modulefile = $(modulefilesdir)/$(python-sphinxcontrib-jsmath)
$(python-sphinxcontrib-jsmath)-prefix = $(pkgdir)/$(python-sphinxcontrib-jsmath)
$(python-sphinxcontrib-jsmath)-site-packages = $($(python-sphinxcontrib-jsmath)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sphinxcontrib-jsmath)-src): $(dir $($(python-sphinxcontrib-jsmath)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinxcontrib-jsmath)-srcurl)

$($(python-sphinxcontrib-jsmath)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-jsmath)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-jsmath)-prefix)/.pkgunpack: $$($(python-sphinxcontrib-jsmath)-src) $($(python-sphinxcontrib-jsmath)-srcdir)/.markerfile $($(python-sphinxcontrib-jsmath)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-jsmath)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinxcontrib-jsmath)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinxcontrib-jsmath)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-jsmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-jsmath)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinxcontrib-jsmath)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinxcontrib-jsmath)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-jsmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-jsmath)-prefix)/.pkgpatch
	cd $($(python-sphinxcontrib-jsmath)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-jsmath)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sphinxcontrib-jsmath)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-jsmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-jsmath)-prefix)/.pkgbuild
	# cd $($(python-sphinxcontrib-jsmath)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sphinxcontrib-jsmath)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-sphinxcontrib-jsmath)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-jsmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-jsmath)-prefix)/.pkgcheck $($(python-sphinxcontrib-jsmath)-site-packages)/.markerfile
	cd $($(python-sphinxcontrib-jsmath)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-jsmath)-builddeps) && \
		PYTHONPATH=$($(python-sphinxcontrib-jsmath)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-sphinxcontrib-jsmath)-prefix)
	@touch $@

$($(python-sphinxcontrib-jsmath)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinxcontrib-jsmath)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinxcontrib-jsmath)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinxcontrib-jsmath)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-jsmath)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-jsmath)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinxcontrib-jsmath)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINXCONTRIB_JSMATH_ROOT $($(python-sphinxcontrib-jsmath)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinxcontrib-jsmath)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinxcontrib-jsmath)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinxcontrib-jsmath)\"" >>$@

$(python-sphinxcontrib-jsmath)-src: $($(python-sphinxcontrib-jsmath)-src)
$(python-sphinxcontrib-jsmath)-unpack: $($(python-sphinxcontrib-jsmath)-prefix)/.pkgunpack
$(python-sphinxcontrib-jsmath)-patch: $($(python-sphinxcontrib-jsmath)-prefix)/.pkgpatch
$(python-sphinxcontrib-jsmath)-build: $($(python-sphinxcontrib-jsmath)-prefix)/.pkgbuild
$(python-sphinxcontrib-jsmath)-check: $($(python-sphinxcontrib-jsmath)-prefix)/.pkgcheck
$(python-sphinxcontrib-jsmath)-install: $($(python-sphinxcontrib-jsmath)-prefix)/.pkginstall
$(python-sphinxcontrib-jsmath)-modulefile: $($(python-sphinxcontrib-jsmath)-modulefile)
$(python-sphinxcontrib-jsmath)-clean:
	rm -rf $($(python-sphinxcontrib-jsmath)-modulefile)
	rm -rf $($(python-sphinxcontrib-jsmath)-prefix)
	rm -rf $($(python-sphinxcontrib-jsmath)-srcdir)
	rm -rf $($(python-sphinxcontrib-jsmath)-src)
$(python-sphinxcontrib-jsmath): $(python-sphinxcontrib-jsmath)-src $(python-sphinxcontrib-jsmath)-unpack $(python-sphinxcontrib-jsmath)-patch $(python-sphinxcontrib-jsmath)-build $(python-sphinxcontrib-jsmath)-check $(python-sphinxcontrib-jsmath)-install $(python-sphinxcontrib-jsmath)-modulefile
