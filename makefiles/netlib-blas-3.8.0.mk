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
# netlib-blas-3.8.0

netlib-blas-version = 3.8.0
netlib-blas = netlib-blas-$(netlib-blas-version)
$(netlib-blas)-description = Reference implementation of Basic Linear Algebra Subprograms (BLAS)
$(netlib-blas)-url = http://www.netlib.org/blas/
$(netlib-blas)-srcurl = http://www.netlib.org/blas/blas-$(netlib-blas-version).tgz
$(netlib-blas)-builddeps = $(gcc-10.1.0) $(libgfortran)
$(netlib-blas)-prereqs = $(libgfortran)
$(netlib-blas)-src = $(pkgsrcdir)/$(notdir $($(netlib-blas)-srcurl))
$(netlib-blas)-srcdir = $(pkgsrcdir)/$(netlib-blas)
$(netlib-blas)-builddir = $($(netlib-blas)-srcdir)
$(netlib-blas)-modulefile = $(modulefilesdir)/$(netlib-blas)
$(netlib-blas)-prefix = $(pkgdir)/$(netlib-blas)

$($(netlib-blas)-src): $(dir $($(netlib-blas)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(netlib-blas)-srcurl)

$($(netlib-blas)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(netlib-blas)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(netlib-blas)-prefix)/.pkgunpack: $($(netlib-blas)-src) $($(netlib-blas)-srcdir)/.markerfile $($(netlib-blas)-prefix)/.markerfile
	tar -C $($(netlib-blas)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(netlib-blas)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(netlib-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(netlib-blas)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(netlib-blas)-builddir),$($(netlib-blas)-srcdir))
$($(netlib-blas)-builddir)/.markerfile: $($(netlib-blas)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(netlib-blas)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(netlib-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(netlib-blas)-builddir)/.markerfile $($(netlib-blas)-prefix)/.pkgpatch
	cd $($(netlib-blas)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(netlib-blas)-builddeps) && \
		$${FC} -shared -O3 -fPIC *.f -o libblas.so
	@touch $@

$($(netlib-blas)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(netlib-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(netlib-blas)-builddir)/.markerfile $($(netlib-blas)-prefix)/.pkgbuild
	@touch $@

$($(netlib-blas)-builddir)/blas.pc: $($(netlib-blas)-builddir)/.markerfile
	@printf '' >$@.tmp
	@echo 'libdir=$($(netlib-blas)-prefix)/lib' >>$@.tmp
	@echo 'includedir=$($(netlib-blas)-prefix)/include' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Name: BLAS' >>$@.tmp
	@echo 'Description: FORTRAN reference implementation of BLAS Basic Linear Algebra Subprograms' >>$@.tmp
	@echo 'Version: $(netlib-blas-version)' >>$@.tmp
	@echo 'URL: http://www.netlib.org/blas/' >>$@.tmp
	@echo 'Libs: -L$${libdir} -lblas' >>$@.tmp
	@mv $@.tmp $@

$($(netlib-blas)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(netlib-blas)-builddeps),$(modulefilesdir)/$$(dep)) $($(netlib-blas)-builddir)/.markerfile $($(netlib-blas)-prefix)/.pkgcheck $($(netlib-blas)-builddir)/blas.pc
	$(INSTALL) -d $($(netlib-blas)-prefix)/lib
	$(INSTALL) -m755 $($(netlib-blas)-builddir)/libblas.so $($(netlib-blas)-prefix)/lib
	$(INSTALL) -d $($(netlib-blas)-prefix)/lib/pkgconfig
	$(INSTALL) -m644 $($(netlib-blas)-builddir)/blas.pc $($(netlib-blas)-prefix)/lib/pkgconfig
	@touch $@

$($(netlib-blas)-modulefile): $(modulefilesdir)/.markerfile $($(netlib-blas)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(netlib-blas)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(netlib-blas)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(netlib-blas)-description)\"" >>$@
	echo "module-whatis \"$($(netlib-blas)-url)\"" >>$@
	printf "$(foreach prereq,$($(netlib-blas)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NETLIB_BLAS_ROOT $($(netlib-blas)-prefix)" >>$@
	echo "setenv NETLIB_BLAS_INCDIR $($(netlib-blas)-prefix)/include" >>$@
	echo "setenv NETLIB_BLAS_INCLUDEDIR $($(netlib-blas)-prefix)/include" >>$@
	echo "setenv NETLIB_BLAS_LIBDIR $($(netlib-blas)-prefix)/lib" >>$@
	echo "setenv NETLIB_BLAS_LIBRARYDIR $($(netlib-blas)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(netlib-blas)-prefix)/lib" >>$@
	echo "setenv BLASLIB blas" >>$@
	echo "prepend-path PATH $($(netlib-blas)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(netlib-blas)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(netlib-blas)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(netlib-blas)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(netlib-blas)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(netlib-blas)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(netlib-blas)\"" >>$@

$(netlib-blas)-src: $($(netlib-blas)-src)
$(netlib-blas)-unpack: $($(netlib-blas)-prefix)/.pkgunpack
$(netlib-blas)-patch: $($(netlib-blas)-prefix)/.pkgpatch
$(netlib-blas)-build: $($(netlib-blas)-prefix)/.pkgbuild
$(netlib-blas)-check: $($(netlib-blas)-prefix)/.pkgcheck
$(netlib-blas)-install: $($(netlib-blas)-prefix)/.pkginstall
$(netlib-blas)-modulefile: $($(netlib-blas)-modulefile)
$(netlib-blas)-clean:
	rm -rf $($(netlib-blas)-modulefile)
	rm -rf $($(netlib-blas)-prefix)
	rm -rf $($(netlib-blas)-srcdir)
	rm -rf $($(netlib-blas)-src)
$(netlib-blas): $(netlib-blas)-src $(netlib-blas)-unpack $(netlib-blas)-patch $(netlib-blas)-build $(netlib-blas)-check $(netlib-blas)-install $(netlib-blas)-modulefile
