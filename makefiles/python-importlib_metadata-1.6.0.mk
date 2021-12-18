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
# python-importlib_metadata-1.6.0

python-importlib_metadata-version = 1.6.0
python-importlib_metadata = python-importlib_metadata-$(python-importlib_metadata-version)
$(python-importlib_metadata)-description = Library for accessing Python package metadata
$(python-importlib_metadata)-url = http://importlib_metadata.readthedocs.io/
$(python-importlib_metadata)-srcurl = https://files.pythonhosted.org/packages/b4/1b/baab42e3cd64c9d5caac25a9d6c054f8324cdc38975a44d600569f1f7158/importlib_metadata-1.6.0.tar.gz
$(python-importlib_metadata)-src = $(pkgsrcdir)/$(notdir $($(python-importlib_metadata)-srcurl))
$(python-importlib_metadata)-srcdir = $(pkgsrcdir)/$(python-importlib_metadata)
$(python-importlib_metadata)-builddeps = $(python) $(python-zipp) $(python-pip) $(python-setuptools) $(python-wheel)
$(python-importlib_metadata)-prereqs = $(python) $(python-zipp)
$(python-importlib_metadata)-modulefile = $(modulefilesdir)/$(python-importlib_metadata)
$(python-importlib_metadata)-prefix = $(pkgdir)/$(python-importlib_metadata)
$(python-importlib_metadata)-site-packages = $($(python-importlib_metadata)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-importlib_metadata)-src): $(dir $($(python-importlib_metadata)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-importlib_metadata)-srcurl)

$($(python-importlib_metadata)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-importlib_metadata)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-importlib_metadata)-prefix)/.pkgunpack: $$($(python-importlib_metadata)-src) $($(python-importlib_metadata)-srcdir)/.markerfile $($(python-importlib_metadata)-prefix)/.markerfile $$(foreach dep,$$($(python-importlib_metadata)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-importlib_metadata)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-importlib_metadata)-prefix)/.pkgpatch: $($(python-importlib_metadata)-prefix)/.pkgunpack
	@touch $@

$($(python-importlib_metadata)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-importlib_metadata)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-importlib_metadata)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-importlib_metadata)-prefix)/.pkgpatch
	cd $($(python-importlib_metadata)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-importlib_metadata)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-importlib_metadata)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-importlib_metadata)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-importlib_metadata)-prefix)/.pkgbuild
	@touch $@

$($(python-importlib_metadata)-prefix)/.pkginstall: $($(python-importlib_metadata)-prefix)/.pkgcheck $($(python-importlib_metadata)-site-packages)/.markerfile
	cd $($(python-importlib_metadata)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-importlib_metadata)-builddeps) && \
		PYTHONPATH=$($(python-importlib_metadata)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(python-importlib_metadata)-prefix)
	@touch $@

$($(python-importlib_metadata)-modulefile): $(modulefilesdir)/.markerfile $($(python-importlib_metadata)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-importlib_metadata)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-importlib_metadata)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-importlib_metadata)-description)\"" >>$@
	echo "module-whatis \"$($(python-importlib_metadata)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-importlib_metadata)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_IMPORTLIB_METADATA_ROOT $($(python-importlib_metadata)-prefix)" >>$@
	echo "prepend-path PATH $($(python-importlib_metadata)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-importlib_metadata)-site-packages)" >>$@
	echo "set MSG \"$(python-importlib_metadata)\"" >>$@

$(python-importlib_metadata)-src: $($(python-importlib_metadata)-src)
$(python-importlib_metadata)-unpack: $($(python-importlib_metadata)-prefix)/.pkgunpack
$(python-importlib_metadata)-patch: $($(python-importlib_metadata)-prefix)/.pkgpatch
$(python-importlib_metadata)-build: $($(python-importlib_metadata)-prefix)/.pkgbuild
$(python-importlib_metadata)-check: $($(python-importlib_metadata)-prefix)/.pkgcheck
$(python-importlib_metadata)-install: $($(python-importlib_metadata)-prefix)/.pkginstall
$(python-importlib_metadata)-modulefile: $($(python-importlib_metadata)-modulefile)
$(python-importlib_metadata)-clean:
	rm -rf $($(python-importlib_metadata)-modulefile)
	rm -rf $($(python-importlib_metadata)-prefix)
	rm -rf $($(python-importlib_metadata)-srcdir)
	rm -rf $($(python-importlib_metadata)-src)
$(python-importlib_metadata): $(python-importlib_metadata)-src $(python-importlib_metadata)-unpack $(python-importlib_metadata)-patch $(python-importlib_metadata)-build $(python-importlib_metadata)-check $(python-importlib_metadata)-install $(python-importlib_metadata)-modulefile
