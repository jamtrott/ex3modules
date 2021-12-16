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
# libdmx-1.1.4

libdmx-version = 1.1.4
libdmx = libdmx-$(libdmx-version)
$(libdmx)-description = X Window System libraries
$(libdmx)-url = https://x.org/
$(libdmx)-srcurl = https://x.org/pub/individual/lib/$(libdmx).tar.bz2
$(libdmx)-src = $(pkgsrcdir)/$(notdir $($(libdmx)-srcurl))
$(libdmx)-srcdir = $(pkgsrcdir)/$(libdmx)
$(libdmx)-builddeps = $(libx11) $(libxext) $(libxcb) $(util-linux) $(xorg-util-macros)
$(libdmx)-prereqs = $(libx11) $(libxext) $(libxcb)
$(libdmx)-modulefile = $(modulefilesdir)/$(libdmx)
$(libdmx)-prefix = $(pkgdir)/$(libdmx)

$($(libdmx)-src): $(dir $($(libdmx)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libdmx)-srcurl)

$($(libdmx)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libdmx)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libdmx)-prefix)/.pkgunpack: $($(libdmx)-src) $($(libdmx)-srcdir)/.markerfile $($(libdmx)-prefix)/.markerfile $$(foreach dep,$$($(libdmx)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libdmx)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libdmx)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdmx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdmx)-prefix)/.pkgunpack
	@touch $@

$($(libdmx)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdmx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdmx)-prefix)/.pkgpatch
	cd $($(libdmx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdmx)-builddeps) && \
		./configure --prefix=$($(libdmx)-prefix) && \
		$(MAKE)
	@touch $@

$($(libdmx)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdmx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdmx)-prefix)/.pkgbuild
	cd $($(libdmx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdmx)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libdmx)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdmx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdmx)-prefix)/.pkgcheck
	$(MAKE) -C $($(libdmx)-srcdir) install
	@touch $@

$($(libdmx)-modulefile): $(modulefilesdir)/.markerfile $($(libdmx)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libdmx)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libdmx)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libdmx)-description)\"" >>$@
	echo "module-whatis \"$($(libdmx)-url)\"" >>$@
	printf "$(foreach prereq,$($(libdmx)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBDMX_ROOT $($(libdmx)-prefix)" >>$@
	echo "setenv LIBDMX_INCDIR $($(libdmx)-prefix)/include" >>$@
	echo "setenv LIBDMX_INCLUDEDIR $($(libdmx)-prefix)/include" >>$@
	echo "setenv LIBDMX_LIBDIR $($(libdmx)-prefix)/lib" >>$@
	echo "setenv LIBDMX_LIBRARYDIR $($(libdmx)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libdmx)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libdmx)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libdmx)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libdmx)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libdmx)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libdmx)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libdmx)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libdmx)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libdmx)-prefix)/share/info" >>$@
	echo "set MSG \"$(libdmx)\"" >>$@

$(libdmx)-src: $($(libdmx)-src)
$(libdmx)-unpack: $($(libdmx)-prefix)/.pkgunpack
$(libdmx)-patch: $($(libdmx)-prefix)/.pkgpatch
$(libdmx)-build: $($(libdmx)-prefix)/.pkgbuild
$(libdmx)-check: $($(libdmx)-prefix)/.pkgcheck
$(libdmx)-install: $($(libdmx)-prefix)/.pkginstall
$(libdmx)-modulefile: $($(libdmx)-modulefile)
$(libdmx)-clean:
	rm -rf $($(libdmx)-modulefile)
	rm -rf $($(libdmx)-prefix)
	rm -rf $($(libdmx)-srcdir)
	rm -rf $($(libdmx)-src)
$(libdmx): $(libdmx)-src $(libdmx)-unpack $(libdmx)-patch $(libdmx)-build $(libdmx)-check $(libdmx)-install $(libdmx)-modulefile
