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
# python-mccabe-0.6.1

python-mccabe-version = 0.6.1
python-mccabe = python-mccabe-$(python-mccabe-version)
$(python-mccabe)-description = McCabe checker, plugin for flake8
$(python-mccabe)-url = https://github.com/pycqa/mccabe
$(python-mccabe)-srcurl = https://files.pythonhosted.org/packages/06/18/fa675aa501e11d6d6ca0ae73a101b2f3571a565e0f7d38e062eec18a91ee/mccabe-0.6.1.tar.gz
$(python-mccabe)-src = $(pkgsrcdir)/$(notdir $($(python-mccabe)-srcurl))
$(python-mccabe)-srcdir = $(pkgsrcdir)/$(python-mccabe)
$(python-mccabe)-builddeps = $(python)
$(python-mccabe)-prereqs = $(python)
$(python-mccabe)-modulefile = $(modulefilesdir)/$(python-mccabe)
$(python-mccabe)-prefix = $(pkgdir)/$(python-mccabe)
$(python-mccabe)-site-packages = $($(python-mccabe)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-mccabe)-src): $(dir $($(python-mccabe)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-mccabe)-srcurl)

$($(python-mccabe)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mccabe)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mccabe)-prefix)/.pkgunpack: $$($(python-mccabe)-src) $($(python-mccabe)-srcdir)/.markerfile $($(python-mccabe)-prefix)/.markerfile $$(foreach dep,$$($(python-mccabe)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-mccabe)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-mccabe)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mccabe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mccabe)-prefix)/.pkgunpack
	@touch $@

$($(python-mccabe)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-mccabe)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mccabe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mccabe)-prefix)/.pkgpatch
	cd $($(python-mccabe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mccabe)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-mccabe)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mccabe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mccabe)-prefix)/.pkgbuild
	cd $($(python-mccabe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mccabe)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-mccabe)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mccabe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mccabe)-prefix)/.pkgcheck $($(python-mccabe)-site-packages)/.markerfile
	cd $($(python-mccabe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mccabe)-builddeps) && \
		PYTHONPATH=$($(python-mccabe)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-mccabe)-prefix)
	@touch $@

$($(python-mccabe)-modulefile): $(modulefilesdir)/.markerfile $($(python-mccabe)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-mccabe)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-mccabe)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-mccabe)-description)\"" >>$@
	echo "module-whatis \"$($(python-mccabe)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-mccabe)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MCCABE_ROOT $($(python-mccabe)-prefix)" >>$@
	echo "prepend-path PATH $($(python-mccabe)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-mccabe)-site-packages)" >>$@
	echo "set MSG \"$(python-mccabe)\"" >>$@

$(python-mccabe)-src: $($(python-mccabe)-src)
$(python-mccabe)-unpack: $($(python-mccabe)-prefix)/.pkgunpack
$(python-mccabe)-patch: $($(python-mccabe)-prefix)/.pkgpatch
$(python-mccabe)-build: $($(python-mccabe)-prefix)/.pkgbuild
$(python-mccabe)-check: $($(python-mccabe)-prefix)/.pkgcheck
$(python-mccabe)-install: $($(python-mccabe)-prefix)/.pkginstall
$(python-mccabe)-modulefile: $($(python-mccabe)-modulefile)
$(python-mccabe)-clean:
	rm -rf $($(python-mccabe)-modulefile)
	rm -rf $($(python-mccabe)-prefix)
	rm -rf $($(python-mccabe)-srcdir)
	rm -rf $($(python-mccabe)-src)
$(python-mccabe): $(python-mccabe)-src $(python-mccabe)-unpack $(python-mccabe)-patch $(python-mccabe)-build $(python-mccabe)-check $(python-mccabe)-install $(python-mccabe)-modulefile
