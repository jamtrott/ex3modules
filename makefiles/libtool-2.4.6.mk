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
# libtool-2.4.6

libtool-version = 2.4.6
libtool = libtool-$(libtool-version)
$(libtool)-description = The GNU Portable Library Tool
$(libtool)-url = https://www.gnu.org/software/libtool/
$(libtool)-srcurl = http://ftpmirror.gnu.org/libtool/libtool-$(libtool-version).tar.gz
$(libtool)-builddeps =
$(libtool)-prereqs =
$(libtool)-src = $(pkgsrcdir)/$(notdir $($(libtool)-srcurl))
$(libtool)-srcdir = $(pkgsrcdir)/$(libtool)
$(libtool)-builddir = $($(libtool)-srcdir)
$(libtool)-modulefile = $(modulefilesdir)/$(libtool)
$(libtool)-prefix = $(pkgdir)/$(libtool)

$($(libtool)-src): $(dir $($(libtool)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libtool)-srcurl)

$($(libtool)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libtool)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libtool)-prefix)/.pkgunpack: $($(libtool)-src) $($(libtool)-srcdir)/.markerfile $($(libtool)-prefix)/.markerfile
	tar -C $($(libtool)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libtool)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtool)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtool)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libtool)-builddir),$($(libtool)-srcdir))
$($(libtool)-builddir)/.markerfile: $($(libtool)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libtool)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtool)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtool)-builddir)/.markerfile $($(libtool)-prefix)/.pkgpatch
	cd $($(libtool)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libtool)-builddeps) && \
		./configure --prefix=$($(libtool)-prefix) && \
		$(MAKE)
	@touch $@

$($(libtool)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtool)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtool)-builddir)/.markerfile $($(libtool)-prefix)/.pkgbuild
# 	cd $($(libtool)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(libtool)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(libtool)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libtool)-builddeps),$(modulefilesdir)/$$(dep)) $($(libtool)-builddir)/.markerfile $($(libtool)-prefix)/.pkgcheck
	cd $($(libtool)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libtool)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libtool)-modulefile): $(modulefilesdir)/.markerfile $($(libtool)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libtool)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libtool)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libtool)-description)\"" >>$@
	echo "module-whatis \"$($(libtool)-url)\"" >>$@
	printf "$(foreach prereq,$($(libtool)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBTOOL_ROOT $($(libtool)-prefix)" >>$@
	echo "setenv LIBTOOL_INCDIR $($(libtool)-prefix)/include" >>$@
	echo "setenv LIBTOOL_INCLUDEDIR $($(libtool)-prefix)/include" >>$@
	echo "setenv LIBTOOL_LIBDIR $($(libtool)-prefix)/lib" >>$@
	echo "setenv LIBTOOL_LIBRARYDIR $($(libtool)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libtool)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libtool)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libtool)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libtool)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libtool)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libtool)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libtool)-prefix)/share/aclocal" >>$@
	echo "prepend-path MANPATH $($(libtool)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libtool)-prefix)/share/info" >>$@
	echo "set MSG \"$(libtool)\"" >>$@

$(libtool)-src: $($(libtool)-src)
$(libtool)-unpack: $($(libtool)-prefix)/.pkgunpack
$(libtool)-patch: $($(libtool)-prefix)/.pkgpatch
$(libtool)-build: $($(libtool)-prefix)/.pkgbuild
$(libtool)-check: $($(libtool)-prefix)/.pkgcheck
$(libtool)-install: $($(libtool)-prefix)/.pkginstall
$(libtool)-modulefile: $($(libtool)-modulefile)
$(libtool)-clean:
	rm -rf $($(libtool)-modulefile)
	rm -rf $($(libtool)-prefix)
	rm -rf $($(libtool)-srcdir)
	rm -rf $($(libtool)-src)
$(libtool): $(libtool)-src $(libtool)-unpack $(libtool)-patch $(libtool)-build $(libtool)-check $(libtool)-install $(libtool)-modulefile
