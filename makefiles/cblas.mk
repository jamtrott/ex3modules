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
# cblas

cblas-version =
cblas = cblas
$(cblas)-description = C wrapper for Fortran BLAS libraries
$(cblas)-url = http://www.netlib.org/blas/
$(cblas)-srcurl = http://www.netlib.org/blas/blast-forum/cblas.tgz
$(cblas)-builddeps = $(gfortran) $(netlib-blas)
$(cblas)-prereqs = $(netlib-blas)
$(cblas)-src = $(pkgsrcdir)/$(notdir $($(cblas)-srcurl))
$(cblas)-srcdir = $(pkgsrcdir)/$(cblas)
$(cblas)-builddir = $($(cblas)-srcdir)/src
$(cblas)-modulefile = $(modulefilesdir)/$(cblas)
$(cblas)-prefix = $(pkgdir)/$(cblas)

$($(cblas)-src): $(dir $($(cblas)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cblas)-srcurl)

$($(cblas)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cblas)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cblas)-prefix)/.pkgunpack: $($(cblas)-src) $($(cblas)-srcdir)/.markerfile $($(cblas)-prefix)/.markerfile $$(foreach dep,$$($(cblas)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cblas)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(cblas)-srcdir)/0001-Making-FORTRAN-compilers-happy.patch: $($(cblas)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 7fb63b1cd386b099d7da6eeaafc3e7dce055a7d0 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: Julien Langou <julien.langou@ucdenver.edu>' >>$@.tmp
	@echo 'Date: Mon, 11 Jul 2016 09:15:44 -0600' >>$@.tmp
	@echo 'Subject: [PATCH] Making FORTRAN compilers happy. Replacing STEMP by STEMP(1)' >>$@.tmp
	@echo ' in some subroutine calls.  Reported by Hans Johnson. Thanks Hans.  Julien.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' testing/c_dblat1.f | 4 ++--' >>$@.tmp
	@echo ' testing/c_sblat1.f | 4 ++--' >>$@.tmp
	@echo ' 2 files changed, 4 insertions(+), 4 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/testing/c_dblat1.f b/testing/c_dblat1.f' >>$@.tmp
	@echo 'index 0aeba45b1..c570a9140 100644' >>$@.tmp
	@echo '--- a/testing/c_dblat1.f' >>$@.tmp
	@echo '+++ b/testing/c_dblat1.f' >>$@.tmp
	@echo '@@ -211,11 +211,11 @@ SUBROUTINE CHECK1(SFAC)' >>$@.tmp
	@echo '             IF (ICASE.EQ.7) THEN' >>$@.tmp
	@echo ' *              .. DNRM2TEST ..' >>$@.tmp
	@echo '                STEMP(1) = DTRUE1(NP1)' >>$@.tmp
	@echo '-               CALL STEST1(DNRM2TEST(N,SX,INCX),STEMP,STEMP,SFAC)' >>$@.tmp
	@echo '+               CALL STEST1(DNRM2TEST(N,SX,INCX),STEMP(1),STEMP,SFAC)' >>$@.tmp
	@echo '             ELSE IF (ICASE.EQ.8) THEN' >>$@.tmp
	@echo ' *              .. DASUMTEST ..' >>$@.tmp
	@echo '                STEMP(1) = DTRUE3(NP1)' >>$@.tmp
	@echo '-               CALL STEST1(DASUMTEST(N,SX,INCX),STEMP,STEMP,SFAC)' >>$@.tmp
	@echo '+               CALL STEST1(DASUMTEST(N,SX,INCX),STEMP(1),STEMP,SFAC)' >>$@.tmp
	@echo '             ELSE IF (ICASE.EQ.9) THEN' >>$@.tmp
	@echo ' *              .. DSCALTEST ..' >>$@.tmp
	@echo '                CALL DSCALTEST(N,SA((INCX-1)*5+NP1),SX,INCX)' >>$@.tmp
	@echo 'diff --git a/testing/c_sblat1.f b/testing/c_sblat1.f' >>$@.tmp
	@echo 'index de2b0380b..773787d6f 100644' >>$@.tmp
	@echo '--- a/testing/c_sblat1.f' >>$@.tmp
	@echo '+++ b/testing/c_sblat1.f' >>$@.tmp
	@echo '@@ -211,11 +211,11 @@ SUBROUTINE CHECK1(SFAC)' >>$@.tmp
	@echo '             IF (ICASE.EQ.7) THEN' >>$@.tmp
	@echo ' *              .. SNRM2TEST ..' >>$@.tmp
	@echo '                STEMP(1) = DTRUE1(NP1)' >>$@.tmp
	@echo '-               CALL STEST1(SNRM2TEST(N,SX,INCX),STEMP,STEMP,SFAC)' >>$@.tmp
	@echo '+               CALL STEST1(SNRM2TEST(N,SX,INCX),STEMP(1),STEMP,SFAC)' >>$@.tmp
	@echo '             ELSE IF (ICASE.EQ.8) THEN' >>$@.tmp
	@echo ' *              .. SASUMTEST ..' >>$@.tmp
	@echo '                STEMP(1) = DTRUE3(NP1)' >>$@.tmp
	@echo '-               CALL STEST1(SASUMTEST(N,SX,INCX),STEMP,STEMP,SFAC)' >>$@.tmp
	@echo '+               CALL STEST1(SASUMTEST(N,SX,INCX),STEMP(1),STEMP,SFAC)' >>$@.tmp
	@echo '             ELSE IF (ICASE.EQ.9) THEN' >>$@.tmp
	@echo ' *              .. SSCALTEST ..' >>$@.tmp
	@echo '                CALL SSCALTEST(N,SA((INCX-1)*5+NP1),SX,INCX)' >>$@.tmp
	@mv $@.tmp $@

$($(cblas)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(cblas)-prefix)/.pkgunpack $($(cblas)-srcdir)/0001-Making-FORTRAN-compilers-happy.patch
	cd $($(cblas)-srcdir) && \
		patch -f -p1 <0001-Making-FORTRAN-compilers-happy.patch
	@touch $@

ifneq ($($(cblas)-builddir),$($(cblas)-srcdir))
$($(cblas)-builddir)/.markerfile: $($(cblas)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cblas)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(cblas)-builddir)/.markerfile $($(cblas)-prefix)/.pkgpatch
	cd $($(cblas)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cblas)-builddeps) && \
		$(FC) -c -O3 -fPIC *.f && \
		$(CC) -c -O3 -DADD_ -fPIC -I../include *.c && \
		$(CC) -shared -o libcblas.so *.o
	@touch $@

