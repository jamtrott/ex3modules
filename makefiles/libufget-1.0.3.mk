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
# libufget-1.0.3

libufget-version = 1.0.3
libufget = libufget-$(libufget-version)
$(libufget)-description = C interface to the SuiteSparse Matrix Collection
$(libufget)-url = https://gitlab.mpi-magdeburg.mpg.de/software/libufget-release
$(libufget)-srcurl = https://gitlab.mpi-magdeburg.mpg.de/software/libufget-release/-/archive/v$(libufget-version)/libufget-release-v$(libufget-version).tar.gz
$(libufget)-builddeps = $(cmake) $(matio) $(sqlite) $(blas) $(libarchive) $(curl) $(bzip2) $(xz)
$(libufget)-prereqs =  $(matio) $(sqlite) $(blas) $(libarchive) $(curl) $(bzip2) $(xz)
$(libufget)-src = $(pkgsrcdir)/$(notdir $($(libufget)-srcurl))
$(libufget)-srcdir = $(pkgsrcdir)/$(libufget)
$(libufget)-builddir = $($(libufget)-srcdir)/build
$(libufget)-modulefile = $(modulefilesdir)/$(libufget)
$(libufget)-prefix = $(pkgdir)/$(libufget)

$($(libufget)-src): $(dir $($(libufget)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libufget)-srcurl)

$($(libufget)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libufget)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libufget)-prefix)/.pkgunpack: $($(libufget)-src) $($(libufget)-srcdir)/.markerfile $($(libufget)-prefix)/.markerfile
	tar -C $($(libufget)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libufget)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libufget)-builddeps),$(modulefilesdir)/$$(dep)) $($(libufget)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libufget)-builddir),$($(libufget)-srcdir))
$($(libufget)-builddir)/.markerfile: $($(libufget)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libufget)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libufget)-builddeps),$(modulefilesdir)/$$(dep)) $($(libufget)-builddir)/.markerfile $($(libufget)-prefix)/.pkgpatch
	cd $($(libufget)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libufget)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(libufget)-prefix) \
			-DMATIO_INCLUDE_DIR="$${MATIO_INCLUDEDIR}" \
			-DSQLITE3_INCLUDE_DIR="$${SQLITE_INCLUDEDIR}" \
			-DBLAS_LIBRARIES="$${BLASLIB}" \
			-DARCHIVE_INCLUDE_DIR="$${LIBARCHIVE_INDCLUDEDIR}" \
			-DCURL_INCLUDE_DIR="$${CURL_INCLUDEDIR}" \
			-DBZIP2_INCLUDE_DIR="$${BZIP2_INCLUDEDIR}" \
			-DBZIP2_LIBRARIES="$${BZIP2_LIBDIR}/libbz2.so" \
			-DARCHIVE_INCLUDE_DIR="$${LIBARCHIVE_INCLUDEDIR}" \
			-DLIBLZMA_INCLUDE_DIR="$${XZ_INCLUDEDIR}" && \
		$(MAKE)
	@touch $@

$($(libufget)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libufget)-builddeps),$(modulefilesdir)/$$(dep)) $($(libufget)-builddir)/.markerfile $($(libufget)-prefix)/.pkgbuild
	@touch $@

$($(libufget)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libufget)-builddeps),$(modulefilesdir)/$$(dep)) $($(libufget)-builddir)/.markerfile $($(libufget)-prefix)/.pkgcheck
	cd $($(libufget)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libufget)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libufget)-modulefile): $(modulefilesdir)/.markerfile $($(libufget)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libufget)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libufget)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libufget)-description)\"" >>$@
	echo "module-whatis \"$($(libufget)-url)\"" >>$@
	printf "$(foreach prereq,$($(libufget)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBUFGET_ROOT $($(libufget)-prefix)" >>$@
	echo "setenv LIBUFGET_INCDIR $($(libufget)-prefix)/include" >>$@
	echo "setenv LIBUFGET_INCLUDEDIR $($(libufget)-prefix)/include" >>$@
	echo "setenv LIBUFGET_LIBDIR $($(libufget)-prefix)/lib" >>$@
	echo "setenv LIBUFGET_LIBRARYDIR $($(libufget)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libufget)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libufget)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libufget)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libufget)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libufget)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libufget)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(libufget)\"" >>$@

$(libufget)-src: $($(libufget)-src)
$(libufget)-unpack: $($(libufget)-prefix)/.pkgunpack
$(libufget)-patch: $($(libufget)-prefix)/.pkgpatch
$(libufget)-build: $($(libufget)-prefix)/.pkgbuild
$(libufget)-check: $($(libufget)-prefix)/.pkgcheck
$(libufget)-install: $($(libufget)-prefix)/.pkginstall
$(libufget)-modulefile: $($(libufget)-modulefile)
$(libufget)-clean:
	rm -rf $($(libufget)-modulefile)
	rm -rf $($(libufget)-prefix)
	rm -rf $($(libufget)-srcdir)
	rm -rf $($(libufget)-src)
$(libufget): $(libufget)-src $(libufget)-unpack $(libufget)-patch $(libufget)-build $(libufget)-check $(libufget)-install $(libufget)-modulefile
