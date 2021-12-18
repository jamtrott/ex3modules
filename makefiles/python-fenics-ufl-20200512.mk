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
# python-fenics-ufl-20200512

python-fenics-ufl-20200512-version = 20200512
python-fenics-ufl-20200512 = python-fenics-ufl-$(python-fenics-ufl-20200512-version)
$(python-fenics-ufl-20200512)-description = FEniCS Project: Unified Form Language (Experimental)
$(python-fenics-ufl-20200512)-url = https://github.com/FEniCS/ufl/
$(python-fenics-ufl-20200512)-srcurl = https://github.com/FEniCS/ufl/archive/e50f7c7da0e89c3eda9b35be48bc5e99808c8b4d.zip
$(python-fenics-ufl-20200512)-src = $(pkgsrcdir)/python-fenics-ufl-$(notdir $($(python-fenics-ufl-20200512)-srcurl))
$(python-fenics-ufl-20200512)-srcdir = $(pkgsrcdir)/$(python-fenics-ufl-20200512)
$(python-fenics-ufl-20200512)-builddir = $($(python-fenics-ufl-20200512)-srcdir)/ufl-e50f7c7da0e89c3eda9b35be48bc5e99808c8b4d
$(python-fenics-ufl-20200512)-builddeps = $(python) $(blas) $(mpi) $(python-numpy)
$(python-fenics-ufl-20200512)-prereqs = $(python) $(python-numpy)
$(python-fenics-ufl-20200512)-modulefile = $(modulefilesdir)/$(python-fenics-ufl-20200512)
$(python-fenics-ufl-20200512)-prefix = $(pkgdir)/$(python-fenics-ufl-20200512)
$(python-fenics-ufl-20200512)-site-packages = $($(python-fenics-ufl-20200512)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-ufl-20200512)-src): $(dir $($(python-fenics-ufl-20200512)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ufl-20200512)-srcurl)

$($(python-fenics-ufl-20200512)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-ufl-20200512)-builddir),$($(python-fenics-ufl-20200512)-srcdir))
$($(python-fenics-ufl-20200512)-builddir)/.markerfile: $($(python-fenics-ufl-20200512)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-ufl-20200512)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-20200512)-prefix)/.pkgunpack: $$($(python-fenics-ufl-20200512)-src) $($(python-fenics-ufl-20200512)-srcdir)/.markerfile $($(python-fenics-ufl-20200512)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-20200512)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(python-fenics-ufl-20200512)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-ufl-20200512)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-20200512)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-20200512)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ufl-20200512)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ufl-20200512)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-20200512)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-20200512)-prefix)/.pkgpatch $($(python-fenics-ufl-20200512)-builddir)/.markerfile
	cd $($(python-fenics-ufl-20200512)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-20200512)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-ufl-20200512)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-20200512)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-20200512)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-ufl-20200512)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-20200512)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-20200512)-prefix)/.pkgcheck $($(python-fenics-ufl-20200512)-site-packages)/.markerfile $($(python-fenics-ufl-20200512)-builddir)/.markerfile
	cd $($(python-fenics-ufl-20200512)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-20200512)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ufl-20200512)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-ufl-20200512)-prefix)
	@touch $@

$($(python-fenics-ufl-20200512)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ufl-20200512)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ufl-20200512)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ufl-20200512)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-20200512)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-20200512)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ufl-20200512)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_UFL_2019_ROOT $($(python-fenics-ufl-20200512)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ufl-20200512)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ufl-20200512)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ufl-20200512)\"" >>$@

$(python-fenics-ufl-20200512)-src: $($(python-fenics-ufl-20200512)-src)
$(python-fenics-ufl-20200512)-unpack: $($(python-fenics-ufl-20200512)-prefix)/.pkgunpack
$(python-fenics-ufl-20200512)-patch: $($(python-fenics-ufl-20200512)-prefix)/.pkgpatch
$(python-fenics-ufl-20200512)-build: $($(python-fenics-ufl-20200512)-prefix)/.pkgbuild
$(python-fenics-ufl-20200512)-check: $($(python-fenics-ufl-20200512)-prefix)/.pkgcheck
$(python-fenics-ufl-20200512)-install: $($(python-fenics-ufl-20200512)-prefix)/.pkginstall
$(python-fenics-ufl-20200512)-modulefile: $($(python-fenics-ufl-20200512)-modulefile)
$(python-fenics-ufl-20200512)-clean:
	rm -rf $($(python-fenics-ufl-20200512)-modulefile)
	rm -rf $($(python-fenics-ufl-20200512)-prefix)
	rm -rf $($(python-fenics-ufl-20200512)-srcdir)
	rm -rf $($(python-fenics-ufl-20200512)-builddir)
	rm -rf $($(python-fenics-ufl-20200512)-src)
$(python-fenics-ufl-20200512): $(python-fenics-ufl-20200512)-src $(python-fenics-ufl-20200512)-unpack $(python-fenics-ufl-20200512)-patch $(python-fenics-ufl-20200512)-build $(python-fenics-ufl-20200512)-check $(python-fenics-ufl-20200512)-install $(python-fenics-ufl-20200512)-modulefile
