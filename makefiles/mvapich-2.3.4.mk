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
# mvapich-2.3.4

mvapich-version = 2.3.4
mvapich = mvapich-$(mvapich-version)
$(mvapich)-description = High-performance MPI Implementation from Ohio State University
$(mvapich)-url = https://mvapich.cse.ohio-state.edu/
$(mvapich)-srcurl = https://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-$(mvapich-version).tar.gz
$(mvapich)-builddeps = $(flex) $(bison) $(knem) $(rdma-core) $(libfabric) $(hwloc) $(slurm)
$(mvapich)-prereqs = $(knem) $(rdma-core) $(libfabric) $(hwloc) $(slurm)
$(mvapich)-src = $(pkgsrcdir)/$(notdir $($(mvapich)-srcurl))
$(mvapich)-srcdir = $(pkgsrcdir)/$(mvapich)
$(mvapich)-builddir = $($(mvapich)-srcdir)
$(mvapich)-modulefile = $(modulefilesdir)/$(mvapich)
$(mvapich)-prefix = $(pkgdir)/$(mvapich)

$($(mvapich)-src): $(dir $($(mvapich)-src)).markerfile
	$(CURL) --insecure $(curl_options) --output $@ $($(mvapich)-srcurl)

$($(mvapich)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(mvapich)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(mvapich)-prefix)/.pkgunpack: $($(mvapich)-src) $($(mvapich)-srcdir)/.markerfile $($(mvapich)-prefix)/.markerfile
	tar -C $($(mvapich)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mvapich)-srcdir)/0001-src-env-Fix-mpicc-mpicxx-linker-command-line.patch: $($(mvapich)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 7d4d580b5d8d56a8ca7c3b861498553a9995c68f Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: "James D. Trotter" <james@simula.no>' >>$@.tmp
	@echo 'Date: Sat, 21 Nov 2020 12:39:01 +0100' >>$@.tmp
	@echo 'Subject: [PATCH] src/env: Fix mpicc/mpicxx linker command line' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' src/env/mpicc.bash.in  | 2 +-' >>$@.tmp
	@echo ' src/env/mpicc.sh.in    | 2 +-' >>$@.tmp
	@echo ' src/env/mpicxx.bash.in | 2 +-' >>$@.tmp
	@echo ' src/env/mpicxx.sh.in   | 2 +-' >>$@.tmp
	@echo ' 4 files changed, 4 insertions(+), 4 deletions(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/src/env/mpicc.bash.in b/src/env/mpicc.bash.in' >>$@.tmp
	@echo 'index aa65f27..21517c0 100644' >>$@.tmp
	@echo '--- a/src/env/mpicc.bash.in' >>$@.tmp
	@echo '+++ b/src/env/mpicc.bash.in' >>$@.tmp
	@echo '@@ -268,7 +268,7 @@ if [ "$$linking" = yes ] ; then' >>$@.tmp
	@echo '         $$Show $$CC $${final_cppflags} $$PROFILE_INCPATHS $${final_cflags} $${final_ldflags} "$${allargs[@]}" -I$$includedir' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     else' >>$@.tmp
	@echo '-        $$Show $$CC $${final_cppflags} $$PROFILE_INCPATHS $${final_cflags} -l@MPILIBNAME@ $${final_ldflags} "$${allargs[@]}" -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '+        $$Show $$CC $${final_cppflags} $$PROFILE_INCPATHS $${final_cflags} $${final_ldflags} "$${allargs[@]}" -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags -l@MPILIBNAME@ @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     fi' >>$@.tmp
	@echo ' else' >>$@.tmp
	@echo 'diff --git a/src/env/mpicc.sh.in b/src/env/mpicc.sh.in' >>$@.tmp
	@echo 'index dceab90..f6e433d 100644' >>$@.tmp
	@echo '--- a/src/env/mpicc.sh.in' >>$@.tmp
	@echo '+++ b/src/env/mpicc.sh.in' >>$@.tmp
	@echo '@@ -277,7 +277,7 @@ if [ "$$linking" = yes ] ; then' >>$@.tmp
	@echo '         $$Show $$CC $${final_cppflags} $$PROFILE_INCPATHS $${final_cflags} $${final_ldflags} $$allargs -I$$includedir' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     else' >>$@.tmp
	@echo '-        $$Show $$CC $${final_cppflags} $$PROFILE_INCPATHS $${final_cflags} -l@MPILIBNAME@ $${final_ldflags} $$allargs -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '+        $$Show $$CC $${final_cppflags} $$PROFILE_INCPATHS $${final_cflags} $${final_ldflags} $$allargs -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags -l@MPILIBNAME@ @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     fi' >>$@.tmp
	@echo ' else' >>$@.tmp
	@echo 'diff --git a/src/env/mpicxx.bash.in b/src/env/mpicxx.bash.in' >>$@.tmp
	@echo 'index 5d4e163..5af4e9e 100644' >>$@.tmp
	@echo '--- a/src/env/mpicxx.bash.in' >>$@.tmp
	@echo '+++ b/src/env/mpicxx.bash.in' >>$@.tmp
	@echo '@@ -266,7 +266,7 @@ if [ "$$linking" = yes ] ; then' >>$@.tmp
	@echo '         $$Show $$CXX $${final_cppflags} $$PROFILE_INCPATHS $${final_cxxflags} $${final_ldflags} "$${allargs[@]}" -I$$includedir' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     else' >>$@.tmp
	@echo '-        $$Show $$CXX $${final_cppflags} $$PROFILE_INCPATHS $${final_cxxflags} $$cxxlibs -l@MPILIBNAME@ $${final_ldflags} "$${allargs[@]}" -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '+        $$Show $$CXX $${final_cppflags} $$PROFILE_INCPATHS $${final_cxxflags} $$cxxlibs $${final_ldflags} "$${allargs[@]}" -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags -l@MPILIBNAME@ @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     fi' >>$@.tmp
	@echo ' else' >>$@.tmp
	@echo 'diff --git a/src/env/mpicxx.sh.in b/src/env/mpicxx.sh.in' >>$@.tmp
	@echo 'index 0186905..3dd1a49 100644' >>$@.tmp
	@echo '--- a/src/env/mpicxx.sh.in' >>$@.tmp
	@echo '+++ b/src/env/mpicxx.sh.in' >>$@.tmp
	@echo '@@ -275,7 +275,7 @@ if [ "$$linking" = yes ] ; then' >>$@.tmp
	@echo '         $$Show $$CXX $${final_cppflags} $$PROFILE_INCPATHS $${final_cxxflags} $${final_ldflags} $$allargs -I$$includedir' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     else' >>$@.tmp
	@echo '-        $$Show $$CXX $${final_cppflags} $$PROFILE_INCPATHS $${final_cxxflags} $$cxxlibs -l@MPILIBNAME@ $${final_ldflags} $$allargs -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '+        $$Show $$CXX $${final_cppflags} $$PROFILE_INCPATHS $${final_cxxflags} $$cxxlibs $${final_ldflags} $$allargs -I$$includedir $$ITAC_OPTIONS -L$$libdir $$PROFILE_PRELIB $$PROFILE_FOO $$rpath_flags -l@MPILIBNAME@ @LPMPILIBNAME@ $$PROFILE_POSTLIB $${final_libs}' >>$@.tmp
	@echo '         rc=$$?' >>$@.tmp
	@echo '     fi' >>$@.tmp
	@echo ' else' >>$@.tmp
	@echo '--' >>$@.tmp
	@echo '2.17.1' >>$@.tmp
	@echo '' >>$@.tmp
	@mv $@.tmp $@

$($(mvapich)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mvapich)-prefix)/.pkgunpack $($(mvapich)-srcdir)/0001-src-env-Fix-mpicc-mpicxx-linker-command-line.patch
	cd $($(mvapich)-srcdir) && \
		patch -t -p1 <0001-src-env-Fix-mpicc-mpicxx-linker-command-line.patch
	@touch $@

