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
# curl-7.69.1

curl-version = 7.69.1
curl = curl-$(curl-version)
$(curl)-description = Command line tool and library for transferring data with URLs
$(curl)-url = https://curl.haxx.se/
$(curl)-srcurl = https://curl.haxx.se/download/curl-$(curl-version).tar.gz
$(curl)-builddeps = $(openssl) $(perl)
$(curl)-prereqs = $(openssl)
$(curl)-src = $(pkgsrcdir)/$(notdir $($(curl)-srcurl))
$(curl)-srcdir = $(pkgsrcdir)/$(curl)
$(curl)-builddir = $($(curl)-srcdir)
$(curl)-modulefile = $(modulefilesdir)/$(curl)
$(curl)-prefix = $(pkgdir)/$(curl)

$($(curl)-src): $(dir $($(curl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(curl)-srcurl)

$($(curl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(curl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(curl)-prefix)/.pkgunpack: $($(curl)-src) $($(curl)-srcdir)/.markerfile $($(curl)-prefix)/.markerfile
	tar -C $($(curl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(curl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(curl)-builddeps),$(modulefilesdir)/$$(dep)) $($(curl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(curl)-builddir),$($(curl)-srcdir))
$($(curl)-builddir)/.markerfile: $($(curl)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(curl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(curl)-builddeps),$(modulefilesdir)/$$(dep)) $($(curl)-builddir)/.markerfile $($(curl)-prefix)/.pkgpatch
	cd $($(curl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(curl)-builddeps) && \
		./configure --prefix=$($(curl)-prefix) \
		--disable-static \
		--enable-threaded-resolver \
		--with-ca-path=/etc/ssl/certs && \
		$(MAKE)
	@touch $@

$($(curl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(curl)-builddeps),$(modulefilesdir)/$$(dep)) $($(curl)-builddir)/.markerfile $($(curl)-prefix)/.pkgbuild
	cd $($(curl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(curl)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(curl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(curl)-builddeps),$(modulefilesdir)/$$(dep)) $($(curl)-builddir)/.markerfile $($(curl)-prefix)/.pkgcheck
	cd $($(curl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(curl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(curl)-modulefile): $(modulefilesdir)/.markerfile $($(curl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(curl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(curl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(curl)-description)\"" >>$@
	echo "module-whatis \"$($(curl)-url)\"" >>$@
	printf "$(foreach prereq,$($(curl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CURL_ROOT $($(curl)-prefix)" >>$@
	echo "setenv CURL_INCDIR $($(curl)-prefix)/include" >>$@
	echo "setenv CURL_INCLUDEDIR $($(curl)-prefix)/include" >>$@
	echo "setenv CURL_LIBDIR $($(curl)-prefix)/lib" >>$@
	echo "setenv CURL_LIBRARYDIR $($(curl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(curl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(curl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(curl)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(curl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(curl)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(curl)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(curl)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(curl)-prefix)/share/man" >>$@
	echo "set MSG \"$(curl)\"" >>$@

$(curl)-src: $($(curl)-src)
$(curl)-unpack: $($(curl)-prefix)/.pkgunpack
$(curl)-patch: $($(curl)-prefix)/.pkgpatch
$(curl)-build: $($(curl)-prefix)/.pkgbuild
$(curl)-check: $($(curl)-prefix)/.pkgcheck
$(curl)-install: $($(curl)-prefix)/.pkginstall
$(curl)-modulefile: $($(curl)-modulefile)
$(curl)-clean:
	rm -rf $($(curl)-modulefile)
	rm -rf $($(curl)-prefix)
	rm -rf $($(curl)-srcdir)
	rm -rf $($(curl)-src)
$(curl): $(curl)-src $(curl)-unpack $(curl)-patch $(curl)-build $(curl)-check $(curl)-install $(curl)-modulefile
