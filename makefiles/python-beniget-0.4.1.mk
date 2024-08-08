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
# python-beniget-0.4.1

python-beniget-version = 0.4.1
python-beniget = python-beniget-$(python-beniget-version)
$(python-beniget)-description = Extract semantic information about static Python code
$(python-beniget)-url = https://github.com/serge-sans-paille/beniget/
$(python-beniget)-srcurl = https://files.pythonhosted.org/packages/14/e7/50cbac38f77eca8efd39516be6651fdb9f3c4c0fab8cf2cf05f612578737/beniget-0.4.1.tar.gz
$(python-beniget)-src = $(pkgsrcdir)/$(notdir $($(python-beniget)-srcurl))
$(python-beniget)-builddeps = $(python) $(python-pip)
$(python-beniget)-prereqs = $(python)
$(python-beniget)-srcdir = $(pkgsrcdir)/$(python-beniget)
$(python-beniget)-modulefile = $(modulefilesdir)/$(python-beniget)
$(python-beniget)-prefix = $(pkgdir)/$(python-beniget)

$($(python-beniget)-src): $(dir $($(python-beniget)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-beniget)-srcurl)

$($(python-beniget)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-beniget)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-beniget)-prefix)/.pkgunpack: $$($(python-beniget)-src) $($(python-beniget)-srcdir)/.markerfile $($(python-beniget)-prefix)/.markerfile $$(foreach dep,$$($(python-beniget)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-beniget)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-beniget)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-beniget)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-beniget)-prefix)/.pkgunpack
	@touch $@

$($(python-beniget)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-beniget)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-beniget)-prefix)/.pkgpatch
	cd $($(python-beniget)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-beniget)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-beniget)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-beniget)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-beniget)-prefix)/.pkgbuild
	cd $($(python-beniget)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-beniget)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-beniget)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-beniget)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-beniget)-prefix)/.pkgcheck
	cd $($(python-beniget)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-beniget)-builddeps) && \
		PYTHONPATH=$($(python-beniget)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-beniget)-prefix)
	@touch $@

$($(python-beniget)-modulefile): $(modulefilesdir)/.markerfile $($(python-beniget)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-beniget)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-beniget)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-beniget)-description)\"" >>$@
	echo "module-whatis \"$($(python-beniget)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-beniget)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_BENIGET_ROOT $($(python-beniget)-prefix)" >>$@
	echo "prepend-path PATH $($(python-beniget)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-beniget)-prefix)" >>$@
	echo "set MSG \"$(python-beniget)\"" >>$@

$(python-beniget)-src: $($(python-beniget)-src)
$(python-beniget)-unpack: $($(python-beniget)-prefix)/.pkgunpack
$(python-beniget)-patch: $($(python-beniget)-prefix)/.pkgpatch
$(python-beniget)-build: $($(python-beniget)-prefix)/.pkgbuild
$(python-beniget)-check: $($(python-beniget)-prefix)/.pkgcheck
$(python-beniget)-install: $($(python-beniget)-prefix)/.pkginstall
$(python-beniget)-modulefile: $($(python-beniget)-modulefile)
$(python-beniget)-clean:
	rm -rf $($(python-beniget)-modulefile)
	rm -rf $($(python-beniget)-prefix)
	rm -rf $($(python-beniget)-srcdir)
	rm -rf $($(python-beniget)-src)
$(python-beniget): $(python-beniget)-src $(python-beniget)-unpack $(python-beniget)-patch $(python-beniget)-build $(python-beniget)-check $(python-beniget)-install $(python-beniget)-modulefile
