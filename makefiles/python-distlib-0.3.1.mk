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
# python-distlib-0.3.1

python-distlib-version = 0.3.1
python-distlib = python-distlib-$(python-distlib-version)
$(python-distlib)-description = Distribution utilities
$(python-distlib)-url = https://bitbucket.org/pypa/distlib/
$(python-distlib)-srcurl = https://files.pythonhosted.org/packages/2f/83/1eba07997b8ba58d92b3e51445d5bf36f9fba9cb8166bcae99b9c3464841/distlib-0.3.1.zip
$(python-distlib)-src = $(pkgsrcdir)/$(notdir $($(python-distlib)-srcurl))
$(python-distlib)-srcdir = $(pkgsrcdir)/$(python-distlib)
$(python-distlib)-builddeps = $(python)
$(python-distlib)-prereqs = $(python)
$(python-distlib)-modulefile = $(modulefilesdir)/$(python-distlib)
$(python-distlib)-prefix = $(pkgdir)/$(python-distlib)
$(python-distlib)-site-packages = $($(python-distlib)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-distlib)-src): $(dir $($(python-distlib)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-distlib)-srcurl)

$($(python-distlib)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-distlib)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-distlib)-prefix)/.pkgunpack: $$($(python-distlib)-src) $($(python-distlib)-srcdir)/.markerfile $($(python-distlib)-prefix)/.markerfile $$(foreach dep,$$($(python-distlib)-builddeps),$(modulefilesdir)/$$(dep))
	unzip -d $($(python-distlib)-srcdir) $<
	@touch $@

$($(python-distlib)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distlib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distlib)-prefix)/.pkgunpack
	@touch $@

$($(python-distlib)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-distlib)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distlib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distlib)-prefix)/.pkgpatch
	cd $($(python-distlib)-srcdir)/distlib-$(python-distlib-version) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-distlib)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-distlib)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distlib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distlib)-prefix)/.pkgbuild
	# cd $($(python-distlib)-srcdir)/distlib-$(python-distlib-version) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-distlib)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-distlib)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distlib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distlib)-prefix)/.pkgcheck $($(python-distlib)-site-packages)/.markerfile
	cd $($(python-distlib)-srcdir)/distlib-$(python-distlib-version) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-distlib)-builddeps) && \
		PYTHONPATH=$($(python-distlib)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-distlib)-prefix)
	@touch $@

$($(python-distlib)-modulefile): $(modulefilesdir)/.markerfile $($(python-distlib)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-distlib)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-distlib)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-distlib)-description)\"" >>$@
	echo "module-whatis \"$($(python-distlib)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-distlib)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_DISTLIB_ROOT $($(python-distlib)-prefix)" >>$@
	echo "prepend-path PATH $($(python-distlib)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-distlib)-site-packages)" >>$@
	echo "set MSG \"$(python-distlib)\"" >>$@

$(python-distlib)-src: $($(python-distlib)-src)
$(python-distlib)-unpack: $($(python-distlib)-prefix)/.pkgunpack
$(python-distlib)-patch: $($(python-distlib)-prefix)/.pkgpatch
$(python-distlib)-build: $($(python-distlib)-prefix)/.pkgbuild
$(python-distlib)-check: $($(python-distlib)-prefix)/.pkgcheck
$(python-distlib)-install: $($(python-distlib)-prefix)/.pkginstall
$(python-distlib)-modulefile: $($(python-distlib)-modulefile)
$(python-distlib)-clean:
	rm -rf $($(python-distlib)-modulefile)
	rm -rf $($(python-distlib)-prefix)
	rm -rf $($(python-distlib)-srcdir)
	rm -rf $($(python-distlib)-src)
$(python-distlib): $(python-distlib)-src $(python-distlib)-unpack $(python-distlib)-patch $(python-distlib)-build $(python-distlib)-check $(python-distlib)-install $(python-distlib)-modulefile
