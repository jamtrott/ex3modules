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
# python-certifi-2020.6.20

python-certifi-version = 2020.6.20
python-certifi = python-certifi-$(python-certifi-version)
$(python-certifi)-description = Python package for providing Mozilla CA Bundle
$(python-certifi)-url = https://certifiio.readthedocs.io/en/latest/
$(python-certifi)-srcurl = https://files.pythonhosted.org/packages/40/a7/ded59fa294b85ca206082306bba75469a38ea1c7d44ea7e1d64f5443d67a/certifi-2020.6.20.tar.gz
$(python-certifi)-src = $(pkgsrcdir)/$(notdir $($(python-certifi)-srcurl))
$(python-certifi)-srcdir = $(pkgsrcdir)/$(python-certifi)
$(python-certifi)-builddeps = $(python)
$(python-certifi)-prereqs = $(python)
$(python-certifi)-modulefile = $(modulefilesdir)/$(python-certifi)
$(python-certifi)-prefix = $(pkgdir)/$(python-certifi)
$(python-certifi)-site-packages = $($(python-certifi)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-certifi)-src): $(dir $($(python-certifi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-certifi)-srcurl)

$($(python-certifi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-certifi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-certifi)-prefix)/.pkgunpack: $$($(python-certifi)-src) $($(python-certifi)-srcdir)/.markerfile $($(python-certifi)-prefix)/.markerfile
	tar -C $($(python-certifi)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-certifi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-certifi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-certifi)-prefix)/.pkgunpack
	@touch $@

$($(python-certifi)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-certifi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-certifi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-certifi)-prefix)/.pkgpatch
	cd $($(python-certifi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-certifi)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-certifi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-certifi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-certifi)-prefix)/.pkgbuild
	@touch $@

$($(python-certifi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-certifi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-certifi)-prefix)/.pkgcheck $($(python-certifi)-site-packages)/.markerfile
	cd $($(python-certifi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-certifi)-builddeps) && \
		PYTHONPATH=$($(python-certifi)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-certifi)-prefix)
	@touch $@

$($(python-certifi)-modulefile): $(modulefilesdir)/.markerfile $($(python-certifi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-certifi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-certifi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-certifi)-description)\"" >>$@
	echo "module-whatis \"$($(python-certifi)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-certifi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CERTIFI_ROOT $($(python-certifi)-prefix)" >>$@
	echo "prepend-path PATH $($(python-certifi)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-certifi)-site-packages)" >>$@
	echo "set MSG \"$(python-certifi)\"" >>$@

$(python-certifi)-src: $($(python-certifi)-src)
$(python-certifi)-unpack: $($(python-certifi)-prefix)/.pkgunpack
$(python-certifi)-patch: $($(python-certifi)-prefix)/.pkgpatch
$(python-certifi)-build: $($(python-certifi)-prefix)/.pkgbuild
$(python-certifi)-check: $($(python-certifi)-prefix)/.pkgcheck
$(python-certifi)-install: $($(python-certifi)-prefix)/.pkginstall
$(python-certifi)-modulefile: $($(python-certifi)-modulefile)
$(python-certifi)-clean:
	rm -rf $($(python-certifi)-modulefile)
	rm -rf $($(python-certifi)-prefix)
	rm -rf $($(python-certifi)-srcdir)
	rm -rf $($(python-certifi)-src)
$(python-certifi): $(python-certifi)-src $(python-certifi)-unpack $(python-certifi)-patch $(python-certifi)-build $(python-certifi)-check $(python-certifi)-install $(python-certifi)-modulefile
