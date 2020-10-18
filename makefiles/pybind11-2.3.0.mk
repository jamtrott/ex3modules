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
# pybind11-2.3.0

pybind11-version = 2.3.0
pybind11 = pybind11-$(pybind11-version)
$(pybind11)-description = Seamless operability between C++11 and Python
$(pybind11)-url = https://github.com/pybind/pybind11
$(pybind11)-srcurl = https://github.com/pybind/pybind11/archive/v$(pybind11-version).tar.gz
$(pybind11)-builddeps = $(boost) $(cmake) $(python) $(python-pytest)
$(pybind11)-prereqs =
$(pybind11)-src = $(pkgsrcdir)/$(notdir $($(pybind11)-srcurl))
$(pybind11)-srcdir = $(pkgsrcdir)/$(pybind11)
$(pybind11)-builddir = $($(pybind11)-srcdir)/build
$(pybind11)-modulefile = $(modulefilesdir)/$(pybind11)
$(pybind11)-prefix = $(pkgdir)/$(pybind11)

$($(pybind11)-src): $(dir $($(pybind11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pybind11)-srcurl)

$($(pybind11)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(pybind11)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(pybind11)-prefix)/.pkgunpack: $($(pybind11)-src) $($(pybind11)-srcdir)/.markerfile $($(pybind11)-prefix)/.markerfile
	tar -C $($(pybind11)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pybind11)-srcdir)/0001-fix-install-directory-permissions.patch: $($(pybind11)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 479482e603b72282bf5db6e7e4d85be611deb2e2 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Mon, 23 Nov 2020 19:58:55 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] Fix install directory permissions' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' CMakeLists.txt | 3 ++-' >>$@.tmp
	@echo ' 1 file changed, 2 insertions(+), 1 deletion(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/CMakeLists.txt b/CMakeLists.txt' >>$@.tmp
	@echo 'index 85ecd90..6420a83 100644' >>$@.tmp
	@echo '--- a/CMakeLists.txt' >>$@.tmp
	@echo '+++ b/CMakeLists.txt' >>$@.tmp
	@echo '@@ -120,7 +120,8 @@ if(NOT (CMAKE_VERSION VERSION_LESS 3.0))  # CMake >= 3.0' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@echo '' >>$@.tmp
	@echo ' if (PYBIND11_INSTALL)' >>$@.tmp
	@echo '-  install(DIRECTORY $${PYBIND11_INCLUDE_DIR}/pybind11 DESTINATION $${CMAKE_INSTALL_INCLUDEDIR})' >>$@.tmp
	@echo '+  install(DIRECTORY $${PYBIND11_INCLUDE_DIR}/pybind11 DESTINATION $${CMAKE_INSTALL_INCLUDEDIR}' >>$@.tmp
	@echo '+    DIRECTORY_PERMISSIONS OWNER_READ OWNER_EXECUTE OWNER_WRITE GROUP_READ GROUP_EXECUTE SETGID WORLD_READ WORLD_EXECUTE)' >>$@.tmp
	@echo '   # GNUInstallDirs "DATADIR" wrong here; CMake search path wants "share".' >>$@.tmp
	@echo '   set(PYBIND11_CMAKECONFIG_INSTALL_DIR "share/cmake/$${PROJECT_NAME}" CACHE STRING "install path for pybind11Config.cmake")' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(pybind11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-prefix)/.pkgunpack $($(pybind11)-srcdir)/0001-fix-install-directory-permissions.patch
	cd $($(pybind11)-srcdir) && \
		patch -t -p1 <0001-fix-install-directory-permissions.patch
	@touch $@

$($(pybind11)-builddir)/.markerfile: $($(pybind11)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(pybind11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-builddir)/.markerfile $($(pybind11)-prefix)/.pkgpatch
	cd $($(pybind11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(pybind11)-prefix) \
			-DCMAKE_INSTALL_DEFAULT_DIRECTORY_PERMISSIONS=OWNER_READ\;OWNER_EXECUTE\;OWNER_WRITE\;GROUP_READ\;GROUP_EXECUTE\;SETGID\;WORLD_READ\;WORLD_EXECUTE \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE)
	@touch $@

$($(pybind11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-builddir)/.markerfile $($(pybind11)-prefix)/.pkgbuild
	cd $($(pybind11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(pybind11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-builddir)/.markerfile $($(pybind11)-prefix)/.pkgcheck
	cd $($(pybind11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(pybind11)-modulefile): $(modulefilesdir)/.markerfile $($(pybind11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pybind11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pybind11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pybind11)-description)\"" >>$@
	echo "module-whatis \"$($(pybind11)-url)\"" >>$@
	printf "$(foreach prereq,$($(pybind11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYBIND11_ROOT $($(pybind11)-prefix)" >>$@
	echo "setenv PYBIND11_INCDIR $($(pybind11)-prefix)/include" >>$@
	echo "setenv PYBIND11_INCLUDEDIR $($(pybind11)-prefix)/include" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pybind11)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pybind11)-prefix)/include" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(pybind11)-prefix)/share/cmake/pybind11" >>$@
	echo "set MSG \"$(pybind11)\"" >>$@

$(pybind11)-src: $($(pybind11)-src)
$(pybind11)-unpack: $($(pybind11)-prefix)/.pkgunpack
$(pybind11)-patch: $($(pybind11)-prefix)/.pkgpatch
$(pybind11)-build: $($(pybind11)-prefix)/.pkgbuild
$(pybind11)-check: $($(pybind11)-prefix)/.pkgcheck
$(pybind11)-install: $($(pybind11)-prefix)/.pkginstall
$(pybind11)-modulefile: $($(pybind11)-modulefile)
$(pybind11)-clean:
	rm -rf $($(pybind11)-modulefile)
	rm -rf $($(pybind11)-prefix)
	rm -rf $($(pybind11)-srcdir)
	rm -rf $($(pybind11)-src)
$(pybind11): $(pybind11)-src $(pybind11)-unpack $(pybind11)-patch $(pybind11)-build $(pybind11)-check $(pybind11)-install $(pybind11)-modulefile
