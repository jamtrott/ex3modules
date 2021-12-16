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
# gettext-0.21

gettext-version = 0.21
gettext = gettext-$(gettext-version)
$(gettext)-description = GNU tools for multi-lingual programs
$(gettext)-url = https://www.gnu.org/software/gettext/
$(gettext)-srcurl = https://ftp.gnu.org/pub/gnu/gettext/gettext-$(gettext-version).tar.gz
$(gettext)-builddeps =
$(gettext)-prereqs =
$(gettext)-src = $(pkgsrcdir)/$(notdir $($(gettext)-srcurl))
$(gettext)-srcdir = $(pkgsrcdir)/$(gettext)
$(gettext)-builddir = $($(gettext)-srcdir)
$(gettext)-modulefile = $(modulefilesdir)/$(gettext)
$(gettext)-prefix = $(pkgdir)/$(gettext)

$($(gettext)-src): $(dir $($(gettext)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gettext)-srcurl)

$($(gettext)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gettext)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gettext)-prefix)/.pkgunpack: $$($(gettext)-src) $($(gettext)-srcdir)/.markerfile $($(gettext)-prefix)/.markerfile $$(foreach dep,$$($(gettext)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gettext)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gettext)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gettext)-builddeps),$(modulefilesdir)/$$(dep)) $($(gettext)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gettext)-builddir),$($(gettext)-srcdir))
$($(gettext)-builddir)/.markerfile: $($(gettext)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gettext)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gettext)-builddeps),$(modulefilesdir)/$$(dep)) $($(gettext)-builddir)/.markerfile $($(gettext)-prefix)/.pkgpatch
	cd $($(gettext)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gettext)-builddeps) && \
		./configure --prefix=$($(gettext)-prefix) && \
		$(MAKE)
	@touch $@

$($(gettext)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gettext)-builddeps),$(modulefilesdir)/$$(dep)) $($(gettext)-builddir)/.markerfile $($(gettext)-prefix)/.pkgbuild
	cd $($(gettext)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gettext)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(gettext)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gettext)-builddeps),$(modulefilesdir)/$$(dep)) $($(gettext)-builddir)/.markerfile $($(gettext)-prefix)/.pkgcheck
	cd $($(gettext)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gettext)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gettext)-modulefile): $(modulefilesdir)/.markerfile $($(gettext)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gettext)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gettext)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gettext)-description)\"" >>$@
	echo "module-whatis \"$($(gettext)-url)\"" >>$@
	printf "$(foreach prereq,$($(gettext)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GETTEXT_ROOT $($(gettext)-prefix)" >>$@
	echo "setenv GETTEXT_INCDIR $($(gettext)-prefix)/include" >>$@
	echo "setenv GETTEXT_INCLUDEDIR $($(gettext)-prefix)/include" >>$@
	echo "setenv GETTEXT_LIBDIR $($(gettext)-prefix)/lib" >>$@
	echo "setenv GETTEXT_LIBRARYDIR $($(gettext)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gettext)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gettext)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gettext)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gettext)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gettext)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gettext)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gettext)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gettext)-prefix)/share/info" >>$@
	echo "set MSG \"$(gettext)\"" >>$@

$(gettext)-src: $$($(gettext)-src)
$(gettext)-unpack: $($(gettext)-prefix)/.pkgunpack
$(gettext)-patch: $($(gettext)-prefix)/.pkgpatch
$(gettext)-build: $($(gettext)-prefix)/.pkgbuild
$(gettext)-check: $($(gettext)-prefix)/.pkgcheck
$(gettext)-install: $($(gettext)-prefix)/.pkginstall
$(gettext)-modulefile: $($(gettext)-modulefile)
$(gettext)-clean:
	rm -rf $($(gettext)-modulefile)
	rm -rf $($(gettext)-prefix)
	rm -rf $($(gettext)-srcdir)
	rm -rf $($(gettext)-src)
$(gettext): $(gettext)-src $(gettext)-unpack $(gettext)-patch $(gettext)-build $(gettext)-check $(gettext)-install $(gettext)-modulefile
