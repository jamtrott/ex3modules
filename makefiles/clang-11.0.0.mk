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
$(clang)-builddeps = $(gcc-10.1.0) $(cmake) $(ninja) $(libffi) $(libpfm) $(llvm) $(llvm-openmp)
$(clang)-prereqs = $(libffi) $(libpfm) $(llvm) $(llvm-openmp)
$(clang)-src = $(pkgsrcdir)/$(notdir $($(clang)-srcurl))
$(clang)-srcdir = $(pkgsrcdir)/$(clang)
$(clang)-builddir = $($(clang)-srcdir)/build
$(clang)-modulefile = $(modulefilesdir)/$(clang)
$(clang)-prefix = $(pkgdir)/$(clang)

$($(clang)-src): $(dir $($(clang)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(clang)-srcurl)

$($(clang)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(clang)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(clang)-prefix)/.pkgunpack: $($(clang)-src) $($(clang)-srcdir)/.markerfile $($(clang)-prefix)/.markerfile
	tar -C $($(clang)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(clang)-srcdir)/0001-Fix-install-directory-permissions.patch: $($(clang)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From a8d2fcffc93c0061e14b3a9c847ef78132e77429 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Fri, 27 Nov 2020 16:24:49 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Fix install directory permissions' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' CMakeLists.txt                | 2 ++' >>$@.tmp
	@echo ' docs/CMakeLists.txt           | 3 ++-' >>$@.tmp
	@echo ' tools/libclang/CMakeLists.txt | 5 ++++-' >>$@.tmp
	@echo ' 3 files changed, 8 insertions(+), 2 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/CMakeLists.txt b/CMakeLists.txt' >>$@.tmp
	@echo 'index 2e06c5fd..a7e4b12a 100644' >>$@.tmp
	@echo '--- a/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/CMakeLists.txt' >>$@.tmp
	@echo '@@ -448,6 +448,7 @@ include_directories(BEFORE' >>$@.tmp
	@echo ' if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '   install(DIRECTORY include/clang include/clang-c' >>$@.tmp
	@echo '     DESTINATION include' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     COMPONENT clang-headers' >>$@.tmp
	@echo '     FILES_MATCHING' >>$@.tmp
	@echo '     PATTERN "*.def"' >>$@.tmp
	@echo '@@ -458,6 +459,7 @@ if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '   install(DIRECTORY $${CMAKE_CURRENT_BINARY_DIR}/include/clang' >>$@.tmp
	@echo '     DESTINATION include' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     COMPONENT clang-headers' >>$@.tmp
	@echo '     FILES_MATCHING' >>$@.tmp
	@echo '     PATTERN "CMakeFiles" EXCLUDE' >>$@.tmp
	@echo 'diff --git a/docs/CMakeLists.txt b/docs/CMakeLists.txt' >>$@.tmp
	@echo 'index 2d3ac5db..efbd9752 100644' >>$@.tmp
	@echo '--- a/docs/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/docs/CMakeLists.txt' >>$@.tmp
	@echo '@@ -85,7 +85,8 @@ if (LLVM_ENABLE_DOXYGEN)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '   if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '     install(DIRECTORY $${CMAKE_CURRENT_BINARY_DIR}/doxygen/html' >>$@.tmp
	@echo '-      DESTINATION docs/html)' >>$@.tmp
	@echo '+      DESTINATION docs/html' >>$@.tmp
	@echo '+      DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE)' >>$@.tmp
	@echo '   endif()' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@echo 'diff --git a/tools/libclang/CMakeLists.txt b/tools/libclang/CMakeLists.txt' >>$@.tmp
	@echo 'index a4077140..80ad8186 100644' >>$@.tmp
	@echo '--- a/tools/libclang/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/tools/libclang/CMakeLists.txt' >>$@.tmp
	@echo '@@ -170,6 +170,7 @@ endif()' >>$@.tmp
	@echo ' install(DIRECTORY ../../include/clang-c' >>$@.tmp
	@echo '   COMPONENT libclang-headers' >>$@.tmp
	@echo '   DESTINATION "$${LIBCLANG_HEADERS_INSTALL_DESTINATION}"' >>$@.tmp
	@echo '+  DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '   FILES_MATCHING' >>$@.tmp
	@echo '   PATTERN "*.h"' >>$@.tmp
	@echo '   PATTERN ".svn" EXCLUDE' >>$@.tmp
	@echo '@@ -195,7 +196,9 @@ foreach(PythonVersion $${CLANG_PYTHON_BINDINGS_VERSIONS})' >>$@.tmp
	@echo '           COMPONENT' >>$@.tmp
	@echo '             libclang-python-bindings' >>$@.tmp
	@echo '           DESTINATION' >>$@.tmp
	@echo '-            "lib$${LLVM_LIBDIR_SUFFIX}/python$${PythonVersion}/site-packages")' >>$@.tmp
	@echo '+            "lib$${LLVM_LIBDIR_SUFFIX}/python$${PythonVersion}/site-packages"' >>$@.tmp
	@echo '+	  DIRECTORY_PERMISSIONS' >>$@.tmp
	@echo '+	    OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE)' >>$@.tmp
	@echo ' endforeach()' >>$@.tmp
	@echo ' if(NOT LLVM_ENABLE_IDE)' >>$@.tmp
	@echo '   add_custom_target(libclang-python-bindings)' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(clang)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(clang)-builddeps),$(modulefilesdir)/$$(dep)) $($(clang)-prefix)/.pkgunpack $($(clang)-srcdir)/0001-Fix-install-directory-permissions.patch
	cd $($(clang)-srcdir) && patch -t -p1 <0001-Fix-install-directory-permissions.patch
	@touch $@

ifneq ($($(clang)-builddir),$($(clang)-srcdir))
$($(clang)-builddir)/.markerfile: $($(clang)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
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
