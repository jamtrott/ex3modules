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
# python-pytz-2020.1

python-pytz-version = 2020.1
python-pytz = python-pytz-$(python-pytz-version)
$(python-pytz)-description = Timezone calculations and access to the Olson timezone database
$(python-pytz)-url = https://launchpad.net/pytz
$(python-pytz)-srcurl = https://files.pythonhosted.org/packages/f4/f6/94fee50f4d54f58637d4b9987a1b862aeb6cd969e73623e02c5c00755577/pytz-2020.1.tar.gz
$(python-pytz)-src = $(pkgsrcdir)/$(notdir $($(python-pytz)-srcurl))
$(python-pytz)-srcdir = $(pkgsrcdir)/$(python-pytz)
$(python-pytz)-builddeps = $(python)
$(python-pytz)-prereqs = $(python)
$(python-pytz)-modulefile = $(modulefilesdir)/$(python-pytz)
$(python-pytz)-prefix = $(pkgdir)/$(python-pytz)
$(python-pytz)-site-packages = $($(python-pytz)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pytz)-src): $(dir $($(python-pytz)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pytz)-srcurl)

$($(python-pytz)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytz)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pytz)-prefix)/.pkgunpack: $$($(python-pytz)-src) $($(python-pytz)-srcdir)/.markerfile $($(python-pytz)-prefix)/.markerfile $$(foreach dep,$$($(python-pytz)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pytz)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pytz)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytz)-prefix)/.pkgunpack
	@touch $@

$($(python-pytz)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pytz)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytz)-prefix)/.pkgpatch
	cd $($(python-pytz)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytz)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pytz)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytz)-prefix)/.pkgbuild
	cd $($(python-pytz)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytz)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-pytz)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pytz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pytz)-prefix)/.pkgcheck $($(python-pytz)-site-packages)/.markerfile
	cd $($(python-pytz)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pytz)-builddeps) && \
		PYTHONPATH=$($(python-pytz)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(python-pytz)-prefix)
	@touch $@

$($(python-pytz)-modulefile): $(modulefilesdir)/.markerfile $($(python-pytz)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pytz)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pytz)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pytz)-description)\"" >>$@
	echo "module-whatis \"$($(python-pytz)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pytz)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYTZ_ROOT $($(python-pytz)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pytz)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pytz)-site-packages)" >>$@
	echo "set MSG \"$(python-pytz)\"" >>$@

$(python-pytz)-src: $($(python-pytz)-src)
$(python-pytz)-unpack: $($(python-pytz)-prefix)/.pkgunpack
$(python-pytz)-patch: $($(python-pytz)-prefix)/.pkgpatch
$(python-pytz)-build: $($(python-pytz)-prefix)/.pkgbuild
$(python-pytz)-check: $($(python-pytz)-prefix)/.pkgcheck
$(python-pytz)-install: $($(python-pytz)-prefix)/.pkginstall
$(python-pytz)-modulefile: $($(python-pytz)-modulefile)
$(python-pytz)-clean:
	rm -rf $($(python-pytz)-modulefile)
	rm -rf $($(python-pytz)-prefix)
	rm -rf $($(python-pytz)-srcdir)
	rm -rf $($(python-pytz)-src)
$(python-pytz): $(python-pytz)-src $(python-pytz)-unpack $(python-pytz)-patch $(python-pytz)-build $(python-pytz)-check $(python-pytz)-install $(python-pytz)-modulefile
