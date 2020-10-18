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
# gobject-introspection-1.64.0

gobject-introspection-version = 1.64.0
gobject-introspection = gobject-introspection-$(gobject-introspection-version)
$(gobject-introspection)-description = Middleware layer between C libraries (using GObject) and language bindings
$(gobject-introspection)-url = https://gi.readthedocs.io/
$(gobject-introspection)-srcurl = http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.64/gobject-introspection-$(gobject-introspection-version).tar.xz
$(gobject-introspection)-src = $(pkgsrcdir)/$(notdir $($(gobject-introspection)-srcurl))
$(gobject-introspection)-srcdir = $(pkgsrcdir)/$(gobject-introspection)
$(gobject-introspection)-builddeps = $(meson) $(ninja) $(glib) $(libffi) $(pcre)
$(gobject-introspection)-prereqs = $(glib) $(libffi) $(pcre)
$(gobject-introspection)-modulefile = $(modulefilesdir)/$(gobject-introspection)
$(gobject-introspection)-prefix = $(pkgdir)/$(gobject-introspection)

$($(gobject-introspection)-src): $(dir $($(gobject-introspection)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gobject-introspection)-srcurl)

$($(gobject-introspection)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(gobject-introspection)-srcdir)/build/.markerfile: $($(gobject-introspection)-srcdir)/.markerfile
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(gobject-introspection)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(gobject-introspection)-prefix)/.pkgunpack: $($(gobject-introspection)-src) $($(gobject-introspection)-srcdir)/.markerfile $($(gobject-introspection)-prefix)/.markerfile
	tar -C $($(gobject-introspection)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(gobject-introspection)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gobject-introspection)-builddeps),$(modulefilesdir)/$$(dep)) $($(gobject-introspection)-prefix)/.pkgunpack
	@touch $@

$($(gobject-introspection)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gobject-introspection)-builddeps),$(modulefilesdir)/$$(dep)) $($(gobject-introspection)-prefix)/.pkgpatch $($(gobject-introspection)-srcdir)/build/.markerfile
	cd $($(gobject-introspection)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gobject-introspection)-builddeps) && \
		meson --prefix=$($(gobject-introspection)-prefix) \
			 --libdir=$($(gobject-introspection)-prefix)/lib \
			.. && \
		ninja
	@touch $@

$($(gobject-introspection)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gobject-introspection)-builddeps),$(modulefilesdir)/$$(dep)) $($(gobject-introspection)-prefix)/.pkgbuild $($(gobject-introspection)-srcdir)/build/.markerfile
	@touch $@

$($(gobject-introspection)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gobject-introspection)-builddeps),$(modulefilesdir)/$$(dep)) $($(gobject-introspection)-prefix)/.pkgcheck $($(gobject-introspection)-srcdir)/build/.markerfile
	$(INSTALL) -m=6755 -d $($(gobject-introspection)-prefix)/lib/gobject-introspection/giscanner/doctemplates/mallard/Python
	$(INSTALL) -m=6755 -d $($(gobject-introspection)-prefix)/lib/gobject-introspection/giscanner/doctemplates/mallard/Gjs
	$(INSTALL) -m=6755 -d $($(gobject-introspection)-prefix)/lib/gobject-introspection/giscanner/doctemplates/mallard/C
	$(INSTALL) -m=6755 -d $($(gobject-introspection)-prefix)/lib/gobject-introspection/giscanner/doctemplates/devdocs/Gjs
	cd $($(gobject-introspection)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gobject-introspection)-builddeps) && \
		ninja install
	@touch $@

$($(gobject-introspection)-modulefile): $(modulefilesdir)/.markerfile $($(gobject-introspection)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gobject-introspection)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gobject-introspection)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gobject-introspection)-description)\"" >>$@
	echo "module-whatis \"$($(gobject-introspection)-url)\"" >>$@
	printf "$(foreach prereq,$($(gobject-introspection)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GOBJECT_INTROSPECTION_ROOT $($(gobject-introspection)-prefix)" >>$@
	echo "setenv GOBJECT_INTROSPECTION_INCDIR $($(gobject-introspection)-prefix)/include" >>$@
	echo "setenv GOBJECT_INTROSPECTION_INCLUDEDIR $($(gobject-introspection)-prefix)/include" >>$@
	echo "setenv GOBJECT_INTROSPECTION_LIBDIR $($(gobject-introspection)-prefix)/lib" >>$@
	echo "setenv GOBJECT_INTROSPECTION_LIBRARYDIR $($(gobject-introspection)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gobject-introspection)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gobject-introspection)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gobject-introspection)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gobject-introspection)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gobject-introspection)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gobject-introspection)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gobject-introspection)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gobject-introspection)-prefix)/share/info" >>$@
	echo "set MSG \"$(gobject-introspection)\"" >>$@

$(gobject-introspection)-src: $($(gobject-introspection)-src)
$(gobject-introspection)-unpack: $($(gobject-introspection)-prefix)/.pkgunpack
$(gobject-introspection)-patch: $($(gobject-introspection)-prefix)/.pkgpatch
$(gobject-introspection)-build: $($(gobject-introspection)-prefix)/.pkgbuild
$(gobject-introspection)-check: $($(gobject-introspection)-prefix)/.pkgcheck
$(gobject-introspection)-install: $($(gobject-introspection)-prefix)/.pkginstall
$(gobject-introspection)-modulefile: $($(gobject-introspection)-modulefile)
$(gobject-introspection)-clean:
	rm -rf $($(gobject-introspection)-modulefile)
	rm -rf $($(gobject-introspection)-prefix)
	rm -rf $($(gobject-introspection)-srcdir)
	rm -rf $($(gobject-introspection)-src)
$(gobject-introspection): $(gobject-introspection)-src $(gobject-introspection)-unpack $(gobject-introspection)-patch $(gobject-introspection)-build $(gobject-introspection)-check $(gobject-introspection)-install $(gobject-introspection)-modulefile
