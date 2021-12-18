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
# python-ldrb-2021.0.2

python-ldrb-version = 2021.0.2
python-ldrb = python-ldrb-$(python-ldrb-version)
$(python-ldrb)-description = Laplace-Dirichlet Rule-Based (LDRB) algorithm for assigning myocardial fiber orientations
$(python-ldrb)-url = https://github.com/finsberg/ldrb/
$(python-ldrb)-srcurl = https://github.com/finsberg/ldrb/archive/refs/tags/v$(python-ldrb-version).tar.gz
$(python-ldrb)-src = $(pkgsrcdir)/python-ldrb-$(notdir $($(python-ldrb)-srcurl))
$(python-ldrb)-srcdir = $(pkgsrcdir)/$(python-ldrb)
$(python-ldrb)-builddeps = $(python) $(python-fenics-dolfin-2019) $(python-fenics-mshr-2019) $(python-numpy) $(python-numpy-quaternion) $(python-scipy) $(python-numba) $(python-h5py) $(python-pytest) $(python-pytest-cov)
$(python-ldrb)-prereqs = $(python) $(python-fenics-dolfin-2019) $(python-fenics-mshr-2019) $(python-numpy) $(python-numpy-quaternion) $(python-scipy) $(python-numba) $(python-h5py)
$(python-ldrb)-modulefile = $(modulefilesdir)/$(python-ldrb)
$(python-ldrb)-prefix = $(pkgdir)/$(python-ldrb)
$(python-ldrb)-site-packages = $($(python-ldrb)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-ldrb)-src): $(dir $($(python-ldrb)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-ldrb)-srcurl)

$($(python-ldrb)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ldrb)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ldrb)-prefix)/.pkgunpack: $$($(python-ldrb)-src) $($(python-ldrb)-srcdir)/.markerfile $($(python-ldrb)-prefix)/.markerfile $$(foreach dep,$$($(python-ldrb)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-ldrb)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-ldrb)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ldrb)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ldrb)-prefix)/.pkgunpack
	@touch $@

$($(python-ldrb)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-ldrb)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ldrb)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ldrb)-prefix)/.pkgpatch
	cd $($(python-ldrb)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ldrb)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-ldrb)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ldrb)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ldrb)-prefix)/.pkgbuild
#	 cd $($(python-ldrb)-srcdir) && \
#	 	$(MODULESINIT) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(python-ldrb)-builddeps) && \
#	 	$(MAKE) test
	@touch $@

$($(python-ldrb)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ldrb)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ldrb)-prefix)/.pkgcheck $($(python-ldrb)-site-packages)/.markerfile
	cd $($(python-ldrb)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ldrb)-builddeps) && \
		PYTHONPATH=$($(python-ldrb)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-ldrb)-prefix)
	@touch $@

$($(python-ldrb)-modulefile): $(modulefilesdir)/.markerfile $($(python-ldrb)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-ldrb)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-ldrb)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-ldrb)-description)\"" >>$@
	echo "module-whatis \"$($(python-ldrb)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-ldrb)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_LDRB_ROOT $($(python-ldrb)-prefix)" >>$@
	echo "prepend-path PATH $($(python-ldrb)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-ldrb)-site-packages)" >>$@
	echo "set MSG \"$(python-ldrb)\"" >>$@

$(python-ldrb)-src: $($(python-ldrb)-src)
$(python-ldrb)-unpack: $($(python-ldrb)-prefix)/.pkgunpack
$(python-ldrb)-patch: $($(python-ldrb)-prefix)/.pkgpatch
$(python-ldrb)-build: $($(python-ldrb)-prefix)/.pkgbuild
$(python-ldrb)-check: $($(python-ldrb)-prefix)/.pkgcheck
$(python-ldrb)-install: $($(python-ldrb)-prefix)/.pkginstall
$(python-ldrb)-modulefile: $($(python-ldrb)-modulefile)
$(python-ldrb)-clean:
	rm -rf $($(python-ldrb)-modulefile)
	rm -rf $($(python-ldrb)-prefix)
	rm -rf $($(python-ldrb)-srcdir)
	rm -rf $($(python-ldrb)-src)
$(python-ldrb): $(python-ldrb)-src $(python-ldrb)-unpack $(python-ldrb)-patch $(python-ldrb)-build $(python-ldrb)-check $(python-ldrb)-install $(python-ldrb)-modulefile
