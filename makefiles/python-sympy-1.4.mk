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
# python-sympy-1.4

python-sympy-1.4-version = 1.4
python-sympy-1.4 = python-sympy-$(python-sympy-1.4-version)
$(python-sympy-1.4)-description = Computer algebra system written in pure Python
$(python-sympy-1.4)-url = https://www.sympy.org/
$(python-sympy-1.4)-srcurl = https://files.pythonhosted.org/packages/54/2e/6adb11fe599d4cfb7e8833753350ac51aa2c0603c226b36f9051cc9d2425/sympy-1.4.tar.gz
$(python-sympy-1.4)-src = $(pkgsrcdir)/$(notdir $($(python-sympy-1.4)-srcurl))
$(python-sympy-1.4)-srcdir = $(pkgsrcdir)/$(python-sympy-1.4)
$(python-sympy-1.4)-builddeps = $(python) $(python-mpmath)
$(python-sympy-1.4)-prereqs = $(python) $(python-mpmath)
$(python-sympy-1.4)-modulefile = $(modulefilesdir)/$(python-sympy-1.4)
$(python-sympy-1.4)-prefix = $(pkgdir)/$(python-sympy-1.4)
$(python-sympy-1.4)-site-packages = $($(python-sympy-1.4)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-sympy-1.4)-src): $(dir $($(python-sympy-1.4)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sympy-1.4)-srcurl)

$($(python-sympy-1.4)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-sympy-1.4)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-sympy-1.4)-prefix)/.pkgunpack: $$($(python-sympy-1.4)-src) $($(python-sympy-1.4)-srcdir)/.markerfile $($(python-sympy-1.4)-prefix)/.markerfile
	tar -C $($(python-sympy-1.4)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sympy-1.4)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.4)-prefix)/.pkgunpack
	@touch $@

$($(python-sympy-1.4)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-sympy-1.4)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.4)-prefix)/.pkgpatch
	cd $($(python-sympy-1.4)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sympy-1.4)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-sympy-1.4)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.4)-prefix)/.pkgbuild
# 	cd $($(python-sympy-1.4)-srcdir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(python-sympy-1.4)-builddeps) && \
# 		python3 setup.py test
	@touch $@

$($(python-sympy-1.4)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.4)-prefix)/.pkgcheck $($(python-sympy-1.4)-site-packages)/.markerfile
	cd $($(python-sympy-1.4)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sympy-1.4)-builddeps) && \
		PYTHONPATH=$($(python-sympy-1.4)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-sympy-1.4)-prefix)
	@touch $@

$($(python-sympy-1.4)-modulefile): $(modulefilesdir)/.markerfile $($(python-sympy-1.4)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sympy-1.4)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sympy-1.4)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sympy-1.4)-description)\"" >>$@
	echo "module-whatis \"$($(python-sympy-1.4)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sympy-1.4)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SYMPY_1_4_ROOT $($(python-sympy-1.4)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sympy-1.4)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sympy-1.4)-site-packages)" >>$@
	echo "set MSG \"$(python-sympy-1.4)\"" >>$@

$(python-sympy-1.4)-src: $($(python-sympy-1.4)-src)
$(python-sympy-1.4)-unpack: $($(python-sympy-1.4)-prefix)/.pkgunpack
$(python-sympy-1.4)-patch: $($(python-sympy-1.4)-prefix)/.pkgpatch
$(python-sympy-1.4)-build: $($(python-sympy-1.4)-prefix)/.pkgbuild
$(python-sympy-1.4)-check: $($(python-sympy-1.4)-prefix)/.pkgcheck
$(python-sympy-1.4)-install: $($(python-sympy-1.4)-prefix)/.pkginstall
$(python-sympy-1.4)-modulefile: $($(python-sympy-1.4)-modulefile)
$(python-sympy-1.4)-clean:
	rm -rf $($(python-sympy-1.4)-modulefile)
	rm -rf $($(python-sympy-1.4)-prefix)
	rm -rf $($(python-sympy-1.4)-srcdir)
	rm -rf $($(python-sympy-1.4)-src)
$(python-sympy-1.4): $(python-sympy-1.4)-src $(python-sympy-1.4)-unpack $(python-sympy-1.4)-patch $(python-sympy-1.4)-build $(python-sympy-1.4)-check $(python-sympy-1.4)-install $(python-sympy-1.4)-modulefile
