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
# libgcrypt-1.8.7

libgcrypt-version = 1.8.7
libgcrypt = libgcrypt-$(libgcrypt-version)
$(libgcrypt)-description = General purpose cryptographic library
$(libgcrypt)-url = https://www.gnupg.org/software/libgcrypt/
$(libgcrypt)-srcurl = https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$(libgcrypt-version).tar.bz2
$(libgcrypt)-builddeps = $(libgpg-error)
$(libgcrypt)-prereqs = $(libgpg-error)
$(libgcrypt)-src = $(pkgsrcdir)/$(notdir $($(libgcrypt)-srcurl))
$(libgcrypt)-srcdir = $(pkgsrcdir)/$(libgcrypt)
$(libgcrypt)-builddir = $($(libgcrypt)-srcdir)
$(libgcrypt)-modulefile = $(modulefilesdir)/$(libgcrypt)
$(libgcrypt)-prefix = $(pkgdir)/$(libgcrypt)

$($(libgcrypt)-src): $(dir $($(libgcrypt)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libgcrypt)-srcurl)

$($(libgcrypt)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libgcrypt)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libgcrypt)-prefix)/.pkgunpack: $($(libgcrypt)-src) $($(libgcrypt)-srcdir)/.markerfile $($(libgcrypt)-prefix)/.markerfile
	tar -C $($(libgcrypt)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libgcrypt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgcrypt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgcrypt)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libgcrypt)-builddir),$($(libgcrypt)-srcdir))
$($(libgcrypt)-builddir)/.markerfile: $($(libgcrypt)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(libgcrypt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgcrypt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgcrypt)-builddir)/.markerfile $($(libgcrypt)-prefix)/.pkgpatch
	cd $($(libgcrypt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgcrypt)-builddeps) && \
		./configure --prefix=$($(libgcrypt)-prefix) \
			--with-libgpg-error-prefix=$${LIBGPG_ERROR_ROOT} && \
		$(MAKE)
	@touch $@

$($(libgcrypt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgcrypt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgcrypt)-builddir)/.markerfile $($(libgcrypt)-prefix)/.pkgbuild
	cd $($(libgcrypt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgcrypt)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libgcrypt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgcrypt)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgcrypt)-builddir)/.markerfile $($(libgcrypt)-prefix)/.pkgcheck
	cd $($(libgcrypt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgcrypt)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libgcrypt)-modulefile): $(modulefilesdir)/.markerfile $($(libgcrypt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libgcrypt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libgcrypt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libgcrypt)-description)\"" >>$@
	echo "module-whatis \"$($(libgcrypt)-url)\"" >>$@
	printf "$(foreach prereq,$($(libgcrypt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBGCRYPT_ROOT $($(libgcrypt)-prefix)" >>$@
	echo "setenv LIBGCRYPT_INCDIR $($(libgcrypt)-prefix)/include" >>$@
	echo "setenv LIBGCRYPT_INCLUDEDIR $($(libgcrypt)-prefix)/include" >>$@
	echo "setenv LIBGCRYPT_LIBDIR $($(libgcrypt)-prefix)/lib" >>$@
	echo "setenv LIBGCRYPT_LIBRARYDIR $($(libgcrypt)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libgcrypt)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libgcrypt)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libgcrypt)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgcrypt)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgcrypt)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libgcrypt)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libgcrypt)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libgcrypt)-prefix)/share/info" >>$@
	echo "set MSG \"$(libgcrypt)\"" >>$@

$(libgcrypt)-src: $($(libgcrypt)-src)
$(libgcrypt)-unpack: $($(libgcrypt)-prefix)/.pkgunpack
$(libgcrypt)-patch: $($(libgcrypt)-prefix)/.pkgpatch
$(libgcrypt)-build: $($(libgcrypt)-prefix)/.pkgbuild
$(libgcrypt)-check: $($(libgcrypt)-prefix)/.pkgcheck
$(libgcrypt)-install: $($(libgcrypt)-prefix)/.pkginstall
$(libgcrypt)-modulefile: $($(libgcrypt)-modulefile)
$(libgcrypt)-clean:
	rm -rf $($(libgcrypt)-modulefile)
	rm -rf $($(libgcrypt)-prefix)
	rm -rf $($(libgcrypt)-srcdir)
	rm -rf $($(libgcrypt)-src)
$(libgcrypt): $(libgcrypt)-src $(libgcrypt)-unpack $(libgcrypt)-patch $(libgcrypt)-build $(libgcrypt)-check $(libgcrypt)-install $(libgcrypt)-modulefile
