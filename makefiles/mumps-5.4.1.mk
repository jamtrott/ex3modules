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
# mumps-5.4.1

mumps-version = 5.4.1
mumps = mumps-$(mumps-version)
$(mumps)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps)-url = http://mumps.enseeiht.fr/
$(mumps)-srcurl = http://mumps.enseeiht.fr/MUMPS_$(mumps-version).tar.gz
$(mumps)-src = $($(mumps-src)-src)
$(mumps)-srcdir = $(pkgsrcdir)/$(mumps)
$(mumps)-builddeps = $(blas) $(mpi) $(metis) $(parmetis) $(scotch) $(scalapack) $(gfortran) $(patchelf)
$(mumps)-prereqs = $(blas) $(mpi) $(metis) $(parmetis) $(scotch) $(scalapack)
$(mumps)-modulefile = $(modulefilesdir)/$(mumps)
$(mumps)-prefix = $(pkgdir)/$(mumps)

$($(mumps)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps)-prefix)/.pkgunpack: $$($(mumps)-src) $($(mumps)-srcdir)/.markerfile $($(mumps)-prefix)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mumps)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mumps)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgunpack
	@touch $@

$($(mumps)-srcdir)/Makefile.inc: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgunpack
	$(MODULESINIT) && \
	$(MODULE) use $(modulefilesdir) && \
	$(MODULE) load $($(mumps)-builddeps) && \
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

$($(mumps)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgpatch $($(mumps)-srcdir)/Makefile.inc
	cd $($(mumps)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps)-builddeps) && \
		$(MAKE) MAKEFLAGS='' all
	@touch $@

$($(mumps)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgbuild
	@touch $@

$($(mumps)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgcheck
	cd $($(mumps)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps)-builddeps) && \
		$(INSTALL) -d $($(mumps)-prefix)/include $($(mumps)-prefix)/lib $($(mumps)-prefix)/share/doc && \
		$(INSTALL) -m644 -t $($(mumps)-prefix)/include $($(mumps)-srcdir)/include/* && \
		$(INSTALL) -m755 -t $($(mumps)-prefix)/lib $($(mumps)-srcdir)/lib/* && \
		$(INSTALL) -m644 -t  $($(mumps)-prefix)/share/doc $($(mumps)-srcdir)/doc/* && \
		patchelf --add-needed libgfortran.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi_mpifh.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed lib$${BLASLIB}.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscalapack.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmetis.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libparmetis.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscotch.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptscotch.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libesmumps.so $($(mumps)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptesmumps.so $($(mumps)-prefix)/lib/lib*.so
	@touch $@

$($(mumps)-modulefile): $(modulefilesdir)/.markerfile $($(mumps)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mumps)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mumps)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mumps)-description)\"" >>$@
	echo "module-whatis \"$($(mumps)-url)\"" >>$@
	printf "$(foreach prereq,$($(mumps)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MUMPS_ROOT $($(mumps)-prefix)" >>$@
	echo "setenv MUMPS_INCDIR $($(mumps)-prefix)/include" >>$@
	echo "setenv MUMPS_INCLUDEDIR $($(mumps)-prefix)/include" >>$@
	echo "setenv MUMPS_LIBDIR $($(mumps)-prefix)/lib" >>$@
	echo "setenv MUMPS_LIBRARYDIR $($(mumps)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mumps)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mumps)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mumps)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mumps)-prefix)/lib" >>$@
	echo "set MSG \"$(mumps)\"" >>$@

$(mumps)-src: $($(mumps)-src)
$(mumps)-unpack: $($(mumps)-prefix)/.pkgunpack
$(mumps)-patch: $($(mumps)-prefix)/.pkgpatch
$(mumps)-build: $($(mumps)-prefix)/.pkgbuild
$(mumps)-check: $($(mumps)-prefix)/.pkgcheck
$(mumps)-install: $($(mumps)-prefix)/.pkginstall
$(mumps)-modulefile: $($(mumps)-modulefile)
$(mumps)-clean:
	rm -rf $($(mumps)-modulefile)
	rm -rf $($(mumps)-prefix)
	rm -rf $($(mumps)-srcdir)
	rm -rf $($(mumps)-src)
$(mumps): $(mumps)-src $(mumps)-unpack $(mumps)-patch $(mumps)-build $(mumps)-check $(mumps)-install $(mumps)-modulefile
