# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# python-dask-2026.1.2

python-dask-version = 2026.1.2
python-dask = python-dask-$(python-dask-version)
$(python-dask)-description = Dask is a flexible parallel computing library for analytics
$(python-dask)-url = https://github.com/dask/dask/
$(python-dask)-srcurl = https://files.pythonhosted.org/packages/bd/52/b0f9172b22778def907db1ff173249e4eb41f054b46a9c83b1528aaf811f/dask-2026.1.2.tar.gz
$(python-dask)-src = $(pkgsrcdir)/$(notdir $($(python-dask)-srcurl))
$(python-dask)-builddeps = $(python) $(python-pip) $(python-click) $(python-cloudpickle) $(python-fsspec) $(python-packaging) $(python-partd) $(python-pyyaml) $(python-toolz)
$(python-dask)-prereqs = $(python) $(python-click) $(python-cloudpickle) $(python-fsspec) $(python-packaging) $(python-partd) $(python-pyyaml) $(python-toolz) $(python-importlib_metadata)
$(python-dask)-srcdir = $(pkgsrcdir)/$(python-dask)
$(python-dask)-modulefile = $(modulefilesdir)/$(python-dask)
$(python-dask)-prefix = $(pkgdir)/$(python-dask)

$($(python-dask)-src): $(dir $($(python-dask)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-dask)-srcurl)

$($(python-dask)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-dask)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-dask)-prefix)/.pkgunpack: $$($(python-dask)-src) $($(python-dask)-srcdir)/.markerfile $($(python-dask)-prefix)/.markerfile $$(foreach dep,$$($(python-dask)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-dask)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-dask)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dask)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dask)-prefix)/.pkgunpack
	@touch $@

$($(python-dask)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dask)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dask)-prefix)/.pkgpatch
	@touch $@

$($(python-dask)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dask)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dask)-prefix)/.pkgbuild
	@touch $@

$($(python-dask)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dask)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dask)-prefix)/.pkgcheck
	cd $($(python-dask)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-dask)-builddeps) && \
		PYTHONPATH=$($(python-dask)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-dask)-prefix)
	@touch $@

$($(python-dask)-modulefile): $(modulefilesdir)/.markerfile $($(python-dask)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-dask)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-dask)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-dask)-description)\"" >>$@
	echo "module-whatis \"$($(python-dask)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-dask)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_DASK_ROOT $($(python-dask)-prefix)" >>$@
	echo "prepend-path PATH $($(python-dask)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-dask)-prefix)" >>$@
	echo "set MSG \"$(python-dask)\"" >>$@

$(python-dask)-src: $($(python-dask)-src)
$(python-dask)-unpack: $($(python-dask)-prefix)/.pkgunpack
$(python-dask)-patch: $($(python-dask)-prefix)/.pkgpatch
$(python-dask)-build: $($(python-dask)-prefix)/.pkgbuild
$(python-dask)-check: $($(python-dask)-prefix)/.pkgcheck
$(python-dask)-install: $($(python-dask)-prefix)/.pkginstall
$(python-dask)-modulefile: $($(python-dask)-modulefile)
$(python-dask)-clean:
	rm -rf $($(python-dask)-modulefile)
	rm -rf $($(python-dask)-prefix)
	rm -rf $($(python-dask)-srcdir)
	rm -rf $($(python-dask)-src)
$(python-dask): $(python-dask)-src $(python-dask)-unpack $(python-dask)-patch $(python-dask)-build $(python-dask)-check $(python-dask)-install $(python-dask)-modulefile
