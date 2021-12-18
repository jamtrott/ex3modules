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
# gfortran-8.4.0

gfortran-8.4.0-version = 8.4.0
gfortran-8.4.0 = gfortran-$(gfortran-8.4.0-version)
$(gfortran-8.4.0)-description = GNU Fortran
$(gfortran-8.4.0)-url = https://gcc.gnu.org/
$(gfortran-8.4.0)-srcurl =
$(gfortran-8.4.0)-builddeps = $(mpfr) $(gmp) $(mpc)
$(gfortran-8.4.0)-prereqs =
$(gfortran-8.4.0)-src = $($(gcc-src-8.4.0)-src)
$(gfortran-8.4.0)-srcdir = $(pkgsrcdir)/$(gfortran-8.4.0)
$(gfortran-8.4.0)-builddir = $($(gfortran-8.4.0)-srcdir)
$(gfortran-8.4.0)-modulefile = $(modulefilesdir)/$(gfortran-8.4.0)
$(gfortran-8.4.0)-prefix = $(pkgdir)/$(gfortran-8.4.0)

$($(gfortran-8.4.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gfortran-8.4.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gfortran-8.4.0)-prefix)/.pkgunpack: $$($(gfortran-8.4.0)-src) $($(gfortran-8.4.0)-srcdir)/.markerfile $($(gfortran-8.4.0)-prefix)/.markerfile $$(foreach dep,$$($(gfortran-8.4.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gfortran-8.4.0)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gfortran-8.4.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gfortran-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gfortran-8.4.0)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gfortran-8.4.0)-builddir),$($(gfortran-8.4.0)-srcdir))
$($(gfortran-8.4.0)-builddir)/.markerfile: $($(gfortran-8.4.0)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gfortran-8.4.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gfortran-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gfortran-8.4.0)-builddir)/.markerfile $($(gfortran-8.4.0)-prefix)/.pkgpatch
	cd $($(gfortran-8.4.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gfortran-8.4.0)-builddeps) && \
		./configure --prefix=$($(gfortran-8.4.0)-prefix) \
			--enable-languages=fortran \
			--enable-checking=release \
			--disable-multilib && \
		$(MAKE)
	@touch $@

$($(gfortran-8.4.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gfortran-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gfortran-8.4.0)-builddir)/.markerfile $($(gfortran-8.4.0)-prefix)/.pkgbuild
	@touch $@

$($(gfortran-8.4.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gfortran-8.4.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(gfortran-8.4.0)-builddir)/.markerfile $($(gfortran-8.4.0)-prefix)/.pkgcheck
	cd $($(gfortran-8.4.0)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gfortran-8.4.0)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gfortran-8.4.0)-modulefile): $(modulefilesdir)/.markerfile $($(gfortran-8.4.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "#$(gfortran-8.4.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for$(gfortran-8.4.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gfortran-8.4.0)-description)\"" >>$@
	echo "module-whatis \"$($(gfortran-8.4.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(gfortran-8.4.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GFORTRAN_ROOT $($(gfortran-8.4.0)-prefix)" >>$@
	echo "setenv GFORTRAN_LIBDIR $($(gfortran-8.4.0)-prefix)/lib64" >>$@
	echo "setenv GFORTRAN_LIBRARYDIR $($(gfortran-8.4.0)-prefix)/lib64" >>$@
	echo "setenv FC $($(gfortran-8.4.0)-prefix)/bin/gfortran$(gfortran-8.4.0-program-suffix)" >>$@
	echo "setenv F77 $($(gfortran-8.4.0)-prefix)/bin/gfortran$(gfortran-8.4.0-program-suffix)" >>$@
	echo "setenv F90 $($(gfortran-8.4.0)-prefix)/bin/gfortran$(gfortran-8.4.0-program-suffix)" >>$@
	echo "setenv F95 $($(gfortran-8.4.0)-prefix)/bin/gfortran$(gfortran-8.4.0-program-suffix)" >>$@
	echo "prepend-path LIBRARY_PATH $($(gfortran-8.4.0)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(gfortran-8.4.0)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gfortran-8.4.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gfortran-8.4.0)-prefix)/lib64" >>$@
	echo "set MSG \"$(gfortran-8.4.0)\"" >>$@

$(gfortran-8.4.0)-src: $$($(gfortran-8.4.0)-src)
$(gfortran-8.4.0)-unpack: $($(gfortran-8.4.0)-prefix)/.pkgunpack
$(gfortran-8.4.0)-patch: $($(gfortran-8.4.0)-prefix)/.pkgpatch
$(gfortran-8.4.0)-build: $($(gfortran-8.4.0)-prefix)/.pkgbuild
$(gfortran-8.4.0)-check: $($(gfortran-8.4.0)-prefix)/.pkgcheck
$(gfortran-8.4.0)-install: $($(gfortran-8.4.0)-prefix)/.pkginstall
$(gfortran-8.4.0)-modulefile: $($(gfortran-8.4.0)-modulefile)
$(gfortran-8.4.0)-clean:
	rm -rf $($(gfortran-8.4.0)-modulefile)
	rm -rf $($(gfortran-8.4.0)-srcdir)
$(gfortran-8.4.0):$(gfortran)-src $(gfortran-8.4.0)-unpack $(gfortran-8.4.0)-patch $(gfortran-8.4.0)-build $(gfortran-8.4.0)-check $(gfortran-8.4.0)-install $(gfortran-8.4.0)-modulefile
