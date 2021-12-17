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
# python-pycparser-2.20

python-pycparser-version = 2.20
python-pycparser = python-pycparser-$(python-pycparser-version)
$(python-pycparser)-description = Parser of the C language, written in pure Python using the PLY parsing library
$(python-pycparser)-url = https://github.com/eliben/pycparser
$(python-pycparser)-srcurl = https://github.com/eliben/pycparser/archive/release_v$(python-pycparser-version).tar.gz
$(python-pycparser)-src = $(pkgsrcdir)/$(notdir $($(python-pycparser)-srcurl))
$(python-pycparser)-srcdir = $(pkgsrcdir)/$(python-pycparser)
$(python-pycparser)-builddeps = $(python)
$(python-pycparser)-prereqs = $(python)
$(python-pycparser)-modulefile = $(modulefilesdir)/$(python-pycparser)
$(python-pycparser)-prefix = $(pkgdir)/$(python-pycparser)
$(python-pycparser)-site-packages = $($(python-pycparser)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pycparser)-src): $(dir $($(python-pycparser)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pycparser)-srcurl)

$($(python-pycparser)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pycparser)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pycparser)-prefix)/.pkgunpack: $$($(python-pycparser)-src) $($(python-pycparser)-srcdir)/.markerfile $($(python-pycparser)-prefix)/.markerfile $$(foreach dep,$$($(python-pycparser)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pycparser)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pycparser)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycparser)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycparser)-prefix)/.pkgunpack
	@touch $@

$($(python-pycparser)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pycparser)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycparser)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycparser)-prefix)/.pkgpatch
	cd $($(python-pycparser)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pycparser)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pycparser)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycparser)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycparser)-prefix)/.pkgbuild
	# cd $($(python-pycparser)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-pycparser)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-pycparser)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pycparser)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pycparser)-prefix)/.pkgcheck $($(python-pycparser)-site-packages)/.markerfile
	cd $($(python-pycparser)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pycparser)-builddeps) && \
		PYTHONPATH=$($(python-pycparser)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-pycparser)-prefix)
	@touch $@

$($(python-pycparser)-modulefile): $(modulefilesdir)/.markerfile $($(python-pycparser)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pycparser)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pycparser)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pycparser)-description)\"" >>$@
	echo "module-whatis \"$($(python-pycparser)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pycparser)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYCPARSER_ROOT $($(python-pycparser)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pycparser)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pycparser)-site-packages)" >>$@
	echo "set MSG \"$(python-pycparser)\"" >>$@

$(python-pycparser)-src: $($(python-pycparser)-src)
$(python-pycparser)-unpack: $($(python-pycparser)-prefix)/.pkgunpack
$(python-pycparser)-patch: $($(python-pycparser)-prefix)/.pkgpatch
$(python-pycparser)-build: $($(python-pycparser)-prefix)/.pkgbuild
$(python-pycparser)-check: $($(python-pycparser)-prefix)/.pkgcheck
$(python-pycparser)-install: $($(python-pycparser)-prefix)/.pkginstall
$(python-pycparser)-modulefile: $($(python-pycparser)-modulefile)
$(python-pycparser)-clean:
	rm -rf $($(python-pycparser)-modulefile)
	rm -rf $($(python-pycparser)-prefix)
	rm -rf $($(python-pycparser)-srcdir)
	rm -rf $($(python-pycparser)-src)
$(python-pycparser): $(python-pycparser)-src $(python-pycparser)-unpack $(python-pycparser)-patch $(python-pycparser)-build $(python-pycparser)-check $(python-pycparser)-install $(python-pycparser)-modulefile
