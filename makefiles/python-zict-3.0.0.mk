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
# python-zict-3.0.0

python-zict-version = 3.0.0
python-zict = python-zict-$(python-zict-version)
$(python-zict)-description = Mutable mapping tools
$(python-zict)-url = http://zict.readthedocs.io/en/latest/
$(python-zict)-srcurl = https://files.pythonhosted.org/packages/d1/ac/3c494dd7ec5122cff8252c1a209b282c0867af029f805ae9befd73ae37eb/zict-3.0.0.tar.gz
$(python-zict)-src = $(pkgsrcdir)/$(notdir $($(python-zict)-srcurl))
$(python-zict)-builddeps = $(python) $(python-pip)
$(python-zict)-prereqs = $(python)
$(python-zict)-srcdir = $(pkgsrcdir)/$(python-zict)
$(python-zict)-modulefile = $(modulefilesdir)/$(python-zict)
$(python-zict)-prefix = $(pkgdir)/$(python-zict)

$($(python-zict)-src): $(dir $($(python-zict)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-zict)-srcurl)

$($(python-zict)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-zict)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-zict)-prefix)/.pkgunpack: $$($(python-zict)-src) $($(python-zict)-srcdir)/.markerfile $($(python-zict)-prefix)/.markerfile $$(foreach dep,$$($(python-zict)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-zict)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-zict)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zict)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zict)-prefix)/.pkgunpack
	@touch $@

$($(python-zict)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zict)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zict)-prefix)/.pkgpatch
	@touch $@

$($(python-zict)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zict)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zict)-prefix)/.pkgbuild
	@touch $@

$($(python-zict)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zict)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zict)-prefix)/.pkgcheck
	cd $($(python-zict)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-zict)-builddeps) && \
		PYTHONPATH=$($(python-zict)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-zict)-prefix)
	@touch $@

$($(python-zict)-modulefile): $(modulefilesdir)/.markerfile $($(python-zict)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-zict)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-zict)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-zict)-description)\"" >>$@
	echo "module-whatis \"$($(python-zict)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-zict)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ZICT_ROOT $($(python-zict)-prefix)" >>$@
	echo "prepend-path PATH $($(python-zict)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-zict)-prefix)" >>$@
	echo "set MSG \"$(python-zict)\"" >>$@

$(python-zict)-src: $($(python-zict)-src)
$(python-zict)-unpack: $($(python-zict)-prefix)/.pkgunpack
$(python-zict)-patch: $($(python-zict)-prefix)/.pkgpatch
$(python-zict)-build: $($(python-zict)-prefix)/.pkgbuild
$(python-zict)-check: $($(python-zict)-prefix)/.pkgcheck
$(python-zict)-install: $($(python-zict)-prefix)/.pkginstall
$(python-zict)-modulefile: $($(python-zict)-modulefile)
$(python-zict)-clean:
	rm -rf $($(python-zict)-modulefile)
	rm -rf $($(python-zict)-prefix)
	rm -rf $($(python-zict)-srcdir)
	rm -rf $($(python-zict)-src)
$(python-zict): $(python-zict)-src $(python-zict)-unpack $(python-zict)-patch $(python-zict)-build $(python-zict)-check $(python-zict)-install $(python-zict)-modulefile
