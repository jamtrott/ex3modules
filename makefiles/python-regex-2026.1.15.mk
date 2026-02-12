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
# python-regex-2026.1.15

python-regex-version = 2026.1.15
python-regex = python-regex-$(python-regex-version)
$(python-regex)-description = Alternative regular expression module, to replace re.
$(python-regex)-url = https://github.com/mrabarnett/mrab-regex
$(python-regex)-srcurl = https://files.pythonhosted.org/packages/0b/86/07d5056945f9ec4590b518171c4254a5925832eb727b56d3c38a7476f316/regex-2026.1.15.tar.gz
$(python-regex)-src = $(pkgsrcdir)/$(notdir $($(python-regex)-srcurl))
$(python-regex)-builddeps = $(python) $(python-pip)
$(python-regex)-prereqs = $(python)
$(python-regex)-srcdir = $(pkgsrcdir)/$(python-regex)
$(python-regex)-modulefile = $(modulefilesdir)/$(python-regex)
$(python-regex)-prefix = $(pkgdir)/$(python-regex)

$($(python-regex)-src): $(dir $($(python-regex)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-regex)-srcurl)

$($(python-regex)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-regex)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-regex)-prefix)/.pkgunpack: $$($(python-regex)-src) $($(python-regex)-srcdir)/.markerfile $($(python-regex)-prefix)/.markerfile $$(foreach dep,$$($(python-regex)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-regex)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-regex)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-regex)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-regex)-prefix)/.pkgunpack
	@touch $@

$($(python-regex)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-regex)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-regex)-prefix)/.pkgpatch
	@touch $@

$($(python-regex)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-regex)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-regex)-prefix)/.pkgbuild
	@touch $@

$($(python-regex)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-regex)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-regex)-prefix)/.pkgcheck
	cd $($(python-regex)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-regex)-builddeps) && \
		PYTHONPATH=$($(python-regex)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-regex)-prefix)
	@touch $@

$($(python-regex)-modulefile): $(modulefilesdir)/.markerfile $($(python-regex)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-regex)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-regex)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-regex)-description)\"" >>$@
	echo "module-whatis \"$($(python-regex)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-regex)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_REGEX_ROOT $($(python-regex)-prefix)" >>$@
	echo "prepend-path PATH $($(python-regex)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-regex)-prefix)" >>$@
	echo "set MSG \"$(python-regex)\"" >>$@

$(python-regex)-src: $($(python-regex)-src)
$(python-regex)-unpack: $($(python-regex)-prefix)/.pkgunpack
$(python-regex)-patch: $($(python-regex)-prefix)/.pkgpatch
$(python-regex)-build: $($(python-regex)-prefix)/.pkgbuild
$(python-regex)-check: $($(python-regex)-prefix)/.pkgcheck
$(python-regex)-install: $($(python-regex)-prefix)/.pkginstall
$(python-regex)-modulefile: $($(python-regex)-modulefile)
$(python-regex)-clean:
	rm -rf $($(python-regex)-modulefile)
	rm -rf $($(python-regex)-prefix)
	rm -rf $($(python-regex)-srcdir)
	rm -rf $($(python-regex)-src)
$(python-regex): $(python-regex)-src $(python-regex)-unpack $(python-regex)-patch $(python-regex)-build $(python-regex)-check $(python-regex)-install $(python-regex)-modulefile
