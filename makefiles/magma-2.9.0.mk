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
# magma-2.9.0

magma-version = 2.9.0
magma = magma-$(magma-version)
$(magma)-description = Matrix Algebra on GPU and Multi-core Architectures (MAGMA)
$(magma)-url = https://icl.utk.edu/magma/
$(magma)-srcurl = https://icl.utk.edu/projectsfiles/magma/downloads/magma-2.9.0.tar.gz
$(magma)-builddeps = $(cmake) $(openblas)
$(magma)-prereqs = $(openblas)
$(magma)-src = $(pkgsrcdir)/$(notdir $($(magma)-srcurl))
$(magma)-srcdir = $(pkgsrcdir)/$(magma)
$(magma)-builddir = $($(magma)-srcdir)/build
$(magma)-modulefile = $(modulefilesdir)/$(magma)
$(magma)-prefix = $(pkgdir)/$(magma)

$($(magma)-src): $(dir $($(magma)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(magma)-srcurl)

$($(magma)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(magma)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(magma)-prefix)/.pkgunpack: $$($(magma)-src) $($(magma)-srcdir)/.markerfile $($(magma)-prefix)/.markerfile $$(foreach dep,$$($(magma)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(magma)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(magma)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(magma)-builddeps),$(modulefilesdir)/$$(dep)) $($(magma)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(magma)-builddir),$($(magma)-srcdir))
$($(magma)-builddir)/.markerfile: $($(magma)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(magma)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(magma)-builddeps),$(modulefilesdir)/$$(dep)) $($(magma)-builddir)/.markerfile $($(magma)-prefix)/.pkgpatch
	cd $($(magma)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(magma)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(magma)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_SHARED_LIBS=ON \
			-DUSE_FORTRAN=NO \
			-DBLA_VENDOR=OpenBLAS \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo -DMAGMA_ENABLE_CUDA=ON -DGPU_TARGET=Ampere -DCMAKE_CUDA_COMPILER="$${CUDA_TOOLKIT_ROOT}/bin/nvcc") \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo -DMAGMA_ENABLE_HIP=ON) && \
		$(MAKE) prefix=$($(magma)-prefix)
	@touch $@

$($(magma)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(magma)-builddeps),$(modulefilesdir)/$$(dep)) $($(magma)-builddir)/.markerfile $($(magma)-prefix)/.pkgbuild
	@touch $@

$($(magma)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(magma)-builddeps),$(modulefilesdir)/$$(dep)) $($(magma)-builddir)/.markerfile $($(magma)-prefix)/.pkgcheck
	cd $($(magma)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(magma)-builddeps) && \
		$(MAKE) install prefix=$($(magma)-prefix) VERBOSE=1
	@touch $@

$($(magma)-modulefile): $(modulefilesdir)/.markerfile $($(magma)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(magma)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(magma)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(magma)-description)\"" >>$@
	echo "module-whatis \"$($(magma)-url)\"" >>$@
	printf "$(foreach prereq,$($(magma)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MAGMA_ROOT $($(magma)-prefix)" >>$@
	echo "setenv MAGMA_INCDIR $($(magma)-prefix)/include" >>$@
	echo "setenv MAGMA_INCLUDEDIR $($(magma)-prefix)/include" >>$@
	echo "setenv MAGMA_LIBDIR $($(magma)-prefix)/lib" >>$@
	echo "setenv MAGMA_LIBRARYDIR $($(magma)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(magma)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(magma)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(magma)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(magma)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(magma)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(magma)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(magma)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(magma)-prefix)/share/info" >>$@
	echo "set MSG \"$(magma)\"" >>$@

$(magma)-src: $$($(magma)-src)
$(magma)-unpack: $($(magma)-prefix)/.pkgunpack
$(magma)-patch: $($(magma)-prefix)/.pkgpatch
$(magma)-build: $($(magma)-prefix)/.pkgbuild
$(magma)-check: $($(magma)-prefix)/.pkgcheck
$(magma)-install: $($(magma)-prefix)/.pkginstall
$(magma)-modulefile: $($(magma)-modulefile)
$(magma)-clean:
	rm -rf $($(magma)-modulefile)
	rm -rf $($(magma)-prefix)
	rm -rf $($(magma)-builddir)
	rm -rf $($(magma)-srcdir)
	rm -rf $($(magma)-src)
$(magma): $(magma)-src $(magma)-unpack $(magma)-patch $(magma)-build $(magma)-check $(magma)-install $(magma)-modulefile
