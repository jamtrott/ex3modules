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
# munge-0.5.13

munge-version = 0.5.13
munge = munge-$(munge-version)
$(munge)-description = Authentication service for creating and validating credentials
$(munge)-url = https://dun.github.io/munge/
$(munge)-srcurl = https://github.com/dun/munge/archive/munge-$(munge-version).tar.gz
$(munge)-builddeps = $(openssl)
$(munge)-prereqs = $(openssl)
$(munge)-src = $(pkgsrcdir)/$(notdir $($(munge)-srcurl))
$(munge)-srcdir = $(pkgsrcdir)/$(munge)
$(munge)-builddir = $($(munge)-srcdir)
$(munge)-modulefile = $(modulefilesdir)/$(munge)
$(munge)-prefix = $(pkgdir)/$(munge)

$($(munge)-src): $(dir $($(munge)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(munge)-srcurl)

$($(munge)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(munge)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(munge)-prefix)/.pkgunpack: $($(munge)-src) $($(munge)-srcdir)/.markerfile $($(munge)-prefix)/.markerfile
	tar -C $($(munge)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(munge)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(munge)-builddir),$($(munge)-srcdir))
$($(munge)-builddir)/.markerfile: $($(munge)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(munge)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge)-builddir)/.markerfile $($(munge)-prefix)/.pkgpatch
	cd $($(munge)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(munge)-builddeps) && \
		./configure --prefix=$($(munge)-prefix) \
			--with-openssl-prefix=$${OPENSSL_ROOT} \
			--with-crypto-lib=openssl \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--runstatedir=/run && \
		$(MAKE)
	@touch $@

$($(munge)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge)-builddir)/.markerfile $($(munge)-prefix)/.pkgbuild
	cd $($(munge)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(munge)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(munge)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge)-builddir)/.markerfile $($(munge)-prefix)/.pkgcheck
	cd $($(munge)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(munge)-builddeps) && \
		$(MAKE) -i install
	@touch $@

$($(munge)-modulefile): $(modulefilesdir)/.markerfile $($(munge)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(munge)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(munge)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(munge)-description)\"" >>$@
	echo "module-whatis \"$($(munge)-url)\"" >>$@
	printf "$(foreach prereq,$($(munge)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MUNGE_ROOT $($(munge)-prefix)" >>$@
	echo "setenv MUNGE_INCDIR $($(munge)-prefix)/include" >>$@
	echo "setenv MUNGE_INCLUDEDIR $($(munge)-prefix)/include" >>$@
	echo "setenv MUNGE_LIBDIR $($(munge)-prefix)/lib" >>$@
	echo "setenv MUNGE_LIBRARYDIR $($(munge)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(munge)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(munge)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(munge)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(munge)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(munge)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(munge)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(munge)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(munge)-prefix)/share/info" >>$@
	echo "set MSG \"$(munge)\"" >>$@

$(munge)-src: $($(munge)-src)
$(munge)-unpack: $($(munge)-prefix)/.pkgunpack
$(munge)-patch: $($(munge)-prefix)/.pkgpatch
$(munge)-build: $($(munge)-prefix)/.pkgbuild
$(munge)-check: $($(munge)-prefix)/.pkgcheck
$(munge)-install: $($(munge)-prefix)/.pkginstall
$(munge)-modulefile: $($(munge)-modulefile)
$(munge)-clean:
	rm -rf $($(munge)-modulefile)
	rm -rf $($(munge)-prefix)
	rm -rf $($(munge)-srcdir)
	rm -rf $($(munge)-src)
$(munge): $(munge)-src $(munge)-unpack $(munge)-patch $(munge)-build $(munge)-check $(munge)-install $(munge)-modulefile
