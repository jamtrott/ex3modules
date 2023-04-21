# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# hwloc-2.7.1

hwloc-2.7.1-version = 2.7.1
hwloc-2.7.1 = hwloc-$(hwloc-2.7.1-version)
$(hwloc-2.7.1)-description = Portable abstraction of hierarchical topology of modern architectures
$(hwloc-2.7.1)-url = https://www.open-mpi.org/projects/hwloc/
$(hwloc-2.7.1)-srcurl =
$(hwloc-2.7.1)-builddeps =
$(hwloc-2.7.1)-prereqs =
$(hwloc-2.7.1)-src = $($(hwloc-src-2.7.1)-src)
$(hwloc-2.7.1)-srcdir = $(pkgsrcdir)/$(hwloc-2.7.1)
$(hwloc-2.7.1)-builddir = $($(hwloc-2.7.1)-srcdir)
$(hwloc-2.7.1)-modulefile = $(modulefilesdir)/$(hwloc-2.7.1)
$(hwloc-2.7.1)-prefix = $(pkgdir)/$(hwloc-2.7.1)

$($(hwloc-2.7.1)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hwloc-2.7.1)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(hwloc-2.7.1)-prefix)/.pkgunpack: $$($(hwloc-2.7.1)-src) $($(hwloc-2.7.1)-srcdir)/.markerfile $($(hwloc-2.7.1)-prefix)/.markerfile $$(foreach dep,$$($(hwloc-2.7.1)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(hwloc-2.7.1)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hwloc-2.7.1)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-2.7.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-2.7.1)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(hwloc-2.7.1)-builddir),$($(hwloc-2.7.1)-srcdir))
$($(hwloc-2.7.1)-builddir)/.markerfile: $($(hwloc-2.7.1)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(hwloc-2.7.1)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-2.7.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-2.7.1)-prefix)/.pkgpatch
	cd $($(hwloc-2.7.1)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc-2.7.1)-builddeps) && \
		./configure --prefix=$($(hwloc-2.7.1)-prefix) \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo --with-cuda="$${CUDA_TOOLKIT_ROOT}" || echo --without-cuda --disable-cuda --disable-nvml) \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo --with-rocm="$${ROCM_ROOT}" || echo --without-rocm) \
			--disable-opencl && \
		$(MAKE)
	@touch $@

$($(hwloc-2.7.1)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-2.7.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-2.7.1)-prefix)/.pkgbuild
# 	cd $($(hwloc-2.7.1)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(hwloc-2.7.1)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(hwloc-2.7.1)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hwloc-2.7.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(hwloc-2.7.1)-prefix)/.pkgcheck
	cd $($(hwloc-2.7.1)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hwloc-2.7.1)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hwloc-2.7.1)-modulefile): $(modulefilesdir)/.markerfile $($(hwloc-2.7.1)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hwloc-2.7.1)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hwloc-2.7.1)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hwloc-2.7.1)-description)\"" >>$@
	echo "module-whatis \"$($(hwloc-2.7.1)-url)\"" >>$@
	printf "$(foreach prereq,$($(hwloc-2.7.1)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HWLOC_ROOT $($(hwloc-2.7.1)-prefix)" >>$@
	echo "setenv HWLOC_INCDIR $($(hwloc-2.7.1)-prefix)/include" >>$@
	echo "setenv HWLOC_INCLUDEDIR $($(hwloc-2.7.1)-prefix)/include" >>$@
	echo "setenv HWLOC_LIBDIR $($(hwloc-2.7.1)-prefix)/lib" >>$@
	echo "setenv HWLOC_LIBRARYDIR $($(hwloc-2.7.1)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hwloc-2.7.1)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(hwloc-2.7.1)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(hwloc-2.7.1)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(hwloc-2.7.1)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(hwloc-2.7.1)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(hwloc-2.7.1)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(hwloc-2.7.1)-prefix)/share/man" >>$@
	echo "set MSG \"$(hwloc-2.7.1)\"" >>$@

$(hwloc-2.7.1)-src: $$($(hwloc-2.7.1)-src)
$(hwloc-2.7.1)-unpack: $($(hwloc-2.7.1)-prefix)/.pkgunpack
$(hwloc-2.7.1)-patch: $($(hwloc-2.7.1)-prefix)/.pkgpatch
$(hwloc-2.7.1)-build: $($(hwloc-2.7.1)-prefix)/.pkgbuild
$(hwloc-2.7.1)-check: $($(hwloc-2.7.1)-prefix)/.pkgcheck
$(hwloc-2.7.1)-install: $($(hwloc-2.7.1)-prefix)/.pkginstall
$(hwloc-2.7.1)-modulefile: $($(hwloc-2.7.1)-modulefile)
$(hwloc-2.7.1)-clean:
	rm -rf $($(hwloc-2.7.1)-modulefile)
	rm -rf $($(hwloc-2.7.1)-prefix)
	rm -rf $($(hwloc-2.7.1)-srcdir)
$(hwloc-2.7.1): $(hwloc-2.7.1)-src $(hwloc-2.7.1)-unpack $(hwloc-2.7.1)-patch $(hwloc-2.7.1)-build $(hwloc-2.7.1)-check $(hwloc-2.7.1)-install $(hwloc-2.7.1)-modulefile
