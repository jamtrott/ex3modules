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
# pmix-3.1.5

pmix-version = 3.1.5
pmix = pmix-$(pmix-version)
$(pmix)-description = PMIx: Process management for exascale environments
$(pmix)-url = https://pmix.org
$(pmix)-srcurl = https://github.com/pmix/pmix/archive/v$(pmix-version).tar.gz
$(pmix)-builddeps = $(hwloc) $(libevent)
$(pmix)-prereqs = $(hwloc) $(libevent)
$(pmix)-src = $(pkgsrcdir)/pmix-$(notdir $($(pmix)-srcurl))
$(pmix)-srcdir = $(pkgsrcdir)/$(pmix)
$(pmix)-builddir = $($(pmix)-srcdir)/build
$(pmix)-modulefile = $(modulefilesdir)/$(pmix)
$(pmix)-prefix = $(pkgdir)/$(pmix)

$($(pmix)-src): $(dir $($(pmix)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pmix)-srcurl)

$($(pmix)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pmix)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pmix)-prefix)/.pkgunpack: $($(pmix)-src) $($(pmix)-srcdir)/.markerfile $($(pmix)-prefix)/.markerfile
	tar -C $($(pmix)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pmix)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pmix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pmix)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(pmix)-builddir),$($(pmix)-srcdir))
$($(pmix)-builddir)/.markerfile: $($(pmix)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pmix)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pmix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pmix)-builddir)/.markerfile $($(pmix)-prefix)/.pkgpatch
	cd $($(pmix)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pmix)-builddeps) && \
		./autogen.sh
	cd $($(pmix)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pmix)-builddeps) && \
		../configure --prefix=$($(pmix)-prefix) \
			--with-hwloc=$${HWLOC_ROOT} \
			--with-libevent=$${LIBEVENT_ROOT} && \
		$(MAKE)
	@touch $@

$($(pmix)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pmix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pmix)-builddir)/.markerfile $($(pmix)-prefix)/.pkgbuild
	cd $($(pmix)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pmix)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(pmix)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pmix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pmix)-builddir)/.markerfile $($(pmix)-prefix)/.pkgcheck
	cd $($(pmix)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pmix)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(pmix)-modulefile): $(modulefilesdir)/.markerfile $($(pmix)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pmix)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pmix)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pmix)-description)\"" >>$@
	echo "module-whatis \"$($(pmix)-url)\"" >>$@
	printf "$(foreach prereq,$($(pmix)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PMIX_ROOT $($(pmix)-prefix)" >>$@
	echo "setenv PMIX_INCDIR $($(pmix)-prefix)/include" >>$@
	echo "setenv PMIX_INCLUDEDIR $($(pmix)-prefix)/include" >>$@
	echo "setenv PMIX_LIBDIR $($(pmix)-prefix)/lib" >>$@
	echo "setenv PMIX_LIBRARYDIR $($(pmix)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pmix)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pmix)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pmix)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pmix)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pmix)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pmix)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pmix)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(pmix)-prefix)/share/info" >>$@
	echo "set MSG \"$(pmix)\"" >>$@

$(pmix)-src: $($(pmix)-src)
$(pmix)-unpack: $($(pmix)-prefix)/.pkgunpack
$(pmix)-patch: $($(pmix)-prefix)/.pkgpatch
$(pmix)-build: $($(pmix)-prefix)/.pkgbuild
$(pmix)-check: $($(pmix)-prefix)/.pkgcheck
$(pmix)-install: $($(pmix)-prefix)/.pkginstall
$(pmix)-modulefile: $($(pmix)-modulefile)
$(pmix)-clean:
	rm -rf $($(pmix)-modulefile)
	rm -rf $($(pmix)-prefix)
	rm -rf $($(pmix)-srcdir)
	rm -rf $($(pmix)-src)
$(pmix): $(pmix)-src $(pmix)-unpack $(pmix)-patch $(pmix)-build $(pmix)-check $(pmix)-install $(pmix)-modulefile
