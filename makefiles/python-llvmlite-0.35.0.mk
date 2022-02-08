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
# python-llvmlite-0.35.0

python-llvmlite-version = 0.35.0
python-llvmlite = python-llvmlite-$(python-llvmlite-version)
$(python-llvmlite)-description = Lightweight LLVM python binding for writing JIT compilers
$(python-llvmlite)-url = https://github.com/numba/llvmlite
$(python-llvmlite)-srcurl = https://github.com/numba/llvmlite/archive/v$(python-llvmlite-version).tar.gz
$(python-llvmlite)-src = $(pkgsrcdir)/python-llvmlite-$(notdir $($(python-llvmlite)-srcurl))
$(python-llvmlite)-srcdir = $(pkgsrcdir)/$(python-llvmlite)
$(python-llvmlite)-builddeps = $(cmake) $(python) $(llvm-10) $(python-wheel) $(python-pip)
$(python-llvmlite)-prereqs = $(python) $(llvm-10)
$(python-llvmlite)-modulefile = $(modulefilesdir)/$(python-llvmlite)
$(python-llvmlite)-prefix = $(pkgdir)/$(python-llvmlite)
$(python-llvmlite)-site-packages = $($(python-llvmlite)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-llvmlite)-src): $(dir $($(python-llvmlite)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-llvmlite)-srcurl)

$($(python-llvmlite)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-llvmlite)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-llvmlite)-prefix)/.pkgunpack: $$($(python-llvmlite)-src) $($(python-llvmlite)-srcdir)/.markerfile $($(python-llvmlite)-prefix)/.markerfile $$(foreach dep,$$($(python-llvmlite)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-llvmlite)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-llvmlite)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-llvmlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-llvmlite)-prefix)/.pkgunpack
	@touch $@

$($(python-llvmlite)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-llvmlite)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-llvmlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-llvmlite)-prefix)/.pkgpatch
	cd $($(python-llvmlite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-llvmlite)-builddeps) && \
		LLVM_CONFIG=$${LLVM_ROOT}/bin/llvm-config \
		$(PYTHON) setup.py build
	@touch $@

$($(python-llvmlite)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-llvmlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-llvmlite)-prefix)/.pkgbuild
	cd $($(python-llvmlite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-llvmlite)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-llvmlite)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-llvmlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-llvmlite)-prefix)/.pkgcheck $($(python-llvmlite)-site-packages)/.markerfile
	cd $($(python-llvmlite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-llvmlite)-builddeps) && \
		PYTHONPATH=$($(python-llvmlite)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-llvmlite)-prefix)
	@touch $@

$($(python-llvmlite)-modulefile): $(modulefilesdir)/.markerfile $($(python-llvmlite)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-llvmlite)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-llvmlite)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-llvmlite)-description)\"" >>$@
	echo "module-whatis \"$($(python-llvmlite)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-llvmlite)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_LLVMLITE_ROOT $($(python-llvmlite)-prefix)" >>$@
	echo "prepend-path PATH $($(python-llvmlite)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-llvmlite)-site-packages)" >>$@
	echo "set MSG \"$(python-llvmlite)\"" >>$@

$(python-llvmlite)-src: $($(python-llvmlite)-src)
$(python-llvmlite)-unpack: $($(python-llvmlite)-prefix)/.pkgunpack
$(python-llvmlite)-patch: $($(python-llvmlite)-prefix)/.pkgpatch
$(python-llvmlite)-build: $($(python-llvmlite)-prefix)/.pkgbuild
$(python-llvmlite)-check: $($(python-llvmlite)-prefix)/.pkgcheck
$(python-llvmlite)-install: $($(python-llvmlite)-prefix)/.pkginstall
$(python-llvmlite)-modulefile: $($(python-llvmlite)-modulefile)
$(python-llvmlite)-clean:
	rm -rf $($(python-llvmlite)-modulefile)
	rm -rf $($(python-llvmlite)-prefix)
	rm -rf $($(python-llvmlite)-srcdir)
	rm -rf $($(python-llvmlite)-src)
$(python-llvmlite): $(python-llvmlite)-src $(python-llvmlite)-unpack $(python-llvmlite)-patch $(python-llvmlite)-build $(python-llvmlite)-check $(python-llvmlite)-install $(python-llvmlite)-modulefile
