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
# gdb-9.2

gdb-version = 9.2
gdb = gdb-$(gdb-version)
$(gdb)-description = GNU Project debugger
$(gdb)-url = https://gdb.gnu.org
$(gdb)-srcurl = https://ftp.gnu.org/gnu/gdb/gdb-$(gdb-version).tar.xz
$(gdb)-builddeps = $(readline) $(python) $(python-six) $(texinfo) $(mpfr)
$(gdb)-prereqs =  $(readline) $(python) $(python-six) $(texinfo) $(mpfr)
$(gdb)-src = $(pkgsrcdir)/$(notdir $($(gdb)-srcurl))
$(gdb)-srcdir = $(pkgsrcdir)/$(gdb)
$(gdb)-builddir = $($(gdb)-srcdir)/build
$(gdb)-modulefile = $(modulefilesdir)/$(gdb)
$(gdb)-prefix = $(pkgdir)/$(gdb)

$($(gdb)-src): $(dir $($(gdb)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gdb)-srcurl)

$($(gdb)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gdb)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gdb)-prefix)/.pkgunpack: $($(gdb)-src) $($(gdb)-srcdir)/.markerfile $($(gdb)-prefix)/.markerfile $$(foreach dep,$$($(gdb)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gdb)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(gdb)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdb)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdb)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gdb)-builddir),$($(gdb)-srcdir))
$($(gdb)-builddir)/.markerfile: $($(gdb)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gdb)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdb)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdb)-builddir)/.markerfile $($(gdb)-prefix)/.pkgpatch
	cd $($(gdb)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gdb)-builddeps) && \
		../configure --prefix=$($(gdb)-prefix) \
			--with-system-readline \
			--with-python="$(PYTHON)" && \
		$(MAKE) LDFLAGS="$$(pkg-config --libs readline) $$(pkg-config --libs ncursesw)"
	@touch $@

$($(gdb)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdb)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdb)-builddir)/.markerfile $($(gdb)-prefix)/.pkgbuild
# 	Some tests currently fail
# 	cd $($(gdb)-builddir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(gdb)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(gdb)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdb)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdb)-builddir)/.markerfile $($(gdb)-prefix)/.pkgcheck
	cd $($(gdb)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gdb)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gdb)-modulefile): $(modulefilesdir)/.markerfile $($(gdb)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gdb)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gdb)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gdb)-description)\"" >>$@
	echo "module-whatis \"$($(gdb)-url)\"" >>$@
	printf "$(foreach prereq,$($(gdb)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GDB_ROOT $($(gdb)-prefix)" >>$@
	echo "setenv GDB_INCDIR $($(gdb)-prefix)/include" >>$@
	echo "setenv GDB_INCLUDEDIR $($(gdb)-prefix)/include" >>$@
	echo "setenv GDB_LIBDIR $($(gdb)-prefix)/lib" >>$@
	echo "setenv GDB_LIBRARYDIR $($(gdb)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gdb)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gdb)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gdb)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gdb)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gdb)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gdb)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gdb)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gdb)-prefix)/share/info" >>$@
	echo "set MSG \"$(gdb)\"" >>$@

$(gdb)-src: $($(gdb)-src)
$(gdb)-unpack: $($(gdb)-prefix)/.pkgunpack
$(gdb)-patch: $($(gdb)-prefix)/.pkgpatch
$(gdb)-build: $($(gdb)-prefix)/.pkgbuild
$(gdb)-check: $($(gdb)-prefix)/.pkgcheck
$(gdb)-install: $($(gdb)-prefix)/.pkginstall
$(gdb)-modulefile: $($(gdb)-modulefile)
$(gdb)-clean:
	rm -rf $($(gdb)-modulefile)
	rm -rf $($(gdb)-prefix)
	rm -rf $($(gdb)-srcdir)
	rm -rf $($(gdb)-src)
$(gdb): $(gdb)-src $(gdb)-unpack $(gdb)-patch $(gdb)-build $(gdb)-check $(gdb)-install $(gdb)-modulefile
