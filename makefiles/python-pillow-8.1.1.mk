# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-pillow-8.1.1

python-pillow-version = 8.1.1
python-pillow = python-pillow-$(python-pillow-version)
$(python-pillow)-description = Python Imaging Library
$(python-pillow)-url = https://python-pillow.org/
$(python-pillow)-srcurl = https://files.pythonhosted.org/packages/a6/24/1346f8c70dae5daf58e22435a1f1f4696682b4f85321eb4d18ca1d81c0c2/Pillow-8.1.1.tar.gz
$(python-pillow)-src = $(pkgsrcdir)/$(notdir $($(python-pillow)-srcurl))
$(python-pillow)-srcdir = $(pkgsrcdir)/$(python-pillow)
$(python-pillow)-builddeps = $(python) $(libjpeg-turbo) $(libtiff) $(freetype) $(libwebp) $(python-pip)
$(python-pillow)-prereqs = $(python) $(libjpeg-turbo) $(libtiff) $(freetype) $(libwebp)
$(python-pillow)-modulefile = $(modulefilesdir)/$(python-pillow)
$(python-pillow)-prefix = $(pkgdir)/$(python-pillow)
$(python-pillow)-site-packages = $($(python-pillow)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pillow)-src): $(dir $($(python-pillow)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pillow)-srcurl)

$($(python-pillow)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pillow)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pillow)-prefix)/.pkgunpack: $$($(python-pillow)-src) $($(python-pillow)-srcdir)/.markerfile $($(python-pillow)-prefix)/.markerfile $$(foreach dep,$$($(python-pillow)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pillow)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pillow)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pillow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pillow)-prefix)/.pkgunpack
	@touch $@

$($(python-pillow)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pillow)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pillow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pillow)-prefix)/.pkgpatch
	cd $($(python-pillow)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pillow)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pillow)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pillow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pillow)-prefix)/.pkgbuild
	@touch $@

$($(python-pillow)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pillow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pillow)-prefix)/.pkgcheck $($(python-pillow)-site-packages)/.markerfile
	cd $($(python-pillow)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pillow)-builddeps) && \
		PYTHONPATH=$($(python-pillow)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-pillow)-prefix)
	@touch $@

$($(python-pillow)-modulefile): $(modulefilesdir)/.markerfile $($(python-pillow)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pillow)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pillow)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pillow)-description)\"" >>$@
	echo "module-whatis \"$($(python-pillow)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pillow)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PILLOW_ROOT $($(python-pillow)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pillow)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pillow)-site-packages)" >>$@
	echo "set MSG \"$(python-pillow)\"" >>$@

$(python-pillow)-src: $($(python-pillow)-src)
$(python-pillow)-unpack: $($(python-pillow)-prefix)/.pkgunpack
$(python-pillow)-patch: $($(python-pillow)-prefix)/.pkgpatch
$(python-pillow)-build: $($(python-pillow)-prefix)/.pkgbuild
$(python-pillow)-check: $($(python-pillow)-prefix)/.pkgcheck
$(python-pillow)-install: $($(python-pillow)-prefix)/.pkginstall
$(python-pillow)-modulefile: $($(python-pillow)-modulefile)
$(python-pillow)-clean:
	rm -rf $($(python-pillow)-modulefile)
	rm -rf $($(python-pillow)-prefix)
	rm -rf $($(python-pillow)-srcdir)
	rm -rf $($(python-pillow)-src)
$(python-pillow): $(python-pillow)-src $(python-pillow)-unpack $(python-pillow)-patch $(python-pillow)-build $(python-pillow)-check $(python-pillow)-install $(python-pillow)-modulefile
