# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# clang-13.0.0

clang-13.0.0-version = 13.0.0
clang-13.0.0 = clang-$(clang-13.0.0-version)
$(clang-13.0.0)-description = Compiler front-end based on LLVM
$(clang-13.0.0)-url = https://clang.llvm.org/
$(clang-13.0.0)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(clang-13.0.0-version)/clang-$(clang-13.0.0-version).src.tar.xz
$(clang-13.0.0)-builddeps = $(gcc) $(cmake) $(ninja) $(libffi) $(libpfm) $(llvm-13.0.0) $(llvm-openmp-13.0.0)
$(clang-13.0.0)-prereqs = $(libffi) $(libpfm) $(llvm-13.0.0) $(llvm-openmp-13.0.0)
$(clang-13.0.0)-src = $(pkgsrcdir)/$(notdir $($(clang-13.0.0)-srcurl))
$(clang-13.0.0)-srcdir = $(pkgsrcdir)/$(clang-13.0.0)
$(clang-13.0.0)-builddir = $($(clang-13.0.0)-srcdir)/build
$(clang-13.0.0)-modulefile = $(modulefilesdir)/$(clang-13.0.0)
$(clang-13.0.0)-prefix = $(pkgdir)/$(clang-13.0.0)

$($(clang-13.0.0)-src): $(dir $($(clang-13.0.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(clang-13.0.0)-srcurl)

$($(clang-13.0.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(clang-13.0.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(clang-13.0.0)-prefix)/.pkgunpack: $($(clang-13.0.0)-src) $($(clang-13.0.0)-srcdir)/.markerfile $($(clang-13.0.0)-prefix)/.markerfile
	tar -C $($(clang-13.0.0)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(clang-13.0.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang-13.0.0)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(clang-13.0.0)-builddir),$($(clang-13.0.0)-srcdir))
$($(clang-13.0.0)-builddir)/.markerfile: $($(clang-13.0.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(clang-13.0.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang-13.0.0)-builddir)/.markerfile $($(clang-13.0.0)-prefix)/.pkgpatch
	cd $($(clang-13.0.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(clang-13.0.0)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(clang-13.0.0)-prefix) \
			-DCMAKE_BUILD_TYPE=Release \
			-DLLVM_LINK_LLVM_DYLIB=ON \
			-DLLVM_ENABLE_RTTI=ON \
			-Wno-dev -G Ninja && \
		ninja
	@touch $@

$($(clang-13.0.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang-13.0.0)-builddir)/.markerfile $($(clang-13.0.0)-prefix)/.pkgbuild
	@touch $@

$($(clang-13.0.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang-13.0.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang-13.0.0)-builddir)/.markerfile $($(clang-13.0.0)-prefix)/.pkgcheck
	cd $($(clang-13.0.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(clang-13.0.0)-builddeps) && \
		ninja install
	@touch $@

$($(clang-13.0.0)-modulefile): $(modulefilesdir)/.markerfile $($(clang-13.0.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(clang-13.0.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(clang-13.0.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(clang-13.0.0)-description)\"" >>$@
	echo "module-whatis \"$($(clang-13.0.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(clang-13.0.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CLANG_ROOT $($(clang-13.0.0)-prefix)" >>$@
	echo "setenv CLANG_INCDIR $($(clang-13.0.0)-prefix)/include" >>$@
	echo "setenv CLANG_INCLUDEDIR $($(clang-13.0.0)-prefix)/include" >>$@
	echo "setenv CLANG_LIBDIR $($(clang-13.0.0)-prefix)/lib" >>$@
	echo "setenv CLANG_LIBRARYDIR $($(clang-13.0.0)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(clang-13.0.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(clang-13.0.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(clang-13.0.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(clang-13.0.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(clang-13.0.0)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(clang-13.0.0)-prefix)/lib/cmake/clang" >>$@
	echo "prepend-path MANPATH $($(clang-13.0.0)-prefix)/share/man" >>$@
	echo "set MSG \"$(clang-13.0.0)\"" >>$@

$(clang-13.0.0)-src: $($(clang-13.0.0)-src)
$(clang-13.0.0)-unpack: $($(clang-13.0.0)-prefix)/.pkgunpack
$(clang-13.0.0)-patch: $($(clang-13.0.0)-prefix)/.pkgpatch
$(clang-13.0.0)-build: $($(clang-13.0.0)-prefix)/.pkgbuild
$(clang-13.0.0)-check: $($(clang-13.0.0)-prefix)/.pkgcheck
$(clang-13.0.0)-install: $($(clang-13.0.0)-prefix)/.pkginstall
$(clang-13.0.0)-modulefile: $($(clang-13.0.0)-modulefile)
$(clang-13.0.0)-clean:
	rm -rf $($(clang-13.0.0)-modulefile)
	rm -rf $($(clang-13.0.0)-prefix)
	rm -rf $($(clang-13.0.0)-srcdir)
	rm -rf $($(clang-13.0.0)-src)
$(clang-13.0.0): $(clang-13.0.0)-src $(clang-13.0.0)-unpack $(clang-13.0.0)-patch $(clang-13.0.0)-build $(clang-13.0.0)-check $(clang-13.0.0)-install $(clang-13.0.0)-modulefile
