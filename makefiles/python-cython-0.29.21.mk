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
# python-cython-0.29.21

python-cython-version = 0.29.21
python-cython = python-cython-$(python-cython-version)
$(python-cython)-description = Optimising static compiler for Python
$(python-cython)-url = https://www.cython.org/
$(python-cython)-srcurl = https://files.pythonhosted.org/packages/6c/9f/f501ba9d178aeb1f5bf7da1ad5619b207c90ac235d9859961c11829d0160/Cython-0.29.21.tar.gz
$(python-cython)-src = $(pkgsrcdir)/$(notdir $($(python-cython)-srcurl))
$(python-cython)-srcdir = $(pkgsrcdir)/$(python-cython)
$(python-cython)-builddeps = $(python) $(python-pip)
$(python-cython)-prereqs = $(python)
$(python-cython)-modulefile = $(modulefilesdir)/$(python-cython)
$(python-cython)-prefix = $(pkgdir)/$(python-cython)
$(python-cython)-site-packages = $($(python-cython)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-cython)-src): $(dir $($(python-cython)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-cython)-srcurl)

$($(python-cython)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cython)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cython)-prefix)/.pkgunpack: $$($(python-cython)-src) $($(python-cython)-srcdir)/.markerfile $($(python-cython)-prefix)/.markerfile $$(foreach dep,$$($(python-cython)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-cython)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-cython)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cython)-prefix)/.pkgunpack
	@touch $@

$($(python-cython)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-cython)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cython)-prefix)/.pkgpatch
	cd $($(python-cython)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cython)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-cython)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cython)-prefix)/.pkgbuild
	@touch $@

$($(python-cython)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cython)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cython)-prefix)/.pkgcheck $($(python-cython)-site-packages)/.markerfile
	cd $($(python-cython)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cython)-builddeps) && \
		PYTHONPATH=$($(python-cython)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-cython)-prefix)
	@touch $@

$($(python-cython)-modulefile): $(modulefilesdir)/.markerfile $($(python-cython)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-cython)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-cython)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-cython)-description)\"" >>$@
	echo "module-whatis \"$($(python-cython)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-cython)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CYTHON_ROOT $($(python-cython)-prefix)" >>$@
	echo "prepend-path PATH $($(python-cython)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-cython)-site-packages)" >>$@
	echo "set MSG \"$(python-cython)\"" >>$@

$(python-cython)-src: $($(python-cython)-src)
$(python-cython)-unpack: $($(python-cython)-prefix)/.pkgunpack
$(python-cython)-patch: $($(python-cython)-prefix)/.pkgpatch
$(python-cython)-build: $($(python-cython)-prefix)/.pkgbuild
$(python-cython)-check: $($(python-cython)-prefix)/.pkgcheck
$(python-cython)-install: $($(python-cython)-prefix)/.pkginstall
$(python-cython)-modulefile: $($(python-cython)-modulefile)
$(python-cython)-clean:
	rm -rf $($(python-cython)-modulefile)
	rm -rf $($(python-cython)-prefix)
	rm -rf $($(python-cython)-srcdir)
	rm -rf $($(python-cython)-src)
$(python-cython): $(python-cython)-src $(python-cython)-unpack $(python-cython)-patch $(python-cython)-build $(python-cython)-check $(python-cython)-install $(python-cython)-modulefile
