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
# libxshmfence-1.3

libxshmfence-version = 1.3
libxshmfence = libxshmfence-$(libxshmfence-version)
$(libxshmfence)-description = X Window System libraries
$(libxshmfence)-url = https://x.org/
$(libxshmfence)-srcurl = https://x.org/pub/individual/lib/$(libxshmfence).tar.bz2
$(libxshmfence)-src = $(pkgsrcdir)/$(notdir $($(libxshmfence)-srcurl))
$(libxshmfence)-srcdir = $(pkgsrcdir)/$(libxshmfence)
$(libxshmfence)-builddeps = $(xorgproto) $(xorg-util-macros)
$(libxshmfence)-prereqs = $(xorgproto)
$(libxshmfence)-modulefile = $(modulefilesdir)/$(libxshmfence)
$(libxshmfence)-prefix = $(pkgdir)/$(libxshmfence)

$($(libxshmfence)-src): $(dir $($(libxshmfence)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxshmfence)-srcurl)

$($(libxshmfence)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxshmfence)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libxshmfence)-prefix)/.pkgunpack: $($(libxshmfence)-src) $($(libxshmfence)-srcdir)/.markerfile $($(libxshmfence)-prefix)/.markerfile
	tar -C $($(libxshmfence)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxshmfence)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxshmfence)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxshmfence)-prefix)/.pkgunpack
	@touch $@

$($(libxshmfence)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxshmfence)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxshmfence)-prefix)/.pkgpatch
	cd $($(libxshmfence)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxshmfence)-builddeps) && \
		./configure --prefix=$($(libxshmfence)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxshmfence)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxshmfence)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxshmfence)-prefix)/.pkgbuild
	cd $($(libxshmfence)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxshmfence)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxshmfence)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxshmfence)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxshmfence)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxshmfence)-srcdir) install
	@touch $@

$($(libxshmfence)-modulefile): $(modulefilesdir)/.markerfile $($(libxshmfence)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxshmfence)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxshmfence)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxshmfence)-description)\"" >>$@
	echo "module-whatis \"$($(libxshmfence)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxshmfence)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXSHMFENCE_ROOT $($(libxshmfence)-prefix)" >>$@
	echo "setenv LIBXSHMFENCE_INCDIR $($(libxshmfence)-prefix)/include" >>$@
	echo "setenv LIBXSHMFENCE_INCLUDEDIR $($(libxshmfence)-prefix)/include" >>$@
	echo "setenv LIBXSHMFENCE_LIBDIR $($(libxshmfence)-prefix)/lib" >>$@
	echo "setenv LIBXSHMFENCE_LIBRARYDIR $($(libxshmfence)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxshmfence)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxshmfence)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxshmfence)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxshmfence)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxshmfence)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxshmfence)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxshmfence)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxshmfence)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxshmfence)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxshmfence)\"" >>$@

$(libxshmfence)-src: $($(libxshmfence)-src)
$(libxshmfence)-unpack: $($(libxshmfence)-prefix)/.pkgunpack
$(libxshmfence)-patch: $($(libxshmfence)-prefix)/.pkgpatch
$(libxshmfence)-build: $($(libxshmfence)-prefix)/.pkgbuild
$(libxshmfence)-check: $($(libxshmfence)-prefix)/.pkgcheck
$(libxshmfence)-install: $($(libxshmfence)-prefix)/.pkginstall
$(libxshmfence)-modulefile: $($(libxshmfence)-modulefile)
$(libxshmfence)-clean:
	rm -rf $($(libxshmfence)-modulefile)
	rm -rf $($(libxshmfence)-prefix)
	rm -rf $($(libxshmfence)-srcdir)
	rm -rf $($(libxshmfence)-src)
$(libxshmfence): $(libxshmfence)-src $(libxshmfence)-unpack $(libxshmfence)-patch $(libxshmfence)-build $(libxshmfence)-check $(libxshmfence)-install $(libxshmfence)-modulefile
