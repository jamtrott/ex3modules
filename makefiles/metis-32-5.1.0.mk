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
# metis-32-5.1.0

metis-32-version = 5.1.0
metis-32 = metis-32-$(metis-32-version)
$(metis-32)-description = Serial Graph Partitioning and Fill-reducing Matrix Ordering
$(metis-32)-url = http://glaros.dtc.umn.edu/gkhome/metis/metis/overview
$(metis-32)-srcurl = $($(metis-src)-srcurl)
$(metis-32)-builddeps = $(cmake)
$(metis-32)-prereqs =
$(metis-32)-src = $($(metis-src)-src)
$(metis-32)-srcdir = $(pkgsrcdir)/$(metis-32)
$(metis-32)-builddir = $($(metis-32)-srcdir)/build
$(metis-32)-modulefile = $(modulefilesdir)/$(metis-32)
$(metis-32)-prefix = $(pkgdir)/$(metis-32)

$($(metis-32)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(metis-32)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(metis-32)-prefix)/.pkgunpack: $$($(metis-32)-src) $($(metis-32)-srcdir)/.markerfile $($(metis-32)-prefix)/.markerfile $$(foreach dep,$$($(metis-32)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(metis-32)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(metis-32)-srcdir)/0001-add_gklib_headers_to_install_into_include.patch: $($(metis-32)-prefix)/.pkgunpack
	@printf "" >$@.tmp
	@echo '# HG changeset patch' >>$@.tmp
	@echo '# User Sean Farley <sean@mcs.anl.gov>' >>$@.tmp
	@echo '# Date 1332269671 18000' >>$@.tmp
	@echo '#      Tue Mar 20 13:54:31 2012 -0500' >>$@.tmp
	@echo '# Node ID b95c0c2e1d8bf8e3273f7d45e856f0c0127d998e' >>$@.tmp
	@echo '# Parent  88049269953c67c3fdcc4309bf901508a875f0dc' >>$@.tmp
	@echo 'cmake: add gklib headers to install into include' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff -r 88049269953c -r b95c0c2e1d8b libmetis/CMakeLists.txt' >>$@.tmp
	@echo 'Index: libmetis/CMakeLists.txt' >>$@.tmp
	@echo '===================================================================' >>$@.tmp
	@echo '--- a/libmetis/CMakeLists.txt Tue Mar 20 13:54:29 2012 -0500' >>$@.tmp
	@echo '+++ b/libmetis/CMakeLists.txt Tue Mar 20 13:54:31 2012 -0500' >>$@.tmp
	@echo '@@ -12,6 +12,8 @@ endif()' >>$@.tmp
	@echo ' if(METIS_INSTALL)' >>$@.tmp
	@echo '   install(TARGETS metis' >>$@.tmp
	@echo '     LIBRARY DESTINATION lib' >>$@.tmp
	@echo '     RUNTIME DESTINATION lib' >>$@.tmp
	@echo '     ARCHIVE DESTINATION lib)' >>$@.tmp
	@echo '+  install(FILES gklib_defs.h DESTINATION include)' >>$@.tmp
	@echo '+  install(FILES gklib_rename.h DESTINATION include)' >>$@.tmp
	@echo ' endif()' >>$@.tmp
	@mv $@.tmp $@

$($(metis-32)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-32)-prefix)/.pkgunpack $($(metis-32)-srcdir)/0001-add_gklib_headers_to_install_into_include.patch
	cd $($(metis-32)-srcdir) && \
		patch -f -p1 <0001-add_gklib_headers_to_install_into_include.patch
	@touch $@

ifneq ($($(metis-32)-builddir),$($(metis-32)-srcdir))
$($(metis-32)-builddir)/.markerfile: $($(metis-32)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(metis-32)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-32)-builddir)/.markerfile $($(metis-32)-prefix)/.pkgpatch
	cd $($(metis-32)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(metis-32)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(metis-32)-prefix) \
			-DSHARED=1 \
			-DGKLIB_PATH=$($(metis-32)-srcdir)/GKlib && \
		$(MAKE)
	@touch $@

$($(metis-32)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-32)-builddir)/.markerfile $($(metis-32)-prefix)/.pkgbuild
	@touch $@

$($(metis-32)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-32)-builddir)/.markerfile $($(metis-32)-prefix)/.pkgcheck
	cd $($(metis-32)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(metis-32)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(metis-32)-modulefile): $(modulefilesdir)/.markerfile $($(metis-32)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(metis-32)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(metis-32)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(metis-32)-description)\"" >>$@
	echo "module-whatis \"$($(metis-32)-url)\"" >>$@
	printf "$(foreach prereq,$($(metis-32)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv METIS_ROOT $($(metis-32)-prefix)" >>$@
	echo "setenv METIS_INCDIR $($(metis-32)-prefix)/include" >>$@
	echo "setenv METIS_INCLUDEDIR $($(metis-32)-prefix)/include" >>$@
	echo "setenv METIS_LIBDIR $($(metis-32)-prefix)/lib" >>$@
	echo "setenv METIS_LIBRARYDIR $($(metis-32)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(metis-32)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(metis-32)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(metis-32)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(metis-32)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(metis-32)-prefix)/lib" >>$@
	echo "set MSG \"$(metis-32)\"" >>$@

$(metis-32)-src: $($(metis-32)-src)
$(metis-32)-unpack: $($(metis-32)-prefix)/.pkgunpack
$(metis-32)-patch: $($(metis-32)-prefix)/.pkgpatch
$(metis-32)-build: $($(metis-32)-prefix)/.pkgbuild
$(metis-32)-check: $($(metis-32)-prefix)/.pkgcheck
$(metis-32)-install: $($(metis-32)-prefix)/.pkginstall
$(metis-32)-modulefile: $($(metis-32)-modulefile)
$(metis-32)-clean:
	rm -rf $($(metis-32)-modulefile)
	rm -rf $($(metis-32)-prefix)
	rm -rf $($(metis-32)-srcdir)
	rm -rf $($(metis-32)-src)
$(metis-32): $(metis-32)-src $(metis-32)-unpack $(metis-32)-patch $(metis-32)-build $(metis-32)-check $(metis-32)-install $(metis-32)-modulefile
