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
# python-fenics-basix-0.3.0

python-fenics-basix-0.3.0-version = 0.3.0
python-fenics-basix-0.3.0 = python-fenics-basix-$(python-fenics-basix-0.3.0-version)
$(python-fenics-basix-0.3.0)-description = Finite element definition and tabulation runtime library
$(python-fenics-basix-0.3.0)-url = https://fenicsproject.org/
$(python-fenics-basix-0.3.0)-srcurl =
$(python-fenics-basix-0.3.0)-builddeps = $(gcc-10.1.0) $(cmake) $(python) $(fenics-basix-0.3.0)
$(python-fenics-basix-0.3.0)-prereqs = $(python) $(fenics-basix-0.3.0)
$(python-fenics-basix-0.3.0)-src = $($(fenics-basix-src-0.3.0)-src)
$(python-fenics-basix-0.3.0)-srcdir = $(pkgsrcdir)/$(python-fenics-basix-0.3.0)
$(python-fenics-basix-0.3.0)-builddir = $(python-fenics-basix-0.3.0-srcdir)/python
$(python-fenics-basix-0.3.0)-modulefile = $(modulefilesdir)/$(python-fenics-basix-0.3.0)
$(python-fenics-basix-0.3.0)-prefix = $(pkgdir)/$(python-fenics-basix-0.3.0)
$(python-fenics-basix-0.3.0)-site-packages = $($(python-fenics-basix-0.3.0)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-fenics-basix-0.3.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-basix-0.3.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-basix-0.3.0)-prefix)/.pkgunpack: $$($(python-fenics-basix-0.3.0)-src) $($(python-fenics-basix-0.3.0)-srcdir)/.markerfile $($(python-fenics-basix-0.3.0)-prefix)/.markerfile
	tar -C $($(python-fenics-basix-0.3.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-basix-0.3.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.3.0)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-basix-0.3.0)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-basix-0.3.0)-builddir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-basix-0.3.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.3.0)-prefix)/.pkgpatch $($(python-fenics-basix-0.3.0)-builddir)/.markerfile
	cd $($(python-fenics-basix-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-basix-0.3.0)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-basix-0.3.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.3.0)-prefix)/.pkgbuild $($(python-fenics-basix-0.3.0)-builddir)/.markerfile
	@touch $@

$($(python-fenics-basix-0.3.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-basix-0.3.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-basix-0.3.0)-prefix)/.pkgcheck $($(python-fenics-basix-0.3.0)-site-packages)/.markerfile $($(python-fenics-basix-0.3.0)-builddir)/.markerfile
	cd $($(python-fenics-basix-0.3.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-basix-0.3.0)-builddeps) && \
		PYTHONPATH=$($(python-fenics-basix-0.3.0)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-basix-0.3.0)-prefix)
	@touch $@

$($(python-fenics-basix-0.3.0)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-basix-0.3.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-basix-0.3.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-basix-0.3.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-basix-0.3.0)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-basix-0.3.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-basix-0.3.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_BASIX_ROOT $($(python-fenics-basix-0.3.0)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-basix-0.3.0)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-basix-0.3.0)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-basix-0.3.0)\"" >>$@

$(python-fenics-basix-0.3.0)-src: $($(python-fenics-basix-0.3.0)-src)
$(python-fenics-basix-0.3.0)-unpack: $($(python-fenics-basix-0.3.0)-prefix)/.pkgunpack
$(python-fenics-basix-0.3.0)-patch: $($(python-fenics-basix-0.3.0)-prefix)/.pkgpatch
$(python-fenics-basix-0.3.0)-build: $($(python-fenics-basix-0.3.0)-prefix)/.pkgbuild
$(python-fenics-basix-0.3.0)-check: $($(python-fenics-basix-0.3.0)-prefix)/.pkgcheck
$(python-fenics-basix-0.3.0)-install: $($(python-fenics-basix-0.3.0)-prefix)/.pkginstall
$(python-fenics-basix-0.3.0)-modulefile: $($(python-fenics-basix-0.3.0)-modulefile)
$(python-fenics-basix-0.3.0)-clean:
	rm -rf $($(python-fenics-basix-0.3.0)-modulefile)
	rm -rf $($(python-fenics-basix-0.3.0)-prefix)
	rm -rf $($(python-fenics-basix-0.3.0)-srcdir)
$(python-fenics-basix-0.3.0): $(python-fenics-basix-0.3.0)-src $(python-fenics-basix-0.3.0)-unpack $(python-fenics-basix-0.3.0)-patch $(python-fenics-basix-0.3.0)-build $(python-fenics-basix-0.3.0)-check $(python-fenics-basix-0.3.0)-install $(python-fenics-basix-0.3.0)-modulefile
