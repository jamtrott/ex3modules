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
# python-pyra-pytorch-1.2.0

python-pyra-pytorch-version = 1.2.0
python-pyra-pytorch = python-pyra-pytorch-$(python-pyra-pytorch-version)
$(python-pyra-pytorch)-description = Pyramid Focus Augmentation: Medical Image Segmentation with Step Wise Focus
$(python-pyra-pytorch)-url = https://vlbthambawita.github.io/PYRA/
$(python-pyra-pytorch)-srcurl = https://files.pythonhosted.org/packages/61/d1/31e2c735b115a613a6b45ec3d19538d0fde65bac730db725001797ea4ba3/pyra-pytorch-1.2.0.tar.gz
$(python-pyra-pytorch)-src = $(pkgsrcdir)/$(notdir $($(python-pyra-pytorch)-srcurl))
$(python-pyra-pytorch)-srcdir = $(pkgsrcdir)/$(python-pyra-pytorch)
$(python-pyra-pytorch)-builddeps = $(python) $(python-numpy) $(python-pillow)
$(python-pyra-pytorch)-prereqs = $(python) $(python-numpy) $(python-pillow)
$(python-pyra-pytorch)-modulefile = $(modulefilesdir)/$(python-pyra-pytorch)
$(python-pyra-pytorch)-prefix = $(pkgdir)/$(python-pyra-pytorch)
$(python-pyra-pytorch)-site-packages = $($(python-pyra-pytorch)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pyra-pytorch)-src): $(dir $($(python-pyra-pytorch)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pyra-pytorch)-srcurl)

$($(python-pyra-pytorch)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyra-pytorch)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyra-pytorch)-prefix)/.pkgunpack: $$($(python-pyra-pytorch)-src) $($(python-pyra-pytorch)-srcdir)/.markerfile $($(python-pyra-pytorch)-prefix)/.markerfile $$(foreach dep,$$($(python-pyra-pytorch)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pyra-pytorch)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pyra-pytorch)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyra-pytorch)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyra-pytorch)-prefix)/.pkgunpack
	@touch $@

$($(python-pyra-pytorch)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pyra-pytorch)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyra-pytorch)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyra-pytorch)-prefix)/.pkgpatch
	cd $($(python-pyra-pytorch)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyra-pytorch)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pyra-pytorch)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyra-pytorch)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyra-pytorch)-prefix)/.pkgbuild
	cd $($(python-pyra-pytorch)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyra-pytorch)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pyra-pytorch)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyra-pytorch)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyra-pytorch)-prefix)/.pkgcheck $($(python-pyra-pytorch)-site-packages)/.markerfile
	cd $($(python-pyra-pytorch)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyra-pytorch)-builddeps) && \
		PYTHONPATH=$($(python-pyra-pytorch)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pyra-pytorch)-prefix)
	@touch $@

$($(python-pyra-pytorch)-modulefile): $(modulefilesdir)/.markerfile $($(python-pyra-pytorch)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pyra-pytorch)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pyra-pytorch)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pyra-pytorch)-description)\"" >>$@
	echo "module-whatis \"$($(python-pyra-pytorch)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pyra-pytorch)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYRA_PYTORCH_ROOT $($(python-pyra-pytorch)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pyra-pytorch)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pyra-pytorch)-site-packages)" >>$@
	echo "set MSG \"$(python-pyra-pytorch)\"" >>$@

$(python-pyra-pytorch)-src: $($(python-pyra-pytorch)-src)
$(python-pyra-pytorch)-unpack: $($(python-pyra-pytorch)-prefix)/.pkgunpack
$(python-pyra-pytorch)-patch: $($(python-pyra-pytorch)-prefix)/.pkgpatch
$(python-pyra-pytorch)-build: $($(python-pyra-pytorch)-prefix)/.pkgbuild
$(python-pyra-pytorch)-check: $($(python-pyra-pytorch)-prefix)/.pkgcheck
$(python-pyra-pytorch)-install: $($(python-pyra-pytorch)-prefix)/.pkginstall
$(python-pyra-pytorch)-modulefile: $($(python-pyra-pytorch)-modulefile)
$(python-pyra-pytorch)-clean:
	rm -rf $($(python-pyra-pytorch)-modulefile)
	rm -rf $($(python-pyra-pytorch)-prefix)
	rm -rf $($(python-pyra-pytorch)-srcdir)
	rm -rf $($(python-pyra-pytorch)-src)
$(python-pyra-pytorch): $(python-pyra-pytorch)-src $(python-pyra-pytorch)-unpack $(python-pyra-pytorch)-patch $(python-pyra-pytorch)-build $(python-pyra-pytorch)-check $(python-pyra-pytorch)-install $(python-pyra-pytorch)-modulefile
