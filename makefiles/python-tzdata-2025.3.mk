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
# python-tzdata-2025.3

python-tzdata-version = 2025.3
python-tzdata = python-tzdata-$(python-tzdata-version)
$(python-tzdata)-description = Provider of IANA time zone data
$(python-tzdata)-url = https://github.com/python/tzdata
$(python-tzdata)-srcurl = https://files.pythonhosted.org/packages/5e/a7/c202b344c5ca7daf398f3b8a477eeb205cf3b6f32e7ec3a6bac0629ca975/tzdata-2025.3.tar.gz
$(python-tzdata)-src = $(pkgsrcdir)/$(notdir $($(python-tzdata)-srcurl))
$(python-tzdata)-builddeps = $(python) $(python-pip)
$(python-tzdata)-prereqs = $(python)
$(python-tzdata)-srcdir = $(pkgsrcdir)/$(python-tzdata)
$(python-tzdata)-modulefile = $(modulefilesdir)/$(python-tzdata)
$(python-tzdata)-prefix = $(pkgdir)/$(python-tzdata)

$($(python-tzdata)-src): $(dir $($(python-tzdata)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-tzdata)-srcurl)

$($(python-tzdata)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tzdata)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tzdata)-prefix)/.pkgunpack: $$($(python-tzdata)-src) $($(python-tzdata)-srcdir)/.markerfile $($(python-tzdata)-prefix)/.markerfile $$(foreach dep,$$($(python-tzdata)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-tzdata)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-tzdata)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tzdata)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tzdata)-prefix)/.pkgunpack
	@touch $@

$($(python-tzdata)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tzdata)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tzdata)-prefix)/.pkgpatch
	@touch $@

$($(python-tzdata)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tzdata)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tzdata)-prefix)/.pkgbuild
	@touch $@

$($(python-tzdata)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tzdata)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tzdata)-prefix)/.pkgcheck
	cd $($(python-tzdata)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tzdata)-builddeps) && \
		PYTHONPATH=$($(python-tzdata)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-tzdata)-prefix)
	@touch $@

$($(python-tzdata)-modulefile): $(modulefilesdir)/.markerfile $($(python-tzdata)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-tzdata)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-tzdata)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-tzdata)-description)\"" >>$@
	echo "module-whatis \"$($(python-tzdata)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-tzdata)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TZDATA_ROOT $($(python-tzdata)-prefix)" >>$@
	echo "prepend-path PATH $($(python-tzdata)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-tzdata)-prefix)" >>$@
	echo "set MSG \"$(python-tzdata)\"" >>$@

$(python-tzdata)-src: $($(python-tzdata)-src)
$(python-tzdata)-unpack: $($(python-tzdata)-prefix)/.pkgunpack
$(python-tzdata)-patch: $($(python-tzdata)-prefix)/.pkgpatch
$(python-tzdata)-build: $($(python-tzdata)-prefix)/.pkgbuild
$(python-tzdata)-check: $($(python-tzdata)-prefix)/.pkgcheck
$(python-tzdata)-install: $($(python-tzdata)-prefix)/.pkginstall
$(python-tzdata)-modulefile: $($(python-tzdata)-modulefile)
$(python-tzdata)-clean:
	rm -rf $($(python-tzdata)-modulefile)
	rm -rf $($(python-tzdata)-prefix)
	rm -rf $($(python-tzdata)-srcdir)
	rm -rf $($(python-tzdata)-src)
$(python-tzdata): $(python-tzdata)-src $(python-tzdata)-unpack $(python-tzdata)-patch $(python-tzdata)-build $(python-tzdata)-check $(python-tzdata)-install $(python-tzdata)-modulefile
