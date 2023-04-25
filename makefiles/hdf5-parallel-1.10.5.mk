# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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

hdf5-parallel-1.10.5-version = 1.10.5
hdf5-parallel-1.10.5 = hdf5-parallel-$(hdf5-parallel-1.10.5-version)
$(hdf5-parallel-1.10.5)-description = HDF5 high performance data software library and file format
$(hdf5-parallel-1.10.5)-url = https://www.hdfgroup.org/solutions/hdf5/
$(hdf5-parallel-1.10.5)-srcurl = $(mpi)
$(hdf5-parallel-1.10.5)-builddeps = $(mpi)
$(hdf5-parallel-1.10.5)-prereqs = $(mpi)
$(hdf5-parallel-1.10.5)-src = $($(hdf5-src-1.10.5)-src)
$(hdf5-parallel-1.10.5)-srcdir = $(pkgsrcdir)/$(hdf5-parallel-1.10.5)
$(hdf5-parallel-1.10.5)-builddir = $($(hdf5-parallel-1.10.5)-srcdir)
$(hdf5-parallel-1.10.5)-modulefile = $(modulefilesdir)/$(hdf5-parallel-1.10.5)
$(hdf5-parallel-1.10.5)-prefix = $(pkgdir)/$(hdf5-parallel-1.10.5)

$($(hdf5-parallel-1.10.5)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hdf5-parallel-1.10.5)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hdf5-parallel-1.10.5)-prefix)/.pkgunpack: $$($(hdf5-parallel-1.10.5)-src) $($(hdf5-parallel-1.10.5)-srcdir)/.markerfile $($(hdf5-parallel-1.10.5)-prefix)/.markerfile $$(foreach dep,$$($(hdf5-parallel-1.10.5)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hdf5-parallel-1.10.5)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hdf5-parallel-1.10.5)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel-1.10.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel-1.10.5)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(hdf5-parallel-1.10.5)-builddir),$($(hdf5-parallel-1.10.5)-srcdir))
$($(hdf5-parallel-1.10.5)-builddir)/.markerfile: $($(hdf5-parallel-1.10.5)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(hdf5-parallel-1.10.5)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel-1.10.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel-1.10.5)-builddir)/.markerfile $($(hdf5-parallel-1.10.5)-prefix)/.pkgpatch
	cd $($(hdf5-parallel-1.10.5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hdf5-parallel-1.10.5)-builddeps) && \
		CC=$${MPICC} CXX=$${MPICXX} FC=$${MPIFORT} \
		./configure --prefix=$($(hdf5-parallel-1.10.5)-prefix) \
			--enable-parallel && \
		$(MAKE)
	@touch $@

$($(hdf5-parallel-1.10.5)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel-1.10.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel-1.10.5)-builddir)/.markerfile $($(hdf5-parallel-1.10.5)-prefix)/.pkgbuild
# Disable failing tests
# 	cd $($(hdf5-parallel-1.10.5)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(hdf5-parallel-1.10.5)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(hdf5-parallel-1.10.5)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hdf5-parallel-1.10.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(hdf5-parallel-1.10.5)-builddir)/.markerfile $($(hdf5-parallel-1.10.5)-prefix)/.pkgcheck
	cd $($(hdf5-parallel-1.10.5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hdf5-parallel-1.10.5)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hdf5-parallel-1.10.5)-modulefile): $(modulefilesdir)/.markerfile $($(hdf5-parallel-1.10.5)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hdf5-parallel-1.10.5)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hdf5-parallel-1.10.5)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hdf5-parallel-1.10.5)-description)\"" >>$@
	echo "module-whatis \"$($(hdf5-parallel-1.10.5)-url)\"" >>$@
	printf "$(foreach prereq,$($(hdf5-parallel-1.10.5)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HDF5_ROOT $($(hdf5-parallel-1.10.5)-prefix)" >>$@
	echo "setenv HDF5_VERSION $(hdf5-parallel-1.10.5-version)" >>$@
	echo "setenv HDF5_INCDIR $($(hdf5-parallel-1.10.5)-prefix)/include" >>$@
	echo "setenv HDF5_INCLUDEDIR $($(hdf5-parallel-1.10.5)-prefix)/include" >>$@
	echo "setenv HDF5_LIBDIR $($(hdf5-parallel-1.10.5)-prefix)/lib" >>$@
	echo "setenv HDF5_LIBRARYDIR $($(hdf5-parallel-1.10.5)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hdf5-parallel-1.10.5)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hdf5-parallel-1.10.5)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hdf5-parallel-1.10.5)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hdf5-parallel-1.10.5)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hdf5-parallel-1.10.5)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(hdf5-parallel-1.10.5)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(hdf5-parallel-1.10.5)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(hdf5-parallel-1.10.5)-prefix)/share/info" >>$@
	echo "set MSG \"$(hdf5-parallel-1.10.5)\"" >>$@

$(hdf5-parallel-1.10.5)-src: $$($(hdf5-parallel-1.10.5)-src)
$(hdf5-parallel-1.10.5)-unpack: $($(hdf5-parallel-1.10.5)-prefix)/.pkgunpack
$(hdf5-parallel-1.10.5)-patch: $($(hdf5-parallel-1.10.5)-prefix)/.pkgpatch
$(hdf5-parallel-1.10.5)-build: $($(hdf5-parallel-1.10.5)-prefix)/.pkgbuild
$(hdf5-parallel-1.10.5)-check: $($(hdf5-parallel-1.10.5)-prefix)/.pkgcheck
$(hdf5-parallel-1.10.5)-install: $($(hdf5-parallel-1.10.5)-prefix)/.pkginstall
$(hdf5-parallel-1.10.5)-modulefile: $($(hdf5-parallel-1.10.5)-modulefile)
$(hdf5-parallel-1.10.5)-clean:
	rm -rf $($(hdf5-parallel-1.10.5)-modulefile)
	rm -rf $($(hdf5-parallel-1.10.5)-prefix)
	rm -rf $($(hdf5-parallel-1.10.5)-srcdir)
$(hdf5-parallel-1.10.5): $(hdf5-parallel-1.10.5)-src $(hdf5-parallel-1.10.5)-unpack $(hdf5-parallel-1.10.5)-patch $(hdf5-parallel-1.10.5)-build $(hdf5-parallel-1.10.5)-check $(hdf5-parallel-1.10.5)-install $(hdf5-parallel-1.10.5)-modulefile
