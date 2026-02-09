# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# python-3.10.12

python-3.10.12-version-major = 3
python-3.10.12-version-minor = 10
python-3.10.12-version-patch = 12
python-3.10.12-version = $(python-3.10.12-version-major).$(python-3.10.12-version-minor).$(python-3.10.12-version-patch)
python-3.10.12-version-short = $(python-3.10.12-version-major).$(python-3.10.12-version-minor)
python-3.10.12 = python-$(python-3.10.12-version)
$(python-3.10.12)-description = Python programming language
$(python-3.10.12)-url = https://www.python.org/
$(python-3.10.12)-srcurl = https://www.python.org/ftp/python/$(python-3.10.12-version)/Python-$(python-3.10.12-version).tar.xz
$(python-3.10.12)-src = $(pkgsrcdir)/$(notdir $($(python-3.10.12)-srcurl))
$(python-3.10.12)-srcdir = $(pkgsrcdir)/$(python-3.10.12)
$(python-3.10.12)-builddeps = $(bzip2) $(xz) $(ncurses) $(readline) $(libffi) $(openssl) $(sqlite) $(expat)
$(python-3.10.12)-prereqs = $(bzip2) $(xz) $(ncurses) $(readline) $(libffi) $(openssl) $(sqlite) $(expat)
$(python-3.10.12)-modulefile = $(modulefilesdir)/$(python-3.10.12)
$(python-3.10.12)-prefix = $(pkgdir)/$(python-3.10.12)

$($(python-3.10.12)-src): $(dir $($(python-3.10.12)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-3.10.12)-srcurl)

$($(python-3.10.12)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-3.10.12)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-3.10.12)-prefix)/.pkgunpack: $$($(python-3.10.12)-src) $($(python-3.10.12)-srcdir)/.markerfile $($(python-3.10.12)-prefix)/.markerfile $$(foreach dep,$$($(python-3.10.12)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-3.10.12)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(python-3.10.12)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.10.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.10.12)-prefix)/.pkgunpack
# Search for sqlite in non-standard directory
	cd $($(python-3.10.12)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-3.10.12)-builddeps) && \
		sed -i -e "s|sqlite_inc_paths = \[ '/usr/include',|sqlite_inc_paths = \[ '$${SQLITE_INCLUDEDIR}', '/usr/include',|" setup.py && \
		sed -i "s|curses_includes = \[\]|curses_includes = \['$${NCURSES_INCDIR}/ncursesw'\]|" setup.py
	@touch $@

$($(python-3.10.12)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.10.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.10.12)-prefix)/.pkgpatch
# See https://bugs.python.org/issue14527 for suggestions on how to
# build with libffi in a non-standard location.
	cd $($(python-3.10.12)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-3.10.12)-builddeps) && \
		PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
		LDFLAGS=$$(pkg-config --libs-only-L libffi) \
		./configure \
			--prefix=$($(python-3.10.12)-prefix) \
			--enable-shared \
			--with-ensurepip=install \
			--with-system-ffi \
			--with-system-expat \
			$$([[ ! -z "$${OPENSSL_ROOT}" ]] && echo --with-openssl="$${OPENSSL_ROOT}") && \
		$(MAKE) LDFLAGS="-L$${NCURSES_LIBDIR} -L$${BZIP2_LIBDIR} -L$${READLINE_LIBDIR}" MAKEFLAGS=
	@touch $@

$($(python-3.10.12)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.10.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.10.12)-prefix)/.pkgbuild
	@touch $@

$($(python-3.10.12)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.10.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.10.12)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(python-3.10.12)-prefix) -C $($(python-3.10.12)-srcdir) install
	cp $($(python-3.10.12)-srcdir)/python-gdb.py $($(python-3.10.12)-prefix)/bin/python$(python-3.10.12-version-major).$(python-3.10.12-version-minor)-gdb.py
	@touch $@

$($(python-3.10.12)-modulefile): $(modulefilesdir)/.markerfile $($(python-3.10.12)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-3.10.12)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-3.10.12)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-3.10.12)-description)\"" >>$@
	echo "module-whatis \"$($(python-3.10.12)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-3.10.12)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ROOT $($(python-3.10.12)-prefix)" >>$@
	echo "setenv PYTHON_INCDIR $($(python-3.10.12)-prefix)/include" >>$@
	echo "setenv PYTHON_INCLUDEDIR $($(python-3.10.12)-prefix)/include" >>$@
	echo "setenv PYTHON_LIBDIR $($(python-3.10.12)-prefix)/lib" >>$@
	echo "setenv PYTHON_LIBRARYDIR $($(python-3.10.12)-prefix)/lib" >>$@
	echo "setenv PYTHON_VERSION $(python-3.10.12-version)" >>$@
	echo "setenv PYTHON_VERSION_SHORT $(python-3.10.12-version-short)" >>$@
	echo "setenv PYTHON_VERSION_MAJOR $(python-3.10.12-version-major)" >>$@
	echo "setenv PYTHON_VERSION_MINOR $(python-3.10.12-version-minor)" >>$@
	echo "prepend-path PATH $($(python-3.10.12)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(python-3.10.12)-prefix)/include/python$(python-3.10.12-version-major).$(python-3.10.12-version-minor)m" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(python-3.10.12)-prefix)/include/python$(python-3.10.12-version-major).$(python-3.10.12-version-minor)m" >>$@
	echo "prepend-path LIBRARY_PATH $($(python-3.10.12)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(python-3.10.12)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(python-3.10.12)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(python-3.10.12)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(python-3.10.12)-prefix)/share/info" >>$@
	echo "set MSG \"$(python-3.10.12)\"" >>$@

$(python-3.10.12)-src: $$($(python-3.10.12)-src)
$(python-3.10.12)-unpack: $($(python-3.10.12)-prefix)/.pkgunpack
$(python-3.10.12)-patch: $($(python-3.10.12)-prefix)/.pkgpatch
$(python-3.10.12)-build: $($(python-3.10.12)-prefix)/.pkgbuild
$(python-3.10.12)-check: $($(python-3.10.12)-prefix)/.pkgcheck
$(python-3.10.12)-install: $($(python-3.10.12)-prefix)/.pkginstall
$(python-3.10.12)-modulefile: $($(python-3.10.12)-modulefile)
$(python-3.10.12)-clean:
	rm -rf $($(python-3.10.12)-modulefile)
	rm -rf $($(python-3.10.12)-prefix)
	rm -rf $($(python-3.10.12)-srcdir)
	rm -rf $($(python-3.10.12)-src)
$(python-3.10.12): $(python-3.10.12)-src $(python-3.10.12)-unpack $(python-3.10.12)-patch $(python-3.10.12)-build $(python-3.10.12)-check $(python-3.10.12)-install $(python-3.10.12)-modulefile
