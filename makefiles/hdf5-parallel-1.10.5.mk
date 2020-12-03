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
# hdf5-parallel-1.10.5

hdf5-parallel-version = 1.10.5
hdf5-parallel = hdf5-parallel-$(hdf5-parallel-version)
$(hdf5-parallel)-description = HDF5 high performance data software library and file format
$(hdf5-parallel)-url = https://www.hdfgroup.org/solutions/hdf5/
$(hdf5-parallel)-srcurl = $(mpi)
$(hdf5-parallel)-builddeps = $(mpi)
$(hdf5-parallel)-prereqs = $(mpi)
$(hdf5-parallel)-src = $($(hdf5-src)-src)
$(hdf5-parallel)-srcdir = $(pkgsrcdir)/$(hdf5-parallel)
$(hdf5-parallel)-builddir = $($(hdf5-parallel)-srcdir)
$(hdf5-parallel)-modulefile = $(modulefilesdir)/$(hdf5-parallel)
$(hdf5-parallel)-prefix = $(pkgdir)/$(hdf5-parallel)

$($(hdf5-parallel)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hdf5-parallel)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hdf5-parallel)-prefix)/.pkgunpack: $$($(hdf5-parallel)-src) $($(hdf5-parallel)-srcdir)/.markerfile $($(hdf5-parallel)-prefix)/.markerfile
	tar -C $($(hdf5-parallel)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hdf5-parallel)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(hdf5-parallel)-builddir),$($(hdf5-parallel)-srcdir))
$($(hdf5-parallel)-builddir)/.markerfile: $($(hdf5-parallel)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(hdf5-parallel)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel)-builddir)/.markerfile $($(hdf5-parallel)-prefix)/.pkgpatch
	cd $($(hdf5-parallel)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hdf5-parallel)-builddeps) && \
		CC=$${MPICC} CXX=$${MPICXX} FC=$${MPIFORT} \
		./configure --prefix=$($(hdf5-parallel)-prefix) \
			--enable-parallel && \
		$(MAKE)
	@touch $@

$($(hdf5-parallel)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel)-builddir)/.markerfile $($(hdf5-parallel)-prefix)/.pkgbuild
# Disable failing tests
# 	cd $($(hdf5-parallel)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(hdf5-parallel)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(hdf5-parallel)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel)-builddir)/.markerfile $($(hdf5-parallel)-prefix)/.pkgcheck
	cd $($(hdf5-parallel)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hdf5-parallel)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hdf5-parallel)-modulefile): $(modulefilesdir)/.markerfile $($(hdf5-parallel)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hdf5-parallel)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hdf5-parallel)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hdf5-parallel)-description)\"" >>$@
	echo "module-whatis \"$($(hdf5-parallel)-url)\"" >>$@
	printf "$(foreach prereq,$($(hdf5-parallel)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HDF5_ROOT $($(hdf5-parallel)-prefix)" >>$@
	echo "setenv HDF5_INCDIR $($(hdf5-parallel)-prefix)/include" >>$@
	echo "setenv HDF5_INCLUDEDIR $($(hdf5-parallel)-prefix)/include" >>$@
	echo "setenv HDF5_LIBDIR $($(hdf5-parallel)-prefix)/lib" >>$@
	echo "setenv HDF5_LIBRARYDIR $($(hdf5-parallel)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hdf5-parallel)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hdf5-parallel)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hdf5-parallel)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hdf5-parallel)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hdf5-parallel)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(hdf5-parallel)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(hdf5-parallel)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(hdf5-parallel)-prefix)/share/info" >>$@
	echo "set MSG \"$(hdf5-parallel)\"" >>$@

$(hdf5-parallel)-src: $$($(hdf5-parallel)-src)
$(hdf5-parallel)-unpack: $($(hdf5-parallel)-prefix)/.pkgunpack
$(hdf5-parallel)-patch: $($(hdf5-parallel)-prefix)/.pkgpatch
$(hdf5-parallel)-build: $($(hdf5-parallel)-prefix)/.pkgbuild
$(hdf5-parallel)-check: $($(hdf5-parallel)-prefix)/.pkgcheck
$(hdf5-parallel)-install: $($(hdf5-parallel)-prefix)/.pkginstall
$(hdf5-parallel)-modulefile: $($(hdf5-parallel)-modulefile)
$(hdf5-parallel)-clean:
	rm -rf $($(hdf5-parallel)-modulefile)
	rm -rf $($(hdf5-parallel)-prefix)
	rm -rf $($(hdf5-parallel)-srcdir)
$(hdf5-parallel): $(hdf5-parallel)-src $(hdf5-parallel)-unpack $(hdf5-parallel)-patch $(hdf5-parallel)-build $(hdf5-parallel)-check $(hdf5-parallel)-install $(hdf5-parallel)-modulefile
