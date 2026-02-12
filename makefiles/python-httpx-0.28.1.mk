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
# python-httpx-0.28.1

python-httpx-version = 0.28.1
python-httpx = python-httpx-$(python-httpx-version)
$(python-httpx)-description = The next generation HTTP client.
$(python-httpx)-url = https://github.com/encode/httpx
$(python-httpx)-srcurl = https://files.pythonhosted.org/packages/b1/df/48c586a5fe32a0f01324ee087459e112ebb7224f646c0b5023f5e79e9956/httpx-0.28.1.tar.gz
$(python-httpx)-src = $(pkgsrcdir)/$(notdir $($(python-httpx)-srcurl))
$(python-httpx)-builddeps = $(python) $(python-pip)
$(python-httpx)-prereqs = $(python)
$(python-httpx)-srcdir = $(pkgsrcdir)/$(python-httpx)
$(python-httpx)-modulefile = $(modulefilesdir)/$(python-httpx)
$(python-httpx)-prefix = $(pkgdir)/$(python-httpx)

$($(python-httpx)-src): $(dir $($(python-httpx)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-httpx)-srcurl)

$($(python-httpx)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-httpx)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-httpx)-prefix)/.pkgunpack: $$($(python-httpx)-src) $($(python-httpx)-srcdir)/.markerfile $($(python-httpx)-prefix)/.markerfile $$(foreach dep,$$($(python-httpx)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-httpx)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-httpx)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpx)-prefix)/.pkgunpack
	@touch $@

$($(python-httpx)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpx)-prefix)/.pkgpatch
	@touch $@

$($(python-httpx)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpx)-prefix)/.pkgbuild
	@touch $@

$($(python-httpx)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpx)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpx)-prefix)/.pkgcheck
	cd $($(python-httpx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-httpx)-builddeps) && \
		PYTHONPATH=$($(python-httpx)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-httpx)-prefix)
	@touch $@

$($(python-httpx)-modulefile): $(modulefilesdir)/.markerfile $($(python-httpx)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-httpx)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-httpx)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-httpx)-description)\"" >>$@
	echo "module-whatis \"$($(python-httpx)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-httpx)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_HTTPX_ROOT $($(python-httpx)-prefix)" >>$@
	echo "prepend-path PATH $($(python-httpx)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-httpx)-prefix)" >>$@
	echo "set MSG \"$(python-httpx)\"" >>$@

$(python-httpx)-src: $($(python-httpx)-src)
$(python-httpx)-unpack: $($(python-httpx)-prefix)/.pkgunpack
$(python-httpx)-patch: $($(python-httpx)-prefix)/.pkgpatch
$(python-httpx)-build: $($(python-httpx)-prefix)/.pkgbuild
$(python-httpx)-check: $($(python-httpx)-prefix)/.pkgcheck
$(python-httpx)-install: $($(python-httpx)-prefix)/.pkginstall
$(python-httpx)-modulefile: $($(python-httpx)-modulefile)
$(python-httpx)-clean:
	rm -rf $($(python-httpx)-modulefile)
	rm -rf $($(python-httpx)-prefix)
	rm -rf $($(python-httpx)-srcdir)
	rm -rf $($(python-httpx)-src)
$(python-httpx): $(python-httpx)-src $(python-httpx)-unpack $(python-httpx)-patch $(python-httpx)-build $(python-httpx)-check $(python-httpx)-install $(python-httpx)-modulefile
