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
# scalapack-cuda-2.1.0

scalapack-cuda-version = 2.1.0
scalapack-cuda = scalapack-cuda-$(scalapack-cuda-version)
$(scalapack-cuda)-description = Scalable Linear Algebra PACKage
$(scalapack-cuda)-url = http://www.netlib.org/scalapack/
$(scalapack-cuda)-srcurl = http://www.netlib.org/scalapack/scalapack-$(scalapack-cuda-version).tgz
$(scalapack-cuda)-builddeps = $(gfortran) $(cmake) $(blas) $(openmpi-cuda)
$(scalapack-cuda)-prereqs = $(blas) $(openmpi-cuda)
$(scalapack-cuda)-src = $($(scalapack-src)-src)
$(scalapack-cuda)-srcdir = $(pkgsrcdir)/$(scalapack-cuda)
$(scalapack-cuda)-builddir = $($(scalapack-cuda)-srcdir)/build
$(scalapack-cuda)-modulefile = $(modulefilesdir)/$(scalapack-cuda)
$(scalapack-cuda)-prefix = $(pkgdir)/$(scalapack-cuda)

$($(scalapack-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scalapack-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scalapack-cuda)-prefix)/.pkgunpack: $$($(scalapack-cuda)-src) $($(scalapack-cuda)-srcdir)/.markerfile $($(scalapack-cuda)-prefix)/.markerfile $$(foreach dep,$$($(scalapack-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(scalapack-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(scalapack-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack-cuda)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(scalapack-cuda)-builddir),$($(scalapack-cuda)-srcdir))
$($(scalapack-cuda)-builddir)/.markerfile: $($(scalapack-cuda)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(scalapack-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack-cuda)-builddir)/.markerfile $($(scalapack-cuda)-prefix)/.pkgpatch
	cd $($(scalapack-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scalapack-cuda)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(scalapack-cuda)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=ON \
			-DBUILD_STATIC_LIBS=OFF \
			-DBLAS_LIBRARIES=$${BLASLIB} \
			-DLAPACK_LIBRARIES=$${LAPACKLIB} \
			-DMPI_BASE_DIR=$${MPI_HOME} && \
		$(MAKE)
	@touch $@

$($(scalapack-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack-cuda)-builddir)/.markerfile $($(scalapack-cuda)-prefix)/.pkgbuild
	@touch $@

$($(scalapack-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scalapack-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scalapack-cuda)-builddir)/.markerfile $($(scalapack-cuda)-prefix)/.pkgcheck
	cd $($(scalapack-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scalapack-cuda)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(scalapack-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(scalapack-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(scalapack-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(scalapack-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(scalapack-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(scalapack-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(scalapack-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SCALAPACK_ROOT $($(scalapack-cuda)-prefix)" >>$@
	echo "setenv SCALAPACK_LIBDIR $($(scalapack-cuda)-prefix)/lib" >>$@
	echo "setenv SCALAPACK_LIBRARYDIR $($(scalapack-cuda)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(scalapack-cuda)-prefix)/bin" >>$@
	echo "prepend-path LIBRARY_PATH $($(scalapack-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(scalapack-cuda)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(scalapack-cuda)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(scalapack-cuda)-prefix)/lib/cmake/scalapack-$(scalapack-version)" >>$@
	echo "set MSG \"$(scalapack-cuda)\"" >>$@

$(scalapack-cuda)-src: $$($(scalapack-cuda)-src)
$(scalapack-cuda)-unpack: $($(scalapack-cuda)-prefix)/.pkgunpack
$(scalapack-cuda)-patch: $($(scalapack-cuda)-prefix)/.pkgpatch
$(scalapack-cuda)-build: $($(scalapack-cuda)-prefix)/.pkgbuild
$(scalapack-cuda)-check: $($(scalapack-cuda)-prefix)/.pkgcheck
$(scalapack-cuda)-install: $($(scalapack-cuda)-prefix)/.pkginstall
$(scalapack-cuda)-modulefile: $($(scalapack-cuda)-modulefile)
$(scalapack-cuda)-clean:
	rm -rf $($(scalapack-cuda)-modulefile)
	rm -rf $($(scalapack-cuda)-prefix)
	rm -rf $($(scalapack-cuda)-srcdir)
	rm -rf $($(scalapack-cuda)-src)
$(scalapack-cuda): $(scalapack-cuda)-src $(scalapack-cuda)-unpack $(scalapack-cuda)-patch $(scalapack-cuda)-build $(scalapack-cuda)-check $(scalapack-cuda)-install $(scalapack-cuda)-modulefile
