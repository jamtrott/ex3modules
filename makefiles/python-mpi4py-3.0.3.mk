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
# python-mpi4py-3.0.3

python-mpi4py-version = 3.0.3
python-mpi4py = python-mpi4py-$(python-mpi4py-version)
$(python-mpi4py)-description = Python bindings for the Message Passing Interface (MPI)
$(python-mpi4py)-url = https://mpi4py.readthedocs.io/
$(python-mpi4py)-srcurl = https://files.pythonhosted.org/packages/ec/8f/bbd8de5ba566dd77e408d8136e2bab7fdf2b97ce06cab830ba8b50a2f588/mpi4py-3.0.3.tar.gz
$(python-mpi4py)-src = $(pkgsrcdir)/$(notdir $($(python-mpi4py)-srcurl))
$(python-mpi4py)-srcdir = $(pkgsrcdir)/$(python-mpi4py)
$(python-mpi4py)-builddeps = $(python) $(mpi)
$(python-mpi4py)-prereqs = $(python) $(mpi)
$(python-mpi4py)-modulefile = $(modulefilesdir)/$(python-mpi4py)
$(python-mpi4py)-prefix = $(pkgdir)/$(python-mpi4py)
$(python-mpi4py)-site-packages = $($(python-mpi4py)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-mpi4py)-src): $(dir $($(python-mpi4py)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-mpi4py)-srcurl)

$($(python-mpi4py)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mpi4py)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mpi4py)-prefix)/.pkgunpack: $$($(python-mpi4py)-src) $($(python-mpi4py)-srcdir)/.markerfile $($(python-mpi4py)-prefix)/.markerfile $$(foreach dep,$$($(python-mpi4py)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-mpi4py)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-mpi4py)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpi4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpi4py)-prefix)/.pkgunpack
	@touch $@

$($(python-mpi4py)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-mpi4py)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpi4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpi4py)-prefix)/.pkgpatch
	cd $($(python-mpi4py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mpi4py)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-mpi4py)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpi4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpi4py)-prefix)/.pkgbuild
# 	Tests currently fail due to this issue: https://github.com/openucx/ucx/issues/4130
# 	cd $($(python-mpi4py)-srcdir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(python-mpi4py)-builddeps) && \
# 		$(PYTHON) setup.py test
	@touch $@

$($(python-mpi4py)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpi4py)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpi4py)-prefix)/.pkgcheck $($(python-mpi4py)-site-packages)/.markerfile
	cd $($(python-mpi4py)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mpi4py)-builddeps) && \
		PYTHONPATH=$($(python-mpi4py)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(python-mpi4py)-prefix)
	@touch $@

$($(python-mpi4py)-modulefile): $(modulefilesdir)/.markerfile $($(python-mpi4py)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-mpi4py)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-mpi4py)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-mpi4py)-description)\"" >>$@
	echo "module-whatis \"$($(python-mpi4py)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-mpi4py)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MPI4PY_ROOT $($(python-mpi4py)-prefix)" >>$@
	echo "prepend-path PATH $($(python-mpi4py)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-mpi4py)-site-packages)" >>$@
	echo "set MSG \"$(python-mpi4py)\"" >>$@

$(python-mpi4py)-src: $($(python-mpi4py)-src)
$(python-mpi4py)-unpack: $($(python-mpi4py)-prefix)/.pkgunpack
$(python-mpi4py)-patch: $($(python-mpi4py)-prefix)/.pkgpatch
$(python-mpi4py)-build: $($(python-mpi4py)-prefix)/.pkgbuild
$(python-mpi4py)-check: $($(python-mpi4py)-prefix)/.pkgcheck
$(python-mpi4py)-install: $($(python-mpi4py)-prefix)/.pkginstall
$(python-mpi4py)-modulefile: $($(python-mpi4py)-modulefile)
$(python-mpi4py)-clean:
	rm -rf $($(python-mpi4py)-modulefile)
	rm -rf $($(python-mpi4py)-prefix)
	rm -rf $($(python-mpi4py)-srcdir)
	rm -rf $($(python-mpi4py)-src)
$(python-mpi4py): $(python-mpi4py)-src $(python-mpi4py)-unpack $(python-mpi4py)-patch $(python-mpi4py)-build $(python-mpi4py)-check $(python-mpi4py)-install $(python-mpi4py)-modulefile
