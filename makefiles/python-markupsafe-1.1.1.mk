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
# python-markupsafe-1.1.1

python-markupsafe-version = 1.1.1
python-markupsafe = python-markupsafe-$(python-markupsafe-version)
$(python-markupsafe)-description = Safely add untrusted strings to HTML/XML markup
$(python-markupsafe)-url = https://palletsprojects.com/p/markupsafe/
$(python-markupsafe)-srcurl = https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz
$(python-markupsafe)-src = $(pkgsrcdir)/$(notdir $($(python-markupsafe)-srcurl))
$(python-markupsafe)-srcdir = $(pkgsrcdir)/$(python-markupsafe)
$(python-markupsafe)-builddeps = $(python)
$(python-markupsafe)-prereqs = $(python)
$(python-markupsafe)-modulefile = $(modulefilesdir)/$(python-markupsafe)
$(python-markupsafe)-prefix = $(pkgdir)/$(python-markupsafe)
$(python-markupsafe)-site-packages = $($(python-markupsafe)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-markupsafe)-src): $(dir $($(python-markupsafe)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-markupsafe)-srcurl)

$($(python-markupsafe)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-markupsafe)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-markupsafe)-prefix)/.pkgunpack: $$($(python-markupsafe)-src) $($(python-markupsafe)-srcdir)/.markerfile $($(python-markupsafe)-prefix)/.markerfile
	tar -C $($(python-markupsafe)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-markupsafe)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-markupsafe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-markupsafe)-prefix)/.pkgunpack
	@touch $@

$($(python-markupsafe)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-markupsafe)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-markupsafe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-markupsafe)-prefix)/.pkgpatch
	cd $($(python-markupsafe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-markupsafe)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-markupsafe)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-markupsafe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-markupsafe)-prefix)/.pkgbuild
	cd $($(python-markupsafe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-markupsafe)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-markupsafe)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-markupsafe)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-markupsafe)-prefix)/.pkgcheck $($(python-markupsafe)-site-packages)/.markerfile
	cd $($(python-markupsafe)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-markupsafe)-builddeps) && \
		PYTHONPATH=$($(python-markupsafe)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-markupsafe)-prefix)
	@touch $@

$($(python-markupsafe)-modulefile): $(modulefilesdir)/.markerfile $($(python-markupsafe)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-markupsafe)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-markupsafe)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-markupsafe)-description)\"" >>$@
	echo "module-whatis \"$($(python-markupsafe)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-markupsafe)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MARKUPSAFE_ROOT $($(python-markupsafe)-prefix)" >>$@
	echo "prepend-path PATH $($(python-markupsafe)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-markupsafe)-site-packages)" >>$@
	echo "set MSG \"$(python-markupsafe)\"" >>$@

$(python-markupsafe)-src: $($(python-markupsafe)-src)
$(python-markupsafe)-unpack: $($(python-markupsafe)-prefix)/.pkgunpack
$(python-markupsafe)-patch: $($(python-markupsafe)-prefix)/.pkgpatch
$(python-markupsafe)-build: $($(python-markupsafe)-prefix)/.pkgbuild
$(python-markupsafe)-check: $($(python-markupsafe)-prefix)/.pkgcheck
$(python-markupsafe)-install: $($(python-markupsafe)-prefix)/.pkginstall
$(python-markupsafe)-modulefile: $($(python-markupsafe)-modulefile)
$(python-markupsafe)-clean:
	rm -rf $($(python-markupsafe)-modulefile)
	rm -rf $($(python-markupsafe)-prefix)
	rm -rf $($(python-markupsafe)-srcdir)
	rm -rf $($(python-markupsafe)-src)
$(python-markupsafe): $(python-markupsafe)-src $(python-markupsafe)-unpack $(python-markupsafe)-patch $(python-markupsafe)-build $(python-markupsafe)-check $(python-markupsafe)-install $(python-markupsafe)-modulefile
