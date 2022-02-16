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
# parmetis-32-4.0.3

parmetis-32-version = 4.0.3
parmetis-32 = parmetis-32-$(parmetis-32-version)
$(parmetis-32)-description = Parallel Graph Partitioning and Fill-reducing Matrix Ordering
$(parmetis-32)-url = http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview
$(parmetis-32)-srcurl = $($(parmetis-src)-srcurl)
$(parmetis-32)-builddeps = $(cmake) $(mpi) $(metis-32) $(gklib)
$(parmetis-32)-prereqs = $(mpi) $(metis)
$(parmetis-32)-src = $($(parmetis-src)-src)
$(parmetis-32)-srcdir = $(pkgsrcdir)/$(parmetis-32)
$(parmetis-32)-builddir = $($(parmetis-32)-srcdir)/build
$(parmetis-32)-modulefile = $(modulefilesdir)/$(parmetis-32)
$(parmetis-32)-prefix = $(pkgdir)/$(parmetis-32)

$($(parmetis-32)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis-32)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis-32)-prefix)/.pkgunpack: $$($(parmetis-32)-src) $($(parmetis-32)-srcdir)/.markerfile $($(parmetis-32)-prefix)/.markerfile $$(foreach dep,$$($(parmetis-32)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(parmetis-32)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(parmetis-32)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-32)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(parmetis-32)-builddir),$($(parmetis-32)-srcdir))
$($(parmetis-32)-builddir)/.markerfile: $($(parmetis-32)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(parmetis-32)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-32)-builddir)/.markerfile $($(parmetis-32)-prefix)/.pkgpatch
	cd $($(parmetis-32)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis-32)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(parmetis-32)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_C_COMPILER="$${MPICC}" \
			-DCMAKE_CXX_COMPILER="$${MPICXX}" \
			-DSHARED=1 \
			-DMETIS_PATH=$($(parmetis-32)-srcdir)/metis \
			-DGKLIB_PATH=$($(parmetis-32)-srcdir)/metis/GKlib && \
		$(MAKE)
	@touch $@

$($(parmetis-32)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-32)-builddir)/.markerfile $($(parmetis-32)-prefix)/.pkgbuild
	@touch $@

$($(parmetis-32)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-32)-builddir)/.markerfile $($(parmetis-32)-prefix)/.pkgcheck
	cd $($(parmetis-32)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis-32)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(parmetis-32)-modulefile): $(modulefilesdir)/.markerfile $($(parmetis-32)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(parmetis-32)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(parmetis-32)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(parmetis-32)-description)\"" >>$@
	echo "module-whatis \"$($(parmetis-32)-url)\"" >>$@
	printf "$(foreach prereq,$($(parmetis-32)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PARMETIS_ROOT $($(parmetis-32)-prefix)" >>$@
	echo "setenv PARMETIS_INCDIR $($(parmetis-32)-prefix)/include" >>$@
	echo "setenv PARMETIS_INCLUDEDIR $($(parmetis-32)-prefix)/include" >>$@
	echo "setenv PARMETIS_LIBDIR $($(parmetis-32)-prefix)/lib" >>$@
	echo "setenv PARMETIS_LIBRARYDIR $($(parmetis-32)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(parmetis-32)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(parmetis-32)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(parmetis-32)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(parmetis-32)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(parmetis-32)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(parmetis-32)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(parmetis-32)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(parmetis-32)-prefix)/share/info" >>$@
	echo "set MSG \"$(parmetis-32)\"" >>$@

$(parmetis-32)-src: $($(parmetis-32)-src)
$(parmetis-32)-unpack: $($(parmetis-32)-prefix)/.pkgunpack
$(parmetis-32)-patch: $($(parmetis-32)-prefix)/.pkgpatch
$(parmetis-32)-build: $($(parmetis-32)-prefix)/.pkgbuild
$(parmetis-32)-check: $($(parmetis-32)-prefix)/.pkgcheck
$(parmetis-32)-install: $($(parmetis-32)-prefix)/.pkginstall
$(parmetis-32)-modulefile: $($(parmetis-32)-modulefile)
$(parmetis-32)-clean:
	rm -rf $($(parmetis-32)-modulefile)
	rm -rf $($(parmetis-32)-prefix)
	rm -rf $($(parmetis-32)-srcdir)
	rm -rf $($(parmetis-32)-src)
$(parmetis-32): $(parmetis-32)-src $(parmetis-32)-unpack $(parmetis-32)-patch $(parmetis-32)-build $(parmetis-32)-check $(parmetis-32)-install $(parmetis-32)-modulefile
