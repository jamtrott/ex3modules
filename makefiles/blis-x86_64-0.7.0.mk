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
# blis-x86_64-0.7.0

blis-x86_64-version = 0.7.0
blis-x86_64 = blis-x86_64-$(blis-x86_64-version)
$(blis-x86_64)-description = High-performance BLAS optimised for Intel Skylake-X CPUs
$(blis-x86_64)-url = https://github.com/flame/blis
$(blis-x86_64)-srcurl =
$(blis-x86_64)-builddeps = $(gcc) $(libgfortran) $(libstdcxx)
$(blis-x86_64)-prereqs = $(libgfortran) $(libstdcxx)
$(blis-x86_64)-src =  $($(blis-src)-src)
$(blis-x86_64)-srcdir = $(pkgsrcdir)/$(blis-x86_64)
$(blis-x86_64)-builddir = $($(blis-x86_64)-srcdir)
$(blis-x86_64)-modulefile = $(modulefilesdir)/$(blis-x86_64)
$(blis-x86_64)-prefix = $(pkgdir)/$(blis-x86_64)

ifneq ($(ARCH),x86_64)
$(info Skipping $(blis-x86_64) - requires x86_64)
$(blis-x86_64)-src:
$(blis-x86_64)-unpack:
$(blis-x86_64)-patch:
$(blis-x86_64)-build:
$(blis-x86_64)-check:
$(blis-x86_64)-install:
$(blis-x86_64)-modulefile:
$(blis-x86_64)-clean:
$(blis-x86_64): $(blis-x86_64)-src $(blis-x86_64)-unpack $(blis-x86_64)-patch $(blis-x86_64)-build $(blis-x86_64)-check $(blis-x86_64)-install $(blis-x86_64)-modulefile

else
$($(blis-x86_64)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-x86_64)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-x86_64)-prefix)/.pkgunpack: $$($(blis-x86_64)-src) $($(blis-x86_64)-srcdir)/.markerfile $($(blis-x86_64)-prefix)/.markerfile
	tar -C $($(blis-x86_64)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(blis-x86_64)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-x86_64)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-x86_64)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(blis-x86_64)-builddir),$($(blis-x86_64)-srcdir))
$($(blis-x86_64)-builddir)/.markerfile: $($(blis-x86_64)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(blis-x86_64)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-x86_64)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-x86_64)-builddir)/.markerfile $($(blis-x86_64)-prefix)/.pkgpatch
	cd $($(blis-x86_64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-x86_64)-builddeps) && \
		./configure --prefix=$($(blis-x86_64)-prefix) x86_64 && \
		$(MAKE)
	@touch $@

$($(blis-x86_64)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-x86_64)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-x86_64)-builddir)/.markerfile $($(blis-x86_64)-prefix)/.pkgbuild
	cd $($(blis-x86_64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-x86_64)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(blis-x86_64)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-x86_64)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-x86_64)-builddir)/.markerfile $($(blis-x86_64)-prefix)/.pkgcheck
	cd $($(blis-x86_64)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-x86_64)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(blis-x86_64)-modulefile): $(modulefilesdir)/.markerfile $($(blis-x86_64)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(blis-x86_64)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(blis-x86_64)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(blis-x86_64)-description)\"" >>$@
	echo "module-whatis \"$($(blis-x86_64)-url)\"" >>$@
	printf "$(foreach prereq,$($(blis-x86_64)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BLIS_ROOT $($(blis-x86_64)-prefix)" >>$@
	echo "setenv BLIS_INCDIR $($(blis-x86_64)-prefix)/include" >>$@
	echo "setenv BLIS_INCLUDEDIR $($(blis-x86_64)-prefix)/include" >>$@
	echo "setenv BLIS_LIBDIR $($(blis-x86_64)-prefix)/lib" >>$@
	echo "setenv BLIS_LIBRARYDIR $($(blis-x86_64)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(blis-x86_64)-prefix)/lib" >>$@
	echo "setenv BLASLIB blis" >>$@
	echo "prepend-path PATH $($(blis-x86_64)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(blis-x86_64)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(blis-x86_64)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(blis-x86_64)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(blis-x86_64)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(blis-x86_64)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(blis-x86_64)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(blis-x86_64)-prefix)/share/info" >>$@
	echo "set MSG \"$(blis-x86_64)\"" >>$@

$(blis-x86_64)-src: $$($(blis-x86_64)-src)
$(blis-x86_64)-unpack: $($(blis-x86_64)-prefix)/.pkgunpack
$(blis-x86_64)-patch: $($(blis-x86_64)-prefix)/.pkgpatch
$(blis-x86_64)-build: $($(blis-x86_64)-prefix)/.pkgbuild
$(blis-x86_64)-check: $($(blis-x86_64)-prefix)/.pkgcheck
$(blis-x86_64)-install: $($(blis-x86_64)-prefix)/.pkginstall
$(blis-x86_64)-modulefile: $($(blis-x86_64)-modulefile)
$(blis-x86_64)-clean:
	rm -rf $($(blis-x86_64)-modulefile)
	rm -rf $($(blis-x86_64)-prefix)
	rm -rf $($(blis-x86_64)-srcdir)
$(blis-x86_64): $(blis-x86_64)-src $(blis-x86_64)-unpack $(blis-x86_64)-patch $(blis-x86_64)-build $(blis-x86_64)-check $(blis-x86_64)-install $(blis-x86_64)-modulefile
endif
