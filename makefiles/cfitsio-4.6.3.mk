# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# cfitsio-4.6.3

cfitsio-version = 4.6.3
cfitsio = cfitsio-$(cfitsio-version)
$(cfitsio)-description = C and Fortran library for reading and writing FITS files 
$(cfitsio)-url = https://github.com/HEASARC/cfitsio
$(cfitsio)-srcurl = https://github.com/HEASARC/cfitsio/archive/refs/tags/cfitsio-4.6.3.tar.gz
$(cfitsio)-builddeps =
$(cfitsio)-prereqs =
$(cfitsio)-src = $(pkgsrcdir)/$(notdir $($(cfitsio)-srcurl))
$(cfitsio)-srcdir = $(pkgsrcdir)/$(cfitsio)
$(cfitsio)-builddir = $($(cfitsio)-srcdir)/build
$(cfitsio)-modulefile = $(modulefilesdir)/$(cfitsio)
$(cfitsio)-prefix = $(pkgdir)/$(cfitsio)

$($(cfitsio)-src): $(dir $($(cfitsio)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cfitsio)-srcurl)

$($(cfitsio)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cfitsio)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cfitsio)-prefix)/.pkgunpack: $$($(cfitsio)-src) $($(cfitsio)-srcdir)/.markerfile $($(cfitsio)-prefix)/.markerfile $$(foreach dep,$$($(cfitsio)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cfitsio)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(cfitsio)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cfitsio)-builddeps),$(modulefilesdir)/$$(dep)) $($(cfitsio)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cfitsio)-builddir),$($(cfitsio)-srcdir))
$($(cfitsio)-builddir)/.markerfile: $($(cfitsio)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cfitsio)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cfitsio)-builddeps),$(modulefilesdir)/$$(dep)) $($(cfitsio)-builddir)/.markerfile $($(cfitsio)-prefix)/.pkgpatch
	cd $($(cfitsio)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cfitsio)-builddeps) && \
		../configure --prefix=$($(cfitsio)-prefix) && \
		$(MAKE)
	@touch $@

$($(cfitsio)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cfitsio)-builddeps),$(modulefilesdir)/$$(dep)) $($(cfitsio)-builddir)/.markerfile $($(cfitsio)-prefix)/.pkgbuild
	cd $($(cfitsio)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cfitsio)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(cfitsio)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cfitsio)-builddeps),$(modulefilesdir)/$$(dep)) $($(cfitsio)-builddir)/.markerfile $($(cfitsio)-prefix)/.pkgcheck
	cd $($(cfitsio)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cfitsio)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cfitsio)-modulefile): $(modulefilesdir)/.markerfile $($(cfitsio)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cfitsio)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cfitsio)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cfitsio)-description)\"" >>$@
	echo "module-whatis \"$($(cfitsio)-url)\"" >>$@
	printf "$(foreach prereq,$($(cfitsio)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CFITSIO_ROOT $($(cfitsio)-prefix)" >>$@
	echo "setenv CFITSIO_INCDIR $($(cfitsio)-prefix)/include" >>$@
	echo "setenv CFITSIO_INCLUDEDIR $($(cfitsio)-prefix)/include" >>$@
	echo "setenv CFITSIO_LIBDIR $($(cfitsio)-prefix)/lib" >>$@
	echo "setenv CFITSIO_LIBRARYDIR $($(cfitsio)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(cfitsio)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cfitsio)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cfitsio)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cfitsio)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cfitsio)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cfitsio)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(cfitsio)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(cfitsio)-prefix)/share/info" >>$@
	echo "set MSG \"$(cfitsio)\"" >>$@

$(cfitsio)-src: $$($(cfitsio)-src)
$(cfitsio)-unpack: $($(cfitsio)-prefix)/.pkgunpack
$(cfitsio)-patch: $($(cfitsio)-prefix)/.pkgpatch
$(cfitsio)-build: $($(cfitsio)-prefix)/.pkgbuild
$(cfitsio)-check: $($(cfitsio)-prefix)/.pkgcheck
$(cfitsio)-install: $($(cfitsio)-prefix)/.pkginstall
$(cfitsio)-modulefile: $($(cfitsio)-modulefile)
$(cfitsio)-clean:
	rm -rf $($(cfitsio)-modulefile)
	rm -rf $($(cfitsio)-prefix)
	rm -rf $($(cfitsio)-builddir)
	rm -rf $($(cfitsio)-srcdir)
	rm -rf $($(cfitsio)-src)
$(cfitsio): $(cfitsio)-src $(cfitsio)-unpack $(cfitsio)-patch $(cfitsio)-build $(cfitsio)-check $(cfitsio)-install $(cfitsio)-modulefile
