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
# combblas-cuda-1.6.2

combblas-cuda-version = 1.6.2
combblas-cuda = combblas-cuda-$(combblas-cuda-version)
$(combblas-cuda)-description = Distributed-memory parallel graph library
$(combblas-cuda)-url = https://people.eecs.berkeley.edu/~aydin/CombBLAS/html/
$(combblas-cuda)-srcurl = http://eecs.berkeley.edu/~aydin/CombBLAS_FILES/CombBLAS_beta_16_2.tgz
$(combblas-cuda)-builddeps = $(cmake) $(openmpi-cuda)
$(combblas-cuda)-prereqs = $(openmpi-cuda)
$(combblas-cuda)-src = $($(combblas-src)-src)
$(combblas-cuda)-srcdir = $(pkgsrcdir)/$(combblas-cuda)
$(combblas-cuda)-builddir = $($(combblas-cuda)-srcdir)/build
$(combblas-cuda)-modulefile = $(modulefilesdir)/$(combblas-cuda)
$(combblas-cuda)-prefix = $(pkgdir)/$(combblas-cuda)

$($(combblas-cuda)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(combblas-cuda)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(combblas-cuda)-prefix)/.pkgunpack: $$($(combblas-cuda)-src) $($(combblas-cuda)-srcdir)/.markerfile $($(combblas-cuda)-prefix)/.markerfile $$(foreach dep,$$($(combblas-cuda)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(combblas-cuda)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(combblas-cuda)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas-cuda)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(combblas-cuda)-builddir),$($(combblas-cuda)-srcdir))
$($(combblas-cuda)-builddir)/.markerfile: $($(combblas-cuda)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(combblas-cuda)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas-cuda)-builddir)/.markerfile $($(combblas-cuda)-prefix)/.pkgpatch
	cd $($(combblas-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(combblas-cuda)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(combblas-cuda)-prefix) \
			-DBUILD_SHARED_LIBS=TRUE && \
		$(MAKE)
	@touch $@

$($(combblas-cuda)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas-cuda)-builddir)/.markerfile $($(combblas-cuda)-prefix)/.pkgbuild
	@touch $@

$($(combblas-cuda)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(combblas-cuda)-builddeps),$(modulefilesdir)/$$(dep)) $($(combblas-cuda)-builddir)/.markerfile $($(combblas-cuda)-prefix)/.pkgcheck
	cd $($(combblas-cuda)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(combblas-cuda)-builddeps) && \
		$(MAKE) install
	$(INSTALL) -d $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings
	$(INSTALL) -m=644 $($(combblas-cuda)-srcdir)/BipartiteMatchings/* $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/
	sed -i 's/double t1Comp, t1Comm, t2Comp, t2Comm, t3Comp, t3Comm, t4Comp, t4Comm, t5Comp, t5Comm, tUpdateMateComp;/static double t1Comp, t1Comm, t2Comp, t2Comm, t3Comp, t3Comm, t4Comp, t4Comm, t5Comp, t5Comm, tUpdateMateComp;/' $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/ApproxWeightPerfectMatching.h
	sed -i 's/int ThreadBuffLenForBinning(int itemsize, int nbins)/static int ThreadBuffLenForBinning(int itemsize, int nbins)/' $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/ApproxWeightPerfectMatching.h
	sed -i 's/MTRand GlobalMT(123);/static MTRand GlobalMT;/' $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximalMatching.h
	sed -i '26i/MTRand GlobalMT = 123;/' $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximalMatching.cpp
	sed -i 's/double tTotalMaximal;/static double tTotalMaximal;/' $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximalMatching.h
	sed -i 's/double tTotalMaximum;/static double tTotalMaximum;/' $($(combblas-cuda)-prefix)/include/CombBLAS/BipartiteMatchings/BPMaximumMatching.h
	@touch $@

$($(combblas-cuda)-modulefile): $(modulefilesdir)/.markerfile $($(combblas-cuda)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(combblas-cuda)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(combblas-cuda)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(combblas-cuda)-description)\"" >>$@
	echo "module-whatis \"$($(combblas-cuda)-url)\"" >>$@
	printf "$(foreach prereq,$($(combblas-cuda)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv COMBBLAS_ROOT $($(combblas-cuda)-prefix)" >>$@
	echo "setenv COMBBLAS_INCDIR $($(combblas-cuda)-prefix)/include" >>$@
	echo "setenv COMBBLAS_INCLUDEDIR $($(combblas-cuda)-prefix)/include" >>$@
	echo "setenv COMBBLAS_LIBDIR $($(combblas-cuda)-prefix)/lib" >>$@
	echo "setenv COMBBLAS_LIBRARYDIR $($(combblas-cuda)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(combblas-cuda)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(combblas-cuda)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(combblas-cuda)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(combblas-cuda)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(combblas-cuda)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(combblas-cuda)-prefix)/lib/cmake/CombBLAS" >>$@
	echo "set MSG \"$(combblas-cuda)\"" >>$@

$(combblas-cuda)-src: $$($(combblas-cuda)-src)
$(combblas-cuda)-unpack: $($(combblas-cuda)-prefix)/.pkgunpack
$(combblas-cuda)-patch: $($(combblas-cuda)-prefix)/.pkgpatch
$(combblas-cuda)-build: $($(combblas-cuda)-prefix)/.pkgbuild
$(combblas-cuda)-check: $($(combblas-cuda)-prefix)/.pkgcheck
$(combblas-cuda)-install: $($(combblas-cuda)-prefix)/.pkginstall
$(combblas-cuda)-modulefile: $($(combblas-cuda)-modulefile)
$(combblas-cuda)-clean:
	rm -rf $($(combblas-cuda)-modulefile)
	rm -rf $($(combblas-cuda)-prefix)
	rm -rf $($(combblas-cuda)-builddir)
	rm -rf $($(combblas-cuda)-srcdir)
	rm -rf $($(combblas-cuda)-src)
$(combblas-cuda): $(combblas-cuda)-src $(combblas-cuda)-unpack $(combblas-cuda)-patch $(combblas-cuda)-build $(combblas-cuda)-check $(combblas-cuda)-install $(combblas-cuda)-modulefile
