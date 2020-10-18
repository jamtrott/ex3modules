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
# python-apipkg-1.5

python-apipkg-version = 1.5
python-apipkg = python-apipkg-$(python-apipkg-version)
$(python-apipkg)-description = apipkg: namespace control and lazy-import mechanism
$(python-apipkg)-url = https://github.com/pytest-dev/apipkg
$(python-apipkg)-srcurl = https://files.pythonhosted.org/packages/a8/af/07a13b1560ebcc9bf4dd439aeb63243cbd8d374f4f328691470d6a9b9804/apipkg-1.5.tar.gz
$(python-apipkg)-src = $(pkgsrcdir)/$(notdir $($(python-apipkg)-srcurl))
$(python-apipkg)-srcdir = $(pkgsrcdir)/$(python-apipkg)
$(python-apipkg)-builddeps = $(python) $(python-py) $(python-pytest)
$(python-apipkg)-prereqs = $(python)
$(python-apipkg)-modulefile = $(modulefilesdir)/$(python-apipkg)
$(python-apipkg)-prefix = $(pkgdir)/$(python-apipkg)
$(python-apipkg)-site-packages = $($(python-apipkg)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-apipkg)-src): $(dir $($(python-apipkg)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-apipkg)-srcurl)

$($(python-apipkg)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-apipkg)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-apipkg)-prefix)/.pkgunpack: $$($(python-apipkg)-src) $($(python-apipkg)-srcdir)/.markerfile $($(python-apipkg)-prefix)/.markerfile
	tar -C $($(python-apipkg)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-apipkg)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-apipkg)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-apipkg)-prefix)/.pkgunpack
	@touch $@

$($(python-apipkg)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-apipkg)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-apipkg)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-apipkg)-prefix)/.pkgpatch
	cd $($(python-apipkg)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-apipkg)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-apipkg)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-apipkg)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-apipkg)-prefix)/.pkgbuild
	cd $($(python-apipkg)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-apipkg)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-apipkg)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-apipkg)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-apipkg)-prefix)/.pkgcheck $($(python-apipkg)-site-packages)/.markerfile
	cd $($(python-apipkg)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-apipkg)-builddeps) && \
		PYTHONPATH=$($(python-apipkg)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-apipkg)-prefix)
	@touch $@

$($(python-apipkg)-modulefile): $(modulefilesdir)/.markerfile $($(python-apipkg)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-apipkg)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-apipkg)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-apipkg)-description)\"" >>$@
	echo "module-whatis \"$($(python-apipkg)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-apipkg)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_APIPKG_ROOT $($(python-apipkg)-prefix)" >>$@
	echo "prepend-path PATH $($(python-apipkg)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-apipkg)-site-packages)" >>$@
	echo "set MSG \"$(python-apipkg)\"" >>$@

$(python-apipkg)-src: $($(python-apipkg)-src)
$(python-apipkg)-unpack: $($(python-apipkg)-prefix)/.pkgunpack
$(python-apipkg)-patch: $($(python-apipkg)-prefix)/.pkgpatch
$(python-apipkg)-build: $($(python-apipkg)-prefix)/.pkgbuild
$(python-apipkg)-check: $($(python-apipkg)-prefix)/.pkgcheck
$(python-apipkg)-install: $($(python-apipkg)-prefix)/.pkginstall
$(python-apipkg)-modulefile: $($(python-apipkg)-modulefile)
$(python-apipkg)-clean:
	rm -rf $($(python-apipkg)-modulefile)
	rm -rf $($(python-apipkg)-prefix)
	rm -rf $($(python-apipkg)-srcdir)
	rm -rf $($(python-apipkg)-src)
$(python-apipkg): $(python-apipkg)-src $(python-apipkg)-unpack $(python-apipkg)-patch $(python-apipkg)-build $(python-apipkg)-check $(python-apipkg)-install $(python-apipkg)-modulefile
