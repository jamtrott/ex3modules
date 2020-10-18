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
# binutils-2.32

binutils-version = 2.32
binutils = binutils-$(binutils-version)
$(binutils)-description = Tools for creating and managing binary programs
$(binutils)-url = https://www.gnu.org/software/binutils/
$(binutils)-srcurl = https://ftp.gnu.org/gnu/binutils/binutils-$(binutils-version).tar.xz
$(binutils)-builddeps =
$(binutils)-prereqs =
$(binutils)-src = $(pkgsrcdir)/$(notdir $($(binutils)-srcurl))
$(binutils)-srcdir = $(pkgsrcdir)/$(binutils)
$(binutils)-builddir = $($(binutils)-srcdir)
$(binutils)-modulefile = $(modulefilesdir)/$(binutils)
$(binutils)-prefix = $(pkgdir)/$(binutils)

$($(binutils)-src): $(dir $($(binutils)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(binutils)-srcurl)

$($(binutils)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(binutils)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(binutils)-prefix)/.pkgunpack: $($(binutils)-src) $($(binutils)-srcdir)/.markerfile $($(binutils)-prefix)/.markerfile
	tar -C $($(binutils)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(binutils)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$(foreach dep,$$($(binutils)-builddeps),$(modulefilesdir)/$$(dep)),$(modulefilesdir)/$$(dep)) $($(binutils)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(binutils)-builddir),$($(binutils)-srcdir))
$($(binutils)-builddir)/.markerfile: $($(binutils)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(binutils)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$(foreach dep,$$($(binutils)-builddeps),$(modulefilesdir)/$$(dep)),$(modulefilesdir)/$$(dep)) $($(binutils)-builddir)/.markerfile $($(binutils)-prefix)/.pkgpatch
	cd $($(binutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(binutils)-builddeps) && \
		./configure --prefix=$($(binutils)-prefix) \
			--enable-shared --with-system-zlib && \
		$(MAKE)
	@touch $@

$($(binutils)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$(foreach dep,$$($(binutils)-builddeps),$(modulefilesdir)/$$(dep)),$(modulefilesdir)/$$(dep)) $($(binutils)-builddir)/.markerfile $($(binutils)-prefix)/.pkgbuild
	cd $($(binutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(binutils)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(binutils)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$(foreach dep,$$($(binutils)-builddeps),$(modulefilesdir)/$$(dep)),$(modulefilesdir)/$$(dep)) $($(binutils)-builddir)/.markerfile $($(binutils)-prefix)/.pkgcheck
	cd $($(binutils)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(binutils)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(binutils)-modulefile): $(modulefilesdir)/.markerfile $($(binutils)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(binutils)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(binutils)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(binutils)-description)\"" >>$@
	echo "module-whatis \"$($(binutils)-url)\"" >>$@
	printf "$(foreach prereq,$($(binutils)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BINUTILS_ROOT $($(binutils)-prefix)" >>$@
	echo "setenv BINUTILS_INCDIR $($(binutils)-prefix)/include" >>$@
	echo "setenv BINUTILS_INCLUDEDIR $($(binutils)-prefix)/include" >>$@
	echo "setenv BINUTILS_LIBDIR $($(binutils)-prefix)/lib" >>$@
	echo "setenv BINUTILS_LIBRARYDIR $($(binutils)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(binutils)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(binutils)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(binutils)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(binutils)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(binutils)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(binutils)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(binutils)-prefix)/share/info" >>$@
	echo "set MSG \"$(binutils)\"" >>$@

$(binutils)-src: $($(binutils)-src)
$(binutils)-unpack: $($(binutils)-prefix)/.pkgunpack
$(binutils)-patch: $($(binutils)-prefix)/.pkgpatch
$(binutils)-build: $($(binutils)-prefix)/.pkgbuild
$(binutils)-check: $($(binutils)-prefix)/.pkgcheck
$(binutils)-install: $($(binutils)-prefix)/.pkginstall
$(binutils)-modulefile: $($(binutils)-modulefile)
$(binutils)-clean:
	rm -rf $($(binutils)-modulefile)
	rm -rf $($(binutils)-prefix)
	rm -rf $($(binutils)-srcdir)
	rm -rf $($(binutils)-src)
$(binutils): $(binutils)-src $(binutils)-unpack $(binutils)-patch $(binutils)-build $(binutils)-check $(binutils)-install $(binutils)-modulefile
