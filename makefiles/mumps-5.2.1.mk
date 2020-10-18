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
# mumps-5.2.1

mumps-version = 5.2.1
mumps = mumps-$(mumps-version)
$(mumps)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps)-url = http://mumps.enseeiht.fr/
$(mumps)-srcurl = http://mumps.enseeiht.fr/MUMPS_$(mumps-version).tar.gz
$(mumps)-src = $(pkgsrcdir)/$(notdir $($(mumps)-srcurl))
$(mumps)-srcdir = $(pkgsrcdir)/$(mumps)
$(mumps)-builddeps = $(blas) $(mpi) $(metis) $(parmetis) $(scotch) $(scalapack)
$(mumps)-prereqs = $(blas) $(mpi) $(metis) $(parmetis) $(scotch) $(scalapack)
$(mumps)-modulefile = $(modulefilesdir)/$(mumps)
$(mumps)-prefix = $(pkgdir)/$(mumps)

$($(mumps)-src): $(dir $($(mumps)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mumps)-srcurl)

$($(mumps)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(mumps)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(mumps)-prefix)/.pkgunpack: $($(mumps)-src) $($(mumps)-srcdir)/.markerfile $($(mumps)-prefix)/.markerfile
	tar -C $($(mumps)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mumps)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgunpack
	@touch $@

$($(mumps)-srcdir)/Makefile.inc: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgunpack
	$(MODULESINIT) && \
	$(MODULE) use $(modulefilesdir) && \
	$(MODULE) load $($(mumps)-builddeps) && \
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
	echo 'LAPACK = -l$${BLASLIB}' >>$@ && \
	echo 'SCALAP  = -lscalapack' >>$@ && \
	echo '' >>$@ && \
	echo 'INCPAR = # not needed with mpif90/mpicc:  -I/usr/include/openmpi' >>$@ && \
	echo '' >>$@ && \
	echo 'LIBPAR = $$(SCALAP) $$(LAPACK) # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi' >>$@ && \
	echo '' >>$@ && \
	echo 'INCSEQ = -I$$(topdir)/libseq' >>$@ && \
	echo 'LIBSEQ  = $$(LAPACK) -L$$(topdir)/libseq -lmpiseq' >>$@ && \
	echo '' >>$@ && \
	echo 'LIBBLAS = -l$${BLASLIB}' >>$@ && \
	echo 'LIBOTHERS = -lpthread' >>$@ && \
	echo '' >>$@ && \
	echo '#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)' >>$@ && \
	echo 'CDEFS   = -DAdd_' >>$@ && \
	echo '' >>$@ && \
	echo '#Begin Optimized options' >>$@ && \
	echo 'OPTF    = -fPIC -O3 -fopenmp -fallow-argument-mismatch' >>$@ && \
	echo 'OPTL    = -fPIC -O3 -fopenmp' >>$@ && \
	echo 'OPTC    = -fPIC -O3 -fopenmp' >>$@ && \
	echo '#End Optimized options' >>$@ && \
	echo '' >>$@ && \
	echo 'INCS = $$(INCPAR)' >>$@ && \
	echo 'LIBS = $$(LIBPAR)' >>$@ && \
	echo 'LIBSEQNEEDED =' >>$@

$($(mumps)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgpatch $($(mumps)-srcdir)/Makefile.inc
	cd $($(mumps)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mumps)-builddeps) && \
		$(MAKE) MAKEFLAGS= alllib --jobs=1 # Parallel builds not supported
	@touch $@

$($(mumps)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgbuild
	@touch $@

$($(mumps)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mumps)-builddeps),$(modulefilesdir)/$$(dep)) $($(mumps)-prefix)/.pkgcheck
	$(INSTALL) -m=6755 -d $($(mumps)-prefix)/include $($(mumps)-prefix)/lib $($(mumps)-prefix)/share/doc
	$(INSTALL) -m644 -t $($(mumps)-prefix)/include $($(mumps)-srcdir)/include/*
	$(INSTALL) -m755 -t $($(mumps)-prefix)/lib $($(mumps)-srcdir)/lib/*
	$(INSTALL) -m644 -t  $($(mumps)-prefix)/share/doc $($(mumps)-srcdir)/doc/*
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
