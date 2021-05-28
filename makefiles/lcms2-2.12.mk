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
# lcms2-2.12

lcms2-version = 2.12
lcms2 = lcms2-$(lcms2-version)
$(lcms2)-description = Color management engine
$(lcms2)-url = https://www.littlecms.com
$(lcms2)-srcurl = https://github.com/mm2/Little-CMS/releases/download/lcms$(lcms2-version)/lcms2-$(lcms2-version).tar.gz
$(lcms2)-builddeps = $(libtiff) $(openjpeg)
$(lcms2)-prereqs = $(libtiff) $(openjpeg)
$(lcms2)-src = $(pkgsrcdir)/$(notdir $($(lcms2)-srcurl))
$(lcms2)-srcdir = $(pkgsrcdir)/$(lcms2)
$(lcms2)-builddir = $($(lcms2)-srcdir)
$(lcms2)-modulefile = $(modulefilesdir)/$(lcms2)
$(lcms2)-prefix = $(pkgdir)/$(lcms2)

$($(lcms2)-src): $(dir $($(lcms2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(lcms2)-srcurl)

$($(lcms2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(lcms2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(lcms2)-prefix)/.pkgunpack: $$($(lcms2)-src) $($(lcms2)-srcdir)/.markerfile $($(lcms2)-prefix)/.markerfile
	tar -C $($(lcms2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(lcms2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lcms2)-builddeps),$(modulefilesdir)/$$(dep)) $($(lcms2)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(lcms2)-builddir),$($(lcms2)-srcdir))
$($(lcms2)-builddir)/.markerfile: $($(lcms2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(lcms2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lcms2)-builddeps),$(modulefilesdir)/$$(dep)) $($(lcms2)-builddir)/.markerfile $($(lcms2)-prefix)/.pkgpatch
	cd $($(lcms2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(lcms2)-builddeps) && \
		./configure --prefix=$($(lcms2)-prefix) && \
		$(MAKE)
	@touch $@

$($(lcms2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lcms2)-builddeps),$(modulefilesdir)/$$(dep)) $($(lcms2)-builddir)/.markerfile $($(lcms2)-prefix)/.pkgbuild
	cd $($(lcms2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(lcms2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(lcms2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lcms2)-builddeps),$(modulefilesdir)/$$(dep)) $($(lcms2)-builddir)/.markerfile $($(lcms2)-prefix)/.pkgcheck
	cd $($(lcms2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(lcms2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(lcms2)-modulefile): $(modulefilesdir)/.markerfile $($(lcms2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(lcms2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(lcms2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(lcms2)-description)\"" >>$@
	echo "module-whatis \"$($(lcms2)-url)\"" >>$@
	printf "$(foreach prereq,$($(lcms2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LCMS2_ROOT $($(lcms2)-prefix)" >>$@
	echo "setenv LCMS2_INCDIR $($(lcms2)-prefix)/include" >>$@
	echo "setenv LCMS2_INCLUDEDIR $($(lcms2)-prefix)/include" >>$@
	echo "setenv LCMS2_LIBDIR $($(lcms2)-prefix)/lib" >>$@
	echo "setenv LCMS2_LIBRARYDIR $($(lcms2)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(lcms2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(lcms2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(lcms2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(lcms2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(lcms2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(lcms2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(lcms2)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(lcms2)-prefix)/share/info" >>$@
	echo "set MSG \"$(lcms2)\"" >>$@

$(lcms2)-src: $$($(lcms2)-src)
$(lcms2)-unpack: $($(lcms2)-prefix)/.pkgunpack
$(lcms2)-patch: $($(lcms2)-prefix)/.pkgpatch
$(lcms2)-build: $($(lcms2)-prefix)/.pkgbuild
$(lcms2)-check: $($(lcms2)-prefix)/.pkgcheck
$(lcms2)-install: $($(lcms2)-prefix)/.pkginstall
$(lcms2)-modulefile: $($(lcms2)-modulefile)
$(lcms2)-clean:
	rm -rf $($(lcms2)-modulefile)
	rm -rf $($(lcms2)-prefix)
	rm -rf $($(lcms2)-builddir)
	rm -rf $($(lcms2)-srcdir)
	rm -rf $($(lcms2)-src)
$(lcms2): $(lcms2)-src $(lcms2)-unpack $(lcms2)-patch $(lcms2)-build $(lcms2)-check $(lcms2)-install $(lcms2)-modulefile
