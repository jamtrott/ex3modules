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
# nasm-2.14.02

nasm-version = 2.14.02
nasm = nasm-$(nasm-version)
$(nasm)-description = Portable assembler tool with support for many output formats
$(nasm)-url = https://www.nasm.us/
$(nasm)-srcurl = https://www.nasm.us/pub/nasm/releasebuilds/$(nasm-version)/nasm-$(nasm-version).tar.gz
$(nasm)-src = $(pkgsrcdir)/$(notdir $($(nasm)-srcurl))
$(nasm)-srcdir = $(pkgsrcdir)/$(nasm)
$(nasm)-builddeps = 
$(nasm)-prereqs =
$(nasm)-modulefile = $(modulefilesdir)/$(nasm)
$(nasm)-prefix = $(pkgdir)/$(nasm)

$($(nasm)-src): $(dir $($(nasm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(nasm)-srcurl)

$($(nasm)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(nasm)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(nasm)-prefix)/.pkgunpack: $($(nasm)-src) $($(nasm)-srcdir)/.markerfile $($(nasm)-prefix)/.markerfile
	tar -C $($(nasm)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(nasm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nasm)-builddeps),$(modulefilesdir)/$$(dep)) $($(nasm)-prefix)/.pkgunpack
	@touch $@

$($(nasm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nasm)-builddeps),$(modulefilesdir)/$$(dep)) $($(nasm)-prefix)/.pkgpatch
	cd $($(nasm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nasm)-builddeps) && \
		./configure --prefix=$($(nasm)-prefix) && \
		$(MAKE)
	@touch $@

$($(nasm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nasm)-builddeps),$(modulefilesdir)/$$(dep)) $($(nasm)-prefix)/.pkgbuild
	@touch $@

$($(nasm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nasm)-builddeps),$(modulefilesdir)/$$(dep)) $($(nasm)-prefix)/.pkgcheck $($(nasm)-prefix)/.markerfile
	cd $($(nasm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nasm)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(nasm)-modulefile): $(modulefilesdir)/.markerfile $($(nasm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(nasm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(nasm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(nasm)-description)\"" >>$@
	echo "module-whatis \"$($(nasm)-url)\"" >>$@
	printf "$(foreach prereq,$($(nasm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NASM_ROOT $($(nasm)-prefix)" >>$@
	echo "prepend-path PATH $($(nasm)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(nasm)-prefix)/share/man" >>$@
	echo "set MSG \"$(nasm)\"" >>$@

$(nasm)-src: $($(nasm)-src)
$(nasm)-unpack: $($(nasm)-prefix)/.pkgunpack
$(nasm)-patch: $($(nasm)-prefix)/.pkgpatch
$(nasm)-build: $($(nasm)-prefix)/.pkgbuild
$(nasm)-check: $($(nasm)-prefix)/.pkgcheck
$(nasm)-install: $($(nasm)-prefix)/.pkginstall
$(nasm)-modulefile: $($(nasm)-modulefile)
$(nasm)-clean:
	rm -rf $($(nasm)-modulefile)
	rm -rf $($(nasm)-prefix)
	rm -rf $($(nasm)-srcdir)
	rm -rf $($(nasm)-src)
$(nasm): $(nasm)-src $(nasm)-unpack $(nasm)-patch $(nasm)-build $(nasm)-check $(nasm)-install $(nasm)-modulefile
