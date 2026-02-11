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
# python-toolz-1.1.0

python-toolz-version = 1.1.0
python-toolz = python-toolz-$(python-toolz-version)
$(python-toolz)-description = List processing tools and functional utilities
$(python-toolz)-url = https://github.com/pytoolz/toolz
$(python-toolz)-srcurl = https://files.pythonhosted.org/packages/11/d6/114b492226588d6ff54579d95847662fc69196bdeec318eb45393b24c192/toolz-1.1.0.tar.gz
$(python-toolz)-src = $(pkgsrcdir)/$(notdir $($(python-toolz)-srcurl))
$(python-toolz)-builddeps = $(python) $(python-pip)
$(python-toolz)-prereqs = $(python)
$(python-toolz)-srcdir = $(pkgsrcdir)/$(python-toolz)
$(python-toolz)-modulefile = $(modulefilesdir)/$(python-toolz)
$(python-toolz)-prefix = $(pkgdir)/$(python-toolz)

$($(python-toolz)-src): $(dir $($(python-toolz)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-toolz)-srcurl)

$($(python-toolz)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-toolz)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-toolz)-prefix)/.pkgunpack: $$($(python-toolz)-src) $($(python-toolz)-srcdir)/.markerfile $($(python-toolz)-prefix)/.markerfile $$(foreach dep,$$($(python-toolz)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-toolz)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-toolz)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toolz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toolz)-prefix)/.pkgunpack
	@touch $@

$($(python-toolz)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toolz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toolz)-prefix)/.pkgpatch
	@touch $@

$($(python-toolz)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toolz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toolz)-prefix)/.pkgbuild
	@touch $@

$($(python-toolz)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-toolz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-toolz)-prefix)/.pkgcheck
	cd $($(python-toolz)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-toolz)-builddeps) && \
		PYTHONPATH=$($(python-toolz)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-toolz)-prefix)
	@touch $@

$($(python-toolz)-modulefile): $(modulefilesdir)/.markerfile $($(python-toolz)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-toolz)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-toolz)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-toolz)-description)\"" >>$@
	echo "module-whatis \"$($(python-toolz)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-toolz)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TOOLZ_ROOT $($(python-toolz)-prefix)" >>$@
	echo "prepend-path PATH $($(python-toolz)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-toolz)-prefix)" >>$@
	echo "set MSG \"$(python-toolz)\"" >>$@

$(python-toolz)-src: $($(python-toolz)-src)
$(python-toolz)-unpack: $($(python-toolz)-prefix)/.pkgunpack
$(python-toolz)-patch: $($(python-toolz)-prefix)/.pkgpatch
$(python-toolz)-build: $($(python-toolz)-prefix)/.pkgbuild
$(python-toolz)-check: $($(python-toolz)-prefix)/.pkgcheck
$(python-toolz)-install: $($(python-toolz)-prefix)/.pkginstall
$(python-toolz)-modulefile: $($(python-toolz)-modulefile)
$(python-toolz)-clean:
	rm -rf $($(python-toolz)-modulefile)
	rm -rf $($(python-toolz)-prefix)
	rm -rf $($(python-toolz)-srcdir)
	rm -rf $($(python-toolz)-src)
$(python-toolz): $(python-toolz)-src $(python-toolz)-unpack $(python-toolz)-patch $(python-toolz)-build $(python-toolz)-check $(python-toolz)-install $(python-toolz)-modulefile
