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
# python-petsc4py-3.13.0

python-petsc4py-version = 3.13.0
python-petsc4py = python-petsc4py-$(python-petsc4py-version)
$(python-petsc4py)-description = Python bindings for PETSc
$(python-petsc4py)-url = https://bitbucket.org/petsc/petsc4py/
$(python-petsc4py)-srcurl = https://files.pythonhosted.org/packages/7c/e7/5b089013c5188ee5f619ad64749fc3e6355943950dfcf421c327d66ee2ac/petsc4py-3.13.0.tar.gz
$(python-petsc4py)-src = $(pkgsrcdir)/$(notdir $($(python-petsc4py)-srcurl))
$(python-petsc4py)-srcdir = $(pkgsrcdir)/$(python-petsc4py)
$(python-petsc4py)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpi4py) $(petsc)
$(python-petsc4py)-prereqs = $(python) $(python-numpy) $(python-mpi4py) $(petsc)
$(python-petsc4py)-modulefile = $(modulefilesdir)/$(python-petsc4py)
$(python-petsc4py)-prefix = $(pkgdir)/$(python-petsc4py)
$(python-petsc4py)-site-packages = $($(python-petsc4py)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-petsc4py)-src): $(dir $($(python-petsc4py)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-petsc4py)-srcurl)

$($(python-petsc4py)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-petsc4py)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-petsc4py)-prefix)/.pkgunpack: $$($(python-petsc4py)-src) $($(python-petsc4py)-srcdir)/.markerfile $($(python-petsc4py)-prefix)/.markerfile
	tar -C $($(python-petsc4py)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-petsc4py)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py)-prefix)/.pkgunpack
	@touch $@

$($(python-petsc4py)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-petsc4py)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py)-prefix)/.pkgpatch
	cd $($(python-petsc4py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-petsc4py)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-petsc4py)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py)-prefix)/.pkgbuild
# 	cd $($(python-petsc4py)-srcdir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(python-petsc4py)-builddeps) && \
# 		python3 setup.py test
	@touch $@

$($(python-petsc4py)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-petsc4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-petsc4py)-prefix)/.pkgcheck $($(python-petsc4py)-site-packages)/.markerfile
	cd $($(python-petsc4py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-petsc4py)-builddeps) && \
		PYTHONPATH=$($(python-petsc4py)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-petsc4py)-prefix)
	@touch $@

$($(python-petsc4py)-modulefile): $(modulefilesdir)/.markerfile $($(python-petsc4py)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-petsc4py)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-petsc4py)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-petsc4py)-description)\"" >>$@
	echo "module-whatis \"$($(python-petsc4py)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-petsc4py)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PETSC4PY_ROOT $($(python-petsc4py)-prefix)" >>$@
	echo "prepend-path PATH $($(python-petsc4py)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-petsc4py)-site-packages)" >>$@
	echo "set MSG \"$(python-petsc4py)\"" >>$@

$(python-petsc4py)-src: $($(python-petsc4py)-src)
$(python-petsc4py)-unpack: $($(python-petsc4py)-prefix)/.pkgunpack
$(python-petsc4py)-patch: $($(python-petsc4py)-prefix)/.pkgpatch
$(python-petsc4py)-build: $($(python-petsc4py)-prefix)/.pkgbuild
$(python-petsc4py)-check: $($(python-petsc4py)-prefix)/.pkgcheck
$(python-petsc4py)-install: $($(python-petsc4py)-prefix)/.pkginstall
$(python-petsc4py)-modulefile: $($(python-petsc4py)-modulefile)
$(python-petsc4py)-clean:
	rm -rf $($(python-petsc4py)-modulefile)
	rm -rf $($(python-petsc4py)-prefix)
	rm -rf $($(python-petsc4py)-srcdir)
	rm -rf $($(python-petsc4py)-src)
$(python-petsc4py): $(python-petsc4py)-src $(python-petsc4py)-unpack $(python-petsc4py)-patch $(python-petsc4py)-build $(python-petsc4py)-check $(python-petsc4py)-install $(python-petsc4py)-modulefile
