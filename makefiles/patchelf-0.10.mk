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
# patchelf-0.10

patchelf-version = 0.10
patchelf = patchelf-$(patchelf-version)
$(patchelf)-description = A small utility to modify the dynamic linker and RPATH of ELF executables
$(patchelf)-url = https://github.com/NixOS/patchelf
$(patchelf)-srcurl = https://github.com/NixOS/patchelf/archive/$(patchelf-version).tar.gz
$(patchelf)-builddeps = 
$(patchelf)-prereqs = 
$(patchelf)-src = $(pkgsrcdir)/$(notdir $($(patchelf)-srcurl))
$(patchelf)-srcdir = $(pkgsrcdir)/$(patchelf)
$(patchelf)-builddir = $($(patchelf)-srcdir)
$(patchelf)-modulefile = $(modulefilesdir)/$(patchelf)
$(patchelf)-prefix = $(pkgdir)/$(patchelf)

$($(patchelf)-src): $(dir $($(patchelf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(patchelf)-srcurl)

$($(patchelf)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(patchelf)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(patchelf)-prefix)/.pkgunpack: $($(patchelf)-src) $($(patchelf)-srcdir)/.markerfile $($(patchelf)-prefix)/.markerfile
	tar -C $($(patchelf)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(patchelf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(patchelf)-builddeps),$(modulefilesdir)/$$(dep)) $($(patchelf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(patchelf)-builddir),$($(patchelf)-srcdir))
$($(patchelf)-builddir)/.markerfile: $($(patchelf)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(patchelf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(patchelf)-builddeps),$(modulefilesdir)/$$(dep)) $($(patchelf)-builddir)/.markerfile $($(patchelf)-prefix)/.pkgpatch
	cd $($(patchelf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(patchelf)-builddeps) && \
		./bootstrap.sh && \
		./configure --prefix=$($(patchelf)-prefix) && \
		$(MAKE)
	@touch $@

$($(patchelf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(patchelf)-builddeps),$(modulefilesdir)/$$(dep)) $($(patchelf)-builddir)/.markerfile $($(patchelf)-prefix)/.pkgbuild
	cd $($(patchelf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(patchelf)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(patchelf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(patchelf)-builddeps),$(modulefilesdir)/$$(dep)) $($(patchelf)-builddir)/.markerfile $($(patchelf)-prefix)/.pkgcheck
	cd $($(patchelf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(patchelf)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(patchelf)-modulefile): $(modulefilesdir)/.markerfile $($(patchelf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(patchelf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(patchelf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(patchelf)-description)\"" >>$@
	echo "module-whatis \"$($(patchelf)-url)\"" >>$@
	printf "$(foreach prereq,$($(patchelf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PATCHELF_ROOT $($(patchelf)-prefix)" >>$@
	echo "prepend-path PATH $($(patchelf)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(patchelf)-prefix)/share/man" >>$@
	echo "set MSG \"$(patchelf)\"" >>$@

$(patchelf)-src: $($(patchelf)-src)
$(patchelf)-unpack: $($(patchelf)-prefix)/.pkgunpack
$(patchelf)-patch: $($(patchelf)-prefix)/.pkgpatch
$(patchelf)-build: $($(patchelf)-prefix)/.pkgbuild
$(patchelf)-check: $($(patchelf)-prefix)/.pkgcheck
$(patchelf)-install: $($(patchelf)-prefix)/.pkginstall
$(patchelf)-modulefile: $($(patchelf)-modulefile)
$(patchelf)-clean:
	rm -rf $($(patchelf)-modulefile)
	rm -rf $($(patchelf)-prefix)
	rm -rf $($(patchelf)-srcdir)
	rm -rf $($(patchelf)-src)
$(patchelf): $(patchelf)-src $(patchelf)-unpack $(patchelf)-patch $(patchelf)-build $(patchelf)-check $(patchelf)-install $(patchelf)-modulefile
