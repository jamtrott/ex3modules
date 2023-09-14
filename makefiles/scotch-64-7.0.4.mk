# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# scotch-64-7.0.4

scotch-64-7.0.4-version = 7.0.4
scotch-64-7.0.4 = scotch-64-$(scotch-64-7.0.4-version)
$(scotch-64-7.0.4)-description = Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package
$(scotch-64-7.0.4)-url = https://www.labri.fr/perso/pelegrin/scotch/
$(scotch-64-7.0.4)-srcurl = https://gitlab.inria.fr/scotch/scotch/-/archive/v$(scotch-64-7.0.4-version)/scotch-v$(scotch-64-7.0.4-version).tar.gz
$(scotch-64-7.0.4)-src = $($(scotch-src-7.0.4)-src)
$(scotch-64-7.0.4)-srcdir = $(pkgsrcdir)/$(scotch-64-7.0.4)
$(scotch-64-7.0.4)-builddeps = $(mpi) $(patchelf)
$(scotch-64-7.0.4)-prereqs = $(mpi)
$(scotch-64-7.0.4)-modulefile = $(modulefilesdir)/$(scotch-64-7.0.4)
$(scotch-64-7.0.4)-prefix = $(pkgdir)/$(scotch-64-7.0.4)

$($(scotch-64-7.0.4)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(scotch-64-7.0.4)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scotch-64-7.0.4)-prefix)/.pkgunpack: $$($(scotch-64-7.0.4)-src) $($(scotch-64-7.0.4)-srcdir)/.markerfile $($(scotch-64-7.0.4)-prefix)/.markerfile $$(foreach dep,$$($(scotch-64-7.0.4)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(scotch-64-7.0.4)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(scotch-64-7.0.4)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-64-7.0.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-64-7.0.4)-prefix)/.pkgunpack
# Modify source to allow correct shared library linking
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch-64-7.0.4)-srcdir)/src/libscotchmetis/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch-64-7.0.4)-srcdir)/src/libscotchmetis/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch-64-7.0.4)-srcdir)/src/libscotch/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch-64-7.0.4)-srcdir)/src/libscotch/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch-64-7.0.4)-srcdir)/src/esmumps/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch-64-7.0.4)-srcdir)/src/esmumps/Makefile
	@touch $@

$($(scotch-64-7.0.4)-srcdir)/src/Makefile.inc: $($(scotch-64-7.0.4)-prefix)/.pkgunpack
	printf "" >$@.tmp
	echo "EXE             =" >>$@.tmp
	echo "LIB             = .so" >>$@.tmp
	echo "OBJ             = .o" >>$@.tmp
	echo "MAKE            = make" >>$@.tmp
	echo "AR              = gcc" >>$@.tmp
	echo "ARFLAGS         = -shared -o" >>$@.tmp
	echo "CAT             = cat" >>$@.tmp
	echo "CCS             = gcc" >>$@.tmp
	echo "CCP             = mpicc" >>$@.tmp
	echo "CCD             = gcc" >>$@.tmp
	echo "CFLAGS          = -g -O3 -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_PTHREAD -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DSCOTCH_PTHREAD -Drestrict=__restrict -DIDXSIZE64 -DINTSIZE64" >>$@.tmp
	echo "CLIBFLAGS       = -shared -fPIC" >>$@.tmp
	echo "LDFLAGS         = -lz -lm -lrt -pthread" >>$@.tmp
	echo "DYNLDFLAGS      = -lz -lm -lrt -pthread" >>$@.tmp
	echo "CP              = cp" >>$@.tmp
	echo "LEX             = flex -Pscotchyy -olex.yy.c" >>$@.tmp
	echo "LN              = ln" >>$@.tmp
	echo "MKDIR           = mkdir -p" >>$@.tmp
	echo "MV              = mv" >>$@.tmp
	echo "RANLIB          = echo" >>$@.tmp
	echo "YACC            = bison -pscotchyy -y -b y" >>$@.tmp
	mv $@.tmp $@

