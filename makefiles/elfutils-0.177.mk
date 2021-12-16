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
# elfutils-0.177

elfutils-version = 0.177
elfutils = elfutils-$(elfutils-version)
$(elfutils)-description = Collection of utilities to handle ELF objects
$(elfutils)-url = https://sourceware.org/elfutils/
$(elfutils)-srcurl = ftp://sourceware.org/pub/elfutils/$(elfutils-version)/elfutils-$(elfutils-version).tar.bz2
$(elfutils)-builddeps = 
$(elfutils)-prereqs = 
$(elfutils)-src = $(pkgsrcdir)/$(notdir $($(elfutils)-srcurl))
$(elfutils)-srcdir = $(pkgsrcdir)/$(elfutils)
$(elfutils)-builddir = $($(elfutils)-srcdir)
$(elfutils)-modulefile = $(modulefilesdir)/$(elfutils)
$(elfutils)-prefix = $(pkgdir)/$(elfutils)

$($(elfutils)-src): $(dir $($(elfutils)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(elfutils)-srcurl)

$($(elfutils)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(elfutils)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(elfutils)-prefix)/.pkgunpack: $($(elfutils)-src) $($(elfutils)-srcdir)/.markerfile $($(elfutils)-prefix)/.markerfile $$(foreach dep,$$($(elfutils)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(elfutils)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(elfutils)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(elfutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(elfutils)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(elfutils)-builddir),$($(elfutils)-srcdir))
$($(elfutils)-builddir)/.markerfile: $($(elfutils)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(elfutils)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(elfutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(elfutils)-builddir)/.markerfile $($(elfutils)-prefix)/.pkgpatch
	cd $($(elfutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(elfutils)-builddeps) && \
		./configure --prefix=$($(elfutils)-prefix) && \
		$(MAKE)
	@touch $@

$($(elfutils)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(elfutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(elfutils)-builddir)/.markerfile $($(elfutils)-prefix)/.pkgbuild
ifneq ($(ARCH),aarch64)
# 	cd $($(elfutils)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(elfutils)-builddeps) && \
# 		$(MAKE) check
endif
	@touch $@

$($(elfutils)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(elfutils)-builddeps),$(modulefilesdir)/$$(dep)) $($(elfutils)-builddir)/.markerfile $($(elfutils)-prefix)/.pkgcheck
	cd $($(elfutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(elfutils)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(elfutils)-modulefile): $(modulefilesdir)/.markerfile $($(elfutils)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(elfutils)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(elfutils)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(elfutils)-description)\"" >>$@
	echo "module-whatis \"$($(elfutils)-url)\"" >>$@
	printf "$(foreach prereq,$($(elfutils)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv ELFUTILS_ROOT $($(elfutils)-prefix)" >>$@
	echo "setenv ELFUTILS_INCDIR $($(elfutils)-prefix)/include" >>$@
	echo "setenv ELFUTILS_INCLUDEDIR $($(elfutils)-prefix)/include" >>$@
	echo "setenv ELFUTILS_LIBDIR $($(elfutils)-prefix)/lib" >>$@
	echo "setenv ELFUTILS_LIBRARYDIR $($(elfutils)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(elfutils)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(elfutils)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(elfutils)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(elfutils)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(elfutils)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(elfutils)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(elfutils)\"" >>$@

$(elfutils)-src: $($(elfutils)-src)
$(elfutils)-unpack: $($(elfutils)-prefix)/.pkgunpack
$(elfutils)-patch: $($(elfutils)-prefix)/.pkgpatch
$(elfutils)-build: $($(elfutils)-prefix)/.pkgbuild
$(elfutils)-check: $($(elfutils)-prefix)/.pkgcheck
$(elfutils)-install: $($(elfutils)-prefix)/.pkginstall
$(elfutils)-modulefile: $($(elfutils)-modulefile)
$(elfutils)-clean:
	rm -rf $($(elfutils)-modulefile)
	rm -rf $($(elfutils)-prefix)
	rm -rf $($(elfutils)-srcdir)
	rm -rf $($(elfutils)-src)
$(elfutils): $(elfutils)-src $(elfutils)-unpack $(elfutils)-patch $(elfutils)-build $(elfutils)-check $(elfutils)-install $(elfutils)-modulefile
