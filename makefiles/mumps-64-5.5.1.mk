# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# mumps-64-5.5.1

mumps-64-5.5.1-version = 5.5.1
mumps-64-5.5.1 = mumps-64-$(mumps-64-5.5.1-version)
$(mumps-64-5.5.1)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps-64-5.5.1)-url = http://mumps.enseeiht.fr/
#$(mumps-64-5.5.1)-srcurl = http://mumps.enseeiht.fr/MUMPS_$(mumps-64-5.5.1-version).tar.gz
$(mumps-64-5.5.1)-srcurl = http://deb.debian.org/debian/pool/main/m/mumps/mumps_$(mumps-64-5.5.1-version).orig.tar.gz
$(mumps-64-5.5.1)-src = $($(mumps-src-5.5.1)-src)
$(mumps-64-5.5.1)-srcdir = $(pkgsrcdir)/$(mumps-64-5.5.1)
$(mumps-64-5.5.1)-builddeps = $(blas) $(mpi) $(metis-64) $(parmetis-64) $(scotch-64) $(scalapack) $(gfortran) $(patchelf)
$(mumps-64-5.5.1)-prereqs = $(blas) $(mpi) $(metis-64) $(parmetis-64) $(scotch-64) $(scalapack) $(gfortran)
$(mumps-64-5.5.1)-modulefile = $(modulefilesdir)/$(mumps-64-5.5.1)
$(mumps-64-5.5.1)-prefix = $(pkgdir)/$(mumps-64-5.5.1)

$($(mumps-64-5.5.1)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps-64-5.5.1)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps-64-5.5.1)-prefix)/.pkgunpack: $$($(mumps-64-5.5.1)-src) $($(mumps-64-5.5.1)-srcdir)/.markerfile $($(mumps-64-5.5.1)-prefix)/.markerfile $$(foreach dep,$$($(mumps-64-5.5.1)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mumps-64-5.5.1)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mumps-64-5.5.1)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-64-5.5.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-64-5.5.1)-prefix)/.pkgunpack
	@touch $@

$($(mumps-64-5.5.1)-srcdir)/Makefile.inc: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-64-5.5.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-64-5.5.1)-prefix)/.pkgunpack
	$(MODULESINIT) && \
	$(MODULE) use $(modulefilesdir) && \
	$(MODULE) load $($(mumps-64-5.5.1)-builddeps) && \
	printf '' >$@.tmp && \
	echo '# Begin orderings' >>$@.tmp && \
	echo "ISCOTCH=-I$${SCOTCH_INCDIR}" >>$@.tmp && \
	echo "LSCOTCH=-L$${SCOTCH_LIBDIR} -lptesmumps -lptscotch -lscotch -lptscotcherr" >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'LPORDDIR=$$(topdir)/PORD/lib/' >>$@.tmp && \
	echo 'IPORD=-I$$(topdir)/PORD/include/ -isystem$$(topdir)/PORD/include' >>$@.tmp && \
	echo 'LPORD=-L$$(LPORDDIR) -lpord' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo "IMETIS=-I$${PARMETIS_INCDIR} -I$${METIS_INCDIR}" >>$@.tmp && \
	echo "LMETIS=-L$${PARMETIS_LIBDIR} -lparmetis -L$${METIS_LIBDIR} -lmetis" >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo '# Corresponding variables reused later' >>$@.tmp && \
	echo 'ORDERINGSF=-Dmetis -Dpord -Dparmetis -Dscotch -Dptscotch' >>$@.tmp && \
	echo 'ORDERINGSC=$$(ORDERINGSF)' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'LORDERINGS=$$(LMETIS) $$(LPORD) $$(LSCOTCH)' >>$@.tmp && \
	echo 'IORDERINGSF=$$(ISCOTCH)' >>$@.tmp && \
	echo 'IORDERINGSC=$$(IMETIS) $$(IPORD) $$(ISCOTCH)' >>$@.tmp && \
	echo '# End orderings' >>$@.tmp && \
	echo '################################################################################' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'PLAT    =' >>$@.tmp && \
	echo 'LIBEXT  = .so' >>$@.tmp && \
	echo 'OUTC    = -o' >>$@.tmp && \
	echo 'OUTF    = -o' >>$@.tmp && \
	echo 'RM = /bin/rm -f' >>$@.tmp && \
	echo 'CC = $${MPICC}' >>$@.tmp && \
	echo 'FC = $${MPIFORT}' >>$@.tmp && \
	echo 'FL = $${MPIFORT}' >>$@.tmp && \
	echo 'AR = $$(CC) -shared -o ' >>$@.tmp && \
	echo 'RANLIB = echo' >>$@.tmp && \
	echo 'LAPACK = -L$${BLASDIR} -l$${BLASLIB}' >>$@.tmp && \
	echo 'SCALAP  = -lscalapack' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'INCPAR = # not needed with mpif90/mpicc:  -I/usr/include/openmpi' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'LIBPAR = $$(SCALAP) $$(LAPACK) -L$${GFORTRAN_LIBDIR} -lgfortran -lmpi_mpifh -lmpi # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'INCSEQ = -I$$(topdir)/libseq' >>$@.tmp && \
	echo 'LIBSEQ  = $$(LAPACK) -L$$(topdir)/libseq -lmpiseq -L$${GFORTRAN_LIBDIR} -lgfortran' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'LIBBLAS = -L$${BLASDIR} -l$${BLASLIB}' >>$@.tmp && \
	echo 'LIBOTHERS = -lpthread' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo '#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)' >>$@.tmp && \
	echo 'CDEFS   = -DAdd_' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo '#Begin Optimized options' >>$@.tmp && \
	(if [[ $$($${MPIFORT} --version | head -n 1 | awk '{ print $$4 }' | cut -d. -f1) -gt 9 ]]; then echo 'OPTF    = -fPIC -O3 -fallow-argument-mismatch' >>$@.tmp; else echo 'OPTF    = -fPIC -O3' >>$@.tmp; fi) && \
	echo 'OPTL    = -fPIC -O3' >>$@.tmp && \
	echo 'OPTC    = -fPIC -O3' >>$@.tmp && \
	echo '#End Optimized options' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'INCS = $$(INCPAR)' >>$@.tmp && \
	echo 'LIBS = $$(LIBPAR)' >>$@.tmp && \
	echo 'LIBSEQNEEDED =' >>$@.tmp
	mv $@.tmp $@

