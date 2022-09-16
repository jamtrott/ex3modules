# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# valgrind-3.19.0

valgrind-version = 3.19.0
valgrind = valgrind-$(valgrind-version)
$(valgrind)-description = Framework and tools for dynamic program analysis
$(valgrind)-url = https://valgrind.org/
$(valgrind)-srcurl = https://sourceware.org/pub/valgrind/valgrind-3.19.0.tar.bz2
$(valgrind)-builddeps =
$(valgrind)-prereqs =
$(valgrind)-src = $(pkgsrcdir)/$(notdir $($(valgrind)-srcurl))
$(valgrind)-srcdir = $(pkgsrcdir)/$(valgrind)
$(valgrind)-builddir = $($(valgrind)-srcdir)
$(valgrind)-modulefile = $(modulefilesdir)/$(valgrind)
$(valgrind)-prefix = $(pkgdir)/$(valgrind)

$($(valgrind)-src): $(dir $($(valgrind)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(valgrind)-srcurl)

$($(valgrind)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(valgrind)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(valgrind)-prefix)/.pkgunpack: $$($(valgrind)-src) $($(valgrind)-srcdir)/.markerfile $($(valgrind)-prefix)/.markerfile $$(foreach dep,$$($(valgrind)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(valgrind)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(valgrind)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(valgrind)-builddeps),$(modulefilesdir)/$$(dep)) $($(valgrind)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(valgrind)-builddir),$($(valgrind)-srcdir))
$($(valgrind)-builddir)/.markerfile: $($(valgrind)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(valgrind)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(valgrind)-builddeps),$(modulefilesdir)/$$(dep)) $($(valgrind)-builddir)/.markerfile $($(valgrind)-prefix)/.pkgpatch
	cd $($(valgrind)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(valgrind)-builddeps) && \
		./configure --prefix=$($(valgrind)-prefix) && \
		$(MAKE)
	@touch $@

$($(valgrind)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(valgrind)-builddeps),$(modulefilesdir)/$$(dep)) $($(valgrind)-builddir)/.markerfile $($(valgrind)-prefix)/.pkgbuild
	cd $($(valgrind)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(valgrind)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(valgrind)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(valgrind)-builddeps),$(modulefilesdir)/$$(dep)) $($(valgrind)-builddir)/.markerfile $($(valgrind)-prefix)/.pkgcheck
	cd $($(valgrind)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(valgrind)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(valgrind)-modulefile): $(modulefilesdir)/.markerfile $($(valgrind)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(valgrind)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(valgrind)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(valgrind)-description)\"" >>$@
	echo "module-whatis \"$($(valgrind)-url)\"" >>$@
	printf "$(foreach prereq,$($(valgrind)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv VALGRIND_ROOT $($(valgrind)-prefix)" >>$@
	echo "setenv VALGRIND_INCDIR $($(valgrind)-prefix)/include" >>$@
	echo "setenv VALGRIND_INCLUDEDIR $($(valgrind)-prefix)/include" >>$@
	echo "setenv VALGRIND_LIBDIR $($(valgrind)-prefix)/lib" >>$@
	echo "setenv VALGRIND_LIBRARYDIR $($(valgrind)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(valgrind)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(valgrind)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(valgrind)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(valgrind)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(valgrind)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(valgrind)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(valgrind)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(valgrind)-prefix)/share/info" >>$@
	echo "set MSG \"$(valgrind)\"" >>$@

$(valgrind)-src: $$($(valgrind)-src)
$(valgrind)-unpack: $($(valgrind)-prefix)/.pkgunpack
$(valgrind)-patch: $($(valgrind)-prefix)/.pkgpatch
$(valgrind)-build: $($(valgrind)-prefix)/.pkgbuild
$(valgrind)-check: $($(valgrind)-prefix)/.pkgcheck
$(valgrind)-install: $($(valgrind)-prefix)/.pkginstall
$(valgrind)-modulefile: $($(valgrind)-modulefile)
$(valgrind)-clean:
	rm -rf $($(valgrind)-modulefile)
	rm -rf $($(valgrind)-prefix)
	rm -rf $($(valgrind)-builddir)
	rm -rf $($(valgrind)-srcdir)
	rm -rf $($(valgrind)-src)
$(valgrind): $(valgrind)-src $(valgrind)-unpack $(valgrind)-patch $(valgrind)-build $(valgrind)-check $(valgrind)-install $(valgrind)-modulefile
