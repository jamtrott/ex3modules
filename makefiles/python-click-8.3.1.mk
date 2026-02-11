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
# python-click-8.3.1

python-click-version = 8.3.1
python-click = python-click-$(python-click-version)
$(python-click)-description = Composable command line interface toolkit
$(python-click)-url = https://github.com/pallets/click/
$(python-click)-srcurl = https://files.pythonhosted.org/packages/3d/fa/656b739db8587d7b5dfa22e22ed02566950fbfbcdc20311993483657a5c0/click-8.3.1.tar.gz
$(python-click)-src = $(pkgsrcdir)/$(notdir $($(python-click)-srcurl))
$(python-click)-builddeps = $(python) $(python-pip)
$(python-click)-prereqs = $(python)
$(python-click)-srcdir = $(pkgsrcdir)/$(python-click)
$(python-click)-modulefile = $(modulefilesdir)/$(python-click)
$(python-click)-prefix = $(pkgdir)/$(python-click)

$($(python-click)-src): $(dir $($(python-click)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-click)-srcurl)

$($(python-click)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-click)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-click)-prefix)/.pkgunpack: $$($(python-click)-src) $($(python-click)-srcdir)/.markerfile $($(python-click)-prefix)/.markerfile $$(foreach dep,$$($(python-click)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-click)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-click)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-click)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-click)-prefix)/.pkgunpack
	@touch $@

$($(python-click)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-click)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-click)-prefix)/.pkgpatch
	@touch $@

$($(python-click)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-click)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-click)-prefix)/.pkgbuild
	@touch $@

$($(python-click)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-click)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-click)-prefix)/.pkgcheck
	cd $($(python-click)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-click)-builddeps) && \
		PYTHONPATH=$($(python-click)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-click)-prefix)
	@touch $@

$($(python-click)-modulefile): $(modulefilesdir)/.markerfile $($(python-click)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-click)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-click)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-click)-description)\"" >>$@
	echo "module-whatis \"$($(python-click)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-click)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CLICK_ROOT $($(python-click)-prefix)" >>$@
	echo "prepend-path PATH $($(python-click)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-click)-prefix)" >>$@
	echo "set MSG \"$(python-click)\"" >>$@

$(python-click)-src: $($(python-click)-src)
$(python-click)-unpack: $($(python-click)-prefix)/.pkgunpack
$(python-click)-patch: $($(python-click)-prefix)/.pkgpatch
$(python-click)-build: $($(python-click)-prefix)/.pkgbuild
$(python-click)-check: $($(python-click)-prefix)/.pkgcheck
$(python-click)-install: $($(python-click)-prefix)/.pkginstall
$(python-click)-modulefile: $($(python-click)-modulefile)
$(python-click)-clean:
	rm -rf $($(python-click)-modulefile)
	rm -rf $($(python-click)-prefix)
	rm -rf $($(python-click)-srcdir)
	rm -rf $($(python-click)-src)
$(python-click): $(python-click)-src $(python-click)-unpack $(python-click)-patch $(python-click)-build $(python-click)-check $(python-click)-install $(python-click)-modulefile
