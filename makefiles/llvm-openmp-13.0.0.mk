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
# llvm-openmp-13.0.0

llvm-openmp-13.0.0-version = 13.0.0
llvm-openmp-13.0.0 = llvm-openmp-$(llvm-openmp-13.0.0-version)
$(llvm-openmp-13.0.0)-description = LLVM Compiler Infrastructure
$(llvm-openmp-13.0.0)-url = https://llvm.org/
$(llvm-openmp-13.0.0)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(llvm-openmp-13.0.0-version)/openmp-$(llvm-openmp-13.0.0-version).src.tar.xz
$(llvm-openmp-13.0.0)-builddeps = $(gcc) $(cmake) $(ninja) $(libffi) $(hwloc)
$(llvm-openmp-13.0.0)-prereqs = $(libffi) $(hwloc)
$(llvm-openmp-13.0.0)-src = $(pkgsrcdir)/$(notdir $($(llvm-openmp-13.0.0)-srcurl))
$(llvm-openmp-13.0.0)-srcdir = $(pkgsrcdir)/$(llvm-openmp-13.0.0)
$(llvm-openmp-13.0.0)-builddir = $($(llvm-openmp-13.0.0)-srcdir)/build
$(llvm-openmp-13.0.0)-modulefile = $(modulefilesdir)/$(llvm-openmp-13.0.0)
$(llvm-openmp-13.0.0)-prefix = $(pkgdir)/$(llvm-openmp-13.0.0)

$($(llvm-openmp-13.0.0)-src): $(dir $($(llvm-openmp-13.0.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(llvm-openmp-13.0.0)-srcurl)

$($(llvm-openmp-13.0.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-openmp-13.0.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-openmp-13.0.0)-prefix)/.pkgunpack: $($(llvm-openmp-13.0.0)-src) $($(llvm-openmp-13.0.0)-srcdir)/.markerfile $($(llvm-openmp-13.0.0)-prefix)/.markerfile
	tar -C $($(llvm-openmp-13.0.0)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(llvm-openmp-13.0.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp-13.0.0)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(llvm-openmp-13.0.0)-builddir),$($(llvm-openmp-13.0.0)-srcdir))
$($(llvm-openmp-13.0.0)-builddir)/.markerfile: $($(llvm-openmp-13.0.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(llvm-openmp-13.0.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp-13.0.0)-builddir)/.markerfile $($(llvm-openmp-13.0.0)-prefix)/.pkgpatch
	cd $($(llvm-openmp-13.0.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-openmp-13.0.0)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(llvm-openmp-13.0.0)-prefix) \
			-DLLVM_ENABLE_FFI=ON \
			-DFFI_INCLUDE_DIR="$${LIBFFI_INCLUDEDIR}" \
			-DFFI_LIBRARY_DIR="$${LIBFFI_LIBDIR}" \
			-DCMAKE_BUILD_TYPE=Release \
			-DLLVM_BUILD_LLVM_DYLIB=ON \
			-DLLVM_LINK_LLVM_DYLIB=ON \
			-DLLVM_ENABLE_RTTI=ON \
			-DLLVM_ENABLE_BINDINGS=OFF \
			-DLLVM_ENABLE_PROJECTS=openmp \
			-DLIBOMP_USE_HWLOC=ON \
			-DLIBOMP_HWLOC_INSTALL_DIR=$${HWLOC_ROOT} \
			-Wno-dev -G Ninja && \
		ninja
	@touch $@

$($(llvm-openmp-13.0.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp-13.0.0)-builddir)/.markerfile $($(llvm-openmp-13.0.0)-prefix)/.pkgbuild
	@touch $@

$($(llvm-openmp-13.0.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp-13.0.0)-builddir)/.markerfile $($(llvm-openmp-13.0.0)-prefix)/.pkgcheck
	cd $($(llvm-openmp-13.0.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-openmp-13.0.0)-builddeps) && \
		ninja install
	@touch $@

$($(llvm-openmp-13.0.0)-modulefile): $(modulefilesdir)/.markerfile $($(llvm-openmp-13.0.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(llvm-openmp-13.0.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(llvm-openmp-13.0.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(llvm-openmp-13.0.0)-description)\"" >>$@
	echo "module-whatis \"$($(llvm-openmp-13.0.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(llvm-openmp-13.0.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LLVM_OPENMP_ROOT $($(llvm-openmp-13.0.0)-prefix)" >>$@
	echo "setenv LLVM_OPENMP_INCDIR $($(llvm-openmp-13.0.0)-prefix)/include" >>$@
	echo "setenv LLVM_OPENMP_INCLUDEDIR $($(llvm-openmp-13.0.0)-prefix)/include" >>$@
	echo "setenv LLVM_OPENMP_LIBDIR $($(llvm-openmp-13.0.0)-prefix)/lib" >>$@
	echo "setenv LLVM_OPENMP_LIBRARYDIR $($(llvm-openmp-13.0.0)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(llvm-openmp-13.0.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(llvm-openmp-13.0.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(llvm-openmp-13.0.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(llvm-openmp-13.0.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(llvm-openmp-13.0.0)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(llvm-openmp-13.0.0)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(llvm-openmp-13.0.0)-prefix)/cmake/llvm-openmp" >>$@
	echo "set MSG \"$(llvm-openmp-13.0.0)\"" >>$@

$(llvm-openmp-13.0.0)-src: $($(llvm-openmp-13.0.0)-src)
$(llvm-openmp-13.0.0)-unpack: $($(llvm-openmp-13.0.0)-prefix)/.pkgunpack
$(llvm-openmp-13.0.0)-patch: $($(llvm-openmp-13.0.0)-prefix)/.pkgpatch
$(llvm-openmp-13.0.0)-build: $($(llvm-openmp-13.0.0)-prefix)/.pkgbuild
$(llvm-openmp-13.0.0)-check: $($(llvm-openmp-13.0.0)-prefix)/.pkgcheck
$(llvm-openmp-13.0.0)-install: $($(llvm-openmp-13.0.0)-prefix)/.pkginstall
$(llvm-openmp-13.0.0)-modulefile: $($(llvm-openmp-13.0.0)-modulefile)
$(llvm-openmp-13.0.0)-clean:
	rm -rf $($(llvm-openmp-13.0.0)-modulefile)
	rm -rf $($(llvm-openmp-13.0.0)-prefix)
	rm -rf $($(llvm-openmp-13.0.0)-srcdir)
	rm -rf $($(llvm-openmp-13.0.0)-src)
$(llvm-openmp-13.0.0): $(llvm-openmp-13.0.0)-src $(llvm-openmp-13.0.0)-unpack $(llvm-openmp-13.0.0)-patch $(llvm-openmp-13.0.0)-build $(llvm-openmp-13.0.0)-check $(llvm-openmp-13.0.0)-install $(llvm-openmp-13.0.0)-modulefile
