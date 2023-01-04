# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# fontconfig-2.13.96

fontconfig-version = 2.13.96
fontconfig = fontconfig-$(fontconfig-version)
$(fontconfig)-description = Library for configuring and customizing font access
$(fontconfig)-url = https://www.freedesktop.org/wiki/Software/fontconfig/
$(fontconfig)-srcurl = https://www.freedesktop.org/software/fontconfig/release/fontconfig-$(fontconfig-version).tar.gz
$(fontconfig)-src = $(pkgsrcdir)/$(notdir $($(fontconfig)-srcurl))
$(fontconfig)-srcdir = $(pkgsrcdir)/$(fontconfig)
$(fontconfig)-builddeps = $(gperf) $(expat) $(util-linux) $(freetype)
$(fontconfig)-prereqs = $(expat) $(util-linux) $(freetype)
$(fontconfig)-modulefile = $(modulefilesdir)/$(fontconfig)
$(fontconfig)-prefix = $(pkgdir)/$(fontconfig)

$($(fontconfig)-src): $(dir $($(fontconfig)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fontconfig)-srcurl)

$($(fontconfig)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fontconfig)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fontconfig)-prefix)/.pkgunpack: $($(fontconfig)-src) $($(fontconfig)-srcdir)/.markerfile $($(fontconfig)-prefix)/.markerfile $$(foreach dep,$$($(fontconfig)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(fontconfig)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fontconfig)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fontconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(fontconfig)-prefix)/.pkgunpack
	@touch $@

$($(fontconfig)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fontconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(fontconfig)-prefix)/.pkgpatch
	cd $($(fontconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fontconfig)-builddeps) && \
		./configure --prefix=$($(fontconfig)-prefix) \
			--disable-docs \
			MKDIR_P="$(INSTALL) -d" && \
		$(MAKE)
	@touch $@

$($(fontconfig)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fontconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(fontconfig)-prefix)/.pkgbuild
	cd $($(fontconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fontconfig)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(fontconfig)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fontconfig)-builddeps),$(modulefilesdir)/$$(dep)) $($(fontconfig)-prefix)/.pkgcheck
	$(INSTALL) -d $($(fontconfig)-prefix)
	$(INSTALL) -d $($(fontconfig)-prefix)/var
	cd $($(fontconfig)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fontconfig)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fontconfig)-modulefile): $(modulefilesdir)/.markerfile $($(fontconfig)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fontconfig)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fontconfig)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fontconfig)-description)\"" >>$@
	echo "module-whatis \"$($(fontconfig)-url)\"" >>$@
	printf "$(foreach prereq,$($(fontconfig)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FONTCONFIG_ROOT $($(fontconfig)-prefix)" >>$@
	echo "setenv FONTCONFIG_INCDIR $($(fontconfig)-prefix)/include" >>$@
	echo "setenv FONTCONFIG_INCLUDEDIR $($(fontconfig)-prefix)/include" >>$@
	echo "setenv FONTCONFIG_LIBDIR $($(fontconfig)-prefix)/lib" >>$@
	echo "setenv FONTCONFIG_LIBRARYDIR $($(fontconfig)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(fontconfig)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fontconfig)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fontconfig)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fontconfig)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fontconfig)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fontconfig)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(fontconfig)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(fontconfig)-prefix)/share/info" >>$@
	echo "set MSG \"$(fontconfig)\"" >>$@

$(fontconfig)-src: $($(fontconfig)-src)
$(fontconfig)-unpack: $($(fontconfig)-prefix)/.pkgunpack
$(fontconfig)-patch: $($(fontconfig)-prefix)/.pkgpatch
$(fontconfig)-build: $($(fontconfig)-prefix)/.pkgbuild
$(fontconfig)-check: $($(fontconfig)-prefix)/.pkgcheck
$(fontconfig)-install: $($(fontconfig)-prefix)/.pkginstall
$(fontconfig)-modulefile: $($(fontconfig)-modulefile)
$(fontconfig)-clean:
	rm -rf $($(fontconfig)-modulefile)
	rm -rf $($(fontconfig)-prefix)
	rm -rf $($(fontconfig)-srcdir)
	rm -rf $($(fontconfig)-src)
$(fontconfig): $(fontconfig)-src $(fontconfig)-unpack $(fontconfig)-patch $(fontconfig)-build $(fontconfig)-check $(fontconfig)-install $(fontconfig)-modulefile
