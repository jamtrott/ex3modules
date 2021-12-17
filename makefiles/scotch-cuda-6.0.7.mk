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
# scotch-cuda-6.0.7

scotch-cuda-version = 6.0.7
scotch-cuda = scotch-cuda-$(scotch-cuda-version)
$(scotch-cuda)-description = Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package
$(scotch-cuda)-url = https://www.labri.fr/perso/pelegrin/scotch/
$(scotch-cuda)-srcurl = https://gforge.inria.fr/frs/download.php/file/38040/scotch_$(scotch-cuda-version).tar.gz
$(scotch-cuda)-builddeps = $(openmpi-cuda) $(patchelf)
$(scotch-cuda)-prereqs = $(openmpi-cuda)
$(scotch-cuda)-src = $($(scotch-src)-src)
$(scotch-cuda)-srcdir = $(pkgsrcdir)/$(scotch-cuda)
$(scotch-cuda)-modulefile = $(modulefilesdir)/$(scotch-cuda)
$(scotch-cuda)-prefix = $(pkgdir)/$(scotch-cuda)

$($(scotch-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(scotch-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scotch-cuda)-prefix)/.pkgunpack: $$($(scotch-cuda)-src) $($(scotch-cuda)-srcdir)/.markerfile $($(scotch-cuda)-prefix)/.markerfile $$(foreach dep,$$($(scotch-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(scotch-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(scotch-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-cuda)-prefix)/.pkgunpack
# Modify source to allow correct shared library linking
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch-cuda)-srcdir)/src/libscotchmetis/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch-cuda)-srcdir)/src/libscotchmetis/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch-cuda)-srcdir)/src/libscotch/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch-cuda)-srcdir)/src/libscotch/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch-cuda)-srcdir)/src/esmumps/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch-cuda)-srcdir)/src/esmumps/Makefile
	@touch $@

$($(scotch-cuda)-srcdir)/src/Makefile.inc: $($(scotch-cuda)-prefix)/.pkgunpack
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
	echo "CFLAGS          = -O3 -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_PTHREAD -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DSCOTCH_PTHREAD -Drestrict=__restrict -DIDXSIZE64" >>$@.tmp
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

$($(scotch-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-cuda)-prefix)/.pkgpatch $($(scotch-cuda)-srcdir)/src/Makefile.inc
# Parallel builds are not supported
	cd $($(scotch-cuda)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scotch-cuda)-builddeps) && \
		$(MAKE) MAKEFLAGS="AR=$${CC:-gcc} CCS=$${CC:-gcc} CCP=$${MPICC:-mpicc} CCD=$${CC:-gcc}" \
			scotch ptscotch esmumps ptesmumps --jobs=1
	@touch $@

$($(scotch-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-cuda)-prefix)/.pkgbuild
	@touch $@

$($(scotch-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch-cuda)-prefix)/.pkgcheck
	cd $($(scotch-cuda)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scotch-cuda)-builddeps) && \
		$(MAKE) install prefix=$($(scotch-cuda)-prefix) \
			MAKEFLAGS="AR=$${CC} CCS=$${CC} CCP=$${MPICC} CCD=$${CC}" && \
		patchelf --add-needed libz.so $($(scotch-cuda)-prefix)/lib/*.so && \
		patchelf --add-needed libscotcherr.so $($(scotch-cuda)-prefix)/lib/libscotch.so && \
		patchelf --add-needed libscotch.so $($(scotch-cuda)-prefix)/lib/libptscotch.so && \
		patchelf --add-needed libptscotch.so $($(scotch-cuda)-prefix)/lib/libptscotchparmetis.so && \
		patchelf --add-needed libscotch.so $($(scotch-cuda)-prefix)/lib/libscotchmetis.so
	@touch $@

$($(scotch-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(scotch-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(scotch-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(scotch-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(scotch-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(scotch-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(scotch-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SCOTCH_ROOT $($(scotch-cuda)-prefix)" >>$@
	echo "setenv SCOTCH_INCDIR $($(scotch-cuda)-prefix)/include" >>$@
	echo "setenv SCOTCH_INCLUDEDIR $($(scotch-cuda)-prefix)/include" >>$@
	echo "setenv SCOTCH_LIBDIR $($(scotch-cuda)-prefix)/lib" >>$@
	echo "setenv SCOTCH_LIBRARYDIR $($(scotch-cuda)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(scotch-cuda)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(scotch-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(scotch-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(scotch-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(scotch-cuda)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(scotch-cuda)-prefix)/share/man" >>$@
	echo "set MSG \"$(scotch-cuda)\"" >>$@

$(scotch-cuda)-src: $($(scotch-cuda)-src)
$(scotch-cuda)-unpack: $($(scotch-cuda)-prefix)/.pkgunpack
$(scotch-cuda)-patch: $($(scotch-cuda)-prefix)/.pkgpatch
$(scotch-cuda)-build: $($(scotch-cuda)-prefix)/.pkgbuild
$(scotch-cuda)-check: $($(scotch-cuda)-prefix)/.pkgcheck
$(scotch-cuda)-install: $($(scotch-cuda)-prefix)/.pkginstall
$(scotch-cuda)-modulefile: $($(scotch-cuda)-modulefile)
$(scotch-cuda)-clean:
	rm -rf $($(scotch-cuda)-modulefile)
	rm -rf $($(scotch-cuda)-prefix)
	rm -rf $($(scotch-cuda)-srcdir)
	rm -rf $($(scotch-cuda)-src)
$(scotch-cuda): $(scotch-cuda)-src $(scotch-cuda)-unpack $(scotch-cuda)-patch $(scotch-cuda)-build $(scotch-cuda)-check $(scotch-cuda)-install $(scotch-cuda)-modulefile
