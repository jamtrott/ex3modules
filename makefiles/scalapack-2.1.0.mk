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
# scalapack-2.1.0

scalapack-version = 2.1.0
scalapack = scalapack-$(scalapack-version)
$(scalapack)-description = Scalable Linear Algebra PACKage
$(scalapack)-url = http://www.netlib.org/scalapack/
$(scalapack)-srcurl = http://www.netlib.org/scalapack/scalapack-$(scalapack-version).tgz
$(scalapack)-builddeps = $(gcc) $(libstdcxx) $(libgfortran) $(cmake) $(blas) $(mpi)
$(scalapack)-prereqs = $(libgfortran) $(blas) $(mpi)
$(scalapack)-src = $(pkgsrcdir)/$(notdir $($(scalapack)-srcurl))
$(scalapack)-srcdir = $(pkgsrcdir)/$(scalapack)
$(scalapack)-builddir = $($(scalapack)-srcdir)/build
$(scalapack)-modulefile = $(modulefilesdir)/$(scalapack)
$(scalapack)-prefix = $(pkgdir)/$(scalapack)

$($(scalapack)-src): $(dir $($(scalapack)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(scalapack)-srcurl)

$($(scalapack)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scalapack)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scalapack)-prefix)/.pkgunpack: $$($(scalapack)-src) $($(scalapack)-srcdir)/.markerfile $($(scalapack)-prefix)/.markerfile
	tar -C $($(scalapack)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(scalapack)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(scalapack)-builddir),$($(scalapack)-srcdir))
$($(scalapack)-builddir)/.markerfile: $($(scalapack)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(scalapack)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack)-builddir)/.markerfile $($(scalapack)-prefix)/.pkgpatch
	cd $($(scalapack)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scalapack)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(scalapack)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=ON \
			-DBUILD_STATIC_LIBS=OFF \
			-DBLAS_LIBRARIES=$${BLASLIB} \
			-DLAPACK_LIBRARIES=$${LAPACKLIB} \
			-DMPI_BASE_DIR=$${MPI_HOME} \
			-DCMAKE_Fortran_FLAGS="-fallow-argument-mismatch" && \
		$(MAKE)
	@touch $@

$($(scalapack)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack)-builddir)/.markerfile $($(scalapack)-prefix)/.pkgbuild
	@touch $@

$($(scalapack)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack)-builddir)/.markerfile $($(scalapack)-prefix)/.pkgcheck
	cd $($(scalapack)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scalapack)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(scalapack)-modulefile): $(modulefilesdir)/.markerfile $($(scalapack)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(scalapack)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(scalapack)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(scalapack)-description)\"" >>$@
	echo "module-whatis \"$($(scalapack)-url)\"" >>$@
	printf "$(foreach prereq,$($(scalapack)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SCALAPACK_ROOT $($(scalapack)-prefix)" >>$@
	echo "setenv SCALAPACK_LIBDIR $($(scalapack)-prefix)/lib" >>$@
	echo "setenv SCALAPACK_LIBRARYDIR $($(scalapack)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(scalapack)-prefix)/bin" >>$@
	echo "prepend-path LIBRARY_PATH $($(scalapack)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(scalapack)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(scalapack)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(scalapack)-prefix)/lib/cmake/scalapack-$(scalapack-version)" >>$@
	echo "set MSG \"$(scalapack)\"" >>$@

$(scalapack)-src: $$($(scalapack)-src)
$(scalapack)-unpack: $($(scalapack)-prefix)/.pkgunpack
$(scalapack)-patch: $($(scalapack)-prefix)/.pkgpatch
$(scalapack)-build: $($(scalapack)-prefix)/.pkgbuild
$(scalapack)-check: $($(scalapack)-prefix)/.pkgcheck
$(scalapack)-install: $($(scalapack)-prefix)/.pkginstall
$(scalapack)-modulefile: $($(scalapack)-modulefile)
$(scalapack)-clean:
	rm -rf $($(scalapack)-modulefile)
	rm -rf $($(scalapack)-prefix)
	rm -rf $($(scalapack)-srcdir)
	rm -rf $($(scalapack)-src)
$(scalapack): $(scalapack)-src $(scalapack)-unpack $(scalapack)-patch $(scalapack)-build $(scalapack)-check $(scalapack)-install $(scalapack)-modulefile
