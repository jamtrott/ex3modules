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
# hwloc-cairo-2.4.1

hwloc-cairo-version = 2.4.1
hwloc-cairo = hwloc-cairo-$(hwloc-cairo-version)
$(hwloc-cairo)-description = Portable abstraction of hierarchical topology of modern architectures
$(hwloc-cairo)-url = https://www.open-mpi.org/projects/hwloc/
$(hwloc-cairo)-srcurl =
$(hwloc-cairo)-builddeps = $(cairo)
$(hwloc-cairo)-prereqs = $(cairo)
$(hwloc-cairo)-src = $($(hwloc-src)-src)
$(hwloc-cairo)-srcdir = $(pkgsrcdir)/$(hwloc-cairo)
$(hwloc-cairo)-builddir = $($(hwloc-cairo)-srcdir)
$(hwloc-cairo)-modulefile = $(modulefilesdir)/$(hwloc-cairo)
$(hwloc-cairo)-prefix = $(pkgdir)/$(hwloc-cairo)

$($(hwloc-cairo)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hwloc-cairo)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hwloc-cairo)-prefix)/.pkgunpack: $$($(hwloc-cairo)-src) $($(hwloc-cairo)-srcdir)/.markerfile $($(hwloc-cairo)-prefix)/.markerfile $$(foreach dep,$$($(hwloc-cairo)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hwloc-cairo)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hwloc-cairo)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-cairo)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(hwloc-cairo)-builddir),$($(hwloc-cairo)-srcdir))
$($(hwloc-cairo)-builddir)/.markerfile: $($(hwloc-cairo)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(hwloc-cairo)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-cairo)-prefix)/.pkgpatch
	cd $($(hwloc-cairo)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc-cairo)-builddeps) && \
		./configure --prefix=$($(hwloc-cairo)-prefix) && \
		$(MAKE)
	@touch $@

$($(hwloc-cairo)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-cairo)-prefix)/.pkgbuild
	cd $($(hwloc-cairo)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc-cairo)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hwloc-cairo)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-cairo)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-cairo)-prefix)/.pkgcheck
	cd $($(hwloc-cairo)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc-cairo)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hwloc-cairo)-modulefile): $(modulefilesdir)/.markerfile $($(hwloc-cairo)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hwloc-cairo)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hwloc-cairo)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hwloc-cairo)-description)\"" >>$@
	echo "module-whatis \"$($(hwloc-cairo)-url)\"" >>$@
	printf "$(foreach prereq,$($(hwloc-cairo)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HWLOC_ROOT $($(hwloc-cairo)-prefix)" >>$@
	echo "setenv HWLOC_INCDIR $($(hwloc-cairo)-prefix)/include" >>$@
	echo "setenv HWLOC_INCLUDEDIR $($(hwloc-cairo)-prefix)/include" >>$@
	echo "setenv HWLOC_LIBDIR $($(hwloc-cairo)-prefix)/lib" >>$@
	echo "setenv HWLOC_LIBRARYDIR $($(hwloc-cairo)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hwloc-cairo)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hwloc-cairo)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hwloc-cairo)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hwloc-cairo)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hwloc-cairo)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(hwloc-cairo)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(hwloc-cairo)-prefix)/share/man" >>$@
	echo "set MSG \"$(hwloc-cairo)\"" >>$@

$(hwloc-cairo)-src: $$($(hwloc-cairo)-src)
$(hwloc-cairo)-unpack: $($(hwloc-cairo)-prefix)/.pkgunpack
$(hwloc-cairo)-patch: $($(hwloc-cairo)-prefix)/.pkgpatch
$(hwloc-cairo)-build: $($(hwloc-cairo)-prefix)/.pkgbuild
$(hwloc-cairo)-check: $($(hwloc-cairo)-prefix)/.pkgcheck
$(hwloc-cairo)-install: $($(hwloc-cairo)-prefix)/.pkginstall
$(hwloc-cairo)-modulefile: $($(hwloc-cairo)-modulefile)
$(hwloc-cairo)-clean:
	rm -rf $($(hwloc-cairo)-modulefile)
	rm -rf $($(hwloc-cairo)-prefix)
	rm -rf $($(hwloc-cairo)-srcdir)
$(hwloc-cairo): $(hwloc-cairo)-src $(hwloc-cairo)-unpack $(hwloc-cairo)-patch $(hwloc-cairo)-build $(hwloc-cairo)-check $(hwloc-cairo)-install $(hwloc-cairo)-modulefile
