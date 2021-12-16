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
# python-meshio-4.3.6

python-meshio-version = 4.3.6
python-meshio = python-meshio-$(python-meshio-version)
$(python-meshio)-description = Library for input and output of many mesh formats
$(python-meshio)-url = https://github.com/nschloe/meshio
$(python-meshio)-srcurl = https://github.com/nschloe/meshio/archive/v$(python-meshio-version).tar.gz
$(python-meshio)-src = $(pkgsrcdir)/python-meshio-$(notdir $($(python-meshio)-srcurl))
$(python-meshio)-srcdir = $(pkgsrcdir)/$(python-meshio)
$(python-meshio)-builddeps = $(python) $(python-importlib_metadata) $(python-zipp) $(python-numpy)
$(python-meshio)-prereqs = $(python)
$(python-meshio)-modulefile = $(modulefilesdir)/$(python-meshio)
$(python-meshio)-prefix = $(pkgdir)/$(python-meshio)
$(python-meshio)-site-packages = $($(python-meshio)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-meshio)-src): $(dir $($(python-meshio)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-meshio)-srcurl)

$($(python-meshio)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-meshio)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-meshio)-prefix)/.pkgunpack: $$($(python-meshio)-src) $($(python-meshio)-srcdir)/.markerfile $($(python-meshio)-prefix)/.markerfile $$(foreach dep,$$($(python-meshio)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-meshio)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-meshio)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-meshio)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-meshio)-prefix)/.pkgunpack
	@touch $@

$($(python-meshio)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-meshio)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-meshio)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-meshio)-prefix)/.pkgpatch
	cd $($(python-meshio)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-meshio)-builddeps) && \
		python3 -c 'from setuptools import setup; setup()' build
	@touch $@

$($(python-meshio)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-meshio)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-meshio)-prefix)/.pkgbuild
	@touch $@

$($(python-meshio)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-meshio)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-meshio)-prefix)/.pkgcheck $($(python-meshio)-site-packages)/.markerfile
	cd $($(python-meshio)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-meshio)-builddeps) && \
		PYTHONPATH=$($(python-meshio)-site-packages):$${PYTHONPATH} \
		python3 -c 'from setuptools import setup; setup()' install --prefix=$($(python-meshio)-prefix)
	@touch $@

$($(python-meshio)-modulefile): $(modulefilesdir)/.markerfile $($(python-meshio)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-meshio)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-meshio)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-meshio)-description)\"" >>$@
	echo "module-whatis \"$($(python-meshio)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-meshio)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MESHIO_ROOT $($(python-meshio)-prefix)" >>$@
	echo "prepend-path PATH $($(python-meshio)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-meshio)-site-packages)" >>$@
	echo "set MSG \"$(python-meshio)\"" >>$@

$(python-meshio)-src: $($(python-meshio)-src)
$(python-meshio)-unpack: $($(python-meshio)-prefix)/.pkgunpack
$(python-meshio)-patch: $($(python-meshio)-prefix)/.pkgpatch
$(python-meshio)-build: $($(python-meshio)-prefix)/.pkgbuild
$(python-meshio)-check: $($(python-meshio)-prefix)/.pkgcheck
$(python-meshio)-install: $($(python-meshio)-prefix)/.pkginstall
$(python-meshio)-modulefile: $($(python-meshio)-modulefile)
$(python-meshio)-clean:
	rm -rf $($(python-meshio)-modulefile)
	rm -rf $($(python-meshio)-prefix)
	rm -rf $($(python-meshio)-srcdir)
	rm -rf $($(python-meshio)-src)
$(python-meshio): $(python-meshio)-src $(python-meshio)-unpack $(python-meshio)-patch $(python-meshio)-build $(python-meshio)-check $(python-meshio)-install $(python-meshio)-modulefile
