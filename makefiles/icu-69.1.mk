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
# icu-69.1

icu-version = 69.1
icu = icu-$(icu-version)
$(icu)-description = C/C++ and Java libraries providing Unicode and Globalization support
$(icu)-url = http://site.icu-project.org/
$(icu)-srcurl = https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz
$(icu)-builddeps =
$(icu)-prereqs =
$(icu)-src = $(pkgsrcdir)/$(notdir $($(icu)-srcurl))
$(icu)-srcdir = $(pkgsrcdir)/$(icu)
$(icu)-builddir = $($(icu)-srcdir)/source
$(icu)-modulefile = $(modulefilesdir)/$(icu)
$(icu)-prefix = $(pkgdir)/$(icu)

$($(icu)-src): $(dir $($(icu)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(icu)-srcurl)

$($(icu)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(icu)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(icu)-prefix)/.pkgunpack: $$($(icu)-src) $($(icu)-srcdir)/.markerfile $($(icu)-prefix)/.markerfile
	tar -C $($(icu)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(icu)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(icu)-builddeps),$(modulefilesdir)/$$(dep)) $($(icu)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(icu)-builddir),$($(icu)-srcdir))
$($(icu)-builddir)/.markerfile: $($(icu)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(icu)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(icu)-builddeps),$(modulefilesdir)/$$(dep)) $($(icu)-builddir)/.markerfile $($(icu)-prefix)/.pkgpatch
	cd $($(icu)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(icu)-builddeps) && \
		./configure --prefix=$($(icu)-prefix) && \
		$(MAKE)
	@touch $@

$($(icu)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(icu)-builddeps),$(modulefilesdir)/$$(dep)) $($(icu)-builddir)/.markerfile $($(icu)-prefix)/.pkgbuild
	@touch $@

$($(icu)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(icu)-builddeps),$(modulefilesdir)/$$(dep)) $($(icu)-builddir)/.markerfile $($(icu)-prefix)/.pkgcheck
	cd $($(icu)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(icu)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(icu)-modulefile): $(modulefilesdir)/.markerfile $($(icu)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(icu)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(icu)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(icu)-description)\"" >>$@
	echo "module-whatis \"$($(icu)-url)\"" >>$@
	printf "$(foreach prereq,$($(icu)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv ICU_ROOT $($(icu)-prefix)" >>$@
	echo "setenv ICU_INCDIR $($(icu)-prefix)/include" >>$@
	echo "setenv ICU_INCLUDEDIR $($(icu)-prefix)/include" >>$@
	echo "setenv ICU_LIBDIR $($(icu)-prefix)/lib" >>$@
	echo "setenv ICU_LIBRARYDIR $($(icu)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(icu)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(icu)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(icu)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(icu)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(icu)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(icu)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(icu)-prefix)/share/man" >>$@
	echo "set MSG \"$(icu)\"" >>$@

$(icu)-src: $$($(icu)-src)
$(icu)-unpack: $($(icu)-prefix)/.pkgunpack
$(icu)-patch: $($(icu)-prefix)/.pkgpatch
$(icu)-build: $($(icu)-prefix)/.pkgbuild
$(icu)-check: $($(icu)-prefix)/.pkgcheck
$(icu)-install: $($(icu)-prefix)/.pkginstall
$(icu)-modulefile: $($(icu)-modulefile)
$(icu)-clean:
	rm -rf $($(icu)-modulefile)
	rm -rf $($(icu)-prefix)
	rm -rf $($(icu)-builddir)
	rm -rf $($(icu)-srcdir)
	rm -rf $($(icu)-src)
$(icu): $(icu)-src $(icu)-unpack $(icu)-patch $(icu)-build $(icu)-check $(icu)-install $(icu)-modulefile
