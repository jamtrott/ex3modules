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
# python-packaging-20.4

python-packaging-version = 20.4
python-packaging = python-packaging-$(python-packaging-version)
$(python-packaging)-description = Core utilities for Python packages
$(python-packaging)-url = https://github.com/pypa/packaging/
$(python-packaging)-srcurl = https://files.pythonhosted.org/packages/55/fd/fc1aca9cf51ed2f2c11748fa797370027babd82f87829c7a8e6dbe720145/packaging-20.4.tar.gz
$(python-packaging)-src = $(pkgsrcdir)/$(notdir $($(python-packaging)-srcurl))
$(python-packaging)-srcdir = $(pkgsrcdir)/$(python-packaging)
$(python-packaging)-builddeps = $(python) $(python-six) $(python-pyparsing)
$(python-packaging)-prereqs = $(python) $(python-six) $(python-pyparsing)
$(python-packaging)-modulefile = $(modulefilesdir)/$(python-packaging)
$(python-packaging)-prefix = $(pkgdir)/$(python-packaging)
$(python-packaging)-site-packages = $($(python-packaging)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-packaging)-src): $(dir $($(python-packaging)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-packaging)-srcurl)

$($(python-packaging)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-packaging)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-packaging)-prefix)/.pkgunpack: $$($(python-packaging)-src) $($(python-packaging)-srcdir)/.markerfile $($(python-packaging)-prefix)/.markerfile $$(foreach dep,$$($(python-packaging)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-packaging)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-packaging)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-packaging)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-packaging)-prefix)/.pkgunpack
	@touch $@

$($(python-packaging)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-packaging)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-packaging)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-packaging)-prefix)/.pkgpatch
	cd $($(python-packaging)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-packaging)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-packaging)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-packaging)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-packaging)-prefix)/.pkgbuild
	# cd $($(python-packaging)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-packaging)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-packaging)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-packaging)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-packaging)-prefix)/.pkgcheck $($(python-packaging)-site-packages)/.markerfile
	cd $($(python-packaging)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-packaging)-builddeps) && \
		PYTHONPATH=$($(python-packaging)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-packaging)-prefix)
	@touch $@

$($(python-packaging)-modulefile): $(modulefilesdir)/.markerfile $($(python-packaging)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-packaging)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-packaging)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-packaging)-description)\"" >>$@
	echo "module-whatis \"$($(python-packaging)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-packaging)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PACKAGING_ROOT $($(python-packaging)-prefix)" >>$@
	echo "prepend-path PATH $($(python-packaging)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-packaging)-site-packages)" >>$@
	echo "set MSG \"$(python-packaging)\"" >>$@

$(python-packaging)-src: $($(python-packaging)-src)
$(python-packaging)-unpack: $($(python-packaging)-prefix)/.pkgunpack
$(python-packaging)-patch: $($(python-packaging)-prefix)/.pkgpatch
$(python-packaging)-build: $($(python-packaging)-prefix)/.pkgbuild
$(python-packaging)-check: $($(python-packaging)-prefix)/.pkgcheck
$(python-packaging)-install: $($(python-packaging)-prefix)/.pkginstall
$(python-packaging)-modulefile: $($(python-packaging)-modulefile)
$(python-packaging)-clean:
	rm -rf $($(python-packaging)-modulefile)
	rm -rf $($(python-packaging)-prefix)
	rm -rf $($(python-packaging)-srcdir)
	rm -rf $($(python-packaging)-src)
$(python-packaging): $(python-packaging)-src $(python-packaging)-unpack $(python-packaging)-patch $(python-packaging)-build $(python-packaging)-check $(python-packaging)-install $(python-packaging)-modulefile
