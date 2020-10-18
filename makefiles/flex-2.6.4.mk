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
# flex-2.6.4

flex-version = 2.6.4
flex = flex-$(flex-version)
$(flex)-description = Fast lexical analyzer generator
$(flex)-url = https://github.com/westes/flex
$(flex)-srcurl = https://github.com/westes/flex/releases/download/v$(flex-version)/flex-$(flex-version).tar.gz
$(flex)-builddeps =
$(flex)-prereqs =
$(flex)-src = $(pkgsrcdir)/$(notdir $($(flex)-srcurl))
$(flex)-srcdir = $(pkgsrcdir)/$(flex)
$(flex)-builddir = $($(flex)-srcdir)
$(flex)-modulefile = $(modulefilesdir)/$(flex)
$(flex)-prefix = $(pkgdir)/$(flex)

$($(flex)-src): $(dir $($(flex)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(flex)-srcurl)

$($(flex)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(flex)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(flex)-prefix)/.pkgunpack: $$($(flex)-src) $($(flex)-srcdir)/.markerfile $($(flex)-prefix)/.markerfile
	tar -C $($(flex)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(flex)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(flex)-builddeps),$(modulefilesdir)/$$(dep)) $($(flex)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(flex)-builddir),$($(flex)-srcdir))
$($(flex)-builddir)/.markerfile: $($(flex)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(flex)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(flex)-builddeps),$(modulefilesdir)/$$(dep)) $($(flex)-builddir)/.markerfile $($(flex)-prefix)/.pkgpatch
	cd $($(flex)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(flex)-builddeps) && \
		./configure --prefix=$($(flex)-prefix) \
			CFLAGS='-D_GNU_SOURCE' && \
		$(MAKE)
	@touch $@

$($(flex)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(flex)-builddeps),$(modulefilesdir)/$$(dep)) $($(flex)-builddir)/.markerfile $($(flex)-prefix)/.pkgbuild
	cd $($(flex)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(flex)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(flex)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(flex)-builddeps),$(modulefilesdir)/$$(dep)) $($(flex)-builddir)/.markerfile $($(flex)-prefix)/.pkgcheck
	cd $($(flex)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(flex)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(flex)-modulefile): $(modulefilesdir)/.markerfile $($(flex)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(flex)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(flex)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(flex)-description)\"" >>$@
	echo "module-whatis \"$($(flex)-url)\"" >>$@
	printf "$(foreach prereq,$($(flex)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FLEX_ROOT $($(flex)-prefix)" >>$@
	echo "setenv FLEX_INCDIR $($(flex)-prefix)/include" >>$@
	echo "setenv FLEX_INCLUDEDIR $($(flex)-prefix)/include" >>$@
	echo "setenv FLEX_LIBDIR $($(flex)-prefix)/lib" >>$@
	echo "setenv FLEX_LIBRARYDIR $($(flex)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(flex)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(flex)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(flex)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(flex)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(flex)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(flex)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(flex)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(flex)-prefix)/share/info" >>$@
	echo "set MSG \"$(flex)\"" >>$@

$(flex)-src: $$($(flex)-src)
$(flex)-unpack: $($(flex)-prefix)/.pkgunpack
$(flex)-patch: $($(flex)-prefix)/.pkgpatch
$(flex)-build: $($(flex)-prefix)/.pkgbuild
$(flex)-check: $($(flex)-prefix)/.pkgcheck
$(flex)-install: $($(flex)-prefix)/.pkginstall
$(flex)-modulefile: $($(flex)-modulefile)
$(flex)-clean:
	rm -rf $($(flex)-modulefile)
	rm -rf $($(flex)-prefix)
	rm -rf $($(flex)-srcdir)
	rm -rf $($(flex)-src)
$(flex): $(flex)-src $(flex)-unpack $(flex)-patch $(flex)-build $(flex)-check $(flex)-install $(flex)-modulefile
