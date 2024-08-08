# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# python-importlib_resources-6.4.0

python-importlib_resources-version = 6.4.0
python-importlib_resources = python-importlib_resources-$(python-importlib_resources-version)
$(python-importlib_resources)-description = Read resources from Python packages
$(python-importlib_resources)-url = https://github.com/python/importlib_resources
$(python-importlib_resources)-srcurl = https://files.pythonhosted.org/packages/c8/9d/6ee73859d6be81c6ea7ebac89655e92740296419bd37e5c8abdb5b62fd55/importlib_resources-6.4.0.tar.gz
$(python-importlib_resources)-src = $(pkgsrcdir)/$(notdir $($(python-importlib_resources)-srcurl))
$(python-importlib_resources)-builddeps = $(python) $(python-pip)
$(python-importlib_resources)-prereqs = $(python)
$(python-importlib_resources)-srcdir = $(pkgsrcdir)/$(python-importlib_resources)
$(python-importlib_resources)-modulefile = $(modulefilesdir)/$(python-importlib_resources)
$(python-importlib_resources)-prefix = $(pkgdir)/$(python-importlib_resources)

$($(python-importlib_resources)-src): $(dir $($(python-importlib_resources)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-importlib_resources)-srcurl)

$($(python-importlib_resources)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-importlib_resources)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-importlib_resources)-prefix)/.pkgunpack: $$($(python-importlib_resources)-src) $($(python-importlib_resources)-srcdir)/.markerfile $($(python-importlib_resources)-prefix)/.markerfile $$(foreach dep,$$($(python-importlib_resources)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-importlib_resources)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-importlib_resources)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-importlib_resources)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-importlib_resources)-prefix)/.pkgunpack
	@touch $@

$($(python-importlib_resources)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-importlib_resources)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-importlib_resources)-prefix)/.pkgpatch
	@touch $@

$($(python-importlib_resources)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-importlib_resources)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-importlib_resources)-prefix)/.pkgbuild
	@touch $@

$($(python-importlib_resources)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-importlib_resources)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-importlib_resources)-prefix)/.pkgcheck
	cd $($(python-importlib_resources)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-importlib_resources)-builddeps) && \
		PYTHONPATH=$($(python-importlib_resources)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-importlib_resources)-prefix)
	@touch $@

$($(python-importlib_resources)-modulefile): $(modulefilesdir)/.markerfile $($(python-importlib_resources)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-importlib_resources)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-importlib_resources)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-importlib_resources)-description)\"" >>$@
	echo "module-whatis \"$($(python-importlib_resources)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-importlib_resources)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_IMPORTLIB_RESOURCES_ROOT $($(python-importlib_resources)-prefix)" >>$@
	echo "prepend-path PATH $($(python-importlib_resources)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-importlib_resources)-prefix)" >>$@
	echo "set MSG \"$(python-importlib_resources)\"" >>$@

$(python-importlib_resources)-src: $($(python-importlib_resources)-src)
$(python-importlib_resources)-unpack: $($(python-importlib_resources)-prefix)/.pkgunpack
$(python-importlib_resources)-patch: $($(python-importlib_resources)-prefix)/.pkgpatch
$(python-importlib_resources)-build: $($(python-importlib_resources)-prefix)/.pkgbuild
$(python-importlib_resources)-check: $($(python-importlib_resources)-prefix)/.pkgcheck
$(python-importlib_resources)-install: $($(python-importlib_resources)-prefix)/.pkginstall
$(python-importlib_resources)-modulefile: $($(python-importlib_resources)-modulefile)
$(python-importlib_resources)-clean:
	rm -rf $($(python-importlib_resources)-modulefile)
	rm -rf $($(python-importlib_resources)-prefix)
	rm -rf $($(python-importlib_resources)-srcdir)
	rm -rf $($(python-importlib_resources)-src)
$(python-importlib_resources): $(python-importlib_resources)-src $(python-importlib_resources)-unpack $(python-importlib_resources)-patch $(python-importlib_resources)-build $(python-importlib_resources)-check $(python-importlib_resources)-install $(python-importlib_resources)-modulefile
