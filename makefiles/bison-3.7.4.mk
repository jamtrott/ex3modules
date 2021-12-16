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
# bison-3.7.4

bison-version = 3.7.4
bison = bison-$(bison-version)
$(bison)-description = General-purpose parser generator
$(bison)-url = https://www.gnu.org/software/bison/
$(bison)-srcurl = https://gnuftp.uib.no/bison/bison-$(bison-version).tar.xz
$(bison)-builddeps = $(readline)
$(bison)-prereqs = $(readline)
$(bison)-src = $(pkgsrcdir)/$(notdir $($(bison)-srcurl))
$(bison)-srcdir = $(pkgsrcdir)/$(bison)
$(bison)-builddir = $($(bison)-srcdir)
$(bison)-modulefile = $(modulefilesdir)/$(bison)
$(bison)-prefix = $(pkgdir)/$(bison)

$($(bison)-src): $(dir $($(bison)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(bison)-srcurl)

$($(bison)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(bison)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(bison)-prefix)/.pkgunpack: $$($(bison)-src) $($(bison)-srcdir)/.markerfile $($(bison)-prefix)/.markerfile $$(foreach dep,$$($(bison)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(bison)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(bison)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bison)-builddeps),$(modulefilesdir)/$$(dep)) $($(bison)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(bison)-builddir),$($(bison)-srcdir))
$($(bison)-builddir)/.markerfile: $($(bison)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(bison)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bison)-builddeps),$(modulefilesdir)/$$(dep)) $($(bison)-builddir)/.markerfile $($(bison)-prefix)/.pkgpatch
	cd $($(bison)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(bison)-builddeps) && \
		./configure --prefix=$($(bison)-prefix) && \
		$(MAKE)
	@touch $@

$($(bison)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bison)-builddeps),$(modulefilesdir)/$$(dep)) $($(bison)-builddir)/.markerfile $($(bison)-prefix)/.pkgbuild
	cd $($(bison)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(bison)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(bison)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(bison)-builddeps),$(modulefilesdir)/$$(dep)) $($(bison)-builddir)/.markerfile $($(bison)-prefix)/.pkgcheck
	cd $($(bison)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(bison)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(bison)-modulefile): $(modulefilesdir)/.markerfile $($(bison)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(bison)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(bison)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(bison)-description)\"" >>$@
	echo "module-whatis \"$($(bison)-url)\"" >>$@
	printf "$(foreach prereq,$($(bison)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BISON_ROOT $($(bison)-prefix)" >>$@
	echo "setenv BISON_INCDIR $($(bison)-prefix)/include" >>$@
	echo "setenv BISON_INCLUDEDIR $($(bison)-prefix)/include" >>$@
	echo "setenv BISON_LIBDIR $($(bison)-prefix)/lib" >>$@
	echo "setenv BISON_LIBRARYDIR $($(bison)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(bison)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(bison)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(bison)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(bison)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(bison)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(bison)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(bison)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(bison)-prefix)/share/info" >>$@
	echo "prepend-path ACLOCAL_PATH $($(bison)-prefix)/share/aclocal" >>$@
	echo "set MSG \"$(bison)\"" >>$@

$(bison)-src: $$($(bison)-src)
$(bison)-unpack: $($(bison)-prefix)/.pkgunpack
$(bison)-patch: $($(bison)-prefix)/.pkgpatch
$(bison)-build: $($(bison)-prefix)/.pkgbuild
$(bison)-check: $($(bison)-prefix)/.pkgcheck
$(bison)-install: $($(bison)-prefix)/.pkginstall
$(bison)-modulefile: $($(bison)-modulefile)
$(bison)-clean:
	rm -rf $($(bison)-modulefile)
	rm -rf $($(bison)-prefix)
	rm -rf $($(bison)-srcdir)
	rm -rf $($(bison)-src)
$(bison): $(bison)-src $(bison)-unpack $(bison)-patch $(bison)-build $(bison)-check $(bison)-install $(bison)-modulefile
