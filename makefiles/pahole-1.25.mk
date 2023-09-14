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
# pahole-1.25

pahole-version = 1.25
pahole = pahole-$(pahole-version)
$(pahole)-description = shows data structure layouts encoded in DWARF and CTF debugging information formats
$(pahole)-url = https://git.kernel.org/pub/scm/devel/pahole/pahole.git
$(pahole)-srcurl = https://git.kernel.org/pub/scm/devel/pahole/pahole.git/snapshot/pahole-1.25.tar.gz
$(pahole)-builddeps = $(cmake) $(libdwarf) $(elfutils) $(libbpf)
$(pahole)-prereqs = $(libdwarf) $(elfutils) $(libbpf)
$(pahole)-src = $(pkgsrcdir)/$(notdir $($(pahole)-srcurl))
$(pahole)-srcdir = $(pkgsrcdir)/$(pahole)
$(pahole)-builddir = $($(pahole)-srcdir)/build
$(pahole)-modulefile = $(modulefilesdir)/$(pahole)
$(pahole)-prefix = $(pkgdir)/$(pahole)

$($(pahole)-src): $(dir $($(pahole)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pahole)-srcurl)

$($(pahole)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pahole)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pahole)-prefix)/.pkgunpack: $$($(pahole)-src) $($(pahole)-srcdir)/.markerfile $($(pahole)-prefix)/.markerfile $$(foreach dep,$$($(pahole)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(pahole)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pahole)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pahole)-builddeps),$(modulefilesdir)/$$(dep)) $($(pahole)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(pahole)-builddir),$($(pahole)-srcdir))
$($(pahole)-builddir)/.markerfile: $($(pahole)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pahole)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pahole)-builddeps),$(modulefilesdir)/$$(dep)) $($(pahole)-builddir)/.markerfile $($(pahole)-prefix)/.pkgpatch
	cd $($(pahole)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pahole)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(pahole)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib -D__LIB=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DLIBBPF_EMBEDDED=NO \
			-DDWARF_INCLUDE_DIR="$${LIBDWARF_INCDIR}" \
			-DLIBDW_INCLUDE_DIR="$${ELFUTILS_INCDIR}" \
			-DDWARF_LIBRARY="$${LIBDWARF_LIBDIR}/libdwarf.so" \
			-DDW_LIBRARY="$${LIBELF_LIBDIR}/libdw.so" \
			-DELF_LIBRARY="$${LIBELF_LIBDIR}/libelf.so" && \
		$(MAKE)
	@touch $@

$($(pahole)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pahole)-builddeps),$(modulefilesdir)/$$(dep)) $($(pahole)-builddir)/.markerfile $($(pahole)-prefix)/.pkgbuild
	cd $($(pahole)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pahole)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(pahole)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pahole)-builddeps),$(modulefilesdir)/$$(dep)) $($(pahole)-builddir)/.markerfile $($(pahole)-prefix)/.pkgcheck
	cd $($(pahole)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pahole)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(pahole)-modulefile): $(modulefilesdir)/.markerfile $($(pahole)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pahole)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pahole)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pahole)-description)\"" >>$@
	echo "module-whatis \"$($(pahole)-url)\"" >>$@
	printf "$(foreach prereq,$($(pahole)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PAHOLE_ROOT $($(pahole)-prefix)" >>$@
	echo "setenv PAHOLE_INCDIR $($(pahole)-prefix)/include" >>$@
	echo "setenv PAHOLE_INCLUDEDIR $($(pahole)-prefix)/include" >>$@
	echo "setenv PAHOLE_LIBDIR $($(pahole)-prefix)/lib" >>$@
	echo "setenv PAHOLE_LIBRARYDIR $($(pahole)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pahole)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pahole)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pahole)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pahole)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pahole)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pahole)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pahole)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(pahole)-prefix)/share/info" >>$@
	echo "set MSG \"$(pahole)\"" >>$@

$(pahole)-src: $$($(pahole)-src)
$(pahole)-unpack: $($(pahole)-prefix)/.pkgunpack
$(pahole)-patch: $($(pahole)-prefix)/.pkgpatch
$(pahole)-build: $($(pahole)-prefix)/.pkgbuild
$(pahole)-check: $($(pahole)-prefix)/.pkgcheck
$(pahole)-install: $($(pahole)-prefix)/.pkginstall
$(pahole)-modulefile: $($(pahole)-modulefile)
$(pahole)-clean:
	rm -rf $($(pahole)-modulefile)
	rm -rf $($(pahole)-prefix)
	rm -rf $($(pahole)-builddir)
	rm -rf $($(pahole)-srcdir)
	rm -rf $($(pahole)-src)
$(pahole): $(pahole)-src $(pahole)-unpack $(pahole)-patch $(pahole)-build $(pahole)-check $(pahole)-install $(pahole)-modulefile
