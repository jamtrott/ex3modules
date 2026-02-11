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
# python-wikiextractor-3.0.6

python-wikiextractor-version = 3.0.6
python-wikiextractor = python-wikiextractor-$(python-wikiextractor-version)
$(python-wikiextractor)-description = A tool for extracting plain text from Wikipedia dumps
$(python-wikiextractor)-url = https://github.com/attardi/wikiextractor
$(python-wikiextractor)-srcurl = https://files.pythonhosted.org/packages/8e/6c/21050e72c7e42f606689b1a4cbfbbf65c81e79addc69a9451de450e2c672/wikiextractor-3.0.6.tar.gz
$(python-wikiextractor)-src = $(pkgsrcdir)/$(notdir $($(python-wikiextractor)-srcurl))
$(python-wikiextractor)-builddeps = $(python) $(python-pip)
$(python-wikiextractor)-prereqs = $(python)
$(python-wikiextractor)-srcdir = $(pkgsrcdir)/$(python-wikiextractor)
$(python-wikiextractor)-modulefile = $(modulefilesdir)/$(python-wikiextractor)
$(python-wikiextractor)-prefix = $(pkgdir)/$(python-wikiextractor)

$($(python-wikiextractor)-src): $(dir $($(python-wikiextractor)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-wikiextractor)-srcurl)

$($(python-wikiextractor)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-wikiextractor)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-wikiextractor)-prefix)/.pkgunpack: $$($(python-wikiextractor)-src) $($(python-wikiextractor)-srcdir)/.markerfile $($(python-wikiextractor)-prefix)/.markerfile $$(foreach dep,$$($(python-wikiextractor)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-wikiextractor)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-wikiextractor)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wikiextractor)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wikiextractor)-prefix)/.pkgunpack
	@touch $@

$($(python-wikiextractor)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wikiextractor)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wikiextractor)-prefix)/.pkgpatch
	@touch $@

$($(python-wikiextractor)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wikiextractor)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wikiextractor)-prefix)/.pkgbuild
	@touch $@

$($(python-wikiextractor)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-wikiextractor)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-wikiextractor)-prefix)/.pkgcheck
	cd $($(python-wikiextractor)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-wikiextractor)-builddeps) && \
		PYTHONPATH=$($(python-wikiextractor)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-wikiextractor)-prefix)
	@touch $@

$($(python-wikiextractor)-modulefile): $(modulefilesdir)/.markerfile $($(python-wikiextractor)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-wikiextractor)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-wikiextractor)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-wikiextractor)-description)\"" >>$@
	echo "module-whatis \"$($(python-wikiextractor)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-wikiextractor)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_WIKIEXTRACTOR_ROOT $($(python-wikiextractor)-prefix)" >>$@
	echo "prepend-path PATH $($(python-wikiextractor)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-wikiextractor)-prefix)" >>$@
	echo "set MSG \"$(python-wikiextractor)\"" >>$@

$(python-wikiextractor)-src: $($(python-wikiextractor)-src)
$(python-wikiextractor)-unpack: $($(python-wikiextractor)-prefix)/.pkgunpack
$(python-wikiextractor)-patch: $($(python-wikiextractor)-prefix)/.pkgpatch
$(python-wikiextractor)-build: $($(python-wikiextractor)-prefix)/.pkgbuild
$(python-wikiextractor)-check: $($(python-wikiextractor)-prefix)/.pkgcheck
$(python-wikiextractor)-install: $($(python-wikiextractor)-prefix)/.pkginstall
$(python-wikiextractor)-modulefile: $($(python-wikiextractor)-modulefile)
$(python-wikiextractor)-clean:
	rm -rf $($(python-wikiextractor)-modulefile)
	rm -rf $($(python-wikiextractor)-prefix)
	rm -rf $($(python-wikiextractor)-srcdir)
	rm -rf $($(python-wikiextractor)-src)
$(python-wikiextractor): $(python-wikiextractor)-src $(python-wikiextractor)-unpack $(python-wikiextractor)-patch $(python-wikiextractor)-build $(python-wikiextractor)-check $(python-wikiextractor)-install $(python-wikiextractor)-modulefile
