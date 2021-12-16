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
# parmetis-cuda-4.0.3

parmetis-cuda-version = 4.0.3
parmetis-cuda = parmetis-cuda-$(parmetis-cuda-version)
$(parmetis-cuda)-description = Parallel Graph Partitioning and Fill-reducing Matrix Ordering
$(parmetis-cuda)-url = http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview
$(parmetis-cuda)-srcurl = http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-$(parmetis-version).tar.gz
$(parmetis-cuda)-builddeps = $(cmake) $(openmpi-cuda) $(metis)
$(parmetis-cuda)-prereqs = $(openmpi-cuda) $(metis)
$(parmetis-cuda)-src = $($(parmetis-src)-src)
$(parmetis-cuda)-srcdir = $(pkgsrcdir)/$(parmetis-cuda)
$(parmetis-cuda)-builddir = $($(parmetis-cuda)-srcdir)/build
$(parmetis-cuda)-modulefile = $(modulefilesdir)/$(parmetis-cuda)
$(parmetis-cuda)-prefix = $(pkgdir)/$(parmetis-cuda)

$($(parmetis-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parmetis-cuda)-prefix)/.pkgunpack: $$($(parmetis-cuda)-src) $($(parmetis-cuda)-srcdir)/.markerfile $($(parmetis-cuda)-prefix)/.markerfile $$(foreach dep,$$($(parmetis-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(parmetis-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(parmetis-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-cuda)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(parmetis-cuda)-builddir),$($(parmetis-cuda)-srcdir))
$($(parmetis-cuda)-builddir)/.markerfile: $($(parmetis-cuda)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(parmetis-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-cuda)-builddir)/.markerfile $($(parmetis-cuda)-prefix)/.pkgpatch
	cd $($(parmetis-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis-cuda)-builddeps) && \
		cmake .. -DCMAKE_INSTALL_PREFIX=$($(parmetis-cuda)-prefix) \
			-DCMAKE_C_COMPILER=mpicc \
			-DCMAKE_CXX_COMPILER=mpicxx \
			-DSHARED=1 \
			-DMETIS_PATH=$($(parmetis-cuda)-srcdir)/metis \
			-DGKLIB_PATH=$($(parmetis-cuda)-srcdir)/metis/GKlib && \
		$(MAKE)
	@touch $@

$($(parmetis-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-cuda)-builddir)/.markerfile $($(parmetis-cuda)-prefix)/.pkgbuild
	@touch $@

$($(parmetis-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parmetis-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(parmetis-cuda)-builddir)/.markerfile $($(parmetis-cuda)-prefix)/.pkgcheck
	cd $($(parmetis-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parmetis-cuda)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(parmetis-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(parmetis-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(parmetis-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(parmetis-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(parmetis-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(parmetis-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(parmetis-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PARMETIS_ROOT $($(parmetis-cuda)-prefix)" >>$@
	echo "setenv PARMETIS_INCDIR $($(parmetis-cuda)-prefix)/include" >>$@
	echo "setenv PARMETIS_INCLUDEDIR $($(parmetis-cuda)-prefix)/include" >>$@
	echo "setenv PARMETIS_LIBDIR $($(parmetis-cuda)-prefix)/lib" >>$@
	echo "setenv PARMETIS_LIBRARYDIR $($(parmetis-cuda)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(parmetis-cuda)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(parmetis-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(parmetis-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(parmetis-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(parmetis-cuda)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(parmetis-cuda)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(parmetis-cuda)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(parmetis-cuda)-prefix)/share/info" >>$@
	echo "set MSG \"$(parmetis-cuda)\"" >>$@

$(parmetis-cuda)-src: $($(parmetis-cuda)-src)
$(parmetis-cuda)-unpack: $($(parmetis-cuda)-prefix)/.pkgunpack
$(parmetis-cuda)-patch: $($(parmetis-cuda)-prefix)/.pkgpatch
$(parmetis-cuda)-build: $($(parmetis-cuda)-prefix)/.pkgbuild
$(parmetis-cuda)-check: $($(parmetis-cuda)-prefix)/.pkgcheck
$(parmetis-cuda)-install: $($(parmetis-cuda)-prefix)/.pkginstall
$(parmetis-cuda)-modulefile: $($(parmetis-cuda)-modulefile)
$(parmetis-cuda)-clean:
	rm -rf $($(parmetis-cuda)-modulefile)
	rm -rf $($(parmetis-cuda)-prefix)
	rm -rf $($(parmetis-cuda)-srcdir)
	rm -rf $($(parmetis-cuda)-src)
$(parmetis-cuda): $(parmetis-cuda)-src $(parmetis-cuda)-unpack $(parmetis-cuda)-patch $(parmetis-cuda)-build $(parmetis-cuda)-check $(parmetis-cuda)-install $(parmetis-cuda)-modulefile
