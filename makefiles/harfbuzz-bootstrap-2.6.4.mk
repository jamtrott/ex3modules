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
# harfbuzz-bootstrap-2.6.4

harfbuzz-bootstrap-version = 2.6.4
harfbuzz-bootstrap = harfbuzz-bootstrap-$(harfbuzz-bootstrap-version)
$(harfbuzz-bootstrap)-description = Text shaping engine
$(harfbuzz-bootstrap)-url = https://www.freedesktop.org/wiki/Software/HarfBuzz/
$(harfbuzz-bootstrap)-srcurl =
$(harfbuzz-bootstrap)-builddeps = $(icu) $(glib)
$(harfbuzz-bootstrap)-prereqs = $(icu) $(glib)
$(harfbuzz-bootstrap)-src = $($(harfbuzz-src)-src)
$(harfbuzz-bootstrap)-srcdir = $(pkgsrcdir)/$(harfbuzz-bootstrap)
$(harfbuzz-bootstrap)-builddir = $($(harfbuzz-bootstrap)-srcdir)
$(harfbuzz-bootstrap)-modulefile = $(modulefilesdir)/$(harfbuzz-bootstrap)
$(harfbuzz-bootstrap)-prefix = $(pkgdir)/$(harfbuzz-bootstrap)

$($(harfbuzz-bootstrap)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(harfbuzz-bootstrap)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(harfbuzz-bootstrap)-prefix)/.pkgunpack: $$($(harfbuzz-bootstrap)-src) $($(harfbuzz-bootstrap)-srcdir)/.markerfile $($(harfbuzz-bootstrap)-prefix)/.markerfile $$(foreach dep,$$($(harfbuzz-bootstrap)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(harfbuzz-bootstrap)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(harfbuzz-bootstrap)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-bootstrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-bootstrap)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(harfbuzz-bootstrap)-builddir),$($(harfbuzz-bootstrap)-srcdir))
$($(harfbuzz-bootstrap)-builddir)/.markerfile: $($(harfbuzz-bootstrap)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(harfbuzz-bootstrap)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-bootstrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-bootstrap)-prefix)/.pkgpatch
	cd $($(harfbuzz-bootstrap)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(harfbuzz-bootstrap)-builddeps) && \
		./configure --prefix=$($(harfbuzz-bootstrap)-prefix) \
			--without-freetype --without-fontconfig --without-cairo && \
		$(MAKE)
	@touch $@

$($(harfbuzz-bootstrap)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-bootstrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-bootstrap)-prefix)/.pkgbuild
#	 Some tests have been observed to be unstable
#	 cd $($(harfbuzz-bootstrap)-srcdir) && \
#	 	$(MODULESINIT) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(harfbuzz-bootstrap)-builddeps) && \
#	 	$(MAKE) check
	@touch $@

$($(harfbuzz-bootstrap)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(harfbuzz-bootstrap)-builddeps),$(modulefilesdir)/$$(dep)) $($(harfbuzz-bootstrap)-prefix)/.pkgcheck
	$(MAKE) -C $($(harfbuzz-bootstrap)-srcdir) install
	@touch $@

$($(harfbuzz-bootstrap)-modulefile): $(modulefilesdir)/.markerfile $($(harfbuzz-bootstrap)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(harfbuzz-bootstrap)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(harfbuzz-bootstrap)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(harfbuzz-bootstrap)-description)\"" >>$@
	echo "module-whatis \"$($(harfbuzz-bootstrap)-url)\"" >>$@
	printf "$(foreach prereq,$($(harfbuzz-bootstrap)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HARFBUZZ_BOOTSTRAP_ROOT $($(harfbuzz-bootstrap)-prefix)" >>$@
	echo "setenv HARFBUZZ_BOOTSTRAP_INCDIR $($(harfbuzz-bootstrap)-prefix)/include/harfbuzz" >>$@
	echo "setenv HARFBUZZ_BOOTSTRAP_INCLUDEDIR $($(harfbuzz-bootstrap)-prefix)/include/harfbuzz" >>$@
	echo "setenv HARFBUZZ_BOOTSTRAP_LIBDIR $($(harfbuzz-bootstrap)-prefix)/lib" >>$@
	echo "setenv HARFBUZZ_BOOTSTRAP_LIBRARYDIR $($(harfbuzz-bootstrap)-prefix)/lib" >>$@
	# echo "prepend-path PATH $($(harfbuzz-bootstrap)-prefix)/bin" >>$@
	# echo "prepend-path C_INCLUDE_PATH $($(harfbuzz-bootstrap)-prefix)/include/harfbuzz" >>$@
	# echo "prepend-path CPLUS_INCLUDE_PATH $($(harfbuzz-bootstrap)-prefix)/include/harfbuzz" >>$@
	# echo "prepend-path LIBRARY_PATH $($(harfbuzz-bootstrap)-prefix)/lib" >>$@
	# echo "prepend-path LD_LIBRARY_PATH $($(harfbuzz-bootstrap)-prefix)/lib" >>$@
	# echo "prepend-path PKG_CONFIG_PATH $($(harfbuzz-bootstrap)-prefix)/lib/pkgconfig" >>$@
	# echo "prepend-path MANPATH $($(harfbuzz-bootstrap)-prefix)/share/man" >>$@
	# echo "prepend-path INFOPATH $($(harfbuzz-bootstrap)-prefix)/share/info" >>$@
	echo "set MSG \"$(harfbuzz-bootstrap)\"" >>$@

$(harfbuzz-bootstrap)-src: $$($(harfbuzz-bootstrap)-src)
$(harfbuzz-bootstrap)-unpack: $($(harfbuzz-bootstrap)-prefix)/.pkgunpack
$(harfbuzz-bootstrap)-patch: $($(harfbuzz-bootstrap)-prefix)/.pkgpatch
$(harfbuzz-bootstrap)-build: $($(harfbuzz-bootstrap)-prefix)/.pkgbuild
$(harfbuzz-bootstrap)-check: $($(harfbuzz-bootstrap)-prefix)/.pkgcheck
$(harfbuzz-bootstrap)-install: $($(harfbuzz-bootstrap)-prefix)/.pkginstall
$(harfbuzz-bootstrap)-modulefile: $($(harfbuzz-bootstrap)-modulefile)
$(harfbuzz-bootstrap)-clean:
	rm -rf $($(harfbuzz-bootstrap)-modulefile)
	rm -rf $($(harfbuzz-bootstrap)-prefix)
	rm -rf $($(harfbuzz-bootstrap)-srcdir)
	rm -rf $($(harfbuzz-bootstrap)-src)
$(harfbuzz-bootstrap): $(harfbuzz-bootstrap)-src $(harfbuzz-bootstrap)-unpack $(harfbuzz-bootstrap)-patch $(harfbuzz-bootstrap)-build $(harfbuzz-bootstrap)-check $(harfbuzz-bootstrap)-install $(harfbuzz-bootstrap)-modulefile
