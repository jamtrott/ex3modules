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

openssl-version = 1.1.1c
openssl = openssl-$(openssl-version)
$(openssl)-description = TLS/SSL and crypto library
$(openssl)-url = https://www.openssl.org/
$(openssl)-srcurl = https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.tar.gz
$(openssl)-builddeps = $(perl)
$(openssl)-prereqs =
$(openssl)-src = $(pkgsrcdir)/$(notdir $($(openssl)-srcurl))
$(openssl)-srcdir = $(pkgsrcdir)/$(openssl)
$(openssl)-builddir = $($(openssl)-srcdir)
$(openssl)-modulefile = $(modulefilesdir)/$(openssl)
$(openssl)-prefix = $(pkgdir)/$(openssl)

$($(openssl)-src): $(dir $($(openssl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openssl)-srcurl)

$($(openssl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openssl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openssl)-prefix)/.pkgunpack: $($(openssl)-src) $($(openssl)-srcdir)/.markerfile $($(openssl)-prefix)/.markerfile $$(foreach dep,$$($(openssl)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openssl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openssl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(openssl)-builddir),$($(openssl)-srcdir))
$($(openssl)-builddir)/.markerfile: $($(openssl)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(openssl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl)-builddir)/.markerfile $($(openssl)-prefix)/.pkgpatch
	cd $($(openssl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl)-builddeps) && \
		./config --prefix=$($(openssl)-prefix) && \
		$(MAKE)
	@touch $@

$($(openssl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl)-builddir)/.markerfile $($(openssl)-prefix)/.pkgbuild
# Note: test_afalg fails on aarch64 (see https://github.com/openssl/openssl/issues/12242)
	cd $($(openssl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl)-builddeps) && \
		$(MAKE) TESTS=-test_afalg test
	@touch $@

$($(openssl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openssl)-builddeps),$(modulefilesdir)/$$(dep)) $($(openssl)-builddir)/.markerfile $($(openssl)-prefix)/.pkgcheck
	cd $($(openssl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openssl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(openssl)-modulefile): $(modulefilesdir)/.markerfile $($(openssl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openssl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openssl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openssl)-description)\"" >>$@
	echo "module-whatis \"$($(openssl)-url)\"" >>$@
	printf "$(foreach prereq,$($(openssl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENSSL_ROOT $($(openssl)-prefix)" >>$@
	echo "setenv OPENSSL_INCDIR $($(openssl)-prefix)/include" >>$@
	echo "setenv OPENSSL_INCLUDEDIR $($(openssl)-prefix)/include" >>$@
	echo "setenv OPENSSL_LIBDIR $($(openssl)-prefix)/lib" >>$@
	echo "setenv OPENSSL_LIBRARYDIR $($(openssl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(openssl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openssl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openssl)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openssl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openssl)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openssl)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openssl)-prefix)/share/man" >>$@
	echo "set MSG \"$(openssl)\"" >>$@

$(openssl)-src: $($(openssl)-src)
$(openssl)-unpack: $($(openssl)-prefix)/.pkgunpack
$(openssl)-patch: $($(openssl)-prefix)/.pkgpatch
$(openssl)-build: $($(openssl)-prefix)/.pkgbuild
$(openssl)-check: $($(openssl)-prefix)/.pkgcheck
$(openssl)-install: $($(openssl)-prefix)/.pkginstall
$(openssl)-modulefile: $($(openssl)-modulefile)
$(openssl)-clean:
	rm -rf $($(openssl)-modulefile)
	rm -rf $($(openssl)-prefix)
	rm -rf $($(openssl)-srcdir)
	rm -rf $($(openssl)-src)
$(openssl): $(openssl)-src $(openssl)-unpack $(openssl)-patch $(openssl)-build $(openssl)-check $(openssl)-install $(openssl)-modulefile