$($(mumps-64-5.5.1)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-64-5.5.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-64-5.5.1)-prefix)/.pkgpatch $($(mumps-64-5.5.1)-srcdir)/Makefile.inc
	cd $($(mumps-64-5.5.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps-64-5.5.1)-builddeps) && \
		$(MAKE) MAKEFLAGS='' all
	@touch $@

$($(mumps-64-5.5.1)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-64-5.5.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-64-5.5.1)-prefix)/.pkgbuild
	@touch $@

$($(mumps-64-5.5.1)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-64-5.5.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-64-5.5.1)-prefix)/.pkgcheck
	cd $($(mumps-64-5.5.1)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps-64-5.5.1)-builddeps) && \
		$(INSTALL) -d $($(mumps-64-5.5.1)-prefix)/include $($(mumps-64-5.5.1)-prefix)/lib $($(mumps-64-5.5.1)-prefix)/share/doc && \
		$(INSTALL) -m644 -t $($(mumps-64-5.5.1)-prefix)/include $($(mumps-64-5.5.1)-srcdir)/include/* && \
		$(INSTALL) -m755 -t $($(mumps-64-5.5.1)-prefix)/lib $($(mumps-64-5.5.1)-srcdir)/lib/* && \
		$(INSTALL) -m644 -t  $($(mumps-64-5.5.1)-prefix)/share/doc $($(mumps-64-5.5.1)-srcdir)/doc/* && \
		patchelf --add-needed libmpi_mpifh.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed lib$${BLASLIB}.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscalapack.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmetis.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libparmetis.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscotch.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptscotch.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libesmumps.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptesmumps.so $($(mumps-64-5.5.1)-prefix)/lib/lib*.so
	@touch $@

$($(mumps-64-5.5.1)-modulefile): $(modulefilesdir)/.markerfile $($(mumps-64-5.5.1)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mumps-64-5.5.1)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mumps-64-5.5.1)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mumps-64-5.5.1)-description)\"" >>$@
	echo "module-whatis \"$($(mumps-64-5.5.1)-url)\"" >>$@
	printf "$(foreach prereq,$($(mumps-64-5.5.1)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MUMPS_ROOT $($(mumps-64-5.5.1)-prefix)" >>$@
	echo "setenv MUMPS_INCDIR $($(mumps-64-5.5.1)-prefix)/include" >>$@
	echo "setenv MUMPS_INCLUDEDIR $($(mumps-64-5.5.1)-prefix)/include" >>$@
	echo "setenv MUMPS_LIBDIR $($(mumps-64-5.5.1)-prefix)/lib" >>$@
	echo "setenv MUMPS_LIBRARYDIR $($(mumps-64-5.5.1)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mumps-64-5.5.1)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mumps-64-5.5.1)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mumps-64-5.5.1)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mumps-64-5.5.1)-prefix)/lib" >>$@
	echo "set MSG \"$(mumps-64-5.5.1)\"" >>$@

$(mumps-64-5.5.1)-src: $$($(mumps-64-5.5.1)-src)
$(mumps-64-5.5.1)-unpack: $($(mumps-64-5.5.1)-prefix)/.pkgunpack
$(mumps-64-5.5.1)-patch: $($(mumps-64-5.5.1)-prefix)/.pkgpatch
$(mumps-64-5.5.1)-build: $($(mumps-64-5.5.1)-prefix)/.pkgbuild
$(mumps-64-5.5.1)-check: $($(mumps-64-5.5.1)-prefix)/.pkgcheck
$(mumps-64-5.5.1)-install: $($(mumps-64-5.5.1)-prefix)/.pkginstall
$(mumps-64-5.5.1)-modulefile: $($(mumps-64-5.5.1)-modulefile)
$(mumps-64-5.5.1)-clean:
	rm -rf $($(mumps-64-5.5.1)-modulefile)
	rm -rf $($(mumps-64-5.5.1)-prefix)
	rm -rf $($(mumps-64-5.5.1)-srcdir)
	rm -rf $($(mumps-64-5.5.1)-src)
$(mumps-64-5.5.1): $(mumps-64-5.5.1)-src $(mumps-64-5.5.1)-unpack $(mumps-64-5.5.1)-patch $(mumps-64-5.5.1)-build $(mumps-64-5.5.1)-check $(mumps-64-5.5.1)-install $(mumps-64-5.5.1)-modulefile
