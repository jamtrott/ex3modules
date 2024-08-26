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
# openmpi-5.0.5

openmpi-5.0.5-version = 5.0.5
openmpi-5.0.5 = openmpi-$(openmpi-5.0.5-version)
$(openmpi-5.0.5)-description = A High Performance Message Passing Library
$(openmpi-5.0.5)-url = https://www.open-mpi.org/
$(openmpi-5.0.5)-srcurl =
$(openmpi-5.0.5)-builddeps = $(knem) $(numactl) $(ucx) $(libfabric) $(slurm) $(cuda-toolkit) $(util-linux) $(libevent)
$(openmpi-5.0.5)-prereqs = $(knem) $(numactl) $(ucx) $(libfabric) $(slurm) $(cuda-toolkit) $(util-linux) $(libevent)
$(openmpi-5.0.5)-src = $($(openmpi-src-5.0.5)-src)
$(openmpi-5.0.5)-srcdir = $(pkgsrcdir)/$(openmpi-5.0.5)
$(openmpi-5.0.5)-modulefile = $(modulefilesdir)/$(openmpi-5.0.5)
$(openmpi-5.0.5)-prefix = $(pkgdir)/$(openmpi-5.0.5)

$($(openmpi-5.0.5)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-5.0.5)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(openmpi-5.0.5)-prefix)/.pkgunpack: $$($(openmpi-5.0.5)-src) $($(openmpi-5.0.5)-srcdir)/.markerfile $($(openmpi-5.0.5)-prefix)/.markerfile $$(foreach dep,$$($(openmpi-5.0.5)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(openmpi-5.0.5)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(openmpi-5.0.5)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-5.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-5.0.5)-prefix)/.pkgunpack
	@touch $@

$($(openmpi-5.0.5)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-5.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-5.0.5)-prefix)/.pkgpatch
	cd $($(openmpi-5.0.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-5.0.5)-builddeps) && \
		./configure --prefix=$($(openmpi-5.0.5)-prefix) \
			--with-hwloc=external --with-hwloc-libdir="$${HWLOC_LIBDIR}" \
			--with-knem="$${KNEM_ROOT}" \
			--with-libevent=external --with-libevent-libdir="$${LIBEVENT_LIBDIR}" \
			--with-ucx="$${UCX_ROOT}" \
			--with-ofi="$${LIBFABRIC_ROOT}" \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo --with-rocm="$${ROCM_ROOT}") \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --with-cuda="$${CUDA_TOOLKIT_ROOT}") \
			--enable-mpi-fortran=all \
			--enable-mpi1-compatibility \
			--enable-orterun-prefix-by-default \
			--enable-mca-no-build=btl-uct && \
		$(MAKE)
	@touch $@

$($(openmpi-5.0.5)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-5.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-5.0.5)-prefix)/.pkgbuild
# Tests currently fail on aarch64
ifneq ($(ARCH),aarch64)
	cd $($(openmpi-5.0.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-5.0.5)-builddeps) && \
		$(MAKE) check
endif
	@touch $@

$($(openmpi-5.0.5)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(openmpi-5.0.5)-builddeps),$(modulefilesdir)/$$(dep)) $($(openmpi-5.0.5)-prefix)/.pkgcheck
	cd $($(openmpi-5.0.5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(openmpi-5.0.5)-builddeps) && \
	$(MAKE) install
	echo "" >>$($(openmpi-5.0.5)-prefix)/etc/openmpi-mca-params.conf
	echo "mca_btl_tcp_if_include = ib" >>$($(openmpi-5.0.5)-prefix)/etc/openmpi-mca-params.conf
	@touch $@

$($(openmpi-5.0.5)-modulefile): $(modulefilesdir)/.markerfile $($(openmpi-5.0.5)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(openmpi-5.0.5)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(openmpi-5.0.5)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(openmpi-5.0.5)-description)\"" >>$@
	echo "module-whatis \"$($(openmpi-5.0.5)-url)\"" >>$@
	printf "$(foreach prereq,$($(openmpi-5.0.5)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENMPI_ROOT $($(openmpi-5.0.5)-prefix)" >>$@
	echo "setenv OPENMPI_INCDIR $($(openmpi-5.0.5)-prefix)/include" >>$@
	echo "setenv OPENMPI_INCLUDEDIR $($(openmpi-5.0.5)-prefix)/include" >>$@
	echo "setenv OPENMPI_LIBDIR $($(openmpi-5.0.5)-prefix)/lib" >>$@
	echo "setenv OPENMPI_LIBRARYDIR $($(openmpi-5.0.5)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(openmpi-5.0.5)-prefix)" >>$@
	echo "setenv MPI_RUN $($(openmpi-5.0.5)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(openmpi-5.0.5)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(openmpi-5.0.5)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(openmpi-5.0.5)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(openmpi-5.0.5)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(openmpi-5.0.5)-prefix)/bin/mpif90" >>$@
	echo "setenv MPIFORT $($(openmpi-5.0.5)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(openmpi-5.0.5)-prefix)/bin/mpirun" >>$@
	echo "setenv OPAL_PREFIX $($(openmpi-5.0.5)-prefix)" >>$@
	echo "prepend-path PATH $($(openmpi-5.0.5)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(openmpi-5.0.5)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(openmpi-5.0.5)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(openmpi-5.0.5)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(openmpi-5.0.5)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(openmpi-5.0.5)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(openmpi-5.0.5)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(openmpi-5.0.5)-prefix)/share/info" >>$@
	echo "set MSG \"$(openmpi-5.0.5)\"" >>$@

$(openmpi-5.0.5)-src: $$($(openmpi-5.0.5)-src)
$(openmpi-5.0.5)-unpack: $($(openmpi-5.0.5)-prefix)/.pkgunpack
$(openmpi-5.0.5)-patch: $($(openmpi-5.0.5)-prefix)/.pkgpatch
$(openmpi-5.0.5)-build: $($(openmpi-5.0.5)-prefix)/.pkgbuild
$(openmpi-5.0.5)-check: $($(openmpi-5.0.5)-prefix)/.pkgcheck
$(openmpi-5.0.5)-install: $($(openmpi-5.0.5)-prefix)/.pkginstall
$(openmpi-5.0.5)-modulefile: $($(openmpi-5.0.5)-modulefile)
$(openmpi-5.0.5)-clean:
	rm -rf $($(openmpi-5.0.5)-modulefile)
	rm -rf $($(openmpi-5.0.5)-prefix)
	rm -rf $($(openmpi-5.0.5)-srcdir)
$(openmpi-5.0.5): $(openmpi-5.0.5)-src $(openmpi-5.0.5)-unpack $(openmpi-5.0.5)-patch $(openmpi-5.0.5)-build $(openmpi-5.0.5)-check $(openmpi-5.0.5)-install $(openmpi-5.0.5)-modulefile
