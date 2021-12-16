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
# python-requests-2.23.0

python-requests-version = 2.23.0
python-requests = python-requests-$(python-requests-version)
$(python-requests)-description = HTTP library for Python
$(python-requests)-url = https://requests.readthedocs.io/
$(python-requests)-srcurl = https://files.pythonhosted.org/packages/f5/4f/280162d4bd4d8aad241a21aecff7a6e46891b905a4341e7ab549ebaf7915/requests-2.23.0.tar.gz
$(python-requests)-src = $(pkgsrcdir)/$(notdir $($(python-requests)-srcurl))
$(python-requests)-srcdir = $(pkgsrcdir)/$(python-requests)
$(python-requests)-builddeps = $(python) $(python-chardet) $(python-idna) $(python-urllib3) $(python-certifi)
$(python-requests)-prereqs = $(python) $(python-chardet) $(python-idna) $(python-urllib3) $(python-certifi)
$(python-requests)-modulefile = $(modulefilesdir)/$(python-requests)
$(python-requests)-prefix = $(pkgdir)/$(python-requests)
$(python-requests)-site-packages = $($(python-requests)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-requests)-src): $(dir $($(python-requests)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-requests)-srcurl)

$($(python-requests)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-requests)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-requests)-prefix)/.pkgunpack: $$($(python-requests)-src) $($(python-requests)-srcdir)/.markerfile $($(python-requests)-prefix)/.markerfile $$(foreach dep,$$($(python-requests)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-requests)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-requests)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-requests)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-requests)-prefix)/.pkgunpack
	@touch $@

$($(python-requests)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-requests)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-requests)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-requests)-prefix)/.pkgpatch
	cd $($(python-requests)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-requests)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-requests)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-requests)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-requests)-prefix)/.pkgbuild
	# cd $($(python-requests)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-requests)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-requests)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-requests)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-requests)-prefix)/.pkgcheck $($(python-requests)-site-packages)/.markerfile
	cd $($(python-requests)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-requests)-builddeps) && \
		PYTHONPATH=$($(python-requests)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-requests)-prefix)
	@touch $@

$($(python-requests)-modulefile): $(modulefilesdir)/.markerfile $($(python-requests)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-requests)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-requests)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-requests)-description)\"" >>$@
	echo "module-whatis \"$($(python-requests)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-requests)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_REQUESTS_ROOT $($(python-requests)-prefix)" >>$@
	echo "prepend-path PATH $($(python-requests)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-requests)-site-packages)" >>$@
	echo "set MSG \"$(python-requests)\"" >>$@

$(python-requests)-src: $($(python-requests)-src)
$(python-requests)-unpack: $($(python-requests)-prefix)/.pkgunpack
$(python-requests)-patch: $($(python-requests)-prefix)/.pkgpatch
$(python-requests)-build: $($(python-requests)-prefix)/.pkgbuild
$(python-requests)-check: $($(python-requests)-prefix)/.pkgcheck
$(python-requests)-install: $($(python-requests)-prefix)/.pkginstall
$(python-requests)-modulefile: $($(python-requests)-modulefile)
$(python-requests)-clean:
	rm -rf $($(python-requests)-modulefile)
	rm -rf $($(python-requests)-prefix)
	rm -rf $($(python-requests)-srcdir)
	rm -rf $($(python-requests)-src)
$(python-requests): $(python-requests)-src $(python-requests)-unpack $(python-requests)-patch $(python-requests)-build $(python-requests)-check $(python-requests)-install $(python-requests)-modulefile
