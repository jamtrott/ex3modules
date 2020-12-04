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
# libgccjit-10.1.0

libgccjit-10.1.0-version = 10.1.0
libgccjit-10.1.0 = libgccjit-$(libgccjit-10.1.0-version)
$(libgccjit-10.1.0)-description = Just-in-time compilation library from the GNU Compiler Collection
$(libgccjit-10.1.0)-url = https://gcc.gnu.org/
$(libgccjit-10.1.0)-srcurl =
$(libgccjit-10.1.0)-builddeps = $(mpfr) $(gmp) $(mpc)
$(libgccjit-10.1.0)-prereqs = $(mpfr) $(gmp) $(mpc)
$(libgccjit-10.1.0)-src = $($(gcc-src-10.1.0)-src)
$(libgccjit-10.1.0)-srcdir = $(pkgsrcdir)/$(libgccjit-10.1.0)
$(libgccjit-10.1.0)-builddir = $($(libgccjit-10.1.0)-srcdir)/build
$(libgccjit-10.1.0)-modulefile = $(modulefilesdir)/$(libgccjit-10.1.0)
$(libgccjit-10.1.0)-prefix = $(pkgdir)/$(libgccjit-10.1.0)

$($(libgccjit-10.1.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libgccjit-10.1.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libgccjit-10.1.0)-prefix)/.pkgunpack: $$($(libgccjit-10.1.0)-src) $($(libgccjit-10.1.0)-srcdir)/.markerfile $($(libgccjit-10.1.0)-prefix)/.markerfile
	tar -C $($(libgccjit-10.1.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libgccjit-10.1.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgccjit-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgccjit-10.1.0)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libgccjit-10.1.0)-builddir),$($(libgccjit-10.1.0)-srcdir))
$($(libgccjit-10.1.0)-builddir)/.markerfile: $($(libgccjit-10.1.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libgccjit-10.1.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgccjit-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgccjit-10.1.0)-builddir)/.markerfile $($(libgccjit-10.1.0)-prefix)/.pkgpatch
	cd $($(libgccjit-10.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgccjit-10.1.0)-builddeps) && \
		../configure --prefix=$($(libgccjit-10.1.0)-prefix) \
			--enable-host-shared \
			--enable-languages=jit,c++ \
			--disable-bootstrap \
			--enable-checking=release && \
		$(MAKE)
	@touch $@

$($(libgccjit-10.1.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgccjit-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgccjit-10.1.0)-builddir)/.markerfile $($(libgccjit-10.1.0)-prefix)/.pkgbuild
	cd $($(libgccjit-10.1.0)-builddir)/gcc && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgccjit-10.1.0)-builddeps) && \
		$(MAKE) check-jit
	@touch $@

$($(libgccjit-10.1.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libgccjit-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(libgccjit-10.1.0)-builddir)/.markerfile $($(libgccjit-10.1.0)-prefix)/.pkgcheck
	cd $($(libgccjit-10.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libgccjit-10.1.0)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libgccjit-10.1.0)-modulefile): $(modulefilesdir)/.markerfile $($(libgccjit-10.1.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libgccjit-10.1.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libgccjit-10.1.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libgccjit-10.1.0)-description)\"" >>$@
	echo "module-whatis \"$($(libgccjit-10.1.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(libgccjit-10.1.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBGCCJIT_ROOT $($(libgccjit-10.1.0)-prefix)" >>$@
	echo "prepend-path PATH $($(libgccjit-10.1.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libgccjit-10.1.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libgccjit-10.1.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/libx32" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/lib32" >>$@
	echo "prepend-path LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/libx32" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/lib32" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libgccjit-10.1.0)-prefix)/lib64" >>$@
	echo "prepend-path MANPATH $($(libgccjit-10.1.0)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libgccjit-10.1.0)-prefix)/share/info" >>$@
	echo "set MSG \"$(libgccjit-10.1.0)\"" >>$@

$(libgccjit-10.1.0)-src: $$($(libgccjit-10.1.0)-src)
$(libgccjit-10.1.0)-unpack: $($(libgccjit-10.1.0)-prefix)/.pkgunpack
$(libgccjit-10.1.0)-patch: $($(libgccjit-10.1.0)-prefix)/.pkgpatch
$(libgccjit-10.1.0)-build: $($(libgccjit-10.1.0)-prefix)/.pkgbuild
$(libgccjit-10.1.0)-check: $($(libgccjit-10.1.0)-prefix)/.pkgcheck
$(libgccjit-10.1.0)-install: $($(libgccjit-10.1.0)-prefix)/.pkginstall
$(libgccjit-10.1.0)-modulefile: $($(libgccjit-10.1.0)-modulefile)
$(libgccjit-10.1.0)-clean:
	rm -rf $($(libgccjit-10.1.0)-modulefile)
	rm -rf $($(libgccjit-10.1.0)-prefix)
	rm -rf $($(libgccjit-10.1.0)-srcdir)
$(libgccjit-10.1.0): $(libgccjit-10.1.0)-src $(libgccjit-10.1.0)-unpack $(libgccjit-10.1.0)-patch $(libgccjit-10.1.0)-build $(libgccjit-10.1.0)-check $(libgccjit-10.1.0)-install $(libgccjit-10.1.0)-modulefile
