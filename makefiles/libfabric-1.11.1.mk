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
# libfabric-1.11.1

libfabric-version = 1.11.1
libfabric = libfabric-$(libfabric-version)
$(libfabric)-description = Library for OpenFabrics Interfaces
$(libfabric)-url = http://libfabric.org/
$(libfabric)-srcurl = https://github.com/ofiwg/libfabric/releases/download/v$(libfabric-version)/libfabric-$(libfabric-version).tar.bz2
$(libfabric)-builddeps = $(numactl) $(rdma-core)
$(libfabric)-prereqs = $(numactl) $(rdma-core)
$(libfabric)-src = $(pkgsrcdir)/$(notdir $($(libfabric)-srcurl))
$(libfabric)-srcdir = $(pkgsrcdir)/$(libfabric)
$(libfabric)-builddir = $($(libfabric)-srcdir)
$(libfabric)-modulefile = $(modulefilesdir)/$(libfabric)
$(libfabric)-prefix = $(pkgdir)/$(libfabric)

$($(libfabric)-src): $(dir $($(libfabric)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libfabric)-srcurl)

$($(libfabric)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libfabric)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libfabric)-prefix)/.pkgunpack: $$($(libfabric)-src) $($(libfabric)-srcdir)/.markerfile $($(libfabric)-prefix)/.markerfile
	tar -C $($(libfabric)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libfabric)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libfabric)-builddir),$($(libfabric)-srcdir))
$($(libfabric)-builddir)/.markerfile: $($(libfabric)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(libfabric)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric)-builddir)/.markerfile $($(libfabric)-prefix)/.pkgpatch
	cd $($(libfabric)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfabric)-builddeps) && \
		./configure --prefix=$($(libfabric)-prefix) \
			--enable-debug \
			--enable-bgq=no \
			--enable-direct=no \
			--enable-efa=no \
			--enable-gni=no \
			--enable-mrail=yes \
			--enable-psm=no \
			--enable-psm2=no \
			--enable-psm=no \
			--enable-rxd=yes \
			--enable-rxm=yes \
			--enable-shm=yes \
			--enable-sockets=no \
			--enable-tcp=yes \
			--enable-udp=yes \
			--enable-usnic=no \
			--enable-verbs=$${RDMA_CORE_ROOT} \
			--with-numa=$${NUMACTL_ROOT} && \
		$(MAKE)
	@touch $@

$($(libfabric)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric)-builddir)/.markerfile $($(libfabric)-prefix)/.pkgbuild
	cd $($(libfabric)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfabric)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libfabric)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric)-builddir)/.markerfile $($(libfabric)-prefix)/.pkgcheck
	cd $($(libfabric)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfabric)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libfabric)-modulefile): $(modulefilesdir)/.markerfile $($(libfabric)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libfabric)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libfabric)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libfabric)-description)\"" >>$@
	echo "module-whatis \"$($(libfabric)-url)\"" >>$@
	printf "$(foreach prereq,$($(libfabric)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBFABRIC_ROOT $($(libfabric)-prefix)" >>$@
	echo "setenv LIBFABRIC_INCDIR $($(libfabric)-prefix)/include" >>$@
	echo "setenv LIBFABRIC_INCLUDEDIR $($(libfabric)-prefix)/include" >>$@
	echo "setenv LIBFABRIC_LIBDIR $($(libfabric)-prefix)/lib" >>$@
	echo "setenv LIBFABRIC_LIBRARYDIR $($(libfabric)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libfabric)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libfabric)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libfabric)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libfabric)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libfabric)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libfabric)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libfabric)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libfabric)-prefix)/share/info" >>$@
	echo "set MSG \"$(libfabric)\"" >>$@

$(libfabric)-src: $$($(libfabric)-src)
$(libfabric)-unpack: $($(libfabric)-prefix)/.pkgunpack
$(libfabric)-patch: $($(libfabric)-prefix)/.pkgpatch
$(libfabric)-build: $($(libfabric)-prefix)/.pkgbuild
$(libfabric)-check: $($(libfabric)-prefix)/.pkgcheck
$(libfabric)-install: $($(libfabric)-prefix)/.pkginstall
$(libfabric)-modulefile: $($(libfabric)-modulefile)
$(libfabric)-clean:
	rm -rf $($(libfabric)-modulefile)
	rm -rf $($(libfabric)-prefix)
	rm -rf $($(libfabric)-srcdir)
	rm -rf $($(libfabric)-src)
$(libfabric): $(libfabric)-src $(libfabric)-unpack $(libfabric)-patch $(libfabric)-build $(libfabric)-check $(libfabric)-install $(libfabric)-modulefile
