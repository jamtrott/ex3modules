# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# llvm-12.0.1

llvm-12-version = 12.0.1
llvm-12 = llvm-$(llvm-12-version)
$(llvm-12)-description = LLVM Compiler Infrastructure
$(llvm-12)-url = https://llvm.org/
$(llvm-12)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(llvm-12-version)/llvm-$(llvm-12-version).src.tar.xz
$(llvm-12)-builddeps = $(cmake) $(ninja) $(libffi)
$(llvm-12)-prereqs = $(libffi)
$(llvm-12)-src = $(pkgsrcdir)/$(notdir $($(llvm-12)-srcurl))
$(llvm-12)-srcdir = $(pkgsrcdir)/$(llvm-12)
$(llvm-12)-builddir = $($(llvm-12)-srcdir)/build
$(llvm-12)-modulefile = $(modulefilesdir)/$(llvm-12)
$(llvm-12)-prefix = $(pkgdir)/$(llvm-12)

$($(llvm-12)-src): $(dir $($(llvm-12)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(llvm-12)-srcurl)

$($(llvm-12)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-12)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-12)-prefix)/.pkgunpack: $($(llvm-12)-src) $($(llvm-12)-srcdir)/.markerfile $($(llvm-12)-prefix)/.markerfile $$(foreach dep,$$($(llvm-12)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(llvm-12)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(llvm-12)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-12)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-12)-prefix)/.pkgunpack
	sed -i '4i #include <limits>' $($(llvm-12)-srcdir)/utils/benchmark/src/benchmark_register.h
	@touch $@

ifneq ($($(llvm-12)-builddir),$($(llvm-12)-srcdir))
$($(llvm-12)-builddir)/.markerfile: $($(llvm-12)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(llvm-12)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-12)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-12)-builddir)/.markerfile $($(llvm-12)-prefix)/.pkgpatch
	cd $($(llvm-12)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-12)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(llvm-12)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DLLVM_ENABLE_FFI=ON \
			-DFFI_INCLUDE_DIR="$${LIBFFI_INCLUDEDIR}" \
			-DFFI_LIBRARY_DIR="$${LIBFFI_LIBDIR}" \
			-DCMAKE_BUILD_TYPE=Release \
			-DLLVM_BUILD_LLVM_DYLIB=ON \
			-DLLVM_LINK_LLVM_DYLIB=ON \
			-DLLVM_ENABLE_RTTI=ON \
			-DLLVM_ENABLE_BINDINGS=OFF \
			-Wno-dev -G Ninja && \
		ninja
	@touch $@

$($(llvm-12)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-12)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-12)-builddir)/.markerfile $($(llvm-12)-prefix)/.pkgbuild
# 	cd $($(llvm-12)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(llvm-12)-builddeps) && \
# 		ninja check
	@touch $@

$($(llvm-12)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-12)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-12)-builddir)/.markerfile $($(llvm-12)-prefix)/.pkgcheck
	cd $($(llvm-12)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-12)-builddeps) && \
		ninja install
	@touch $@

$($(llvm-12)-modulefile): $(modulefilesdir)/.markerfile $($(llvm-12)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(llvm-12)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(llvm-12)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(llvm-12)-description)\"" >>$@
	echo "module-whatis \"$($(llvm-12)-url)\"" >>$@
	printf "$(foreach prereq,$($(llvm-12)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LLVM_ROOT $($(llvm-12)-prefix)" >>$@
	echo "setenv LLVM_INCDIR $($(llvm-12)-prefix)/include" >>$@
	echo "setenv LLVM_INCLUDEDIR $($(llvm-12)-prefix)/include" >>$@
	echo "setenv LLVM_LIBDIR $($(llvm-12)-prefix)/lib" >>$@
	echo "setenv LLVM_LIBRARYDIR $($(llvm-12)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(llvm-12)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(llvm-12)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(llvm-12)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(llvm-12)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(llvm-12)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(llvm-12)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(llvm-12)-prefix)/cmake/llvm" >>$@
	echo "set MSG \"$(llvm-12)\"" >>$@

$(llvm-12)-src: $($(llvm-12)-src)
$(llvm-12)-unpack: $($(llvm-12)-prefix)/.pkgunpack
$(llvm-12)-patch: $($(llvm-12)-prefix)/.pkgpatch
$(llvm-12)-build: $($(llvm-12)-prefix)/.pkgbuild
$(llvm-12)-check: $($(llvm-12)-prefix)/.pkgcheck
$(llvm-12)-install: $($(llvm-12)-prefix)/.pkginstall
$(llvm-12)-modulefile: $($(llvm-12)-modulefile)
$(llvm-12)-clean:
	rm -rf $($(llvm-12)-modulefile)
	rm -rf $($(llvm-12)-prefix)
	rm -rf $($(llvm-12)-srcdir)
	rm -rf $($(llvm-12)-src)
$(llvm-12): $(llvm-12)-src $(llvm-12)-unpack $(llvm-12)-patch $(llvm-12)-build $(llvm-12)-check $(llvm-12)-install $(llvm-12)-modulefile
