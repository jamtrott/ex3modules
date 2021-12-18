# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
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
# python-six-1.15.0

python-six-version = 1.15.0
python-six = python-six-$(python-six-version)
$(python-six)-description = Python 2 and 3 compatibility library
$(python-six)-url = https://github.com/benjaminp/six
$(python-six)-srcurl = https://github.com/benjaminp/six/archive/$(python-six-version).tar.gz
$(python-six)-src = $(pkgsrcdir)/python-six-$(notdir $($(python-six)-srcurl))
$(python-six)-srcdir = $(pkgsrcdir)/$(python-six)
$(python-six)-builddeps = $(python) $(python-wheel)
$(python-six)-prereqs = $(python)
$(python-six)-modulefile = $(modulefilesdir)/$(python-six)
$(python-six)-prefix = $(pkgdir)/$(python-six)
$(python-six)-site-packages = $($(python-six)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-six)-src): $(dir $($(python-six)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-six)-srcurl)

$($(python-six)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-six)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-six)-prefix)/.pkgunpack: $$($(python-six)-src) $($(python-six)-srcdir)/.markerfile $($(python-six)-prefix)/.markerfile $$(foreach dep,$$($(python-six)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-six)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-six)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-six)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-six)-prefix)/.pkgunpack
	@touch $@

$($(python-six)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-six)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-six)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-six)-prefix)/.pkgpatch
	cd $($(python-six)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-six)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-six)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-six)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-six)-prefix)/.pkgbuild
	@touch $@

$($(python-six)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-six)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-six)-prefix)/.pkgcheck $($(python-six)-site-packages)/.markerfile
	cd $($(python-six)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-six)-builddeps) && \
		PYTHONPATH=$($(python-six)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-six)-prefix)
	@touch $@

$($(python-six)-modulefile): $(modulefilesdir)/.markerfile $($(python-six)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-six)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-six)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-six)-description)\"" >>$@
	echo "module-whatis \"$($(python-six)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-six)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SIX_ROOT $($(python-six)-prefix)" >>$@
	echo "prepend-path PATH $($(python-six)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-six)-site-packages)" >>$@
	echo "set MSG \"$(python-six)\"" >>$@

$(python-six)-src: $($(python-six)-src)
$(python-six)-unpack: $($(python-six)-prefix)/.pkgunpack
$(python-six)-patch: $($(python-six)-prefix)/.pkgpatch
$(python-six)-build: $($(python-six)-prefix)/.pkgbuild
$(python-six)-check: $($(python-six)-prefix)/.pkgcheck
$(python-six)-install: $($(python-six)-prefix)/.pkginstall
$(python-six)-modulefile: $($(python-six)-modulefile)
$(python-six)-clean:
	rm -rf $($(python-six)-modulefile)
	rm -rf $($(python-six)-prefix)
	rm -rf $($(python-six)-srcdir)
	rm -rf $($(python-six)-src)
$(python-six): $(python-six)-src $(python-six)-unpack $(python-six)-patch $(python-six)-build $(python-six)-check $(python-six)-install $(python-six)-modulefile
