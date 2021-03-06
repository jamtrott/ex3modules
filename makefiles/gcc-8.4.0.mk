# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# gcc-8.4.0

gcc-8.4.0-program-suffix = -8.4
gcc-8.4.0-version = 8.4.0
gcc-8.4.0 = gcc-$(gcc-8.4.0-version)
$(gcc-8.4.0)-description = GNU Compiler Collection
$(gcc-8.4.0)-url = https://gcc.gnu.org/
$(gcc-8.4.0)-srcurl = ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-$(gcc-8.4.0-version)/gcc-$(gcc-8.4.0-version).tar.gz
$(gcc-8.4.0)-src = $(pkgsrcdir)/$(notdir $($(gcc-8.4.0)-srcurl))
$(gcc-8.4.0)-srcdir = $(pkgsrcdir)/$(gcc-8.4.0)
$(gcc-8.4.0)-builddeps = $(mpfr) $(gmp) $(mpc)
$(gcc-8.4.0)-prereqs = $(mpfr) $(gmp) $(mpc)
$(gcc-8.4.0)-modulefile = $(modulefilesdir)/$(gcc-8.4.0)
$(gcc-8.4.0)-prefix = $(pkgdir)/$(gcc-8.4.0)

$($(gcc-8.4.0)-src): $(dir $($(gcc-8.4.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gcc-8.4.0)-srcurl)

$($(gcc-8.4.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gcc-8.4.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gcc-8.4.0)-prefix)/.pkgunpack: $($(gcc-8.4.0)-src) $($(gcc-8.4.0)-srcdir)/.markerfile $($(gcc-8.4.0)-prefix)/.markerfile
	tar -C $($(gcc-8.4.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gcc-8.4.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-8.4.0)-prefix)/.pkgunpack
	@touch $@

$($(gcc-8.4.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-8.4.0)-prefix)/.pkgpatch
	cd $($(gcc-8.4.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gcc-8.4.0)-builddeps) && \
		./configure --prefix=$($(gcc-8.4.0)-prefix) \
			--enable-languages=c,c++,fortran \
			--enable-checking=release \
			--disable-multilib \
			--program-suffix=$(gcc-8.4.0-program-suffix) && \
		$(MAKE)
	@touch $@

$($(gcc-8.4.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-8.4.0)-prefix)/.pkgbuild
# 	https://gcc.gnu.org/bugzilla/show_bug.cgi?id=87716
# 	cd $($(gcc-8.4.0)-srcdir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(gcc-8.4.0)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(gcc-8.4.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gcc-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gcc-8.4.0)-prefix)/.pkgcheck
	$(MAKE) -C $($(gcc-8.4.0)-srcdir) install
	@touch $@

$($(gcc-8.4.0)-modulefile): $(modulefilesdir)/.markerfile $($(gcc-8.4.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gcc-8.4.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gcc-8.4.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gcc-8.4.0)-description)\"" >>$@
	echo "module-whatis \"$($(gcc-8.4.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(gcc-8.4.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GCC_ROOT $($(gcc-8.4.0)-prefix)" >>$@
	echo "setenv CC $($(gcc-8.4.0)-prefix)/bin/gcc$(gcc-8.4.0-program-suffix)" >>$@
	echo "setenv GCC $($(gcc-8.4.0)-prefix)/bin/gcc$(gcc-8.4.0-program-suffix)" >>$@
	echo "setenv CXX $($(gcc-8.4.0)-prefix)/bin/g++$(gcc-8.4.0-program-suffix)" >>$@
	echo "setenv FC $($(gcc-8.4.0)-prefix)/bin/gfortran$(gcc-8.4.0-program-suffix)" >>$@
	echo "setenv F77 $($(gcc-8.4.0)-prefix)/bin/gfortran$(gcc-8.4.0-program-suffix)" >>$@
	echo "setenv F90 $($(gcc-8.4.0)-prefix)/bin/gfortran$(gcc-8.4.0-program-suffix)" >>$@
	echo "setenv F95 $($(gcc-8.4.0)-prefix)/bin/gfortran$(gcc-8.4.0-program-suffix)" >>$@
	echo "prepend-path PATH $($(gcc-8.4.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gcc-8.4.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gcc-8.4.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-8.4.0)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-8.4.0)-prefix)/libx32" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-8.4.0)-prefix)/lib32" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc-8.4.0)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-8.4.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-8.4.0)-prefix)/libx32" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-8.4.0)-prefix)/lib32" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc-8.4.0)-prefix)/lib64" >>$@
	echo "prepend-path MANPATH $($(gcc-8.4.0)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gcc-8.4.0)-prefix)/share/info" >>$@
	echo "set MSG \"$(gcc-8.4.0)\"" >>$@

$(gcc-8.4.0)-src: $($(gcc-8.4.0)-src)
$(gcc-8.4.0)-unpack: $($(gcc-8.4.0)-prefix)/.pkgunpack
$(gcc-8.4.0)-patch: $($(gcc-8.4.0)-prefix)/.pkgpatch
$(gcc-8.4.0)-build: $($(gcc-8.4.0)-prefix)/.pkgbuild
$(gcc-8.4.0)-check: $($(gcc-8.4.0)-prefix)/.pkgcheck
$(gcc-8.4.0)-install: $($(gcc-8.4.0)-prefix)/.pkginstall
$(gcc-8.4.0)-modulefile: $($(gcc-8.4.0)-modulefile)
$(gcc-8.4.0)-clean:
	rm -rf $($(gcc-8.4.0)-modulefile)
	rm -rf $($(gcc-8.4.0)-prefix)
	rm -rf $($(gcc-8.4.0)-srcdir)
	rm -rf $($(gcc-8.4.0)-src)
$(gcc-8.4.0): $(gcc-8.4.0)-src $(gcc-8.4.0)-unpack $(gcc-8.4.0)-patch $(gcc-8.4.0)-build $(gcc-8.4.0)-check $(gcc-8.4.0)-install $(gcc-8.4.0)-modulefile
