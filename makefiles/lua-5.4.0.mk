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
# lua-5.4.0

lua-version = 5.4.0
lua = lua-$(lua-version)
$(lua)-description = Lua programming language
$(lua)-url = https://www.lua.org/
$(lua)-srcurl = https://www.lua.org/ftp/lua-5.4.0.tar.gz
$(lua)-builddeps =
$(lua)-prereqs =
$(lua)-src = $(pkgsrcdir)/$(notdir $($(lua)-srcurl))
$(lua)-srcdir = $(pkgsrcdir)/$(lua)
$(lua)-builddir = $($(lua)-srcdir)/build
$(lua)-modulefile = $(modulefilesdir)/$(lua)
$(lua)-prefix = $(pkgdir)/$(lua)

$($(lua)-src): $(dir $($(lua)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(lua)-srcurl)

$($(lua)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(lua)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(lua)-prefix)/.pkgunpack: $$($(lua)-src) $($(lua)-srcdir)/.markerfile $($(lua)-prefix)/.markerfile $$(foreach dep,$$($(lua)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(lua)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(lua)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lua)-builddeps),$(modulefilesdir)/$$(dep)) $($(lua)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(lua)-builddir),$($(lua)-srcdir))
$($(lua)-builddir)/.markerfile: $($(lua)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(lua)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lua)-builddeps),$(modulefilesdir)/$$(dep)) $($(lua)-builddir)/.markerfile $($(lua)-prefix)/.pkgpatch
	cd $($(lua)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(lua)-builddeps) && \
		$(MAKE) -C .. MYCFLAGS="-fPIC"
	@touch $@

$($(lua)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lua)-builddeps),$(modulefilesdir)/$$(dep)) $($(lua)-builddir)/.markerfile $($(lua)-prefix)/.pkgbuild
	@touch $@

$($(lua)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lua)-builddeps),$(modulefilesdir)/$$(dep)) $($(lua)-builddir)/.markerfile $($(lua)-prefix)/.pkgcheck
	cd $($(lua)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(lua)-builddeps) && \
		$(MAKE) -C .. INSTALL_TOP=$($(lua)-prefix) install
	@touch $@

$($(lua)-modulefile): $(modulefilesdir)/.markerfile $($(lua)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(lua)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(lua)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(lua)-description)\"" >>$@
	echo "module-whatis \"$($(lua)-url)\"" >>$@
	printf "$(foreach prereq,$($(lua)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LUA_DIR $($(lua)-prefix)" >>$@
	echo "setenv LUA_ROOT $($(lua)-prefix)" >>$@
	echo "setenv LUA_INCDIR $($(lua)-prefix)/include" >>$@
	echo "setenv LUA_INCLUDEDIR $($(lua)-prefix)/include" >>$@
	echo "setenv LUA_LIBDIR $($(lua)-prefix)/lib" >>$@
	echo "setenv LUA_LIBRARYDIR $($(lua)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(lua)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(lua)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(lua)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(lua)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(lua)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(lua)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(lua)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(lua)-prefix)/share/info" >>$@
	echo "set MSG \"$(lua)\"" >>$@

$(lua)-src: $$($(lua)-src)
$(lua)-unpack: $($(lua)-prefix)/.pkgunpack
$(lua)-patch: $($(lua)-prefix)/.pkgpatch
$(lua)-build: $($(lua)-prefix)/.pkgbuild
$(lua)-check: $($(lua)-prefix)/.pkgcheck
$(lua)-install: $($(lua)-prefix)/.pkginstall
$(lua)-modulefile: $($(lua)-modulefile)
$(lua)-clean:
	rm -rf $($(lua)-modulefile)
	rm -rf $($(lua)-prefix)
	rm -rf $($(lua)-builddir)
	rm -rf $($(lua)-srcdir)
	rm -rf $($(lua)-src)
$(lua): $(lua)-src $(lua)-unpack $(lua)-patch $(lua)-build $(lua)-check $(lua)-install $(lua)-modulefile
