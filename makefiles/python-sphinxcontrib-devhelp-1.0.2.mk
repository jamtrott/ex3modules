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
# python-sphinxcontrib-devhelp-1.0.2

python-sphinxcontrib-devhelp-version = 1.0.2
python-sphinxcontrib-devhelp = python-sphinxcontrib-devhelp-$(python-sphinxcontrib-devhelp-version)
$(python-sphinxcontrib-devhelp)-description = Sphinx extension which outputs Devhelp document
$(python-sphinxcontrib-devhelp)-url = http://sphinx-doc.org/
$(python-sphinxcontrib-devhelp)-srcurl = https://files.pythonhosted.org/packages/98/33/dc28393f16385f722c893cb55539c641c9aaec8d1bc1c15b69ce0ac2dbb3/sphinxcontrib-devhelp-1.0.2.tar.gz
$(python-sphinxcontrib-devhelp)-src = $(pkgsrcdir)/$(notdir $($(python-sphinxcontrib-devhelp)-srcurl))
$(python-sphinxcontrib-devhelp)-srcdir = $(pkgsrcdir)/$(python-sphinxcontrib-devhelp)
$(python-sphinxcontrib-devhelp)-builddeps = $(python)
$(python-sphinxcontrib-devhelp)-prereqs = $(python)
$(python-sphinxcontrib-devhelp)-modulefile = $(modulefilesdir)/$(python-sphinxcontrib-devhelp)
$(python-sphinxcontrib-devhelp)-prefix = $(pkgdir)/$(python-sphinxcontrib-devhelp)
$(python-sphinxcontrib-devhelp)-site-packages = $($(python-sphinxcontrib-devhelp)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-sphinxcontrib-devhelp)-src): $(dir $($(python-sphinxcontrib-devhelp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sphinxcontrib-devhelp)-srcurl)

$($(python-sphinxcontrib-devhelp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-devhelp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sphinxcontrib-devhelp)-prefix)/.pkgunpack: $$($(python-sphinxcontrib-devhelp)-src) $($(python-sphinxcontrib-devhelp)-srcdir)/.markerfile $($(python-sphinxcontrib-devhelp)-prefix)/.markerfile
	tar -C $($(python-sphinxcontrib-devhelp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sphinxcontrib-devhelp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-devhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-devhelp)-prefix)/.pkgunpack
	@touch $@

$($(python-sphinxcontrib-devhelp)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sphinxcontrib-devhelp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-devhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-devhelp)-prefix)/.pkgpatch
	cd $($(python-sphinxcontrib-devhelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-devhelp)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-sphinxcontrib-devhelp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-devhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-devhelp)-prefix)/.pkgbuild
	# cd $($(python-sphinxcontrib-devhelp)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sphinxcontrib-devhelp)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-sphinxcontrib-devhelp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sphinxcontrib-devhelp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sphinxcontrib-devhelp)-prefix)/.pkgcheck $($(python-sphinxcontrib-devhelp)-site-packages)/.markerfile
	cd $($(python-sphinxcontrib-devhelp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sphinxcontrib-devhelp)-builddeps) && \
		PYTHONPATH=$($(python-sphinxcontrib-devhelp)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-sphinxcontrib-devhelp)-prefix)
	@touch $@

$($(python-sphinxcontrib-devhelp)-modulefile): $(modulefilesdir)/.markerfile $($(python-sphinxcontrib-devhelp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sphinxcontrib-devhelp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sphinxcontrib-devhelp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-devhelp)-description)\"" >>$@
	echo "module-whatis \"$($(python-sphinxcontrib-devhelp)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sphinxcontrib-devhelp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SPHINXCONTRIB_DEVHELP_ROOT $($(python-sphinxcontrib-devhelp)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sphinxcontrib-devhelp)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sphinxcontrib-devhelp)-site-packages)" >>$@
	echo "set MSG \"$(python-sphinxcontrib-devhelp)\"" >>$@

$(python-sphinxcontrib-devhelp)-src: $($(python-sphinxcontrib-devhelp)-src)
$(python-sphinxcontrib-devhelp)-unpack: $($(python-sphinxcontrib-devhelp)-prefix)/.pkgunpack
$(python-sphinxcontrib-devhelp)-patch: $($(python-sphinxcontrib-devhelp)-prefix)/.pkgpatch
$(python-sphinxcontrib-devhelp)-build: $($(python-sphinxcontrib-devhelp)-prefix)/.pkgbuild
$(python-sphinxcontrib-devhelp)-check: $($(python-sphinxcontrib-devhelp)-prefix)/.pkgcheck
$(python-sphinxcontrib-devhelp)-install: $($(python-sphinxcontrib-devhelp)-prefix)/.pkginstall
$(python-sphinxcontrib-devhelp)-modulefile: $($(python-sphinxcontrib-devhelp)-modulefile)
$(python-sphinxcontrib-devhelp)-clean:
	rm -rf $($(python-sphinxcontrib-devhelp)-modulefile)
	rm -rf $($(python-sphinxcontrib-devhelp)-prefix)
	rm -rf $($(python-sphinxcontrib-devhelp)-srcdir)
	rm -rf $($(python-sphinxcontrib-devhelp)-src)
$(python-sphinxcontrib-devhelp): $(python-sphinxcontrib-devhelp)-src $(python-sphinxcontrib-devhelp)-unpack $(python-sphinxcontrib-devhelp)-patch $(python-sphinxcontrib-devhelp)-build $(python-sphinxcontrib-devhelp)-check $(python-sphinxcontrib-devhelp)-install $(python-sphinxcontrib-devhelp)-modulefile
