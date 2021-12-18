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
# python-sphinxcontrib-serializinghtml-1.1.4

python-sphinxcontrib-serializinghtml-version = 1.1.4
python-sphinxcontrib-serializinghtml = python-sphinxcontrib-serializinghtml-$(python-sphinxcontrib-serializinghtml-version)
$(python-sphinxcontrib-serializinghtml)-description = Sphinx extension which outputs \\"serialized\\" HTML files
$(python-sphinxcontrib-serializinghtml)-url = http://sphinx-doc.org/
$(python-sphinxcontrib-serializinghtml)-srcurl = https://files.pythonhosted.org/packages/ac/86/021876a9dd4eac9dae0b1d454d848acbd56d5574d350d0f835043b5ac2cd/sphinxcontrib-serializinghtml-1.1.4.tar.gz
$(python-sphinxcontrib-serializinghtml)-src = $(pkgsrcdir)/$(notdir $($(python-sphinxcontrib-serializinghtml)-srcurl))
$(python-sphinxcontrib-serializinghtml)-srcdir = $(pkgsrcdir)/$(python-sphinxcontrib-serializinghtml)
$(python-sphinxcontrib-serializinghtml)-builddeps = $(python)
$(python-sphinxcontrib-serializinghtml)-prereqs = $(python)
$(python-sphinxcontrib-serializinghtml)-modulefile = $(modulefilesdir)/$(python-sphinxcontrib-serializinghtml)
$(python-sphinxcontrib-serializinghtml)-prefix = $(pkgdir)/$(python-sphinxcontrib-serializinghtml)
$(python-sphinxcontrib-serializinghtml)-site-packages = $($(python-sphinxcontrib-serializinghtml)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sphinxcontrib-serializinghtml)-src): $(dir $($(python-sphinxcontrib-serializinghtml)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinxcontrib-serializinghtml)-srcurl)

$($(python-sphinxcontrib-serializinghtml)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-serializinghtml)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgunpack: $$($(python-sphinxcontrib-serializinghtml)-src) $($(python-sphinxcontrib-serializinghtml)-srcdir)/.markerfile $($(python-sphinxcontrib-serializinghtml)-prefix)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-serializinghtml)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sphinxcontrib-serializinghtml)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-serializinghtml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinxcontrib-serializinghtml)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-serializinghtml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgpatch
	cd $($(python-sphinxcontrib-serializinghtml)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-serializinghtml)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-serializinghtml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgbuild
	# cd $($(python-sphinxcontrib-serializinghtml)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sphinxcontrib-serializinghtml)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-sphinxcontrib-serializinghtml)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-serializinghtml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgcheck $($(python-sphinxcontrib-serializinghtml)-site-packages)/.markerfile
	cd $($(python-sphinxcontrib-serializinghtml)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-serializinghtml)-builddeps) && \
		PYTHONPATH=$($(python-sphinxcontrib-serializinghtml)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-sphinxcontrib-serializinghtml)-prefix)
	@touch $@

$($(python-sphinxcontrib-serializinghtml)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinxcontrib-serializinghtml)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinxcontrib-serializinghtml)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-serializinghtml)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-serializinghtml)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinxcontrib-serializinghtml)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINXCONTRIB_SERIALIZINGHTML_ROOT $($(python-sphinxcontrib-serializinghtml)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinxcontrib-serializinghtml)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinxcontrib-serializinghtml)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinxcontrib-serializinghtml)\"" >>$@

$(python-sphinxcontrib-serializinghtml)-src: $($(python-sphinxcontrib-serializinghtml)-src)
$(python-sphinxcontrib-serializinghtml)-unpack: $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgunpack
$(python-sphinxcontrib-serializinghtml)-patch: $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgpatch
$(python-sphinxcontrib-serializinghtml)-build: $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgbuild
$(python-sphinxcontrib-serializinghtml)-check: $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkgcheck
$(python-sphinxcontrib-serializinghtml)-install: $($(python-sphinxcontrib-serializinghtml)-prefix)/.pkginstall
$(python-sphinxcontrib-serializinghtml)-modulefile: $($(python-sphinxcontrib-serializinghtml)-modulefile)
$(python-sphinxcontrib-serializinghtml)-clean:
	rm -rf $($(python-sphinxcontrib-serializinghtml)-modulefile)
	rm -rf $($(python-sphinxcontrib-serializinghtml)-prefix)
	rm -rf $($(python-sphinxcontrib-serializinghtml)-srcdir)
	rm -rf $($(python-sphinxcontrib-serializinghtml)-src)
$(python-sphinxcontrib-serializinghtml): $(python-sphinxcontrib-serializinghtml)-src $(python-sphinxcontrib-serializinghtml)-unpack $(python-sphinxcontrib-serializinghtml)-patch $(python-sphinxcontrib-serializinghtml)-build $(python-sphinxcontrib-serializinghtml)-check $(python-sphinxcontrib-serializinghtml)-install $(python-sphinxcontrib-serializinghtml)-modulefile
