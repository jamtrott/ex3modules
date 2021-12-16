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
# libpciaccess-0.16

libpciaccess-version = 0.16
libpciaccess = libpciaccess-$(libpciaccess-version)
$(libpciaccess)-description = X Window System libraries
$(libpciaccess)-url = https://x.org/
$(libpciaccess)-srcurl = https://x.org/pub/individual/lib/$(libpciaccess).tar.bz2
$(libpciaccess)-src = $(pkgsrcdir)/$(notdir $($(libpciaccess)-srcurl))
$(libpciaccess)-srcdir = $(pkgsrcdir)/$(libpciaccess)
$(libpciaccess)-builddeps = $(xorg-util-macros)
$(libpciaccess)-prereqs =
$(libpciaccess)-modulefile = $(modulefilesdir)/$(libpciaccess)
$(libpciaccess)-prefix = $(pkgdir)/$(libpciaccess)

$($(libpciaccess)-src): $(dir $($(libpciaccess)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libpciaccess)-srcurl)

$($(libpciaccess)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpciaccess)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpciaccess)-prefix)/.pkgunpack: $($(libpciaccess)-src) $($(libpciaccess)-srcdir)/.markerfile $($(libpciaccess)-prefix)/.markerfile $$(foreach dep,$$($(libpciaccess)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libpciaccess)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libpciaccess)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpciaccess)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpciaccess)-prefix)/.pkgunpack
	@touch $@

$($(libpciaccess)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpciaccess)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpciaccess)-prefix)/.pkgpatch
	cd $($(libpciaccess)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpciaccess)-builddeps) && \
		./configure --prefix=$($(libpciaccess)-prefix) && \
		$(MAKE)
	@touch $@

$($(libpciaccess)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpciaccess)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpciaccess)-prefix)/.pkgbuild
	cd $($(libpciaccess)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpciaccess)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libpciaccess)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpciaccess)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpciaccess)-prefix)/.pkgcheck
	$(MAKE) -C $($(libpciaccess)-srcdir) install
	@touch $@

$($(libpciaccess)-modulefile): $(modulefilesdir)/.markerfile $($(libpciaccess)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libpciaccess)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libpciaccess)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libpciaccess)-description)\"" >>$@
	echo "module-whatis \"$($(libpciaccess)-url)\"" >>$@
	printf "$(foreach prereq,$($(libpciaccess)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBPCIACCESS_ROOT $($(libpciaccess)-prefix)" >>$@
	echo "setenv LIBPCIACCESS_INCDIR $($(libpciaccess)-prefix)/include" >>$@
	echo "setenv LIBPCIACCESS_INCLUDEDIR $($(libpciaccess)-prefix)/include" >>$@
	echo "setenv LIBPCIACCESS_LIBDIR $($(libpciaccess)-prefix)/lib" >>$@
	echo "setenv LIBPCIACCESS_LIBRARYDIR $($(libpciaccess)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libpciaccess)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libpciaccess)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libpciaccess)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libpciaccess)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libpciaccess)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libpciaccess)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libpciaccess)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libpciaccess)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libpciaccess)-prefix)/share/info" >>$@
	echo "set MSG \"$(libpciaccess)\"" >>$@

$(libpciaccess)-src: $($(libpciaccess)-src)
$(libpciaccess)-unpack: $($(libpciaccess)-prefix)/.pkgunpack
$(libpciaccess)-patch: $($(libpciaccess)-prefix)/.pkgpatch
$(libpciaccess)-build: $($(libpciaccess)-prefix)/.pkgbuild
$(libpciaccess)-check: $($(libpciaccess)-prefix)/.pkgcheck
$(libpciaccess)-install: $($(libpciaccess)-prefix)/.pkginstall
$(libpciaccess)-modulefile: $($(libpciaccess)-modulefile)
$(libpciaccess)-clean:
	rm -rf $($(libpciaccess)-modulefile)
	rm -rf $($(libpciaccess)-prefix)
	rm -rf $($(libpciaccess)-srcdir)
	rm -rf $($(libpciaccess)-src)
$(libpciaccess): $(libpciaccess)-src $(libpciaccess)-unpack $(libpciaccess)-patch $(libpciaccess)-build $(libpciaccess)-check $(libpciaccess)-install $(libpciaccess)-modulefile
