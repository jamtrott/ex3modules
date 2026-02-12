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
# python-nltk-3.9.2

python-nltk-version = 3.9.2
python-nltk = python-nltk-$(python-nltk-version)
$(python-nltk)-description = Natural Language Toolkit
$(python-nltk)-url = https://www.nltk.org/
$(python-nltk)-srcurl = https://files.pythonhosted.org/packages/f9/76/3a5e4312c19a028770f86fd7c058cf9f4ec4321c6cf7526bab998a5b683c/nltk-3.9.2.tar.gz
$(python-nltk)-src = $(pkgsrcdir)/$(notdir $($(python-nltk)-srcurl))
$(python-nltk)-builddeps = $(python) $(python-pip) $(python-regex)
$(python-nltk)-prereqs = $(python) $(python-regex)
$(python-nltk)-srcdir = $(pkgsrcdir)/$(python-nltk)
$(python-nltk)-modulefile = $(modulefilesdir)/$(python-nltk)
$(python-nltk)-prefix = $(pkgdir)/$(python-nltk)

$($(python-nltk)-src): $(dir $($(python-nltk)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-nltk)-srcurl)

$($(python-nltk)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-nltk)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-nltk)-prefix)/.pkgunpack: $$($(python-nltk)-src) $($(python-nltk)-srcdir)/.markerfile $($(python-nltk)-prefix)/.markerfile $$(foreach dep,$$($(python-nltk)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-nltk)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-nltk)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nltk)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nltk)-prefix)/.pkgunpack
	@touch $@

$($(python-nltk)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nltk)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nltk)-prefix)/.pkgpatch
	@touch $@

$($(python-nltk)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nltk)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nltk)-prefix)/.pkgbuild
	@touch $@

$($(python-nltk)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nltk)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nltk)-prefix)/.pkgcheck
	cd $($(python-nltk)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-nltk)-builddeps) && \
		PYTHONPATH=$($(python-nltk)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-nltk)-prefix)
	@touch $@

$($(python-nltk)-modulefile): $(modulefilesdir)/.markerfile $($(python-nltk)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-nltk)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-nltk)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-nltk)-description)\"" >>$@
	echo "module-whatis \"$($(python-nltk)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-nltk)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_NLTK_ROOT $($(python-nltk)-prefix)" >>$@
	echo "prepend-path PATH $($(python-nltk)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-nltk)-prefix)" >>$@
	echo "set MSG \"$(python-nltk)\"" >>$@

$(python-nltk)-src: $($(python-nltk)-src)
$(python-nltk)-unpack: $($(python-nltk)-prefix)/.pkgunpack
$(python-nltk)-patch: $($(python-nltk)-prefix)/.pkgpatch
$(python-nltk)-build: $($(python-nltk)-prefix)/.pkgbuild
$(python-nltk)-check: $($(python-nltk)-prefix)/.pkgcheck
$(python-nltk)-install: $($(python-nltk)-prefix)/.pkginstall
$(python-nltk)-modulefile: $($(python-nltk)-modulefile)
$(python-nltk)-clean:
	rm -rf $($(python-nltk)-modulefile)
	rm -rf $($(python-nltk)-prefix)
	rm -rf $($(python-nltk)-srcdir)
	rm -rf $($(python-nltk)-src)
$(python-nltk): $(python-nltk)-src $(python-nltk)-unpack $(python-nltk)-patch $(python-nltk)-build $(python-nltk)-check $(python-nltk)-install $(python-nltk)-modulefile
