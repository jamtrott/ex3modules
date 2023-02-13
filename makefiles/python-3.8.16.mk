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
# python-3.8.16

python-3.8.16-version-major = 3
python-3.8.16-version-minor = 8
python-3.8.16-version-patch = 16
python-3.8.16-version = $(python-3.8.16-version-major).$(python-3.8.16-version-minor).$(python-3.8.16-version-patch)
python-3.8.16-version-short = $(python-3.8.16-version-major).$(python-3.8.16-version-minor)
python-3.8.16 = python-$(python-3.8.16-version)
$(python-3.8.16)-description = Python programming language
$(python-3.8.16)-url = https://www.python.org/
$(python-3.8.16)-srcurl = https://www.python.org/ftp/python/$(python-3.8.16-version)/Python-$(python-3.8.16-version).tar.xz
$(python-3.8.16)-src = $(pkgsrcdir)/$(notdir $($(python-3.8.16)-srcurl))
$(python-3.8.16)-srcdir = $(pkgsrcdir)/$(python-3.8.16)
$(python-3.8.16)-builddeps = $(bzip2) $(xz) $(ncurses) $(readline) $(libffi) $(openssl) $(sqlite) $(expat)
$(python-3.8.16)-prereqs = $(bzip2) $(xz) $(ncurses) $(readline) $(libffi) $(openssl) $(sqlite) $(expat)
$(python-3.8.16)-modulefile = $(modulefilesdir)/$(python-3.8.16)
$(python-3.8.16)-prefix = $(pkgdir)/$(python-3.8.16)

$($(python-3.8.16)-src): $(dir $($(python-3.8.16)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-3.8.16)-srcurl)

$($(python-3.8.16)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-3.8.16)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-3.8.16)-prefix)/.pkgunpack: $$($(python-3.8.16)-src) $($(python-3.8.16)-srcdir)/.markerfile $($(python-3.8.16)-prefix)/.markerfile $$(foreach dep,$$($(python-3.8.16)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-3.8.16)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(python-3.8.16)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.8.16)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.8.16)-prefix)/.pkgunpack
# Search for sqlite in non-standard directory
	cd $($(python-3.8.16)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-3.8.16)-builddeps) && \
		sed -i -e "s|sqlite_inc_paths = \[ '/usr/include',|sqlite_inc_paths = \[ '$${SQLITE_INCLUDEDIR}', '/usr/include',|" setup.py && \
		sed -i "s|curses_includes = \[\]|curses_includes = \['$${NCURSES_INCDIR}/ncursesw'\]|" setup.py
	@touch $@

$($(python-3.8.16)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.8.16)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.8.16)-prefix)/.pkgpatch
# See https://bugs.python.org/issue14527 for suggestions on how to
# build with libffi in a non-standard location.
	cd $($(python-3.8.16)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-3.8.16)-builddeps) && \
		PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
		LDFLAGS=$$(pkg-config --libs-only-L libffi) \
		./configure \
			--prefix=$($(python-3.8.16)-prefix) \
			--enable-shared \
			--with-ensurepip=install \
			--with-system-ffi \
			--with-system-expat \
			$$([[ ! -z "$${OPENSSL_ROOT}" ]] && echo --with-openssl="$${OPENSSL_ROOT}") && \
		$(MAKE) LDFLAGS="-L$${NCURSES_LIBDIR} -L$${BZIP2_LIBDIR} -L$${READLINE_LIBDIR}" MAKEFLAGS=
	@touch $@

$($(python-3.8.16)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.8.16)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.8.16)-prefix)/.pkgbuild
	@touch $@

$($(python-3.8.16)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-3.8.16)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-3.8.16)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(python-3.8.16)-prefix) -C $($(python-3.8.16)-srcdir) install
	cp $($(python-3.8.16)-srcdir)/python-gdb.py $($(python-3.8.16)-prefix)/bin/python$(python-3.8.16-version-major).$(python-3.8.16-version-minor)-gdb.py
	@touch $@

$($(python-3.8.16)-modulefile): $(modulefilesdir)/.markerfile $($(python-3.8.16)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-3.8.16)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-3.8.16)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-3.8.16)-description)\"" >>$@
	echo "module-whatis \"$($(python-3.8.16)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-3.8.16)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ROOT $($(python-3.8.16)-prefix)" >>$@
	echo "setenv PYTHON_INCDIR $($(python-3.8.16)-prefix)/include" >>$@
	echo "setenv PYTHON_INCLUDEDIR $($(python-3.8.16)-prefix)/include" >>$@
	echo "setenv PYTHON_LIBDIR $($(python-3.8.16)-prefix)/lib" >>$@
	echo "setenv PYTHON_LIBRARYDIR $($(python-3.8.16)-prefix)/lib" >>$@
	echo "setenv PYTHON_VERSION $(python-3.8.16-version)" >>$@
	echo "setenv PYTHON_VERSION_SHORT $(python-3.8.16-version-short)" >>$@
	echo "setenv PYTHON_VERSION_MAJOR $(python-3.8.16-version-major)" >>$@
	echo "setenv PYTHON_VERSION_MINOR $(python-3.8.16-version-minor)" >>$@
	echo "prepend-path PATH $($(python-3.8.16)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(python-3.8.16)-prefix)/include/python$(python-3.8.16-version-major).$(python-3.8.16-version-minor)m" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(python-3.8.16)-prefix)/include/python$(python-3.8.16-version-major).$(python-3.8.16-version-minor)m" >>$@
	echo "prepend-path LIBRARY_PATH $($(python-3.8.16)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(python-3.8.16)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(python-3.8.16)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(python-3.8.16)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(python-3.8.16)-prefix)/share/info" >>$@
	echo "set MSG \"$(python-3.8.16)\"" >>$@

$(python-3.8.16)-src: $$($(python-3.8.16)-src)
$(python-3.8.16)-unpack: $($(python-3.8.16)-prefix)/.pkgunpack
$(python-3.8.16)-patch: $($(python-3.8.16)-prefix)/.pkgpatch
$(python-3.8.16)-build: $($(python-3.8.16)-prefix)/.pkgbuild
$(python-3.8.16)-check: $($(python-3.8.16)-prefix)/.pkgcheck
$(python-3.8.16)-install: $($(python-3.8.16)-prefix)/.pkginstall
$(python-3.8.16)-modulefile: $($(python-3.8.16)-modulefile)
$(python-3.8.16)-clean:
	rm -rf $($(python-3.8.16)-modulefile)
	rm -rf $($(python-3.8.16)-prefix)
	rm -rf $($(python-3.8.16)-srcdir)
	rm -rf $($(python-3.8.16)-src)
$(python-3.8.16): $(python-3.8.16)-src $(python-3.8.16)-unpack $(python-3.8.16)-patch $(python-3.8.16)-build $(python-3.8.16)-check $(python-3.8.16)-install $(python-3.8.16)-modulefile
