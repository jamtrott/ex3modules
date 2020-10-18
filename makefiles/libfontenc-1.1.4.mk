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
# libfontenc-1.1.4

libfontenc-version = 1.1.4
libfontenc = libfontenc-$(libfontenc-version)
$(libfontenc)-description = X Window System libraries
$(libfontenc)-url = https://x.org/
$(libfontenc)-srcurl = https://x.org/pub/individual/lib/$(libfontenc).tar.bz2
$(libfontenc)-src = $(pkgsrcdir)/$(notdir $($(libfontenc)-srcurl))
$(libfontenc)-srcdir = $(pkgsrcdir)/$(libfontenc)
$(libfontenc)-builddeps = $(fontconfig) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libfontenc)-prereqs = $(fontconfig) $(libxcb)
$(libfontenc)-modulefile = $(modulefilesdir)/$(libfontenc)
$(libfontenc)-prefix = $(pkgdir)/$(libfontenc)

$($(libfontenc)-src): $(dir $($(libfontenc)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libfontenc)-srcurl)

$($(libfontenc)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libfontenc)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libfontenc)-prefix)/.pkgunpack: $($(libfontenc)-src) $($(libfontenc)-srcdir)/.markerfile $($(libfontenc)-prefix)/.markerfile
	tar -C $($(libfontenc)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libfontenc)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfontenc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfontenc)-prefix)/.pkgunpack
	@touch $@

$($(libfontenc)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfontenc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfontenc)-prefix)/.pkgpatch
	cd $($(libfontenc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfontenc)-builddeps) && \
		./configure --prefix=$($(libfontenc)-prefix) && \
		$(MAKE)
	@touch $@

$($(libfontenc)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfontenc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfontenc)-prefix)/.pkgbuild
	cd $($(libfontenc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfontenc)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libfontenc)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfontenc)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfontenc)-prefix)/.pkgcheck
	$(MAKE) -C $($(libfontenc)-srcdir) install
	@touch $@

$($(libfontenc)-modulefile): $(modulefilesdir)/.markerfile $($(libfontenc)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libfontenc)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libfontenc)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libfontenc)-description)\"" >>$@
	echo "module-whatis \"$($(libfontenc)-url)\"" >>$@
	printf "$(foreach prereq,$($(libfontenc)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBFONTENC_ROOT $($(libfontenc)-prefix)" >>$@
	echo "setenv LIBFONTENC_INCDIR $($(libfontenc)-prefix)/include" >>$@
	echo "setenv LIBFONTENC_INCLUDEDIR $($(libfontenc)-prefix)/include" >>$@
	echo "setenv LIBFONTENC_LIBDIR $($(libfontenc)-prefix)/lib" >>$@
	echo "setenv LIBFONTENC_LIBRARYDIR $($(libfontenc)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libfontenc)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libfontenc)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libfontenc)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libfontenc)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libfontenc)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libfontenc)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libfontenc)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libfontenc)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libfontenc)-prefix)/share/info" >>$@
	echo "set MSG \"$(libfontenc)\"" >>$@

$(libfontenc)-src: $($(libfontenc)-src)
$(libfontenc)-unpack: $($(libfontenc)-prefix)/.pkgunpack
$(libfontenc)-patch: $($(libfontenc)-prefix)/.pkgpatch
$(libfontenc)-build: $($(libfontenc)-prefix)/.pkgbuild
$(libfontenc)-check: $($(libfontenc)-prefix)/.pkgcheck
$(libfontenc)-install: $($(libfontenc)-prefix)/.pkginstall
$(libfontenc)-modulefile: $($(libfontenc)-modulefile)
$(libfontenc)-clean:
	rm -rf $($(libfontenc)-modulefile)
	rm -rf $($(libfontenc)-prefix)
	rm -rf $($(libfontenc)-srcdir)
	rm -rf $($(libfontenc)-src)
$(libfontenc): $(libfontenc)-src $(libfontenc)-unpack $(libfontenc)-patch $(libfontenc)-build $(libfontenc)-check $(libfontenc)-install $(libfontenc)-modulefile
