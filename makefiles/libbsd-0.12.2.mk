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
# libbsd-0.12.2

libbsd-version = 0.12.2
libbsd = libbsd-$(libbsd-version)
$(libbsd)-description = functions commonly found on BSD systems
$(libbsd)-url = https://libbsd.freedesktop.org/wiki/
$(libbsd)-srcurl = https://libbsd.freedesktop.org/releases/libbsd-0.12.2.tar.xz
$(libbsd)-builddeps = $(libmd)
$(libbsd)-prereqs = $(libmd)
$(libbsd)-src = $(pkgsrcdir)/$(notdir $($(libbsd)-srcurl))
$(libbsd)-srcdir = $(pkgsrcdir)/$(libbsd)
$(libbsd)-builddir = $($(libbsd)-srcdir)/build
$(libbsd)-modulefile = $(modulefilesdir)/$(libbsd)
$(libbsd)-prefix = $(pkgdir)/$(libbsd)

$($(libbsd)-src): $(dir $($(libbsd)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libbsd)-srcurl)

$($(libbsd)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libbsd)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libbsd)-prefix)/.pkgunpack: $$($(libbsd)-src) $($(libbsd)-srcdir)/.markerfile $($(libbsd)-prefix)/.markerfile $$(foreach dep,$$($(libbsd)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libbsd)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libbsd)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbsd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbsd)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libbsd)-builddir),$($(libbsd)-srcdir))
$($(libbsd)-builddir)/.markerfile: $($(libbsd)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libbsd)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbsd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbsd)-builddir)/.markerfile $($(libbsd)-prefix)/.pkgpatch
	cd $($(libbsd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libbsd)-builddeps) && \
		../configure --prefix=$($(libbsd)-prefix) && \
		$(MAKE)
	@touch $@

$($(libbsd)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbsd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbsd)-builddir)/.markerfile $($(libbsd)-prefix)/.pkgbuild
	cd $($(libbsd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libbsd)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libbsd)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbsd)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbsd)-builddir)/.markerfile $($(libbsd)-prefix)/.pkgcheck
	cd $($(libbsd)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libbsd)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libbsd)-modulefile): $(modulefilesdir)/.markerfile $($(libbsd)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libbsd)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libbsd)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libbsd)-description)\"" >>$@
	echo "module-whatis \"$($(libbsd)-url)\"" >>$@
	printf "$(foreach prereq,$($(libbsd)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBBSD_ROOT $($(libbsd)-prefix)" >>$@
	echo "setenv LIBBSD_INCDIR $($(libbsd)-prefix)/include" >>$@
	echo "setenv LIBBSD_INCLUDEDIR $($(libbsd)-prefix)/include" >>$@
	echo "setenv LIBBSD_LIBDIR $($(libbsd)-prefix)/lib" >>$@
	echo "setenv LIBBSD_LIBRARYDIR $($(libbsd)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libbsd)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libbsd)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libbsd)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libbsd)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libbsd)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libbsd)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libbsd)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libbsd)-prefix)/share/info" >>$@
	echo "set MSG \"$(libbsd)\"" >>$@

$(libbsd)-src: $$($(libbsd)-src)
$(libbsd)-unpack: $($(libbsd)-prefix)/.pkgunpack
$(libbsd)-patch: $($(libbsd)-prefix)/.pkgpatch
$(libbsd)-build: $($(libbsd)-prefix)/.pkgbuild
$(libbsd)-check: $($(libbsd)-prefix)/.pkgcheck
$(libbsd)-install: $($(libbsd)-prefix)/.pkginstall
$(libbsd)-modulefile: $($(libbsd)-modulefile)
$(libbsd)-clean:
	rm -rf $($(libbsd)-modulefile)
	rm -rf $($(libbsd)-prefix)
	rm -rf $($(libbsd)-builddir)
	rm -rf $($(libbsd)-srcdir)
	rm -rf $($(libbsd)-src)
$(libbsd): $(libbsd)-src $(libbsd)-unpack $(libbsd)-patch $(libbsd)-build $(libbsd)-check $(libbsd)-install $(libbsd)-modulefile
