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
# libxxf86vm-1.1.4

libxxf86vm-version = 1.1.4
libxxf86vm = libxxf86vm-$(libxxf86vm-version)
$(libxxf86vm)-description = X Window System libraries
$(libxxf86vm)-url = https://x.org/
$(libxxf86vm)-srcurl = https://x.org/pub/individual/lib/libXxf86vm-$(libxxf86vm-version).tar.bz2
$(libxxf86vm)-src = $(pkgsrcdir)/$(notdir $($(libxxf86vm)-srcurl))
$(libxxf86vm)-srcdir = $(pkgsrcdir)/libXxf86vm-$(libxxf86vm-version)
$(libxxf86vm)-builddeps = $(libxcb) $(libx11) $(libxext) $(xorg-util-macros)
$(libxxf86vm)-prereqs = $(libxcb) $(libx11) $(libxext)
$(libxxf86vm)-modulefile = $(modulefilesdir)/$(libxxf86vm)
$(libxxf86vm)-prefix = $(pkgdir)/$(libxxf86vm)

$($(libxxf86vm)-src): $(dir $($(libxxf86vm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxxf86vm)-srcurl)

$($(libxxf86vm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxxf86vm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxxf86vm)-prefix)/.pkgunpack: $($(libxxf86vm)-src) $($(libxxf86vm)-srcdir)/.markerfile $($(libxxf86vm)-prefix)/.markerfile
	tar -C $($(libxxf86vm)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxxf86vm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86vm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86vm)-prefix)/.pkgunpack
	@touch $@

$($(libxxf86vm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86vm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86vm)-prefix)/.pkgpatch
	cd $($(libxxf86vm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxxf86vm)-builddeps) && \
		./configure --prefix=$($(libxxf86vm)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxxf86vm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86vm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86vm)-prefix)/.pkgbuild
	cd $($(libxxf86vm)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxxf86vm)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxxf86vm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxxf86vm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxxf86vm)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxxf86vm)-srcdir) install
	@touch $@

$($(libxxf86vm)-modulefile): $(modulefilesdir)/.markerfile $($(libxxf86vm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxxf86vm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxxf86vm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxxf86vm)-description)\"" >>$@
	echo "module-whatis \"$($(libxxf86vm)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxxf86vm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXXF86VM_ROOT $($(libxxf86vm)-prefix)" >>$@
	echo "setenv LIBXXF86VM_INCDIR $($(libxxf86vm)-prefix)/include" >>$@
	echo "setenv LIBXXF86VM_INCLUDEDIR $($(libxxf86vm)-prefix)/include" >>$@
	echo "setenv LIBXXF86VM_LIBDIR $($(libxxf86vm)-prefix)/lib" >>$@
	echo "setenv LIBXXF86VM_LIBRARYDIR $($(libxxf86vm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxxf86vm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxxf86vm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxxf86vm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxxf86vm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxxf86vm)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxxf86vm)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxxf86vm)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxxf86vm)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxxf86vm)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxxf86vm)\"" >>$@

$(libxxf86vm)-src: $($(libxxf86vm)-src)
$(libxxf86vm)-unpack: $($(libxxf86vm)-prefix)/.pkgunpack
$(libxxf86vm)-patch: $($(libxxf86vm)-prefix)/.pkgpatch
$(libxxf86vm)-build: $($(libxxf86vm)-prefix)/.pkgbuild
$(libxxf86vm)-check: $($(libxxf86vm)-prefix)/.pkgcheck
$(libxxf86vm)-install: $($(libxxf86vm)-prefix)/.pkginstall
$(libxxf86vm)-modulefile: $($(libxxf86vm)-modulefile)
$(libxxf86vm)-clean:
	rm -rf $($(libxxf86vm)-modulefile)
	rm -rf $($(libxxf86vm)-prefix)
	rm -rf $($(libxxf86vm)-srcdir)
	rm -rf $($(libxxf86vm)-src)
$(libxxf86vm): $(libxxf86vm)-src $(libxxf86vm)-unpack $(libxxf86vm)-patch $(libxxf86vm)-build $(libxxf86vm)-check $(libxxf86vm)-install $(libxxf86vm)-modulefile
