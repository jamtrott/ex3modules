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
# libfs-1.0.8

libfs-version = 1.0.8
libfs = libfs-$(libfs-version)
$(libfs)-description = X Window System libraries
$(libfs)-url = https://x.org/
$(libfs)-srcurl = https://x.org/pub/individual/lib/libFS-$(libfs-version).tar.bz2
$(libfs)-src = $(pkgsrcdir)/$(notdir $($(libfs)-srcurl))
$(libfs)-srcdir = $(pkgsrcdir)/libFS-$(libfs-version)
$(libfs)-builddeps = $(fontconfig) $(libxcb) $(xtrans) $(util-linux) $(xorg-util-macros)
$(libfs)-prereqs = $(fontconfig) $(libxcb) $(xtrans) $(util-linux)
$(libfs)-modulefile = $(modulefilesdir)/$(libfs)
$(libfs)-prefix = $(pkgdir)/$(libfs)

$($(libfs)-src): $(dir $($(libfs)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libfs)-srcurl)

$($(libfs)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libfs)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libfs)-prefix)/.pkgunpack: $($(libfs)-src) $($(libfs)-srcdir)/.markerfile $($(libfs)-prefix)/.markerfile $$(foreach dep,$$($(libfs)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libfs)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libfs)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfs)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfs)-prefix)/.pkgunpack
	@touch $@

$($(libfs)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfs)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfs)-prefix)/.pkgpatch
	cd $($(libfs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfs)-builddeps) && \
		./configure --prefix=$($(libfs)-prefix) && \
		$(MAKE)
	@touch $@

$($(libfs)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfs)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfs)-prefix)/.pkgbuild
	cd $($(libfs)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfs)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libfs)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfs)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfs)-prefix)/.pkgcheck
	$(MAKE) -C $($(libfs)-srcdir) install
	@touch $@

$($(libfs)-modulefile): $(modulefilesdir)/.markerfile $($(libfs)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libfs)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libfs)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libfs)-description)\"" >>$@
	echo "module-whatis \"$($(libfs)-url)\"" >>$@
	printf "$(foreach prereq,$($(libfs)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBFS_ROOT $($(libfs)-prefix)" >>$@
	echo "setenv LIBFS_INCDIR $($(libfs)-prefix)/include" >>$@
	echo "setenv LIBFS_INCLUDEDIR $($(libfs)-prefix)/include" >>$@
	echo "setenv LIBFS_LIBDIR $($(libfs)-prefix)/lib" >>$@
	echo "setenv LIBFS_LIBRARYDIR $($(libfs)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libfs)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libfs)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libfs)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libfs)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libfs)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libfs)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libfs)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libfs)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libfs)-prefix)/share/info" >>$@
	echo "set MSG \"$(libfs)\"" >>$@

$(libfs)-src: $($(libfs)-src)
$(libfs)-unpack: $($(libfs)-prefix)/.pkgunpack
$(libfs)-patch: $($(libfs)-prefix)/.pkgpatch
$(libfs)-build: $($(libfs)-prefix)/.pkgbuild
$(libfs)-check: $($(libfs)-prefix)/.pkgcheck
$(libfs)-install: $($(libfs)-prefix)/.pkginstall
$(libfs)-modulefile: $($(libfs)-modulefile)
$(libfs)-clean:
	rm -rf $($(libfs)-modulefile)
	rm -rf $($(libfs)-prefix)
	rm -rf $($(libfs)-srcdir)
	rm -rf $($(libfs)-src)
$(libfs): $(libfs)-src $(libfs)-unpack $(libfs)-patch $(libfs)-build $(libfs)-check $(libfs)-install $(libfs)-modulefile
