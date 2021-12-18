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
# python-appdirs-1.4.4

python-appdirs-version = 1.4.4
python-appdirs = python-appdirs-$(python-appdirs-version)
$(python-appdirs)-description = Python module for determining appropriate platform-specific dirs
$(python-appdirs)-url = http://github.com/ActiveState/appdirs/
$(python-appdirs)-srcurl = https://files.pythonhosted.org/packages/d7/d8/05696357e0311f5b5c316d7b95f46c669dd9c15aaeecbb48c7d0aeb88c40/appdirs-1.4.4.tar.gz
$(python-appdirs)-src = $(pkgsrcdir)/$(notdir $($(python-appdirs)-srcurl))
$(python-appdirs)-srcdir = $(pkgsrcdir)/$(python-appdirs)
$(python-appdirs)-builddeps = $(python)
$(python-appdirs)-prereqs = $(python)
$(python-appdirs)-modulefile = $(modulefilesdir)/$(python-appdirs)
$(python-appdirs)-prefix = $(pkgdir)/$(python-appdirs)
$(python-appdirs)-site-packages = $($(python-appdirs)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-appdirs)-src): $(dir $($(python-appdirs)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-appdirs)-srcurl)

$($(python-appdirs)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-appdirs)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-appdirs)-prefix)/.pkgunpack: $$($(python-appdirs)-src) $($(python-appdirs)-srcdir)/.markerfile $($(python-appdirs)-prefix)/.markerfile $$(foreach dep,$$($(python-appdirs)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-appdirs)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-appdirs)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-appdirs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-appdirs)-prefix)/.pkgunpack
	@touch $@

$($(python-appdirs)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-appdirs)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-appdirs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-appdirs)-prefix)/.pkgpatch
	cd $($(python-appdirs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-appdirs)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-appdirs)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-appdirs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-appdirs)-prefix)/.pkgbuild
	cd $($(python-appdirs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-appdirs)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-appdirs)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-appdirs)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-appdirs)-prefix)/.pkgcheck $($(python-appdirs)-site-packages)/.markerfile
	cd $($(python-appdirs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-appdirs)-builddeps) && \
		PYTHONPATH=$($(python-appdirs)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(python-appdirs)-prefix)
	@touch $@

$($(python-appdirs)-modulefile): $(modulefilesdir)/.markerfile $($(python-appdirs)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-appdirs)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-appdirs)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-appdirs)-description)\"" >>$@
	echo "module-whatis \"$($(python-appdirs)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-appdirs)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_APPDIRS_ROOT $($(python-appdirs)-prefix)" >>$@
	echo "prepend-path PATH $($(python-appdirs)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-appdirs)-site-packages)" >>$@
	echo "set MSG \"$(python-appdirs)\"" >>$@

$(python-appdirs)-src: $($(python-appdirs)-src)
$(python-appdirs)-unpack: $($(python-appdirs)-prefix)/.pkgunpack
$(python-appdirs)-patch: $($(python-appdirs)-prefix)/.pkgpatch
$(python-appdirs)-build: $($(python-appdirs)-prefix)/.pkgbuild
$(python-appdirs)-check: $($(python-appdirs)-prefix)/.pkgcheck
$(python-appdirs)-install: $($(python-appdirs)-prefix)/.pkginstall
$(python-appdirs)-modulefile: $($(python-appdirs)-modulefile)
$(python-appdirs)-clean:
	rm -rf $($(python-appdirs)-modulefile)
	rm -rf $($(python-appdirs)-prefix)
	rm -rf $($(python-appdirs)-srcdir)
	rm -rf $($(python-appdirs)-src)
$(python-appdirs): $(python-appdirs)-src $(python-appdirs)-unpack $(python-appdirs)-patch $(python-appdirs)-build $(python-appdirs)-check $(python-appdirs)-install $(python-appdirs)-modulefile
