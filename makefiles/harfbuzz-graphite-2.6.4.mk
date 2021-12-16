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
# harfbuzz-graphite-2.6.4
#
# To avoid circular dependencies, harfbuzz is first built without
# graphite support, then we build graphite and, finally, harfbuzz is
# built a second time, now with graphite support.

harfbuzz-graphite-version = 2.6.4
harfbuzz-graphite = harfbuzz-graphite-$(harfbuzz-version)
$(harfbuzz-graphite)-description = Text shaping engine (with graphite support)
$(harfbuzz-graphite)-url = https://www.freedesktop.org/wiki/Software/HarfBuzz/
$(harfbuzz-graphite)-srcurl =
$(harfbuzz-graphite)-builddeps = $(fontconfig) $(freetype) $(icu) $(cairo) $(glib) $(graphite2)
$(harfbuzz-graphite)-prereqs = $(fontconfig) $(freetype) $(icu) $(cairo) $(glib) $(graphite2)
$(harfbuzz-graphite)-src = $($(harfbuzz-src)-src)
$(harfbuzz-graphite)-srcdir = $(pkgsrcdir)/$(harfbuzz-graphite)
$(harfbuzz-graphite)-builddir = $($(harfbuzz-graphite)-srcdir)
$(harfbuzz-graphite)-modulefile = $(modulefilesdir)/$(harfbuzz-graphite)
$(harfbuzz-graphite)-prefix = $(pkgdir)/$(harfbuzz-graphite)

$($(harfbuzz-graphite)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(harfbuzz-graphite)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(harfbuzz-graphite)-prefix)/.pkgunpack: $$($(harfbuzz-graphite)-src) $($(harfbuzz-graphite)-srcdir)/.markerfile $($(harfbuzz-graphite)-prefix)/.markerfile $$(foreach dep,$$($(harfbuzz-graphite)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(harfbuzz-graphite)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(harfbuzz-graphite)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-graphite)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-graphite)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(harfbuzz-graphite)-builddir),$($(harfbuzz-graphite)-srcdir))
$($(harfbuzz-graphite)-builddir)/.markerfile: $($(harfbuzz-graphite)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(harfbuzz-graphite)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-graphite)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-graphite)-prefix)/.pkgpatch
	cd $($(harfbuzz-graphite)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(harfbuzz-graphite)-builddeps) && \
		echo "GRAPHITE2_ROOT=$${GRAPHITE2_ROOT}" && \
		./configure --prefix=$($(harfbuzz-graphite)-prefix) \
			--with-graphite2=yes && \
		$(MAKE)
	@touch $@

$($(harfbuzz-graphite)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-graphite)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-graphite)-prefix)/.pkgbuild
#	 Some tests have been observed to be unstable
#	 cd $($(harfbuzz-graphite)-srcdir) && \
#	 	$(MODULESINIT) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(harfbuzz-graphite)-builddeps) && \
#	 	$(MAKE) check
	@touch $@

$($(harfbuzz-graphite)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-graphite)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-graphite)-prefix)/.pkgcheck
	$(MAKE) -C $($(harfbuzz-graphite)-srcdir) install
	@touch $@

$($(harfbuzz-graphite)-modulefile): $(modulefilesdir)/.markerfile $($(harfbuzz-graphite)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(harfbuzz-graphite)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(harfbuzz-graphite)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(harfbuzz-graphite)-description)\"" >>$@
	echo "module-whatis \"$($(harfbuzz-graphite)-url)\"" >>$@
	printf "$(foreach prereq,$($(harfbuzz-graphite)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HARFBUZZ_ROOT $($(harfbuzz-graphite)-prefix)" >>$@
	echo "setenv HARFBUZZ_INCDIR $($(harfbuzz-graphite)-prefix)/include/harfbuzz" >>$@
	echo "setenv HARFBUZZ_INCLUDEDIR $($(harfbuzz-graphite)-prefix)/include/harfbuzz" >>$@
	echo "setenv HARFBUZZ_LIBDIR $($(harfbuzz-graphite)-prefix)/lib" >>$@
	echo "setenv HARFBUZZ_LIBRARYDIR $($(harfbuzz-graphite)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(harfbuzz-graphite)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(harfbuzz-graphite)-prefix)/include/harfbuzz" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(harfbuzz-graphite)-prefix)/include/harfbuzz" >>$@
	echo "prepend-path LIBRARY_PATH $($(harfbuzz-graphite)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(harfbuzz-graphite)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(harfbuzz-graphite)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(harfbuzz-graphite)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(harfbuzz-graphite)-prefix)/share/info" >>$@
	echo "set MSG \"$(harfbuzz-graphite)\"" >>$@

$(harfbuzz-graphite)-src: $$($(harfbuzz-graphite)-src)
$(harfbuzz-graphite)-unpack: $($(harfbuzz-graphite)-prefix)/.pkgunpack
$(harfbuzz-graphite)-patch: $($(harfbuzz-graphite)-prefix)/.pkgpatch
$(harfbuzz-graphite)-build: $($(harfbuzz-graphite)-prefix)/.pkgbuild
$(harfbuzz-graphite)-check: $($(harfbuzz-graphite)-prefix)/.pkgcheck
$(harfbuzz-graphite)-install: $($(harfbuzz-graphite)-prefix)/.pkginstall
$(harfbuzz-graphite)-modulefile: $($(harfbuzz-graphite)-modulefile)
$(harfbuzz-graphite)-clean:
	rm -rf $($(harfbuzz-graphite)-modulefile)
	rm -rf $($(harfbuzz-graphite)-prefix)
	rm -rf $($(harfbuzz-graphite)-srcdir)
	rm -rf $($(harfbuzz-graphite)-src)
$(harfbuzz-graphite): $(harfbuzz-graphite)-src $(harfbuzz-graphite)-unpack $(harfbuzz-graphite)-patch $(harfbuzz-graphite)-build $(harfbuzz-graphite)-check $(harfbuzz-graphite)-install $(harfbuzz-graphite)-modulefile
