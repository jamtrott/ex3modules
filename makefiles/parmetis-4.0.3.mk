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
# parmetis-4.0.3

parmetis-version = 4.0.3
parmetis = parmetis-$(parmetis-version)
$(parmetis)-description = Parallel Graph Partitioning and Fill-reducing Matrix Ordering
$(parmetis)-url = http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview
$(parmetis)-srcurl = $($(parmetis-src)-srcurl)
$(parmetis)-builddeps = $(cmake) $(mpi) $(metis)
$(parmetis)-prereqs = $(mpi) $(metis)
$(parmetis)-src = $($(parmetis-src)-src)
$(parmetis)-srcdir = $(pkgsrcdir)/$(parmetis)
$(parmetis)-builddir = $($(parmetis)-srcdir)/build
$(parmetis)-modulefile = $(modulefilesdir)/$(parmetis)
$(parmetis)-prefix = $(pkgdir)/$(parmetis)

$($(parmetis)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis)-prefix)/.pkgunpack: $$($(parmetis)-src) $($(parmetis)-srcdir)/.markerfile $($(parmetis)-prefix)/.markerfile $$(foreach dep,$$($(parmetis)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(parmetis)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(parmetis)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(parmetis)-builddir),$($(parmetis)-srcdir))
$($(parmetis)-builddir)/.markerfile: $($(parmetis)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(parmetis)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis)-builddir)/.markerfile $($(parmetis)-prefix)/.pkgpatch
	cd $($(parmetis)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(parmetis)-prefix) \
			-DCMAKE_C_COMPILER="$${MPICC}" \
			-DCMAKE_CXX_COMPILER="$${MPICXX}" \
			-DSHARED=1 \
			-DMETIS_PATH=$($(parmetis)-srcdir)/metis \
			-DGKLIB_PATH=$($(parmetis)-srcdir)/metis/GKlib && \
		$(MAKE)
	@touch $@

$($(parmetis)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis)-builddir)/.markerfile $($(parmetis)-prefix)/.pkgbuild
	@touch $@

$($(parmetis)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis)-builddir)/.markerfile $($(parmetis)-prefix)/.pkgcheck
	cd $($(parmetis)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(parmetis)-modulefile): $(modulefilesdir)/.markerfile $($(parmetis)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(parmetis)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(parmetis)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(parmetis)-description)\"" >>$@
	echo "module-whatis \"$($(parmetis)-url)\"" >>$@
	printf "$(foreach prereq,$($(parmetis)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PARMETIS_ROOT $($(parmetis)-prefix)" >>$@
	echo "setenv PARMETIS_INCDIR $($(parmetis)-prefix)/include" >>$@
	echo "setenv PARMETIS_INCLUDEDIR $($(parmetis)-prefix)/include" >>$@
	echo "setenv PARMETIS_LIBDIR $($(parmetis)-prefix)/lib" >>$@
	echo "setenv PARMETIS_LIBRARYDIR $($(parmetis)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(parmetis)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(parmetis)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(parmetis)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(parmetis)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(parmetis)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(parmetis)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(parmetis)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(parmetis)-prefix)/share/info" >>$@
	echo "set MSG \"$(parmetis)\"" >>$@

$(parmetis)-src: $($(parmetis)-src)
$(parmetis)-unpack: $($(parmetis)-prefix)/.pkgunpack
$(parmetis)-patch: $($(parmetis)-prefix)/.pkgpatch
$(parmetis)-build: $($(parmetis)-prefix)/.pkgbuild
$(parmetis)-check: $($(parmetis)-prefix)/.pkgcheck
$(parmetis)-install: $($(parmetis)-prefix)/.pkginstall
$(parmetis)-modulefile: $($(parmetis)-modulefile)
$(parmetis)-clean:
	rm -rf $($(parmetis)-modulefile)
	rm -rf $($(parmetis)-prefix)
	rm -rf $($(parmetis)-srcdir)
	rm -rf $($(parmetis)-src)
$(parmetis): $(parmetis)-src $(parmetis)-unpack $(parmetis)-patch $(parmetis)-build $(parmetis)-check $(parmetis)-install $(parmetis)-modulefile
