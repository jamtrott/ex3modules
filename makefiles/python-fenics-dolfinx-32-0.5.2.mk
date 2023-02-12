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
# python-fenics-dolfinx-32-0.5.2

python-fenics-dolfinx-32-0.5.2-version = 0.5.2
python-fenics-dolfinx-32-0.5.2 = python-fenics-dolfinx-32-$(python-fenics-dolfinx-32-0.5.2-version)
$(python-fenics-dolfinx-32-0.5.2)-description = Next generation FEniCS problem solving environment
$(python-fenics-dolfinx-32-0.5.2)-url = https://github.com/FEniCS/dolfinx
$(python-fenics-dolfinx-32-0.5.2)-srcurl =
$(python-fenics-dolfinx-32-0.5.2)-src = $($(fenics-dolfinx-src-0.5.2)-src)
$(python-fenics-dolfinx-32-0.5.2)-builddeps = $(python) $(fenics-dolfinx-32-0.5.2) $(python-pip)
$(python-fenics-dolfinx-32-0.5.2)-prereqs = $(python) $(fenics-dolfinx-32-0.5.2)
$(python-fenics-dolfinx-32-0.5.2)-srcdir = $(pkgsrcdir)/$(python-fenics-dolfinx-32-0.5.2)
$(python-fenics-dolfinx-32-0.5.2)-modulefile = $(modulefilesdir)/$(python-fenics-dolfinx-32-0.5.2)
$(python-fenics-dolfinx-32-0.5.2)-prefix = $(pkgdir)/$(python-fenics-dolfinx-32-0.5.2)
$(python-fenics-dolfinx-32-0.5.2)-site-packages = $($(python-fenics-dolfinx-32-0.5.2)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-fenics-dolfinx-32-0.5.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfinx-32-0.5.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgunpack: $$($(python-fenics-dolfinx-32-0.5.2)-src) $($(python-fenics-dolfinx-32-0.5.2)-srcdir)/.markerfile $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-32-0.5.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-fenics-dolfinx-32-0.5.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-32-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-dolfinx-32-0.5.2)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-32-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgpatch
	cd $($(python-fenics-dolfinx-32-0.5.2)-srcdir)/python && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-32-0.5.2)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-32-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgbuild
	cd $($(python-fenics-dolfinx-32-0.5.2)-srcdir)/python && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-32-0.5.2)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-dolfinx-32-0.5.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgcheck $($(python-fenics-dolfinx-32-0.5.2)-site-packages)/.markerfile
	cd $($(python-fenics-dolfinx-32-0.5.2)-srcdir)/python && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-dolfinx-32-0.5.2)-builddeps) && \
		PYTHONPATH=$($(python-fenics-dolfinx-32-0.5.2)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-fenics-dolfinx-32-0.5.2)-prefix)
	@touch $@

$($(python-fenics-dolfinx-32-0.5.2)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-dolfinx-32-0.5.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-dolfinx-32-0.5.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-dolfinx-32-0.5.2)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-dolfinx-32-0.5.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-dolfinx-32-0.5.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS-DOLFINX-32-0.5.2_ROOT $($(python-fenics-dolfinx-32-0.5.2)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-dolfinx-32-0.5.2)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-dolfinx-32-0.5.2)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-dolfinx-32-0.5.2)\"" >>$@

$(python-fenics-dolfinx-32-0.5.2)-src: $($(python-fenics-dolfinx-32-0.5.2)-src)
$(python-fenics-dolfinx-32-0.5.2)-unpack: $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgunpack
$(python-fenics-dolfinx-32-0.5.2)-patch: $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgpatch
$(python-fenics-dolfinx-32-0.5.2)-build: $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgbuild
$(python-fenics-dolfinx-32-0.5.2)-check: $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkgcheck
$(python-fenics-dolfinx-32-0.5.2)-install: $($(python-fenics-dolfinx-32-0.5.2)-prefix)/.pkginstall
$(python-fenics-dolfinx-32-0.5.2)-modulefile: $($(python-fenics-dolfinx-32-0.5.2)-modulefile)
$(python-fenics-dolfinx-32-0.5.2)-clean:
	rm -rf $($(python-fenics-dolfinx-32-0.5.2)-modulefile)
	rm -rf $($(python-fenics-dolfinx-32-0.5.2)-prefix)
	rm -rf $($(python-fenics-dolfinx-32-0.5.2)-srcdir)
	rm -rf $($(python-fenics-dolfinx-32-0.5.2)-src)
$(python-fenics-dolfinx-32-0.5.2): $(python-fenics-dolfinx-32-0.5.2)-src $(python-fenics-dolfinx-32-0.5.2)-unpack $(python-fenics-dolfinx-32-0.5.2)-patch $(python-fenics-dolfinx-32-0.5.2)-build $(python-fenics-dolfinx-32-0.5.2)-check $(python-fenics-dolfinx-32-0.5.2)-install $(python-fenics-dolfinx-32-0.5.2)-modulefile
