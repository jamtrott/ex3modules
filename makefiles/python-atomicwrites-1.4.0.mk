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
# python-atomicwrites-1.4.0

python-atomicwrites-version = 1.4.0
python-atomicwrites = python-atomicwrites-$(python-atomicwrites-version)
$(python-atomicwrites)-description = Atomic file writes
$(python-atomicwrites)-url = https://github.com/untitaker/python-atomicwrites
$(python-atomicwrites)-srcurl = https://files.pythonhosted.org/packages/55/8d/74a75635f2c3c914ab5b3850112fd4b0c8039975ecb320e4449aa363ba54/atomicwrites-1.4.0.tar.gz
$(python-atomicwrites)-src = $(pkgsrcdir)/$(notdir $($(python-atomicwrites)-srcurl))
$(python-atomicwrites)-srcdir = $(pkgsrcdir)/$(python-atomicwrites)
$(python-atomicwrites)-builddeps = $(python) $(python-wheel) $(python-pip)
$(python-atomicwrites)-prereqs = $(python)
$(python-atomicwrites)-modulefile = $(modulefilesdir)/$(python-atomicwrites)
$(python-atomicwrites)-prefix = $(pkgdir)/$(python-atomicwrites)
$(python-atomicwrites)-site-packages = $($(python-atomicwrites)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-atomicwrites)-src): $(dir $($(python-atomicwrites)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-atomicwrites)-srcurl)

$($(python-atomicwrites)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-atomicwrites)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-atomicwrites)-prefix)/.pkgunpack: $$($(python-atomicwrites)-src) $($(python-atomicwrites)-srcdir)/.markerfile $($(python-atomicwrites)-prefix)/.markerfile $$(foreach dep,$$($(python-atomicwrites)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-atomicwrites)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-atomicwrites)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-atomicwrites)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-atomicwrites)-prefix)/.pkgunpack
	@touch $@

$($(python-atomicwrites)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-atomicwrites)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-atomicwrites)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-atomicwrites)-prefix)/.pkgpatch
	cd $($(python-atomicwrites)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-atomicwrites)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-atomicwrites)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-atomicwrites)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-atomicwrites)-prefix)/.pkgbuild
	@touch $@

$($(python-atomicwrites)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-atomicwrites)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-atomicwrites)-prefix)/.pkgcheck $($(python-atomicwrites)-site-packages)/.markerfile
	cd $($(python-atomicwrites)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-atomicwrites)-builddeps) && \
		PYTHONPATH=$($(python-atomicwrites)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-atomicwrites)-prefix)
	@touch $@

$($(python-atomicwrites)-modulefile): $(modulefilesdir)/.markerfile $($(python-atomicwrites)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-atomicwrites)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-atomicwrites)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-atomicwrites)-description)\"" >>$@
	echo "module-whatis \"$($(python-atomicwrites)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-atomicwrites)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ATOMICWRITES_ROOT $($(python-atomicwrites)-prefix)" >>$@
	echo "prepend-path PATH $($(python-atomicwrites)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-atomicwrites)-site-packages)" >>$@
	echo "set MSG \"$(python-atomicwrites)\"" >>$@

$(python-atomicwrites)-src: $($(python-atomicwrites)-src)
$(python-atomicwrites)-unpack: $($(python-atomicwrites)-prefix)/.pkgunpack
$(python-atomicwrites)-patch: $($(python-atomicwrites)-prefix)/.pkgpatch
$(python-atomicwrites)-build: $($(python-atomicwrites)-prefix)/.pkgbuild
$(python-atomicwrites)-check: $($(python-atomicwrites)-prefix)/.pkgcheck
$(python-atomicwrites)-install: $($(python-atomicwrites)-prefix)/.pkginstall
$(python-atomicwrites)-modulefile: $($(python-atomicwrites)-modulefile)
$(python-atomicwrites)-clean:
	rm -rf $($(python-atomicwrites)-modulefile)
	rm -rf $($(python-atomicwrites)-prefix)
	rm -rf $($(python-atomicwrites)-srcdir)
	rm -rf $($(python-atomicwrites)-src)
$(python-atomicwrites): $(python-atomicwrites)-src $(python-atomicwrites)-unpack $(python-atomicwrites)-patch $(python-atomicwrites)-build $(python-atomicwrites)-check $(python-atomicwrites)-install $(python-atomicwrites)-modulefile
