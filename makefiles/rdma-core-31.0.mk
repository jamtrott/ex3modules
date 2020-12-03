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
# rdma-core-31.0

rdma-core-version = 31.0
rdma-core = rdma-core-$(rdma-core-version)
$(rdma-core)-description = Userspace components for the Linux infiniband subsystem
$(rdma-core)-url = https://github.com/linux-rdma/rdma-core/
$(rdma-core)-srcurl = https://github.com/linux-rdma/rdma-core/releases/download/v$(rdma-core-version)/rdma-core-$(rdma-core-version).tar.gz
$(rdma-core)-src = $(pkgsrcdir)/$(notdir $($(rdma-core)-srcurl))
$(rdma-core)-srcdir = $(pkgsrcdir)/$(rdma-core)
$(rdma-core)-builddeps = $(cmake) $(ninja) $(python-docutils) $(libnl)
$(rdma-core)-prereqs = $(libnl)
$(rdma-core)-modulefile = $(modulefilesdir)/$(rdma-core)
$(rdma-core)-prefix = $(pkgdir)/$(rdma-core)

$($(rdma-core)-src): $(dir $($(rdma-core)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(rdma-core)-srcurl)

$($(rdma-core)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(rdma-core)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(rdma-core)-prefix)/.pkgunpack: $($(rdma-core)-src) $($(rdma-core)-srcdir)/.markerfile $($(rdma-core)-prefix)/.markerfile
	tar -C $($(rdma-core)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(rdma-core)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(rdma-core)-builddeps),$(modulefilesdir)/$$(dep)) $($(rdma-core)-prefix)/.pkgunpack
	@touch $@

$($(rdma-core)-srcdir)/build/.markerfile: $($(rdma-core)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(rdma-core)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(rdma-core)-builddeps),$(modulefilesdir)/$$(dep)) $($(rdma-core)-prefix)/.pkgpatch $($(rdma-core)-srcdir)/build/.markerfile
	cd $($(rdma-core)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(rdma-core)-builddeps) && \
		cmake .. -GNinja \
			-DCMAKE_INSTALL_PREFIX=$($(rdma-core)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib && \
	ninja
	@touch $@

$($(rdma-core)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(rdma-core)-builddeps),$(modulefilesdir)/$$(dep)) $($(rdma-core)-prefix)/.pkgbuild
	@touch $@

$($(rdma-core)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(rdma-core)-builddeps),$(modulefilesdir)/$$(dep)) $($(rdma-core)-prefix)/.pkgcheck
	cd $($(rdma-core)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(rdma-core)-builddeps) && \
	ninja install
	@touch $@

$($(rdma-core)-modulefile): $(modulefilesdir)/.markerfile $($(rdma-core)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(rdma-core)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(rdma-core)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(rdma-core)-description)\"" >>$@
	echo "module-whatis \"$($(rdma-core)-url)\"" >>$@
	printf "$(foreach prereq,$($(rdma-core)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv RDMA_CORE_ROOT $($(rdma-core)-prefix)" >>$@
	echo "setenv RDMA_CORE_INCDIR $($(rdma-core)-prefix)/include" >>$@
	echo "setenv RDMA_CORE_INCLUDEDIR $($(rdma-core)-prefix)/include" >>$@
	echo "setenv RDMA_CORE_LIBDIR $($(rdma-core)-prefix)/lib" >>$@
	echo "setenv RDMA_CORE_LIBRARYDIR $($(rdma-core)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(rdma-core)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(rdma-core)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(rdma-core)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(rdma-core)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(rdma-core)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(rdma-core)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(rdma-core)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(rdma-core)-prefix)/share/info" >>$@
	echo "set MSG \"$(rdma-core)\"" >>$@

$(rdma-core)-src: $($(rdma-core)-src)
$(rdma-core)-unpack: $($(rdma-core)-prefix)/.pkgunpack
$(rdma-core)-patch: $($(rdma-core)-prefix)/.pkgpatch
$(rdma-core)-build: $($(rdma-core)-prefix)/.pkgbuild
$(rdma-core)-check: $($(rdma-core)-prefix)/.pkgcheck
$(rdma-core)-install: $($(rdma-core)-prefix)/.pkginstall
$(rdma-core)-modulefile: $($(rdma-core)-modulefile)
$(rdma-core)-clean:
	rm -rf $($(rdma-core)-modulefile)
	rm -rf $($(rdma-core)-prefix)
	rm -rf $($(rdma-core)-srcdir)
	rm -rf $($(rdma-core)-src)
$(rdma-core): $(rdma-core)-src $(rdma-core)-unpack $(rdma-core)-patch $(rdma-core)-build $(rdma-core)-check $(rdma-core)-install $(rdma-core)-modulefile
