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
# python-pyflakes-2.2.0

python-pyflakes-version = 2.2.0
python-pyflakes = python-pyflakes-$(python-pyflakes-version)
$(python-pyflakes)-description = A simple program which checks Python source files for errors
$(python-pyflakes)-url = https://github.com/PyCQA/pyflakes
$(python-pyflakes)-srcurl = https://files.pythonhosted.org/packages/f1/e2/e02fc89959619590eec0c35f366902535ade2728479fc3082c8af8840013/pyflakes-2.2.0.tar.gz
$(python-pyflakes)-src = $(pkgsrcdir)/$(notdir $($(python-pyflakes)-srcurl))
$(python-pyflakes)-srcdir = $(pkgsrcdir)/$(python-pyflakes)
$(python-pyflakes)-builddeps = $(python)
$(python-pyflakes)-prereqs = $(python)
$(python-pyflakes)-modulefile = $(modulefilesdir)/$(python-pyflakes)
$(python-pyflakes)-prefix = $(pkgdir)/$(python-pyflakes)
$(python-pyflakes)-site-packages = $($(python-pyflakes)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pyflakes)-src): $(dir $($(python-pyflakes)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pyflakes)-srcurl)

$($(python-pyflakes)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyflakes)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyflakes)-prefix)/.pkgunpack: $$($(python-pyflakes)-src) $($(python-pyflakes)-srcdir)/.markerfile $($(python-pyflakes)-prefix)/.markerfile
	tar -C $($(python-pyflakes)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pyflakes)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyflakes)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyflakes)-prefix)/.pkgunpack
	@touch $@

$($(python-pyflakes)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pyflakes)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyflakes)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyflakes)-prefix)/.pkgpatch
	cd $($(python-pyflakes)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyflakes)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pyflakes)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyflakes)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyflakes)-prefix)/.pkgbuild
	cd $($(python-pyflakes)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyflakes)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pyflakes)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyflakes)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyflakes)-prefix)/.pkgcheck $($(python-pyflakes)-site-packages)/.markerfile
	cd $($(python-pyflakes)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyflakes)-builddeps) && \
		PYTHONPATH=$($(python-pyflakes)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pyflakes)-prefix)
	@touch $@

$($(python-pyflakes)-modulefile): $(modulefilesdir)/.markerfile $($(python-pyflakes)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pyflakes)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pyflakes)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pyflakes)-description)\"" >>$@
	echo "module-whatis \"$($(python-pyflakes)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pyflakes)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYFLAKES_ROOT $($(python-pyflakes)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pyflakes)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pyflakes)-site-packages)" >>$@
	echo "set MSG \"$(python-pyflakes)\"" >>$@

$(python-pyflakes)-src: $($(python-pyflakes)-src)
$(python-pyflakes)-unpack: $($(python-pyflakes)-prefix)/.pkgunpack
$(python-pyflakes)-patch: $($(python-pyflakes)-prefix)/.pkgpatch
$(python-pyflakes)-build: $($(python-pyflakes)-prefix)/.pkgbuild
$(python-pyflakes)-check: $($(python-pyflakes)-prefix)/.pkgcheck
$(python-pyflakes)-install: $($(python-pyflakes)-prefix)/.pkginstall
$(python-pyflakes)-modulefile: $($(python-pyflakes)-modulefile)
$(python-pyflakes)-clean:
	rm -rf $($(python-pyflakes)-modulefile)
	rm -rf $($(python-pyflakes)-prefix)
	rm -rf $($(python-pyflakes)-srcdir)
	rm -rf $($(python-pyflakes)-src)
$(python-pyflakes): $(python-pyflakes)-src $(python-pyflakes)-unpack $(python-pyflakes)-patch $(python-pyflakes)-build $(python-pyflakes)-check $(python-pyflakes)-install $(python-pyflakes)-modulefile
