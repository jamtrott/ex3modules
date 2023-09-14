# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# openssl-1.1.1v

openssl-1.1.1v-version = 1.1.1v
openssl-1.1.1v = openssl-$(openssl-1.1.1v-version)
$(openssl-1.1.1v)-description = TLS/SSL and crypto library
$(openssl-1.1.1v)-url = https://www.openssl.org/
$(openssl-1.1.1v)-srcurl = https://github.com/openssl/openssl/archive/OpenSSL_1_1_1v.tar.gz
$(openssl-1.1.1v)-builddeps = $(perl)
$(openssl-1.1.1v)-prereqs =
$(openssl-1.1.1v)-src = $(pkgsrcdir)/$(notdir $($(openssl-1.1.1v)-srcurl))
$(openssl-1.1.1v)-srcdir = $(pkgsrcdir)/$(openssl-1.1.1v)
$(openssl-1.1.1v)-builddir = $($(openssl-1.1.1v)-srcdir)
$(openssl-1.1.1v)-modulefile = $(modulefilesdir)/$(openssl-1.1.1v)
$(openssl-1.1.1v)-prefix = $(pkgdir)/$(openssl-1.1.1v)

$($(openssl-1.1.1v)-src): $(dir $($(openssl-1.1.1v)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openssl-1.1.1v)-srcurl)

$($(openssl-1.1.1v)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openssl-1.1.1v)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openssl-1.1.1v)-prefix)/.pkgunpack: $$($(openssl-1.1.1v)-src) $($(openssl-1.1.1v)-srcdir)/.markerfile $($(openssl-1.1.1v)-prefix)/.markerfile $$(foreach dep,$$($(openssl-1.1.1v)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openssl-1.1.1v)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openssl-1.1.1v)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1v)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1v)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(openssl-1.1.1v)-builddir),$($(openssl-1.1.1v)-srcdir))
$($(openssl-1.1.1v)-builddir)/.markerfile: $($(openssl-1.1.1v)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(openssl-1.1.1v)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1v)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1v)-builddir)/.markerfile $($(openssl-1.1.1v)-prefix)/.pkgpatch
	cd $($(openssl-1.1.1v)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl-1.1.1v)-builddeps) && \
		./config --prefix=$($(openssl-1.1.1v)-prefix) && \
		$(MAKE)
	@touch $@

$($(openssl-1.1.1v)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1v)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1v)-builddir)/.markerfile $($(openssl-1.1.1v)-prefix)/.pkgbuild
# Note: test_afalg fails on aarch64 (see https://github.com/openssl/openssl/issues/12242)
	cd $($(openssl-1.1.1v)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl-1.1.1v)-builddeps) && \
		$(MAKE) TESTS=-test_afalg test
	@touch $@

$($(openssl-1.1.1v)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl-1.1.1v)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl-1.1.1v)-builddir)/.markerfile $($(openssl-1.1.1v)-prefix)/.pkgcheck
	cd $($(openssl-1.1.1v)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl-1.1.1v)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(openssl-1.1.1v)-modulefile): $(modulefilesdir)/.markerfile $($(openssl-1.1.1v)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openssl-1.1.1v)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openssl-1.1.1v)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openssl-1.1.1v)-description)\"" >>$@
	echo "module-whatis \"$($(openssl-1.1.1v)-url)\"" >>$@
	printf "$(foreach prereq,$($(openssl-1.1.1v)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENSSL_ROOT $($(openssl-1.1.1v)-prefix)" >>$@
	echo "setenv OPENSSL_INCDIR $($(openssl-1.1.1v)-prefix)/include" >>$@
	echo "setenv OPENSSL_INCLUDEDIR $($(openssl-1.1.1v)-prefix)/include" >>$@
	echo "setenv OPENSSL_LIBDIR $($(openssl-1.1.1v)-prefix)/lib" >>$@
	echo "setenv OPENSSL_LIBRARYDIR $($(openssl-1.1.1v)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(openssl-1.1.1v)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openssl-1.1.1v)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openssl-1.1.1v)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openssl-1.1.1v)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openssl-1.1.1v)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openssl-1.1.1v)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openssl-1.1.1v)-prefix)/share/man" >>$@
	echo "set MSG \"$(openssl-1.1.1v)\"" >>$@

$(openssl-1.1.1v)-src: $$($(openssl-1.1.1v)-src)
$(openssl-1.1.1v)-unpack: $($(openssl-1.1.1v)-prefix)/.pkgunpack
$(openssl-1.1.1v)-patch: $($(openssl-1.1.1v)-prefix)/.pkgpatch
$(openssl-1.1.1v)-build: $($(openssl-1.1.1v)-prefix)/.pkgbuild
$(openssl-1.1.1v)-check: $($(openssl-1.1.1v)-prefix)/.pkgcheck
$(openssl-1.1.1v)-install: $($(openssl-1.1.1v)-prefix)/.pkginstall
$(openssl-1.1.1v)-modulefile: $($(openssl-1.1.1v)-modulefile)
$(openssl-1.1.1v)-clean:
	rm -rf $($(openssl-1.1.1v)-modulefile)
	rm -rf $($(openssl-1.1.1v)-prefix)
	rm -rf $($(openssl-1.1.1v)-srcdir)
	rm -rf $($(openssl-1.1.1v)-src)
$(openssl-1.1.1v): $(openssl-1.1.1v)-src $(openssl-1.1.1v)-unpack $(openssl-1.1.1v)-patch $(openssl-1.1.1v)-build $(openssl-1.1.1v)-check $(openssl-1.1.1v)-install $(openssl-1.1.1v)-modulefile
