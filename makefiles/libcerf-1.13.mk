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
# libcerf-1.13

libcerf-version = 1.13
libcerf = libcerf-$(libcerf-version)
$(libcerf)-description = Numeric library for complex error functions
$(libcerf)-url = https://jugit.fz-juelich.de/mlz/libcerf
$(libcerf)-srcurl = https://jugit.fz-juelich.de/mlz/libcerf/-/archive/v$(libcerf-version)/libcerf-v$(libcerf-version).tar.gz
$(libcerf)-builddeps = $(cmake)
$(libcerf)-prereqs = 
$(libcerf)-src = $(pkgsrcdir)/$(notdir $($(libcerf)-srcurl))
$(libcerf)-srcdir = $(pkgsrcdir)/$(libcerf)
$(libcerf)-builddir = $($(libcerf)-srcdir)/build
$(libcerf)-modulefile = $(modulefilesdir)/$(libcerf)
$(libcerf)-prefix = $(pkgdir)/$(libcerf)

$($(libcerf)-src): $(dir $($(libcerf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libcerf)-srcurl)

$($(libcerf)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libcerf)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libcerf)-prefix)/.pkgunpack: $($(libcerf)-src) $($(libcerf)-srcdir)/.markerfile $($(libcerf)-prefix)/.markerfile
	tar -C $($(libcerf)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libcerf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcerf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcerf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libcerf)-builddir),$($(libcerf)-srcdir))
$($(libcerf)-builddir)/.markerfile: $($(libcerf)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(libcerf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcerf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcerf)-builddir)/.markerfile $($(libcerf)-prefix)/.pkgpatch
	cd $($(libcerf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libcerf)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(libcerf)-prefix) && \
		$(MAKE)
	@touch $@

$($(libcerf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcerf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcerf)-builddir)/.markerfile $($(libcerf)-prefix)/.pkgbuild
	cd $($(libcerf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libcerf)-builddeps) && \
		$(MAKE) test
	@touch $@

$($(libcerf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcerf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcerf)-builddir)/.markerfile $($(libcerf)-prefix)/.pkgcheck
	cd $($(libcerf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libcerf)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libcerf)-modulefile): $(modulefilesdir)/.markerfile $($(libcerf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libcerf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libcerf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libcerf)-description)\"" >>$@
	echo "module-whatis \"$($(libcerf)-url)\"" >>$@
	printf "$(foreach prereq,$($(libcerf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBCERF_ROOT $($(libcerf)-prefix)" >>$@
	echo "setenv LIBCERF_INCDIR $($(libcerf)-prefix)/include" >>$@
	echo "setenv LIBCERF_INCLUDEDIR $($(libcerf)-prefix)/include" >>$@
	echo "setenv LIBCERF_LIBDIR $($(libcerf)-prefix)/lib" >>$@
	echo "setenv LIBCERF_LIBRARYDIR $($(libcerf)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libcerf)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libcerf)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libcerf)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libcerf)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libcerf)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libcerf)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libcerf)-prefix)/share/man" >>$@
	echo "set MSG \"$(libcerf)\"" >>$@

$(libcerf)-src: $($(libcerf)-src)
$(libcerf)-unpack: $($(libcerf)-prefix)/.pkgunpack
$(libcerf)-patch: $($(libcerf)-prefix)/.pkgpatch
$(libcerf)-build: $($(libcerf)-prefix)/.pkgbuild
$(libcerf)-check: $($(libcerf)-prefix)/.pkgcheck
$(libcerf)-install: $($(libcerf)-prefix)/.pkginstall
$(libcerf)-modulefile: $($(libcerf)-modulefile)
$(libcerf)-clean:
	rm -rf $($(libcerf)-modulefile)
	rm -rf $($(libcerf)-prefix)
	rm -rf $($(libcerf)-srcdir)
	rm -rf $($(libcerf)-src)
$(libcerf): $(libcerf)-src $(libcerf)-unpack $(libcerf)-patch $(libcerf)-build $(libcerf)-check $(libcerf)-install $(libcerf)-modulefile
