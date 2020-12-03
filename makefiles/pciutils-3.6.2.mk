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
# pciutils-3.6.2

pciutils-version = 3.6.2
pciutils = pciutils-$(pciutils-version)
$(pciutils)-description = Programs for inspecting and manipulating configuration of PCI devices
$(pciutils)-url = https://mj.ucw.cz/sw/pciutils/
$(pciutils)-srcurl = https://mj.ucw.cz/download/linux/pci/pciutils-$(pciutils-version).tar.gz
$(pciutils)-builddeps =
$(pciutils)-prereqs =
$(pciutils)-src = $(pkgsrcdir)/$(notdir $($(pciutils)-srcurl))
$(pciutils)-srcdir = $(pkgsrcdir)/$(pciutils)
$(pciutils)-builddir = $($(pciutils)-srcdir)
$(pciutils)-modulefile = $(modulefilesdir)/$(pciutils)
$(pciutils)-prefix = $(pkgdir)/$(pciutils)

$($(pciutils)-src): $(dir $($(pciutils)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pciutils)-srcurl)

$($(pciutils)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pciutils)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pciutils)-prefix)/.pkgunpack: $($(pciutils)-src) $($(pciutils)-srcdir)/.markerfile $($(pciutils)-prefix)/.markerfile
	tar -C $($(pciutils)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pciutils)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pciutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(pciutils)-prefix)/.pkgunpack
	sed -i 's,MANDIR:=.*,MANDIR=$$(PREFIX)/share/man,' $($(pciutils)-srcdir)/Makefile
	@touch $@

ifneq ($($(pciutils)-builddir),$($(pciutils)-srcdir))
$($(pciutils)-builddir)/.markerfile: $($(pciutils)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pciutils)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pciutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(pciutils)-builddir)/.markerfile $($(pciutils)-prefix)/.pkgpatch
	cd $($(pciutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pciutils)-builddeps) && \
		$(MAKE) \
			SHARED=yes
	@touch $@

$($(pciutils)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pciutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(pciutils)-builddir)/.markerfile $($(pciutils)-prefix)/.pkgbuild
	@touch $@

$($(pciutils)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pciutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(pciutils)-builddir)/.markerfile $($(pciutils)-prefix)/.pkgcheck
	cd $($(pciutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pciutils)-builddeps) && \
		$(MAKE) MAKEFLAGS="PREFIX=$($(pciutils)-prefix)" install install-lib && \
		ln -sf $($(pciutils)-prefix)/lib/libpci.so.$(pciutils-version) $($(pciutils)-prefix)/lib/libpci.so
	@touch $@

$($(pciutils)-modulefile): $(modulefilesdir)/.markerfile $($(pciutils)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pciutils)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pciutils)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pciutils)-description)\"" >>$@
	echo "module-whatis \"$($(pciutils)-url)\"" >>$@
	printf "$(foreach prereq,$($(pciutils)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PCIUTILS_ROOT $($(pciutils)-prefix)" >>$@
	echo "setenv PCIUTILS_INCDIR $($(pciutils)-prefix)/include" >>$@
	echo "setenv PCIUTILS_INCLUDEDIR $($(pciutils)-prefix)/include" >>$@
	echo "setenv PCIUTILS_LIBDIR $($(pciutils)-prefix)/lib" >>$@
	echo "setenv PCIUTILS_LIBRARYDIR $($(pciutils)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pciutils)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pciutils)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pciutils)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pciutils)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pciutils)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pciutils)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pciutils)-prefix)/share/man" >>$@
	echo "set MSG \"$(pciutils)\"" >>$@

$(pciutils)-src: $($(pciutils)-src)
$(pciutils)-unpack: $($(pciutils)-prefix)/.pkgunpack
$(pciutils)-patch: $($(pciutils)-prefix)/.pkgpatch
$(pciutils)-build: $($(pciutils)-prefix)/.pkgbuild
$(pciutils)-check: $($(pciutils)-prefix)/.pkgcheck
$(pciutils)-install: $($(pciutils)-prefix)/.pkginstall
$(pciutils)-modulefile: $($(pciutils)-modulefile)
$(pciutils)-clean:
	rm -rf $($(pciutils)-modulefile)
	rm -rf $($(pciutils)-prefix)
	rm -rf $($(pciutils)-srcdir)
	rm -rf $($(pciutils)-src)
$(pciutils): $(pciutils)-src $(pciutils)-unpack $(pciutils)-patch $(pciutils)-build $(pciutils)-check $(pciutils)-install $(pciutils)-modulefile
