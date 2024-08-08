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
# python-gast-0.6.0

python-gast-version = 0.6.0
python-gast = python-gast-$(python-gast-version)
$(python-gast)-description = Python AST that abstracts the underlying Python version
$(python-gast)-url = https://github.com/serge-sans-paille/gast/
$(python-gast)-srcurl = https://files.pythonhosted.org/packages/3c/14/c566f5ca00c115db7725263408ff952b8ae6d6a4e792ef9c84e77d9af7a1/gast-0.6.0.tar.gz
$(python-gast)-src = $(pkgsrcdir)/$(notdir $($(python-gast)-srcurl))
$(python-gast)-builddeps = $(python) $(python-pip)
$(python-gast)-prereqs = $(python)
$(python-gast)-srcdir = $(pkgsrcdir)/$(python-gast)
$(python-gast)-modulefile = $(modulefilesdir)/$(python-gast)
$(python-gast)-prefix = $(pkgdir)/$(python-gast)

$($(python-gast)-src): $(dir $($(python-gast)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-gast)-srcurl)

$($(python-gast)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-gast)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-gast)-prefix)/.pkgunpack: $$($(python-gast)-src) $($(python-gast)-srcdir)/.markerfile $($(python-gast)-prefix)/.markerfile $$(foreach dep,$$($(python-gast)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-gast)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-gast)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-gast)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-gast)-prefix)/.pkgunpack
	@touch $@

$($(python-gast)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-gast)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-gast)-prefix)/.pkgpatch
	cd $($(python-gast)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-gast)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-gast)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-gast)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-gast)-prefix)/.pkgbuild
	cd $($(python-gast)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-gast)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-gast)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-gast)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-gast)-prefix)/.pkgcheck
	cd $($(python-gast)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-gast)-builddeps) && \
		PYTHONPATH=$($(python-gast)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-gast)-prefix)
	@touch $@

$($(python-gast)-modulefile): $(modulefilesdir)/.markerfile $($(python-gast)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-gast)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-gast)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-gast)-description)\"" >>$@
	echo "module-whatis \"$($(python-gast)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-gast)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_GAST_ROOT $($(python-gast)-prefix)" >>$@
	echo "prepend-path PATH $($(python-gast)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-gast)-prefix)" >>$@
	echo "set MSG \"$(python-gast)\"" >>$@

$(python-gast)-src: $($(python-gast)-src)
$(python-gast)-unpack: $($(python-gast)-prefix)/.pkgunpack
$(python-gast)-patch: $($(python-gast)-prefix)/.pkgpatch
$(python-gast)-build: $($(python-gast)-prefix)/.pkgbuild
$(python-gast)-check: $($(python-gast)-prefix)/.pkgcheck
$(python-gast)-install: $($(python-gast)-prefix)/.pkginstall
$(python-gast)-modulefile: $($(python-gast)-modulefile)
$(python-gast)-clean:
	rm -rf $($(python-gast)-modulefile)
	rm -rf $($(python-gast)-prefix)
	rm -rf $($(python-gast)-srcdir)
	rm -rf $($(python-gast)-src)
$(python-gast): $(python-gast)-src $(python-gast)-unpack $(python-gast)-patch $(python-gast)-build $(python-gast)-check $(python-gast)-install $(python-gast)-modulefile
