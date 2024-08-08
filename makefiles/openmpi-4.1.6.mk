# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# openmpi-4.1.6

openmpi-4.1.6-version = 4.1.6
openmpi-4.1.6 = openmpi-$(openmpi-4.1.6-version)
$(openmpi-4.1.6)-description = A High Performance Message Passing Library
$(openmpi-4.1.6)-url = https://www.open-mpi.org/
$(openmpi-4.1.6)-srcurl =
$(openmpi-4.1.6)-builddeps = $(knem) $(numactl) $(ucx) $(libfabric) $(slurm) $(cuda-toolkit) $(util-linux)
$(openmpi-4.1.6)-prereqs = $(knem) $(numactl) $(ucx) $(libfabric) $(slurm) $(cuda-toolkit) $(util-linux)
$(openmpi-4.1.6)-src = $($(openmpi-src-4.1.6)-src)
$(openmpi-4.1.6)-srcdir = $(pkgsrcdir)/$(openmpi-4.1.6)
$(openmpi-4.1.6)-modulefile = $(modulefilesdir)/$(openmpi-4.1.6)
$(openmpi-4.1.6)-prefix = $(pkgdir)/$(openmpi-4.1.6)

$($(openmpi-4.1.6)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-4.1.6)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-4.1.6)-prefix)/.pkgunpack: $$($(openmpi-4.1.6)-src) $($(openmpi-4.1.6)-srcdir)/.markerfile $($(openmpi-4.1.6)-prefix)/.markerfile $$(foreach dep,$$($(openmpi-4.1.6)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openmpi-4.1.6)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(openmpi-4.1.6)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-4.1.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-4.1.6)-prefix)/.pkgunpack
	@touch $@

$($(openmpi-4.1.6)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-4.1.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-4.1.6)-prefix)/.pkgpatch
	cd $($(openmpi-4.1.6)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-4.1.6)-builddeps) && \
		./configure --prefix=$($(openmpi-4.1.6)-prefix) \
			--with-hwloc=external --with-hwloc-libdir="$${HWLOC_LIBDIR}" \
			--with-knem="$${KNEM_ROOT}" \
			--with-libevent=external --with-libevent-libdir="$${LIBEVENT_LIBDIR}" \
			--with-ucx="$${UCX_ROOT}" \
			--with-ofi="$${LIBFABRIC_ROOT}" \
			--with-verbs="$${RDMA_CORE_ROOT}" \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --with-cuda="$${CUDA_TOOLKIT_ROOT}") \
			$$([ ! -z "$${SLURM_ROOT}" ] && echo --with-slurm --with-pmi="$${SLURM_ROOT}" --with-pmi-libdir="$${SLURM_ROOT}/lib64") \
			--without-verbs \
			--enable-mpi-cxx \
			--enable-mpi-fortran=all \
			--enable-mpi1-compatibility \
			--enable-orterun-prefix-by-default \
			--enable-mca-no-build=btl-uct && \
		$(MAKE)
	@touch $@

$($(openmpi-4.1.6)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-4.1.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-4.1.6)-prefix)/.pkgbuild
# Tests currently fail on aarch64
ifneq ($(ARCH),aarch64)
	cd $($(openmpi-4.1.6)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-4.1.6)-builddeps) && \
		$(MAKE) check
endif
	@touch $@

$($(openmpi-4.1.6)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-4.1.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-4.1.6)-prefix)/.pkgcheck
	cd $($(openmpi-4.1.6)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-4.1.6)-builddeps) && \
	$(MAKE) install
	echo "" >>$($(openmpi-4.1.6)-prefix)/etc/openmpi-mca-params.conf
	echo "mca_btl_tcp_if_include = ib" >>$($(openmpi-4.1.6)-prefix)/etc/openmpi-mca-params.conf
	@touch $@

$($(openmpi-4.1.6)-modulefile): $(modulefilesdir)/.markerfile $($(openmpi-4.1.6)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openmpi-4.1.6)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openmpi-4.1.6)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openmpi-4.1.6)-description)\"" >>$@
	echo "module-whatis \"$($(openmpi-4.1.6)-url)\"" >>$@
	printf "$(foreach prereq,$($(openmpi-4.1.6)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENMPI_ROOT $($(openmpi-4.1.6)-prefix)" >>$@
	echo "setenv OPENMPI_INCDIR $($(openmpi-4.1.6)-prefix)/include" >>$@
	echo "setenv OPENMPI_INCLUDEDIR $($(openmpi-4.1.6)-prefix)/include" >>$@
	echo "setenv OPENMPI_LIBDIR $($(openmpi-4.1.6)-prefix)/lib" >>$@
	echo "setenv OPENMPI_LIBRARYDIR $($(openmpi-4.1.6)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(openmpi-4.1.6)-prefix)" >>$@
	echo "setenv MPI_RUN $($(openmpi-4.1.6)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(openmpi-4.1.6)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(openmpi-4.1.6)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(openmpi-4.1.6)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(openmpi-4.1.6)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(openmpi-4.1.6)-prefix)/bin/mpif90" >>$@
	echo "setenv MPIFORT $($(openmpi-4.1.6)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(openmpi-4.1.6)-prefix)/bin/mpirun" >>$@
	echo "setenv OPAL_PREFIX $($(openmpi-4.1.6)-prefix)" >>$@
	echo "prepend-path PATH $($(openmpi-4.1.6)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openmpi-4.1.6)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openmpi-4.1.6)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openmpi-4.1.6)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openmpi-4.1.6)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openmpi-4.1.6)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openmpi-4.1.6)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(openmpi-4.1.6)-prefix)/share/info" >>$@
	echo "set MSG \"$(openmpi-4.1.6)\"" >>$@

$(openmpi-4.1.6)-src: $$($(openmpi-4.1.6)-src)
$(openmpi-4.1.6)-unpack: $($(openmpi-4.1.6)-prefix)/.pkgunpack
$(openmpi-4.1.6)-patch: $($(openmpi-4.1.6)-prefix)/.pkgpatch
$(openmpi-4.1.6)-build: $($(openmpi-4.1.6)-prefix)/.pkgbuild
$(openmpi-4.1.6)-check: $($(openmpi-4.1.6)-prefix)/.pkgcheck
$(openmpi-4.1.6)-install: $($(openmpi-4.1.6)-prefix)/.pkginstall
$(openmpi-4.1.6)-modulefile: $($(openmpi-4.1.6)-modulefile)
$(openmpi-4.1.6)-clean:
	rm -rf $($(openmpi-4.1.6)-modulefile)
	rm -rf $($(openmpi-4.1.6)-prefix)
	rm -rf $($(openmpi-4.1.6)-srcdir)
$(openmpi-4.1.6): $(openmpi-4.1.6)-src $(openmpi-4.1.6)-unpack $(openmpi-4.1.6)-patch $(openmpi-4.1.6)-build $(openmpi-4.1.6)-check $(openmpi-4.1.6)-install $(openmpi-4.1.6)-modulefile
