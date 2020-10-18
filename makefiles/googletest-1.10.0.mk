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
# googletest-1.10.0

googletest-version = 1.10.0
googletest = googletest-$(googletest-version)
$(googletest)-description = Google Testing and Mocking Framework
$(googletest)-url = https://github.com/google/googletest/
$(googletest)-srcurl = https://github.com/google/googletest/archive/release-$(googletest-version).tar.gz
$(googletest)-builddeps = $(cmake)
$(googletest)-prereqs =
$(googletest)-src = $(pkgsrcdir)/$(notdir $($(googletest)-srcurl))
$(googletest)-srcdir = $(pkgsrcdir)/$(googletest)
$(googletest)-builddir = $($(googletest)-srcdir)/build
$(googletest)-modulefile = $(modulefilesdir)/$(googletest)
$(googletest)-prefix = $(pkgdir)/$(googletest)

$($(googletest)-src): $(dir $($(googletest)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(googletest)-srcurl)

$($(googletest)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(googletest)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(googletest)-prefix)/.pkgunpack: $($(googletest)-src) $($(googletest)-srcdir)/.markerfile $($(googletest)-prefix)/.markerfile
	tar -C $($(googletest)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(googletest)-srcdir)/0001-Fix-install-directory-permissions.patch: $($(googletest)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 92b26c56fbcd9f3536358ac308c4a0584352f4b8 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Mon, 30 Nov 2020 18:47:33 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Fix install directory permissions' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' googletest/cmake/internal_utils.cmake | 3 ++-' >>$@.tmp
	@echo ' 1 file changed, 2 insertions(+), 1 deletion(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/googletest/cmake/internal_utils.cmake b/googletest/cmake/internal_utils.cmake' >>$@.tmp
	@echo 'index 2f70f0b..48a21ef 100644' >>$@.tmp
	@echo '--- a/googletest/cmake/internal_utils.cmake' >>$@.tmp
	@echo '+++ b/googletest/cmake/internal_utils.cmake' >>$@.tmp
	@echo '@@ -327,7 +327,8 @@ endfunction()' >>$@.tmp
	@echo ' function(install_project)' >>$@.tmp
	@echo '   if(INSTALL_GTEST)' >>$@.tmp
	@echo '     install(DIRECTORY "$${PROJECT_SOURCE_DIR}/include/"' >>$@.tmp
	@echo '-      DESTINATION "$${CMAKE_INSTALL_INCLUDEDIR}")' >>$@.tmp
	@echo '+      DESTINATION "$${CMAKE_INSTALL_INCLUDEDIR}"' >>$@.tmp
	@echo '+      DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE)' >>$@.tmp
	@echo '     # Install the project targets.' >>$@.tmp
	@echo '     install(TARGETS $${ARGN}' >>$@.tmp
	@echo '       EXPORT $${targets_export_name}' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(googletest)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(googletest)-builddeps),$(modulefilesdir)/$$(dep)) $($(googletest)-prefix)/.pkgunpack $($(googletest)-srcdir)/0001-Fix-install-directory-permissions.patch
	cd $($(googletest)-srcdir) && patch -t -p1 <0001-Fix-install-directory-permissions.patch
	@touch $@

ifneq ($($(googletest)-builddir),$($(googletest)-srcdir))
$($(googletest)-builddir)/.markerfile: $($(googletest)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(googletest)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(googletest)-builddeps),$(modulefilesdir)/$$(dep)) $($(googletest)-builddir)/.markerfile $($(googletest)-prefix)/.pkgpatch
	cd $($(googletest)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(googletest)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(googletest)-prefix) \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE)
	@touch $@

$($(googletest)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(googletest)-builddeps),$(modulefilesdir)/$$(dep)) $($(googletest)-builddir)/.markerfile $($(googletest)-prefix)/.pkgbuild
	@touch $@

$($(googletest)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(googletest)-builddeps),$(modulefilesdir)/$$(dep)) $($(googletest)-builddir)/.markerfile $($(googletest)-prefix)/.pkgcheck
	cd $($(googletest)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(googletest)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(googletest)-modulefile): $(modulefilesdir)/.markerfile $($(googletest)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(googletest)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(googletest)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(googletest)-description)\"" >>$@
	echo "module-whatis \"$($(googletest)-url)\"" >>$@
	printf "$(foreach prereq,$($(googletest)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GTEST_ROOT $($(googletest)-prefix)" >>$@
	echo "setenv GMOCK_ROOT $($(googletest)-prefix)" >>$@
	echo "setenv GOOGLETEST_ROOT $($(googletest)-prefix)" >>$@
	echo "setenv GOOGLETEST_INCDIR $($(googletest)-prefix)/include" >>$@
	echo "setenv GOOGLETEST_INCLUDEDIR $($(googletest)-prefix)/include" >>$@
	echo "setenv GOOGLETEST_LIBDIR $($(googletest)-prefix)/lib" >>$@
	echo "setenv GOOGLETEST_LIBRARYDIR $($(googletest)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(googletest)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(googletest)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(googletest)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(googletest)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(googletest)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(googletest)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(googletest)-prefix)/lib/cmake/GTest" >>$@
	echo "set MSG \"$(googletest)\"" >>$@

$(googletest)-src: $($(googletest)-src)
$(googletest)-unpack: $($(googletest)-prefix)/.pkgunpack
$(googletest)-patch: $($(googletest)-prefix)/.pkgpatch
$(googletest)-build: $($(googletest)-prefix)/.pkgbuild
$(googletest)-check: $($(googletest)-prefix)/.pkgcheck
$(googletest)-install: $($(googletest)-prefix)/.pkginstall
$(googletest)-modulefile: $($(googletest)-modulefile)
$(googletest)-clean:
	rm -rf $($(googletest)-modulefile)
	rm -rf $($(googletest)-prefix)
	rm -rf $($(googletest)-srcdir)
	rm -rf $($(googletest)-src)
$(googletest): $(googletest)-src $(googletest)-unpack $(googletest)-patch $(googletest)-build $(googletest)-check $(googletest)-install $(googletest)-modulefile
