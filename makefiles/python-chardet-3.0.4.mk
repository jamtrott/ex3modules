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
# python-chardet-3.0.4

python-chardet-version = 3.0.4
python-chardet = python-chardet-$(python-chardet-version)
$(python-chardet)-description = Universal encoding detector for Python 2 and 3
$(python-chardet)-url = https://github.com/chardet/chardet/
$(python-chardet)-srcurl = https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz
$(python-chardet)-src = $(pkgsrcdir)/$(notdir $($(python-chardet)-srcurl))
$(python-chardet)-srcdir = $(pkgsrcdir)/$(python-chardet)
$(python-chardet)-builddeps = $(python) $(python-hypothesis) $(python-pytest) $(python-sortedcontainers) $(python-attrs) $(python-toml) $(python-py) $(python-pluggy) $(python-packaging) $(python-iniconfig) $(python-importlib_metadata) $(python-six) $(python-pyparsing) $(python-zipp)
$(python-chardet)-prereqs = $(python) $(python-hypothesis) $(python-pytest) $(python-sortedcontainers) $(python-attrs) $(python-toml) $(python-py) $(python-pluggy) $(python-packaging) $(python-iniconfig) $(python-importlib_metadata) $(python-six) $(python-pyparsing) $(python-zipp)
$(python-chardet)-modulefile = $(modulefilesdir)/$(python-chardet)
$(python-chardet)-prefix = $(pkgdir)/$(python-chardet)
$(python-chardet)-site-packages = $($(python-chardet)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-chardet)-src): $(dir $($(python-chardet)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-chardet)-srcurl)

$($(python-chardet)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-chardet)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-chardet)-prefix)/.pkgunpack: $$($(python-chardet)-src) $($(python-chardet)-srcdir)/.markerfile $($(python-chardet)-prefix)/.markerfile $$(foreach dep,$$($(python-chardet)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-chardet)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-chardet)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-chardet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-chardet)-prefix)/.pkgunpack
	@touch $@

$($(python-chardet)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-chardet)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-chardet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-chardet)-prefix)/.pkgpatch
	cd $($(python-chardet)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-chardet)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-chardet)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-chardet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-chardet)-prefix)/.pkgbuild
	# cd $($(python-chardet)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-chardet)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-chardet)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-chardet)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-chardet)-prefix)/.pkgcheck $($(python-chardet)-site-packages)/.markerfile
	cd $($(python-chardet)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-chardet)-builddeps) && \
		PYTHONPATH=$($(python-chardet)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-chardet)-prefix)
	@touch $@

$($(python-chardet)-modulefile): $(modulefilesdir)/.markerfile $($(python-chardet)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-chardet)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-chardet)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-chardet)-description)\"" >>$@
	echo "module-whatis \"$($(python-chardet)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-chardet)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CHARDET_ROOT $($(python-chardet)-prefix)" >>$@
	echo "prepend-path PATH $($(python-chardet)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-chardet)-site-packages)" >>$@
	echo "set MSG \"$(python-chardet)\"" >>$@

$(python-chardet)-src: $($(python-chardet)-src)
$(python-chardet)-unpack: $($(python-chardet)-prefix)/.pkgunpack
$(python-chardet)-patch: $($(python-chardet)-prefix)/.pkgpatch
$(python-chardet)-build: $($(python-chardet)-prefix)/.pkgbuild
$(python-chardet)-check: $($(python-chardet)-prefix)/.pkgcheck
$(python-chardet)-install: $($(python-chardet)-prefix)/.pkginstall
$(python-chardet)-modulefile: $($(python-chardet)-modulefile)
$(python-chardet)-clean:
	rm -rf $($(python-chardet)-modulefile)
	rm -rf $($(python-chardet)-prefix)
	rm -rf $($(python-chardet)-srcdir)
	rm -rf $($(python-chardet)-src)
$(python-chardet): $(python-chardet)-src $(python-chardet)-unpack $(python-chardet)-patch $(python-chardet)-build $(python-chardet)-check $(python-chardet)-install $(python-chardet)-modulefile
