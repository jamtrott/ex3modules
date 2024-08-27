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
# ucx-1.17.0

ucx-1.17.0-version = 1.17.0
ucx-1.17.0 = ucx-$(ucx-1.17.0-version)
$(ucx-1.17.0)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications
$(ucx-1.17.0)-url = http://www.openucx.org/
$(ucx-1.17.0)-srcurl =
$(ucx-1.17.0)-builddeps = $(autoconf) $(automake) $(libtool) $(knem) $(numactl) $(rdma-core) $(cuda-toolkit) $(gdrcopy)
$(ucx-1.17.0)-prereqs = $(knem) $(numactl) $(rdma-core) $(cuda-toolkit) $(gdrcopy)
$(ucx-1.17.0)-src = $($(ucx-src-1.17.0)-src)
$(ucx-1.17.0)-srcdir = $(pkgsrcdir)/$(ucx-1.17.0)
$(ucx-1.17.0)-modulefile = $(modulefilesdir)/$(ucx-1.17.0)
$(ucx-1.17.0)-prefix = $(pkgdir)/$(ucx-1.17.0)
$(ucx-1.17.0)-configure-x86_64-opts = --with-avx --with-sse41 --with-sse42
$(ucx-1.17.0)-configure-aarch64-opts =

$($(ucx-1.17.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx-1.17.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx-1.17.0)-prefix)/.pkgunpack: $$($(ucx-1.17.0)-src) $($(ucx-1.17.0)-srcdir)/.markerfile $($(ucx-1.17.0)-prefix)/.markerfile $$(foreach dep,$$($(ucx-1.17.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(ucx-1.17.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ucx-1.17.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.17.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.17.0)-prefix)/.pkgunpack
	sed -i 's,ucx_check_gdrcopy_dir/lib64,ucx_check_gdrcopy_libdir,' $($(ucx-1.17.0)-srcdir)/config/m4/gdrcopy.m4
	@touch $@

$($(ucx-1.17.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.17.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.17.0)-prefix)/.pkgpatch
	cd $($(ucx-1.17.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx-1.17.0)-builddeps) && \
		./autogen.sh && \
		./configure --prefix=$($(ucx-1.17.0)-prefix) \
			--enable-cma \
			--with-rc --with-ud --with-dc --with-ib-hw-tm --with-dm \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --with-cuda="$${CUDA_TOOLKIT_ROOT}" || echo --without-cuda) \
			$$([ ! -z "$${GDRCOPY_ROOT}" ] && echo --with-gdrcopy="$${GDRCOPY_ROOT}") \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo --with-rocm="$${ROCM_ROOT}" || echo --without-rocm) \
			--without-java \
			--enable-mt \
			--enable-optimizations \
			--enable-compiler-opt=3 \
			--without-mpi \
			MPICC= MPIRUN= \
			$($(ucx-1.17.0)-configure-$(ARCH)-opts) && \
		$(MAKE)
	@touch $@

$($(ucx-1.17.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.17.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.17.0)-prefix)/.pkgbuild
	cd $($(ucx-1.17.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx-1.17.0)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ucx-1.17.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx-1.17.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx-1.17.0)-prefix)/.pkgcheck
	$(MAKE) -C $($(ucx-1.17.0)-srcdir) install
	@touch $@

$($(ucx-1.17.0)-modulefile): $(modulefilesdir)/.markerfile $($(ucx-1.17.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ucx-1.17.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ucx-1.17.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ucx-1.17.0)-description)\"" >>$@
	echo "module-whatis \"$($(ucx-1.17.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(ucx-1.17.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv UCX_ROOT $($(ucx-1.17.0)-prefix)" >>$@
	echo "setenv UCX_INCDIR $($(ucx-1.17.0)-prefix)/include" >>$@
	echo "setenv UCX_INCLUDEDIR $($(ucx-1.17.0)-prefix)/include" >>$@
	echo "setenv UCX_LIBDIR $($(ucx-1.17.0)-prefix)/lib" >>$@
	echo "setenv UCX_LIBRARYDIR $($(ucx-1.17.0)-prefix)/lib" >>$@
	echo "setenv UCX_WARN_UNUSED_ENV_VARS n" >>$@
	echo "prepend-path PATH $($(ucx-1.17.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ucx-1.17.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ucx-1.17.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(ucx-1.17.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ucx-1.17.0)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(ucx-1.17.0)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(ucx-1.17.0)\"" >>$@

$(ucx-1.17.0)-src: $$($(ucx-1.17.0)-src)
$(ucx-1.17.0)-unpack: $($(ucx-1.17.0)-prefix)/.pkgunpack
$(ucx-1.17.0)-patch: $($(ucx-1.17.0)-prefix)/.pkgpatch
$(ucx-1.17.0)-build: $($(ucx-1.17.0)-prefix)/.pkgbuild
$(ucx-1.17.0)-check: $($(ucx-1.17.0)-prefix)/.pkgcheck
$(ucx-1.17.0)-install: $($(ucx-1.17.0)-prefix)/.pkginstall
$(ucx-1.17.0)-modulefile: $($(ucx-1.17.0)-modulefile)
$(ucx-1.17.0)-clean:
	rm -rf $($(ucx-1.17.0)-modulefile)
	rm -rf $($(ucx-1.17.0)-prefix)
	rm -rf $($(ucx-1.17.0)-srcdir)
$(ucx-1.17.0): $(ucx-1.17.0)-src $(ucx-1.17.0)-unpack $(ucx-1.17.0)-patch $(ucx-1.17.0)-build $(ucx-1.17.0)-check $(ucx-1.17.0)-install $(ucx-1.17.0)-modulefile
