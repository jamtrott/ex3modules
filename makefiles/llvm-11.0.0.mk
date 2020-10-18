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
$(llvm)-builddeps = $(gcc-10.1.0) $(cmake) $(ninja) $(libffi)
$(llvm)-prereqs = $(libstdcxx) $(libffi)
$(llvm)-src = $(pkgsrcdir)/$(notdir $($(llvm)-srcurl))
$(llvm)-srcdir = $(pkgsrcdir)/$(llvm)
$(llvm)-builddir = $($(llvm)-srcdir)/build
$(llvm)-modulefile = $(modulefilesdir)/$(llvm)
$(llvm)-prefix = $(pkgdir)/$(llvm)

$($(llvm)-src): $(dir $($(llvm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(llvm)-srcurl)

$($(llvm)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(llvm)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(llvm)-prefix)/.pkgunpack: $($(llvm)-src) $($(llvm)-srcdir)/.markerfile $($(llvm)-prefix)/.markerfile
	tar -C $($(llvm)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(llvm)-srcdir)/0001-Fix-install-directory-permissions.patch: $($(llvm)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 6ae293b7dd0bc8d05ae0b24e14f45363908e7135 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Fri, 27 Nov 2020 09:54:16 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Fix install directory permissions' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' CMakeLists.txt               | 4 ++++' >>$@.tmp
	@echo ' cmake/modules/CMakeLists.txt | 1 +' >>$@.tmp
	@echo ' 2 files changed, 5 insertions(+)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/CMakeLists.txt b/CMakeLists.txt' >>$@.tmp
	@echo 'index 038139a..10643d3 100644' >>$@.tmp
	@echo '--- a/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/CMakeLists.txt' >>$@.tmp
	@echo '@@ -1109,6 +1109,7 @@ endif()' >>$@.tmp
	@echo ' if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '   install(DIRECTORY include/llvm include/llvm-c' >>$@.tmp
	@echo '     DESTINATION include' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     COMPONENT llvm-headers' >>$@.tmp
	@echo '     FILES_MATCHING' >>$@.tmp
	@echo '     PATTERN "*.def"' >>$@.tmp
	@echo '@@ -1121,6 +1122,7 @@ if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '   install(DIRECTORY $${LLVM_INCLUDE_DIR}/llvm $${LLVM_INCLUDE_DIR}/llvm-c' >>$@.tmp
	@echo '     DESTINATION include' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     COMPONENT llvm-headers' >>$@.tmp
	@echo '     FILES_MATCHING' >>$@.tmp
	@echo '     PATTERN "*.def"' >>$@.tmp
	@echo '@@ -1136,12 +1138,14 @@ if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '   if (LLVM_INSTALL_MODULEMAPS)' >>$@.tmp
	@echo '     install(DIRECTORY include/llvm include/llvm-c' >>$@.tmp
	@echo '             DESTINATION include' >>$@.tmp
	@echo '+            DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '             COMPONENT llvm-headers' >>$@.tmp
	@echo '             FILES_MATCHING' >>$@.tmp
	@echo '             PATTERN "module.modulemap"' >>$@.tmp
	@echo '             )' >>$@.tmp
	@echo '     install(FILES include/llvm/module.install.modulemap' >>$@.tmp
	@echo '             DESTINATION include/llvm' >>$@.tmp
	@echo '+            DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '             COMPONENT llvm-headers' >>$@.tmp
	@echo '             RENAME "module.extern.modulemap"' >>$@.tmp
	@echo '             )' >>$@.tmp
	@echo 'diff --git a/cmake/modules/CMakeLists.txt b/cmake/modules/CMakeLists.txt' >>$@.tmp
	@echo 'index 4b8879f..2f5add6 100644' >>$@.tmp
	@echo '--- a/cmake/modules/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/cmake/modules/CMakeLists.txt' >>$@.tmp
	@echo '@@ -150,6 +150,7 @@ if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '   install(DIRECTORY .' >>$@.tmp
	@echo '     DESTINATION $${LLVM_INSTALL_PACKAGE_DIR}' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     COMPONENT cmake-exports' >>$@.tmp
	@echo '     FILES_MATCHING PATTERN *.cmake' >>$@.tmp
	@echo '     PATTERN .svn EXCLUDE' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(llvm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(llvm)-builddeps),$(modulefilesdir)/$$(dep)) $($(llvm)-prefix)/.pkgunpack $($(llvm)-srcdir)/0001-Fix-install-directory-permissions.patch
	cd $($(llvm)-srcdir) && patch -t -p1 <0001-Fix-install-directory-permissions.patch
	@touch $@

ifneq ($($(llvm)-builddir),$($(llvm)-srcdir))
$($(llvm)-builddir)/.markerfile: $($(llvm)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
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
	cd $($(llvm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(llvm)-builddeps) && \
		ninja check
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
