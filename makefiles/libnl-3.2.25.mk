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
# libnl-3.2.25

libnl-version = 3.2.25
libnl = libnl-$(libnl-version)
$(libnl)-description = Library for netlink protocol-based Linux kernel interfaces
$(libnl)-url = https://www.infradead.org/~tgr/libnl/
$(libnl)-srcurl = https://www.infradead.org/~tgr/libnl/files/libnl-$(libnl-version).tar.gz
$(libnl)-builddeps =
$(libnl)-prereqs =
$(libnl)-src = $(pkgsrcdir)/$(notdir $($(libnl)-srcurl))
$(libnl)-srcdir = $(pkgsrcdir)/$(libnl)
$(libnl)-builddir = $($(libnl)-srcdir)
$(libnl)-modulefile = $(modulefilesdir)/$(libnl)
$(libnl)-prefix = $(pkgdir)/$(libnl)

$($(libnl)-src): $(dir $($(libnl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libnl)-srcurl)

$($(libnl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libnl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libnl)-prefix)/.pkgunpack: $$($(libnl)-src) $($(libnl)-srcdir)/.markerfile $($(libnl)-prefix)/.markerfile $$(foreach dep,$$($(libnl)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libnl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libnl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libnl)-builddeps),$(modulefilesdir)/$$(dep)) $($(libnl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libnl)-builddir),$($(libnl)-srcdir))
$($(libnl)-builddir)/.markerfile: $($(libnl)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libnl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libnl)-builddeps),$(modulefilesdir)/$$(dep)) $($(libnl)-builddir)/.markerfile $($(libnl)-prefix)/.pkgpatch
	cd $($(libnl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libnl)-builddeps) && \
		./configure --prefix=$($(libnl)-prefix) && \
		$(MAKE)
	@touch $@

$($(libnl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libnl)-builddeps),$(modulefilesdir)/$$(dep)) $($(libnl)-builddir)/.markerfile $($(libnl)-prefix)/.pkgbuild
	cd $($(libnl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libnl)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libnl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libnl)-builddeps),$(modulefilesdir)/$$(dep)) $($(libnl)-builddir)/.markerfile $($(libnl)-prefix)/.pkgcheck
	cd $($(libnl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libnl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libnl)-modulefile): $(modulefilesdir)/.markerfile $($(libnl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libnl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libnl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libnl)-description)\"" >>$@
	echo "module-whatis \"$($(libnl)-url)\"" >>$@
	printf "$(foreach prereq,$($(libnl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBNL_ROOT $($(libnl)-prefix)" >>$@
	echo "setenv LIBNL_INCDIR $($(libnl)-prefix)/include" >>$@
	echo "setenv LIBNL_INCLUDEDIR $($(libnl)-prefix)/include" >>$@
	echo "setenv LIBNL_LIBDIR $($(libnl)-prefix)/lib" >>$@
	echo "setenv LIBNL_LIBRARYDIR $($(libnl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libnl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libnl)-prefix)/include/libnl3" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libnl)-prefix)/include/libnl3" >>$@
	echo "prepend-path LIBRARY_PATH $($(libnl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libnl)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libnl)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libnl)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libnl)-prefix)/share/info" >>$@
	echo "set MSG \"$(libnl)\"" >>$@

$(libnl)-src: $$($(libnl)-src)
$(libnl)-unpack: $($(libnl)-prefix)/.pkgunpack
$(libnl)-patch: $($(libnl)-prefix)/.pkgpatch
$(libnl)-build: $($(libnl)-prefix)/.pkgbuild
$(libnl)-check: $($(libnl)-prefix)/.pkgcheck
$(libnl)-install: $($(libnl)-prefix)/.pkginstall
$(libnl)-modulefile: $($(libnl)-modulefile)
$(libnl)-clean:
	rm -rf $($(libnl)-modulefile)
	rm -rf $($(libnl)-prefix)
	rm -rf $($(libnl)-srcdir)
	rm -rf $($(libnl)-src)
$(libnl): $(libnl)-src $(libnl)-unpack $(libnl)-patch $(libnl)-build $(libnl)-check $(libnl)-install $(libnl)-modulefile
