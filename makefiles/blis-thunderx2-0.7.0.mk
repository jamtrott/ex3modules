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
# blis-thunderx2-0.7.0

blis-thunderx2-version = 0.7.0
blis-thunderx2 = blis-thunderx2-$(blis-thunderx2-version)
$(blis-thunderx2)-description = High-performance BLAS optimised for Cavium ThunderX2 CPUs
$(blis-thunderx2)-url = https://github.com/flame/blis
$(blis-thunderx2)-srcurl =
$(blis-thunderx2)-builddeps = $(libgfortran) $(libstdcxx)
$(blis-thunderx2)-prereqs = $(libgfortran) $(libstdcxx)
$(blis-thunderx2)-src =  $($(blis-src)-src)
$(blis-thunderx2)-srcdir = $(pkgsrcdir)/$(blis-thunderx2)
$(blis-thunderx2)-builddir = $($(blis-thunderx2)-srcdir)
$(blis-thunderx2)-modulefile = $(modulefilesdir)/$(blis-thunderx2)
$(blis-thunderx2)-prefix = $(pkgdir)/$(blis-thunderx2)

ifneq ($(ARCH),aarch64)
$(info Skipping $(blis-thunderx2) - requires aarch64)
$(blis-thunderx2)-src:
$(blis-thunderx2)-unpack:
$(blis-thunderx2)-patch:
$(blis-thunderx2)-build:
$(blis-thunderx2)-check:
$(blis-thunderx2)-install:
$(blis-thunderx2)-modulefile:
$(blis-thunderx2)-clean:
$(blis-thunderx2): $(blis-thunderx2)-src $(blis-thunderx2)-unpack $(blis-thunderx2)-patch $(blis-thunderx2)-build $(blis-thunderx2)-check $(blis-thunderx2)-install $(blis-thunderx2)-modulefile

else
$($(blis-thunderx2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-thunderx2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-thunderx2)-prefix)/.pkgunpack: $$($(blis-thunderx2)-src) $($(blis-thunderx2)-srcdir)/.markerfile $($(blis-thunderx2)-prefix)/.markerfile $$(foreach dep,$$($(blis-thunderx2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(blis-thunderx2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(blis-thunderx2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-thunderx2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-thunderx2)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(blis-thunderx2)-builddir),$($(blis-thunderx2)-srcdir))
$($(blis-thunderx2)-builddir)/.markerfile: $($(blis-thunderx2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(blis-thunderx2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-thunderx2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-thunderx2)-builddir)/.markerfile $($(blis-thunderx2)-prefix)/.pkgpatch
	cd $($(blis-thunderx2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-thunderx2)-builddeps) && \
		./configure --prefix=$($(blis-thunderx2)-prefix) thunderx2 && \
		$(MAKE)
	@touch $@

$($(blis-thunderx2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-thunderx2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-thunderx2)-builddir)/.markerfile $($(blis-thunderx2)-prefix)/.pkgbuild
	cd $($(blis-thunderx2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-thunderx2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(blis-thunderx2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-thunderx2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-thunderx2)-builddir)/.markerfile $($(blis-thunderx2)-prefix)/.pkgcheck
	cd $($(blis-thunderx2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-thunderx2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(blis-thunderx2)-modulefile): $(modulefilesdir)/.markerfile $($(blis-thunderx2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(blis-thunderx2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(blis-thunderx2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(blis-thunderx2)-description)\"" >>$@
	echo "module-whatis \"$($(blis-thunderx2)-url)\"" >>$@
	printf "$(foreach prereq,$($(blis-thunderx2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BLIS_ROOT $($(blis-thunderx2)-prefix)" >>$@
	echo "setenv BLIS_INCDIR $($(blis-thunderx2)-prefix)/include" >>$@
	echo "setenv BLIS_INCLUDEDIR $($(blis-thunderx2)-prefix)/include" >>$@
	echo "setenv BLIS_LIBDIR $($(blis-thunderx2)-prefix)/lib" >>$@
	echo "setenv BLIS_LIBRARYDIR $($(blis-thunderx2)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(blis-thunderx2)-prefix)/lib" >>$@
	echo "setenv BLASLIB blis" >>$@
	echo "prepend-path PATH $($(blis-thunderx2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(blis-thunderx2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(blis-thunderx2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(blis-thunderx2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(blis-thunderx2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(blis-thunderx2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(blis-thunderx2)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(blis-thunderx2)-prefix)/share/info" >>$@
	echo "set MSG \"$(blis-thunderx2)\"" >>$@

$(blis-thunderx2)-src: $$($(blis-thunderx2)-src)
$(blis-thunderx2)-unpack: $($(blis-thunderx2)-prefix)/.pkgunpack
$(blis-thunderx2)-patch: $($(blis-thunderx2)-prefix)/.pkgpatch
$(blis-thunderx2)-build: $($(blis-thunderx2)-prefix)/.pkgbuild
$(blis-thunderx2)-check: $($(blis-thunderx2)-prefix)/.pkgcheck
$(blis-thunderx2)-install: $($(blis-thunderx2)-prefix)/.pkginstall
$(blis-thunderx2)-modulefile: $($(blis-thunderx2)-modulefile)
$(blis-thunderx2)-clean:
	rm -rf $($(blis-thunderx2)-modulefile)
	rm -rf $($(blis-thunderx2)-prefix)
	rm -rf $($(blis-thunderx2)-srcdir)
$(blis-thunderx2): $(blis-thunderx2)-src $(blis-thunderx2)-unpack $(blis-thunderx2)-patch $(blis-thunderx2)-build $(blis-thunderx2)-check $(blis-thunderx2)-install $(blis-thunderx2)-modulefile
endif
