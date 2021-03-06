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
# clang-11.0.0

clang-version = 11.0.0
clang = clang-$(clang-version)
$(clang)-description = Compiler front-end based on LLVM
$(clang)-url = https://clang.llvm.org/
$(clang)-srcurl = https://github.com/llvm/llvm-project/releases/download/llvmorg-$(clang-version)/clang-$(clang-version).src.tar.xz
$(clang)-builddeps = $(gcc) $(cmake) $(ninja) $(libffi) $(libpfm) $(llvm) $(llvm-openmp)
$(clang)-prereqs = $(libffi) $(libpfm) $(llvm) $(llvm-openmp)
$(clang)-src = $(pkgsrcdir)/$(notdir $($(clang)-srcurl))
$(clang)-srcdir = $(pkgsrcdir)/$(clang)
$(clang)-builddir = $($(clang)-srcdir)/build
$(clang)-modulefile = $(modulefilesdir)/$(clang)
$(clang)-prefix = $(pkgdir)/$(clang)

$($(clang)-src): $(dir $($(clang)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(clang)-srcurl)

$($(clang)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(clang)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(clang)-prefix)/.pkgunpack: $($(clang)-src) $($(clang)-srcdir)/.markerfile $($(clang)-prefix)/.markerfile
	tar -C $($(clang)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(clang)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(clang)-builddir),$($(clang)-srcdir))
$($(clang)-builddir)/.markerfile: $($(clang)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(clang)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang)-builddir)/.markerfile $($(clang)-prefix)/.pkgpatch
	cd $($(clang)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(clang)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(clang)-prefix) \
			-DCMAKE_BUILD_TYPE=Release \
			-DLLVM_LINK_LLVM_DYLIB=ON \
			-DLLVM_ENABLE_RTTI=ON \
			-Wno-dev -G Ninja && \
		ninja
	@touch $@

$($(clang)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang)-builddir)/.markerfile $($(clang)-prefix)/.pkgbuild
	@touch $@

$($(clang)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang)-builddir)/.markerfile $($(clang)-prefix)/.pkgcheck
	cd $($(clang)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(clang)-builddeps) && \
		ninja install
	@touch $@

$($(clang)-modulefile): $(modulefilesdir)/.markerfile $($(clang)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(clang)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(clang)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(clang)-description)\"" >>$@
	echo "module-whatis \"$($(clang)-url)\"" >>$@
	printf "$(foreach prereq,$($(clang)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CLANG_ROOT $($(clang)-prefix)" >>$@
	echo "setenv CLANG_INCDIR $($(clang)-prefix)/include" >>$@
	echo "setenv CLANG_INCLUDEDIR $($(clang)-prefix)/include" >>$@
	echo "setenv CLANG_LIBDIR $($(clang)-prefix)/lib" >>$@
	echo "setenv CLANG_LIBRARYDIR $($(clang)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(clang)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(clang)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(clang)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(clang)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(clang)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(clang)-prefix)/lib/cmake/clang" >>$@
	echo "prepend-path MANPATH $($(clang)-prefix)/share/man" >>$@
	echo "set MSG \"$(clang)\"" >>$@

$(clang)-src: $($(clang)-src)
$(clang)-unpack: $($(clang)-prefix)/.pkgunpack
$(clang)-patch: $($(clang)-prefix)/.pkgpatch
$(clang)-build: $($(clang)-prefix)/.pkgbuild
$(clang)-check: $($(clang)-prefix)/.pkgcheck
$(clang)-install: $($(clang)-prefix)/.pkginstall
$(clang)-modulefile: $($(clang)-modulefile)
$(clang)-clean:
	rm -rf $($(clang)-modulefile)
	rm -rf $($(clang)-prefix)
	rm -rf $($(clang)-srcdir)
	rm -rf $($(clang)-src)
$(clang): $(clang)-src $(clang)-unpack $(clang)-patch $(clang)-build $(clang)-check $(clang)-install $(clang)-modulefile
