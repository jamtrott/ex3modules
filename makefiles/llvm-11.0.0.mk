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
# llvm-11.0.0

llvm-version = 11.0.0
llvm = llvm-$(llvm-version)
$(llvm)-description = LLVM Compiler Infrastructure
$(llvm)-url = https://llvm.org/
$(llvm)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(llvm-version)/llvm-$(llvm-version).src.tar.xz
$(llvm)-builddeps = $(gcc) $(cmake) $(ninja) $(libffi)
$(llvm)-prereqs = $(libstdcxx) $(libffi)
$(llvm)-src = $(pkgsrcdir)/$(notdir $($(llvm)-srcurl))
$(llvm)-srcdir = $(pkgsrcdir)/$(llvm)
$(llvm)-builddir = $($(llvm)-srcdir)/build
$(llvm)-modulefile = $(modulefilesdir)/$(llvm)
$(llvm)-prefix = $(pkgdir)/$(llvm)

$($(llvm)-src): $(dir $($(llvm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(llvm)-srcurl)

$($(llvm)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(llvm)-prefix)/.pkgunpack: $($(llvm)-src) $($(llvm)-srcdir)/.markerfile $($(llvm)-prefix)/.markerfile
	tar -C $($(llvm)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(llvm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(llvm)-builddir),$($(llvm)-srcdir))
$($(llvm)-builddir)/.markerfile: $($(llvm)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(llvm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm)-builddir)/.markerfile $($(llvm)-prefix)/.pkgpatch
	cd $($(llvm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(llvm)-prefix) \
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

$($(llvm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm)-builddir)/.markerfile $($(llvm)-prefix)/.pkgbuild
# 	cd $($(llvm)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(llvm)-builddeps) && \
# 		ninja check
	@touch $@

$($(llvm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm)-builddir)/.markerfile $($(llvm)-prefix)/.pkgcheck
	cd $($(llvm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm)-builddeps) && \
		ninja install
	@touch $@

$($(llvm)-modulefile): $(modulefilesdir)/.markerfile $($(llvm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(llvm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(llvm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(llvm)-description)\"" >>$@
	echo "module-whatis \"$($(llvm)-url)\"" >>$@
	printf "$(foreach prereq,$($(llvm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LLVM_ROOT $($(llvm)-prefix)" >>$@
	echo "setenv LLVM_INCDIR $($(llvm)-prefix)/include" >>$@
	echo "setenv LLVM_INCLUDEDIR $($(llvm)-prefix)/include" >>$@
	echo "setenv LLVM_LIBDIR $($(llvm)-prefix)/lib" >>$@
	echo "setenv LLVM_LIBRARYDIR $($(llvm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(llvm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(llvm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(llvm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(llvm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(llvm)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(llvm)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(llvm)-prefix)/cmake/llvm" >>$@
	echo "set MSG \"$(llvm)\"" >>$@

$(llvm)-src: $($(llvm)-src)
$(llvm)-unpack: $($(llvm)-prefix)/.pkgunpack
$(llvm)-patch: $($(llvm)-prefix)/.pkgpatch
$(llvm)-build: $($(llvm)-prefix)/.pkgbuild
$(llvm)-check: $($(llvm)-prefix)/.pkgcheck
$(llvm)-install: $($(llvm)-prefix)/.pkginstall
$(llvm)-modulefile: $($(llvm)-modulefile)
$(llvm)-clean:
	rm -rf $($(llvm)-modulefile)
	rm -rf $($(llvm)-prefix)
	rm -rf $($(llvm)-srcdir)
	rm -rf $($(llvm)-src)
$(llvm): $(llvm)-src $(llvm)-unpack $(llvm)-patch $(llvm)-build $(llvm)-check $(llvm)-install $(llvm)-modulefile
