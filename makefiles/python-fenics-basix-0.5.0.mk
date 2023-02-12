# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# python-fenics-basix-0.5.0

python-fenics-basix-0.5.0-version = 0.5.0
python-fenics-basix-0.5.0 = python-fenics-basix-$(python-fenics-basix-0.5.0-version)
$(python-fenics-basix-0.5.0)-description = FEniCS Project: finite element definition and tabulation runtime library
$(python-fenics-basix-0.5.0)-url = https://github.com/FEniCS/basix/
$(python-fenics-basix-0.5.0)-srcurl = https://files.pythonhosted.org/packages/dc/1c/e84f268888ae85dd9f07f06bb1303c03d07dbd5b816795e6b80d3ed3012f/fenics-basix-0.5.0.tar.gz
$(python-fenics-basix-0.5.0)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-basix-0.5.0)-srcurl))
$(python-fenics-basix-0.5.0)-srcdir = $(pkgsrcdir)/$(python-fenics-basix-0.5.0)
$(python-fenics-basix-0.5.0)-builddir = $($(python-fenics-basix-0.5.0)-srcdir)
$(python-fenics-basix-0.5.0)-builddeps = $(python) $(blas) $(python-numpy) $(python-numba) $(python-pip) $(python-scikit-build) $(python-packaging) $(python-typing_extensions)
$(python-fenics-basix-0.5.0)-prereqs = $(python) $(blas) $(python-numpy) $(python-numba) $(python-fenics-ufl-2022)
$(python-fenics-basix-0.5.0)-modulefile = $(modulefilesdir)/$(python-fenics-basix-0.5.0)
$(python-fenics-basix-0.5.0)-prefix = $(pkgdir)/$(python-fenics-basix-0.5.0)
$(python-fenics-basix-0.5.0)-site-packages = $($(python-fenics-basix-0.5.0)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-basix-0.5.0)-src): $(dir $($(python-fenics-basix-0.5.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-basix-0.5.0)-srcurl)

$($(python-fenics-basix-0.5.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-basix-0.5.0)-builddir),$($(python-fenics-basix-0.5.0)-srcdir))
$($(python-fenics-basix-0.5.0)-builddir)/.markerfile: $($(python-fenics-basix-0.5.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-basix-0.5.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-basix-0.5.0)-prefix)/.pkgunpack: $$($(python-fenics-basix-0.5.0)-src) $($(python-fenics-basix-0.5.0)-srcdir)/.markerfile $($(python-fenics-basix-0.5.0)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.5.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-basix-0.5.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-basix-0.5.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.5.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.5.0)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-basix-0.5.0)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-basix-0.5.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.5.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.5.0)-prefix)/.pkgpatch $($(python-fenics-basix-0.5.0)-builddir)/.markerfile
	@touch $@

$($(python-fenics-basix-0.5.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.5.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.5.0)-prefix)/.pkgbuild $($(python-fenics-basix-0.5.0)-builddir)/.markerfile
#	cd $($(python-fenics-basix-0.5.0)-builddir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(python-fenics-basix-0.5.0)-builddeps) && \
#		$(PYTHON) test/test.py
	@touch $@

$($(python-fenics-basix-0.5.0)-prefix)/include/.markerfile: $($(python-fenics-basix-0.5.0)-prefix)/.pkgcheck
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-basix-0.5.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.5.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.5.0)-prefix)/.pkgcheck $($(python-fenics-basix-0.5.0)-site-packages)/.markerfile $($(python-fenics-basix-0.5.0)-builddir)/.markerfile
	cd $($(python-fenics-basix-0.5.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-basix-0.5.0)-builddeps) && \
		PYTHONPATH=$($(python-fenics-basix-0.5.0)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-basix-0.5.0)-prefix)
	@touch $@

$($(python-fenics-basix-0.5.0)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-basix-0.5.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-basix-0.5.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-basix-0.5.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-basix-0.5.0)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-basix-0.5.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-basix-0.5.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_BASIX_ROOT $($(python-fenics-basix-0.5.0)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-basix-0.5.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(python-fenics-basix-0.5.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(python-fenics-basix-0.5.0)-prefix)/include" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-basix-0.5.0)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-basix-0.5.0)\"" >>$@

$(python-fenics-basix-0.5.0)-src: $($(python-fenics-basix-0.5.0)-src)
$(python-fenics-basix-0.5.0)-unpack: $($(python-fenics-basix-0.5.0)-prefix)/.pkgunpack
$(python-fenics-basix-0.5.0)-patch: $($(python-fenics-basix-0.5.0)-prefix)/.pkgpatch
$(python-fenics-basix-0.5.0)-build: $($(python-fenics-basix-0.5.0)-prefix)/.pkgbuild
$(python-fenics-basix-0.5.0)-check: $($(python-fenics-basix-0.5.0)-prefix)/.pkgcheck
$(python-fenics-basix-0.5.0)-install: $($(python-fenics-basix-0.5.0)-prefix)/.pkginstall
$(python-fenics-basix-0.5.0)-modulefile: $($(python-fenics-basix-0.5.0)-modulefile)
$(python-fenics-basix-0.5.0)-clean:
	rm -rf $($(python-fenics-basix-0.5.0)-modulefile)
	rm -rf $($(python-fenics-basix-0.5.0)-prefix)
	rm -rf $($(python-fenics-basix-0.5.0)-builddir)
	rm -rf $($(python-fenics-basix-0.5.0)-srcdir)
	rm -rf $($(python-fenics-basix-0.5.0)-src)
$(python-fenics-basix-0.5.0): $(python-fenics-basix-0.5.0)-src $(python-fenics-basix-0.5.0)-unpack $(python-fenics-basix-0.5.0)-patch $(python-fenics-basix-0.5.0)-build $(python-fenics-basix-0.5.0)-check $(python-fenics-basix-0.5.0)-install $(python-fenics-basix-0.5.0)-modulefile
