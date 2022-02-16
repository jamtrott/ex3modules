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
# llvm-openmp-11.0.0

llvm-openmp-version = 11.0.0
llvm-openmp = llvm-openmp-$(llvm-openmp-version)
$(llvm-openmp)-description = LLVM Compiler Infrastructure
$(llvm-openmp)-url = https://llvm.org/
$(llvm-openmp)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(llvm-openmp-version)/openmp-$(llvm-openmp-version).src.tar.xz
$(llvm-openmp)-builddeps = $(cmake) $(ninja) $(libffi) $(hwloc)
$(llvm-openmp)-prereqs = $(libffi) $(hwloc)
$(llvm-openmp)-src = $(pkgsrcdir)/$(notdir $($(llvm-openmp)-srcurl))
$(llvm-openmp)-srcdir = $(pkgsrcdir)/$(llvm-openmp)
$(llvm-openmp)-builddir = $($(llvm-openmp)-srcdir)/build
$(llvm-openmp)-modulefile = $(modulefilesdir)/$(llvm-openmp)
$(llvm-openmp)-prefix = $(pkgdir)/$(llvm-openmp)

$($(llvm-openmp)-src): $(dir $($(llvm-openmp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(llvm-openmp)-srcurl)

$($(llvm-openmp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-openmp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-openmp)-prefix)/.pkgunpack: $($(llvm-openmp)-src) $($(llvm-openmp)-srcdir)/.markerfile $($(llvm-openmp)-prefix)/.markerfile $$(foreach dep,$$($(llvm-openmp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(llvm-openmp)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(llvm-openmp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(llvm-openmp)-builddir),$($(llvm-openmp)-srcdir))
$($(llvm-openmp)-builddir)/.markerfile: $($(llvm-openmp)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(llvm-openmp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp)-builddir)/.markerfile $($(llvm-openmp)-prefix)/.pkgpatch
	cd $($(llvm-openmp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-openmp)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(llvm-openmp)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
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

$($(llvm-openmp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp)-builddir)/.markerfile $($(llvm-openmp)-prefix)/.pkgbuild
	@touch $@

$($(llvm-openmp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-openmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-openmp)-builddir)/.markerfile $($(llvm-openmp)-prefix)/.pkgcheck
	cd $($(llvm-openmp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-openmp)-builddeps) && \
		ninja install
	@touch $@

$($(llvm-openmp)-modulefile): $(modulefilesdir)/.markerfile $($(llvm-openmp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(llvm-openmp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(llvm-openmp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(llvm-openmp)-description)\"" >>$@
	echo "module-whatis \"$($(llvm-openmp)-url)\"" >>$@
	printf "$(foreach prereq,$($(llvm-openmp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LLVM_OPENMP_ROOT $($(llvm-openmp)-prefix)" >>$@
	echo "setenv LLVM_OPENMP_INCDIR $($(llvm-openmp)-prefix)/include" >>$@
	echo "setenv LLVM_OPENMP_INCLUDEDIR $($(llvm-openmp)-prefix)/include" >>$@
	echo "setenv LLVM_OPENMP_LIBDIR $($(llvm-openmp)-prefix)/lib" >>$@
	echo "setenv LLVM_OPENMP_LIBRARYDIR $($(llvm-openmp)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(llvm-openmp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(llvm-openmp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(llvm-openmp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(llvm-openmp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(llvm-openmp)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(llvm-openmp)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(llvm-openmp)-prefix)/cmake/llvm-openmp" >>$@
	echo "set MSG \"$(llvm-openmp)\"" >>$@

$(llvm-openmp)-src: $($(llvm-openmp)-src)
$(llvm-openmp)-unpack: $($(llvm-openmp)-prefix)/.pkgunpack
$(llvm-openmp)-patch: $($(llvm-openmp)-prefix)/.pkgpatch
$(llvm-openmp)-build: $($(llvm-openmp)-prefix)/.pkgbuild
$(llvm-openmp)-check: $($(llvm-openmp)-prefix)/.pkgcheck
$(llvm-openmp)-install: $($(llvm-openmp)-prefix)/.pkginstall
$(llvm-openmp)-modulefile: $($(llvm-openmp)-modulefile)
$(llvm-openmp)-clean:
	rm -rf $($(llvm-openmp)-modulefile)
	rm -rf $($(llvm-openmp)-prefix)
	rm -rf $($(llvm-openmp)-srcdir)
	rm -rf $($(llvm-openmp)-src)
$(llvm-openmp): $(llvm-openmp)-src $(llvm-openmp)-unpack $(llvm-openmp)-patch $(llvm-openmp)-build $(llvm-openmp)-check $(llvm-openmp)-install $(llvm-openmp)-modulefile
