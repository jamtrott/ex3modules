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
# glib-2.64.1

glib-version-major = 2
glib-version-minor = 64
glib-version-patch = 1
glib-version = $(glib-version-major).$(glib-version-minor).$(glib-version-patch)
glib = glib-$(glib-version)
$(glib)-description = Core object system used in GNOME
$(glib)-url = https://developer.gnome.org/glib/
$(glib)-srcurl = https://ftp.gnome.org/pub/GNOME/sources/glib/$(glib-version-major).$(glib-version-minor)/$(glib).tar.xz
$(glib)-src = $(pkgsrcdir)/$(notdir $($(glib)-srcurl))
$(glib)-srcdir = $(pkgsrcdir)/$(glib)
$(glib)-builddeps = $(meson) $(ninja) $(libffi) $(pcre)
$(glib)-prereqs = $(libffi) $(pcre)
$(glib)-modulefile = $(modulefilesdir)/$(glib)
$(glib)-prefix = $(pkgdir)/$(glib)

$($(glib)-src): $(dir $($(glib)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(glib)-srcurl)

$($(glib)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(glib)-srcdir)/build/.markerfile: $($(glib)-srcdir)/.markerfile
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(glib)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(glib)-prefix)/.pkgunpack: $($(glib)-src) $($(glib)-srcdir)/.markerfile $($(glib)-prefix)/.markerfile
	tar -C $($(glib)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(glib)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(glib)-builddeps),$(modulefilesdir)/$$(dep)) $($(glib)-prefix)/.pkgunpack
	@touch $@

$($(glib)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(glib)-builddeps),$(modulefilesdir)/$$(dep)) $($(glib)-prefix)/.pkgpatch $($(glib)-srcdir)/build/.markerfile
	cd $($(glib)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(glib)-builddeps) && \
		meson --prefix=$($(glib)-prefix) \
			--libdir=$($(glib)-prefix)/lib \
			-Dselinux=disabled .. && \
		ninja
	@touch $@

$($(glib)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(glib)-builddeps),$(modulefilesdir)/$$(dep)) $($(glib)-prefix)/.pkgbuild
	@touch $@

$($(glib)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(glib)-builddeps),$(modulefilesdir)/$$(dep)) $($(glib)-prefix)/.pkgcheck
	cd $($(glib)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(glib)-builddeps) && \
		ninja install
	@touch $@

$($(glib)-modulefile): $(modulefilesdir)/.markerfile $($(glib)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(glib)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(glib)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(glib)-description)\"" >>$@
	echo "module-whatis \"$($(glib)-url)\"" >>$@
	printf "$(foreach prereq,$($(glib)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GLIB_ROOT $($(glib)-prefix)" >>$@
	echo "setenv GLIB_INCDIR $($(glib)-prefix)/include" >>$@
	echo "setenv GLIB_INCLUDEDIR $($(glib)-prefix)/include" >>$@
	echo "setenv GLIB_LIBDIR $($(glib)-prefix)/lib" >>$@
	echo "setenv GLIB_LIBRARYDIR $($(glib)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(glib)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(glib)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(glib)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(glib)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(glib)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(glib)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(glib)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(glib)-prefix)/share/info" >>$@
	echo "set MSG \"$(glib)\"" >>$@

$(glib)-src: $($(glib)-src)
$(glib)-unpack: $($(glib)-prefix)/.pkgunpack
$(glib)-patch: $($(glib)-prefix)/.pkgpatch
$(glib)-build: $($(glib)-prefix)/.pkgbuild
$(glib)-check: $($(glib)-prefix)/.pkgcheck
$(glib)-install: $($(glib)-prefix)/.pkginstall
$(glib)-modulefile: $($(glib)-modulefile)
$(glib)-clean:
	rm -rf $($(glib)-modulefile)
	rm -rf $($(glib)-prefix)
	rm -rf $($(glib)-srcdir)
	rm -rf $($(glib)-src)
$(glib): $(glib)-src $(glib)-unpack $(glib)-patch $(glib)-build $(glib)-check $(glib)-install $(glib)-modulefile
