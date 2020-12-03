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
# hwloc-2.0.4

hwloc-version = 2.0.4
hwloc = hwloc-$(hwloc-version)
$(hwloc)-description = Portable abstraction of hierarchical topology of modern architectures
$(hwloc)-url = https://www.open-mpi.org/projects/hwloc/
$(hwloc)-srcurl =
$(hwloc)-builddeps =
$(hwloc)-prereqs =
$(hwloc)-src = $($(hwloc-src)-src)
$(hwloc)-srcdir = $(pkgsrcdir)/$(hwloc)
$(hwloc)-builddir = $($(hwloc)-srcdir)
$(hwloc)-modulefile = $(modulefilesdir)/$(hwloc)
$(hwloc)-prefix = $(pkgdir)/$(hwloc)

$($(hwloc)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hwloc)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hwloc)-prefix)/.pkgunpack: $$($(hwloc)-src) $($(hwloc)-srcdir)/.markerfile $($(hwloc)-prefix)/.markerfile
	tar -C $($(hwloc)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hwloc)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(hwloc)-builddir),$($(hwloc)-srcdir))
$($(hwloc)-builddir)/.markerfile: $($(hwloc)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(hwloc)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc)-prefix)/.pkgpatch
	cd $($(hwloc)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc)-builddeps) && \
		./configure --prefix=$($(hwloc)-prefix) && \
		$(MAKE)
	@touch $@

$($(hwloc)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc)-prefix)/.pkgbuild
# 	cd $($(hwloc)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(hwloc)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(hwloc)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc)-prefix)/.pkgcheck
	cd $($(hwloc)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hwloc)-modulefile): $(modulefilesdir)/.markerfile $($(hwloc)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hwloc)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hwloc)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hwloc)-description)\"" >>$@
	echo "module-whatis \"$($(hwloc)-url)\"" >>$@
	printf "$(foreach prereq,$($(hwloc)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HWLOC_ROOT $($(hwloc)-prefix)" >>$@
	echo "setenv HWLOC_INCDIR $($(hwloc)-prefix)/include" >>$@
	echo "setenv HWLOC_INCLUDEDIR $($(hwloc)-prefix)/include" >>$@
	echo "setenv HWLOC_LIBDIR $($(hwloc)-prefix)/lib" >>$@
	echo "setenv HWLOC_LIBRARYDIR $($(hwloc)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hwloc)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hwloc)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hwloc)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hwloc)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hwloc)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(hwloc)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(hwloc)-prefix)/share/man" >>$@
	echo "set MSG \"$(hwloc)\"" >>$@

$(hwloc)-src: $$($(hwloc)-src)
$(hwloc)-unpack: $($(hwloc)-prefix)/.pkgunpack
$(hwloc)-patch: $($(hwloc)-prefix)/.pkgpatch
$(hwloc)-build: $($(hwloc)-prefix)/.pkgbuild
$(hwloc)-check: $($(hwloc)-prefix)/.pkgcheck
$(hwloc)-install: $($(hwloc)-prefix)/.pkginstall
$(hwloc)-modulefile: $($(hwloc)-modulefile)
$(hwloc)-clean:
	rm -rf $($(hwloc)-modulefile)
	rm -rf $($(hwloc)-prefix)
	rm -rf $($(hwloc)-srcdir)
$(hwloc): $(hwloc)-src $(hwloc)-unpack $(hwloc)-patch $(hwloc)-build $(hwloc)-check $(hwloc)-install $(hwloc)-modulefile
