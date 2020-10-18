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
# python-sympy-1.1

python-sympy-1.1-version = 1.1
python-sympy-1.1 = python-sympy-$(python-sympy-1.1-version)
$(python-sympy-1.1)-description = Computer algebra system written in pure Python
$(python-sympy-1.1)-url = https://www.sympy.org/
$(python-sympy-1.1)-srcurl = https://files.pythonhosted.org/packages/d5/40/153799104ca0d644f539ef8212f83fe67f67f57324d4ef51a16f85141915/sympy-1.1.tar.gz
$(python-sympy-1.1)-src = $(pkgsrcdir)/$(notdir $($(python-sympy-1.1)-srcurl))
$(python-sympy-1.1)-srcdir = $(pkgsrcdir)/$(python-sympy-1.1)
$(python-sympy-1.1)-builddeps = $(python) $(python-mpmath)
$(python-sympy-1.1)-prereqs = $(python) $(python-mpmath)
$(python-sympy-1.1)-modulefile = $(modulefilesdir)/$(python-sympy-1.1)
$(python-sympy-1.1)-prefix = $(pkgdir)/$(python-sympy-1.1)
$(python-sympy-1.1)-site-packages = $($(python-sympy-1.1)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-sympy-1.1)-src): $(dir $($(python-sympy-1.1)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sympy-1.1)-srcurl)

$($(python-sympy-1.1)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-sympy-1.1)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-sympy-1.1)-prefix)/.pkgunpack: $$($(python-sympy-1.1)-src) $($(python-sympy-1.1)-srcdir)/.markerfile $($(python-sympy-1.1)-prefix)/.markerfile
	tar -C $($(python-sympy-1.1)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sympy-1.1)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.1)-prefix)/.pkgunpack
	@touch $@

$($(python-sympy-1.1)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-sympy-1.1)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.1)-prefix)/.pkgpatch
	cd $($(python-sympy-1.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sympy-1.1)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-sympy-1.1)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.1)-prefix)/.pkgbuild
# 	cd $($(python-sympy-1.1)-srcdir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(python-sympy-1.1)-builddeps) && \
# 		python3 setup.py test
	@touch $@

$($(python-sympy-1.1)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sympy-1.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sympy-1.1)-prefix)/.pkgcheck $($(python-sympy-1.1)-site-packages)/.markerfile
	cd $($(python-sympy-1.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sympy-1.1)-builddeps) && \
		PYTHONPATH=$($(python-sympy-1.1)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-sympy-1.1)-prefix)
	@touch $@

$($(python-sympy-1.1)-modulefile): $(modulefilesdir)/.markerfile $($(python-sympy-1.1)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sympy-1.1)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sympy-1.1)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sympy-1.1)-description)\"" >>$@
	echo "module-whatis \"$($(python-sympy-1.1)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sympy-1.1)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SYMPY_1_1_ROOT $($(python-sympy-1.1)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sympy-1.1)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sympy-1.1)-site-packages)" >>$@
	echo "set MSG \"$(python-sympy-1.1)\"" >>$@

$(python-sympy-1.1)-src: $($(python-sympy-1.1)-src)
$(python-sympy-1.1)-unpack: $($(python-sympy-1.1)-prefix)/.pkgunpack
$(python-sympy-1.1)-patch: $($(python-sympy-1.1)-prefix)/.pkgpatch
$(python-sympy-1.1)-build: $($(python-sympy-1.1)-prefix)/.pkgbuild
$(python-sympy-1.1)-check: $($(python-sympy-1.1)-prefix)/.pkgcheck
$(python-sympy-1.1)-install: $($(python-sympy-1.1)-prefix)/.pkginstall
$(python-sympy-1.1)-modulefile: $($(python-sympy-1.1)-modulefile)
$(python-sympy-1.1)-clean:
	rm -rf $($(python-sympy-1.1)-modulefile)
	rm -rf $($(python-sympy-1.1)-prefix)
	rm -rf $($(python-sympy-1.1)-srcdir)
	rm -rf $($(python-sympy-1.1)-src)
$(python-sympy-1.1): $(python-sympy-1.1)-src $(python-sympy-1.1)-unpack $(python-sympy-1.1)-patch $(python-sympy-1.1)-build $(python-sympy-1.1)-check $(python-sympy-1.1)-install $(python-sympy-1.1)-modulefile
