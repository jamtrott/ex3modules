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
# wcslib-8.5

wcslib-version = 8.5
wcslib = wcslib-$(wcslib-version)
$(wcslib)-description = A C library that implements the 'World Coordinate System' (WCS) standard in FITS
$(wcslib)-url = https://www.atnf.csiro.au/computing/software/wcs/
$(wcslib)-srcurl = https://www.atnf.csiro.au/computing/software/wcs/wcslib-releases/wcslib-8.5.tar.bz2
$(wcslib)-builddeps = $(cfitsio)
$(wcslib)-prereqs = $(cfitsio)
$(wcslib)-src = $(pkgsrcdir)/$(notdir $($(wcslib)-srcurl))
$(wcslib)-srcdir = $(pkgsrcdir)/$(wcslib)
# $(wcslib)-builddir = $($(wcslib)-srcdir)/build
$(wcslib)-builddir = $($(wcslib)-srcdir)
$(wcslib)-modulefile = $(modulefilesdir)/$(wcslib)
$(wcslib)-prefix = $(pkgdir)/$(wcslib)

$($(wcslib)-src): $(dir $($(wcslib)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(wcslib)-srcurl)

$($(wcslib)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(wcslib)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(wcslib)-prefix)/.pkgunpack: $$($(wcslib)-src) $($(wcslib)-srcdir)/.markerfile $($(wcslib)-prefix)/.markerfile $$(foreach dep,$$($(wcslib)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(wcslib)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(wcslib)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(wcslib)-builddeps),$(modulefilesdir)/$$(dep)) $($(wcslib)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(wcslib)-builddir),$($(wcslib)-srcdir))
$($(wcslib)-builddir)/.markerfile: $($(wcslib)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(wcslib)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(wcslib)-builddeps),$(modulefilesdir)/$$(dep)) $($(wcslib)-builddir)/.markerfile $($(wcslib)-prefix)/.pkgpatch
	cd $($(wcslib)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(wcslib)-builddeps) && \
		./configure --prefix=$($(wcslib)-prefix) \
                  --with-cfitsiolib="$${HWLOC_LIBDIR}" \
                  --with-cfitsioinc="$${HWLOC_INCDIR}" && \
		$(MAKE)
	@touch $@

$($(wcslib)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(wcslib)-builddeps),$(modulefilesdir)/$$(dep)) $($(wcslib)-builddir)/.markerfile $($(wcslib)-prefix)/.pkgbuild
	# cd $($(wcslib)-builddir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(wcslib)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(wcslib)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(wcslib)-builddeps),$(modulefilesdir)/$$(dep)) $($(wcslib)-builddir)/.markerfile $($(wcslib)-prefix)/.pkgcheck
	cd $($(wcslib)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(wcslib)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(wcslib)-modulefile): $(modulefilesdir)/.markerfile $($(wcslib)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(wcslib)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(wcslib)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(wcslib)-description)\"" >>$@
	echo "module-whatis \"$($(wcslib)-url)\"" >>$@
	printf "$(foreach prereq,$($(wcslib)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv WCSLIB_ROOT $($(wcslib)-prefix)" >>$@
	echo "setenv WCSLIB_INCDIR $($(wcslib)-prefix)/include" >>$@
	echo "setenv WCSLIB_INCLUDEDIR $($(wcslib)-prefix)/include" >>$@
	echo "setenv WCSLIB_LIBDIR $($(wcslib)-prefix)/lib" >>$@
	echo "setenv WCSLIB_LIBRARYDIR $($(wcslib)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(wcslib)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(wcslib)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(wcslib)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(wcslib)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(wcslib)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(wcslib)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(wcslib)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(wcslib)-prefix)/share/info" >>$@
	echo "set MSG \"$(wcslib)\"" >>$@

$(wcslib)-src: $$($(wcslib)-src)
$(wcslib)-unpack: $($(wcslib)-prefix)/.pkgunpack
$(wcslib)-patch: $($(wcslib)-prefix)/.pkgpatch
$(wcslib)-build: $($(wcslib)-prefix)/.pkgbuild
$(wcslib)-check: $($(wcslib)-prefix)/.pkgcheck
$(wcslib)-install: $($(wcslib)-prefix)/.pkginstall
$(wcslib)-modulefile: $($(wcslib)-modulefile)
$(wcslib)-clean:
	rm -rf $($(wcslib)-modulefile)
	rm -rf $($(wcslib)-prefix)
	rm -rf $($(wcslib)-builddir)
	rm -rf $($(wcslib)-srcdir)
	rm -rf $($(wcslib)-src)
$(wcslib): $(wcslib)-src $(wcslib)-unpack $(wcslib)-patch $(wcslib)-build $(wcslib)-check $(wcslib)-install $(wcslib)-modulefile
