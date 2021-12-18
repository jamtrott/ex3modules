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
# python-numpy-quaternion-2021.11.4.15.26.3

python-numpy-quaternion-version = 2021.11.4.15.26.3
python-numpy-quaternion = python-numpy-quaternion-$(python-numpy-quaternion-version)
$(python-numpy-quaternion)-description = Quaternions in numpy
$(python-numpy-quaternion)-url = https://github.com/moble/quaternion
$(python-numpy-quaternion)-srcurl = https://github.com/moble/quaternion/archive/refs/tags/v$(python-numpy-quaternion-version).tar.gz
$(python-numpy-quaternion)-src = $(pkgsrcdir)/python-numpy-quaternion-$(notdir $($(python-numpy-quaternion)-srcurl))
$(python-numpy-quaternion)-srcdir = $(pkgsrcdir)/$(python-numpy-quaternion)
$(python-numpy-quaternion)-builddeps = $(python) $(python-numpy) $(python-setuptools)
$(python-numpy-quaternion)-prereqs = $(python) $(python-numpy)
$(python-numpy-quaternion)-modulefile = $(modulefilesdir)/$(python-numpy-quaternion)
$(python-numpy-quaternion)-prefix = $(pkgdir)/$(python-numpy-quaternion)
$(python-numpy-quaternion)-site-packages = $($(python-numpy-quaternion)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-numpy-quaternion)-src): $(dir $($(python-numpy-quaternion)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-numpy-quaternion)-srcurl)

$($(python-numpy-quaternion)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-numpy-quaternion)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-numpy-quaternion)-prefix)/.pkgunpack: $$($(python-numpy-quaternion)-src) $($(python-numpy-quaternion)-srcdir)/.markerfile $($(python-numpy-quaternion)-prefix)/.markerfile $$(foreach dep,$$($(python-numpy-quaternion)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-numpy-quaternion)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-numpy-quaternion)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy-quaternion)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy-quaternion)-prefix)/.pkgunpack
	@touch $@

$($(python-numpy-quaternion)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-numpy-quaternion)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy-quaternion)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy-quaternion)-prefix)/.pkgpatch
	cd $($(python-numpy-quaternion)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numpy-quaternion)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-numpy-quaternion)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy-quaternion)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy-quaternion)-prefix)/.pkgbuild
	cd $($(python-numpy-quaternion)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numpy-quaternion)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-numpy-quaternion)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy-quaternion)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy-quaternion)-prefix)/.pkgcheck $($(python-numpy-quaternion)-site-packages)/.markerfile
	cd $($(python-numpy-quaternion)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numpy-quaternion)-builddeps) && \
		PYTHONPATH=$($(python-numpy-quaternion)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(python-numpy-quaternion)-prefix)
	@touch $@

$($(python-numpy-quaternion)-modulefile): $(modulefilesdir)/.markerfile $($(python-numpy-quaternion)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-numpy-quaternion)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-numpy-quaternion)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-numpy-quaternion)-description)\"" >>$@
	echo "module-whatis \"$($(python-numpy-quaternion)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-numpy-quaternion)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_NUMPY_QUATERNION_ROOT $($(python-numpy-quaternion)-prefix)" >>$@
	echo "prepend-path PATH $($(python-numpy-quaternion)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-numpy-quaternion)-site-packages)" >>$@
	echo "set MSG \"$(python-numpy-quaternion)\"" >>$@

$(python-numpy-quaternion)-src: $($(python-numpy-quaternion)-src)
$(python-numpy-quaternion)-unpack: $($(python-numpy-quaternion)-prefix)/.pkgunpack
$(python-numpy-quaternion)-patch: $($(python-numpy-quaternion)-prefix)/.pkgpatch
$(python-numpy-quaternion)-build: $($(python-numpy-quaternion)-prefix)/.pkgbuild
$(python-numpy-quaternion)-check: $($(python-numpy-quaternion)-prefix)/.pkgcheck
$(python-numpy-quaternion)-install: $($(python-numpy-quaternion)-prefix)/.pkginstall
$(python-numpy-quaternion)-modulefile: $($(python-numpy-quaternion)-modulefile)
$(python-numpy-quaternion)-clean:
	rm -rf $($(python-numpy-quaternion)-modulefile)
	rm -rf $($(python-numpy-quaternion)-prefix)
	rm -rf $($(python-numpy-quaternion)-srcdir)
	rm -rf $($(python-numpy-quaternion)-src)
$(python-numpy-quaternion): $(python-numpy-quaternion)-src $(python-numpy-quaternion)-unpack $(python-numpy-quaternion)-patch $(python-numpy-quaternion)-build $(python-numpy-quaternion)-check $(python-numpy-quaternion)-install $(python-numpy-quaternion)-modulefile
