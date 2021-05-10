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
# libiconv-1.16

libiconv-version = 1.16
libiconv = libiconv-$(libiconv-version)
$(libiconv)-description = Library for converting from one character encoding to another
$(libiconv)-url = https://www.gnu.org/software/libiconv/
$(libiconv)-srcurl = https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(libiconv-version).tar.gz
$(libiconv)-builddeps =
$(libiconv)-prereqs =
$(libiconv)-src = $(pkgsrcdir)/$(notdir $($(libiconv)-srcurl))
$(libiconv)-srcdir = $(pkgsrcdir)/$(libiconv)
$(libiconv)-builddir = $($(libiconv)-srcdir)
$(libiconv)-modulefile = $(modulefilesdir)/$(libiconv)
$(libiconv)-prefix = $(pkgdir)/$(libiconv)

$($(libiconv)-src): $(dir $($(libiconv)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libiconv)-srcurl)

$($(libiconv)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libiconv)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libiconv)-prefix)/.pkgunpack: $$($(libiconv)-src) $($(libiconv)-srcdir)/.markerfile $($(libiconv)-prefix)/.markerfile
	tar -C $($(libiconv)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libiconv)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libiconv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libiconv)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libiconv)-builddir),$($(libiconv)-srcdir))
$($(libiconv)-builddir)/.markerfile: $($(libiconv)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libiconv)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libiconv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libiconv)-builddir)/.markerfile $($(libiconv)-prefix)/.pkgpatch
	cd $($(libiconv)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libiconv)-builddeps) && \
		./configure --prefix=$($(libiconv)-prefix) && \
		$(MAKE)
	@touch $@

$($(libiconv)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libiconv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libiconv)-builddir)/.markerfile $($(libiconv)-prefix)/.pkgbuild
	cd $($(libiconv)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libiconv)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libiconv)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libiconv)-builddeps),$(modulefilesdir)/$$(dep)) $($(libiconv)-builddir)/.markerfile $($(libiconv)-prefix)/.pkgcheck
	cd $($(libiconv)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libiconv)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libiconv)-modulefile): $(modulefilesdir)/.markerfile $($(libiconv)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libiconv)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libiconv)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libiconv)-description)\"" >>$@
	echo "module-whatis \"$($(libiconv)-url)\"" >>$@
	printf "$(foreach prereq,$($(libiconv)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBICONV_ROOT $($(libiconv)-prefix)" >>$@
	echo "setenv LIBICONV_INCDIR $($(libiconv)-prefix)/include" >>$@
	echo "setenv LIBICONV_INCLUDEDIR $($(libiconv)-prefix)/include" >>$@
	echo "setenv LIBICONV_LIBDIR $($(libiconv)-prefix)/lib" >>$@
	echo "setenv LIBICONV_LIBRARYDIR $($(libiconv)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libiconv)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libiconv)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libiconv)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libiconv)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libiconv)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(libiconv)-prefix)/share/man" >>$@
	echo "set MSG \"$(libiconv)\"" >>$@

$(libiconv)-src: $$($(libiconv)-src)
$(libiconv)-unpack: $($(libiconv)-prefix)/.pkgunpack
$(libiconv)-patch: $($(libiconv)-prefix)/.pkgpatch
$(libiconv)-build: $($(libiconv)-prefix)/.pkgbuild
$(libiconv)-check: $($(libiconv)-prefix)/.pkgcheck
$(libiconv)-install: $($(libiconv)-prefix)/.pkginstall
$(libiconv)-modulefile: $($(libiconv)-modulefile)
$(libiconv)-clean:
	rm -rf $($(libiconv)-modulefile)
	rm -rf $($(libiconv)-prefix)
	rm -rf $($(libiconv)-builddir)
	rm -rf $($(libiconv)-srcdir)
	rm -rf $($(libiconv)-src)
$(libiconv): $(libiconv)-src $(libiconv)-unpack $(libiconv)-patch $(libiconv)-build $(libiconv)-check $(libiconv)-install $(libiconv)-modulefile
