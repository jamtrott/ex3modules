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
# lapack-3.9.0

lapack-version = 3.9.0
lapack = lapack-$(lapack-version)
$(lapack)-description = Library of Fortran subroutines for numerical linear algebra
$(lapack)-url = http://performance.netlib.org/lapack/
$(lapack)-srcurl = https://github.com/Reference-LAPACK/lapack/archive/v$(lapack-version).tar.gz
$(lapack)-builddeps = $(gcc) $(libgfortran)
$(lapack)-prereqs = $(libgfortran)
$(lapack)-src = $(pkgsrcdir)/lapack-$(notdir $($(lapack)-srcurl))
$(lapack)-srcdir = $(pkgsrcdir)/$(lapack)
$(lapack)-builddir = $($(lapack)-srcdir)
$(lapack)-modulefile = $(modulefilesdir)/$(lapack)
$(lapack)-prefix = $(pkgdir)/$(lapack)

$($(lapack)-src): $(dir $($(lapack)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(lapack)-srcurl)

$($(lapack)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(lapack)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(lapack)-prefix)/.pkgunpack: $($(lapack)-src) $($(lapack)-srcdir)/.markerfile $($(lapack)-prefix)/.markerfile $$(foreach dep,$$($(lapack)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(lapack)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(lapack)-srcdir)/make.inc: $($(lapack)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'SHELL = /bin/sh' >>$@.tmp
	@echo 'CC = $(CC)' >>$@.tmp
	@echo 'CFLAGS = -O3 -fpic' >>$@.tmp
	@echo 'FC = $(FC)' >>$@.tmp
	@echo 'FFLAGS = -O3 -frecursive -fpic' >>$@.tmp
	@echo 'FFLAGS_DRV = $$(FFLAGS)' >>$@.tmp
	@echo 'FFLAGS_NOOPT = -O0 -frecursive -fpic' >>$@.tmp
	@echo 'LDFLAGS =' >>$@.tmp
	@echo 'AR = $(CC)' >>$@.tmp
	@echo 'ARFLAGS = -shared -o' >>$@.tmp
	@echo 'RANLIB = echo' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'TIMER = INT_ETIME' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'BLASLIB      = $$(TOPSRCDIR)/librefblas.so' >>$@.tmp
	@echo 'CBLASLIB     = $$(TOPSRCDIR)/libcblas.so' >>$@.tmp
	@echo 'LAPACKLIB    = $$(TOPSRCDIR)/liblapack.so' >>$@.tmp
	@echo 'TMGLIB       = $$(TOPSRCDIR)/libtmglib.so' >>$@.tmp
	@echo 'LAPACKELIB   = $$(TOPSRCDIR)/liblapacke.so' >>$@.tmp
	@mv $@.tmp $@

$($(lapack)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(lapack)-prefix)/.pkgunpack $($(lapack)-srcdir)/make.inc
	@touch $@

ifneq ($($(lapack)-builddir),$($(lapack)-srcdir))
$($(lapack)-builddir)/.markerfile: $($(lapack)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(lapack)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(lapack)-builddir)/.markerfile $($(lapack)-prefix)/.pkgpatch
	cd $($(lapack)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(lapack)-builddeps) && \
		$(MAKE) lapacklib CC=$${CC} FC=$${FC} && \
		$(MAKE) lapackelib CC=$${CC} FC=$${FC}
	@touch $@

$($(lapack)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(lapack)-builddir)/.markerfile $($(lapack)-prefix)/.pkgbuild
	@touch $@

$($(lapack)-srcdir)/lapack.pc: $($(lapack)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'prefix=$($(lapack)-prefix)' >>$@.tmp
	@echo 'libdir=$($(lapack)-prefix)/lib' >>$@.tmp
	@echo 'includedir=$($(lapack)-prefix)/include' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Name: LAPACK' >>$@.tmp
	@echo 'Description: FORTRAN reference implementation of LAPACK Linear Algebra PACKage' >>$@.tmp
	@echo 'Version: $(lapack-version)' >>$@.tmp
	@echo 'URL: http://www.netlib.org/lapack/' >>$@.tmp
	@echo 'Libs: -L$${libdir} -llapack' >>$@.tmp
	@echo 'Requires.private: blas' >>$@.tmp
	@mv $@.tmp $@

$($(lapack)-srcdir)/lapacke.pc: $($(lapack)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'prefix=$($(lapack)-prefix)' >>$@.tmp
	@echo 'libdir=$($(lapack)-prefix)/lib' >>$@.tmp
	@echo 'includedir=$($(lapack)-prefix)/include' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Name: LAPACKE' >>$@.tmp
	@echo 'Description: C Standard Interface to LAPACK Linear Algebra PACKage' >>$@.tmp
	@echo 'Version: $(lapack-version)' >>$@.tmp
	@echo 'URL: http://www.netlib.org/lapack/#_standard_c_language_apis_for_lapack' >>$@.tmp
	@echo 'Libs: -L$${libdir} -llapacke' >>$@.tmp
	@echo 'Cflags: -I$${includedir}' >>$@.tmp
	@echo 'Requires.private: lapack' >>$@.tmp
	@mv $@.tmp $@

$($(lapack)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(lapack)-builddeps),$(modulefilesdir)/$$(dep)) $($(lapack)-builddir)/.markerfile $($(lapack)-prefix)/.pkgcheck $($(lapack)-srcdir)/lapack.pc $($(lapack)-srcdir)/lapacke.pc
	$(INSTALL) -d $($(lapack)-prefix)/include
	$(INSTALL) -m644 $($(lapack)-srcdir)/LAPACKE/include/lapack.h $($(lapack)-prefix)/include
	$(INSTALL) -m644 $($(lapack)-srcdir)/LAPACKE/include/lapacke.h $($(lapack)-prefix)/include
	$(INSTALL) -m644 $($(lapack)-srcdir)/LAPACKE/include/lapacke_config.h $($(lapack)-prefix)/include
	$(INSTALL) -m644 $($(lapack)-srcdir)/LAPACKE/include/lapacke_mangling.h $($(lapack)-prefix)/include
	$(INSTALL) -m644 $($(lapack)-srcdir)/LAPACKE/include/lapacke_utils.h $($(lapack)-prefix)/include
	$(INSTALL) -d $($(lapack)-prefix)/lib
	$(INSTALL) -m755 $($(lapack)-builddir)/liblapack.so $($(lapack)-prefix)/lib
	$(INSTALL) -m755 $($(lapack)-builddir)/liblapacke.so $($(lapack)-prefix)/lib
	$(INSTALL) -d $($(lapack)-prefix)/lib/pkgconfig
	$(INSTALL) -m644 $($(lapack)-srcdir)/lapack.pc $($(lapack)-prefix)/lib/pkgconfig
	$(INSTALL) -m644 $($(lapack)-srcdir)/lapacke.pc $($(lapack)-prefix)/lib/pkgconfig
	@touch $@

$($(lapack)-modulefile): $(modulefilesdir)/.markerfile $($(lapack)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(lapack)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(lapack)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(lapack)-description)\"" >>$@
	echo "module-whatis \"$($(lapack)-url)\"" >>$@
	printf "$(foreach prereq,$($(lapack)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LAPACK_ROOT $($(lapack)-prefix)" >>$@
	echo "setenv LAPACK_INCDIR $($(lapack)-prefix)/include" >>$@
	echo "setenv LAPACK_INCLUDEDIR $($(lapack)-prefix)/include" >>$@
	echo "setenv LAPACK_LIBDIR $($(lapack)-prefix)/lib" >>$@
	echo "setenv LAPACK_LIBRARYDIR $($(lapack)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(lapack)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(lapack)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(lapack)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(lapack)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(lapack)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(lapack)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(lapack)\"" >>$@

$(lapack)-src: $($(lapack)-src)
$(lapack)-unpack: $($(lapack)-prefix)/.pkgunpack
$(lapack)-patch: $($(lapack)-prefix)/.pkgpatch
$(lapack)-build: $($(lapack)-prefix)/.pkgbuild
$(lapack)-check: $($(lapack)-prefix)/.pkgcheck
$(lapack)-install: $($(lapack)-prefix)/.pkginstall
$(lapack)-modulefile: $($(lapack)-modulefile)
$(lapack)-clean:
	rm -rf $($(lapack)-modulefile)
	rm -rf $($(lapack)-prefix)
	rm -rf $($(lapack)-srcdir)
	rm -rf $($(lapack)-src)
$(lapack): $(lapack)-src $(lapack)-unpack $(lapack)-patch $(lapack)-build $(lapack)-check $(lapack)-install $(lapack)-modulefile