ifneq ($($(mvapich)-builddir),$($(mvapich)-srcdir))
$($(mvapich)-builddir)/.markerfile: $($(mvapich)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(mvapich)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mvapich)-builddir)/.markerfile $($(mvapich)-prefix)/.pkgpatch
	cd $($(mvapich)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mvapich)-builddeps) && \
		./configure --prefix=$($(mvapich)-prefix) \
			--with-ofi=$${LIBFABRIC_ROOT} \
			--with-mxm=$${LIBFABRIC_ROOT} \
			--with-knem=$${KNEM_ROOT} \
			--with-ibverbs=$${RDMA_CORE_ROOT} \
			--with-device=ch3:mrail --with-rdma=gen2 \
			--with-pmi=pmi2 \
			--with-pm=slurm \
			--with-slurm=$${SLURM_ROOT} \
			--enable-slurm=yes \
			--enable-fortran=all \
			--enable-fast=O3,ndebug --without-timing --without-mpit-pvars && \
		$(MAKE)
	@touch $@

$($(mvapich)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mvapich)-builddir)/.markerfile $($(mvapich)-prefix)/.pkgbuild
	cd $($(mvapich)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mvapich)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(mvapich)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mvapich)-builddir)/.markerfile $($(mvapich)-prefix)/.pkgcheck
	cd $($(mvapich)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mvapich)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(mvapich)-modulefile): $(modulefilesdir)/.markerfile $($(mvapich)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mvapich)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mvapich)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mvapich)-description)\"" >>$@
	echo "module-whatis \"$($(mvapich)-url)\"" >>$@
	printf "$(foreach prereq,$($(mvapich)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MVAPICH_ROOT $($(mvapich)-prefix)" >>$@
	echo "setenv MVAPICH_INCDIR $($(mvapich)-prefix)/include" >>$@
	echo "setenv MVAPICH_INCLUDEDIR $($(mvapich)-prefix)/include" >>$@
	echo "setenv MVAPICH_LIBDIR $($(mvapich)-prefix)/lib" >>$@
	echo "setenv MVAPICH_LIBRARYDIR $($(mvapich)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(mvapich)-prefix)" >>$@
	echo "setenv MPI_RUN $($(mvapich)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(mvapich)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(mvapich)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(mvapich)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(mvapich)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(mvapich)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIFORT $($(mvapich)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(mvapich)-prefix)/bin/mpirun" >>$@
	echo "prepend-path PATH $($(mvapich)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mvapich)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mvapich)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mvapich)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mvapich)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mvapich)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(mvapich)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(mvapich)-prefix)/share/info" >>$@
	echo "set MSG \"$(mvapich)\"" >>$@

$(mvapich)-src: $($(mvapich)-src)
$(mvapich)-unpack: $($(mvapich)-prefix)/.pkgunpack
$(mvapich)-patch: $($(mvapich)-prefix)/.pkgpatch
$(mvapich)-build: $($(mvapich)-prefix)/.pkgbuild
$(mvapich)-check: $($(mvapich)-prefix)/.pkgcheck
$(mvapich)-install: $($(mvapich)-prefix)/.pkginstall
$(mvapich)-modulefile: $($(mvapich)-modulefile)
$(mvapich)-clean:
	rm -rf $($(mvapich)-modulefile)
	rm -rf $($(mvapich)-prefix)
	rm -rf $($(mvapich)-srcdir)
	rm -rf $($(mvapich)-src)
$(mvapich): $(mvapich)-src $(mvapich)-unpack $(mvapich)-patch $(mvapich)-build $(mvapich)-check $(mvapich)-install $(mvapich)-modulefile
