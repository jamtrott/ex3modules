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
# blis-skx-0.7.0

blis-skx-version = 0.7.0
blis-skx = blis-skx-$(blis-skx-version)
$(blis-skx)-description = High-performance BLAS optimised for Intel Skylake-X CPUs
$(blis-skx)-url = https://github.com/flame/blis
$(blis-skx)-srcurl =
$(blis-skx)-builddeps = $(gcc) $(libgfortran) $(libstdcxx)
$(blis-skx)-prereqs = $(libgfortran) $(libstdcxx)
$(blis-skx)-src =  $($(blis-src)-src)
$(blis-skx)-srcdir = $(pkgsrcdir)/$(blis-skx)
$(blis-skx)-builddir = $($(blis-skx)-srcdir)
$(blis-skx)-modulefile = $(modulefilesdir)/$(blis-skx)
$(blis-skx)-prefix = $(pkgdir)/$(blis-skx)

ifneq ($(ARCH),x86_64)
$(info Skipping $(blis-skx) - requires x86_64)
$(blis-skx)-src:
$(blis-skx)-unpack:
$(blis-skx)-patch:
$(blis-skx)-build:
$(blis-skx)-check:
$(blis-skx)-install:
$(blis-skx)-modulefile:
$(blis-skx)-clean:
$(blis-skx): $(blis-skx)-src $(blis-skx)-unpack $(blis-skx)-patch $(blis-skx)-build $(blis-skx)-check $(blis-skx)-install $(blis-skx)-modulefile

else ifneq ($(AVX512F),true)
$(info Skipping $(blis-skx) - requires avx512f)
$(blis-skx)-src:
$(blis-skx)-unpack:
$(blis-skx)-patch:
$(blis-skx)-build:
$(blis-skx)-check:
$(blis-skx)-install:
$(blis-skx)-modulefile:
$(blis-skx)-clean:
$(blis-skx): $(blis-skx)-src $(blis-skx)-unpack $(blis-skx)-patch $(blis-skx)-build $(blis-skx)-check $(blis-skx)-install $(blis-skx)-modulefile

else
$($(blis-skx)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-skx)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-skx)-prefix)/.pkgunpack: $$($(blis-skx)-src) $($(blis-skx)-srcdir)/.markerfile $($(blis-skx)-prefix)/.markerfile
	tar -C $($(blis-skx)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(blis-skx)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-skx)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-skx)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(blis-skx)-builddir),$($(blis-skx)-srcdir))
$($(blis-skx)-builddir)/.markerfile: $($(blis-skx)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(blis-skx)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-skx)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-skx)-builddir)/.markerfile $($(blis-skx)-prefix)/.pkgpatch
	cd $($(blis-skx)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-skx)-builddeps) && \
		./configure --prefix=$($(blis-skx)-prefix) skx && \
		$(MAKE)
	@touch $@

$($(blis-skx)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-skx)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-skx)-builddir)/.markerfile $($(blis-skx)-prefix)/.pkgbuild
	cd $($(blis-skx)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-skx)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(blis-skx)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-skx)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-skx)-builddir)/.markerfile $($(blis-skx)-prefix)/.pkgcheck
	cd $($(blis-skx)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-skx)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(blis-skx)-modulefile): $(modulefilesdir)/.markerfile $($(blis-skx)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(blis-skx)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(blis-skx)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(blis-skx)-description)\"" >>$@
	echo "module-whatis \"$($(blis-skx)-url)\"" >>$@
	printf "$(foreach prereq,$($(blis-skx)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BLIS_ROOT $($(blis-skx)-prefix)" >>$@
	echo "setenv BLIS_INCDIR $($(blis-skx)-prefix)/include" >>$@
	echo "setenv BLIS_INCLUDEDIR $($(blis-skx)-prefix)/include" >>$@
	echo "setenv BLIS_LIBDIR $($(blis-skx)-prefix)/lib" >>$@
	echo "setenv BLIS_LIBRARYDIR $($(blis-skx)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(blis-skx)-prefix)/lib" >>$@
	echo "setenv BLASLIB blis" >>$@
	echo "prepend-path PATH $($(blis-skx)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(blis-skx)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(blis-skx)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(blis-skx)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(blis-skx)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(blis-skx)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(blis-skx)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(blis-skx)-prefix)/share/info" >>$@
	echo "set MSG \"$(blis-skx)\"" >>$@

$(blis-skx)-src: $$($(blis-skx)-src)
$(blis-skx)-unpack: $($(blis-skx)-prefix)/.pkgunpack
$(blis-skx)-patch: $($(blis-skx)-prefix)/.pkgpatch
$(blis-skx)-build: $($(blis-skx)-prefix)/.pkgbuild
$(blis-skx)-check: $($(blis-skx)-prefix)/.pkgcheck
$(blis-skx)-install: $($(blis-skx)-prefix)/.pkginstall
$(blis-skx)-modulefile: $($(blis-skx)-modulefile)
$(blis-skx)-clean:
	rm -rf $($(blis-skx)-modulefile)
	rm -rf $($(blis-skx)-prefix)
	rm -rf $($(blis-skx)-srcdir)
$(blis-skx): $(blis-skx)-src $(blis-skx)-unpack $(blis-skx)-patch $(blis-skx)-build $(blis-skx)-check $(blis-skx)-install $(blis-skx)-modulefile
endif
