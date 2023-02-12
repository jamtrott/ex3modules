# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# python-typing_extensions-4.4.0

python-typing_extensions-version = 4.4.0
python-typing_extensions = python-typing_extensions-$(python-typing_extensions-version)
$(python-typing_extensions)-description = Backported and Experimental Type Hints for Python 3.7+
$(python-typing_extensions)-url = https://github.com/python/typing_extensions
$(python-typing_extensions)-srcurl = https://files.pythonhosted.org/packages/e3/a7/8f4e456ef0adac43f452efc2d0e4b242ab831297f1bac60ac815d37eb9cf/typing_extensions-4.4.0.tar.gz
$(python-typing_extensions)-src = $(pkgsrcdir)/$(notdir $($(python-typing_extensions)-srcurl))
$(python-typing_extensions)-builddeps = $(python) $(python-pip)
$(python-typing_extensions)-prereqs = $(python)
$(python-typing_extensions)-srcdir = $(pkgsrcdir)/$(python-typing_extensions)
$(python-typing_extensions)-modulefile = $(modulefilesdir)/$(python-typing_extensions)
$(python-typing_extensions)-prefix = $(pkgdir)/$(python-typing_extensions)
$(python-typing_extensions)-site-packages = $($(python-typing_extensions)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-typing_extensions)-src): $(dir $($(python-typing_extensions)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-typing_extensions)-srcurl)

$($(python-typing_extensions)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-typing_extensions)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-typing_extensions)-prefix)/.pkgunpack: $$($(python-typing_extensions)-src) $($(python-typing_extensions)-srcdir)/.markerfile $($(python-typing_extensions)-prefix)/.markerfile $$(foreach dep,$$($(python-typing_extensions)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-typing_extensions)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-typing_extensions)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typing_extensions)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typing_extensions)-prefix)/.pkgunpack
	@touch $@

$($(python-typing_extensions)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-typing_extensions)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typing_extensions)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typing_extensions)-prefix)/.pkgpatch
	@touch $@

$($(python-typing_extensions)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typing_extensions)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typing_extensions)-prefix)/.pkgbuild
	@touch $@

$($(python-typing_extensions)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typing_extensions)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typing_extensions)-prefix)/.pkgcheck $($(python-typing_extensions)-site-packages)/.markerfile
	cd $($(python-typing_extensions)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-typing_extensions)-builddeps) && \
		PYTHONPATH=$($(python-typing_extensions)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-typing_extensions)-prefix)
	@touch $@

$($(python-typing_extensions)-modulefile): $(modulefilesdir)/.markerfile $($(python-typing_extensions)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-typing_extensions)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-typing_extensions)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-typing_extensions)-description)\"" >>$@
	echo "module-whatis \"$($(python-typing_extensions)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-typing_extensions)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TYPING_EXTENSIONS_ROOT $($(python-typing_extensions)-prefix)" >>$@
	echo "prepend-path PATH $($(python-typing_extensions)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-typing_extensions)-site-packages)" >>$@
	echo "set MSG \"$(python-typing_extensions)\"" >>$@

$(python-typing_extensions)-src: $($(python-typing_extensions)-src)
$(python-typing_extensions)-unpack: $($(python-typing_extensions)-prefix)/.pkgunpack
$(python-typing_extensions)-patch: $($(python-typing_extensions)-prefix)/.pkgpatch
$(python-typing_extensions)-build: $($(python-typing_extensions)-prefix)/.pkgbuild
$(python-typing_extensions)-check: $($(python-typing_extensions)-prefix)/.pkgcheck
$(python-typing_extensions)-install: $($(python-typing_extensions)-prefix)/.pkginstall
$(python-typing_extensions)-modulefile: $($(python-typing_extensions)-modulefile)
$(python-typing_extensions)-clean:
	rm -rf $($(python-typing_extensions)-modulefile)
	rm -rf $($(python-typing_extensions)-prefix)
	rm -rf $($(python-typing_extensions)-srcdir)
	rm -rf $($(python-typing_extensions)-src)
$(python-typing_extensions): $(python-typing_extensions)-src $(python-typing_extensions)-unpack $(python-typing_extensions)-patch $(python-typing_extensions)-build $(python-typing_extensions)-check $(python-typing_extensions)-install $(python-typing_extensions)-modulefile
