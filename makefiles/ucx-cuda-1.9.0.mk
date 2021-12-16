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
# ucx-cuda-1.9.0

ucx-cuda-version = 1.9.0
ucx-cuda = ucx-cuda-$(ucx-cuda-version)
$(ucx-cuda)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications
$(ucx-cuda)-url = http://www.openucx.org/
$(ucx-cuda)-srcurl =
$(ucx-cuda)-builddeps = $(knem) $(numactl) $(rdma-core) $(cuda-toolkit) $(gdrcopy)
$(ucx-cuda)-prereqs = $(knem) $(numactl) $(rdma-core) $(cuda-toolkit) $(gdrcopy)
$(ucx-cuda)-src = $($(ucx-src)-src)
$(ucx-cuda)-srcdir = $(pkgsrcdir)/$(ucx-cuda)
$(ucx-cuda)-modulefile = $(modulefilesdir)/$(ucx-cuda)
$(ucx-cuda)-prefix = $(pkgdir)/$(ucx-cuda)
$(ucx-cuda)-configure-x86_64-opts = --with-avx --with-sse41 --with-sse42
$(ucx-cuda)-configure-aarch64-opts =

$($(ucx-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx-cuda)-prefix)/.pkgunpack: $$($(ucx-cuda)-src) $($(ucx-cuda)-srcdir)/.markerfile $($(ucx-cuda)-prefix)/.markerfile $$(foreach dep,$$($(ucx-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(ucx-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ucx-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-cuda)-prefix)/.pkgunpack
	@touch $@

$($(ucx-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-cuda)-prefix)/.pkgpatch
	cd $($(ucx-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx-cuda)-builddeps) && \
		./autogen.sh && \
		./configure --prefix=$($(ucx-cuda)-prefix) \
			--enable-cma \
			--with-rc --with-ud --with-dc --with-ib-hw-tm --with-dm \
			--with-knem=$${KNEM_ROOT} \
			--with-rdmacm=$${RDMA_CORE_ROOT} \
			--with-verbs=$${RDMA_CORE_ROOT} \
			--with-mlx5-dv=$${RDMA_CORE_ROOT} \
			--with-cuda=$${CUDA_TOOLKIT_ROOT} \
			--without-rocm \
			--with-gdrcopy=$${GDRCOPY_ROOT} \
			--without-java \
			--enable-mt \
			--enable-optimizations \
			--enable-compiler-opt=3 \
			--without-mpi \
			MPICC= MPIRUN= \
			$($(ucx-cuda)-configure-$(ARCH)-opts) && \
		$(MAKE)
	@touch $@

$($(ucx-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-cuda)-prefix)/.pkgbuild
	cd $($(ucx-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx-cuda)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ucx-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-cuda)-prefix)/.pkgcheck
	$(MAKE) -C $($(ucx-cuda)-srcdir) install
	@touch $@

$($(ucx-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(ucx-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ucx-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ucx-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ucx-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(ucx-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(ucx-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv UCX_ROOT $($(ucx-cuda)-prefix)" >>$@
	echo "setenv UCX_INCDIR $($(ucx-cuda)-prefix)/include" >>$@
	echo "setenv UCX_INCLUDEDIR $($(ucx-cuda)-prefix)/include" >>$@
	echo "setenv UCX_LIBDIR $($(ucx-cuda)-prefix)/lib" >>$@
	echo "setenv UCX_LIBRARYDIR $($(ucx-cuda)-prefix)/lib" >>$@
	echo "setenv UCX_WARN_UNUSED_ENV_VARS n" >>$@
	echo "prepend-path PATH $($(ucx-cuda)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ucx-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ucx-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(ucx-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ucx-cuda)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(ucx-cuda)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(ucx-cuda)\"" >>$@

$(ucx-cuda)-src: $$($(ucx-cuda)-src)
$(ucx-cuda)-unpack: $($(ucx-cuda)-prefix)/.pkgunpack
$(ucx-cuda)-patch: $($(ucx-cuda)-prefix)/.pkgpatch
$(ucx-cuda)-build: $($(ucx-cuda)-prefix)/.pkgbuild
$(ucx-cuda)-check: $($(ucx-cuda)-prefix)/.pkgcheck
$(ucx-cuda)-install: $($(ucx-cuda)-prefix)/.pkginstall
$(ucx-cuda)-modulefile: $($(ucx-cuda)-modulefile)
$(ucx-cuda)-clean:
	rm -rf $($(ucx-cuda)-modulefile)
	rm -rf $($(ucx-cuda)-prefix)
	rm -rf $($(ucx-cuda)-srcdir)
$(ucx-cuda): $(ucx-cuda)-src $(ucx-cuda)-unpack $(ucx-cuda)-patch $(ucx-cuda)-build $(ucx-cuda)-check $(ucx-cuda)-install $(ucx-cuda)-modulefile
