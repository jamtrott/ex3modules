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
# mumps-cuda-5.2.1

mumps-cuda-version = 5.2.1
mumps-cuda = mumps-cuda-$(mumps-cuda-version)
$(mumps-cuda)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps-cuda)-url = http://mumps.enseeiht.fr/
$(mumps-cuda)-srcurl = http://mumps.enseeiht.fr/MUMPS_$(mumps-cuda-version).tar.gz
$(mumps-cuda)-src = $($(mumps-src)-src)
$(mumps-cuda)-srcdir = $(pkgsrcdir)/$(mumps-cuda)
$(mumps-cuda)-builddeps = $(blas) $(openmpi-cuda) $(metis) $(parmetis-cuda) $(scotch-cuda) $(scalapack-cuda) $(libgfortran) $(patchelf)
$(mumps-cuda)-prereqs = $(blas) $(openmpi-cuda) $(metis) $(parmetis-cuda) $(scotch-cuda) $(scalapack-cuda) $(libgfortran)
$(mumps-cuda)-modulefile = $(modulefilesdir)/$(mumps-cuda)
$(mumps-cuda)-prefix = $(pkgdir)/$(mumps-cuda)

$($(mumps-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mumps-cuda)-prefix)/.pkgunpack: $$($(mumps-cuda)-src) $($(mumps-cuda)-srcdir)/.markerfile $($(mumps-cuda)-prefix)/.markerfile
	tar -C $($(mumps-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mumps-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-cuda)-prefix)/.pkgunpack
	@touch $@

$($(mumps-cuda)-srcdir)/Makefile.inc: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-cuda)-prefix)/.pkgunpack
	$(MODULESINIT) && \
	$(MODULE) use $(modulefilesdir) && \
	$(MODULE) load $($(mumps-cuda)-builddeps) && \
	printf '' >$@ && \
	echo '# Begin orderings' >>$@ && \
	echo "ISCOTCH=-I$${SCOTCH_INCDIR}" >>$@ && \
	echo "LSCOTCH=-L$${SCOTCH_LIBDIR} -lptesmumps -lptscotch -lscotch -lptscotcherr" >>$@ && \
	echo '' >>$@ && \
	echo 'LPORDDIR=$$(topdir)/PORD/lib/' >>$@ && \
	echo 'IPORD=-I$$(topdir)/PORD/include/ -isystem$$(topdir)/PORD/include' >>$@ && \
	echo 'LPORD=-L$$(LPORDDIR) -lpord' >>$@ && \
	echo '' >>$@ && \
	echo "IMETIS=-I$${PARMETIS_INCDIR} -I$${METIS_INCDIR}" >>$@ && \
	echo "LMETIS=-L$${PARMETIS_LIBDIR} -lparmetis -L$${METIS_LIBDIR} -lmetis" >>$@ && \
	echo '' >>$@ && \
	echo '# Corresponding variables reused later' >>$@ && \
	echo 'ORDERINGSF=-Dmetis -Dpord -Dparmetis -Dscotch -Dptscotch' >>$@ && \
	echo 'ORDERINGSC=$$(ORDERINGSF)' >>$@ && \
	echo '' >>$@ && \
	echo 'LORDERINGS=$$(LMETIS) $$(LPORD) $$(LSCOTCH)' >>$@ && \
	echo 'IORDERINGSF=$$(ISCOTCH)' >>$@ && \
	echo 'IORDERINGSC=$$(IMETIS) $$(IPORD) $$(ISCOTCH)' >>$@ && \
	echo '# End orderings' >>$@ && \
	echo '################################################################################' >>$@ && \
	echo '' >>$@ && \
	echo 'PLAT    =' >>$@ && \
	echo 'LIBEXT  = .so' >>$@ && \
	echo 'OUTC    = -o' >>$@ && \
	echo 'OUTF    = -o' >>$@ && \
	echo 'RM = /bin/rm -f' >>$@ && \
	echo 'CC = $${MPICC}' >>$@ && \
	echo 'FC = $${MPIFORT}' >>$@ && \
	echo 'FL = $${MPIFORT}' >>$@ && \
	echo 'AR = $$(CC) -shared -o ' >>$@ && \
	echo 'RANLIB = echo' >>$@ && \
	echo 'LAPACK = -L$${BLASDIR} -l$${BLASLIB}' >>$@ && \
	echo 'SCALAP  = -lscalapack' >>$@ && \
	echo '' >>$@ && \
	echo 'INCPAR = # not needed with mpif90/mpicc:  -I/usr/include/openmpi' >>$@ && \
	echo '' >>$@ && \
	echo 'LIBPAR = $$(SCALAP) $$(LAPACK) -L$${LIBGFORTRAN_LIBDIR} -lgfortran -lmpi_mpifh -lmpi # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi' >>$@ && \
	echo '' >>$@ && \
	echo 'INCSEQ = -I$$(topdir)/libseq' >>$@ && \
	echo 'LIBSEQ  = $$(LAPACK) -L$$(topdir)/libseq -lmpiseq -L$${LIBGFORTRAN_LIBDIR} -lgfortran' >>$@ && \
	echo '' >>$@ && \
	echo 'LIBBLAS = -L$${BLASDIR} -l$${BLASLIB}' >>$@ && \
	echo 'LIBOTHERS = -lpthread' >>$@ && \
	echo '' >>$@ && \
	echo '#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)' >>$@ && \
	echo 'CDEFS   = -DAdd_' >>$@ && \
	echo '' >>$@ && \
	echo '#Begin Optimized options' >>$@ && \
	echo 'OPTF    = -fPIC -O3' >>$@ && \
	echo 'OPTL    = -fPIC -O3' >>$@ && \
	echo 'OPTC    = -fPIC -O3' >>$@ && \
	echo '#End Optimized options' >>$@ && \
	echo '' >>$@ && \
	echo 'INCS = $$(INCPAR)' >>$@ && \
	echo 'LIBS = $$(LIBPAR)' >>$@ && \
	echo 'LIBSEQNEEDED =' >>$@

