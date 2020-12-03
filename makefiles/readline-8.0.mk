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
# readline-8.0

readline-version = 8.0
readline = readline-$(readline-version)
$(readline)-description = Library for line editing and command history
$(readline)-url = https://tiswww.case.edu/php/chet/readline/rltop.html
$(readline)-srcurl = ftp://ftp.gnu.org/gnu/readline/readline-$(readline-version).tar.gz
$(readline)-src = $(pkgsrcdir)/$(readline).tar.gz
$(readline)-srcdir = $(pkgsrcdir)/$(readline)
$(readline)-builddeps = $(ncurses)
$(readline)-prereqs = $(ncurses)
$(readline)-modulefile = $(modulefilesdir)/$(readline)
$(readline)-prefix = $(pkgdir)/$(readline)

$($(readline)-src): $(dir $($(readline)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(readline)-srcurl)

$($(readline)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(readline)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(readline)-prefix)/.pkgunpack: $($(readline)-src) $($(readline)-srcdir)/.markerfile $($(readline)-prefix)/.markerfile
	tar -C $($(readline)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(readline)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(readline)-builddeps),$(modulefilesdir)/$$(dep)) $($(readline)-prefix)/.pkgunpack
	cd $($(readline)-srcdir) && sed -i '/MV.*old/d' Makefile.in
	cd $($(readline)-srcdir) && sed -i '/{OLDSUFF}/c:' support/shlib-install
	@touch $@

$($(readline)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(readline)-builddeps),$(modulefilesdir)/$$(dep)) $($(readline)-prefix)/.pkgpatch
	cd $($(readline)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(readline)-builddeps) && \
		./configure \
			--prefix=$($(readline)-prefix) \
			--with-curses \
			--disable-static && \
		$(MAKE) SHLIB_LIBS="-L$${NCURSES_LIBRARYDIR} -lncursesw"
	@touch $@

$($(readline)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(readline)-builddeps),$(modulefilesdir)/$$(dep)) $($(readline)-prefix)/.pkgbuild
	cd $($(readline)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(readline)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(readline)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(readline)-builddeps),$(modulefilesdir)/$$(dep)) $($(readline)-prefix)/.pkgcheck
	cd $($(readline)-srcdir) && sed -i 's/Requires.private: ncurses/Requires.private: ncursesw/' readline.pc
	$(MAKE) MAKEFLAGS= prefix=$($(readline)-prefix) -C $($(readline)-srcdir) SHLIB_LIBS="-L$${NCURSES_LIBRARYDIR} -lncursesw" install
	@touch $@

$($(readline)-modulefile): $(modulefilesdir)/.markerfile $($(readline)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(readline)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(readline)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(readline)-description)\"" >>$@
	echo "module-whatis \"$($(readline)-url)\"" >>$@
	echo "" >>$@
	echo "$(foreach prereq,$($(readline)-prereqs),$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "setenv READLINE_ROOT $($(readline)-prefix)" >>$@
	echo "setenv READLINE_INCDIR $($(readline)-prefix)/include" >>$@
	echo "setenv READLINE_INCLUDEDIR $($(readline)-prefix)/include" >>$@
	echo "setenv READLINE_LIBDIR $($(readline)-prefix)/lib" >>$@
	echo "setenv READLINE_LIBRARYDIR $($(readline)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(readline)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(readline)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(readline)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(readline)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(readline)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(readline)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(readline)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(readline)-prefix)/share/info" >>$@
	echo "set MSG \"$(readline)\"" >>$@

$(readline)-src: $($(readline)-src)
$(readline)-unpack: $($(readline)-prefix)/.pkgunpack
$(readline)-patch: $($(readline)-prefix)/.pkgpatch
$(readline)-build: $($(readline)-prefix)/.pkgbuild
$(readline)-check: $($(readline)-prefix)/.pkgcheck
$(readline)-install: $($(readline)-prefix)/.pkginstall
$(readline)-modulefile: $($(readline)-modulefile)
$(readline)-clean:
	rm -rf $($(readline)-modulefile)
	rm -rf $($(readline)-prefix)
	rm -rf $($(readline)-srcdir)
	rm -rf $($(readline)-src)
$(readline): $(readline)-src $(readline)-unpack $(readline)-patch $(readline)-build $(readline)-check $(readline)-install $(readline)-modulefile
