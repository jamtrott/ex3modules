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
# blis-zen2-0.7.0

blis-zen2-version = 0.7.0
blis-zen2 = blis-zen2-$(blis-zen2-version)
$(blis-zen2)-description = High-performance BLAS optimised for AMD Zen2 CPUs
$(blis-zen2)-url = https://github.com/flame/blis
$(blis-zen2)-srcurl =
$(blis-zen2)-builddeps = $(gcc) $(libgfortran) $(libstdcxx)
$(blis-zen2)-prereqs = $(libgfortran) $(libstdcxx)
$(blis-zen2)-src =  $($(blis-src)-src)
$(blis-zen2)-srcdir = $(pkgsrcdir)/$(blis-zen2)
$(blis-zen2)-builddir = $($(blis-zen2)-srcdir)
$(blis-zen2)-modulefile = $(modulefilesdir)/$(blis-zen2)
$(blis-zen2)-prefix = $(pkgdir)/$(blis-zen2)

ifneq ($(ARCH),x86_64)
$(info Skipping $(blis-zen2) - requires x86_64)
$(blis-zen2)-src:
$(blis-zen2)-unpack:
$(blis-zen2)-patch:
$(blis-zen2)-build:
$(blis-zen2)-check:
$(blis-zen2)-install:
$(blis-zen2)-modulefile:
$(blis-zen2)-clean:
$(blis-zen2): $(blis-zen2)-src $(blis-zen2)-unpack $(blis-zen2)-patch $(blis-zen2)-build $(blis-zen2)-check $(blis-zen2)-install $(blis-zen2)-modulefile

else
$($(blis-zen2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-zen2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-zen2)-prefix)/.pkgunpack: $$($(blis-zen2)-src) $($(blis-zen2)-srcdir)/.markerfile $($(blis-zen2)-prefix)/.markerfile $$(foreach dep,$$($(blis-zen2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(blis-zen2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(blis-zen2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen2)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(blis-zen2)-builddir),$($(blis-zen2)-srcdir))
$($(blis-zen2)-builddir)/.markerfile: $($(blis-zen2)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(blis-zen2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen2)-builddir)/.markerfile $($(blis-zen2)-prefix)/.pkgpatch
	cd $($(blis-zen2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-zen2)-builddeps) && \
		./configure --prefix=$($(blis-zen2)-prefix) zen2 && \
		$(MAKE)
	@touch $@

$($(blis-zen2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen2)-builddir)/.markerfile $($(blis-zen2)-prefix)/.pkgbuild
	cd $($(blis-zen2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-zen2)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(blis-zen2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen2)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen2)-builddir)/.markerfile $($(blis-zen2)-prefix)/.pkgcheck
	cd $($(blis-zen2)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-zen2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(blis-zen2)-modulefile): $(modulefilesdir)/.markerfile $($(blis-zen2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(blis-zen2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(blis-zen2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(blis-zen2)-description)\"" >>$@
	echo "module-whatis \"$($(blis-zen2)-url)\"" >>$@
	printf "$(foreach prereq,$($(blis-zen2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BLIS_ROOT $($(blis-zen2)-prefix)" >>$@
	echo "setenv BLIS_INCDIR $($(blis-zen2)-prefix)/include" >>$@
	echo "setenv BLIS_INCLUDEDIR $($(blis-zen2)-prefix)/include" >>$@
	echo "setenv BLIS_LIBDIR $($(blis-zen2)-prefix)/lib" >>$@
	echo "setenv BLIS_LIBRARYDIR $($(blis-zen2)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(blis-zen2)-prefix)/lib" >>$@
	echo "setenv BLASLIB blis" >>$@
	echo "prepend-path PATH $($(blis-zen2)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(blis-zen2)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(blis-zen2)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(blis-zen2)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(blis-zen2)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(blis-zen2)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(blis-zen2)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(blis-zen2)-prefix)/share/info" >>$@
	echo "set MSG \"$(blis-zen2)\"" >>$@

$(blis-zen2)-src: $$($(blis-zen2)-src)
$(blis-zen2)-unpack: $($(blis-zen2)-prefix)/.pkgunpack
$(blis-zen2)-patch: $($(blis-zen2)-prefix)/.pkgpatch
$(blis-zen2)-build: $($(blis-zen2)-prefix)/.pkgbuild
$(blis-zen2)-check: $($(blis-zen2)-prefix)/.pkgcheck
$(blis-zen2)-install: $($(blis-zen2)-prefix)/.pkginstall
$(blis-zen2)-modulefile: $($(blis-zen2)-modulefile)
$(blis-zen2)-clean:
	rm -rf $($(blis-zen2)-modulefile)
	rm -rf $($(blis-zen2)-prefix)
	rm -rf $($(blis-zen2)-srcdir)
$(blis-zen2): $(blis-zen2)-src $(blis-zen2)-unpack $(blis-zen2)-patch $(blis-zen2)-build $(blis-zen2)-check $(blis-zen2)-install $(blis-zen2)-modulefile
endif
