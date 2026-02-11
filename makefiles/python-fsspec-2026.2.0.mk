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
# python-fsspec-2026.2.0

python-fsspec-version = 2026.2.0
python-fsspec = python-fsspec-$(python-fsspec-version)
$(python-fsspec)-description = File-system specification
$(python-fsspec)-url = https://github.com/fsspec/filesystem_spec
$(python-fsspec)-srcurl = https://files.pythonhosted.org/packages/51/7c/f60c259dcbf4f0c47cc4ddb8f7720d2dcdc8888c8e5ad84c73ea4531cc5b/fsspec-2026.2.0.tar.gz
$(python-fsspec)-src = $(pkgsrcdir)/$(notdir $($(python-fsspec)-srcurl))
$(python-fsspec)-builddeps = $(python) $(python-pip)
$(python-fsspec)-prereqs = $(python)
$(python-fsspec)-srcdir = $(pkgsrcdir)/$(python-fsspec)
$(python-fsspec)-modulefile = $(modulefilesdir)/$(python-fsspec)
$(python-fsspec)-prefix = $(pkgdir)/$(python-fsspec)

$($(python-fsspec)-src): $(dir $($(python-fsspec)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fsspec)-srcurl)

$($(python-fsspec)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fsspec)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fsspec)-prefix)/.pkgunpack: $$($(python-fsspec)-src) $($(python-fsspec)-srcdir)/.markerfile $($(python-fsspec)-prefix)/.markerfile $$(foreach dep,$$($(python-fsspec)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fsspec)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fsspec)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fsspec)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fsspec)-prefix)/.pkgunpack
	@touch $@

$($(python-fsspec)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fsspec)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fsspec)-prefix)/.pkgpatch
	@touch $@

$($(python-fsspec)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fsspec)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fsspec)-prefix)/.pkgbuild
	@touch $@

$($(python-fsspec)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fsspec)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fsspec)-prefix)/.pkgcheck
	cd $($(python-fsspec)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fsspec)-builddeps) && \
		PYTHONPATH=$($(python-fsspec)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-fsspec)-prefix)
	@touch $@

$($(python-fsspec)-modulefile): $(modulefilesdir)/.markerfile $($(python-fsspec)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fsspec)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fsspec)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fsspec)-description)\"" >>$@
	echo "module-whatis \"$($(python-fsspec)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fsspec)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FSSPEC_ROOT $($(python-fsspec)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fsspec)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fsspec)-prefix)" >>$@
	echo "set MSG \"$(python-fsspec)\"" >>$@

$(python-fsspec)-src: $($(python-fsspec)-src)
$(python-fsspec)-unpack: $($(python-fsspec)-prefix)/.pkgunpack
$(python-fsspec)-patch: $($(python-fsspec)-prefix)/.pkgpatch
$(python-fsspec)-build: $($(python-fsspec)-prefix)/.pkgbuild
$(python-fsspec)-check: $($(python-fsspec)-prefix)/.pkgcheck
$(python-fsspec)-install: $($(python-fsspec)-prefix)/.pkginstall
$(python-fsspec)-modulefile: $($(python-fsspec)-modulefile)
$(python-fsspec)-clean:
	rm -rf $($(python-fsspec)-modulefile)
	rm -rf $($(python-fsspec)-prefix)
	rm -rf $($(python-fsspec)-srcdir)
	rm -rf $($(python-fsspec)-src)
$(python-fsspec): $(python-fsspec)-src $(python-fsspec)-unpack $(python-fsspec)-patch $(python-fsspec)-build $(python-fsspec)-check $(python-fsspec)-install $(python-fsspec)-modulefile
