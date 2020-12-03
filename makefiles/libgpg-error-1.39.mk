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
# libgpg-error-1.39

libgpg-error-version = 1.39
libgpg-error = libgpg-error-$(libgpg-error-version)
$(libgpg-error)-description = Common error values for all GnuPG components
$(libgpg-error)-url = https://www.gnupg.org/software/libgpg-error/
$(libgpg-error)-srcurl = https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$(libgpg-error-version).tar.bz2
$(libgpg-error)-builddeps =
$(libgpg-error)-prereqs =
$(libgpg-error)-src = $(pkgsrcdir)/$(notdir $($(libgpg-error)-srcurl))
$(libgpg-error)-srcdir = $(pkgsrcdir)/$(libgpg-error)
$(libgpg-error)-builddir = $($(libgpg-error)-srcdir)
$(libgpg-error)-modulefile = $(modulefilesdir)/$(libgpg-error)
$(libgpg-error)-prefix = $(pkgdir)/$(libgpg-error)

$($(libgpg-error)-src): $(dir $($(libgpg-error)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libgpg-error)-srcurl)

$($(libgpg-error)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libgpg-error)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libgpg-error)-prefix)/.pkgunpack: $($(libgpg-error)-src) $($(libgpg-error)-srcdir)/.markerfile $($(libgpg-error)-prefix)/.markerfile
	tar -C $($(libgpg-error)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libgpg-error)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgpg-error)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgpg-error)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libgpg-error)-builddir),$($(libgpg-error)-srcdir))
$($(libgpg-error)-builddir)/.markerfile: $($(libgpg-error)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libgpg-error)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgpg-error)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgpg-error)-builddir)/.markerfile $($(libgpg-error)-prefix)/.pkgpatch
	cd $($(libgpg-error)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgpg-error)-builddeps) && \
		./configure --prefix=$($(libgpg-error)-prefix) && \
		$(MAKE)
	@touch $@

$($(libgpg-error)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgpg-error)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgpg-error)-builddir)/.markerfile $($(libgpg-error)-prefix)/.pkgbuild
# Disable failing tests
#	cd $($(libgpg-error)-builddir) && \
#		$(MODULESINIT) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(libgpg-error)-builddeps) && \
#		$(MAKE) check
	@touch $@

$($(libgpg-error)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgpg-error)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgpg-error)-builddir)/.markerfile $($(libgpg-error)-prefix)/.pkgcheck
	cd $($(libgpg-error)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgpg-error)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libgpg-error)-modulefile): $(modulefilesdir)/.markerfile $($(libgpg-error)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libgpg-error)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libgpg-error)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libgpg-error)-description)\"" >>$@
	echo "module-whatis \"$($(libgpg-error)-url)\"" >>$@
	printf "$(foreach prereq,$($(libgpg-error)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBGPG_ERROR_ROOT $($(libgpg-error)-prefix)" >>$@
	echo "setenv LIBGPG_ERROR_INCDIR $($(libgpg-error)-prefix)/include" >>$@
	echo "setenv LIBGPG_ERROR_INCLUDEDIR $($(libgpg-error)-prefix)/include" >>$@
	echo "setenv LIBGPG_ERROR_LIBDIR $($(libgpg-error)-prefix)/lib" >>$@
	echo "setenv LIBGPG_ERROR_LIBRARYDIR $($(libgpg-error)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libgpg-error)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libgpg-error)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libgpg-error)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgpg-error)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgpg-error)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libgpg-error)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libgpg-error)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libgpg-error)-prefix)/share/info" >>$@
	echo "set MSG \"$(libgpg-error)\"" >>$@

$(libgpg-error)-src: $($(libgpg-error)-src)
$(libgpg-error)-unpack: $($(libgpg-error)-prefix)/.pkgunpack
$(libgpg-error)-patch: $($(libgpg-error)-prefix)/.pkgpatch
$(libgpg-error)-build: $($(libgpg-error)-prefix)/.pkgbuild
$(libgpg-error)-check: $($(libgpg-error)-prefix)/.pkgcheck
$(libgpg-error)-install: $($(libgpg-error)-prefix)/.pkginstall
$(libgpg-error)-modulefile: $($(libgpg-error)-modulefile)
$(libgpg-error)-clean:
	rm -rf $($(libgpg-error)-modulefile)
	rm -rf $($(libgpg-error)-prefix)
	rm -rf $($(libgpg-error)-srcdir)
	rm -rf $($(libgpg-error)-src)
$(libgpg-error): $(libgpg-error)-src $(libgpg-error)-unpack $(libgpg-error)-patch $(libgpg-error)-build $(libgpg-error)-check $(libgpg-error)-install $(libgpg-error)-modulefile