$($(cblas)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(cblas)-builddir)/.markerfile $($(cblas)-prefix)/.pkgbuild
	cd $($(cblas)-srcdir)/testing && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cblas)-builddeps) && \
		$(FC) -c -O3 *.f && \
		$(CC) -c -O3 -DADD_ -I../include *.c && \
		$(CC) -o xscblat1 c_sblat1.o c_sblas1.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xdcblat1 c_dblat1.o c_dblas1.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xccblat1 c_cblat1.o c_cblas1.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xzcblat1 c_zblat1.o c_zblas1.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xscblat2 c_sblat2.o c_sblas2.o c_s2chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xdcblat2 c_dblat2.o c_dblas2.o c_d2chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xccblat2 c_cblat2.o c_cblas2.o c_c2chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran -lm && \
		$(CC) -o xzcblat2 c_zblat2.o c_zblas2.o c_z2chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran -lm && \
		$(CC) -o xscblat3 c_sblat3.o c_sblas3.o c_s3chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xdcblat3 c_dblat3.o c_dblas3.o c_d3chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xccblat3 c_cblat3.o c_cblas3.o c_c3chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
		$(CC) -o xzcblat3 c_zblat3.o c_zblas3.o c_z3chke.o auxiliary.o c_xerbla.o -Wl,-rpath=$($(cblas)-builddir) -L$($(cblas)-builddir) -lcblas -l$${BLASLIB} -lgfortran && \
	cd $($(cblas)-srcdir)/testing && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cblas)-builddeps) && \
		./xscblat1 > stest1.out && \
		./xdcblat1 > dtest1.out && \
		./xccblat1 > ctest1.out && \
		./xzcblat1 > ztest1.out && \
		./xscblat2 < sin2 > stest2.out && \
		./xdcblat2 < din2 > dtest2.out && \
		./xccblat2 < cin2 > ctest2.out && \
		./xzcblat2 < zin2 > ztest2.out && \
		./xscblat3 < sin3 > stest3.out && \
		./xdcblat3 < din3 > dtest3.out && \
		./xccblat3 < cin3 > ctest3.out && \
		./xzcblat3 < zin3 > ztest3.out
	@touch $@

