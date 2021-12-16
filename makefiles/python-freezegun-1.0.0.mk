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
# python-freezegun-1.0.0

python-freezegun-version = 1.0.0
python-freezegun = python-freezegun-$(python-freezegun-version)
$(python-freezegun)-description = Python test library for mocking the datetime module
$(python-freezegun)-url = https://github.com/spulec/freezegun
$(python-freezegun)-srcurl = https://files.pythonhosted.org/packages/38/65/0ad5d6f2d4357ba8aa1ab797bb3663dac8e94aa80bde17646decdb8c63ad/freezegun-1.0.0.tar.gz
$(python-freezegun)-src = $(pkgsrcdir)/$(notdir $($(python-freezegun)-srcurl))
$(python-freezegun)-srcdir = $(pkgsrcdir)/$(python-freezegun)
$(python-freezegun)-builddeps = $(python) $(python-pytest)
$(python-freezegun)-prereqs = $(python)
$(python-freezegun)-modulefile = $(modulefilesdir)/$(python-freezegun)
$(python-freezegun)-prefix = $(pkgdir)/$(python-freezegun)
$(python-freezegun)-site-packages = $($(python-freezegun)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-freezegun)-src): $(dir $($(python-freezegun)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-freezegun)-srcurl)

$($(python-freezegun)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-freezegun)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-freezegun)-prefix)/.pkgunpack: $$($(python-freezegun)-src) $($(python-freezegun)-srcdir)/.markerfile $($(python-freezegun)-prefix)/.markerfile $$(foreach dep,$$($(python-freezegun)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-freezegun)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-freezegun)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-freezegun)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-freezegun)-prefix)/.pkgunpack
	@touch $@

$($(python-freezegun)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-freezegun)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-freezegun)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-freezegun)-prefix)/.pkgpatch
	cd $($(python-freezegun)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-freezegun)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-freezegun)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-freezegun)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-freezegun)-prefix)/.pkgbuild
	cd $($(python-freezegun)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-freezegun)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-freezegun)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-freezegun)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-freezegun)-prefix)/.pkgcheck $($(python-freezegun)-site-packages)/.markerfile
	cd $($(python-freezegun)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-freezegun)-builddeps) && \
		PYTHONPATH=$($(python-freezegun)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-freezegun)-prefix)
	@touch $@

$($(python-freezegun)-modulefile): $(modulefilesdir)/.markerfile $($(python-freezegun)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-freezegun)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-freezegun)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-freezegun)-description)\"" >>$@
	echo "module-whatis \"$($(python-freezegun)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-freezegun)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FREEZEGUN_ROOT $($(python-freezegun)-prefix)" >>$@
	echo "prepend-path PATH $($(python-freezegun)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-freezegun)-site-packages)" >>$@
	echo "set MSG \"$(python-freezegun)\"" >>$@

$(python-freezegun)-src: $($(python-freezegun)-src)
$(python-freezegun)-unpack: $($(python-freezegun)-prefix)/.pkgunpack
$(python-freezegun)-patch: $($(python-freezegun)-prefix)/.pkgpatch
$(python-freezegun)-build: $($(python-freezegun)-prefix)/.pkgbuild
$(python-freezegun)-check: $($(python-freezegun)-prefix)/.pkgcheck
$(python-freezegun)-install: $($(python-freezegun)-prefix)/.pkginstall
$(python-freezegun)-modulefile: $($(python-freezegun)-modulefile)
$(python-freezegun)-clean:
	rm -rf $($(python-freezegun)-modulefile)
	rm -rf $($(python-freezegun)-prefix)
	rm -rf $($(python-freezegun)-srcdir)
	rm -rf $($(python-freezegun)-src)
$(python-freezegun): $(python-freezegun)-src $(python-freezegun)-unpack $(python-freezegun)-patch $(python-freezegun)-build $(python-freezegun)-check $(python-freezegun)-install $(python-freezegun)-modulefile
