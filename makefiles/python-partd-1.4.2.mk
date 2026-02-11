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
# python-partd-1.4.2

python-partd-version = 1.4.2
python-partd = python-partd-$(python-partd-version)
$(python-partd)-description = Appendable key-value storage
$(python-partd)-url = http://github.com/dask/partd/
$(python-partd)-srcurl = https://files.pythonhosted.org/packages/b2/3a/3f06f34820a31257ddcabdfafc2672c5816be79c7e353b02c1f318daa7d4/partd-1.4.2.tar.gz
$(python-partd)-src = $(pkgsrcdir)/$(notdir $($(python-partd)-srcurl))
$(python-partd)-builddeps = $(python) $(python-pip)
$(python-partd)-prereqs = $(python)
$(python-partd)-srcdir = $(pkgsrcdir)/$(python-partd)
$(python-partd)-modulefile = $(modulefilesdir)/$(python-partd)
$(python-partd)-prefix = $(pkgdir)/$(python-partd)

$($(python-partd)-src): $(dir $($(python-partd)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-partd)-srcurl)

$($(python-partd)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-partd)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-partd)-prefix)/.pkgunpack: $$($(python-partd)-src) $($(python-partd)-srcdir)/.markerfile $($(python-partd)-prefix)/.markerfile $$(foreach dep,$$($(python-partd)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-partd)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-partd)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-partd)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-partd)-prefix)/.pkgunpack
	@touch $@

$($(python-partd)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-partd)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-partd)-prefix)/.pkgpatch
	@touch $@

$($(python-partd)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-partd)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-partd)-prefix)/.pkgbuild
	@touch $@

$($(python-partd)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-partd)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-partd)-prefix)/.pkgcheck
	cd $($(python-partd)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-partd)-builddeps) && \
		PYTHONPATH=$($(python-partd)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-partd)-prefix)
	@touch $@

$($(python-partd)-modulefile): $(modulefilesdir)/.markerfile $($(python-partd)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-partd)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-partd)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-partd)-description)\"" >>$@
	echo "module-whatis \"$($(python-partd)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-partd)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PARTD_ROOT $($(python-partd)-prefix)" >>$@
	echo "prepend-path PATH $($(python-partd)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-partd)-prefix)" >>$@
	echo "set MSG \"$(python-partd)\"" >>$@

$(python-partd)-src: $($(python-partd)-src)
$(python-partd)-unpack: $($(python-partd)-prefix)/.pkgunpack
$(python-partd)-patch: $($(python-partd)-prefix)/.pkgpatch
$(python-partd)-build: $($(python-partd)-prefix)/.pkgbuild
$(python-partd)-check: $($(python-partd)-prefix)/.pkgcheck
$(python-partd)-install: $($(python-partd)-prefix)/.pkginstall
$(python-partd)-modulefile: $($(python-partd)-modulefile)
$(python-partd)-clean:
	rm -rf $($(python-partd)-modulefile)
	rm -rf $($(python-partd)-prefix)
	rm -rf $($(python-partd)-srcdir)
	rm -rf $($(python-partd)-src)
$(python-partd): $(python-partd)-src $(python-partd)-unpack $(python-partd)-patch $(python-partd)-build $(python-partd)-check $(python-partd)-install $(python-partd)-modulefile
