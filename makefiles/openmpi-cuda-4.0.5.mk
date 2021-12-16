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
# openmpi-cuda-4.0.5

openmpi-cuda-version = 4.0.5
openmpi-cuda = openmpi-cuda-$(openmpi-cuda-version)
$(openmpi-cuda)-description = A High Performance Message Passing Library
$(openmpi-cuda)-url = https://www.open-mpi.org/
$(openmpi-cuda)-srcurl =
$(openmpi-cuda)-builddeps = $(gcc) $(knem) $(hwloc) $(libevent) $(numactl) $(ucx-cuda) $(libfabric) $(slurm) $(pmix) $(cuda-toolkit)
$(openmpi-cuda)-prereqs = $(gcc) $(knem) $(hwloc) $(libevent) $(numactl) $(ucx-cuda) $(libfabric) $(slurm) $(pmix) $(cuda-toolkit)
$(openmpi-cuda)-src = $($(openmpi-src)-src)
$(openmpi-cuda)-srcdir = $(pkgsrcdir)/$(openmpi-cuda)
$(openmpi-cuda)-modulefile = $(modulefilesdir)/$(openmpi-cuda)
$(openmpi-cuda)-prefix = $(pkgdir)/$(openmpi-cuda)

$($(openmpi-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-cuda)-prefix)/.pkgunpack: $$($(openmpi-cuda)-src) $($(openmpi-cuda)-srcdir)/.markerfile $($(openmpi-cuda)-prefix)/.markerfile $$(foreach dep,$$($(openmpi-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openmpi-cuda)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(openmpi-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda)-prefix)/.pkgunpack
	@touch $@

$($(openmpi-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda)-prefix)/.pkgpatch
	cd $($(openmpi-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-cuda)-builddeps) && \
		./configure --prefix=$($(openmpi-cuda)-prefix) \
			--with-hwloc="$${HWLOC_ROOT}" \
			--with-knem="$${KNEM_ROOT}" \
			--with-libevent="$${LIBEVENT_ROOT}" \
			--with-ucx="$${UCX_ROOT}" \
			--with-ofi="$${LIBFABRIC_ROOT}" \
			--with-verbs="$${RDMA_CORE_ROOT}" \
			--with-slurm \
			--with-pmi="$${SLURM_ROOT}" \
			--with-pmix="$${PMIX_ROOT}" \
			--without-verbs \
			--with-cuda="$${CUDA_TOOLKIT_ROOT}" \
			--enable-mpi-cxx \
			--enable-mpi-fortran=all \
			--enable-mpi1-compatibility \
			--enable-orterun-prefix-by-default \
			--enable-mca-no-build=btl-uct && \
		$(MAKE)
	@touch $@

$($(openmpi-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda)-prefix)/.pkgbuild
# Tests currently fail on aarch64
ifneq ($(ARCH),aarch64)
	cd $($(openmpi-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-cuda)-builddeps) && \
		$(MAKE) check
endif
	@touch $@

$($(openmpi-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda)-prefix)/.pkgcheck
	cd $($(openmpi-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-cuda)-builddeps) && \
	$(MAKE) install
	echo "" >>$($(openmpi-cuda)-prefix)/etc/openmpi-cuda-mca-params.conf
	echo "mca_btl_tcp_if_include = ib" >>$($(openmpi-cuda)-prefix)/etc/openmpi-cuda-mca-params.conf
	@touch $@

$($(openmpi-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(openmpi-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openmpi-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openmpi-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openmpi-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(openmpi-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(openmpi-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENMPI_ROOT $($(openmpi-cuda)-prefix)" >>$@
	echo "setenv OPENMPI_INCDIR $($(openmpi-cuda)-prefix)/include" >>$@
	echo "setenv OPENMPI_INCLUDEDIR $($(openmpi-cuda)-prefix)/include" >>$@
	echo "setenv OPENMPI_LIBDIR $($(openmpi-cuda)-prefix)/lib" >>$@
	echo "setenv OPENMPI_LIBRARYDIR $($(openmpi-cuda)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(openmpi-cuda)-prefix)" >>$@
	echo "setenv MPI_RUN $($(openmpi-cuda)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(openmpi-cuda)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(openmpi-cuda)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(openmpi-cuda)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(openmpi-cuda)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(openmpi-cuda)-prefix)/bin/mpif90" >>$@
	echo "setenv MPIFORT $($(openmpi-cuda)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(openmpi-cuda)-prefix)/bin/mpirun" >>$@
	echo "prepend-path PATH $($(openmpi-cuda)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openmpi-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openmpi-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openmpi-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openmpi-cuda)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openmpi-cuda)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openmpi-cuda)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(openmpi-cuda)-prefix)/share/info" >>$@
	echo "set MSG \"$(openmpi-cuda)\"" >>$@

$(openmpi-cuda)-src: $$($(openmpi-cuda)-src)
$(openmpi-cuda)-unpack: $($(openmpi-cuda)-prefix)/.pkgunpack
$(openmpi-cuda)-patch: $($(openmpi-cuda)-prefix)/.pkgpatch
$(openmpi-cuda)-build: $($(openmpi-cuda)-prefix)/.pkgbuild
$(openmpi-cuda)-check: $($(openmpi-cuda)-prefix)/.pkgcheck
$(openmpi-cuda)-install: $($(openmpi-cuda)-prefix)/.pkginstall
$(openmpi-cuda)-modulefile: $($(openmpi-cuda)-modulefile)
$(openmpi-cuda)-clean:
	rm -rf $($(openmpi-cuda)-modulefile)
	rm -rf $($(openmpi-cuda)-prefix)
	rm -rf $($(openmpi-cuda)-srcdir)
$(openmpi-cuda): $(openmpi-cuda)-src $(openmpi-cuda)-unpack $(openmpi-cuda)-patch $(openmpi-cuda)-build $(openmpi-cuda)-check $(openmpi-cuda)-install $(openmpi-cuda)-modulefile
