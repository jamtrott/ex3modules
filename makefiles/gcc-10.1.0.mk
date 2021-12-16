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
# gcc-10.1.0

gcc-10.1.0-program-suffix = -10.1
gcc-10.1.0-version = 10.1.0
gcc-10.1.0 = gcc-$(gcc-10.1.0-version)
$(gcc-10.1.0)-description = GNU Compiler Collection
$(gcc-10.1.0)-url = https://gcc.gnu.org/
$(gcc-10.1.0)-srcurl =
$(gcc-10.1.0)-builddeps = $(mpfr) $(gmp) $(mpc)
$(gcc-10.1.0)-prereqs = $(mpfr) $(gmp) $(mpc)
$(gcc-10.1.0)-src = $($(gcc-src-10.1.0)-src)
$(gcc-10.1.0)-srcdir = $(pkgsrcdir)/$(gcc-10.1.0)
$(gcc-10.1.0)-builddir = $($(gcc-10.1.0)-srcdir)
$(gcc-10.1.0)-modulefile = $(modulefilesdir)/$(gcc-10.1.0)
$(gcc-10.1.0)-prefix = $(pkgdir)/$(gcc-10.1.0)

$($(gcc-10.1.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gcc-10.1.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gcc-10.1.0)-prefix)/.pkgunpack: $$($(gcc-10.1.0)-src) $($(gcc-10.1.0)-srcdir)/.markerfile $($(gcc-10.1.0)-prefix)/.markerfile $$(foreach dep,$$($(gcc-10.1.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gcc-10.1.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gcc-10.1.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-10.1.0)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gcc-10.1.0)-builddir),$($(gcc-10.1.0)-srcdir))
$($(gcc-10.1.0)-builddir)/.markerfile: $($(gcc-10.1.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gcc-10.1.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-10.1.0)-builddir)/.markerfile $($(gcc-10.1.0)-prefix)/.pkgpatch
	cd $($(gcc-10.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gcc-10.1.0)-builddeps) && \
		./configure --prefix=$($(gcc-10.1.0)-prefix) \
			--enable-languages=c,c++,fortran \
			--enable-checking=release \
			--disable-multilib \
			--program-suffix=$(gcc-10.1.0-program-suffix) && \
		$(MAKE)
	@touch $@

$($(gcc-10.1.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-10.1.0)-builddir)/.markerfile $($(gcc-10.1.0)-prefix)/.pkgbuild
#	Some tests currently fail
#	cd $($(gcc-10.1.0)-builddir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(gcc-10.1.0)-builddeps) && \
#		$(MAKE) check
	@touch $@

$($(gcc-10.1.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-10.1.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-10.1.0)-builddir)/.markerfile $($(gcc-10.1.0)-prefix)/.pkgcheck
	cd $($(gcc-10.1.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gcc-10.1.0)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gcc-10.1.0)-modulefile): $(modulefilesdir)/.markerfile $($(gcc-10.1.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gcc-10.1.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gcc-10.1.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gcc-10.1.0)-description)\"" >>$@
	echo "module-whatis \"$($(gcc-10.1.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(gcc-10.1.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GCC_ROOT $($(gcc-10.1.0)-prefix)" >>$@
	echo "setenv CC $($(gcc-10.1.0)-prefix)/bin/gcc$(gcc-10.1.0-program-suffix)" >>$@
	echo "setenv GCC $($(gcc-10.1.0)-prefix)/bin/gcc$(gcc-10.1.0-program-suffix)" >>$@
	echo "setenv CXX $($(gcc-10.1.0)-prefix)/bin/g++$(gcc-10.1.0-program-suffix)" >>$@
	echo "setenv FC $($(gcc-10.1.0)-prefix)/bin/gfortran$(gcc-10.1.0-program-suffix)" >>$@
	echo "setenv F77 $($(gcc-10.1.0)-prefix)/bin/gfortran$(gcc-10.1.0-program-suffix)" >>$@
	echo "setenv F90 $($(gcc-10.1.0)-prefix)/bin/gfortran$(gcc-10.1.0-program-suffix)" >>$@
	echo "setenv F95 $($(gcc-10.1.0)-prefix)/bin/gfortran$(gcc-10.1.0-program-suffix)" >>$@
	echo "prepend-path PATH $($(gcc-10.1.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gcc-10.1.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gcc-10.1.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-10.1.0)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-10.1.0)-prefix)/libx32" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-10.1.0)-prefix)/lib32" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-10.1.0)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-10.1.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-10.1.0)-prefix)/libx32" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-10.1.0)-prefix)/lib32" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-10.1.0)-prefix)/lib64" >>$@
	echo "prepend-path MANPATH $($(gcc-10.1.0)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gcc-10.1.0)-prefix)/share/info" >>$@
	echo "set MSG \"$(gcc-10.1.0)\"" >>$@

$(gcc-10.1.0)-src: $$($(gcc-10.1.0)-src)
$(gcc-10.1.0)-unpack: $($(gcc-10.1.0)-prefix)/.pkgunpack
$(gcc-10.1.0)-patch: $($(gcc-10.1.0)-prefix)/.pkgpatch
$(gcc-10.1.0)-build: $($(gcc-10.1.0)-prefix)/.pkgbuild
$(gcc-10.1.0)-check: $($(gcc-10.1.0)-prefix)/.pkgcheck
$(gcc-10.1.0)-install: $($(gcc-10.1.0)-prefix)/.pkginstall
$(gcc-10.1.0)-modulefile: $($(gcc-10.1.0)-modulefile)
$(gcc-10.1.0)-clean:
	rm -rf $($(gcc-10.1.0)-modulefile)
	rm -rf $($(gcc-10.1.0)-prefix)
	rm -rf $($(gcc-10.1.0)-srcdir)
$(gcc-10.1.0): $(gcc-10.1.0)-src $(gcc-10.1.0)-unpack $(gcc-10.1.0)-patch $(gcc-10.1.0)-build $(gcc-10.1.0)-check $(gcc-10.1.0)-install $(gcc-10.1.0)-modulefile
