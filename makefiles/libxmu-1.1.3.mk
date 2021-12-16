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
# libxmu-1.1.3

libxmu-version = 1.1.3
libxmu = libxmu-$(libxmu-version)
$(libxmu)-description = X Window System libraries
$(libxmu)-url = https://x.org/
$(libxmu)-srcurl = https://x.org/pub/individual/lib/libXmu-$(libxmu-version).tar.bz2
$(libxmu)-src = $(pkgsrcdir)/$(notdir $($(libxmu)-srcurl))
$(libxmu)-srcdir = $(pkgsrcdir)/libXmu-$(libxmu-version)
$(libxmu)-builddeps = $(fontconfig) $(libxcb) $(libxt) $(libxext) $(util-linux) $(xorg-util-macros)
$(libxmu)-prereqs = $(fontconfig) $(libxcb) $(libxt) $(libxext)
$(libxmu)-modulefile = $(modulefilesdir)/$(libxmu)
$(libxmu)-prefix = $(pkgdir)/$(libxmu)

$($(libxmu)-src): $(dir $($(libxmu)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxmu)-srcurl)

$($(libxmu)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxmu)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxmu)-prefix)/.pkgunpack: $($(libxmu)-src) $($(libxmu)-srcdir)/.markerfile $($(libxmu)-prefix)/.markerfile $$(foreach dep,$$($(libxmu)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxmu)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxmu)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxmu)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxmu)-prefix)/.pkgunpack
	@touch $@

$($(libxmu)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxmu)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxmu)-prefix)/.pkgpatch
	cd $($(libxmu)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxmu)-builddeps) && \
		./configure --prefix=$($(libxmu)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxmu)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxmu)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxmu)-prefix)/.pkgbuild
	cd $($(libxmu)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxmu)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxmu)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxmu)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxmu)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxmu)-srcdir) install
	@touch $@

$($(libxmu)-modulefile): $(modulefilesdir)/.markerfile $($(libxmu)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxmu)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxmu)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxmu)-description)\"" >>$@
	echo "module-whatis \"$($(libxmu)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxmu)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXMU_ROOT $($(libxmu)-prefix)" >>$@
	echo "setenv LIBXMU_INCDIR $($(libxmu)-prefix)/include" >>$@
	echo "setenv LIBXMU_INCLUDEDIR $($(libxmu)-prefix)/include" >>$@
	echo "setenv LIBXMU_LIBDIR $($(libxmu)-prefix)/lib" >>$@
	echo "setenv LIBXMU_LIBRARYDIR $($(libxmu)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxmu)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxmu)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxmu)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxmu)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxmu)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxmu)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxmu)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxmu)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxmu)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxmu)\"" >>$@

$(libxmu)-src: $($(libxmu)-src)
$(libxmu)-unpack: $($(libxmu)-prefix)/.pkgunpack
$(libxmu)-patch: $($(libxmu)-prefix)/.pkgpatch
$(libxmu)-build: $($(libxmu)-prefix)/.pkgbuild
$(libxmu)-check: $($(libxmu)-prefix)/.pkgcheck
$(libxmu)-install: $($(libxmu)-prefix)/.pkginstall
$(libxmu)-modulefile: $($(libxmu)-modulefile)
$(libxmu)-clean:
	rm -rf $($(libxmu)-modulefile)
	rm -rf $($(libxmu)-prefix)
	rm -rf $($(libxmu)-srcdir)
	rm -rf $($(libxmu)-src)
$(libxmu): $(libxmu)-src $(libxmu)-unpack $(libxmu)-patch $(libxmu)-build $(libxmu)-check $(libxmu)-install $(libxmu)-modulefile
