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
# python-py-1.9.0

python-py-version = 1.9.0
python-py = python-py-$(python-py-version)
$(python-py)-description = Library with cross-python path, ini-parsing, io, code, log facilities
$(python-py)-url = http://py.readthedocs.io/
$(python-py)-srcurl = https://files.pythonhosted.org/packages/97/a6/ab9183fe08f69a53d06ac0ee8432bc0ffbb3989c575cc69b73a0229a9a99/py-1.9.0.tar.gz
$(python-py)-src = $(pkgsrcdir)/$(notdir $($(python-py)-srcurl))
$(python-py)-srcdir = $(pkgsrcdir)/$(python-py)
$(python-py)-builddeps = $(python)
$(python-py)-prereqs = $(python)
$(python-py)-modulefile = $(modulefilesdir)/$(python-py)
$(python-py)-prefix = $(pkgdir)/$(python-py)
$(python-py)-site-packages = $($(python-py)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-py)-src): $(dir $($(python-py)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-py)-srcurl)

$($(python-py)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-py)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-py)-prefix)/.pkgunpack: $$($(python-py)-src) $($(python-py)-srcdir)/.markerfile $($(python-py)-prefix)/.markerfile
	tar -C $($(python-py)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-py)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-py)-prefix)/.pkgunpack
	@touch $@

$($(python-py)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-py)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-py)-prefix)/.pkgpatch
	cd $($(python-py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-py)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-py)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-py)-prefix)/.pkgbuild
	@touch $@

$($(python-py)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-py)-prefix)/.pkgcheck $($(python-py)-site-packages)/.markerfile
	cd $($(python-py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-py)-builddeps) && \
		PYTHONPATH=$($(python-py)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-py)-prefix)
	@touch $@

$($(python-py)-modulefile): $(modulefilesdir)/.markerfile $($(python-py)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-py)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-py)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-py)-description)\"" >>$@
	echo "module-whatis \"$($(python-py)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-py)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PY_ROOT $($(python-py)-prefix)" >>$@
	echo "prepend-path PATH $($(python-py)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-py)-site-packages)" >>$@
	echo "set MSG \"$(python-py)\"" >>$@

$(python-py)-src: $($(python-py)-src)
$(python-py)-unpack: $($(python-py)-prefix)/.pkgunpack
$(python-py)-patch: $($(python-py)-prefix)/.pkgpatch
$(python-py)-build: $($(python-py)-prefix)/.pkgbuild
$(python-py)-check: $($(python-py)-prefix)/.pkgcheck
$(python-py)-install: $($(python-py)-prefix)/.pkginstall
$(python-py)-modulefile: $($(python-py)-modulefile)
$(python-py)-clean:
	rm -rf $($(python-py)-modulefile)
	rm -rf $($(python-py)-prefix)
	rm -rf $($(python-py)-srcdir)
	rm -rf $($(python-py)-src)
$(python-py): $(python-py)-src $(python-py)-unpack $(python-py)-patch $(python-py)-build $(python-py)-check $(python-py)-install $(python-py)-modulefile
