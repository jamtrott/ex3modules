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
# openblas-0.3.21-mt

openblas-0.3.21-mt-version = 0.3.21
openblas-0.3.21-mt-suffix = -mt
openblas-0.3.21-mt = openblas-$(openblas-0.3.21-mt-version)$(openblas-0.3.21-mt-suffix)
$(openblas-0.3.21-mt)-description = Optimized BLAS library
$(openblas-0.3.21-mt)-url = http://www.openblas.net/
$(openblas-0.3.21-mt)-srcurl =
$(openblas-0.3.21-mt)-builddeps = $(cmake)
$(openblas-0.3.21-mt)-prereqs =
$(openblas-0.3.21-mt)-src = $($(openblas-src-0.3.21)-src)
$(openblas-0.3.21-mt)-srcdir = $(pkgsrcdir)/$(openblas-0.3.21-mt)
$(openblas-0.3.21-mt)-modulefile = $(modulefilesdir)/$(openblas-0.3.21-mt)
$(openblas-0.3.21-mt)-prefix = $(pkgdir)/$(openblas-0.3.21-mt)

$($(openblas-0.3.21-mt)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openblas-0.3.21-mt)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openblas-0.3.21-mt)-prefix)/.pkgunpack: $$($(openblas-0.3.21-mt)-src) $($(openblas-0.3.21-mt)-srcdir)/.markerfile $($(openblas-0.3.21-mt)-prefix)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-mt)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openblas-0.3.21-mt)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openblas-0.3.21-mt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-mt)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-mt)-prefix)/.pkgunpack
	sed -i '64i .NOTPARALLEL:' $($(openblas-0.3.21-mt)-srcdir)/lapack-netlib/TESTING/MATGEN/Makefile
	@touch $@

$($(openblas-0.3.21-mt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-mt)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-mt)-prefix)/.pkgpatch
ifeq ($(ARCH),x86_64)
	cd $($(openblas-0.3.21-mt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas-0.3.21-mt)-builddeps) && \
		$(MAKE) DYNAMIC_ARCH=1 TARGET=HASWELL USE_THREAD=1 USE_LOCKING=0 USE_OPENMP=0 NUM_THREADS=256 NO_AFFINITY=1 USE_CBLAS=1 NOFORTRAN=1
else ifeq ($(ARCH),aarch64)
	cd $($(openblas-0.3.21-mt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas-0.3.21-mt)-builddeps) && \
		$(MAKE) DYNAMIC_ARCH=1 TARGET=ARMV8 USE_THREAD=1 USE_LOCKING=0 USE_OPENMP=0 NUM_THREADS=256 NO_AFFINITY=1 USE_CBLAS=1 NOFORTRAN=1
endif
	@touch $@

$($(openblas-0.3.21-mt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-mt)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-mt)-prefix)/.pkgbuild
	@touch $@

$($(openblas-0.3.21-mt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas-0.3.21-mt)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas-0.3.21-mt)-prefix)/.pkgcheck
	cd $($(openblas-0.3.21-mt)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas-0.3.21-mt)-builddeps) && \
		$(MAKE) PREFIX=$($(openblas-0.3.21-mt)-prefix) install
	@touch $@

$($(openblas-0.3.21-mt)-modulefile): $(modulefilesdir)/.markerfile $($(openblas-0.3.21-mt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openblas-0.3.21-mt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openblas-0.3.21-mt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openblas-0.3.21-mt)-description)\"" >>$@
	echo "module-whatis \"$($(openblas-0.3.21-mt)-url)\"" >>$@
	printf "$(foreach prereq,$($(openblas-0.3.21-mt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENBLAS_ROOT $($(openblas-0.3.21-mt)-prefix)" >>$@
	echo "setenv OPENBLAS_INCDIR $($(openblas-0.3.21-mt)-prefix)/include" >>$@
	echo "setenv OPENBLAS_INCLUDEDIR $($(openblas-0.3.21-mt)-prefix)/include" >>$@
	echo "setenv OPENBLAS_LIBDIR $($(openblas-0.3.21-mt)-prefix)/lib" >>$@
	echo "setenv OPENBLAS_LIBRARYDIR $($(openblas-0.3.21-mt)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(openblas-0.3.21-mt)-prefix)/lib" >>$@
	echo "setenv BLASLIB openblas" >>$@
	echo "setenv LAPACKDIR $($(openblas-0.3.21-mt)-prefix)/lib" >>$@
	echo "setenv LAPACKLIB openblas" >>$@
	echo "setenv OPENBLAS_NUM_THREADS 1" >>$@
	echo "prepend-path PATH $($(openblas-0.3.21-mt)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openblas-0.3.21-mt)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openblas-0.3.21-mt)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openblas-0.3.21-mt)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openblas-0.3.21-mt)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openblas-0.3.21-mt)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(openblas-0.3.21-mt)-prefix)/lib/cmake/openblas" >>$@
	echo "set MSG \"$(openblas-0.3.21-mt)\"" >>$@

$(openblas-0.3.21-mt)-src: $($(openblas-0.3.21-mt)-src)
$(openblas-0.3.21-mt)-unpack: $($(openblas-0.3.21-mt)-prefix)/.pkgunpack
$(openblas-0.3.21-mt)-patch: $($(openblas-0.3.21-mt)-prefix)/.pkgpatch
$(openblas-0.3.21-mt)-build: $($(openblas-0.3.21-mt)-prefix)/.pkgbuild
$(openblas-0.3.21-mt)-check: $($(openblas-0.3.21-mt)-prefix)/.pkgcheck
$(openblas-0.3.21-mt)-install: $($(openblas-0.3.21-mt)-prefix)/.pkginstall
$(openblas-0.3.21-mt)-modulefile: $($(openblas-0.3.21-mt)-modulefile)
$(openblas-0.3.21-mt)-clean:
	rm -rf $($(openblas-0.3.21-mt)-modulefile)
	rm -rf $($(openblas-0.3.21-mt)-prefix)
	rm -rf $($(openblas-0.3.21-mt)-srcdir)
	rm -rf $($(openblas-0.3.21-mt)-src)
$(openblas-0.3.21-mt): $(openblas-0.3.21-mt)-src $(openblas-0.3.21-mt)-unpack $(openblas-0.3.21-mt)-patch $(openblas-0.3.21-mt)-build $(openblas-0.3.21-mt)-check $(openblas-0.3.21-mt)-install $(openblas-0.3.21-mt)-modulefile
