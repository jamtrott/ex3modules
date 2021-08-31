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
# graphviz-2.44.0

graphviz-version = 2.44.0
graphviz = graphviz-$(graphviz-version)
$(graphviz)-description = Open source graph visualization software
$(graphviz)-url = https://www.graphviz.org/
$(graphviz)-srcurl = https://www2.graphviz.org/Packages/stable/portable_source/graphviz-$(graphviz-version).tar.gz
$(graphviz)-builddeps = $(cairo) $(expat) $(freetype) $(libgd) $(fontconfig) $(glib) $(libpng) $(pango) $(python)
$(graphviz)-prereqs = $(cairo) $(expat) $(freetype) $(libgd) $(fontconfig) $(glib) $(libpng) $(pango)
$(graphviz)-src = $(pkgsrcdir)/$(notdir $($(graphviz)-srcurl))
$(graphviz)-srcdir = $(pkgsrcdir)/$(graphviz)
$(graphviz)-builddir = $($(graphviz)-srcdir)
$(graphviz)-modulefile = $(modulefilesdir)/$(graphviz)
$(graphviz)-prefix = $(pkgdir)/$(graphviz)

$($(graphviz)-src): $(dir $($(graphviz)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(graphviz)-srcurl)

$($(graphviz)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(graphviz)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(graphviz)-prefix)/.pkgunpack: $($(graphviz)-src) $($(graphviz)-srcdir)/.markerfile $($(graphviz)-prefix)/.markerfile
	tar -C $($(graphviz)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(graphviz)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphviz)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(graphviz)-builddir),$($(graphviz)-srcdir))
$($(graphviz)-builddir)/.markerfile: $($(graphviz)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(graphviz)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphviz)-builddir)/.markerfile $($(graphviz)-prefix)/.pkgpatch
	cd $($(graphviz)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(graphviz)-builddeps) && \
		./configure --prefix=$($(graphviz)-prefix) \
			--disable-swig \
			--disable-sharp \
			--disable-guile \
			--disable-java \
			--disable-lua \
			--disable-ocaml \
			--disable-perl \
			--disable-php \
			--disable-ruby \
			--disable-tcl \
			&& \
		$(MAKE)
	@touch $@

$($(graphviz)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphviz)-builddir)/.markerfile $($(graphviz)-prefix)/.pkgbuild
	@touch $@

$($(graphviz)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(graphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(graphviz)-builddir)/.markerfile $($(graphviz)-prefix)/.pkgcheck
	cd $($(graphviz)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(graphviz)-builddeps) && \
		$(MAKE) MAKEFLAGS= install
	@touch $@

$($(graphviz)-modulefile): $(modulefilesdir)/.markerfile $($(graphviz)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(graphviz)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(graphviz)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(graphviz)-description)\"" >>$@
	echo "module-whatis \"$($(graphviz)-url)\"" >>$@
	printf "$(foreach prereq,$($(graphviz)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GRAPHVIZ_ROOT $($(graphviz)-prefix)" >>$@
	echo "setenv GRAPHVIZ_INCDIR $($(graphviz)-prefix)/include" >>$@
	echo "setenv GRAPHVIZ_INCLUDEDIR $($(graphviz)-prefix)/include" >>$@
	echo "setenv GRAPHVIZ_LIBDIR $($(graphviz)-prefix)/lib" >>$@
	echo "setenv GRAPHVIZ_LIBRARYDIR $($(graphviz)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(graphviz)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(graphviz)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(graphviz)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(graphviz)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(graphviz)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(graphviz)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(graphviz)-prefix)/share/man" >>$@
	echo "set MSG \"$(graphviz)\"" >>$@

$(graphviz)-src: $($(graphviz)-src)
$(graphviz)-unpack: $($(graphviz)-prefix)/.pkgunpack
$(graphviz)-patch: $($(graphviz)-prefix)/.pkgpatch
$(graphviz)-build: $($(graphviz)-prefix)/.pkgbuild
$(graphviz)-check: $($(graphviz)-prefix)/.pkgcheck
$(graphviz)-install: $($(graphviz)-prefix)/.pkginstall
$(graphviz)-modulefile: $($(graphviz)-modulefile)
$(graphviz)-clean:
	rm -rf $($(graphviz)-modulefile)
	rm -rf $($(graphviz)-prefix)
	rm -rf $($(graphviz)-srcdir)
	rm -rf $($(graphviz)-src)
$(graphviz): $(graphviz)-src $(graphviz)-unpack $(graphviz)-patch $(graphviz)-build $(graphviz)-check $(graphviz)-install $(graphviz)-modulefile
