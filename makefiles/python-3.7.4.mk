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
# python-3.7.4

python-version-major = 3
python-version-minor = 7
python-version-patch = 4
python-version = $(python-version-major).$(python-version-minor).$(python-version-patch)
python-version-short = $(python-version-major).$(python-version-minor)
python = python-$(python-version)
$(python)-description = Python programming language
$(python)-url = https://www.python.org/
$(python)-srcurl = https://www.python.org/ftp/python/$(python-version)/Python-$(python-version).tar.xz
$(python)-src = $(pkgsrcdir)/$(notdir $($(python)-srcurl))
$(python)-srcdir = $(pkgsrcdir)/$(python)
$(python)-builddeps = $(bzip2) $(xz) $(ncurses) $(readline) $(libffi) $(openssl) $(sqlite) $(expat)
$(python)-prereqs = $(bzip2) $(xz) $(ncurses) $(readline) $(libffi) $(openssl) $(sqlite) $(expat)
$(python)-modulefile = $(modulefilesdir)/$(python)
$(python)-prefix = $(pkgdir)/$(python)

$($(python)-src): $(dir $($(python)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python)-srcurl)

$($(python)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python)-prefix)/.pkgunpack: $($(python)-src) $($(python)-srcdir)/.markerfile $($(python)-prefix)/.markerfile
	tar -C $($(python)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(python)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python)-builddeps),$(modulefilesdir)/$$(dep)) $($(python)-prefix)/.pkgunpack
# Search for sqlite in non-standard directory
	cd $($(python)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python)-builddeps) && \
		sed -i -e "s|sqlite_inc_paths = \[ '/usr/include',|sqlite_inc_paths = \[ '$${SQLITE_INCLUDEDIR}', '/usr/include',|" setup.py && \
		sed -i "s|curses_includes = \[\]|curses_includes = \['$${NCURSES_INCDIR}/ncursesw'\]|" setup.py
	@touch $@

$($(python)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python)-builddeps),$(modulefilesdir)/$$(dep)) $($(python)-prefix)/.pkgpatch
# See https://bugs.python.org/issue14527 for suggestions on how to
# build with libffi in a non-standard location.
	cd $($(python)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python)-builddeps) && \
		PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 \
		LDFLAGS=$$(pkg-config --libs-only-L libffi) \
		./configure \
			--prefix=$($(python)-prefix) \
			--enable-shared \
			--with-ensurepip=install \
			--with-system-ffi \
			--with-system-expat \
			--with-openssl=$${OPENSSL_ROOT} && \
		$(MAKE) LDFLAGS="-L$${NCURSES_LIBDIR} -L$${BZIP2_LIBDIR} -L$${READLINE_LIBDIR}" MAKEFLAGS=
	@touch $@

$($(python)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python)-builddeps),$(modulefilesdir)/$$(dep)) $($(python)-prefix)/.pkgbuild
	@touch $@

$($(python)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python)-builddeps),$(modulefilesdir)/$$(dep)) $($(python)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(python)-prefix) -C $($(python)-srcdir) install
	@touch $@

$($(python)-modulefile): $(modulefilesdir)/.markerfile $($(python)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python)-description)\"" >>$@
	echo "module-whatis \"$($(python)-url)\"" >>$@
	printf "$(foreach prereq,$($(python)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ROOT $($(python)-prefix)" >>$@
	echo "setenv PYTHON_INCDIR $($(python)-prefix)/include" >>$@
	echo "setenv PYTHON_INCLUDEDIR $($(python)-prefix)/include" >>$@
	echo "setenv PYTHON_LIBDIR $($(python)-prefix)/lib" >>$@
	echo "setenv PYTHON_LIBRARYDIR $($(python)-prefix)/lib" >>$@
	echo "setenv PYTHON_VERSION $(python-version)" >>$@
	echo "setenv PYTHON_VERSION_SHORT $(python-version-short)" >>$@
	echo "prepend-path PATH $($(python)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(python)-prefix)/include/python$(python-version-major).$(python-version-minor)m" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(python)-prefix)/include/python$(python-version-major).$(python-version-minor)m" >>$@
	echo "prepend-path LIBRARY_PATH $($(python)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(python)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(python)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(python)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(python)-prefix)/share/info" >>$@
	echo "set MSG \"$(python)\"" >>$@

$(python)-src: $($(python)-src)
$(python)-unpack: $($(python)-prefix)/.pkgunpack
$(python)-patch: $($(python)-prefix)/.pkgpatch
$(python)-build: $($(python)-prefix)/.pkgbuild
$(python)-check: $($(python)-prefix)/.pkgcheck
$(python)-install: $($(python)-prefix)/.pkginstall
$(python)-modulefile: $($(python)-modulefile)
$(python)-clean:
	rm -rf $($(python)-modulefile)
	rm -rf $($(python)-prefix)
	rm -rf $($(python)-srcdir)
	rm -rf $($(python)-src)
$(python): $(python)-src $(python)-unpack $(python)-patch $(python)-build $(python)-check $(python)-install $(python)-modulefile
