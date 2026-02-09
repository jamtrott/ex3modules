# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# python-pyyaml-6.0.3

python-pyyaml-version = 6.0.3
python-pyyaml = python-pyyaml-$(python-pyyaml-version)
$(python-pyyaml)-description = YAML parser and emitter for Python
$(python-pyyaml)-url = https://pyyaml.org/
$(python-pyyaml)-srcurl = https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz
$(python-pyyaml)-src = $(pkgsrcdir)/$(notdir $($(python-pyyaml)-srcurl))
$(python-pyyaml)-builddeps = $(python) $(python-pip) $(python-cython) $(libyaml)
$(python-pyyaml)-prereqs = $(python) $(libyaml)
$(python-pyyaml)-srcdir = $(pkgsrcdir)/$(python-pyyaml)
$(python-pyyaml)-modulefile = $(modulefilesdir)/$(python-pyyaml)
$(python-pyyaml)-prefix = $(pkgdir)/$(python-pyyaml)

$($(python-pyyaml)-src): $(dir $($(python-pyyaml)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pyyaml)-srcurl)

$($(python-pyyaml)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyyaml)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyyaml)-prefix)/.pkgunpack: $$($(python-pyyaml)-src) $($(python-pyyaml)-srcdir)/.markerfile $($(python-pyyaml)-prefix)/.markerfile $$(foreach dep,$$($(python-pyyaml)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pyyaml)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pyyaml)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyyaml)-prefix)/.pkgunpack
	@touch $@

$($(python-pyyaml)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyyaml)-prefix)/.pkgpatch
	cd $($(python-pyyaml)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyyaml)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pyyaml)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyyaml)-prefix)/.pkgbuild
	@touch $@

$($(python-pyyaml)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyyaml)-prefix)/.pkgcheck
	cd $($(python-pyyaml)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyyaml)-builddeps) && \
		PYTHONPATH=$($(python-pyyaml)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-pyyaml)-prefix)
	@touch $@

$($(python-pyyaml)-modulefile): $(modulefilesdir)/.markerfile $($(python-pyyaml)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pyyaml)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pyyaml)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pyyaml)-description)\"" >>$@
	echo "module-whatis \"$($(python-pyyaml)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pyyaml)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYYAML_ROOT $($(python-pyyaml)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pyyaml)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pyyaml)-prefix)" >>$@
	echo "set MSG \"$(python-pyyaml)\"" >>$@

$(python-pyyaml)-src: $($(python-pyyaml)-src)
$(python-pyyaml)-unpack: $($(python-pyyaml)-prefix)/.pkgunpack
$(python-pyyaml)-patch: $($(python-pyyaml)-prefix)/.pkgpatch
$(python-pyyaml)-build: $($(python-pyyaml)-prefix)/.pkgbuild
$(python-pyyaml)-check: $($(python-pyyaml)-prefix)/.pkgcheck
$(python-pyyaml)-install: $($(python-pyyaml)-prefix)/.pkginstall
$(python-pyyaml)-modulefile: $($(python-pyyaml)-modulefile)
$(python-pyyaml)-clean:
	rm -rf $($(python-pyyaml)-modulefile)
	rm -rf $($(python-pyyaml)-prefix)
	rm -rf $($(python-pyyaml)-srcdir)
	rm -rf $($(python-pyyaml)-src)
$(python-pyyaml): $(python-pyyaml)-src $(python-pyyaml)-unpack $(python-pyyaml)-patch $(python-pyyaml)-build $(python-pyyaml)-check $(python-pyyaml)-install $(python-pyyaml)-modulefile
