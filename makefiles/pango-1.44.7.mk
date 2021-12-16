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
# pango-1.44.7

pango-version = 1.44.7
pango = pango-$(pango-version)
$(pango)-description = Library for laying out and rendering of text
$(pango)-url = https://pango.gnome.org/
$(pango)-srcurl = http://ftp.gnome.org/pub/GNOME/sources/pango/1.44/pango-$(pango-version).tar.xz
$(pango)-src = $(pkgsrcdir)/$(notdir $($(pango)-srcurl))
$(pango)-srcdir = $(pkgsrcdir)/$(pango)
$(pango)-builddir = $($(pango)-srcdir)/build
$(pango)-builddeps = $(meson) $(ninja) $(cmake) $(libffi) $(harfbuzz-graphite) $(fontconfig) $(freetype) $(cairo) $(glib) $(gobject-introspection) $(fribidi)
$(pango)-prereqs = $(libffi) $(harfbuzz-graphite) $(fontconfig) $(freetype) $(cairo) $(glib) $(gobject-introspection) $(fribidi)
$(pango)-modulefile = $(modulefilesdir)/$(pango)
$(pango)-prefix = $(pkgdir)/$(pango)

$($(pango)-src): $(dir $($(pango)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pango)-srcurl)

$($(pango)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pango)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pango)-prefix)/.pkgunpack: $($(pango)-src) $($(pango)-srcdir)/.markerfile $($(pango)-prefix)/.markerfile $$(foreach dep,$$($(pango)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(pango)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(pango)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pango)-builddeps),$(modulefilesdir)/$$(dep)) $($(pango)-prefix)/.pkgunpack
	@touch $@

$($(pango)-builddir)/.markerfile: $($(pango)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(pango)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pango)-builddeps),$(modulefilesdir)/$$(dep)) $($(pango)-prefix)/.pkgpatch $($(pango)-builddir)/.markerfile
	cd $($(pango)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pango)-builddeps) && \
		meson .. --prefix=$($(pango)-prefix) \
			--libdir=$($(pango)-prefix)/lib \
			--sysconfdir=$($(pango)-prefix)/etc && \
		ninja
	@touch $@

$($(pango)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pango)-builddeps),$(modulefilesdir)/$$(dep)) $($(pango)-prefix)/.pkgbuild $($(pango)-builddir)/.markerfile
	@touch $@

$($(pango)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pango)-builddeps),$(modulefilesdir)/$$(dep)) $($(pango)-prefix)/.pkgcheck $($(pango)-builddir)/.markerfile
	cd $($(pango)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pango)-builddeps) && \
		ninja install
	@touch $@

$($(pango)-modulefile): $(modulefilesdir)/.markerfile $($(pango)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pango)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pango)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pango)-description)\"" >>$@
	echo "module-whatis \"$($(pango)-url)\"" >>$@
	printf "$(foreach prereq,$($(pango)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PANGO_ROOT $($(pango)-prefix)" >>$@
	echo "setenv PANGO_INCDIR $($(pango)-prefix)/include" >>$@
	echo "setenv PANGO_INCLUDEDIR $($(pango)-prefix)/include" >>$@
	echo "setenv PANGO_LIBDIR $($(pango)-prefix)/lib" >>$@
	echo "setenv PANGO_LIBRARYDIR $($(pango)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pango)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pango)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pango)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pango)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pango)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pango)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pango)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(pango)-prefix)/share/info" >>$@
	echo "set MSG \"$(pango)\"" >>$@

$(pango)-src: $($(pango)-src)
$(pango)-unpack: $($(pango)-prefix)/.pkgunpack
$(pango)-patch: $($(pango)-prefix)/.pkgpatch
$(pango)-build: $($(pango)-prefix)/.pkgbuild
$(pango)-check: $($(pango)-prefix)/.pkgcheck
$(pango)-install: $($(pango)-prefix)/.pkginstall
$(pango)-modulefile: $($(pango)-modulefile)
$(pango)-clean:
	rm -rf $($(pango)-modulefile)
	rm -rf $($(pango)-prefix)
	rm -rf $($(pango)-srcdir)
	rm -rf $($(pango)-src)
$(pango): $(pango)-src $(pango)-unpack $(pango)-patch $(pango)-build $(pango)-check $(pango)-install $(pango)-modulefile
