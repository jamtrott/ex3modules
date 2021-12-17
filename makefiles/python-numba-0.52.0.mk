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
# python-numba-0.52.0

python-numba-version = 0.52.0
python-numba = python-numba-$(python-numba-version)
$(python-numba)-description = JIT compiler for Python and NumPy code
$(python-numba)-url = https://numba.pydata.org/
$(python-numba)-srcurl = https://github.com/numba/numba/archive/$(python-numba-version).tar.gz
$(python-numba)-src = $(pkgsrcdir)/python-numba-$(notdir $($(python-numba)-srcurl))
$(python-numba)-srcdir = $(pkgsrcdir)/$(python-numba)
$(python-numba)-builddeps = $(python) $(python-numpy) $(python-llvmlite)
$(python-numba)-prereqs = $(python) $(python-numpy) $(python-llvmlite)
$(python-numba)-modulefile = $(modulefilesdir)/$(python-numba)
$(python-numba)-prefix = $(pkgdir)/$(python-numba)
$(python-numba)-site-packages = $($(python-numba)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-numba)-src): $(dir $($(python-numba)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-numba)-srcurl)

$($(python-numba)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-numba)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-numba)-prefix)/.pkgunpack: $$($(python-numba)-src) $($(python-numba)-srcdir)/.markerfile $($(python-numba)-prefix)/.markerfile $$(foreach dep,$$($(python-numba)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-numba)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-numba)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numba)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numba)-prefix)/.pkgunpack
	@touch $@

$($(python-numba)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-numba)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numba)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numba)-prefix)/.pkgpatch
	cd $($(python-numba)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numba)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-numba)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numba)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numba)-prefix)/.pkgbuild
	@touch $@

$($(python-numba)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numba)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numba)-prefix)/.pkgcheck $($(python-numba)-site-packages)/.markerfile
	cd $($(python-numba)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numba)-builddeps) && \
		PYTHONPATH=$($(python-numba)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-numba)-prefix)
	@touch $@

$($(python-numba)-modulefile): $(modulefilesdir)/.markerfile $($(python-numba)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-numba)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-numba)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-numba)-description)\"" >>$@
	echo "module-whatis \"$($(python-numba)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-numba)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_NUMBA_ROOT $($(python-numba)-prefix)" >>$@
	echo "prepend-path PATH $($(python-numba)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-numba)-site-packages)" >>$@
	echo "set MSG \"$(python-numba)\"" >>$@

$(python-numba)-src: $($(python-numba)-src)
$(python-numba)-unpack: $($(python-numba)-prefix)/.pkgunpack
$(python-numba)-patch: $($(python-numba)-prefix)/.pkgpatch
$(python-numba)-build: $($(python-numba)-prefix)/.pkgbuild
$(python-numba)-check: $($(python-numba)-prefix)/.pkgcheck
$(python-numba)-install: $($(python-numba)-prefix)/.pkginstall
$(python-numba)-modulefile: $($(python-numba)-modulefile)
$(python-numba)-clean:
	rm -rf $($(python-numba)-modulefile)
	rm -rf $($(python-numba)-prefix)
	rm -rf $($(python-numba)-srcdir)
	rm -rf $($(python-numba)-src)
$(python-numba): $(python-numba)-src $(python-numba)-unpack $(python-numba)-patch $(python-numba)-build $(python-numba)-check $(python-numba)-install $(python-numba)-modulefile
