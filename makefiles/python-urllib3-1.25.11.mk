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
# python-urllib3-1.25.11

python-urllib3-version = 1.25.11
python-urllib3 = python-urllib3-$(python-urllib3-version)
$(python-urllib3)-description = HTTP client for Python
$(python-urllib3)-url = https://urllib3.readthedocs.io/
$(python-urllib3)-srcurl = https://files.pythonhosted.org/packages/76/d9/bbbafc76b18da706451fa91bc2ebe21c0daf8868ef3c30b869ac7cb7f01d/urllib3-1.25.11.tar.gz
$(python-urllib3)-src = $(pkgsrcdir)/$(notdir $($(python-urllib3)-srcurl))
$(python-urllib3)-srcdir = $(pkgsrcdir)/$(python-urllib3)
$(python-urllib3)-builddeps = $(python) $(python-pytest)
$(python-urllib3)-prereqs = $(python)
$(python-urllib3)-modulefile = $(modulefilesdir)/$(python-urllib3)
$(python-urllib3)-prefix = $(pkgdir)/$(python-urllib3)
$(python-urllib3)-site-packages = $($(python-urllib3)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-urllib3)-src): $(dir $($(python-urllib3)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-urllib3)-srcurl)

$($(python-urllib3)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-urllib3)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-urllib3)-prefix)/.pkgunpack: $$($(python-urllib3)-src) $($(python-urllib3)-srcdir)/.markerfile $($(python-urllib3)-prefix)/.markerfile $$(foreach dep,$$($(python-urllib3)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-urllib3)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-urllib3)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-urllib3)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-urllib3)-prefix)/.pkgunpack
	@touch $@

$($(python-urllib3)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-urllib3)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-urllib3)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-urllib3)-prefix)/.pkgpatch
	cd $($(python-urllib3)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-urllib3)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-urllib3)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-urllib3)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-urllib3)-prefix)/.pkgbuild
	# cd $($(python-urllib3)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-urllib3)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-urllib3)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-urllib3)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-urllib3)-prefix)/.pkgcheck $($(python-urllib3)-site-packages)/.markerfile
	cd $($(python-urllib3)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-urllib3)-builddeps) && \
		PYTHONPATH=$($(python-urllib3)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-urllib3)-prefix)
	@touch $@

$($(python-urllib3)-modulefile): $(modulefilesdir)/.markerfile $($(python-urllib3)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-urllib3)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-urllib3)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-urllib3)-description)\"" >>$@
	echo "module-whatis \"$($(python-urllib3)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-urllib3)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_URLLIB3_ROOT $($(python-urllib3)-prefix)" >>$@
	echo "prepend-path PATH $($(python-urllib3)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-urllib3)-site-packages)" >>$@
	echo "set MSG \"$(python-urllib3)\"" >>$@

$(python-urllib3)-src: $($(python-urllib3)-src)
$(python-urllib3)-unpack: $($(python-urllib3)-prefix)/.pkgunpack
$(python-urllib3)-patch: $($(python-urllib3)-prefix)/.pkgpatch
$(python-urllib3)-build: $($(python-urllib3)-prefix)/.pkgbuild
$(python-urllib3)-check: $($(python-urllib3)-prefix)/.pkgcheck
$(python-urllib3)-install: $($(python-urllib3)-prefix)/.pkginstall
$(python-urllib3)-modulefile: $($(python-urllib3)-modulefile)
$(python-urllib3)-clean:
	rm -rf $($(python-urllib3)-modulefile)
	rm -rf $($(python-urllib3)-prefix)
	rm -rf $($(python-urllib3)-srcdir)
	rm -rf $($(python-urllib3)-src)
$(python-urllib3): $(python-urllib3)-src $(python-urllib3)-unpack $(python-urllib3)-patch $(python-urllib3)-build $(python-urllib3)-check $(python-urllib3)-install $(python-urllib3)-modulefile
