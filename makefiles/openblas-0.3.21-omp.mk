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
# openblas-0.3.21-omp

openblas-0.3.21-omp-version = 0.3.21
openblas-0.3.21-omp-suffix = -omp
openblas-0.3.21-omp = openblas-$(openblas-0.3.21-omp-version)$(openblas-0.3.21-omp-suffix)
$(openblas-0.3.21-omp)-description = Optimized BLAS library
$(openblas-0.3.21-omp)-url = http://www.openblas.net/
$(openblas-0.3.21-omp)-srcurl =
$(openblas-0.3.21-omp)-builddeps = $(cmake)
$(openblas-0.3.21-omp)-prereqs =
$(openblas-0.3.21-omp)-src = $($(openblas-src-0.3.21)-src)
$(openblas-0.3.21-omp)-srcdir = $(pkgsrcdir)/$(openblas-0.3.21-omp)
$(openblas-0.3.21-omp)-modulefile = $(modulefilesdir)/$(openblas-0.3.21-omp)
$(openblas-0.3.21-omp)-prefix = $(pkgdir)/$(openblas-0.3.21-omp)

$($(openblas-0.3.21-omp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openblas-0.3.21-omp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openblas-0.3.21-omp)-prefix)/.pkgunpack: $$($(openblas-0.3.21-omp)-src) $($(openblas-0.3.21-omp)-srcdir)/.markerfile $($(openblas-0.3.21-omp)-prefix)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-omp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openblas-0.3.21-omp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openblas-0.3.21-omp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-omp)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-omp)-prefix)/.pkgunpack
	sed -i '64i .NOTPARALLEL:' $($(openblas-0.3.21-omp)-srcdir)/lapack-netlib/TESTING/MATGEN/Makefile
	@touch $@

$($(openblas-0.3.21-omp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-omp)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-omp)-prefix)/.pkgpatch
ifeq ($(ARCH),x86_64)
	cd $($(openblas-0.3.21-omp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas-0.3.21-omp)-builddeps) && \
		$(MAKE) DYNAMIC_ARCH=1 TARGET=HASWELL USE_THREAD=1 USE_LOCKING=0 USE_OPENMP=1 NUM_THREADS=256 NO_AFFINITY=1 USE_CBLAS=1 NOFORTRAN=1
else ifeq ($(ARCH),aarch64)
	cd $($(openblas-0.3.21-omp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas-0.3.21-omp)-builddeps) && \
		$(MAKE) DYNAMIC_ARCH=1 TARGET=ARMV8 USE_THREAD=1 USE_LOCKING=0 USE_OPENMP=1 NUM_THREADS=256 NO_AFFINITY=1 USE_CBLAS=1 NOFORTRAN=1
endif
	@touch $@

$($(openblas-0.3.21-omp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-omp)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-omp)-prefix)/.pkgbuild
	@touch $@

$($(openblas-0.3.21-omp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-omp)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-omp)-prefix)/.pkgcheck
	cd $($(openblas-0.3.21-omp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas-0.3.21-omp)-builddeps) && \
		$(MAKE) PREFIX=$($(openblas-0.3.21-omp)-prefix) install
	@touch $@

$($(openblas-0.3.21-omp)-modulefile): $(modulefilesdir)/.markerfile $($(openblas-0.3.21-omp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openblas-0.3.21-omp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openblas-0.3.21-omp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openblas-0.3.21-omp)-description)\"" >>$@
	echo "module-whatis \"$($(openblas-0.3.21-omp)-url)\"" >>$@
	printf "$(foreach prereq,$($(openblas-0.3.21-omp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENBLAS_ROOT $($(openblas-0.3.21-omp)-prefix)" >>$@
	echo "setenv OPENBLAS_INCDIR $($(openblas-0.3.21-omp)-prefix)/include" >>$@
	echo "setenv OPENBLAS_INCLUDEDIR $($(openblas-0.3.21-omp)-prefix)/include" >>$@
	echo "setenv OPENBLAS_LIBDIR $($(openblas-0.3.21-omp)-prefix)/lib" >>$@
	echo "setenv OPENBLAS_LIBRARYDIR $($(openblas-0.3.21-omp)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(openblas-0.3.21-omp)-prefix)/lib" >>$@
	echo "setenv BLASLIB openblas" >>$@
	echo "setenv LAPACKDIR $($(openblas-0.3.21-omp)-prefix)/lib" >>$@
	echo "setenv LAPACKLIB openblas" >>$@
	echo "setenv OPENBLAS_NUM_THREADS 1" >>$@
	echo "prepend-path PATH $($(openblas-0.3.21-omp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openblas-0.3.21-omp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openblas-0.3.21-omp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openblas-0.3.21-omp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openblas-0.3.21-omp)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openblas-0.3.21-omp)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(openblas-0.3.21-omp)-prefix)/lib/cmake/openblas" >>$@
	echo "set MSG \"$(openblas-0.3.21-omp)\"" >>$@

$(openblas-0.3.21-omp)-src: $($(openblas-0.3.21-omp)-src)
$(openblas-0.3.21-omp)-unpack: $($(openblas-0.3.21-omp)-prefix)/.pkgunpack
$(openblas-0.3.21-omp)-patch: $($(openblas-0.3.21-omp)-prefix)/.pkgpatch
$(openblas-0.3.21-omp)-build: $($(openblas-0.3.21-omp)-prefix)/.pkgbuild
$(openblas-0.3.21-omp)-check: $($(openblas-0.3.21-omp)-prefix)/.pkgcheck
$(openblas-0.3.21-omp)-install: $($(openblas-0.3.21-omp)-prefix)/.pkginstall
$(openblas-0.3.21-omp)-modulefile: $($(openblas-0.3.21-omp)-modulefile)
$(openblas-0.3.21-omp)-clean:
	rm -rf $($(openblas-0.3.21-omp)-modulefile)
	rm -rf $($(openblas-0.3.21-omp)-prefix)
	rm -rf $($(openblas-0.3.21-omp)-srcdir)
	rm -rf $($(openblas-0.3.21-omp)-src)
$(openblas-0.3.21-omp): $(openblas-0.3.21-omp)-src $(openblas-0.3.21-omp)-unpack $(openblas-0.3.21-omp)-patch $(openblas-0.3.21-omp)-build $(openblas-0.3.21-omp)-check $(openblas-0.3.21-omp)-install $(openblas-0.3.21-omp)-modulefile
