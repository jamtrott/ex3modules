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
# libxkbfile-1.1.0

libxkbfile-version = 1.1.0
libxkbfile = libxkbfile-$(libxkbfile-version)
$(libxkbfile)-description = X Window System libraries
$(libxkbfile)-url = https://x.org/
$(libxkbfile)-srcurl = https://x.org/pub/individual/lib/$(libxkbfile).tar.bz2
$(libxkbfile)-src = $(pkgsrcdir)/$(notdir $($(libxkbfile)-srcurl))
$(libxkbfile)-srcdir = $(pkgsrcdir)/$(libxkbfile)
$(libxkbfile)-builddeps = $(libx11) $(xorg-util-macros)
$(libxkbfile)-prereqs = $(libx11)
$(libxkbfile)-modulefile = $(modulefilesdir)/$(libxkbfile)
$(libxkbfile)-prefix = $(pkgdir)/$(libxkbfile)

$($(libxkbfile)-src): $(dir $($(libxkbfile)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxkbfile)-srcurl)

$($(libxkbfile)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxkbfile)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxkbfile)-prefix)/.pkgunpack: $($(libxkbfile)-src) $($(libxkbfile)-srcdir)/.markerfile $($(libxkbfile)-prefix)/.markerfile $$(foreach dep,$$($(libxkbfile)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxkbfile)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libxkbfile)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxkbfile)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxkbfile)-prefix)/.pkgunpack
	@touch $@

$($(libxkbfile)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxkbfile)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxkbfile)-prefix)/.pkgpatch
	cd $($(libxkbfile)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxkbfile)-builddeps) && \
		./configure --prefix=$($(libxkbfile)-prefix) && \
		$(MAKE)
	@touch $@

$($(libxkbfile)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxkbfile)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxkbfile)-prefix)/.pkgbuild
	cd $($(libxkbfile)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxkbfile)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxkbfile)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxkbfile)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxkbfile)-prefix)/.pkgcheck
	$(MAKE) -C $($(libxkbfile)-srcdir) install
	@touch $@

$($(libxkbfile)-modulefile): $(modulefilesdir)/.markerfile $($(libxkbfile)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxkbfile)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxkbfile)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxkbfile)-description)\"" >>$@
	echo "module-whatis \"$($(libxkbfile)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxkbfile)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXKBFILE_ROOT $($(libxkbfile)-prefix)" >>$@
	echo "setenv LIBXKBFILE_INCDIR $($(libxkbfile)-prefix)/include" >>$@
	echo "setenv LIBXKBFILE_INCLUDEDIR $($(libxkbfile)-prefix)/include" >>$@
	echo "setenv LIBXKBFILE_LIBDIR $($(libxkbfile)-prefix)/lib" >>$@
	echo "setenv LIBXKBFILE_LIBRARYDIR $($(libxkbfile)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxkbfile)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxkbfile)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxkbfile)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxkbfile)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxkbfile)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxkbfile)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxkbfile)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libxkbfile)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libxkbfile)-prefix)/share/info" >>$@
	echo "set MSG \"$(libxkbfile)\"" >>$@

$(libxkbfile)-src: $($(libxkbfile)-src)
$(libxkbfile)-unpack: $($(libxkbfile)-prefix)/.pkgunpack
$(libxkbfile)-patch: $($(libxkbfile)-prefix)/.pkgpatch
$(libxkbfile)-build: $($(libxkbfile)-prefix)/.pkgbuild
$(libxkbfile)-check: $($(libxkbfile)-prefix)/.pkgcheck
$(libxkbfile)-install: $($(libxkbfile)-prefix)/.pkginstall
$(libxkbfile)-modulefile: $($(libxkbfile)-modulefile)
$(libxkbfile)-clean:
	rm -rf $($(libxkbfile)-modulefile)
	rm -rf $($(libxkbfile)-prefix)
	rm -rf $($(libxkbfile)-srcdir)
	rm -rf $($(libxkbfile)-src)
$(libxkbfile): $(libxkbfile)-src $(libxkbfile)-unpack $(libxkbfile)-patch $(libxkbfile)-build $(libxkbfile)-check $(libxkbfile)-install $(libxkbfile)-modulefile
