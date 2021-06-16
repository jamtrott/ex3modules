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
# openblas-0.3.12

openblas-version = 0.3.12
openblas = openblas-$(openblas-version)
$(openblas)-description = Optimized BLAS library
$(openblas)-url = http://www.openblas.net/
$(openblas)-srcurl = https://github.com/xianyi/OpenBLAS/archive/v$(openblas-version).tar.gz
$(openblas)-src = $(pkgsrcdir)/openblas-$(notdir $($(openblas)-srcurl))
$(openblas)-srcdir = $(pkgsrcdir)/$(openblas)
$(openblas)-builddeps = $(cmake) $(gcc) $(libstdcxx) $(libgfortran)
$(openblas)-prereqs = $(libgfortran) $(libstdcxx)
$(openblas)-modulefile = $(modulefilesdir)/$(openblas)
$(openblas)-prefix = $(pkgdir)/$(openblas)

$($(openblas)-src): $(dir $($(openblas)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openblas)-srcurl)

$($(openblas)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openblas)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openblas)-prefix)/.pkgunpack: $($(openblas)-src) $($(openblas)-srcdir)/.markerfile $($(openblas)-prefix)/.markerfile
	tar -C $($(openblas)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(openblas)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas)-prefix)/.pkgunpack
	@touch $@

$($(openblas)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas)-prefix)/.pkgpatch
ifeq ($(ARCH),x86_64)
	cd $($(openblas)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas)-builddeps) && \
		$(MAKE) DYNAMIC_ARCH=1 TARGET=HASWELL USE_THREAD=0 USE_LOCKING=1 USE_OPENMP=0 NUM_THREADS=256 NO_AFFINITY=1
else ifeq ($(ARCH),aarch64)
	cd $($(openblas)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas)-builddeps) && \
		$(MAKE) DYNAMIC_ARCH=1 TARGET=ARMV8 USE_THREAD=0 USE_LOCKING=1 USE_OPENMP=0 NUM_THREADS=256 NO_AFFINITY=1
endif
	@touch $@

$($(openblas)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas)-prefix)/.pkgbuild
	@touch $@

$($(openblas)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(openblas)-prefix)/.pkgcheck
	cd $($(openblas)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openblas)-builddeps) && \
		$(MAKE) PREFIX=$($(openblas)-prefix) install
	@touch $@

$($(openblas)-modulefile): $(modulefilesdir)/.markerfile $($(openblas)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openblas)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openblas)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openblas)-description)\"" >>$@
	echo "module-whatis \"$($(openblas)-url)\"" >>$@
	printf "$(foreach prereq,$($(openblas)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENBLAS_ROOT $($(openblas)-prefix)" >>$@
	echo "setenv OPENBLAS_INCDIR $($(openblas)-prefix)/include" >>$@
	echo "setenv OPENBLAS_INCLUDEDIR $($(openblas)-prefix)/include" >>$@
	echo "setenv OPENBLAS_LIBDIR $($(openblas)-prefix)/lib" >>$@
	echo "setenv OPENBLAS_LIBRARYDIR $($(openblas)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(openblas)-prefix)/lib" >>$@
	echo "setenv BLASLIB openblas" >>$@
	echo "setenv LAPACKDIR $($(openblas)-prefix)/lib" >>$@
	echo "setenv LAPACKLIB openblas" >>$@
	echo "setenv OPENBLAS_NUM_THREADS 1" >>$@
	echo "prepend-path PATH $($(openblas)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openblas)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openblas)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openblas)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openblas)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openblas)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(openblas)-prefix)/lib/cmake/openblas" >>$@
	echo "set MSG \"$(openblas)\"" >>$@

$(openblas)-src: $($(openblas)-src)
$(openblas)-unpack: $($(openblas)-prefix)/.pkgunpack
$(openblas)-patch: $($(openblas)-prefix)/.pkgpatch
$(openblas)-build: $($(openblas)-prefix)/.pkgbuild
$(openblas)-check: $($(openblas)-prefix)/.pkgcheck
$(openblas)-install: $($(openblas)-prefix)/.pkginstall
$(openblas)-modulefile: $($(openblas)-modulefile)
$(openblas)-clean:
	rm -rf $($(openblas)-modulefile)
	rm -rf $($(openblas)-prefix)
	rm -rf $($(openblas)-srcdir)
	rm -rf $($(openblas)-src)
$(openblas): $(openblas)-src $(openblas)-unpack $(openblas)-patch $(openblas)-build $(openblas)-check $(openblas)-install $(openblas)-modulefile
