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
# python-imagesize-1.2.0

python-imagesize-version = 1.2.0
python-imagesize = python-imagesize-$(python-imagesize-version)
$(python-imagesize)-description = Getting image size from png/jpeg/jpeg2000/gif file
$(python-imagesize)-url = https://github.com/shibukawa/imagesize_py
$(python-imagesize)-srcurl = https://files.pythonhosted.org/packages/e4/9f/0452b459c8ba97e07c3cd2bd243783936a992006cf4cd1353c314a927028/imagesize-1.2.0.tar.gz
$(python-imagesize)-src = $(pkgsrcdir)/$(notdir $($(python-imagesize)-srcurl))
$(python-imagesize)-srcdir = $(pkgsrcdir)/$(python-imagesize)
$(python-imagesize)-builddeps = $(python)
$(python-imagesize)-prereqs = $(python)
$(python-imagesize)-modulefile = $(modulefilesdir)/$(python-imagesize)
$(python-imagesize)-prefix = $(pkgdir)/$(python-imagesize)
$(python-imagesize)-site-packages = $($(python-imagesize)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-imagesize)-src): $(dir $($(python-imagesize)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-imagesize)-srcurl)

$($(python-imagesize)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-imagesize)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-imagesize)-prefix)/.pkgunpack: $$($(python-imagesize)-src) $($(python-imagesize)-srcdir)/.markerfile $($(python-imagesize)-prefix)/.markerfile $$(foreach dep,$$($(python-imagesize)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-imagesize)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-imagesize)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-imagesize)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-imagesize)-prefix)/.pkgunpack
	@touch $@

$($(python-imagesize)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-imagesize)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-imagesize)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-imagesize)-prefix)/.pkgpatch
	cd $($(python-imagesize)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-imagesize)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-imagesize)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-imagesize)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-imagesize)-prefix)/.pkgbuild
	cd $($(python-imagesize)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-imagesize)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-imagesize)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-imagesize)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-imagesize)-prefix)/.pkgcheck $($(python-imagesize)-site-packages)/.markerfile
	cd $($(python-imagesize)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-imagesize)-builddeps) && \
		PYTHONPATH=$($(python-imagesize)-site-packages):$${PYTHONPATH} \
		$(PYTHON) setup.py install --prefix=$($(python-imagesize)-prefix)
	@touch $@

$($(python-imagesize)-modulefile): $(modulefilesdir)/.markerfile $($(python-imagesize)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-imagesize)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-imagesize)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-imagesize)-description)\"" >>$@
	echo "module-whatis \"$($(python-imagesize)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-imagesize)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_IMAGESIZE_ROOT $($(python-imagesize)-prefix)" >>$@
	echo "prepend-path PATH $($(python-imagesize)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-imagesize)-site-packages)" >>$@
	echo "set MSG \"$(python-imagesize)\"" >>$@

$(python-imagesize)-src: $($(python-imagesize)-src)
$(python-imagesize)-unpack: $($(python-imagesize)-prefix)/.pkgunpack
$(python-imagesize)-patch: $($(python-imagesize)-prefix)/.pkgpatch
$(python-imagesize)-build: $($(python-imagesize)-prefix)/.pkgbuild
$(python-imagesize)-check: $($(python-imagesize)-prefix)/.pkgcheck
$(python-imagesize)-install: $($(python-imagesize)-prefix)/.pkginstall
$(python-imagesize)-modulefile: $($(python-imagesize)-modulefile)
$(python-imagesize)-clean:
	rm -rf $($(python-imagesize)-modulefile)
	rm -rf $($(python-imagesize)-prefix)
	rm -rf $($(python-imagesize)-srcdir)
	rm -rf $($(python-imagesize)-src)
$(python-imagesize): $(python-imagesize)-src $(python-imagesize)-unpack $(python-imagesize)-patch $(python-imagesize)-build $(python-imagesize)-check $(python-imagesize)-install $(python-imagesize)-modulefile
