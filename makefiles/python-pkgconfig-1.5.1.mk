# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-pkgconfig-1.5.1

python-pkgconfig-version = 1.5.1
python-pkgconfig = python-pkgconfig-$(python-pkgconfig-version)
$(python-pkgconfig)-description = Python interface to the pkg-config command line tool
$(python-pkgconfig)-url = https://github.com/matze/pkgconfig/
$(python-pkgconfig)-srcurl = https://files.pythonhosted.org/packages/6e/a9/ff67ef67217dfdf2aca847685fe789f82b931a6957a3deac861297585db6/pkgconfig-1.5.1.tar.gz
$(python-pkgconfig)-src = $(pkgsrcdir)/$(notdir $($(python-pkgconfig)-srcurl))
$(python-pkgconfig)-srcdir = $(pkgsrcdir)/$(python-pkgconfig)
$(python-pkgconfig)-builddeps = $(python) $(python-pip)
$(python-pkgconfig)-prereqs = $(python)
$(python-pkgconfig)-modulefile = $(modulefilesdir)/$(python-pkgconfig)
$(python-pkgconfig)-prefix = $(pkgdir)/$(python-pkgconfig)
$(python-pkgconfig)-site-packages = $($(python-pkgconfig)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pkgconfig)-src): $(dir $($(python-pkgconfig)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pkgconfig)-srcurl)

$($(python-pkgconfig)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pkgconfig)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pkgconfig)-prefix)/.pkgunpack: $$($(python-pkgconfig)-src) $($(python-pkgconfig)-srcdir)/.markerfile $($(python-pkgconfig)-prefix)/.markerfile $$(foreach dep,$$($(python-pkgconfig)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pkgconfig)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pkgconfig)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pkgconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pkgconfig)-prefix)/.pkgunpack
	@touch $@

$($(python-pkgconfig)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pkgconfig)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pkgconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pkgconfig)-prefix)/.pkgpatch
	cd $($(python-pkgconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pkgconfig)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pkgconfig)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pkgconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pkgconfig)-prefix)/.pkgbuild
	@touch $@

$($(python-pkgconfig)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pkgconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pkgconfig)-prefix)/.pkgcheck $($(python-pkgconfig)-site-packages)/.markerfile
	cd $($(python-pkgconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pkgconfig)-builddeps) && \
		PYTHONPATH=$($(python-pkgconfig)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-pkgconfig)-prefix)
	@touch $@

$($(python-pkgconfig)-modulefile): $(modulefilesdir)/.markerfile $($(python-pkgconfig)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pkgconfig)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pkgconfig)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pkgconfig)-description)\"" >>$@
	echo "module-whatis \"$($(python-pkgconfig)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pkgconfig)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PKGCONFIG_ROOT $($(python-pkgconfig)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pkgconfig)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pkgconfig)-site-packages)" >>$@
	echo "set MSG \"$(python-pkgconfig)\"" >>$@

$(python-pkgconfig)-src: $($(python-pkgconfig)-src)
$(python-pkgconfig)-unpack: $($(python-pkgconfig)-prefix)/.pkgunpack
$(python-pkgconfig)-patch: $($(python-pkgconfig)-prefix)/.pkgpatch
$(python-pkgconfig)-build: $($(python-pkgconfig)-prefix)/.pkgbuild
$(python-pkgconfig)-check: $($(python-pkgconfig)-prefix)/.pkgcheck
$(python-pkgconfig)-install: $($(python-pkgconfig)-prefix)/.pkginstall
$(python-pkgconfig)-modulefile: $($(python-pkgconfig)-modulefile)
$(python-pkgconfig)-clean:
	rm -rf $($(python-pkgconfig)-modulefile)
	rm -rf $($(python-pkgconfig)-prefix)
	rm -rf $($(python-pkgconfig)-srcdir)
	rm -rf $($(python-pkgconfig)-src)
$(python-pkgconfig): $(python-pkgconfig)-src $(python-pkgconfig)-unpack $(python-pkgconfig)-patch $(python-pkgconfig)-build $(python-pkgconfig)-check $(python-pkgconfig)-install $(python-pkgconfig)-modulefile
