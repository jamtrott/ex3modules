# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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

openmpi-cuda-4.0.5-version = 4.0.5
openmpi-cuda-4.0.5 = openmpi-cuda-$(openmpi-cuda-4.0.5-version)
$(openmpi-cuda-4.0.5)-description = A High Performance Message Passing Library
$(openmpi-cuda-4.0.5)-url = https://www.open-mpi.org/
$(openmpi-cuda-4.0.5)-srcurl =
$(openmpi-cuda-4.0.5)-builddeps = $(knem) $(hwloc) $(libevent) $(numactl) $(ucx-cuda) $(libfabric) $(slurm) $(pmix) $(cuda-toolkit)
$(openmpi-cuda-4.0.5)-prereqs = $(knem) $(hwloc) $(libevent) $(numactl) $(ucx-cuda) $(libfabric) $(slurm) $(pmix) $(cuda-toolkit)
$(openmpi-cuda-4.0.5)-src = $($(openmpi-src-4.0.5)-src)
$(openmpi-cuda-4.0.5)-srcdir = $(pkgsrcdir)/$(openmpi-cuda-4.0.5)
$(openmpi-cuda-4.0.5)-modulefile = $(modulefilesdir)/$(openmpi-cuda-4.0.5)
$(openmpi-cuda-4.0.5)-prefix = $(pkgdir)/$(openmpi-cuda-4.0.5)

$($(openmpi-cuda-4.0.5)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-cuda-4.0.5)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-cuda-4.0.5)-prefix)/.pkgunpack: $$($(openmpi-cuda-4.0.5)-src) $($(openmpi-cuda-4.0.5)-srcdir)/.markerfile $($(openmpi-cuda-4.0.5)-prefix)/.markerfile $$(foreach dep,$$($(openmpi-cuda-4.0.5)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openmpi-cuda-4.0.5)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(openmpi-cuda-4.0.5)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda-4.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda-4.0.5)-prefix)/.pkgunpack
	@touch $@

$($(openmpi-cuda-4.0.5)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda-4.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda-4.0.5)-prefix)/.pkgpatch
	cd $($(openmpi-cuda-4.0.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-cuda-4.0.5)-builddeps) && \
		./configure --prefix=$($(openmpi-cuda-4.0.5)-prefix) \
			--with-hwloc="$${HWLOC_ROOT}" \
			--with-knem="$${KNEM_ROOT}" \
			--with-libevent="$${LIBEVENT_ROOT}" \
			--with-ucx="$${UCX_ROOT}" \
			--with-ofi="$${LIBFABRIC_ROOT}" \
			--with-verbs="$${RDMA_CORE_ROOT}" \
			$$([ ! -z "$${SLURM_ROOT}" ] && echo --with-slurm --with-pmi="$${SLURM_ROOT}") \
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

$($(openmpi-cuda-4.0.5)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda-4.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda-4.0.5)-prefix)/.pkgbuild
# Tests currently fail on aarch64
ifneq ($(ARCH),aarch64)
	cd $($(openmpi-cuda-4.0.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-cuda-4.0.5)-builddeps) && \
		$(MAKE) check
endif
	@touch $@

$($(openmpi-cuda-4.0.5)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-cuda-4.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-cuda-4.0.5)-prefix)/.pkgcheck
	cd $($(openmpi-cuda-4.0.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-cuda-4.0.5)-builddeps) && \
	$(MAKE) install
	echo "" >>$($(openmpi-cuda-4.0.5)-prefix)/etc/openmpi-mca-params.conf
	echo "mca_btl_tcp_if_include = ib" >>$($(openmpi-cuda-4.0.5)-prefix)/etc/openmpi-mca-params.conf
	@touch $@

$($(openmpi-cuda-4.0.5)-modulefile): $(modulefilesdir)/.markerfile $($(openmpi-cuda-4.0.5)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openmpi-cuda-4.0.5)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openmpi-cuda-4.0.5)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openmpi-cuda-4.0.5)-description)\"" >>$@
	echo "module-whatis \"$($(openmpi-cuda-4.0.5)-url)\"" >>$@
	printf "$(foreach prereq,$($(openmpi-cuda-4.0.5)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENMPI_ROOT $($(openmpi-cuda-4.0.5)-prefix)" >>$@
	echo "setenv OPENMPI_INCDIR $($(openmpi-cuda-4.0.5)-prefix)/include" >>$@
	echo "setenv OPENMPI_INCLUDEDIR $($(openmpi-cuda-4.0.5)-prefix)/include" >>$@
	echo "setenv OPENMPI_LIBDIR $($(openmpi-cuda-4.0.5)-prefix)/lib" >>$@
	echo "setenv OPENMPI_LIBRARYDIR $($(openmpi-cuda-4.0.5)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(openmpi-cuda-4.0.5)-prefix)" >>$@
	echo "setenv MPI_RUN $($(openmpi-cuda-4.0.5)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(openmpi-cuda-4.0.5)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(openmpi-cuda-4.0.5)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(openmpi-cuda-4.0.5)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(openmpi-cuda-4.0.5)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(openmpi-cuda-4.0.5)-prefix)/bin/mpif90" >>$@
	echo "setenv MPIFORT $($(openmpi-cuda-4.0.5)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(openmpi-cuda-4.0.5)-prefix)/bin/mpirun" >>$@
	echo "setenv OPAL_PREFIX $($(openmpi-cuda-4.0.5)-prefix)" >>$@
	echo "prepend-path PATH $($(openmpi-cuda-4.0.5)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openmpi-cuda-4.0.5)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openmpi-cuda-4.0.5)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openmpi-cuda-4.0.5)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openmpi-cuda-4.0.5)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openmpi-cuda-4.0.5)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openmpi-cuda-4.0.5)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(openmpi-cuda-4.0.5)-prefix)/share/info" >>$@
	echo "set MSG \"$(openmpi-cuda-4.0.5)\"" >>$@

$(openmpi-cuda-4.0.5)-src: $$($(openmpi-cuda-4.0.5)-src)
$(openmpi-cuda-4.0.5)-unpack: $($(openmpi-cuda-4.0.5)-prefix)/.pkgunpack
$(openmpi-cuda-4.0.5)-patch: $($(openmpi-cuda-4.0.5)-prefix)/.pkgpatch
$(openmpi-cuda-4.0.5)-build: $($(openmpi-cuda-4.0.5)-prefix)/.pkgbuild
$(openmpi-cuda-4.0.5)-check: $($(openmpi-cuda-4.0.5)-prefix)/.pkgcheck
$(openmpi-cuda-4.0.5)-install: $($(openmpi-cuda-4.0.5)-prefix)/.pkginstall
$(openmpi-cuda-4.0.5)-modulefile: $($(openmpi-cuda-4.0.5)-modulefile)
$(openmpi-cuda-4.0.5)-clean:
	rm -rf $($(openmpi-cuda-4.0.5)-modulefile)
	rm -rf $($(openmpi-cuda-4.0.5)-prefix)
	rm -rf $($(openmpi-cuda-4.0.5)-srcdir)
$(openmpi-cuda-4.0.5): $(openmpi-cuda-4.0.5)-src $(openmpi-cuda-4.0.5)-unpack $(openmpi-cuda-4.0.5)-patch $(openmpi-cuda-4.0.5)-build $(openmpi-cuda-4.0.5)-check $(openmpi-cuda-4.0.5)-install $(openmpi-cuda-4.0.5)-modulefile
