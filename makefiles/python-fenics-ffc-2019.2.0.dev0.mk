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
# python-fenics-ffc-2019.2.0.dev0

python-fenics-ffc-2019.2.0.dev0-version = 2019.2.0.dev0
python-fenics-ffc-2019.2.0.dev0 = python-fenics-ffc-$(python-fenics-ffc-2019.2.0.dev0-version)
$(python-fenics-ffc-2019.2.0.dev0)-description = FEniCS Project: FEniCS Form Compiler
$(python-fenics-ffc-2019.2.0.dev0)-url = https://bitbucket.org/fenics-project/ffc/
$(python-fenics-ffc-2019.2.0.dev0)-srcurl = https://bitbucket.org/fenics-project/ffc/get/72129fd974f582bb1f7ed96121c3d216665c9ead.tar.gz
$(python-fenics-ffc-2019.2.0.dev0)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-ffc-2019.2.0.dev0)-srcurl))
$(python-fenics-ffc-2019.2.0.dev0)-srcdir = $(pkgsrcdir)/$(python-fenics-ffc-2019.2.0.dev0)
$(python-fenics-ffc-2019.2.0.dev0)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpmath) $(python-sympy-1.4) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019.2.0.dev0) $(python-fenics-ufl-legacy-2022.3.0) $(python-fenics-ufl-legacy-2022.3.0) $(python-setuptools) $(python-wheel) $(python-pip)
$(python-fenics-ffc-2019.2.0.dev0)-prereqs = $(python) $(python-numpy) $(python-mpmath) $(python-sympy-1.4) $(python-fenics-dijitso-2019) $(python-fenics-fiat-2019.2.0.dev0) $(python-fenics-ufl-legacy-2022.3.0)
$(python-fenics-ffc-2019.2.0.dev0)-modulefile = $(modulefilesdir)/$(python-fenics-ffc-2019.2.0.dev0)
$(python-fenics-ffc-2019.2.0.dev0)-prefix = $(pkgdir)/$(python-fenics-ffc-2019.2.0.dev0)
$(python-fenics-ffc-2019.2.0.dev0)-site-packages = $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-ffc-2019.2.0.dev0)-src): $(dir $($(python-fenics-ffc-2019.2.0.dev0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ffc-2019.2.0.dev0)-srcurl)

$($(python-fenics-ffc-2019.2.0.dev0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgunpack: $$($(python-fenics-ffc-2019.2.0.dev0)-src) $($(python-fenics-ffc-2019.2.0.dev0)-srcdir)/.markerfile $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-ffc-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-ffc-2019.2.0.dev0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffc-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffc-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgpatch
	cd $($(python-fenics-ffc-2019.2.0.dev0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ffc-2019.2.0.dev0)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffc-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgbuild
#	cd $($(python-fenics-ffc-2019.2.0.dev0)-srcdir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(python-fenics-ffc-2019.2.0.dev0)-builddeps) && \
#		$(PYTHON) test/test.py
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/.markerfile: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgcheck
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/ufc.h: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/.markerfile $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgcheck
	$(INSTALL) $($(python-fenics-ffc-2019.2.0.dev0)-srcdir)/ffc/backends/ufc/ufc.h $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/ufc_geometry.h: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/.markerfile $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgcheck
	$(INSTALL) $($(python-fenics-ffc-2019.2.0.dev0)-srcdir)/ffc/backends/ufc/ufc_geometry.h $@

$($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffc-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgcheck $($(python-fenics-ffc-2019.2.0.dev0)-site-packages)/.markerfile $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/ufc.h $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include/ufc_geometry.h
	cd $($(python-fenics-ffc-2019.2.0.dev0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ffc-2019.2.0.dev0)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ffc-2019.2.0.dev0)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-ffc-2019.2.0.dev0)-prefix)
	@touch $@

$($(python-fenics-ffc-2019.2.0.dev0)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ffc-2019.2.0.dev0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ffc-2019.2.0.dev0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ffc-2019.2.0.dev0)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ffc-2019.2.0.dev0)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ffc-2019.2.0.dev0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_FFC_2019_ROOT $($(python-fenics-ffc-2019.2.0.dev0)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/include" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ffc-2019.2.0.dev0)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ffc-2019.2.0.dev0)\"" >>$@

$(python-fenics-ffc-2019.2.0.dev0)-src: $($(python-fenics-ffc-2019.2.0.dev0)-src)
$(python-fenics-ffc-2019.2.0.dev0)-unpack: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgunpack
$(python-fenics-ffc-2019.2.0.dev0)-patch: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgpatch
$(python-fenics-ffc-2019.2.0.dev0)-build: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgbuild
$(python-fenics-ffc-2019.2.0.dev0)-check: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkgcheck
$(python-fenics-ffc-2019.2.0.dev0)-install: $($(python-fenics-ffc-2019.2.0.dev0)-prefix)/.pkginstall
$(python-fenics-ffc-2019.2.0.dev0)-modulefile: $($(python-fenics-ffc-2019.2.0.dev0)-modulefile)
$(python-fenics-ffc-2019.2.0.dev0)-clean:
	rm -rf $($(python-fenics-ffc-2019.2.0.dev0)-modulefile)
	rm -rf $($(python-fenics-ffc-2019.2.0.dev0)-prefix)
	rm -rf $($(python-fenics-ffc-2019.2.0.dev0)-srcdir)
	rm -rf $($(python-fenics-ffc-2019.2.0.dev0)-src)
$(python-fenics-ffc-2019.2.0.dev0): $(python-fenics-ffc-2019.2.0.dev0)-src $(python-fenics-ffc-2019.2.0.dev0)-unpack $(python-fenics-ffc-2019.2.0.dev0)-patch $(python-fenics-ffc-2019.2.0.dev0)-build $(python-fenics-ffc-2019.2.0.dev0)-check $(python-fenics-ffc-2019.2.0.dev0)-install $(python-fenics-ffc-2019.2.0.dev0)-modulefile
