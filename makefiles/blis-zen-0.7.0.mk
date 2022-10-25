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
# blis-zen-0.7.0

blis-zen-version = 0.7.0
blis-zen = blis-zen-$(blis-zen-version)
$(blis-zen)-description = High-performance BLAS optimised for AMD Zen CPUs
$(blis-zen)-url = https://github.com/flame/blis
$(blis-zen)-srcurl =
$(blis-zen)-builddeps = $(gfortran)
$(blis-zen)-prereqs =
$(blis-zen)-src =  $($(blis-src)-src)
$(blis-zen)-srcdir = $(pkgsrcdir)/$(blis-zen)
$(blis-zen)-builddir = $($(blis-zen)-srcdir)
$(blis-zen)-modulefile = $(modulefilesdir)/$(blis-zen)
$(blis-zen)-prefix = $(pkgdir)/$(blis-zen)

ifneq ($(ARCH),x86_64)
$(info Skipping $(blis-zen) - requires x86_64)
$(blis-zen)-src:
$(blis-zen)-unpack:
$(blis-zen)-patch:
$(blis-zen)-build:
$(blis-zen)-check:
$(blis-zen)-install:
$(blis-zen)-modulefile:
$(blis-zen)-clean:
$(blis-zen): $(blis-zen)-src $(blis-zen)-unpack $(blis-zen)-patch $(blis-zen)-build $(blis-zen)-check $(blis-zen)-install $(blis-zen)-modulefile

else
$($(blis-zen)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-zen)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-zen)-prefix)/.pkgunpack: $$($(blis-zen)-src) $($(blis-zen)-srcdir)/.markerfile $($(blis-zen)-prefix)/.markerfile $$(foreach dep,$$($(blis-zen)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(blis-zen)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(blis-zen)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(blis-zen)-builddir),$($(blis-zen)-srcdir))
$($(blis-zen)-builddir)/.markerfile: $($(blis-zen)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(blis-zen)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen)-builddir)/.markerfile $($(blis-zen)-prefix)/.pkgpatch
	cd $($(blis-zen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-zen)-builddeps) && \
		./configure --prefix=$($(blis-zen)-prefix) --enable-cblas zen && \
		$(MAKE)
	@touch $@

$($(blis-zen)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen)-builddir)/.markerfile $($(blis-zen)-prefix)/.pkgbuild
	cd $($(blis-zen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-zen)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(blis-zen)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-zen)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-zen)-builddir)/.markerfile $($(blis-zen)-prefix)/.pkgcheck
	cd $($(blis-zen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-zen)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(blis-zen)-modulefile): $(modulefilesdir)/.markerfile $($(blis-zen)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(blis-zen)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(blis-zen)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(blis-zen)-description)\"" >>$@
	echo "module-whatis \"$($(blis-zen)-url)\"" >>$@
	printf "$(foreach prereq,$($(blis-zen)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BLIS_ROOT $($(blis-zen)-prefix)" >>$@
	echo "setenv BLIS_INCDIR $($(blis-zen)-prefix)/include" >>$@
	echo "setenv BLIS_INCLUDEDIR $($(blis-zen)-prefix)/include" >>$@
	echo "setenv BLIS_LIBDIR $($(blis-zen)-prefix)/lib" >>$@
	echo "setenv BLIS_LIBRARYDIR $($(blis-zen)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(blis-zen)-prefix)/lib" >>$@
	echo "setenv BLASLIB blis" >>$@
	echo "prepend-path PATH $($(blis-zen)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(blis-zen)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(blis-zen)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(blis-zen)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(blis-zen)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(blis-zen)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(blis-zen)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(blis-zen)-prefix)/share/info" >>$@
	echo "set MSG \"$(blis-zen)\"" >>$@

$(blis-zen)-src: $$($(blis-zen)-src)
$(blis-zen)-unpack: $($(blis-zen)-prefix)/.pkgunpack
$(blis-zen)-patch: $($(blis-zen)-prefix)/.pkgpatch
$(blis-zen)-build: $($(blis-zen)-prefix)/.pkgbuild
$(blis-zen)-check: $($(blis-zen)-prefix)/.pkgcheck
$(blis-zen)-install: $($(blis-zen)-prefix)/.pkginstall
$(blis-zen)-modulefile: $($(blis-zen)-modulefile)
$(blis-zen)-clean:
	rm -rf $($(blis-zen)-modulefile)
	rm -rf $($(blis-zen)-prefix)
	rm -rf $($(blis-zen)-srcdir)
$(blis-zen): $(blis-zen)-src $(blis-zen)-unpack $(blis-zen)-patch $(blis-zen)-build $(blis-zen)-check $(blis-zen)-install $(blis-zen)-modulefile
endif
