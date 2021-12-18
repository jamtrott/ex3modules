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
# python-xarray-0.15.1

python-xarray-version = 0.15.1
python-xarray = python-xarray-$(python-xarray-version)
$(python-xarray)-description = Python package for working with multi-dimensional arrays
$(python-xarray)-url = http://xarray.pydata.org/
$(python-xarray)-srcurl = https://files.pythonhosted.org/packages/f9/5b/04b117f3f8aca131635e30b6b2c8af10a67db660bc3e879ea75f5dc74a66/xarray-0.15.1.tar.gz
$(python-xarray)-src = $(pkgsrcdir)/$(notdir $($(python-xarray)-srcurl))
$(python-xarray)-srcdir = $(pkgsrcdir)/$(python-xarray)
$(python-xarray)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-pandas) $(python-scipy) $(python-matplotlib) $(python-pytest)
$(python-xarray)-prereqs = $(python) $(python-numpy) $(python-pandas) $(python-scipy) $(python-matplotlib)
$(python-xarray)-modulefile = $(modulefilesdir)/$(python-xarray)
$(python-xarray)-prefix = $(pkgdir)/$(python-xarray)
$(python-xarray)-site-packages = $($(python-xarray)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-xarray)-src): $(dir $($(python-xarray)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-xarray)-srcurl)

$($(python-xarray)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-xarray)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-xarray)-prefix)/.pkgunpack: $$($(python-xarray)-src) $($(python-xarray)-srcdir)/.markerfile $($(python-xarray)-prefix)/.markerfile $$(foreach dep,$$($(python-xarray)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-xarray)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-xarray)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-xarray)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-xarray)-prefix)/.pkgunpack
	@touch $@

$($(python-xarray)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-xarray)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-xarray)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-xarray)-prefix)/.pkgpatch
	cd $($(python-xarray)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-xarray)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-xarray)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-xarray)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-xarray)-prefix)/.pkgbuild
	@touch $@

$($(python-xarray)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-xarray)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-xarray)-prefix)/.pkgcheck $($(python-xarray)-site-packages)/.markerfile
	cd $($(python-xarray)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-xarray)-builddeps) && \
		PYTHONPATH=$($(python-xarray)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-xarray)-prefix)
	@touch $@

$($(python-xarray)-modulefile): $(modulefilesdir)/.markerfile $($(python-xarray)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-xarray)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-xarray)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-xarray)-description)\"" >>$@
	echo "module-whatis \"$($(python-xarray)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-xarray)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_XARRAY_ROOT $($(python-xarray)-prefix)" >>$@
	echo "prepend-path PATH $($(python-xarray)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-xarray)-site-packages)" >>$@
	echo "set MSG \"$(python-xarray)\"" >>$@

$(python-xarray)-src: $($(python-xarray)-src)
$(python-xarray)-unpack: $($(python-xarray)-prefix)/.pkgunpack
$(python-xarray)-patch: $($(python-xarray)-prefix)/.pkgpatch
$(python-xarray)-build: $($(python-xarray)-prefix)/.pkgbuild
$(python-xarray)-check: $($(python-xarray)-prefix)/.pkgcheck
$(python-xarray)-install: $($(python-xarray)-prefix)/.pkginstall
$(python-xarray)-modulefile: $($(python-xarray)-modulefile)
$(python-xarray)-clean:
	rm -rf $($(python-xarray)-modulefile)
	rm -rf $($(python-xarray)-prefix)
	rm -rf $($(python-xarray)-srcdir)
	rm -rf $($(python-xarray)-src)
$(python-xarray): $(python-xarray)-src $(python-xarray)-unpack $(python-xarray)-patch $(python-xarray)-build $(python-xarray)-check $(python-xarray)-install $(python-xarray)-modulefile
