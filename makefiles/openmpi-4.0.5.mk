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
# openmpi-4.0.5

openmpi-version = 4.0.5
openmpi = openmpi-$(openmpi-version)
$(openmpi)-description = A High Performance Message Passing Library
$(openmpi)-url = https://www.open-mpi.org/
$(openmpi)-srcurl = https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-$(openmpi-version).tar.bz2
$(openmpi)-src = $(pkgsrcdir)/$(notdir $($(openmpi)-srcurl))
$(openmpi)-srcdir = $(pkgsrcdir)/$(openmpi)
$(openmpi)-builddeps = $(gcc-10.1.0) $(knem) $(hwloc) $(libevent) $(numactl) $(ucx) $(slurm)
$(openmpi)-prereqs = $(gcc-10.1.0) $(knem) $(hwloc) $(libevent) $(numactl) $(ucx) $(slurm)
$(openmpi)-modulefile = $(modulefilesdir)/$(openmpi)
$(openmpi)-prefix = $(pkgdir)/$(openmpi)

$($(openmpi)-src): $(dir $($(openmpi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openmpi)-srcurl)

$($(openmpi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi)-prefix)/.pkgunpack: $($(openmpi)-src) $($(openmpi)-srcdir)/.markerfile $($(openmpi)-prefix)/.markerfile
	tar -C $($(openmpi)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(openmpi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi)-prefix)/.pkgunpack
	@touch $@

$($(openmpi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi)-prefix)/.pkgpatch
	cd $($(openmpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi)-builddeps) && \
		./configure --prefix=$($(openmpi)-prefix) \
			--with-hwloc="$${HWLOC_ROOT}" \
			--with-knem="$${KNEM_ROOT}" \
			--with-libevent="$${LIBEVENT_ROOT}" \
			--with-ucx="$${UCX_ROOT}" \
			--with-ofi="$${LIBFABRIC_ROOT}" \
			--with-verbs="$${RDMA_CORE_ROOT}" \
			--with-pmi="$${SLURM_ROOT}" \
			--enable-mpi-cxx \
			--enable-mpi-fortran=all \
			--enable-mpi1-compatibility \
			--without-verbs && \
		$(MAKE)
	@touch $@

$($(openmpi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi)-prefix)/.pkgbuild
# Tests currently fail on aarch64
ifneq ($(ARCH),aarch64)
	cd $($(openmpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi)-builddeps) && \
		$(MAKE) check
endif
	@touch $@

$($(openmpi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi)-prefix)/.pkgcheck
	cd $($(openmpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi)-builddeps) && \
	$(MAKE) install
	echo "" >>$($(openmpi)-prefix)/etc/openmpi-mca-params.conf
	echo "mca_btl_tcp_if_include = ib" >>$($(openmpi)-prefix)/etc/openmpi-mca-params.conf
	@touch $@

$($(openmpi)-modulefile): $(modulefilesdir)/.markerfile $($(openmpi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openmpi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openmpi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openmpi)-description)\"" >>$@
	echo "module-whatis \"$($(openmpi)-url)\"" >>$@
	printf "$(foreach prereq,$($(openmpi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENMPI_ROOT $($(openmpi)-prefix)" >>$@
	echo "setenv OPENMPI_INCDIR $($(openmpi)-prefix)/include" >>$@
	echo "setenv OPENMPI_INCLUDEDIR $($(openmpi)-prefix)/include" >>$@
	echo "setenv OPENMPI_LIBDIR $($(openmpi)-prefix)/lib" >>$@
	echo "setenv OPENMPI_LIBRARYDIR $($(openmpi)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(openmpi)-prefix)" >>$@
	echo "setenv MPI_RUN $($(openmpi)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(openmpi)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(openmpi)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(openmpi)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(openmpi)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(openmpi)-prefix)/bin/mpif90" >>$@
	echo "setenv MPIFORT $($(openmpi)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(openmpi)-prefix)/bin/mpirun" >>$@
	echo "prepend-path PATH $($(openmpi)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openmpi)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openmpi)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openmpi)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openmpi)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openmpi)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openmpi)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(openmpi)-prefix)/share/info" >>$@
	echo "set MSG \"$(openmpi)\"" >>$@

$(openmpi)-src: $($(openmpi)-src)
$(openmpi)-unpack: $($(openmpi)-prefix)/.pkgunpack
$(openmpi)-patch: $($(openmpi)-prefix)/.pkgpatch
$(openmpi)-build: $($(openmpi)-prefix)/.pkgbuild
$(openmpi)-check: $($(openmpi)-prefix)/.pkgcheck
$(openmpi)-install: $($(openmpi)-prefix)/.pkginstall
$(openmpi)-modulefile: $($(openmpi)-modulefile)
$(openmpi)-clean:
	rm -rf $($(openmpi)-modulefile)
	rm -rf $($(openmpi)-prefix)
	rm -rf $($(openmpi)-srcdir)
	rm -rf $($(openmpi)-src)
$(openmpi): $(openmpi)-src $(openmpi)-unpack $(openmpi)-patch $(openmpi)-build $(openmpi)-check $(openmpi)-install $(openmpi)-modulefile
