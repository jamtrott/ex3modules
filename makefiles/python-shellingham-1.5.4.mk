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
# python-shellingham-1.5.4

python-shellingham-version = 1.5.4
python-shellingham = python-shellingham-$(python-shellingham-version)
$(python-shellingham)-description = Tool to Detect Surrounding Shell
$(python-shellingham)-url = https://github.com/sarugaku/shellingham
$(python-shellingham)-srcurl = https://files.pythonhosted.org/packages/58/15/8b3609fd3830ef7b27b655beb4b4e9c62313a4e8da8c676e142cc210d58e/shellingham-1.5.4.tar.gz
$(python-shellingham)-src = $(pkgsrcdir)/$(notdir $($(python-shellingham)-srcurl))
$(python-shellingham)-builddeps = $(python) $(python-pip)
$(python-shellingham)-prereqs = $(python)
$(python-shellingham)-srcdir = $(pkgsrcdir)/$(python-shellingham)
$(python-shellingham)-modulefile = $(modulefilesdir)/$(python-shellingham)
$(python-shellingham)-prefix = $(pkgdir)/$(python-shellingham)

$($(python-shellingham)-src): $(dir $($(python-shellingham)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-shellingham)-srcurl)

$($(python-shellingham)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-shellingham)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-shellingham)-prefix)/.pkgunpack: $$($(python-shellingham)-src) $($(python-shellingham)-srcdir)/.markerfile $($(python-shellingham)-prefix)/.markerfile $$(foreach dep,$$($(python-shellingham)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-shellingham)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-shellingham)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-shellingham)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-shellingham)-prefix)/.pkgunpack
	@touch $@

$($(python-shellingham)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-shellingham)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-shellingham)-prefix)/.pkgpatch
	@touch $@

$($(python-shellingham)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-shellingham)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-shellingham)-prefix)/.pkgbuild
	@touch $@

$($(python-shellingham)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-shellingham)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-shellingham)-prefix)/.pkgcheck
	cd $($(python-shellingham)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-shellingham)-builddeps) && \
		PYTHONPATH=$($(python-shellingham)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-shellingham)-prefix)
	@touch $@

$($(python-shellingham)-modulefile): $(modulefilesdir)/.markerfile $($(python-shellingham)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-shellingham)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-shellingham)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-shellingham)-description)\"" >>$@
	echo "module-whatis \"$($(python-shellingham)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-shellingham)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SHELLINGHAM_ROOT $($(python-shellingham)-prefix)" >>$@
	echo "prepend-path PATH $($(python-shellingham)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-shellingham)-prefix)" >>$@
	echo "set MSG \"$(python-shellingham)\"" >>$@

$(python-shellingham)-src: $($(python-shellingham)-src)
$(python-shellingham)-unpack: $($(python-shellingham)-prefix)/.pkgunpack
$(python-shellingham)-patch: $($(python-shellingham)-prefix)/.pkgpatch
$(python-shellingham)-build: $($(python-shellingham)-prefix)/.pkgbuild
$(python-shellingham)-check: $($(python-shellingham)-prefix)/.pkgcheck
$(python-shellingham)-install: $($(python-shellingham)-prefix)/.pkginstall
$(python-shellingham)-modulefile: $($(python-shellingham)-modulefile)
$(python-shellingham)-clean:
	rm -rf $($(python-shellingham)-modulefile)
	rm -rf $($(python-shellingham)-prefix)
	rm -rf $($(python-shellingham)-srcdir)
	rm -rf $($(python-shellingham)-src)
$(python-shellingham): $(python-shellingham)-src $(python-shellingham)-unpack $(python-shellingham)-patch $(python-shellingham)-build $(python-shellingham)-check $(python-shellingham)-install $(python-shellingham)-modulefile
