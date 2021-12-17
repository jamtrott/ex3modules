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
# python-attrs-19.3.0

python-attrs-version = 19.3.0
python-attrs = python-attrs-$(python-attrs-version)
$(python-attrs)-description = Classes Without Boilerplate
$(python-attrs)-url = https://www.attrs.org/
$(python-attrs)-srcurl = https://files.pythonhosted.org/packages/98/c3/2c227e66b5e896e15ccdae2e00bbc69aa46e9a8ce8869cc5fa96310bf612/attrs-19.3.0.tar.gz
$(python-attrs)-src = $(pkgsrcdir)/$(notdir $($(python-attrs)-srcurl))
$(python-attrs)-srcdir = $(pkgsrcdir)/$(python-attrs)
$(python-attrs)-builddeps = $(python)
$(python-attrs)-prereqs = $(python)
$(python-attrs)-modulefile = $(modulefilesdir)/$(python-attrs)
$(python-attrs)-prefix = $(pkgdir)/$(python-attrs)
$(python-attrs)-site-packages = $($(python-attrs)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-attrs)-src): $(dir $($(python-attrs)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-attrs)-srcurl)

$($(python-attrs)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-attrs)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-attrs)-prefix)/.pkgunpack: $$($(python-attrs)-src) $($(python-attrs)-srcdir)/.markerfile $($(python-attrs)-prefix)/.markerfile $$(foreach dep,$$($(python-attrs)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-attrs)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-attrs)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-attrs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-attrs)-prefix)/.pkgunpack
	@touch $@

$($(python-attrs)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-attrs)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-attrs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-attrs)-prefix)/.pkgpatch
	cd $($(python-attrs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-attrs)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-attrs)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-attrs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-attrs)-prefix)/.pkgbuild
	# cd $($(python-attrs)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-attrs)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-attrs)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-attrs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-attrs)-prefix)/.pkgcheck $($(python-attrs)-site-packages)/.markerfile
	cd $($(python-attrs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-attrs)-builddeps) && \
		PYTHONPATH=$($(python-attrs)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-attrs)-prefix)
	@touch $@

$($(python-attrs)-modulefile): $(modulefilesdir)/.markerfile $($(python-attrs)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-attrs)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-attrs)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-attrs)-description)\"" >>$@
	echo "module-whatis \"$($(python-attrs)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-attrs)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ATTRS_ROOT $($(python-attrs)-prefix)" >>$@
	echo "prepend-path PATH $($(python-attrs)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-attrs)-site-packages)" >>$@
	echo "set MSG \"$(python-attrs)\"" >>$@

$(python-attrs)-src: $($(python-attrs)-src)
$(python-attrs)-unpack: $($(python-attrs)-prefix)/.pkgunpack
$(python-attrs)-patch: $($(python-attrs)-prefix)/.pkgpatch
$(python-attrs)-build: $($(python-attrs)-prefix)/.pkgbuild
$(python-attrs)-check: $($(python-attrs)-prefix)/.pkgcheck
$(python-attrs)-install: $($(python-attrs)-prefix)/.pkginstall
$(python-attrs)-modulefile: $($(python-attrs)-modulefile)
$(python-attrs)-clean:
	rm -rf $($(python-attrs)-modulefile)
	rm -rf $($(python-attrs)-prefix)
	rm -rf $($(python-attrs)-srcdir)
	rm -rf $($(python-attrs)-src)
$(python-attrs): $(python-attrs)-src $(python-attrs)-unpack $(python-attrs)-patch $(python-attrs)-build $(python-attrs)-check $(python-attrs)-install $(python-attrs)-modulefile
