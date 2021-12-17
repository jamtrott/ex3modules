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
# openssl-1.1.1c

openssl-1.1.1c-version = 1.1.1c
openssl-1.1.1c = openssl-$(openssl-1.1.1c-version)
$(openssl-1.1.1c)-description = TLS/SSL and crypto library
$(openssl-1.1.1c)-url = https://www.openssl.org/
$(openssl-1.1.1c)-srcurl = https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.tar.gz
$(openssl-1.1.1c)-builddeps = $(perl)
$(openssl-1.1.1c)-prereqs =
$(openssl-1.1.1c)-src = $(pkgsrcdir)/$(notdir $($(openssl-1.1.1c)-srcurl))
$(openssl-1.1.1c)-srcdir = $(pkgsrcdir)/$(openssl-1.1.1c)
$(openssl-1.1.1c)-builddir = $($(openssl-1.1.1c)-srcdir)
$(openssl-1.1.1c)-modulefile = $(modulefilesdir)/$(openssl-1.1.1c)
$(openssl-1.1.1c)-prefix = $(pkgdir)/$(openssl-1.1.1c)

$($(openssl-1.1.1c)-src): $(dir $($(openssl-1.1.1c)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openssl-1.1.1c)-srcurl)

$($(openssl-1.1.1c)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openssl-1.1.1c)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openssl-1.1.1c)-prefix)/.pkgunpack: $$($(openssl-1.1.1c)-src) $($(openssl-1.1.1c)-srcdir)/.markerfile $($(openssl-1.1.1c)-prefix)/.markerfile $$(foreach dep,$$($(openssl-1.1.1c)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openssl-1.1.1c)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openssl-1.1.1c)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1c)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1c)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(openssl-1.1.1c)-builddir),$($(openssl-1.1.1c)-srcdir))
$($(openssl-1.1.1c)-builddir)/.markerfile: $($(openssl-1.1.1c)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(openssl-1.1.1c)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1c)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1c)-builddir)/.markerfile $($(openssl-1.1.1c)-prefix)/.pkgpatch
	cd $($(openssl-1.1.1c)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl-1.1.1c)-builddeps) && \
		./config --prefix=$($(openssl-1.1.1c)-prefix) && \
		$(MAKE)
	@touch $@

$($(openssl-1.1.1c)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1c)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1c)-builddir)/.markerfile $($(openssl-1.1.1c)-prefix)/.pkgbuild
# Note: test_afalg fails on aarch64 (see https://github.com/openssl/openssl/issues/12242)
	cd $($(openssl-1.1.1c)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl-1.1.1c)-builddeps) && \
		$(MAKE) TESTS=-test_afalg test
	@touch $@

$($(openssl-1.1.1c)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1c)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1c)-builddir)/.markerfile $($(openssl-1.1.1c)-prefix)/.pkgcheck
	cd $($(openssl-1.1.1c)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl-1.1.1c)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(openssl-1.1.1c)-modulefile): $(modulefilesdir)/.markerfile $($(openssl-1.1.1c)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openssl-1.1.1c)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openssl-1.1.1c)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openssl-1.1.1c)-description)\"" >>$@
	echo "module-whatis \"$($(openssl-1.1.1c)-url)\"" >>$@
	printf "$(foreach prereq,$($(openssl-1.1.1c)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENSSL_ROOT $($(openssl-1.1.1c)-prefix)" >>$@
	echo "setenv OPENSSL_INCDIR $($(openssl-1.1.1c)-prefix)/include" >>$@
	echo "setenv OPENSSL_INCLUDEDIR $($(openssl-1.1.1c)-prefix)/include" >>$@
	echo "setenv OPENSSL_LIBDIR $($(openssl-1.1.1c)-prefix)/lib" >>$@
	echo "setenv OPENSSL_LIBRARYDIR $($(openssl-1.1.1c)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(openssl-1.1.1c)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openssl-1.1.1c)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openssl-1.1.1c)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openssl-1.1.1c)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openssl-1.1.1c)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openssl-1.1.1c)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openssl-1.1.1c)-prefix)/share/man" >>$@
	echo "set MSG \"$(openssl-1.1.1c)\"" >>$@

$(openssl-1.1.1c)-src: $$($(openssl-1.1.1c)-src)
$(openssl-1.1.1c)-unpack: $($(openssl-1.1.1c)-prefix)/.pkgunpack
$(openssl-1.1.1c)-patch: $($(openssl-1.1.1c)-prefix)/.pkgpatch
$(openssl-1.1.1c)-build: $($(openssl-1.1.1c)-prefix)/.pkgbuild
$(openssl-1.1.1c)-check: $($(openssl-1.1.1c)-prefix)/.pkgcheck
$(openssl-1.1.1c)-install: $($(openssl-1.1.1c)-prefix)/.pkginstall
$(openssl-1.1.1c)-modulefile: $($(openssl-1.1.1c)-modulefile)
$(openssl-1.1.1c)-clean:
	rm -rf $($(openssl-1.1.1c)-modulefile)
	rm -rf $($(openssl-1.1.1c)-prefix)
	rm -rf $($(openssl-1.1.1c)-srcdir)
	rm -rf $($(openssl-1.1.1c)-src)
$(openssl-1.1.1c): $(openssl-1.1.1c)-src $(openssl-1.1.1c)-unpack $(openssl-1.1.1c)-patch $(openssl-1.1.1c)-build $(openssl-1.1.1c)-check $(openssl-1.1.1c)-install $(openssl-1.1.1c)-modulefile
