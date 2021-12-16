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
# hunspell-1.7.0

hunspell-version = 1.7.0
hunspell = hunspell-$(hunspell-version)
$(hunspell)-description = Spell checker and morphological analyzer
$(hunspell)-url = https://hunspell.github.io/
$(hunspell)-srcurl = https://github.com/hunspell/hunspell/files/2573619/hunspell-$(hunspell-version).tar.gz
$(hunspell)-builddeps = $(autoconf) $(automake) $(libtool) $(libiconv) $(ncurses) $(readline) $(gettext)
$(hunspell)-prereqs = $(libiconv) $(ncurses) $(readline) $(gettext)
$(hunspell)-src = $(pkgsrcdir)/$(notdir $($(hunspell)-srcurl))
$(hunspell)-srcdir = $(pkgsrcdir)/$(hunspell)
$(hunspell)-builddir = $($(hunspell)-srcdir)
$(hunspell)-modulefile = $(modulefilesdir)/$(hunspell)
$(hunspell)-prefix = $(pkgdir)/$(hunspell)

$($(hunspell)-src): $(dir $($(hunspell)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hunspell)-srcurl)

$($(hunspell)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hunspell)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hunspell)-prefix)/.pkgunpack: $$($(hunspell)-src) $($(hunspell)-srcdir)/.markerfile $($(hunspell)-prefix)/.markerfile $$(foreach dep,$$($(hunspell)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hunspell)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hunspell)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hunspell)-builddeps),$(modulefilesdir)/$$(dep)) $($(hunspell)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(hunspell)-builddir),$($(hunspell)-srcdir))
$($(hunspell)-builddir)/.markerfile: $($(hunspell)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(hunspell)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hunspell)-builddeps),$(modulefilesdir)/$$(dep)) $($(hunspell)-builddir)/.markerfile $($(hunspell)-prefix)/.pkgpatch
	cd $($(hunspell)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hunspell)-builddeps) && \
		./configure --prefix=$($(hunspell)-prefix) && \
		$(MAKE)
	@touch $@

$($(hunspell)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hunspell)-builddeps),$(modulefilesdir)/$$(dep)) $($(hunspell)-builddir)/.markerfile $($(hunspell)-prefix)/.pkgbuild
	cd $($(hunspell)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hunspell)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hunspell)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hunspell)-builddeps),$(modulefilesdir)/$$(dep)) $($(hunspell)-builddir)/.markerfile $($(hunspell)-prefix)/.pkgcheck
	cd $($(hunspell)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hunspell)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hunspell)-modulefile): $(modulefilesdir)/.markerfile $($(hunspell)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hunspell)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hunspell)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hunspell)-description)\"" >>$@
	echo "module-whatis \"$($(hunspell)-url)\"" >>$@
	printf "$(foreach prereq,$($(hunspell)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HUNSPELL_ROOT $($(hunspell)-prefix)" >>$@
	echo "setenv HUNSPELL_INCDIR $($(hunspell)-prefix)/include" >>$@
	echo "setenv HUNSPELL_INCLUDEDIR $($(hunspell)-prefix)/include" >>$@
	echo "setenv HUNSPELL_LIBDIR $($(hunspell)-prefix)/lib" >>$@
	echo "setenv HUNSPELL_LIBRARYDIR $($(hunspell)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hunspell)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hunspell)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hunspell)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hunspell)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hunspell)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(hunspell)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(hunspell)-prefix)/share/man" >>$@
	echo "set MSG \"$(hunspell)\"" >>$@

$(hunspell)-src: $$($(hunspell)-src)
$(hunspell)-unpack: $($(hunspell)-prefix)/.pkgunpack
$(hunspell)-patch: $($(hunspell)-prefix)/.pkgpatch
$(hunspell)-build: $($(hunspell)-prefix)/.pkgbuild
$(hunspell)-check: $($(hunspell)-prefix)/.pkgcheck
$(hunspell)-install: $($(hunspell)-prefix)/.pkginstall
$(hunspell)-modulefile: $($(hunspell)-modulefile)
$(hunspell)-clean:
	rm -rf $($(hunspell)-modulefile)
	rm -rf $($(hunspell)-prefix)
	rm -rf $($(hunspell)-builddir)
	rm -rf $($(hunspell)-srcdir)
	rm -rf $($(hunspell)-src)
$(hunspell): $(hunspell)-src $(hunspell)-unpack $(hunspell)-patch $(hunspell)-build $(hunspell)-check $(hunspell)-install $(hunspell)-modulefile
