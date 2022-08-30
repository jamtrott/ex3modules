# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-simplejson-3.17.6

python-simplejson-version = 3.17.6
python-simplejson = python-simplejson-$(python-simplejson-version)
$(python-simplejson)-description = Simple, fast, extensible JSON encoder/decoder for Python
$(python-simplejson)-url =
$(python-simplejson)-srcurl = https://files.pythonhosted.org/packages/7a/47/c7cc3d4ed15f09917838a2fb4e1759eafb6d2f37ebf7043af984d8b36cf7/simplejson-3.17.6.tar.gz
$(python-simplejson)-src = $(pkgsrcdir)/$(notdir $($(python-simplejson)-srcurl))
$(python-simplejson)-builddeps = $(python) $(python-pip)
$(python-simplejson)-prereqs = $(python)
$(python-simplejson)-srcdir = $(pkgsrcdir)/$(python-simplejson)
$(python-simplejson)-modulefile = $(modulefilesdir)/$(python-simplejson)
$(python-simplejson)-prefix = $(pkgdir)/$(python-simplejson)
$(python-simplejson)-site-packages = $($(python-simplejson)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-simplejson)-src): $(dir $($(python-simplejson)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-simplejson)-srcurl)

$($(python-simplejson)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-simplejson)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-simplejson)-prefix)/.pkgunpack: $$($(python-simplejson)-src) $($(python-simplejson)-srcdir)/.markerfile $($(python-simplejson)-prefix)/.markerfile $$(foreach dep,$$($(python-simplejson)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-simplejson)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-simplejson)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-simplejson)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-simplejson)-prefix)/.pkgunpack
	@touch $@

$($(python-simplejson)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-simplejson)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-simplejson)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-simplejson)-prefix)/.pkgpatch
	cd $($(python-simplejson)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-simplejson)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-simplejson)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-simplejson)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-simplejson)-prefix)/.pkgbuild
	cd $($(python-simplejson)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-simplejson)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-simplejson)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-simplejson)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-simplejson)-prefix)/.pkgcheck $($(python-simplejson)-site-packages)/.markerfile
	cd $($(python-simplejson)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-simplejson)-builddeps) && \
		PYTHONPATH=$($(python-simplejson)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-simplejson)-prefix)
	@touch $@

$($(python-simplejson)-modulefile): $(modulefilesdir)/.markerfile $($(python-simplejson)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-simplejson)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-simplejson)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-simplejson)-description)\"" >>$@
	echo "module-whatis \"$($(python-simplejson)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-simplejson)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SIMPLEJSON_ROOT $($(python-simplejson)-prefix)" >>$@
	echo "prepend-path PATH $($(python-simplejson)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-simplejson)-site-packages)" >>$@
	echo "set MSG \"$(python-simplejson)\"" >>$@

$(python-simplejson)-src: $($(python-simplejson)-src)
$(python-simplejson)-unpack: $($(python-simplejson)-prefix)/.pkgunpack
$(python-simplejson)-patch: $($(python-simplejson)-prefix)/.pkgpatch
$(python-simplejson)-build: $($(python-simplejson)-prefix)/.pkgbuild
$(python-simplejson)-check: $($(python-simplejson)-prefix)/.pkgcheck
$(python-simplejson)-install: $($(python-simplejson)-prefix)/.pkginstall
$(python-simplejson)-modulefile: $($(python-simplejson)-modulefile)
$(python-simplejson)-clean:
	rm -rf $($(python-simplejson)-modulefile)
	rm -rf $($(python-simplejson)-prefix)
	rm -rf $($(python-simplejson)-srcdir)
	rm -rf $($(python-simplejson)-src)
$(python-simplejson): $(python-simplejson)-src $(python-simplejson)-unpack $(python-simplejson)-patch $(python-simplejson)-build $(python-simplejson)-check $(python-simplejson)-install $(python-simplejson)-modulefile
