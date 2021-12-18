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
# python-execnet-1.7.1

python-execnet-version = 1.7.1
python-execnet = python-execnet-$(python-execnet-version)
$(python-execnet)-description = execnet: rapid multi-Python deployment
$(python-execnet)-url = https://execnet.readthedocs.io/en/latest/
$(python-execnet)-srcurl = https://files.pythonhosted.org/packages/5a/61/1b50e0891d9b934154637fdaac88c68a82fd8dc5648dfb04e65937fc6234/execnet-1.7.1.tar.gz
$(python-execnet)-src = $(pkgsrcdir)/$(notdir $($(python-execnet)-srcurl))
$(python-execnet)-srcdir = $(pkgsrcdir)/$(python-execnet)
$(python-execnet)-builddeps = $(python) $(python-apipkg) $(python-setuptools_scm)
$(python-execnet)-prereqs = $(python) $(python-apipkg)
$(python-execnet)-modulefile = $(modulefilesdir)/$(python-execnet)
$(python-execnet)-prefix = $(pkgdir)/$(python-execnet)
$(python-execnet)-site-packages = $($(python-execnet)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-execnet)-src): $(dir $($(python-execnet)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-execnet)-srcurl)

$($(python-execnet)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-execnet)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-execnet)-prefix)/.pkgunpack: $$($(python-execnet)-src) $($(python-execnet)-srcdir)/.markerfile $($(python-execnet)-prefix)/.markerfile $$(foreach dep,$$($(python-execnet)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-execnet)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-execnet)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-execnet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-execnet)-prefix)/.pkgunpack
	@touch $@

$($(python-execnet)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-execnet)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-execnet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-execnet)-prefix)/.pkgpatch
	cd $($(python-execnet)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-execnet)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-execnet)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-execnet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-execnet)-prefix)/.pkgbuild
#	 cd $($(python-execnet)-srcdir) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(python-execnet)-builddeps) && \
#	 	$(PYTHON) setup.py test
	@touch $@

$($(python-execnet)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-execnet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-execnet)-prefix)/.pkgcheck $($(python-execnet)-site-packages)/.markerfile
	cd $($(python-execnet)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-execnet)-builddeps) && \
		PYTHONPATH=$($(python-execnet)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-execnet)-prefix)
	@touch $@

$($(python-execnet)-modulefile): $(modulefilesdir)/.markerfile $($(python-execnet)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-execnet)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-execnet)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-execnet)-description)\"" >>$@
	echo "module-whatis \"$($(python-execnet)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-execnet)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_EXECNET_ROOT $($(python-execnet)-prefix)" >>$@
	echo "prepend-path PATH $($(python-execnet)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-execnet)-site-packages)" >>$@
	echo "set MSG \"$(python-execnet)\"" >>$@

$(python-execnet)-src: $($(python-execnet)-src)
$(python-execnet)-unpack: $($(python-execnet)-prefix)/.pkgunpack
$(python-execnet)-patch: $($(python-execnet)-prefix)/.pkgpatch
$(python-execnet)-build: $($(python-execnet)-prefix)/.pkgbuild
$(python-execnet)-check: $($(python-execnet)-prefix)/.pkgcheck
$(python-execnet)-install: $($(python-execnet)-prefix)/.pkginstall
$(python-execnet)-modulefile: $($(python-execnet)-modulefile)
$(python-execnet)-clean:
	rm -rf $($(python-execnet)-modulefile)
	rm -rf $($(python-execnet)-prefix)
	rm -rf $($(python-execnet)-srcdir)
	rm -rf $($(python-execnet)-src)
$(python-execnet): $(python-execnet)-src $(python-execnet)-unpack $(python-execnet)-patch $(python-execnet)-build $(python-execnet)-check $(python-execnet)-install $(python-execnet)-modulefile