$($(cblas)-builddir)/cblas.pc: $($(cblas)-builddir)/.markerfile
	@printf '' >$@.tmp
	@echo 'libdir=$($(cblas)-prefix)/lib' >>$@.tmp
	@echo 'includedir=$($(cblas)-prefix)/include' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Name: CBLAS' >>$@.tmp
	@echo 'Description: C interface to BLAS Basic Linear Algebra Subprograms' >>$@.tmp
	@echo 'Version: $(blas-version)' >>$@.tmp
	@echo 'URL: http://www.netlib.org/blas/' >>$@.tmp
	@echo 'Libs: -L$${libdir} -lcblas' >>$@.tmp
	@echo 'Cflags: -I$${includedir}' >>$@.tmp
	@echo 'Requires.private: blas' >>$@.tmp
	@mv $@.tmp $@

$($(cblas)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(cblas)-builddir)/.markerfile $($(cblas)-prefix)/.pkgcheck $($(cblas)-builddir)/cblas.pc
	$(INSTALL) -d $($(cblas)-prefix)/lib
	$(INSTALL) -m755 $($(cblas)-builddir)/libcblas.so $($(cblas)-prefix)/lib
	$(INSTALL) -d $($(cblas)-prefix)/lib/pkgconfig
	$(INSTALL) -m644 $($(cblas)-builddir)/cblas.pc $($(cblas)-prefix)/lib/pkgconfig
	$(INSTALL) -d $($(cblas)-prefix)/include
	$(INSTALL) -m644 $($(cblas)-srcdir)/include/cblas.h $($(cblas)-prefix)/include
	$(INSTALL) -m644 $($(cblas)-srcdir)/include/cblas_f77.h $($(cblas)-prefix)/include
	@touch $@

$($(cblas)-modulefile): $(modulefilesdir)/.markerfile $($(cblas)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cblas)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cblas)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cblas)-description)\"" >>$@
	echo "module-whatis \"$($(cblas)-url)\"" >>$@
	printf "$(foreach prereq,$($(cblas)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CBLAS_ROOT $($(cblas)-prefix)" >>$@
	echo "setenv CBLAS_INCDIR $($(cblas)-prefix)/include" >>$@
	echo "setenv CBLAS_INCLUDEDIR $($(cblas)-prefix)/include" >>$@
	echo "setenv CBLAS_LIBDIR $($(cblas)-prefix)/lib" >>$@
	echo "setenv CBLAS_LIBRARYDIR $($(cblas)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(cblas)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cblas)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cblas)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cblas)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cblas)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(lapack)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(cblas)\"" >>$@

$(cblas)-src: $($(cblas)-src)
$(cblas)-unpack: $($(cblas)-prefix)/.pkgunpack
$(cblas)-patch: $($(cblas)-prefix)/.pkgpatch
$(cblas)-build: $($(cblas)-prefix)/.pkgbuild
$(cblas)-check: $($(cblas)-prefix)/.pkgcheck
$(cblas)-install: $($(cblas)-prefix)/.pkginstall
$(cblas)-modulefile: $($(cblas)-modulefile)
$(cblas)-clean:
	rm -rf $($(cblas)-modulefile)
	rm -rf $($(cblas)-prefix)
	rm -rf $($(cblas)-srcdir)
	rm -rf $($(cblas)-src)
$(cblas): $(cblas)-src $(cblas)-unpack $(cblas)-patch $(cblas)-build $(cblas)-check $(cblas)-install $(cblas)-modulefile
