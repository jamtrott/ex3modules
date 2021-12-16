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
# libpfm-4.10.1

libpfm-version = 4.10.1
libpfm = libpfm-$(libpfm-version)
$(libpfm)-description = Performance monitoring library for Linux
$(libpfm)-url = http://perfmon2.sourceforge.net/
$(libpfm)-srcurl = https://download.sourceforge.net/perfmon2/libpfm-$(libpfm-version).tar.gz
$(libpfm)-builddeps = 
$(libpfm)-prereqs = 
$(libpfm)-src = $(pkgsrcdir)/$(notdir $($(libpfm)-srcurl))
$(libpfm)-srcdir = $(pkgsrcdir)/$(libpfm)
$(libpfm)-builddir = $($(libpfm)-srcdir)
$(libpfm)-modulefile = $(modulefilesdir)/$(libpfm)
$(libpfm)-prefix = $(pkgdir)/$(libpfm)

$($(libpfm)-src): $(dir $($(libpfm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libpfm)-srcurl)

$($(libpfm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpfm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpfm)-prefix)/.pkgunpack: $($(libpfm)-src) $($(libpfm)-srcdir)/.markerfile $($(libpfm)-prefix)/.markerfile $$(foreach dep,$$($(libpfm)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libpfm)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libpfm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpfm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpfm)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libpfm)-builddir),$($(libpfm)-srcdir))
$($(libpfm)-builddir)/.markerfile: $($(libpfm)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libpfm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpfm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpfm)-builddir)/.markerfile $($(libpfm)-prefix)/.pkgpatch
	cd $($(libpfm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpfm)-builddeps) && \
		$(MAKE)
	@touch $@

$($(libpfm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpfm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpfm)-builddir)/.markerfile $($(libpfm)-prefix)/.pkgbuild
	cd $($(libpfm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpfm)-builddeps) && \
		./tests/validate
	@touch $@

$($(libpfm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpfm)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpfm)-builddir)/.markerfile $($(libpfm)-prefix)/.pkgcheck
	cd $($(libpfm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpfm)-builddeps) && \
		$(MAKE) MAKEFLAGS="PREFIX=$($(libpfm)-prefix)" install
	@touch $@

$($(libpfm)-modulefile): $(modulefilesdir)/.markerfile $($(libpfm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libpfm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libpfm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libpfm)-description)\"" >>$@
	echo "module-whatis \"$($(libpfm)-url)\"" >>$@
	printf "$(foreach prereq,$($(libpfm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBPFM_ROOT $($(libpfm)-prefix)" >>$@
	echo "setenv LIBPFM_INCDIR $($(libpfm)-prefix)/include" >>$@
	echo "setenv LIBPFM_INCLUDEDIR $($(libpfm)-prefix)/include" >>$@
	echo "setenv LIBPFM_LIBDIR $($(libpfm)-prefix)/lib" >>$@
	echo "setenv LIBPFM_LIBRARYDIR $($(libpfm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libpfm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libpfm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libpfm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libpfm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libpfm)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(libpfm)-prefix)/share/man" >>$@
	echo "set MSG \"$(libpfm)\"" >>$@

$(libpfm)-src: $($(libpfm)-src)
$(libpfm)-unpack: $($(libpfm)-prefix)/.pkgunpack
$(libpfm)-patch: $($(libpfm)-prefix)/.pkgpatch
$(libpfm)-build: $($(libpfm)-prefix)/.pkgbuild
$(libpfm)-check: $($(libpfm)-prefix)/.pkgcheck
$(libpfm)-install: $($(libpfm)-prefix)/.pkginstall
$(libpfm)-modulefile: $($(libpfm)-modulefile)
$(libpfm)-clean:
	rm -rf $($(libpfm)-modulefile)
	rm -rf $($(libpfm)-prefix)
	rm -rf $($(libpfm)-srcdir)
	rm -rf $($(libpfm)-src)
$(libpfm): $(libpfm)-src $(libpfm)-unpack $(libpfm)-patch $(libpfm)-build $(libpfm)-check $(libpfm)-install $(libpfm)-modulefile
