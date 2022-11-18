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
# python-cffi-1.14.3

python-cffi-version = 1.14.3
python-cffi = python-cffi-$(python-cffi-version)
$(python-cffi)-description = Foreign Function Interface for Python calling C code
$(python-cffi)-url = https://cffi.readthedocs.io/en/latest/
$(python-cffi)-srcurl = https://files.pythonhosted.org/packages/cb/ae/380e33d621ae301770358eb11a896a34c34f30db188847a561e8e39ee866/cffi-1.14.3.tar.gz
$(python-cffi)-src = $(pkgsrcdir)/$(notdir $($(python-cffi)-srcurl))
$(python-cffi)-srcdir = $(pkgsrcdir)/$(python-cffi)
$(python-cffi)-builddeps = $(python) $(libffi) $(python-pycparser) $(python-py) $(python-pytest) $(python-pip)
$(python-cffi)-prereqs = $(python) $(libffi) $(python-pycparser)
$(python-cffi)-modulefile = $(modulefilesdir)/$(python-cffi)
$(python-cffi)-prefix = $(pkgdir)/$(python-cffi)
$(python-cffi)-site-packages = $($(python-cffi)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-cffi)-src): $(dir $($(python-cffi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-cffi)-srcurl)

$($(python-cffi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cffi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cffi)-prefix)/.pkgunpack: $$($(python-cffi)-src) $($(python-cffi)-srcdir)/.markerfile $($(python-cffi)-prefix)/.markerfile $$(foreach dep,$$($(python-cffi)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-cffi)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-cffi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cffi)-prefix)/.pkgunpack
	@touch $@

$($(python-cffi)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-cffi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cffi)-prefix)/.pkgpatch
	cd $($(python-cffi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cffi)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-cffi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cffi)-prefix)/.pkgbuild
	@touch $@

$($(python-cffi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cffi)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cffi)-prefix)/.pkgcheck $($(python-cffi)-site-packages)/.markerfile
	cd $($(python-cffi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cffi)-builddeps) && \
		PYTHONPATH=$($(python-cffi)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-cffi)-prefix)
	@touch $@

$($(python-cffi)-modulefile): $(modulefilesdir)/.markerfile $($(python-cffi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-cffi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-cffi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-cffi)-description)\"" >>$@
	echo "module-whatis \"$($(python-cffi)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-cffi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CFFI_ROOT $($(python-cffi)-prefix)" >>$@
	echo "prepend-path PATH $($(python-cffi)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-cffi)-site-packages)" >>$@
	echo "set MSG \"$(python-cffi)\"" >>$@

$(python-cffi)-src: $($(python-cffi)-src)
$(python-cffi)-unpack: $($(python-cffi)-prefix)/.pkgunpack
$(python-cffi)-patch: $($(python-cffi)-prefix)/.pkgpatch
$(python-cffi)-build: $($(python-cffi)-prefix)/.pkgbuild
$(python-cffi)-check: $($(python-cffi)-prefix)/.pkgcheck
$(python-cffi)-install: $($(python-cffi)-prefix)/.pkginstall
$(python-cffi)-modulefile: $($(python-cffi)-modulefile)
$(python-cffi)-clean:
	rm -rf $($(python-cffi)-modulefile)
	rm -rf $($(python-cffi)-prefix)
	rm -rf $($(python-cffi)-srcdir)
	rm -rf $($(python-cffi)-src)
$(python-cffi): $(python-cffi)-src $(python-cffi)-unpack $(python-cffi)-patch $(python-cffi)-build $(python-cffi)-check $(python-cffi)-install $(python-cffi)-modulefile
