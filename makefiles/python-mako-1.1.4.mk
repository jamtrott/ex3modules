# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# python-mako-1.1.4

python-mako-version = 1.1.4
python-mako = python-mako-$(python-mako-version)
$(python-mako)-description = Python template library
$(python-mako)-url = https://www.makotemplates.org/
$(python-mako)-srcurl = https://files.pythonhosted.org/packages/5c/db/2d2d88b924aa4674a080aae83b59ea19d593250bfe5ed789947c21736785/Mako-1.1.4.tar.gz
$(python-mako)-src = $(pkgsrcdir)/$(notdir $($(python-mako)-srcurl))
$(python-mako)-srcdir = $(pkgsrcdir)/$(python-mako)
$(python-mako)-builddeps = $(python) $(python-tox)
$(python-mako)-prereqs = $(python)
$(python-mako)-modulefile = $(modulefilesdir)/$(python-mako)
$(python-mako)-prefix = $(pkgdir)/$(python-mako)
$(python-mako)-site-packages = $($(python-mako)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-mako)-src): $(dir $($(python-mako)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-mako)-srcurl)

$($(python-mako)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mako)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mako)-prefix)/.pkgunpack: $$($(python-mako)-src) $($(python-mako)-srcdir)/.markerfile $($(python-mako)-prefix)/.markerfile $$(foreach dep,$$($(python-mako)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-mako)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-mako)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mako)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mako)-prefix)/.pkgunpack
	@touch $@

$($(python-mako)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-mako)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mako)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mako)-prefix)/.pkgpatch
	cd $($(python-mako)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mako)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-mako)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mako)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mako)-prefix)/.pkgbuild
	@touch $@

$($(python-mako)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mako)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mako)-prefix)/.pkgcheck $($(python-mako)-site-packages)/.markerfile
	cd $($(python-mako)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mako)-builddeps) && \
		PYTHONPATH=$($(python-mako)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-mako)-prefix)
	@touch $@

$($(python-mako)-modulefile): $(modulefilesdir)/.markerfile $($(python-mako)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-mako)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-mako)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-mako)-description)\"" >>$@
	echo "module-whatis \"$($(python-mako)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-mako)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MAKO_ROOT $($(python-mako)-prefix)" >>$@
	echo "prepend-path PATH $($(python-mako)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-mako)-site-packages)" >>$@
	echo "set MSG \"$(python-mako)\"" >>$@

$(python-mako)-src: $($(python-mako)-src)
$(python-mako)-unpack: $($(python-mako)-prefix)/.pkgunpack
$(python-mako)-patch: $($(python-mako)-prefix)/.pkgpatch
$(python-mako)-build: $($(python-mako)-prefix)/.pkgbuild
$(python-mako)-check: $($(python-mako)-prefix)/.pkgcheck
$(python-mako)-install: $($(python-mako)-prefix)/.pkginstall
$(python-mako)-modulefile: $($(python-mako)-modulefile)
$(python-mako)-clean:
	rm -rf $($(python-mako)-modulefile)
	rm -rf $($(python-mako)-prefix)
	rm -rf $($(python-mako)-srcdir)
	rm -rf $($(python-mako)-src)
$(python-mako): $(python-mako)-src $(python-mako)-unpack $(python-mako)-patch $(python-mako)-build $(python-mako)-check $(python-mako)-install $(python-mako)-modulefile
