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
# metis-64-5.1.0

metis-64-version = 5.1.0
metis-64 = metis-64-$(metis-64-version)
$(metis-64)-description = Serial Graph Partitioning and Fill-reducing Matrix Ordering
$(metis-64)-url = http://glaros.dtc.umn.edu/gkhome/metis/metis/overview
$(metis-64)-srcurl = $($(metis-src)-srcurl)
$(metis-64)-builddeps = $(cmake)
$(metis-64)-prereqs =
$(metis-64)-src = $($(metis-src)-src)
$(metis-64)-srcdir = $(pkgsrcdir)/$(metis-64)
$(metis-64)-builddir = $($(metis-64)-srcdir)/build
$(metis-64)-modulefile = $(modulefilesdir)/$(metis-64)
$(metis-64)-prefix = $(pkgdir)/$(metis-64)

$($(metis-64)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(metis-64)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(metis-64)-prefix)/.pkgunpack: $$($(metis-64)-src) $($(metis-64)-srcdir)/.markerfile $($(metis-64)-prefix)/.markerfile $$(foreach dep,$$($(metis-64)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(metis-64)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(metis-64)-srcdir)/0001-add_gklib_headers_to_install_into_include.patch: $($(metis-64)-prefix)/.pkgunpack
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

$($(metis-64)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-64)-prefix)/.pkgunpack $($(metis-64)-srcdir)/0001-add_gklib_headers_to_install_into_include.patch
	cd $($(metis-64)-srcdir) && \
		patch -f -p1 <0001-add_gklib_headers_to_install_into_include.patch
	sed -i 's,IDXTYPEWIDTH 32,IDXTYPEWIDTH 64,' $($(metis-64)-srcdir)/include/metis.h
	@touch $@

ifneq ($($(metis-64)-builddir),$($(metis-64)-srcdir))
$($(metis-64)-builddir)/.markerfile: $($(metis-64)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(metis-64)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-64)-builddir)/.markerfile $($(metis-64)-prefix)/.pkgpatch
	cd $($(metis-64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(metis-64)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(metis-64)-prefix) \
			-DSHARED=1 \
			-DGKLIB_PATH=$($(metis-64)-srcdir)/GKlib && \
		$(MAKE)
	@touch $@

$($(metis-64)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-64)-builddir)/.markerfile $($(metis-64)-prefix)/.pkgbuild
	@touch $@

$($(metis-64)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis-64)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis-64)-builddir)/.markerfile $($(metis-64)-prefix)/.pkgcheck
	cd $($(metis-64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(metis-64)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(metis-64)-modulefile): $(modulefilesdir)/.markerfile $($(metis-64)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(metis-64)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(metis-64)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(metis-64)-description)\"" >>$@
	echo "module-whatis \"$($(metis-64)-url)\"" >>$@
	printf "$(foreach prereq,$($(metis-64)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv METIS_ROOT $($(metis-64)-prefix)" >>$@
	echo "setenv METIS_INCDIR $($(metis-64)-prefix)/include" >>$@
	echo "setenv METIS_INCLUDEDIR $($(metis-64)-prefix)/include" >>$@
	echo "setenv METIS_LIBDIR $($(metis-64)-prefix)/lib" >>$@
	echo "setenv METIS_LIBRARYDIR $($(metis-64)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(metis-64)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(metis-64)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(metis-64)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(metis-64)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(metis-64)-prefix)/lib" >>$@
	echo "set MSG \"$(metis-64)\"" >>$@

$(metis-64)-src: $($(metis-64)-src)
$(metis-64)-unpack: $($(metis-64)-prefix)/.pkgunpack
$(metis-64)-patch: $($(metis-64)-prefix)/.pkgpatch
$(metis-64)-build: $($(metis-64)-prefix)/.pkgbuild
$(metis-64)-check: $($(metis-64)-prefix)/.pkgcheck
$(metis-64)-install: $($(metis-64)-prefix)/.pkginstall
$(metis-64)-modulefile: $($(metis-64)-modulefile)
$(metis-64)-clean:
	rm -rf $($(metis-64)-modulefile)
	rm -rf $($(metis-64)-prefix)
	rm -rf $($(metis-64)-srcdir)
	rm -rf $($(metis-64)-src)
$(metis-64): $(metis-64)-src $(metis-64)-unpack $(metis-64)-patch $(metis-64)-build $(metis-64)-check $(metis-64)-install $(metis-64)-modulefile
