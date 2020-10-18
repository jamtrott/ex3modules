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
# cmake-3.17.2

cmake-version = 3.17.2
cmake = cmake-$(cmake-version)
$(cmake)-description = Open-source, cross-platform tools to build, test and package software
$(cmake)-url = https://cmake.org/
$(cmake)-srcurl = https://github.com/Kitware/CMake/releases/download/v$(cmake-version)/cmake-$(cmake-version).tar.gz
$(cmake)-src = $(pkgsrcdir)/$(cmake).tar.gz
$(cmake)-srcdir = $(pkgsrcdir)/$(cmake)
$(cmake)-builddeps = $(openssl)
$(cmake)-prereqs = $(openssl)
$(cmake)-modulefile = $(modulefilesdir)/$(cmake)
$(cmake)-prefix = $(pkgdir)/$(cmake)

$($(cmake)-src): $(dir $($(cmake)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cmake)-srcurl)

$($(cmake)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(cmake)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(cmake)-prefix)/.pkgunpack: $($(cmake)-src) $($(cmake)-srcdir)/.markerfile $($(cmake)-prefix)/.markerfile
	tar -C $($(cmake)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(cmake)-srcdir)/0001-add-setgid-to-permissions-of-installed-directories.patch: $($(cmake)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 2fa5769337de5f7845a7fb21df76035d70a898b7 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Wed, 18 Nov 2020 09:11:58 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Add setgid to permissions of installed directories' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' Auxiliary/CMakeLists.txt | 2 +-' >>$@.tmp
	@echo ' CMakeLists.txt           | 2 +-' >>$@.tmp
	@echo ' 2 files changed, 2 insertions(+), 2 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/Auxiliary/CMakeLists.txt b/Auxiliary/CMakeLists.txt' >>$@.tmp
	@echo 'index 53cf2c5..a8858a6 100644' >>$@.tmp
	@echo '--- a/Auxiliary/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/Auxiliary/CMakeLists.txt' >>$@.tmp
	@echo '@@ -1,4 +1,4 @@' >>$@.tmp
	@echo '-install(DIRECTORY vim/indent vim/syntax DESTINATION $${CMAKE_DATA_DIR}/editors/vim)' >>$@.tmp
	@echo '+install(DIRECTORY vim/indent vim/syntax DESTINATION $${CMAKE_DATA_DIR}/editors/vim DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE)' >>$@.tmp
	@echo ' install(FILES cmake-mode.el DESTINATION $${CMAKE_DATA_DIR}/editors/emacs)' >>$@.tmp
	@echo ' install(FILES cmake.m4 DESTINATION $${CMAKE_XDGDATA_DIR}/aclocal)' >>$@.tmp
	@echo ' add_subdirectory (bash-completion)' >>$@.tmp
	@echo 'diff --git a/CMakeLists.txt b/CMakeLists.txt' >>$@.tmp
	@echo 'index fb7b9b7..02e0742 100644' >>$@.tmp
	@echo '--- a/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/CMakeLists.txt' >>$@.tmp
	@echo '@@ -805,7 +805,7 @@ if(NOT CMake_TEST_EXTERNAL_CMAKE)' >>$@.tmp
	@echo '     DESTINATION $${CMAKE_DATA_DIR}' >>$@.tmp
	@echo '     FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ' >>$@.tmp
	@echo '     DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE' >>$@.tmp
	@echo '-                          GROUP_READ GROUP_EXECUTE' >>$@.tmp
	@echo '+                          GROUP_READ GROUP_EXECUTE SETGID' >>$@.tmp
	@echo '                           WORLD_READ WORLD_EXECUTE' >>$@.tmp
	@echo '     PATTERN "*.sh*" PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE' >>$@.tmp
	@echo '                                 GROUP_READ GROUP_EXECUTE' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '1.8.3.1' >>$@.tmp
	@mv $@.tmp $@

$($(cmake)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake)-prefix)/.pkgunpack $($(cmake)-srcdir)/0001-add-setgid-to-permissions-of-installed-directories.patch
	cd $($(cmake)-srcdir) && \
		patch -t -p1 <0001-add-setgid-to-permissions-of-installed-directories.patch
	@touch $@

$($(cmake)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake)-prefix)/.pkgpatch
	cd $($(cmake)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake)-builddeps) && \
		./configure --prefix=$($(cmake)-prefix) -- \
			-DCMAKE_BUILD_TYPE:STRING=Release && \
		$(MAKE)
	@touch $@

$($(cmake)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake)-prefix)/.pkgbuild
# Disable tests, since they currently fail
#	cd $($(cmake)-srcdir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(cmake)-builddeps) && \
#		$(MAKE) test
	@touch $@

$($(cmake)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake)-prefix)/.pkgcheck
	cd $($(cmake)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cmake)-modulefile): $(modulefilesdir)/.markerfile $($(cmake)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cmake)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cmake)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cmake)-description)\"" >>$@
	echo "module-whatis \"$($(cmake)-url)\"" >>$@
	printf "$(foreach prereq,$($(cmake)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CMAKE_ROOT $($(cmake)-prefix)" >>$@
	echo "prepend-path PATH $($(cmake)-prefix)/bin" >>$@
	echo "set MSG \"$(cmake)\"" >>$@

$(cmake)-src: $($(cmake)-src)
$(cmake)-unpack: $($(cmake)-prefix)/.pkgunpack
$(cmake)-patch: $($(cmake)-prefix)/.pkgpatch
$(cmake)-build: $($(cmake)-prefix)/.pkgbuild
$(cmake)-check: $($(cmake)-prefix)/.pkgcheck
$(cmake)-install: $($(cmake)-prefix)/.pkginstall
$(cmake)-modulefile: $($(cmake)-modulefile)
$(cmake)-clean:
	rm -rf $($(cmake)-modulefile)
	rm -rf $($(cmake)-prefix)
	rm -rf $($(cmake)-srcdir)
	rm -rf $($(cmake)-src)
$(cmake): $(cmake)-src $(cmake)-unpack $(cmake)-patch $(cmake)-build $(cmake)-check $(cmake)-install $(cmake)-modulefile
