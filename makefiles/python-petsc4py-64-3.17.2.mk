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
# python-petsc4py-64-3.17.2

python-petsc4py-64-version = 3.17.2
python-petsc4py-64 = python-petsc4py-64-$(python-petsc4py-64-version)
$(python-petsc4py-64)-description = Python bindings for PETSc
$(python-petsc4py-64)-url = https://bitbucket.org/petsc/petsc4py/
$(python-petsc4py-64)-srcurl =
$(python-petsc4py-64)-src = $($(python-petsc4py)-src)
$(python-petsc4py-64)-srcdir = $(pkgsrcdir)/$(python-petsc4py-64)
$(python-petsc4py-64)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpi4py) $(petsc-64) $(python-pip)
$(python-petsc4py-64)-prereqs = $(python) $(python-numpy) $(python-mpi4py) $(petsc-64)
$(python-petsc4py-64)-modulefile = $(modulefilesdir)/$(python-petsc4py-64)
$(python-petsc4py-64)-prefix = $(pkgdir)/$(python-petsc4py-64)
$(python-petsc4py-64)-site-packages = $($(python-petsc4py-64)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-petsc4py-64)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-petsc4py-64)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-petsc4py-64)-prefix)/.pkgunpack: $$($(python-petsc4py-64)-src) $($(python-petsc4py-64)-srcdir)/.markerfile $($(python-petsc4py-64)-prefix)/.markerfile $$(foreach dep,$$($(python-petsc4py-64)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-petsc4py-64)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-petsc4py-64)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py-64)-prefix)/.pkgunpack
	@touch $@

$($(python-petsc4py-64)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-petsc4py-64)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py-64)-prefix)/.pkgpatch
	cd $($(python-petsc4py-64)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-petsc4py-64)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-petsc4py-64)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py-64)-prefix)/.pkgbuild
# 	cd $($(python-petsc4py-64)-srcdir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(python-petsc4py-64)-builddeps) && \
# 		$(PYTHON) setup.py test
	@touch $@

$($(python-petsc4py-64)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py-64)-prefix)/.pkgcheck $($(python-petsc4py-64)-site-packages)/.markerfile
	cd $($(python-petsc4py-64)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-petsc4py-64)-builddeps) && \
		PYTHONPATH=$($(python-petsc4py-64)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-petsc4py-64)-prefix)
	@touch $@

$($(python-petsc4py-64)-modulefile): $(modulefilesdir)/.markerfile $($(python-petsc4py-64)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-petsc4py-64)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-petsc4py-64)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-petsc4py-64)-description)\"" >>$@
	echo "module-whatis \"$($(python-petsc4py-64)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-petsc4py-64)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PETSC4PY_ROOT $($(python-petsc4py-64)-prefix)" >>$@
	echo "prepend-path PATH $($(python-petsc4py-64)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-petsc4py-64)-site-packages)" >>$@
	echo "set MSG \"$(python-petsc4py-64)\"" >>$@

$(python-petsc4py-64)-src: $($(python-petsc4py-64)-src)
$(python-petsc4py-64)-unpack: $($(python-petsc4py-64)-prefix)/.pkgunpack
$(python-petsc4py-64)-patch: $($(python-petsc4py-64)-prefix)/.pkgpatch
$(python-petsc4py-64)-build: $($(python-petsc4py-64)-prefix)/.pkgbuild
$(python-petsc4py-64)-check: $($(python-petsc4py-64)-prefix)/.pkgcheck
$(python-petsc4py-64)-install: $($(python-petsc4py-64)-prefix)/.pkginstall
$(python-petsc4py-64)-modulefile: $($(python-petsc4py-64)-modulefile)
$(python-petsc4py-64)-clean:
	rm -rf $($(python-petsc4py-64)-modulefile)
	rm -rf $($(python-petsc4py-64)-prefix)
	rm -rf $($(python-petsc4py-64)-srcdir)
	rm -rf $($(python-petsc4py-64)-src)
$(python-petsc4py-64): $(python-petsc4py-64)-src $(python-petsc4py-64)-unpack $(python-petsc4py-64)-patch $(python-petsc4py-64)-build $(python-petsc4py-64)-check $(python-petsc4py-64)-install $(python-petsc4py-64)-modulefile
