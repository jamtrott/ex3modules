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
# mumps-32-5.4.1

mumps-32-version = 5.4.1
mumps-32 = mumps-32-$(mumps-32-version)
$(mumps-32)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps-32)-url = http://mumps.enseeiht.fr/
$(mumps-32)-srcurl = $($(mumps-src)-srcurl)
$(mumps-32)-src = $($(mumps-src)-src)
$(mumps-32)-srcdir = $(pkgsrcdir)/$(mumps-32)
$(mumps-32)-builddeps = $(blas) $(mpi) $(metis-32) $(parmetis-32) $(scotch) $(scalapack) $(gfortran) $(patchelf)
$(mumps-32)-prereqs = $(blas) $(mpi) $(metis-32) $(parmetis-32) $(scotch) $(scalapack)
$(mumps-32)-modulefile = $(modulefilesdir)/$(mumps-32)
$(mumps-32)-prefix = $(pkgdir)/$(mumps-32)

$($(mumps-32)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps-32)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps-32)-prefix)/.pkgunpack: $$($(mumps-32)-src) $($(mumps-32)-srcdir)/.markerfile $($(mumps-32)-prefix)/.markerfile $$(foreach dep,$$($(mumps-32)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mumps-32)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mumps-32)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-32)-prefix)/.pkgunpack
	@touch $@

$($(mumps-32)-srcdir)/Makefile.inc: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-32)-prefix)/.pkgunpack
	$(MODULESINIT) && \
	$(MODULE) use $(modulefilesdir) && \
	$(MODULE) load $($(mumps-32)-builddeps) && \
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
	echo 'LIBPAR = $$(SCALAP) $$(LAPACK) -L$${LIBGFORTRAN_LIBDIR} -lgfortran -lmpi_mpifh -lmpi # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi' >>$@.tmp && \
	echo '' >>$@.tmp && \
	echo 'INCSEQ = -I$$(topdir)/libseq' >>$@.tmp && \
	echo 'LIBSEQ  = $$(LAPACK) -L$$(topdir)/libseq -lmpiseq -L$${LIBGFORTRAN_LIBDIR} -lgfortran' >>$@.tmp && \
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

$($(mumps-32)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-32)-prefix)/.pkgpatch $($(mumps-32)-srcdir)/Makefile.inc
	cd $($(mumps-32)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps-32)-builddeps) && \
		$(MAKE) MAKEFLAGS='' all
	@touch $@

$($(mumps-32)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-32)-prefix)/.pkgbuild
	@touch $@

$($(mumps-32)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-32)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-32)-prefix)/.pkgcheck
	cd $($(mumps-32)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps-32)-builddeps) && \
		$(INSTALL) -d $($(mumps-32)-prefix)/include $($(mumps-32)-prefix)/lib $($(mumps-32)-prefix)/share/doc && \
		$(INSTALL) -m644 -t $($(mumps-32)-prefix)/include $($(mumps-32)-srcdir)/include/* && \
		$(INSTALL) -m755 -t $($(mumps-32)-prefix)/lib $($(mumps-32)-srcdir)/lib/* && \
		$(INSTALL) -m644 -t  $($(mumps-32)-prefix)/share/doc $($(mumps-32)-srcdir)/doc/* && \
		patchelf --add-needed libgfortran.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi_mpifh.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed lib$${BLASLIB}.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscalapack.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmetis.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libparmetis.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscotch.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptscotch.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libesmumps.so $($(mumps-32)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptesmumps.so $($(mumps-32)-prefix)/lib/lib*.so
	@touch $@

$($(mumps-32)-modulefile): $(modulefilesdir)/.markerfile $($(mumps-32)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mumps-32)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mumps-32)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mumps-32)-description)\"" >>$@
	echo "module-whatis \"$($(mumps-32)-url)\"" >>$@
	printf "$(foreach prereq,$($(mumps-32)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MUMPS_ROOT $($(mumps-32)-prefix)" >>$@
	echo "setenv MUMPS_INCDIR $($(mumps-32)-prefix)/include" >>$@
	echo "setenv MUMPS_INCLUDEDIR $($(mumps-32)-prefix)/include" >>$@
	echo "setenv MUMPS_LIBDIR $($(mumps-32)-prefix)/lib" >>$@
	echo "setenv MUMPS_LIBRARYDIR $($(mumps-32)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mumps-32)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mumps-32)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mumps-32)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mumps-32)-prefix)/lib" >>$@
	echo "set MSG \"$(mumps-32)\"" >>$@

$(mumps-32)-src: $$($(mumps-32)-src)
$(mumps-32)-unpack: $($(mumps-32)-prefix)/.pkgunpack
$(mumps-32)-patch: $($(mumps-32)-prefix)/.pkgpatch
$(mumps-32)-build: $($(mumps-32)-prefix)/.pkgbuild
$(mumps-32)-check: $($(mumps-32)-prefix)/.pkgcheck
$(mumps-32)-install: $($(mumps-32)-prefix)/.pkginstall
$(mumps-32)-modulefile: $($(mumps-32)-modulefile)
$(mumps-32)-clean:
	rm -rf $($(mumps-32)-modulefile)
	rm -rf $($(mumps-32)-prefix)
	rm -rf $($(mumps-32)-srcdir)
	rm -rf $($(mumps-32)-src)
$(mumps-32): $(mumps-32)-src $(mumps-32)-unpack $(mumps-32)-patch $(mumps-32)-build $(mumps-32)-check $(mumps-32)-install $(mumps-32)-modulefile
