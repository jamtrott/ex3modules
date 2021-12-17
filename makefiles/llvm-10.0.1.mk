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
# llvm-10.0.1

llvm-10-version = 10.0.1
llvm-10 = llvm-$(llvm-10-version)
$(llvm-10)-description = LLVM Compiler Infrastructure
$(llvm-10)-url = https://llvm.org/
$(llvm-10)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(llvm-10-version)/llvm-$(llvm-10-version).src.tar.xz
$(llvm-10)-builddeps = $(cmake) $(ninja) $(libffi)
$(llvm-10)-prereqs = $(libffi)
$(llvm-10)-src = $(pkgsrcdir)/$(notdir $($(llvm-10)-srcurl))
$(llvm-10)-srcdir = $(pkgsrcdir)/$(llvm-10)
$(llvm-10)-builddir = $($(llvm-10)-srcdir)/build
$(llvm-10)-modulefile = $(modulefilesdir)/$(llvm-10)
$(llvm-10)-prefix = $(pkgdir)/$(llvm-10)

$($(llvm-10)-src): $(dir $($(llvm-10)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(llvm-10)-srcurl)

$($(llvm-10)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-10)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm-10)-prefix)/.pkgunpack: $($(llvm-10)-src) $($(llvm-10)-srcdir)/.markerfile $($(llvm-10)-prefix)/.markerfile $$(foreach dep,$$($(llvm-10)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(llvm-10)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(llvm-10)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-10)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-10)-prefix)/.pkgunpack
	sed -i '4i #include <limits>' $($(llvm-10)-srcdir)/utils/benchmark/src/benchmark_register.h
	@touch $@

ifneq ($($(llvm-10)-builddir),$($(llvm-10)-srcdir))
$($(llvm-10)-builddir)/.markerfile: $($(llvm-10)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(llvm-10)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-10)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-10)-builddir)/.markerfile $($(llvm-10)-prefix)/.pkgpatch
	cd $($(llvm-10)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-10)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(llvm-10)-prefix) \
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

$($(llvm-10)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-10)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-10)-builddir)/.markerfile $($(llvm-10)-prefix)/.pkgbuild
# 	cd $($(llvm-10)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(llvm-10)-builddeps) && \
# 		ninja check
	@touch $@

$($(llvm-10)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm-10)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm-10)-builddir)/.markerfile $($(llvm-10)-prefix)/.pkgcheck
	cd $($(llvm-10)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm-10)-builddeps) && \
		ninja install
	@touch $@

$($(llvm-10)-modulefile): $(modulefilesdir)/.markerfile $($(llvm-10)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(llvm-10)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(llvm-10)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(llvm-10)-description)\"" >>$@
	echo "module-whatis \"$($(llvm-10)-url)\"" >>$@
	printf "$(foreach prereq,$($(llvm-10)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LLVM_ROOT $($(llvm-10)-prefix)" >>$@
	echo "setenv LLVM_INCDIR $($(llvm-10)-prefix)/include" >>$@
	echo "setenv LLVM_INCLUDEDIR $($(llvm-10)-prefix)/include" >>$@
	echo "setenv LLVM_LIBDIR $($(llvm-10)-prefix)/lib" >>$@
	echo "setenv LLVM_LIBRARYDIR $($(llvm-10)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(llvm-10)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(llvm-10)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(llvm-10)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(llvm-10)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(llvm-10)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(llvm-10)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(llvm-10)-prefix)/cmake/llvm" >>$@
	echo "set MSG \"$(llvm-10)\"" >>$@

$(llvm-10)-src: $($(llvm-10)-src)
$(llvm-10)-unpack: $($(llvm-10)-prefix)/.pkgunpack
$(llvm-10)-patch: $($(llvm-10)-prefix)/.pkgpatch
$(llvm-10)-build: $($(llvm-10)-prefix)/.pkgbuild
$(llvm-10)-check: $($(llvm-10)-prefix)/.pkgcheck
$(llvm-10)-install: $($(llvm-10)-prefix)/.pkginstall
$(llvm-10)-modulefile: $($(llvm-10)-modulefile)
$(llvm-10)-clean:
	rm -rf $($(llvm-10)-modulefile)
	rm -rf $($(llvm-10)-prefix)
	rm -rf $($(llvm-10)-srcdir)
	rm -rf $($(llvm-10)-src)
$(llvm-10): $(llvm-10)-src $(llvm-10)-unpack $(llvm-10)-patch $(llvm-10)-build $(llvm-10)-check $(llvm-10)-install $(llvm-10)-modulefile
