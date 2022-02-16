# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# zlib-1.2.11

zlib-1.2.11-version = 1.2.11
zlib-1.2.11 = zlib-$(zlib-1.2.11-version)
$(zlib-1.2.11)-description = zlib compression library
$(zlib-1.2.11)-url = https://zlib.net/
$(zlib-1.2.11)-srcurl = https://zlib.net/zlib-$(zlib-1.2.11-version).tar.gz
$(zlib-1.2.11)-builddeps =
$(zlib-1.2.11)-prereqs =
$(zlib-1.2.11)-src = $(pkgsrcdir)/$(notdir $($(zlib-1.2.11)-srcurl))
$(zlib-1.2.11)-srcdir = $(pkgsrcdir)/$(zlib-1.2.11)
$(zlib-1.2.11)-builddir = $($(zlib-1.2.11)-srcdir)/build
$(zlib-1.2.11)-modulefile = $(modulefilesdir)/$(zlib-1.2.11)
$(zlib-1.2.11)-prefix = $(pkgdir)/$(zlib-1.2.11)

$($(zlib-1.2.11)-src): $(dir $($(zlib-1.2.11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(zlib-1.2.11)-srcurl)

$($(zlib-1.2.11)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(zlib-1.2.11)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(zlib-1.2.11)-prefix)/.pkgunpack: $$($(zlib-1.2.11)-src) $($(zlib-1.2.11)-srcdir)/.markerfile $($(zlib-1.2.11)-prefix)/.markerfile $$(foreach dep,$$($(zlib-1.2.11)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(zlib-1.2.11)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(zlib-1.2.11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(zlib-1.2.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(zlib-1.2.11)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(zlib-1.2.11)-builddir),$($(zlib-1.2.11)-srcdir))
$($(zlib-1.2.11)-builddir)/.markerfile: $($(zlib-1.2.11)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(zlib-1.2.11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(zlib-1.2.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(zlib-1.2.11)-builddir)/.markerfile $($(zlib-1.2.11)-prefix)/.pkgpatch
	cd $($(zlib-1.2.11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(zlib-1.2.11)-builddeps) && \
		../configure --prefix=$($(zlib-1.2.11)-prefix) && \
		$(MAKE)
	@touch $@

$($(zlib-1.2.11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(zlib-1.2.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(zlib-1.2.11)-builddir)/.markerfile $($(zlib-1.2.11)-prefix)/.pkgbuild
	cd $($(zlib-1.2.11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(zlib-1.2.11)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(zlib-1.2.11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(zlib-1.2.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(zlib-1.2.11)-builddir)/.markerfile $($(zlib-1.2.11)-prefix)/.pkgcheck
	cd $($(zlib-1.2.11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(zlib-1.2.11)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(zlib-1.2.11)-modulefile): $(modulefilesdir)/.markerfile $($(zlib-1.2.11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(zlib-1.2.11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(zlib-1.2.11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(zlib-1.2.11)-description)\"" >>$@
	echo "module-whatis \"$($(zlib-1.2.11)-url)\"" >>$@
	printf "$(foreach prereq,$($(zlib-1.2.11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv ZLIB_ROOT $($(zlib-1.2.11)-prefix)" >>$@
	echo "setenv ZLIB_INCDIR $($(zlib-1.2.11)-prefix)/include" >>$@
	echo "setenv ZLIB_INCLUDEDIR $($(zlib-1.2.11)-prefix)/include" >>$@
	echo "setenv ZLIB_LIBDIR $($(zlib-1.2.11)-prefix)/lib" >>$@
	echo "setenv ZLIB_LIBRARYDIR $($(zlib-1.2.11)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(zlib-1.2.11)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(zlib-1.2.11)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(zlib-1.2.11)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(zlib-1.2.11)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(zlib-1.2.11)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(zlib-1.2.11)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(zlib-1.2.11)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(zlib-1.2.11)-prefix)/share/info" >>$@
	echo "set MSG \"$(zlib-1.2.11)\"" >>$@

$(zlib-1.2.11)-src: $$($(zlib-1.2.11)-src)
$(zlib-1.2.11)-unpack: $($(zlib-1.2.11)-prefix)/.pkgunpack
$(zlib-1.2.11)-patch: $($(zlib-1.2.11)-prefix)/.pkgpatch
$(zlib-1.2.11)-build: $($(zlib-1.2.11)-prefix)/.pkgbuild
$(zlib-1.2.11)-check: $($(zlib-1.2.11)-prefix)/.pkgcheck
$(zlib-1.2.11)-install: $($(zlib-1.2.11)-prefix)/.pkginstall
$(zlib-1.2.11)-modulefile: $($(zlib-1.2.11)-modulefile)
$(zlib-1.2.11)-clean:
	rm -rf $($(zlib-1.2.11)-modulefile)
	rm -rf $($(zlib-1.2.11)-prefix)
	rm -rf $($(zlib-1.2.11)-builddir)
	rm -rf $($(zlib-1.2.11)-srcdir)
	rm -rf $($(zlib-1.2.11)-src)
$(zlib-1.2.11): $(zlib-1.2.11)-src $(zlib-1.2.11)-unpack $(zlib-1.2.11)-patch $(zlib-1.2.11)-build $(zlib-1.2.11)-check $(zlib-1.2.11)-install $(zlib-1.2.11)-modulefile