$($(mumps-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-cuda)-prefix)/.pkgpatch $($(mumps-cuda)-srcdir)/Makefile.inc
	cd $($(mumps-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps-cuda)-builddeps) && \
		$(MAKE) MAKEFLAGS='' alllib --jobs=1 # Parallel builds not supported
	@touch $@

$($(mumps-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-cuda)-prefix)/.pkgbuild
	@touch $@

$($(mumps-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps-cuda)-prefix)/.pkgcheck
	cd $($(mumps-cuda)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps-cuda)-builddeps) && \
		$(INSTALL) -d $($(mumps-cuda)-prefix)/include $($(mumps-cuda)-prefix)/lib $($(mumps-cuda)-prefix)/share/doc && \
		$(INSTALL) -m644 -t $($(mumps-cuda)-prefix)/include $($(mumps-cuda)-srcdir)/include/* && \
		$(INSTALL) -m755 -t $($(mumps-cuda)-prefix)/lib $($(mumps-cuda)-srcdir)/lib/* && \
		$(INSTALL) -m644 -t  $($(mumps-cuda)-prefix)/share/doc $($(mumps-cuda)-srcdir)/doc/* && \
		patchelf --add-needed libgfortran.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi_mpifh.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmpi.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed lib$${BLASLIB}.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscalapack.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libmetis.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libparmetis.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libscotch.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptscotch.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libesmumps.so $($(mumps-cuda)-prefix)/lib/lib*.so && \
		patchelf --add-needed libptesmumps.so $($(mumps-cuda)-prefix)/lib/lib*.so
	@touch $@

$($(mumps-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(mumps-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mumps-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mumps-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mumps-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(mumps-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(mumps-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MUMPS_ROOT $($(mumps-cuda)-prefix)" >>$@
	echo "setenv MUMPS_INCDIR $($(mumps-cuda)-prefix)/include" >>$@
	echo "setenv MUMPS_INCLUDEDIR $($(mumps-cuda)-prefix)/include" >>$@
	echo "setenv MUMPS_LIBDIR $($(mumps-cuda)-prefix)/lib" >>$@
	echo "setenv MUMPS_LIBRARYDIR $($(mumps-cuda)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mumps-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mumps-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mumps-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mumps-cuda)-prefix)/lib" >>$@
	echo "set MSG \"$(mumps-cuda)\"" >>$@

$(mumps-cuda)-src: $($(mumps-cuda)-src)
$(mumps-cuda)-unpack: $($(mumps-cuda)-prefix)/.pkgunpack
$(mumps-cuda)-patch: $($(mumps-cuda)-prefix)/.pkgpatch
$(mumps-cuda)-build: $($(mumps-cuda)-prefix)/.pkgbuild
$(mumps-cuda)-check: $($(mumps-cuda)-prefix)/.pkgcheck
$(mumps-cuda)-install: $($(mumps-cuda)-prefix)/.pkginstall
$(mumps-cuda)-modulefile: $($(mumps-cuda)-modulefile)
$(mumps-cuda)-clean:
	rm -rf $($(mumps-cuda)-modulefile)
	rm -rf $($(mumps-cuda)-prefix)
	rm -rf $($(mumps-cuda)-srcdir)
	rm -rf $($(mumps-cuda)-src)
$(mumps-cuda): $(mumps-cuda)-src $(mumps-cuda)-unpack $(mumps-cuda)-patch $(mumps-cuda)-build $(mumps-cuda)-check $(mumps-cuda)-install $(mumps-cuda)-modulefile