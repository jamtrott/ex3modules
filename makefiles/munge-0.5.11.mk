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
# munge-0.5.11

munge-0.5.11-version = 0.5.11
munge-0.5.11 = munge-$(munge-0.5.11-version)
$(munge-0.5.11)-description = Authentication service for creating and validating credentials
$(munge-0.5.11)-url = https://dun.github.io/munge/
$(munge-0.5.11)-srcurl = https://github.com/dun/munge/archive/munge-$(munge-0.5.11-version).tar.gz
$(munge-0.5.11)-builddeps = $(autoconf) $(libgcrypt)
$(munge-0.5.11)-prereqs = $(libgcrypt)
$(munge-0.5.11)-src = $(pkgsrcdir)/$(notdir $($(munge-0.5.11)-srcurl))
$(munge-0.5.11)-srcdir = $(pkgsrcdir)/$(munge-0.5.11)
$(munge-0.5.11)-builddir = $($(munge-0.5.11)-srcdir)
$(munge-0.5.11)-modulefile = $(modulefilesdir)/$(munge-0.5.11)
$(munge-0.5.11)-prefix = $(pkgdir)/$(munge-0.5.11)

$($(munge-0.5.11)-src): $(dir $($(munge-0.5.11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(munge-0.5.11)-srcurl)

$($(munge-0.5.11)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(munge-0.5.11)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(munge-0.5.11)-prefix)/.pkgunpack: $($(munge-0.5.11)-src) $($(munge-0.5.11)-srcdir)/.markerfile $($(munge-0.5.11)-prefix)/.markerfile $$(foreach dep,$$($(munge-0.5.11)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(munge-0.5.11)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(munge-0.5.11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge-0.5.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge-0.5.11)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(munge-0.5.11)-builddir),$($(munge-0.5.11)-srcdir))
$($(munge-0.5.11)-builddir)/.markerfile: $($(munge-0.5.11)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(munge-0.5.11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge-0.5.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge-0.5.11)-builddir)/.markerfile $($(munge-0.5.11)-prefix)/.pkgpatch
	cd $($(munge-0.5.11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(munge-0.5.11)-builddeps) && \
		./bootstrap && \
		./configure --prefix=$($(munge-0.5.11)-prefix) \
			--with-libgcrypt-prefix=$${LIBGCRYPT_ROOT} \
			--with-crypto-lib=libgcrypt \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--runstatedir=/run && \
		$(MAKE)
	@touch $@

$($(munge-0.5.11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge-0.5.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge-0.5.11)-builddir)/.markerfile $($(munge-0.5.11)-prefix)/.pkgbuild
	cd $($(munge-0.5.11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(munge-0.5.11)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(munge-0.5.11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(munge-0.5.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(munge-0.5.11)-builddir)/.markerfile $($(munge-0.5.11)-prefix)/.pkgcheck
	cd $($(munge-0.5.11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(munge-0.5.11)-builddeps) && \
		$(MAKE) -i install
	@touch $@

$($(munge-0.5.11)-modulefile): $(modulefilesdir)/.markerfile $($(munge-0.5.11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(munge-0.5.11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(munge-0.5.11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(munge-0.5.11)-description)\"" >>$@
	echo "module-whatis \"$($(munge-0.5.11)-url)\"" >>$@
	printf "$(foreach prereq,$($(munge-0.5.11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MUNGE_ROOT $($(munge-0.5.11)-prefix)" >>$@
	echo "setenv MUNGE_INCDIR $($(munge-0.5.11)-prefix)/include" >>$@
	echo "setenv MUNGE_INCLUDEDIR $($(munge-0.5.11)-prefix)/include" >>$@
	echo "setenv MUNGE_LIBDIR $($(munge-0.5.11)-prefix)/lib" >>$@
	echo "setenv MUNGE_LIBRARYDIR $($(munge-0.5.11)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(munge-0.5.11)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(munge-0.5.11)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(munge-0.5.11)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(munge-0.5.11)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(munge-0.5.11)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(munge-0.5.11)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(munge-0.5.11)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(munge-0.5.11)-prefix)/share/info" >>$@
	echo "set MSG \"$(munge-0.5.11)\"" >>$@

$(munge-0.5.11)-src: $($(munge-0.5.11)-src)
$(munge-0.5.11)-unpack: $($(munge-0.5.11)-prefix)/.pkgunpack
$(munge-0.5.11)-patch: $($(munge-0.5.11)-prefix)/.pkgpatch
$(munge-0.5.11)-build: $($(munge-0.5.11)-prefix)/.pkgbuild
$(munge-0.5.11)-check: $($(munge-0.5.11)-prefix)/.pkgcheck
$(munge-0.5.11)-install: $($(munge-0.5.11)-prefix)/.pkginstall
$(munge-0.5.11)-modulefile: $($(munge-0.5.11)-modulefile)
$(munge-0.5.11)-clean:
	rm -rf $($(munge-0.5.11)-modulefile)
	rm -rf $($(munge-0.5.11)-prefix)
	rm -rf $($(munge-0.5.11)-srcdir)
	rm -rf $($(munge-0.5.11)-src)
$(munge-0.5.11): $(munge-0.5.11)-src $(munge-0.5.11)-unpack $(munge-0.5.11)-patch $(munge-0.5.11)-build $(munge-0.5.11)-check $(munge-0.5.11)-install $(munge-0.5.11)-modulefile
