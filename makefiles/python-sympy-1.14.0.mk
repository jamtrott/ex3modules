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
# python-sympy-1.14

python-sympy-1.14-version = 1.14.0
python-sympy-1.14 = python-sympy-$(python-sympy-1.14-version)
$(python-sympy-1.14)-description = Computer algebra system written in pure Python
$(python-sympy-1.14)-url = https://www.sympy.org/
$(python-sympy-1.14)-srcurl = https://files.pythonhosted.org/packages/83/d3/803453b36afefb7c2bb238361cd4ae6125a569b4db67cd9e79846ba2d68c/sympy-1.14.0.tar.gz
$(python-sympy-1.14)-src = $(pkgsrcdir)/$(notdir $($(python-sympy-1.14)-srcurl))
$(python-sympy-1.14)-srcdir = $(pkgsrcdir)/$(python-sympy-1.14)
$(python-sympy-1.14)-builddeps = $(python) $(python-mpmath) $(python-pip)
$(python-sympy-1.14)-prereqs = $(python) $(python-mpmath)
$(python-sympy-1.14)-modulefile = $(modulefilesdir)/$(python-sympy-1.14)
$(python-sympy-1.14)-prefix = $(pkgdir)/$(python-sympy-1.14)
$(python-sympy-1.14)-site-packages = $($(python-sympy-1.14)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sympy-1.14)-src): $(dir $($(python-sympy-1.14)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sympy-1.14)-srcurl)

$($(python-sympy-1.14)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sympy-1.14)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sympy-1.14)-prefix)/.pkgunpack: $$($(python-sympy-1.14)-src) $($(python-sympy-1.14)-srcdir)/.markerfile $($(python-sympy-1.14)-prefix)/.markerfile $$(foreach dep,$$($(python-sympy-1.14)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sympy-1.14)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sympy-1.14)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.14)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.14)-prefix)/.pkgunpack
	@touch $@

$($(python-sympy-1.14)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sympy-1.14)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.14)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.14)-prefix)/.pkgpatch
	cd $($(python-sympy-1.14)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sympy-1.14)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sympy-1.14)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.14)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.14)-prefix)/.pkgbuild
	@touch $@

$($(python-sympy-1.14)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.14)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.14)-prefix)/.pkgcheck $($(python-sympy-1.14)-site-packages)/.markerfile
	cd $($(python-sympy-1.14)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sympy-1.14)-builddeps) && \
		PYTHONPATH=$($(python-sympy-1.14)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-sympy-1.14)-prefix)
	@touch $@

$($(python-sympy-1.14)-modulefile): $(modulefilesdir)/.markerfile $($(python-sympy-1.14)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sympy-1.14)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sympy-1.14)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sympy-1.14)-description)\"" >>$@
	echo "module-whatis \"$($(python-sympy-1.14)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sympy-1.14)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SYMPY_1_4_ROOT $($(python-sympy-1.14)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sympy-1.14)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sympy-1.14)-site-packages)" >>$@
	echo "set MSG \"$(python-sympy-1.14)\"" >>$@

$(python-sympy-1.14)-src: $($(python-sympy-1.14)-src)
$(python-sympy-1.14)-unpack: $($(python-sympy-1.14)-prefix)/.pkgunpack
$(python-sympy-1.14)-patch: $($(python-sympy-1.14)-prefix)/.pkgpatch
$(python-sympy-1.14)-build: $($(python-sympy-1.14)-prefix)/.pkgbuild
$(python-sympy-1.14)-check: $($(python-sympy-1.14)-prefix)/.pkgcheck
$(python-sympy-1.14)-install: $($(python-sympy-1.14)-prefix)/.pkginstall
$(python-sympy-1.14)-modulefile: $($(python-sympy-1.14)-modulefile)
$(python-sympy-1.14)-clean:
	rm -rf $($(python-sympy-1.14)-modulefile)
	rm -rf $($(python-sympy-1.14)-prefix)
	rm -rf $($(python-sympy-1.14)-srcdir)
	rm -rf $($(python-sympy-1.14)-src)
$(python-sympy-1.14): $(python-sympy-1.14)-src $(python-sympy-1.14)-unpack $(python-sympy-1.14)-patch $(python-sympy-1.14)-build $(python-sympy-1.14)-check $(python-sympy-1.14)-install $(python-sympy-1.14)-modulefile
