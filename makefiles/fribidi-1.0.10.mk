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
# fribidi-1.0.10

fribidi-version = 1.0.10
fribidi = fribidi-$(fribidi-version)
$(fribidi)-description = Free implementation of the Unicode Bidirectional Algorithm
$(fribidi)-url = https://github.com/fribidi/fribidi/
$(fribidi)-srcurl = https://github.com/fribidi/fribidi/releases/download/v$(fribidi-version)/fribidi-$(fribidi-version).tar.xz
$(fribidi)-builddeps =
$(fribidi)-prereqs =
$(fribidi)-src = $(pkgsrcdir)/$(notdir $($(fribidi)-srcurl))
$(fribidi)-srcdir = $(pkgsrcdir)/$(fribidi)
$(fribidi)-builddir = $($(fribidi)-srcdir)
$(fribidi)-modulefile = $(modulefilesdir)/$(fribidi)
$(fribidi)-prefix = $(pkgdir)/$(fribidi)

$($(fribidi)-src): $(dir $($(fribidi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fribidi)-srcurl)

$($(fribidi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fribidi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fribidi)-prefix)/.pkgunpack: $$($(fribidi)-src) $($(fribidi)-srcdir)/.markerfile $($(fribidi)-prefix)/.markerfile
	tar -C $($(fribidi)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(fribidi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fribidi)-builddeps),$(modulefilesdir)/$$(dep)) $($(fribidi)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(fribidi)-builddir),$($(fribidi)-srcdir))
$($(fribidi)-builddir)/.markerfile: $($(fribidi)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(fribidi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fribidi)-builddeps),$(modulefilesdir)/$$(dep)) $($(fribidi)-builddir)/.markerfile $($(fribidi)-prefix)/.pkgpatch
	cd $($(fribidi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fribidi)-builddeps) && \
		./configure --prefix=$($(fribidi)-prefix) && \
		$(MAKE)
	@touch $@

$($(fribidi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fribidi)-builddeps),$(modulefilesdir)/$$(dep)) $($(fribidi)-builddir)/.markerfile $($(fribidi)-prefix)/.pkgbuild
	cd $($(fribidi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fribidi)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(fribidi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fribidi)-builddeps),$(modulefilesdir)/$$(dep)) $($(fribidi)-builddir)/.markerfile $($(fribidi)-prefix)/.pkgcheck
	cd $($(fribidi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fribidi)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fribidi)-modulefile): $(modulefilesdir)/.markerfile $($(fribidi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fribidi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fribidi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fribidi)-description)\"" >>$@
	echo "module-whatis \"$($(fribidi)-url)\"" >>$@
	printf "$(foreach prereq,$($(fribidi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FRIBIDI_ROOT $($(fribidi)-prefix)" >>$@
	echo "setenv FRIBIDI_INCDIR $($(fribidi)-prefix)/include" >>$@
	echo "setenv FRIBIDI_INCLUDEDIR $($(fribidi)-prefix)/include" >>$@
	echo "setenv FRIBIDI_LIBDIR $($(fribidi)-prefix)/lib" >>$@
	echo "setenv FRIBIDI_LIBRARYDIR $($(fribidi)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(fribidi)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fribidi)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fribidi)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fribidi)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fribidi)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fribidi)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(fribidi)-prefix)/share/man" >>$@
	echo "set MSG \"$(fribidi)\"" >>$@

$(fribidi)-src: $$($(fribidi)-src)
$(fribidi)-unpack: $($(fribidi)-prefix)/.pkgunpack
$(fribidi)-patch: $($(fribidi)-prefix)/.pkgpatch
$(fribidi)-build: $($(fribidi)-prefix)/.pkgbuild
$(fribidi)-check: $($(fribidi)-prefix)/.pkgcheck
$(fribidi)-install: $($(fribidi)-prefix)/.pkginstall
$(fribidi)-modulefile: $($(fribidi)-modulefile)
$(fribidi)-clean:
	rm -rf $($(fribidi)-modulefile)
	rm -rf $($(fribidi)-prefix)
	rm -rf $($(fribidi)-srcdir)
	rm -rf $($(fribidi)-src)
$(fribidi): $(fribidi)-src $(fribidi)-unpack $(fribidi)-patch $(fribidi)-build $(fribidi)-check $(fribidi)-install $(fribidi)-modulefile
