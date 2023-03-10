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
# python-fenics-fiat-2019.2.0.dev0

python-fenics-fiat-2019.2.0.dev0-version = 2019.2.0.dev0
python-fenics-fiat-2019.2.0.dev0 = python-fenics-fiat-$(python-fenics-fiat-2019.2.0.dev0-version)
$(python-fenics-fiat-2019.2.0.dev0)-description = FEniCS Project: FInite element Automatic Tabulator
$(python-fenics-fiat-2019.2.0.dev0)-url = https://bitbucket.org/fenics-project/fiat/
$(python-fenics-fiat-2019.2.0.dev0)-srcurl = https://github.com/FEniCS/fiat/archive/7d418fa0a372ac6f5e103533ab77ad6a9fac764c.zip
$(python-fenics-fiat-2019.2.0.dev0)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-fiat-2019.2.0.dev0)-srcurl))
$(python-fenics-fiat-2019.2.0.dev0)-srcdir = $(pkgsrcdir)/$(python-fenics-fiat-2019.2.0.dev0)
$(python-fenics-fiat-2019.2.0.dev0)-builddir = $($(python-fenics-fiat-2019.2.0.dev0)-srcdir)/fiat-7d418fa0a372ac6f5e103533ab77ad6a9fac764c
$(python-fenics-fiat-2019.2.0.dev0)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpmath) $(python-sympy-1.4) $(python-pip)
$(python-fenics-fiat-2019.2.0.dev0)-prereqs = $(python) $(python-numpy) $(python-mpmath) $(python-sympy-1.4)
$(python-fenics-fiat-2019.2.0.dev0)-modulefile = $(modulefilesdir)/$(python-fenics-fiat-2019.2.0.dev0)
$(python-fenics-fiat-2019.2.0.dev0)-prefix = $(pkgdir)/$(python-fenics-fiat-2019.2.0.dev0)
$(python-fenics-fiat-2019.2.0.dev0)-site-packages = $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-fiat-2019.2.0.dev0)-src): $(dir $($(python-fenics-fiat-2019.2.0.dev0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-fiat-2019.2.0.dev0)-srcurl)

$($(python-fenics-fiat-2019.2.0.dev0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-fiat-2019.2.0.dev0)-builddir),$($(python-fenics-fiat-2019.2.0.dev0)-srcdir))
$($(python-fenics-fiat-2019.2.0.dev0)-builddir)/.markerfile: $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgunpack: $$($(python-fenics-fiat-2019.2.0.dev0)-src) $($(python-fenics-fiat-2019.2.0.dev0)-srcdir)/.markerfile $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(python-fenics-fiat-2019.2.0.dev0)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgpatch
	cd $($(python-fenics-fiat-2019.2.0.dev0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-2019.2.0.dev0)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgbuild
	@touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-fiat-2019.2.0.dev0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgcheck $($(python-fenics-fiat-2019.2.0.dev0)-site-packages)/.markerfile
	cd $($(python-fenics-fiat-2019.2.0.dev0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-fiat-2019.2.0.dev0)-builddeps) && \
		PYTHONPATH=$($(python-fenics-fiat-2019.2.0.dev0)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-fiat-2019.2.0.dev0)-prefix)
	@touch $@

$($(python-fenics-fiat-2019.2.0.dev0)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-fiat-2019.2.0.dev0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-fiat-2019.2.0.dev0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-2019.2.0.dev0)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-fiat-2019.2.0.dev0)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-fiat-2019.2.0.dev0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_FIAT_2019_ROOT $($(python-fenics-fiat-2019.2.0.dev0)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-fiat-2019.2.0.dev0)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-fiat-2019.2.0.dev0)\"" >>$@

$(python-fenics-fiat-2019.2.0.dev0)-src: $($(python-fenics-fiat-2019.2.0.dev0)-src)
$(python-fenics-fiat-2019.2.0.dev0)-unpack: $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgunpack
$(python-fenics-fiat-2019.2.0.dev0)-patch: $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgpatch
$(python-fenics-fiat-2019.2.0.dev0)-build: $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgbuild
$(python-fenics-fiat-2019.2.0.dev0)-check: $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkgcheck
$(python-fenics-fiat-2019.2.0.dev0)-install: $($(python-fenics-fiat-2019.2.0.dev0)-prefix)/.pkginstall
$(python-fenics-fiat-2019.2.0.dev0)-modulefile: $($(python-fenics-fiat-2019.2.0.dev0)-modulefile)
$(python-fenics-fiat-2019.2.0.dev0)-clean:
	rm -rf $($(python-fenics-fiat-2019.2.0.dev0)-modulefile)
	rm -rf $($(python-fenics-fiat-2019.2.0.dev0)-prefix)
	rm -rf $($(python-fenics-fiat-2019.2.0.dev0)-builddir)
	rm -rf $($(python-fenics-fiat-2019.2.0.dev0)-srcdir)
	rm -rf $($(python-fenics-fiat-2019.2.0.dev0)-src)
$(python-fenics-fiat-2019.2.0.dev0): $(python-fenics-fiat-2019.2.0.dev0)-src $(python-fenics-fiat-2019.2.0.dev0)-unpack $(python-fenics-fiat-2019.2.0.dev0)-patch $(python-fenics-fiat-2019.2.0.dev0)-build $(python-fenics-fiat-2019.2.0.dev0)-check $(python-fenics-fiat-2019.2.0.dev0)-install $(python-fenics-fiat-2019.2.0.dev0)-modulefile
