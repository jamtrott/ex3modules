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
# ucx-1.12.1

ucx-1.12.1-version = 1.12.1
ucx-1.12.1 = ucx-$(ucx-1.12.1-version)
$(ucx-1.12.1)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications
$(ucx-1.12.1)-url = http://www.openucx.org/
$(ucx-1.12.1)-srcurl =
$(ucx-1.12.1)-builddeps = $(autoconf) $(automake) $(libtool) $(knem) $(numactl) $(rdma-core) $(cuda-toolkit) $(gdrcopy)
$(ucx-1.12.1)-prereqs = $(knem) $(numactl) $(rdma-core) $(cuda-toolkit) $(gdrcopy)
$(ucx-1.12.1)-src = $($(ucx-src-1.12.1)-src)
$(ucx-1.12.1)-srcdir = $(pkgsrcdir)/$(ucx-1.12.1)
$(ucx-1.12.1)-modulefile = $(modulefilesdir)/$(ucx-1.12.1)
$(ucx-1.12.1)-prefix = $(pkgdir)/$(ucx-1.12.1)
$(ucx-1.12.1)-configure-x86_64-opts = --with-avx --with-sse41 --with-sse42
$(ucx-1.12.1)-configure-aarch64-opts =

$($(ucx-1.12.1)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx-1.12.1)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx-1.12.1)-prefix)/.pkgunpack: $$($(ucx-1.12.1)-src) $($(ucx-1.12.1)-srcdir)/.markerfile $($(ucx-1.12.1)-prefix)/.markerfile $$(foreach dep,$$($(ucx-1.12.1)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(ucx-1.12.1)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ucx-1.12.1)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.12.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.12.1)-prefix)/.pkgunpack
	sed -i 's,ucx_check_gdrcopy_dir/lib64,ucx_check_gdrcopy_libdir,' $($(ucx-1.12.1)-srcdir)/config/m4/gdrcopy.m4
	@touch $@

$($(ucx-1.12.1)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.12.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.12.1)-prefix)/.pkgpatch
	cd $($(ucx-1.12.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx-1.12.1)-builddeps) && \
		./autogen.sh && \
		./configure --prefix=$($(ucx-1.12.1)-prefix) \
			--enable-cma \
			--with-rc --with-ud --with-dc --with-ib-hw-tm --with-dm \
			--with-knem=$${KNEM_ROOT} \
			--with-rdmacm=$${RDMA_CORE_ROOT} \
			--with-verbs=$${RDMA_CORE_ROOT} \
			--with-mlx5-dv=$${RDMA_CORE_ROOT} \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --with-cuda="$${CUDA_TOOLKIT_ROOT}" || echo --without-cuda) \
			$$([ ! -z "$${GDRCOPY_ROOT}" ] && echo --with-gdrcopy="$${GDRCOPY_ROOT}" || echo --without-gdrcopy) \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo --with-rocm="$${ROCM_ROOT}" || echo --without-rocm) \
			--without-java \
			--enable-mt \
			--enable-optimizations \
			--enable-compiler-opt=3 \
			--without-mpi \
			MPICC= MPIRUN= \
			$($(ucx-1.12.1)-configure-$(ARCH)-opts) && \
		$(MAKE)
	@touch $@

$($(ucx-1.12.1)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.12.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.12.1)-prefix)/.pkgbuild
	cd $($(ucx-1.12.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx-1.12.1)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ucx-1.12.1)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.12.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.12.1)-prefix)/.pkgcheck
	$(MAKE) -C $($(ucx-1.12.1)-srcdir) install
	@touch $@

$($(ucx-1.12.1)-modulefile): $(modulefilesdir)/.markerfile $($(ucx-1.12.1)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ucx-1.12.1)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ucx-1.12.1)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ucx-1.12.1)-description)\"" >>$@
	echo "module-whatis \"$($(ucx-1.12.1)-url)\"" >>$@
	printf "$(foreach prereq,$($(ucx-1.12.1)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv UCX_ROOT $($(ucx-1.12.1)-prefix)" >>$@
	echo "setenv UCX_INCDIR $($(ucx-1.12.1)-prefix)/include" >>$@
	echo "setenv UCX_INCLUDEDIR $($(ucx-1.12.1)-prefix)/include" >>$@
	echo "setenv UCX_LIBDIR $($(ucx-1.12.1)-prefix)/lib" >>$@
	echo "setenv UCX_LIBRARYDIR $($(ucx-1.12.1)-prefix)/lib" >>$@
	echo "setenv UCX_WARN_UNUSED_ENV_VARS n" >>$@
	echo "prepend-path PATH $($(ucx-1.12.1)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ucx-1.12.1)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ucx-1.12.1)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(ucx-1.12.1)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ucx-1.12.1)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(ucx-1.12.1)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(ucx-1.12.1)\"" >>$@

$(ucx-1.12.1)-src: $$($(ucx-1.12.1)-src)
$(ucx-1.12.1)-unpack: $($(ucx-1.12.1)-prefix)/.pkgunpack
$(ucx-1.12.1)-patch: $($(ucx-1.12.1)-prefix)/.pkgpatch
$(ucx-1.12.1)-build: $($(ucx-1.12.1)-prefix)/.pkgbuild
$(ucx-1.12.1)-check: $($(ucx-1.12.1)-prefix)/.pkgcheck
$(ucx-1.12.1)-install: $($(ucx-1.12.1)-prefix)/.pkginstall
$(ucx-1.12.1)-modulefile: $($(ucx-1.12.1)-modulefile)
$(ucx-1.12.1)-clean:
	rm -rf $($(ucx-1.12.1)-modulefile)
	rm -rf $($(ucx-1.12.1)-prefix)
	rm -rf $($(ucx-1.12.1)-srcdir)
$(ucx-1.12.1): $(ucx-1.12.1)-src $(ucx-1.12.1)-unpack $(ucx-1.12.1)-patch $(ucx-1.12.1)-build $(ucx-1.12.1)-check $(ucx-1.12.1)-install $(ucx-1.12.1)-modulefile
