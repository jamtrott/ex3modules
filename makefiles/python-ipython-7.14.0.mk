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
# python-ipython-7.14.0

python-ipython-version = 7.14.0
python-ipython = python-ipython-$(python-ipython-version)
$(python-ipython)-description = Interactive Python shell
$(python-ipython)-url = https://www.ipython.org/
$(python-ipython)-srcurl = https://github.com/ipython/ipython/archive/$(python-ipython-version).tar.gz
$(python-ipython)-src = $(pkgsrcdir)/python-ipython-$(notdir $($(python-ipython)-srcurl))
$(python-ipython)-srcdir = $(pkgsrcdir)/$(python-ipython)
$(python-ipython)-builddeps = $(python)
$(python-ipython)-prereqs = $(python)
$(python-ipython)-modulefile = $(modulefilesdir)/$(python-ipython)
$(python-ipython)-prefix = $(pkgdir)/$(python-ipython)
$(python-ipython)-site-packages = $($(python-ipython)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-ipython)-src): $(dir $($(python-ipython)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-ipython)-srcurl)

$($(python-ipython)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ipython)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ipython)-prefix)/.pkgunpack: $$($(python-ipython)-src) $($(python-ipython)-srcdir)/.markerfile $($(python-ipython)-prefix)/.markerfile $$(foreach dep,$$($(python-ipython)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-ipython)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-ipython)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipython)-prefix)/.pkgunpack
	@touch $@

$($(python-ipython)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-ipython)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipython)-prefix)/.pkgpatch
	cd $($(python-ipython)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ipython)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-ipython)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipython)-prefix)/.pkgbuild
	@touch $@

$($(python-ipython)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipython)-prefix)/.pkgcheck $($(python-ipython)-site-packages)/.markerfile
	cd $($(python-ipython)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ipython)-builddeps) && \
		PYTHONPATH=$($(python-ipython)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-ipython)-prefix)
	@touch $@

$($(python-ipython)-modulefile): $(modulefilesdir)/.markerfile $($(python-ipython)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-ipython)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-ipython)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-ipython)-description)\"" >>$@
	echo "module-whatis \"$($(python-ipython)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-ipython)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_IPYTHON_ROOT $($(python-ipython)-prefix)" >>$@
	echo "prepend-path PATH $($(python-ipython)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-ipython)-site-packages)" >>$@
	echo "set MSG \"$(python-ipython)\"" >>$@

$(python-ipython)-src: $($(python-ipython)-src)
$(python-ipython)-unpack: $($(python-ipython)-prefix)/.pkgunpack
$(python-ipython)-patch: $($(python-ipython)-prefix)/.pkgpatch
$(python-ipython)-build: $($(python-ipython)-prefix)/.pkgbuild
$(python-ipython)-check: $($(python-ipython)-prefix)/.pkgcheck
$(python-ipython)-install: $($(python-ipython)-prefix)/.pkginstall
$(python-ipython)-modulefile: $($(python-ipython)-modulefile)
$(python-ipython)-clean:
	rm -rf $($(python-ipython)-modulefile)
	rm -rf $($(python-ipython)-prefix)
	rm -rf $($(python-ipython)-srcdir)
	rm -rf $($(python-ipython)-src)
$(python-ipython): $(python-ipython)-src $(python-ipython)-unpack $(python-ipython)-patch $(python-ipython)-build $(python-ipython)-check $(python-ipython)-install $(python-ipython)-modulefile
