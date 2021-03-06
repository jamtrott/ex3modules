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
# ucx-1.9.0

ucx-version = 1.9.0
ucx = ucx-$(ucx-version)
$(ucx)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications
$(ucx)-url = http://www.openucx.org/
$(ucx)-srcurl = https://github.com/openucx/ucx/archive/v$(ucx-version).tar.gz
$(ucx)-src = $(pkgsrcdir)/ucx-$(notdir $($(ucx)-srcurl))
$(ucx)-srcdir = $(pkgsrcdir)/$(ucx)
$(ucx)-builddeps = $(knem) $(numactl) $(rdma-core)
$(ucx)-prereqs = $(knem) $(numactl) $(rdma-core)
$(ucx)-modulefile = $(modulefilesdir)/$(ucx)
$(ucx)-prefix = $(pkgdir)/$(ucx)
$(ucx)-configure-x86_64-opts = --with-avx --with-sse41 --with-sse42
$(ucx)-configure-aarch64-opts =

$($(ucx)-src): $(dir $($(ucx)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ucx)-srcurl)

$($(ucx)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ucx)-prefix)/.pkgunpack: $($(ucx)-src) $($(ucx)-srcdir)/.markerfile $($(ucx)-prefix)/.markerfile
	tar -C $($(ucx)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ucx)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx)-prefix)/.pkgunpack
	@touch $@

$($(ucx)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx)-prefix)/.pkgpatch
	cd $($(ucx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx)-builddeps) && \
		./autogen.sh && \
		./configure --prefix=$($(ucx)-prefix) \
			--enable-cma \
			--with-rc --with-ud --with-dc --with-ib-hw-tm --with-dm \
			--with-knem=$${KNEM_ROOT} \
			--with-rdmacm=$${RDMA_CORE_ROOT} \
			--with-verbs=$${RDMA_CORE_ROOT} \
			--with-mlx5-dv=$${RDMA_CORE_ROOT} \
			--without-cuda \
			--without-rocm \
			--without-gdrcopy \
			--without-java \
			--enable-mt \
			--enable-optimizations \
			--enable-compiler-opt=3 \
			--without-mpi \
			MPICC= MPIRUN= \
			$($(ucx)-configure-$(ARCH)-opts) && \
		$(MAKE)
	@touch $@

$($(ucx)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx)-prefix)/.pkgbuild
	cd $($(ucx)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ucx)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ucx)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ucx)-builddeps),$(modulefilesdir)/$$(dep)) $($(ucx)-prefix)/.pkgcheck
	$(MAKE) -C $($(ucx)-srcdir) install
	@touch $@

$($(ucx)-modulefile): $(modulefilesdir)/.markerfile $($(ucx)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ucx)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ucx)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ucx)-description)\"" >>$@
	echo "module-whatis \"$($(ucx)-url)\"" >>$@
	printf "$(foreach prereq,$($(ucx)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv UCX_ROOT $($(ucx)-prefix)" >>$@
	echo "setenv UCX_INCDIR $($(ucx)-prefix)/include" >>$@
	echo "setenv UCX_INCLUDEDIR $($(ucx)-prefix)/include" >>$@
	echo "setenv UCX_LIBDIR $($(ucx)-prefix)/lib" >>$@
	echo "setenv UCX_LIBRARYDIR $($(ucx)-prefix)/lib" >>$@
	echo "setenv UCX_WARN_UNUSED_ENV_VARS n" >>$@
	echo "prepend-path PATH $($(ucx)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ucx)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ucx)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(ucx)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ucx)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(ucx)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(ucx)\"" >>$@

$(ucx)-src: $($(ucx)-src)
$(ucx)-unpack: $($(ucx)-prefix)/.pkgunpack
$(ucx)-patch: $($(ucx)-prefix)/.pkgpatch
$(ucx)-build: $($(ucx)-prefix)/.pkgbuild
$(ucx)-check: $($(ucx)-prefix)/.pkgcheck
$(ucx)-install: $($(ucx)-prefix)/.pkginstall
$(ucx)-modulefile: $($(ucx)-modulefile)
$(ucx)-clean:
	rm -rf $($(ucx)-modulefile)
	rm -rf $($(ucx)-prefix)
	rm -rf $($(ucx)-srcdir)
	rm -rf $($(ucx)-src)
$(ucx): $(ucx)-src $(ucx)-unpack $(ucx)-patch $(ucx)-build $(ucx)-check $(ucx)-install $(ucx)-modulefile
