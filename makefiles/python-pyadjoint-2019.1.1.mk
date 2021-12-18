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
# python-pyadjoint-2019.1.1

python-pyadjoint-version = 2019.1.1
python-pyadjoint = python-pyadjoint-$(python-pyadjoint-version)
$(python-pyadjoint)-description = Algorithmic differentiation framework for FEniCS and Firedrake
$(python-pyadjoint)-url = http://www.dolfin-adjoint.org/
$(python-pyadjoint)-srcurl = https://github.com/dolfin-adjoint/pyadjoint/archive/refs/tags/$(python-pyadjoint-version).tar.gz
$(python-pyadjoint)-src = $(pkgsrcdir)/$(notdir $($(python-pyadjoint)-srcurl))
$(python-pyadjoint)-srcdir = $(pkgsrcdir)/$(python-pyadjoint)
$(python-pyadjoint)-builddeps = $(python) $(python-ipopt) $(ipopt) $(python-fenics-dolfin-2019)
$(python-pyadjoint)-prereqs = $(python) $(python-ipopt) $(ipopt) $(python-fenics-dolfin-2019)
$(python-pyadjoint)-modulefile = $(modulefilesdir)/$(python-pyadjoint)
$(python-pyadjoint)-prefix = $(pkgdir)/$(python-pyadjoint)
$(python-pyadjoint)-site-packages = $($(python-pyadjoint)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pyadjoint)-src): $(dir $($(python-pyadjoint)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pyadjoint)-srcurl)

$($(python-pyadjoint)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyadjoint)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyadjoint)-prefix)/.pkgunpack: $$($(python-pyadjoint)-src) $($(python-pyadjoint)-srcdir)/.markerfile $($(python-pyadjoint)-prefix)/.markerfile $$(foreach dep,$$($(python-pyadjoint)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pyadjoint)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pyadjoint)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyadjoint)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyadjoint)-prefix)/.pkgunpack
	@touch $@

$($(python-pyadjoint)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pyadjoint)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyadjoint)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyadjoint)-prefix)/.pkgpatch
	cd $($(python-pyadjoint)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyadjoint)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pyadjoint)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyadjoint)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyadjoint)-prefix)/.pkgbuild
#	 cd $($(python-pyadjoint)-srcdir) && \
#	 	$(MODULESINIT) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(python-pyadjoint)-builddeps) && \
#	 	$(PYTHON) setup.py test
	@touch $@

$($(python-pyadjoint)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyadjoint)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyadjoint)-prefix)/.pkgcheck $($(python-pyadjoint)-site-packages)/.markerfile
	cd $($(python-pyadjoint)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyadjoint)-builddeps) && \
		PYTHONPATH=$($(python-pyadjoint)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-pyadjoint)-prefix)
	@touch $@

$($(python-pyadjoint)-modulefile): $(modulefilesdir)/.markerfile $($(python-pyadjoint)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pyadjoint)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pyadjoint)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pyadjoint)-description)\"" >>$@
	echo "module-whatis \"$($(python-pyadjoint)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pyadjoint)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYADJOINT_ROOT $($(python-pyadjoint)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pyadjoint)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pyadjoint)-site-packages)" >>$@
	echo "set MSG \"$(python-pyadjoint)\"" >>$@

$(python-pyadjoint)-src: $($(python-pyadjoint)-src)
$(python-pyadjoint)-unpack: $($(python-pyadjoint)-prefix)/.pkgunpack
$(python-pyadjoint)-patch: $($(python-pyadjoint)-prefix)/.pkgpatch
$(python-pyadjoint)-build: $($(python-pyadjoint)-prefix)/.pkgbuild
$(python-pyadjoint)-check: $($(python-pyadjoint)-prefix)/.pkgcheck
$(python-pyadjoint)-install: $($(python-pyadjoint)-prefix)/.pkginstall
$(python-pyadjoint)-modulefile: $($(python-pyadjoint)-modulefile)
$(python-pyadjoint)-clean:
	rm -rf $($(python-pyadjoint)-modulefile)
	rm -rf $($(python-pyadjoint)-prefix)
	rm -rf $($(python-pyadjoint)-srcdir)
	rm -rf $($(python-pyadjoint)-src)
$(python-pyadjoint): $(python-pyadjoint)-src $(python-pyadjoint)-unpack $(python-pyadjoint)-patch $(python-pyadjoint)-build $(python-pyadjoint)-check $(python-pyadjoint)-install $(python-pyadjoint)-modulefile
