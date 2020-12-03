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
# combblas-1.6.2

combblas-version = 1.6.2
combblas = combblas-$(combblas-version)
$(combblas)-description = Distributed-memory parallel graph library
$(combblas)-url = https://people.eecs.berkeley.edu/~aydin/CombBLAS/html/
$(combblas)-srcurl = http://eecs.berkeley.edu/~aydin/CombBLAS_FILES/CombBLAS_beta_16_2.tgz
$(combblas)-builddeps = $(cmake) $(mpi)
$(combblas)-prereqs = $(mpi)
$(combblas)-src = $(pkgsrcdir)/$(notdir $($(combblas)-srcurl))
$(combblas)-srcdir = $(pkgsrcdir)/$(combblas)
$(combblas)-builddir = $($(combblas)-srcdir)/build
$(combblas)-modulefile = $(modulefilesdir)/$(combblas)
$(combblas)-prefix = $(pkgdir)/$(combblas)

$($(combblas)-src): $(dir $($(combblas)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(combblas)-srcurl)

$($(combblas)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(combblas)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(combblas)-prefix)/.pkgunpack: $$($(combblas)-src) $($(combblas)-srcdir)/.markerfile $($(combblas)-prefix)/.markerfile
	tar -C $($(combblas)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(combblas)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(combblas)-builddir),$($(combblas)-srcdir))
$($(combblas)-builddir)/.markerfile: $($(combblas)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(combblas)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas)-builddir)/.markerfile $($(combblas)-prefix)/.pkgpatch
	cd $($(combblas)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(combblas)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(combblas)-prefix) \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE)
	@touch $@

$($(combblas)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas)-builddir)/.markerfile $($(combblas)-prefix)/.pkgbuild
	@touch $@

$($(combblas)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas)-builddir)/.markerfile $($(combblas)-prefix)/.pkgcheck
	cd $($(combblas)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(combblas)-builddeps) && \
		$(MAKE) install
	$(INSTALL) -m=6755 -d $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings
	$(INSTALL) -m=644 $($(combblas)-srcdir)/BipartiteMatchings/* $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/
	sed -i 's/double t1Comp, t1Comm, t2Comp, t2Comm, t3Comp, t3Comm, t4Comp, t4Comm, t5Comp, t5Comm, tUpdateMateComp;/static double t1Comp, t1Comm, t2Comp, t2Comm, t3Comp, t3Comm, t4Comp, t4Comm, t5Comp, t5Comm, tUpdateMateComp;/' $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/ApproxWeightPerfectMatching.h
	sed -i 's/int ThreadBuffLenForBinning(int itemsize, int nbins)/static int ThreadBuffLenForBinning(int itemsize, int nbins)/' $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/ApproxWeightPerfectMatching.h
	sed -i 's/MTRand GlobalMT(123);/static MTRand GlobalMT;/' $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximalMatching.h
	sed -i '26i/MTRand GlobalMT = 123;/' $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximalMatching.cpp
	sed -i 's/double tTotalMaximal;/static double tTotalMaximal;/' $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximalMatching.h
	sed -i 's/double tTotalMaximum;/static double tTotalMaximum;/' $($(combblas)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximumMatching.h
	@touch $@

$($(combblas)-modulefile): $(modulefilesdir)/.markerfile $($(combblas)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(combblas)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(combblas)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(combblas)-description)\"" >>$@
	echo "module-whatis \"$($(combblas)-url)\"" >>$@
	printf "$(foreach prereq,$($(combblas)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv COMBBLAS_ROOT $($(combblas)-prefix)" >>$@
	echo "setenv COMBBLAS_INCDIR $($(combblas)-prefix)/include" >>$@
	echo "setenv COMBBLAS_INCLUDEDIR $($(combblas)-prefix)/include" >>$@
	echo "setenv COMBBLAS_LIBDIR $($(combblas)-prefix)/lib" >>$@
	echo "setenv COMBBLAS_LIBRARYDIR $($(combblas)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(combblas)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(combblas)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(combblas)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(combblas)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(combblas)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(combblas)-prefix)/lib/cmake/CombBLAS" >>$@
	echo "set MSG \"$(combblas)\"" >>$@

$(combblas)-src: $$($(combblas)-src)
$(combblas)-unpack: $($(combblas)-prefix)/.pkgunpack
$(combblas)-patch: $($(combblas)-prefix)/.pkgpatch
$(combblas)-build: $($(combblas)-prefix)/.pkgbuild
$(combblas)-check: $($(combblas)-prefix)/.pkgcheck
$(combblas)-install: $($(combblas)-prefix)/.pkginstall
$(combblas)-modulefile: $($(combblas)-modulefile)
$(combblas)-clean:
	rm -rf $($(combblas)-modulefile)
	rm -rf $($(combblas)-prefix)
	rm -rf $($(combblas)-builddir)
	rm -rf $($(combblas)-srcdir)
	rm -rf $($(combblas)-src)
$(combblas): $(combblas)-src $(combblas)-unpack $(combblas)-patch $(combblas)-build $(combblas)-check $(combblas)-install $(combblas)-modulefile
