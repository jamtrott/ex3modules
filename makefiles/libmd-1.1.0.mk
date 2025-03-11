# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# libmd-1.1.0

libmd-version = 1.1.0
libmd = libmd-$(libmd-version)
$(libmd)-description =
$(libmd)-url = https://libbsd.freedesktop.org/wiki/
$(libmd)-srcurl = https://libbsd.freedesktop.org/releases/libmd-1.1.0.tar.xz
$(libmd)-builddeps =
$(libmd)-prereqs =
$(libmd)-src = $(pkgsrcdir)/$(notdir $($(libmd)-srcurl))
$(libmd)-srcdir = $(pkgsrcdir)/$(libmd)
$(libmd)-builddir = $($(libmd)-srcdir)/build
$(libmd)-modulefile = $(modulefilesdir)/$(libmd)
$(libmd)-prefix = $(pkgdir)/$(libmd)

$($(libmd)-src): $(dir $($(libmd)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libmd)-srcurl)

$($(libmd)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libmd)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libmd)-prefix)/.pkgunpack: $$($(libmd)-src) $($(libmd)-srcdir)/.markerfile $($(libmd)-prefix)/.markerfile $$(foreach dep,$$($(libmd)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libmd)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libmd)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libmd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libmd)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libmd)-builddir),$($(libmd)-srcdir))
$($(libmd)-builddir)/.markerfile: $($(libmd)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libmd)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libmd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libmd)-builddir)/.markerfile $($(libmd)-prefix)/.pkgpatch
	cd $($(libmd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libmd)-builddeps) && \
		../configure --prefix=$($(libmd)-prefix) && \
		$(MAKE)
	@touch $@

$($(libmd)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libmd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libmd)-builddir)/.markerfile $($(libmd)-prefix)/.pkgbuild
	cd $($(libmd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libmd)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libmd)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libmd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libmd)-builddir)/.markerfile $($(libmd)-prefix)/.pkgcheck
	cd $($(libmd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libmd)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libmd)-modulefile): $(modulefilesdir)/.markerfile $($(libmd)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libmd)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libmd)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libmd)-description)\"" >>$@
	echo "module-whatis \"$($(libmd)-url)\"" >>$@
	printf "$(foreach prereq,$($(libmd)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBMD_ROOT $($(libmd)-prefix)" >>$@
	echo "setenv LIBMD_INCDIR $($(libmd)-prefix)/include" >>$@
	echo "setenv LIBMD_INCLUDEDIR $($(libmd)-prefix)/include" >>$@
	echo "setenv LIBMD_LIBDIR $($(libmd)-prefix)/lib" >>$@
	echo "setenv LIBMD_LIBRARYDIR $($(libmd)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libmd)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libmd)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libmd)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libmd)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libmd)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libmd)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libmd)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libmd)-prefix)/share/info" >>$@
	echo "set MSG \"$(libmd)\"" >>$@

$(libmd)-src: $$($(libmd)-src)
$(libmd)-unpack: $($(libmd)-prefix)/.pkgunpack
$(libmd)-patch: $($(libmd)-prefix)/.pkgpatch
$(libmd)-build: $($(libmd)-prefix)/.pkgbuild
$(libmd)-check: $($(libmd)-prefix)/.pkgcheck
$(libmd)-install: $($(libmd)-prefix)/.pkginstall
$(libmd)-modulefile: $($(libmd)-modulefile)
$(libmd)-clean:
	rm -rf $($(libmd)-modulefile)
	rm -rf $($(libmd)-prefix)
	rm -rf $($(libmd)-builddir)
	rm -rf $($(libmd)-srcdir)
	rm -rf $($(libmd)-src)
$(libmd): $(libmd)-src $(libmd)-unpack $(libmd)-patch $(libmd)-build $(libmd)-check $(libmd)-install $(libmd)-modulefile
