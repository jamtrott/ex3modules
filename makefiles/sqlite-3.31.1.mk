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
# sqlite-3.31.1

sqlite-version = 3.31.1
sqlite = sqlite-$(sqlite-version)
$(sqlite)-description = Small, fast, self-contained, high-reliability, full-featured, SQL database engine
$(sqlite)-url = https://www.sqlite.org/index.html
$(sqlite)-srcurl = https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
$(sqlite)-src = $(pkgsrcdir)/sqlite-autoconf-3310100.tar.gz
$(sqlite)-srcdir = $(pkgsrcdir)/sqlite-autoconf-3310100
$(sqlite)-builddeps =
$(sqlite)-prereqs =
$(sqlite)-modulefile = $(modulefilesdir)/$(sqlite)
$(sqlite)-prefix = $(pkgdir)/$(sqlite)

$($(sqlite)-src): $(dir $($(sqlite)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(sqlite)-srcurl)

$($(sqlite)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(sqlite)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(sqlite)-prefix)/.pkgunpack: $($(sqlite)-src) $($(sqlite)-srcdir)/.markerfile $($(sqlite)-prefix)/.markerfile $$(foreach dep,$$($(sqlite)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(sqlite)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(sqlite)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sqlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(sqlite)-prefix)/.pkgunpack
	@touch $@

$($(sqlite)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sqlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(sqlite)-prefix)/.pkgpatch
	cd $($(sqlite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sqlite)-builddeps) && \
		./configure --prefix=$($(sqlite)-prefix) && \
		$(MAKE) MAKEFLAGS=
	@touch $@

$($(sqlite)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sqlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(sqlite)-prefix)/.pkgbuild
	cd $($(sqlite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sqlite)-builddeps) && \
		$(MAKE) MAKEFLAGS= check
	@touch $@

$($(sqlite)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sqlite)-builddeps),$(modulefilesdir)/$$(dep)) $($(sqlite)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= -C $($(sqlite)-srcdir) install
	@touch $@

$($(sqlite)-modulefile): $(modulefilesdir)/.markerfile $($(sqlite)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(sqlite)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(sqlite)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(sqlite)-description)\"" >>$@
	echo "module-whatis \"$($(sqlite)-url)\"" >>$@
	echo "" >>$@
	echo "$(foreach prereq,$($(sqlite)-prereqs),$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "setenv SQLITE_ROOT $($(sqlite)-prefix)" >>$@
	echo "setenv SQLITE_INCDIR $($(sqlite)-prefix)/include" >>$@
	echo "setenv SQLITE_INCLUDEDIR $($(sqlite)-prefix)/include" >>$@
	echo "setenv SQLITE_LIBDIR $($(sqlite)-prefix)/lib" >>$@
	echo "setenv SQLITE_LIBRARYDIR $($(sqlite)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(sqlite)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(sqlite)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(sqlite)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(sqlite)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(sqlite)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(sqlite)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(sqlite)-prefix)/share/man" >>$@
	echo "set MSG \"$(sqlite)\"" >>$@

$(sqlite)-src: $($(sqlite)-src)
$(sqlite)-unpack: $($(sqlite)-prefix)/.pkgunpack
$(sqlite)-patch: $($(sqlite)-prefix)/.pkgpatch
$(sqlite)-build: $($(sqlite)-prefix)/.pkgbuild
$(sqlite)-check: $($(sqlite)-prefix)/.pkgcheck
$(sqlite)-install: $($(sqlite)-prefix)/.pkginstall
$(sqlite)-modulefile: $($(sqlite)-modulefile)
$(sqlite)-clean:
	rm -rf $($(sqlite)-modulefile)
	rm -rf $($(sqlite)-prefix)
	rm -rf $($(sqlite)-srcdir)
	rm -rf $($(sqlite)-src)
$(sqlite): $(sqlite)-src $(sqlite)-unpack $(sqlite)-patch $(sqlite)-build $(sqlite)-check $(sqlite)-install $(sqlite)-modulefile
