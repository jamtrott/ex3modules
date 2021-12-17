# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# python-wheel-0.37.0

python-wheel-version = 0.37.0
python-wheel = python-wheel-$(python-wheel-version)
$(python-wheel)-description = Reference implementation of the Python wheel packaging standard
$(python-wheel)-url = https://github.com/pypa/wheel
$(python-wheel)-srcurl = https://files.pythonhosted.org/packages/4e/be/8139f127b4db2f79c8b117c80af56a3078cc4824b5b94250c7f81a70e03b/wheel-0.37.0.tar.gz
$(python-wheel)-src = $(pkgsrcdir)/$(notdir $($(python-wheel)-srcurl))
$(python-wheel)-srcdir = $(pkgsrcdir)/$(python-wheel)
$(python-wheel)-builddeps = $(python) $(python-setuptools)
$(python-wheel)-prereqs = $(python)
$(python-wheel)-modulefile = $(modulefilesdir)/$(python-wheel)
$(python-wheel)-prefix = $(pkgdir)/$(python-wheel)
$(python-wheel)-site-packages = $($(python-wheel)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-wheel)-src): $(dir $($(python-wheel)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-wheel)-srcurl)

$($(python-wheel)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-wheel)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-wheel)-prefix)/.pkgunpack: $$($(python-wheel)-src) $($(python-wheel)-srcdir)/.markerfile $($(python-wheel)-prefix)/.markerfile $$(foreach dep,$$($(python-wheel)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-wheel)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-wheel)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wheel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wheel)-prefix)/.pkgunpack
	@touch $@

$($(python-wheel)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-wheel)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wheel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wheel)-prefix)/.pkgpatch
	cd $($(python-wheel)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wheel)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-wheel)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wheel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wheel)-prefix)/.pkgbuild
	cd $($(python-wheel)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wheel)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-wheel)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wheel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wheel)-prefix)/.pkgcheck $($(python-wheel)-site-packages)/.markerfile
	cd $($(python-wheel)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wheel)-builddeps) && \
		PYTHONPATH=$($(python-wheel)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-wheel)-prefix)
	@touch $@

$($(python-wheel)-modulefile): $(modulefilesdir)/.markerfile $($(python-wheel)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-wheel)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-wheel)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-wheel)-description)\"" >>$@
	echo "module-whatis \"$($(python-wheel)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-wheel)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_WHEEL_ROOT $($(python-wheel)-prefix)" >>$@
	echo "prepend-path PATH $($(python-wheel)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-wheel)-site-packages)" >>$@
	echo "set MSG \"$(python-wheel)\"" >>$@

$(python-wheel)-src: $($(python-wheel)-src)
$(python-wheel)-unpack: $($(python-wheel)-prefix)/.pkgunpack
$(python-wheel)-patch: $($(python-wheel)-prefix)/.pkgpatch
$(python-wheel)-build: $($(python-wheel)-prefix)/.pkgbuild
$(python-wheel)-check: $($(python-wheel)-prefix)/.pkgcheck
$(python-wheel)-install: $($(python-wheel)-prefix)/.pkginstall
$(python-wheel)-modulefile: $($(python-wheel)-modulefile)
$(python-wheel)-clean:
	rm -rf $($(python-wheel)-modulefile)
	rm -rf $($(python-wheel)-prefix)
	rm -rf $($(python-wheel)-srcdir)
	rm -rf $($(python-wheel)-src)
$(python-wheel): $(python-wheel)-src $(python-wheel)-unpack $(python-wheel)-patch $(python-wheel)-build $(python-wheel)-check $(python-wheel)-install $(python-wheel)-modulefile
