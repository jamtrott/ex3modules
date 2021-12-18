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
# meson-0.53.2

meson-version = 0.53.2
meson = meson-$(meson-version)
$(meson)-description = Open source build system implemented in Python
$(meson)-url = https://mesonbuild.com/
$(meson)-srcurl = https://github.com/mesonbuild/meson/releases/download/$(meson-version)/meson-$(meson-version).tar.gz
$(meson)-src = $(pkgsrcdir)/$(meson).tar.gz
$(meson)-srcdir = $(pkgsrcdir)/$(meson)
$(meson)-builddeps = $(python)
$(meson)-prereqs = $(python)
$(meson)-modulefile = $(modulefilesdir)/$(meson)
$(meson)-prefix = $(pkgdir)/$(meson)
$(meson)-site-packages = $($(meson)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(meson)-src): $(dir $($(meson)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(meson)-srcurl)

$($(meson)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(meson)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(meson)-prefix)/.pkgunpack: $($(meson)-src) $($(meson)-srcdir)/.markerfile $($(meson)-prefix)/.markerfile $$(foreach dep,$$($(meson)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(meson)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(meson)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(meson)-builddeps),$(modulefilesdir)/$$(dep)) $($(meson)-prefix)/.pkgunpack
	@touch $@

$($(meson)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(meson)-builddeps),$(modulefilesdir)/$$(dep)) $($(meson)-prefix)/.pkgpatch
	cd $($(meson)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(meson)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(meson)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(meson)-builddeps),$(modulefilesdir)/$$(dep)) $($(meson)-prefix)/.pkgbuild
	cd $($(meson)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(meson)-builddeps) && \
		$(PYTHON) setup.py check
	@touch $@

$($(meson)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(meson)-builddeps),$(modulefilesdir)/$$(dep)) $($(meson)-prefix)/.pkgcheck
	$(INSTALL) -d $($(meson)-site-packages)
	cd $($(meson)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(meson)-builddeps) && \
		PYTHONPATH=$($(meson)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(meson)-prefix)
	@touch $@

$($(meson)-modulefile): $(modulefilesdir)/.markerfile $($(meson)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(meson)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(meson)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(meson)-description)\"" >>$@
	echo "module-whatis \"$($(meson)-url)\"" >>$@
	printf "$(foreach prereq,$($(meson)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MESON_ROOT $($(meson)-prefix)" >>$@
	echo "prepend-path PATH $($(meson)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(meson)-site-packages)" >>$@
	echo "set MSG \"$(meson)\"" >>$@

$(meson)-src: $($(meson)-src)
$(meson)-unpack: $($(meson)-prefix)/.pkgunpack
$(meson)-patch: $($(meson)-prefix)/.pkgpatch
$(meson)-build: $($(meson)-prefix)/.pkgbuild
$(meson)-check: $($(meson)-prefix)/.pkgcheck
$(meson)-install: $($(meson)-prefix)/.pkginstall
$(meson)-modulefile: $($(meson)-modulefile)
$(meson)-clean:
	rm -rf $($(meson)-modulefile)
	rm -rf $($(meson)-prefix)
	rm -rf $($(meson)-srcdir)
	rm -rf $($(meson)-src)
$(meson): $(meson)-src $(meson)-unpack $(meson)-patch $(meson)-build $(meson)-check $(meson)-install $(meson)-modulefile
