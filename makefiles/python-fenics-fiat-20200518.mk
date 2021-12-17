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
# python-fenics-fiat-20200518

python-fenics-fiat-20200518-version = 20200518
python-fenics-fiat-20200518 = python-fenics-fiat-$(python-fenics-fiat-20200518-version)
$(python-fenics-fiat-20200518)-description = FEniCS Project: FInite element Automatic Tabulator (Experimental)
$(python-fenics-fiat-20200518)-url = https://github.com/FEniCS/fiat/
$(python-fenics-fiat-20200518)-srcurl = https://github.com/FEniCS/fiat/archive/a8c4d489da0d783921e2e9e261e43717b8a28882.zip
$(python-fenics-fiat-20200518)-src = $(pkgsrcdir)/python-fenics-fiat-$(notdir $($(python-fenics-fiat-20200518)-srcurl))
$(python-fenics-fiat-20200518)-srcdir = $(pkgsrcdir)/$(python-fenics-fiat-20200518)
$(python-fenics-fiat-20200518)-builddir = $($(python-fenics-fiat-20200518)-srcdir)/fiat-a8c4d489da0d783921e2e9e261e43717b8a28882
$(python-fenics-fiat-20200518)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpmath) $(python-sympy-1.4)
$(python-fenics-fiat-20200518)-prereqs = $(python) $(python-numpy) $(python-mpmath) $(python-sympy-1.4)
$(python-fenics-fiat-20200518)-modulefile = $(modulefilesdir)/$(python-fenics-fiat-20200518)
$(python-fenics-fiat-20200518)-prefix = $(pkgdir)/$(python-fenics-fiat-20200518)
$(python-fenics-fiat-20200518)-site-packages = $($(python-fenics-fiat-20200518)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-fiat-20200518)-src): $(dir $($(python-fenics-fiat-20200518)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-fiat-20200518)-srcurl)

$($(python-fenics-fiat-20200518)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-fiat-20200518)-builddir),$($(python-fenics-fiat-20200518)-srcdir))
$($(python-fenics-fiat-20200518)-builddir)/.markerfile: $($(python-fenics-fiat-20200518)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-fiat-20200518)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-fiat-20200518)-prefix)/.pkgunpack: $$($(python-fenics-fiat-20200518)-src) $($(python-fenics-fiat-20200518)-srcdir)/.markerfile $($(python-fenics-fiat-20200518)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-20200518)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(python-fenics-fiat-20200518)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-fiat-20200518)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-20200518)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-20200518)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-fiat-20200518)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-fiat-20200518)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-20200518)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-20200518)-prefix)/.pkgpatch $($(python-fenics-fiat-20200518)-builddir)/.markerfile
	cd $($(python-fenics-fiat-20200518)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-20200518)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-fiat-20200518)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-20200518)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-20200518)-prefix)/.pkgbuild $($(python-fenics-fiat-20200518)-builddir)/.markerfile
	@touch $@

$($(python-fenics-fiat-20200518)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-20200518)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-20200518)-prefix)/.pkgcheck $($(python-fenics-fiat-20200518)-site-packages)/.markerfile $($(python-fenics-fiat-20200518)-builddir)/.markerfile
	cd $($(python-fenics-fiat-20200518)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-20200518)-builddeps) && \
		PYTHONPATH=$($(python-fenics-fiat-20200518)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-fiat-20200518)-prefix)
	@touch $@

$($(python-fenics-fiat-20200518)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-fiat-20200518)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-fiat-20200518)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-fiat-20200518)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-20200518)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-20200518)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-fiat-20200518)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_FIAT_20200518_ROOT $($(python-fenics-fiat-20200518)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-fiat-20200518)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-fiat-20200518)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-fiat-20200518)\"" >>$@

$(python-fenics-fiat-20200518)-src: $($(python-fenics-fiat-20200518)-src)
$(python-fenics-fiat-20200518)-unpack: $($(python-fenics-fiat-20200518)-prefix)/.pkgunpack
$(python-fenics-fiat-20200518)-patch: $($(python-fenics-fiat-20200518)-prefix)/.pkgpatch
$(python-fenics-fiat-20200518)-build: $($(python-fenics-fiat-20200518)-prefix)/.pkgbuild
$(python-fenics-fiat-20200518)-check: $($(python-fenics-fiat-20200518)-prefix)/.pkgcheck
$(python-fenics-fiat-20200518)-install: $($(python-fenics-fiat-20200518)-prefix)/.pkginstall
$(python-fenics-fiat-20200518)-modulefile: $($(python-fenics-fiat-20200518)-modulefile)
$(python-fenics-fiat-20200518)-clean:
	rm -rf $($(python-fenics-fiat-20200518)-modulefile)
	rm -rf $($(python-fenics-fiat-20200518)-prefix)
	rm -rf $($(python-fenics-fiat-20200518)-builddir)
	rm -rf $($(python-fenics-fiat-20200518)-srcdir)
	rm -rf $($(python-fenics-fiat-20200518)-src)
$(python-fenics-fiat-20200518): $(python-fenics-fiat-20200518)-src $(python-fenics-fiat-20200518)-unpack $(python-fenics-fiat-20200518)-patch $(python-fenics-fiat-20200518)-build $(python-fenics-fiat-20200518)-check $(python-fenics-fiat-20200518)-install $(python-fenics-fiat-20200518)-modulefile
