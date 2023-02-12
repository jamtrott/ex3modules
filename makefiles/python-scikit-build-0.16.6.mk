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
# python-scikit-build-0.16.6

python-scikit-build-version = 0.16.6
python-scikit-build = python-scikit-build-$(python-scikit-build-version)
$(python-scikit-build)-description = Improved build system generator for Python C/C++/Fortran/Cython extensions
$(python-scikit-build)-url = https://github.com/scikit-build/scikit-build
$(python-scikit-build)-srcurl = https://files.pythonhosted.org/packages/00/91/2c7cd1a6b567e8e40c1677c61aba39e5f14ccf06ac78ae4fa6acb84ae140/scikit-build-0.16.6.tar.gz
$(python-scikit-build)-src = $(pkgsrcdir)/$(notdir $($(python-scikit-build)-srcurl))
$(python-scikit-build)-builddeps = $(python) $(python-pip) $(python-setuptools_scm)
$(python-scikit-build)-prereqs = $(python)
$(python-scikit-build)-srcdir = $(pkgsrcdir)/$(python-scikit-build)
$(python-scikit-build)-modulefile = $(modulefilesdir)/$(python-scikit-build)
$(python-scikit-build)-prefix = $(pkgdir)/$(python-scikit-build)
$(python-scikit-build)-site-packages = $($(python-scikit-build)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-scikit-build)-src): $(dir $($(python-scikit-build)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-scikit-build)-srcurl)

$($(python-scikit-build)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-scikit-build)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-scikit-build)-prefix)/.pkgunpack: $$($(python-scikit-build)-src) $($(python-scikit-build)-srcdir)/.markerfile $($(python-scikit-build)-prefix)/.markerfile $$(foreach dep,$$($(python-scikit-build)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-scikit-build)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-scikit-build)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scikit-build)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scikit-build)-prefix)/.pkgunpack
	@touch $@

$($(python-scikit-build)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-scikit-build)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scikit-build)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scikit-build)-prefix)/.pkgpatch
	cd $($(python-scikit-build)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-scikit-build)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-scikit-build)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scikit-build)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scikit-build)-prefix)/.pkgbuild
	# cd $($(python-scikit-build)-srcdir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-scikit-build)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-scikit-build)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scikit-build)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scikit-build)-prefix)/.pkgcheck $($(python-scikit-build)-site-packages)/.markerfile
	cd $($(python-scikit-build)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-scikit-build)-builddeps) && \
		PYTHONPATH=$($(python-scikit-build)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-scikit-build)-prefix)
	@touch $@

$($(python-scikit-build)-modulefile): $(modulefilesdir)/.markerfile $($(python-scikit-build)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-scikit-build)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-scikit-build)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-scikit-build)-description)\"" >>$@
	echo "module-whatis \"$($(python-scikit-build)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-scikit-build)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_EXAMPLE_ROOT $($(python-scikit-build)-prefix)" >>$@
	echo "prepend-path PATH $($(python-scikit-build)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-scikit-build)-site-packages)" >>$@
	echo "set MSG \"$(python-scikit-build)\"" >>$@

$(python-scikit-build)-src: $($(python-scikit-build)-src)
$(python-scikit-build)-unpack: $($(python-scikit-build)-prefix)/.pkgunpack
$(python-scikit-build)-patch: $($(python-scikit-build)-prefix)/.pkgpatch
$(python-scikit-build)-build: $($(python-scikit-build)-prefix)/.pkgbuild
$(python-scikit-build)-check: $($(python-scikit-build)-prefix)/.pkgcheck
$(python-scikit-build)-install: $($(python-scikit-build)-prefix)/.pkginstall
$(python-scikit-build)-modulefile: $($(python-scikit-build)-modulefile)
$(python-scikit-build)-clean:
	rm -rf $($(python-scikit-build)-modulefile)
	rm -rf $($(python-scikit-build)-prefix)
	rm -rf $($(python-scikit-build)-srcdir)
	rm -rf $($(python-scikit-build)-src)
$(python-scikit-build): $(python-scikit-build)-src $(python-scikit-build)-unpack $(python-scikit-build)-patch $(python-scikit-build)-build $(python-scikit-build)-check $(python-scikit-build)-install $(python-scikit-build)-modulefile
