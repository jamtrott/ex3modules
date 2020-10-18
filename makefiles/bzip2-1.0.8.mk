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
# bzip2-1.0.8

bzip2-version = 1.0.8
bzip2 = bzip2-$(bzip2-version)
$(bzip2)-description = Data compression program and library
$(bzip2)-url = https://www.sourceware.org/bzip2/
$(bzip2)-srcurl =  https://sourceware.org/pub/bzip2/bzip2-$(bzip2-version).tar.gz
$(bzip2)-builddeps =
$(bzip2)-prereqs =
$(bzip2)-src = $(pkgsrcdir)/$(notdir $($(bzip2)-srcurl))
$(bzip2)-srcdir = $(pkgsrcdir)/$(bzip2)
$(bzip2)-builddir = $($(bzip2)-srcdir)
$(bzip2)-modulefile = $(modulefilesdir)/$(bzip2)
$(bzip2)-prefix = $(pkgdir)/$(bzip2)

$($(bzip2)-src): $(dir $($(bzip2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(bzip2)-srcurl)

$($(bzip2)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(bzip2)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(bzip2)-prefix)/.pkgunpack: $($(bzip2)-src) $($(bzip2)-srcdir)/.markerfile $($(bzip2)-prefix)/.markerfile
	tar -C $($(bzip2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(bzip2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bzip2)-builddeps),$(modulefilesdir)/$$(dep)) $($(bzip2)-prefix)/.pkgunpack
	sed -i 's@\(ln -s -f \)$$(PREFIX)/bin/@\1@' $($(bzip2)-srcdir)/Makefile # See http://www.linuxfromscratch.org/lfs/view/development/chapter06/bzip2.html
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" $($(bzip2)-srcdir)/Makefile
	$(MAKE) MAKEFLAGS= -C $($(bzip2)-srcdir) -f Makefile-libbz2_so
	@touch $@

ifneq ($($(bzip2)-builddir),$($(bzip2)-srcdir))
$($(bzip2)-builddir)/.markerfile: $($(bzip2)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(bzip2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bzip2)-builddeps),$(modulefilesdir)/$$(dep)) $($(bzip2)-builddir)/.markerfile $($(bzip2)-prefix)/.pkgpatch
	cd $($(bzip2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(bzip2)-builddeps) && \
		$(MAKE)
	@touch $@

$($(bzip2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bzip2)-builddeps),$(modulefilesdir)/$$(dep)) $($(bzip2)-builddir)/.markerfile $($(bzip2)-prefix)/.pkgbuild
	cd $($(bzip2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(bzip2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(bzip2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bzip2)-builddeps),$(modulefilesdir)/$$(dep)) $($(bzip2)-builddir)/.markerfile $($(bzip2)-prefix)/.pkgcheck
	cd $($(bzip2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(bzip2)-builddeps) && \
		$(MAKE) PREFIX=$($(bzip2)-prefix) install
	cp -av $($(bzip2)-srcdir)/libbz2.so* $($(bzip2)-prefix)/lib
	ln -rsfv $($(bzip2)-prefix)/lib/libbz2.so.1.0 $($(bzip2)-prefix)/lib/libbz2.so
	rm $($(bzip2)-prefix)/lib/libbz2.a
	@touch $@

$($(bzip2)-modulefile): $(modulefilesdir)/.markerfile $($(bzip2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(bzip2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(bzip2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(bzip2)-description)\"" >>$@
	echo "module-whatis \"$($(bzip2)-url)\"" >>$@
	printf "$(foreach prereq,$($(bzip2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BZIP2_ROOT $($(bzip2)-prefix)" >>$@
	echo "setenv BZIP2_INCDIR $($(bzip2)-prefix)/include" >>$@
	echo "setenv BZIP2_INCLUDEDIR $($(bzip2)-prefix)/include" >>$@
	echo "setenv BZIP2_LIBDIR $($(bzip2)-prefix)/lib" >>$@
	echo "setenv BZIP2_LIBRARYDIR $($(bzip2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(bzip2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(bzip2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(bzip2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(bzip2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(bzip2)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(bzip2)-prefix)/share/man" >>$@
	echo "set MSG \"$(bzip2)\"" >>$@

$(bzip2)-src: $($(bzip2)-src)
$(bzip2)-unpack: $($(bzip2)-prefix)/.pkgunpack
$(bzip2)-patch: $($(bzip2)-prefix)/.pkgpatch
$(bzip2)-build: $($(bzip2)-prefix)/.pkgbuild
$(bzip2)-check: $($(bzip2)-prefix)/.pkgcheck
$(bzip2)-install: $($(bzip2)-prefix)/.pkginstall
$(bzip2)-modulefile: $($(bzip2)-modulefile)
$(bzip2)-clean:
	rm -rf $($(bzip2)-modulefile)
	rm -rf $($(bzip2)-prefix)
	rm -rf $($(bzip2)-srcdir)
	rm -rf $($(bzip2)-src)
$(bzip2): $(bzip2)-src $(bzip2)-unpack $(bzip2)-patch $(bzip2)-build $(bzip2)-check $(bzip2)-install $(bzip2)-modulefile
