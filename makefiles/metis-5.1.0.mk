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
# metis-5.1.0

metis-version = 5.1.0
metis = metis-$(metis-version)
$(metis)-description = Serial Graph Partitioning and Fill-reducing Matrix Ordering
$(metis)-url = http://glaros.dtc.umn.edu/gkhome/metis/metis/overview
$(metis)-srcurl = $($(metis-src)-srcurl)
$(metis)-builddeps = $(cmake)
$(metis)-prereqs =
$(metis)-src = $($(metis-src)-src)
$(metis)-srcdir = $(pkgsrcdir)/$(metis)
$(metis)-builddir = $($(metis)-srcdir)/build
$(metis)-modulefile = $(modulefilesdir)/$(metis)
$(metis)-prefix = $(pkgdir)/$(metis)

$($(metis)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(metis)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(metis)-prefix)/.pkgunpack: $$($(metis)-src) $($(metis)-srcdir)/.markerfile $($(metis)-prefix)/.markerfile $$(foreach dep,$$($(metis)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(metis)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(metis)-srcdir)/0001-add_gklib_headers_to_install_into_include.patch: $($(metis)-prefix)/.pkgunpack
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

$($(metis)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis)-prefix)/.pkgunpack $($(metis)-srcdir)/0001-add_gklib_headers_to_install_into_include.patch
	cd $($(metis)-srcdir) && \
		patch -f -p1 <0001-add_gklib_headers_to_install_into_include.patch
	@touch $@

ifneq ($($(metis)-builddir),$($(metis)-srcdir))
$($(metis)-builddir)/.markerfile: $($(metis)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(metis)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis)-builddir)/.markerfile $($(metis)-prefix)/.pkgpatch
	cd $($(metis)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(metis)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(metis)-prefix) \
			-DSHARED=1 \
			-DGKLIB_PATH=$($(metis)-srcdir)/GKlib && \
		$(MAKE)
	@touch $@

$($(metis)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis)-builddir)/.markerfile $($(metis)-prefix)/.pkgbuild
	@touch $@

$($(metis)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(metis)-builddeps),$(modulefilesdir)/$$(dep)) $($(metis)-builddir)/.markerfile $($(metis)-prefix)/.pkgcheck
	cd $($(metis)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(metis)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(metis)-modulefile): $(modulefilesdir)/.markerfile $($(metis)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(metis)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(metis)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(metis)-description)\"" >>$@
	echo "module-whatis \"$($(metis)-url)\"" >>$@
	printf "$(foreach prereq,$($(metis)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv METIS_ROOT $($(metis)-prefix)" >>$@
	echo "setenv METIS_INCDIR $($(metis)-prefix)/include" >>$@
	echo "setenv METIS_INCLUDEDIR $($(metis)-prefix)/include" >>$@
	echo "setenv METIS_LIBDIR $($(metis)-prefix)/lib" >>$@
	echo "setenv METIS_LIBRARYDIR $($(metis)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(metis)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(metis)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(metis)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(metis)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(metis)-prefix)/lib" >>$@
	echo "set MSG \"$(metis)\"" >>$@

$(metis)-src: $($(metis)-src)
$(metis)-unpack: $($(metis)-prefix)/.pkgunpack
$(metis)-patch: $($(metis)-prefix)/.pkgpatch
$(metis)-build: $($(metis)-prefix)/.pkgbuild
$(metis)-check: $($(metis)-prefix)/.pkgcheck
$(metis)-install: $($(metis)-prefix)/.pkginstall
$(metis)-modulefile: $($(metis)-modulefile)
$(metis)-clean:
	rm -rf $($(metis)-modulefile)
	rm -rf $($(metis)-prefix)
	rm -rf $($(metis)-srcdir)
	rm -rf $($(metis)-src)
$(metis): $(metis)-src $(metis)-unpack $(metis)-patch $(metis)-build $(metis)-check $(metis)-install $(metis)-modulefile
