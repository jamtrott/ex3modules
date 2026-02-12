# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# python-locket-1.0.0

python-locket-version = 1.0.0
python-locket = python-locket-$(python-locket-version)
$(python-locket)-description = File-based locks for Python on Linux and Windows
$(python-locket)-url = http://github.com/mwilliamson/locket.py
$(python-locket)-srcurl = https://files.pythonhosted.org/packages/2f/83/97b29fe05cb6ae28d2dbd30b81e2e402a3eed5f460c26e9eaa5895ceacf5/locket-1.0.0.tar.gz
$(python-locket)-src = $(pkgsrcdir)/$(notdir $($(python-locket)-srcurl))
$(python-locket)-builddeps = $(python) $(python-pip)
$(python-locket)-prereqs = $(python)
$(python-locket)-srcdir = $(pkgsrcdir)/$(python-locket)
$(python-locket)-modulefile = $(modulefilesdir)/$(python-locket)
$(python-locket)-prefix = $(pkgdir)/$(python-locket)

$($(python-locket)-src): $(dir $($(python-locket)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-locket)-srcurl)

$($(python-locket)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-locket)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-locket)-prefix)/.pkgunpack: $$($(python-locket)-src) $($(python-locket)-srcdir)/.markerfile $($(python-locket)-prefix)/.markerfile $$(foreach dep,$$($(python-locket)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-locket)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-locket)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-locket)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-locket)-prefix)/.pkgunpack
	@touch $@

$($(python-locket)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-locket)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-locket)-prefix)/.pkgpatch
	@touch $@

$($(python-locket)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-locket)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-locket)-prefix)/.pkgbuild
	@touch $@

$($(python-locket)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-locket)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-locket)-prefix)/.pkgcheck
	cd $($(python-locket)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-locket)-builddeps) && \
		PYTHONPATH=$($(python-locket)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-locket)-prefix)
	@touch $@

$($(python-locket)-modulefile): $(modulefilesdir)/.markerfile $($(python-locket)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-locket)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-locket)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-locket)-description)\"" >>$@
	echo "module-whatis \"$($(python-locket)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-locket)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_LOCKET_ROOT $($(python-locket)-prefix)" >>$@
	echo "prepend-path PATH $($(python-locket)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-locket)-prefix)" >>$@
	echo "set MSG \"$(python-locket)\"" >>$@

$(python-locket)-src: $($(python-locket)-src)
$(python-locket)-unpack: $($(python-locket)-prefix)/.pkgunpack
$(python-locket)-patch: $($(python-locket)-prefix)/.pkgpatch
$(python-locket)-build: $($(python-locket)-prefix)/.pkgbuild
$(python-locket)-check: $($(python-locket)-prefix)/.pkgcheck
$(python-locket)-install: $($(python-locket)-prefix)/.pkginstall
$(python-locket)-modulefile: $($(python-locket)-modulefile)
$(python-locket)-clean:
	rm -rf $($(python-locket)-modulefile)
	rm -rf $($(python-locket)-prefix)
	rm -rf $($(python-locket)-srcdir)
	rm -rf $($(python-locket)-src)
$(python-locket): $(python-locket)-src $(python-locket)-unpack $(python-locket)-patch $(python-locket)-build $(python-locket)-check $(python-locket)-install $(python-locket)-modulefile
