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
# python-ipopt-0.3.0

python-ipopt-version = 0.3.0
python-ipopt = python-ipopt-$(python-ipopt-version)
$(python-ipopt)-description = A Cython wrapper for the IPOPT optimization package
$(python-ipopt)-url = https://pypi.org/project/ipopt/
$(python-ipopt)-srcurl = https://files.pythonhosted.org/packages/13/29/6a8f36efc3e2bd030c7b46ee635550494b93d66fca190636c53394fc1e4c/ipopt-0.3.0.tar.gz
$(python-ipopt)-src = $(pkgsrcdir)/$(notdir $($(python-ipopt)-srcurl))
$(python-ipopt)-srcdir = $(pkgsrcdir)/$(python-ipopt)
$(python-ipopt)-builddeps = $(python) $(python-cython) $(python-numpy) $(python-scipy) $(python-six) $(python-future) $(python-setuptools) $(ipopt)
$(python-ipopt)-prereqs = $(python) $(python-cython) $(python-numpy) $(python-scipy) $(python-six) $(python-future) $(ipopt)
$(python-ipopt)-modulefile = $(modulefilesdir)/$(python-ipopt) $(python-six)
$(python-ipopt)-prefix = $(pkgdir)/$(python-ipopt)
$(python-ipopt)-site-packages = $($(python-ipopt)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-ipopt)-src): $(dir $($(python-ipopt)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-ipopt)-srcurl)

$($(python-ipopt)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ipopt)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ipopt)-prefix)/.pkgunpack: $$($(python-ipopt)-src) $($(python-ipopt)-srcdir)/.markerfile $($(python-ipopt)-prefix)/.markerfile $$(foreach dep,$$($(python-ipopt)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-ipopt)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-ipopt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipopt)-prefix)/.pkgunpack
	@touch $@

$($(python-ipopt)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-ipopt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipopt)-prefix)/.pkgpatch
	cd $($(python-ipopt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ipopt)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-ipopt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipopt)-prefix)/.pkgbuild
	cd $($(python-ipopt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ipopt)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-ipopt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ipopt)-prefix)/.pkgcheck $($(python-ipopt)-site-packages)/.markerfile
	cd $($(python-ipopt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ipopt)-builddeps) && \
		PYTHONPATH=$($(python-ipopt)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-ipopt)-prefix)
	@touch $@

$($(python-ipopt)-modulefile): $(modulefilesdir)/.markerfile $($(python-ipopt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-ipopt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-ipopt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-ipopt)-description)\"" >>$@
	echo "module-whatis \"$($(python-ipopt)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-ipopt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_IPOPT_ROOT $($(python-ipopt)-prefix)" >>$@
	echo "prepend-path PATH $($(python-ipopt)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-ipopt)-site-packages)" >>$@
	echo "set MSG \"$(python-ipopt)\"" >>$@

$(python-ipopt)-src: $($(python-ipopt)-src)
$(python-ipopt)-unpack: $($(python-ipopt)-prefix)/.pkgunpack
$(python-ipopt)-patch: $($(python-ipopt)-prefix)/.pkgpatch
$(python-ipopt)-build: $($(python-ipopt)-prefix)/.pkgbuild
$(python-ipopt)-check: $($(python-ipopt)-prefix)/.pkgcheck
$(python-ipopt)-install: $($(python-ipopt)-prefix)/.pkginstall
$(python-ipopt)-modulefile: $($(python-ipopt)-modulefile)
$(python-ipopt)-clean:
	rm -rf $($(python-ipopt)-modulefile)
	rm -rf $($(python-ipopt)-prefix)
	rm -rf $($(python-ipopt)-srcdir)
	rm -rf $($(python-ipopt)-src)
$(python-ipopt): $(python-ipopt)-src $(python-ipopt)-unpack $(python-ipopt)-patch $(python-ipopt)-build $(python-ipopt)-check $(python-ipopt)-install $(python-ipopt)-modulefile
