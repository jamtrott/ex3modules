# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# python-fenics-ufl-2021.1.0

python-fenics-ufl-2021.1.0-version = 2021.1.0
python-fenics-ufl-2021.1.0 = python-fenics-ufl-$(python-fenics-ufl-2021.1.0-version)
$(python-fenics-ufl-2021.1.0)-description = FEniCS Project: Unified Form Language (Experimental)
$(python-fenics-ufl-2021.1.0)-url = https://github.com/FEniCS/ufl/
$(python-fenics-ufl-2021.1.0)-srcurl = https://github.com/FEniCS/ufl/archive/refs/tags/2021.1.0.tar.gz
$(python-fenics-ufl-2021.1.0)-src = $(pkgsrcdir)/python-fenics-ufl-$(notdir $($(python-fenics-ufl-2021.1.0)-srcurl))
$(python-fenics-ufl-2021.1.0)-srcdir = $(pkgsrcdir)/$(python-fenics-ufl-2021.1.0)
$(python-fenics-ufl-2021.1.0)-builddir = $($(python-fenics-ufl-2021.1.0)-srcdir)
$(python-fenics-ufl-2021.1.0)-builddeps = $(python) $(blas) $(mpi) $(python-numpy)
$(python-fenics-ufl-2021.1.0)-prereqs = $(python) $(python-numpy)
$(python-fenics-ufl-2021.1.0)-modulefile = $(modulefilesdir)/$(python-fenics-ufl-2021.1.0)
$(python-fenics-ufl-2021.1.0)-prefix = $(pkgdir)/$(python-fenics-ufl-2021.1.0)
$(python-fenics-ufl-2021.1.0)-site-packages = $($(python-fenics-ufl-2021.1.0)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-fenics-ufl-2021.1.0)-src): $(dir $($(python-fenics-ufl-2021.1.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ufl-2021.1.0)-srcurl)

$($(python-fenics-ufl-2021.1.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-ufl-2021.1.0)-builddir),$($(python-fenics-ufl-2021.1.0)-srcdir))
$($(python-fenics-ufl-2021.1.0)-builddir)/.markerfile: $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-ufl-2021.1.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ufl-2021.1.0)-prefix)/.pkgunpack: $$($(python-fenics-ufl-2021.1.0)-src) $($(python-fenics-ufl-2021.1.0)-srcdir)/.markerfile $($(python-fenics-ufl-2021.1.0)-prefix)/.markerfile
	tar -C $($(python-fenics-ufl-2021.1.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-ufl-2021.1.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ufl-2021.1.0)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ufl-2021.1.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgpatch $($(python-fenics-ufl-2021.1.0)-builddir)/.markerfile
	cd $($(python-fenics-ufl-2021.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2021.1.0)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-ufl-2021.1.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-ufl-2021.1.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ufl-2021.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgcheck $($(python-fenics-ufl-2021.1.0)-site-packages)/.markerfile $($(python-fenics-ufl-2021.1.0)-builddir)/.markerfile
	cd $($(python-fenics-ufl-2021.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ufl-2021.1.0)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ufl-2021.1.0)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-ufl-2021.1.0)-prefix)
	@touch $@

$($(python-fenics-ufl-2021.1.0)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ufl-2021.1.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ufl-2021.1.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ufl-2021.1.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2021.1.0)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ufl-2021.1.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ufl-2021.1.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_UFL_ROOT $($(python-fenics-ufl-2021.1.0)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ufl-2021.1.0)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ufl-2021.1.0)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ufl-2021.1.0)\"" >>$@

$(python-fenics-ufl-2021.1.0)-src: $($(python-fenics-ufl-2021.1.0)-src)
$(python-fenics-ufl-2021.1.0)-unpack: $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgunpack
$(python-fenics-ufl-2021.1.0)-patch: $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgpatch
$(python-fenics-ufl-2021.1.0)-build: $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgbuild
$(python-fenics-ufl-2021.1.0)-check: $($(python-fenics-ufl-2021.1.0)-prefix)/.pkgcheck
$(python-fenics-ufl-2021.1.0)-install: $($(python-fenics-ufl-2021.1.0)-prefix)/.pkginstall
$(python-fenics-ufl-2021.1.0)-modulefile: $($(python-fenics-ufl-2021.1.0)-modulefile)
$(python-fenics-ufl-2021.1.0)-clean:
	rm -rf $($(python-fenics-ufl-2021.1.0)-modulefile)
	rm -rf $($(python-fenics-ufl-2021.1.0)-prefix)
	rm -rf $($(python-fenics-ufl-2021.1.0)-srcdir)
	rm -rf $($(python-fenics-ufl-2021.1.0)-builddir)
	rm -rf $($(python-fenics-ufl-2021.1.0)-src)
$(python-fenics-ufl-2021.1.0): $(python-fenics-ufl-2021.1.0)-src $(python-fenics-ufl-2021.1.0)-unpack $(python-fenics-ufl-2021.1.0)-patch $(python-fenics-ufl-2021.1.0)-build $(python-fenics-ufl-2021.1.0)-check $(python-fenics-ufl-2021.1.0)-install $(python-fenics-ufl-2021.1.0)-modulefile