$($(scotch-64-7.0.4)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-64-7.0.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-64-7.0.4)-prefix)/.pkgpatch $($(scotch-64-7.0.4)-srcdir)/src/Makefile.inc
# Parallel builds are not supported
	cd $($(scotch-64-7.0.4)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scotch-64-7.0.4)-builddeps) && \
		$(MAKE) MAKEFLAGS="AR=$${CC:-gcc} CCS=$${CC:-gcc} CCP=$${MPICC:-mpicc} CCD=$${CC:-gcc}" \
			scotch ptscotch esmumps ptesmumps --jobs=1
	@touch $@

$($(scotch-64-7.0.4)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-64-7.0.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-64-7.0.4)-prefix)/.pkgbuild
	@touch $@

$($(scotch-64-7.0.4)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-64-7.0.4)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-64-7.0.4)-prefix)/.pkgcheck
	cd $($(scotch-64-7.0.4)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scotch-64-7.0.4)-builddeps) && \
		$(MAKE) install prefix=$($(scotch-64-7.0.4)-prefix) \
			MAKEFLAGS="AR=$${CC} CCS=$${CC} CCP=$${MPICC} CCD=$${CC}" && \
		patchelf --add-needed libz.so $($(scotch-64-7.0.4)-prefix)/lib/*.so && \
		patchelf --add-needed libscotcherr.so $($(scotch-64-7.0.4)-prefix)/lib/libscotch.so && \
		patchelf --add-needed libscotch.so $($(scotch-64-7.0.4)-prefix)/lib/libptscotch.so && \
		patchelf --add-needed libptscotch.so $($(scotch-64-7.0.4)-prefix)/lib/libptscotchparmetis.so && \
		patchelf --add-needed libscotch.so $($(scotch-64-7.0.4)-prefix)/lib/libscotchmetis.so
	@touch $@

$($(scotch-64-7.0.4)-modulefile): $(modulefilesdir)/.markerfile $($(scotch-64-7.0.4)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(scotch-64-7.0.4)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(scotch-64-7.0.4)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(scotch-64-7.0.4)-description)\"" >>$@
	echo "module-whatis \"$($(scotch-64-7.0.4)-url)\"" >>$@
	printf "$(foreach prereq,$($(scotch-64-7.0.4)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SCOTCH_ROOT $($(scotch-64-7.0.4)-prefix)" >>$@
	echo "setenv SCOTCH_INCDIR $($(scotch-64-7.0.4)-prefix)/include" >>$@
	echo "setenv SCOTCH_INCLUDEDIR $($(scotch-64-7.0.4)-prefix)/include" >>$@
	echo "setenv SCOTCH_LIBDIR $($(scotch-64-7.0.4)-prefix)/lib" >>$@
	echo "setenv SCOTCH_LIBRARYDIR $($(scotch-64-7.0.4)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(scotch-64-7.0.4)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(scotch-64-7.0.4)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(scotch-64-7.0.4)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(scotch-64-7.0.4)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(scotch-64-7.0.4)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(scotch-64-7.0.4)-prefix)/share/man" >>$@
	echo "set MSG \"$(scotch-64-7.0.4)\"" >>$@

$(scotch-64-7.0.4)-src: $($(scotch-64-7.0.4)-src)
$(scotch-64-7.0.4)-unpack: $($(scotch-64-7.0.4)-prefix)/.pkgunpack
$(scotch-64-7.0.4)-patch: $($(scotch-64-7.0.4)-prefix)/.pkgpatch
$(scotch-64-7.0.4)-build: $($(scotch-64-7.0.4)-prefix)/.pkgbuild
$(scotch-64-7.0.4)-check: $($(scotch-64-7.0.4)-prefix)/.pkgcheck
$(scotch-64-7.0.4)-install: $($(scotch-64-7.0.4)-prefix)/.pkginstall
$(scotch-64-7.0.4)-modulefile: $($(scotch-64-7.0.4)-modulefile)
$(scotch-64-7.0.4)-clean:
	rm -rf $($(scotch-64-7.0.4)-modulefile)
	rm -rf $($(scotch-64-7.0.4)-prefix)
	rm -rf $($(scotch-64-7.0.4)-srcdir)
	rm -rf $($(scotch-64-7.0.4)-src)
$(scotch-64-7.0.4): $(scotch-64-7.0.4)-src $(scotch-64-7.0.4)-unpack $(scotch-64-7.0.4)-patch $(scotch-64-7.0.4)-build $(scotch-64-7.0.4)-check $(scotch-64-7.0.4)-install $(scotch-64-7.0.4)-modulefile
