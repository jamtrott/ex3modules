# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# libxml2-2.9.12

libxml2-version = 2.9.12
libxml2 = libxml2-$(libxml2-version)
$(libxml2)-description = XML C parser and toolkit
$(libxml2)-url = http://xmlsoft.org/
$(libxml2)-srcurl = http://xmlsoft.org/sources/libxml2-$(libxml2-version).tar.gz
$(libxml2)-builddeps = $(python) $(xz)
$(libxml2)-prereqs = $(xz)
$(libxml2)-src = $(pkgsrcdir)/$(notdir $($(libxml2)-srcurl))
$(libxml2)-srcdir = $(pkgsrcdir)/$(libxml2)
$(libxml2)-builddir = $($(libxml2)-srcdir)
$(libxml2)-modulefile = $(modulefilesdir)/$(libxml2)
$(libxml2)-prefix = $(pkgdir)/$(libxml2)

$($(libxml2)-src): $(dir $($(libxml2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libxml2)-srcurl)

$($(libxml2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxml2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libxml2)-prefix)/.pkgunpack: $$($(libxml2)-src) $($(libxml2)-srcdir)/.markerfile $($(libxml2)-prefix)/.markerfile $$(foreach dep,$$($(libxml2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libxml2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libxml2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxml2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxml2)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libxml2)-builddir),$($(libxml2)-srcdir))
$($(libxml2)-builddir)/.markerfile: $($(libxml2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libxml2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxml2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxml2)-builddir)/.markerfile $($(libxml2)-prefix)/.pkgpatch
	cd $($(libxml2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxml2)-builddeps) && \
		./configure --prefix=$($(libxml2)-prefix) \
			--without-python && \
		$(MAKE)
	@touch $@

$($(libxml2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxml2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxml2)-builddir)/.markerfile $($(libxml2)-prefix)/.pkgbuild
	cd $($(libxml2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxml2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libxml2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libxml2)-builddeps),$(modulefilesdir)/$$(dep)) $($(libxml2)-builddir)/.markerfile $($(libxml2)-prefix)/.pkgcheck
	cd $($(libxml2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libxml2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libxml2)-modulefile): $(modulefilesdir)/.markerfile $($(libxml2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libxml2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libxml2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libxml2)-description)\"" >>$@
	echo "module-whatis \"$($(libxml2)-url)\"" >>$@
	printf "$(foreach prereq,$($(libxml2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBXML2_ROOT $($(libxml2)-prefix)" >>$@
	echo "setenv LIBXML2_INCDIR $($(libxml2)-prefix)/include" >>$@
	echo "setenv LIBXML2_INCLUDEDIR $($(libxml2)-prefix)/include" >>$@
	echo "setenv LIBXML2_LIBDIR $($(libxml2)-prefix)/lib" >>$@
	echo "setenv LIBXML2_LIBRARYDIR $($(libxml2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libxml2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libxml2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libxml2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libxml2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libxml2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libxml2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(libxml2)-prefix)/lib/cmake/libxml2" >>$@
	echo "prepend-path MANPATH $($(libxml2)-prefix)/share/man" >>$@
	echo "prepend-path ACLOCAL_PATH $($(libxml2)-prefix)/share/aclocal" >>$@
	echo "set MSG \"$(libxml2)\"" >>$@

$(libxml2)-src: $$($(libxml2)-src)
$(libxml2)-unpack: $($(libxml2)-prefix)/.pkgunpack
$(libxml2)-patch: $($(libxml2)-prefix)/.pkgpatch
$(libxml2)-build: $($(libxml2)-prefix)/.pkgbuild
$(libxml2)-check: $($(libxml2)-prefix)/.pkgcheck
$(libxml2)-install: $($(libxml2)-prefix)/.pkginstall
$(libxml2)-modulefile: $($(libxml2)-modulefile)
$(libxml2)-clean:
	rm -rf $($(libxml2)-modulefile)
	rm -rf $($(libxml2)-prefix)
	rm -rf $($(libxml2)-builddir)
	rm -rf $($(libxml2)-srcdir)
	rm -rf $($(libxml2)-src)
$(libxml2): $(libxml2)-src $(libxml2)-unpack $(libxml2)-patch $(libxml2)-build $(libxml2)-check $(libxml2)-install $(libxml2)-modulefile
