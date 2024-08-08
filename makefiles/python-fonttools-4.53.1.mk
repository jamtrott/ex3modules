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
# python-fonttools-4.53.1

python-fonttools-version = 4.53.1
python-fonttools = python-fonttools-$(python-fonttools-version)
$(python-fonttools)-description = Tools to manipulate font files
$(python-fonttools)-url = http://github.com/fonttools/fonttools
$(python-fonttools)-srcurl = https://files.pythonhosted.org/packages/c6/cb/cd80a0da995adde8ade6044a8744aee0da5efea01301cadf770f7fbe7dcc/fonttools-4.53.1.tar.gz
$(python-fonttools)-src = $(pkgsrcdir)/$(notdir $($(python-fonttools)-srcurl))
$(python-fonttools)-builddeps = $(python) $(python-pip)
$(python-fonttools)-prereqs = $(python)
$(python-fonttools)-srcdir = $(pkgsrcdir)/$(python-fonttools)
$(python-fonttools)-modulefile = $(modulefilesdir)/$(python-fonttools)
$(python-fonttools)-prefix = $(pkgdir)/$(python-fonttools)

$($(python-fonttools)-src): $(dir $($(python-fonttools)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fonttools)-srcurl)

$($(python-fonttools)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fonttools)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fonttools)-prefix)/.pkgunpack: $$($(python-fonttools)-src) $($(python-fonttools)-srcdir)/.markerfile $($(python-fonttools)-prefix)/.markerfile $$(foreach dep,$$($(python-fonttools)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fonttools)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fonttools)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fonttools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fonttools)-prefix)/.pkgunpack
	@touch $@

$($(python-fonttools)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fonttools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fonttools)-prefix)/.pkgpatch
	cd $($(python-fonttools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fonttools)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fonttools)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fonttools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fonttools)-prefix)/.pkgbuild
	cd $($(python-fonttools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fonttools)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-fonttools)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fonttools)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fonttools)-prefix)/.pkgcheck
	cd $($(python-fonttools)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fonttools)-builddeps) && \
		PYTHONPATH=$($(python-fonttools)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-fonttools)-prefix)
	@touch $@

$($(python-fonttools)-modulefile): $(modulefilesdir)/.markerfile $($(python-fonttools)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fonttools)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fonttools)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fonttools)-description)\"" >>$@
	echo "module-whatis \"$($(python-fonttools)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fonttools)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FONTTOOLS_ROOT $($(python-fonttools)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fonttools)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fonttools)-prefix)" >>$@
	echo "set MSG \"$(python-fonttools)\"" >>$@

$(python-fonttools)-src: $($(python-fonttools)-src)
$(python-fonttools)-unpack: $($(python-fonttools)-prefix)/.pkgunpack
$(python-fonttools)-patch: $($(python-fonttools)-prefix)/.pkgpatch
$(python-fonttools)-build: $($(python-fonttools)-prefix)/.pkgbuild
$(python-fonttools)-check: $($(python-fonttools)-prefix)/.pkgcheck
$(python-fonttools)-install: $($(python-fonttools)-prefix)/.pkginstall
$(python-fonttools)-modulefile: $($(python-fonttools)-modulefile)
$(python-fonttools)-clean:
	rm -rf $($(python-fonttools)-modulefile)
	rm -rf $($(python-fonttools)-prefix)
	rm -rf $($(python-fonttools)-srcdir)
	rm -rf $($(python-fonttools)-src)
$(python-fonttools): $(python-fonttools)-src $(python-fonttools)-unpack $(python-fonttools)-patch $(python-fonttools)-build $(python-fonttools)-check $(python-fonttools)-install $(python-fonttools)-modulefile
