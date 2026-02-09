# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# pastix-6.3.2

pastix-version = 6.3.2
pastix = pastix-$(pastix-version)
$(pastix)-description = Parallel sparse direct Solver
$(pastix)-url = https://gitlab.inria.fr/solverstack/pastix
$(pastix)-srcurl = https://gitlab.inria.fr/solverstack/pastix//uploads/32711239db22edb6c291282b581b9e0b/pastix-6.3.2.tar.gz
$(pastix)-builddeps = $(cmake) $(mpi) $(scotch) $(metis) $(blas) $(lapack) $(hwloc)
$(pastix)-prereqs = $(scotch) $(mpi) $(metis) $(blas) $(lapack) $(hwloc)
$(pastix)-src = $(pkgsrcdir)/$(notdir $($(pastix)-srcurl))
$(pastix)-srcdir = $(pkgsrcdir)/$(pastix)
$(pastix)-builddir = $($(pastix)-srcdir)/build
$(pastix)-modulefile = $(modulefilesdir)/$(pastix)
$(pastix)-prefix = $(pkgdir)/$(pastix)

$($(pastix)-src): $(dir $($(pastix)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pastix)-srcurl)

$($(pastix)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pastix)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pastix)-prefix)/.pkgunpack: $$($(pastix)-src) $($(pastix)-srcdir)/.markerfile $($(pastix)-prefix)/.markerfile $$(foreach dep,$$($(pastix)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(pastix)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pastix)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(pastix)-builddir),$($(pastix)-srcdir))
$($(pastix)-builddir)/.markerfile: $($(pastix)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pastix)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix)-builddir)/.markerfile $($(pastix)-prefix)/.pkgpatch
	cd $($(pastix)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pastix)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(pastix)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DPASTIX_INT64=Off \
			-DPASTIX_ORDERING_SCOTCH=On \
			-DPASTIX_ORDERING_METIS=On \
			-DPASTIX_WITH_MPI=On && \
		$(MAKE)
	@touch $@

$($(pastix)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix)-builddir)/.markerfile $($(pastix)-prefix)/.pkgbuild
	cd $($(pastix)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pastix)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(pastix)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pastix)-builddeps),$(modulefilesdir)/$$(dep)) $($(pastix)-builddir)/.markerfile $($(pastix)-prefix)/.pkgcheck
	cd $($(pastix)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pastix)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(pastix)-modulefile): $(modulefilesdir)/.markerfile $($(pastix)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pastix)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pastix)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pastix)-description)\"" >>$@
	echo "module-whatis \"$($(pastix)-url)\"" >>$@
	printf "$(foreach prereq,$($(pastix)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PASTIX_ROOT $($(pastix)-prefix)" >>$@
	echo "setenv PASTIX_INCDIR $($(pastix)-prefix)/include" >>$@
	echo "setenv PASTIX_INCLUDEDIR $($(pastix)-prefix)/include" >>$@
	echo "setenv PASTIX_LIBDIR $($(pastix)-prefix)/lib" >>$@
	echo "setenv PASTIX_LIBRARYDIR $($(pastix)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pastix)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pastix)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pastix)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pastix)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pastix)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pastix)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pastix)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(pastix)-prefix)/share/info" >>$@
	echo "set MSG \"$(pastix)\"" >>$@

$(pastix)-src: $$($(pastix)-src)
$(pastix)-unpack: $($(pastix)-prefix)/.pkgunpack
$(pastix)-patch: $($(pastix)-prefix)/.pkgpatch
$(pastix)-build: $($(pastix)-prefix)/.pkgbuild
$(pastix)-check: $($(pastix)-prefix)/.pkgcheck
$(pastix)-install: $($(pastix)-prefix)/.pkginstall
$(pastix)-modulefile: $($(pastix)-modulefile)
$(pastix)-clean:
	rm -rf $($(pastix)-modulefile)
	rm -rf $($(pastix)-prefix)
	rm -rf $($(pastix)-builddir)
	rm -rf $($(pastix)-srcdir)
	rm -rf $($(pastix)-src)
$(pastix): $(pastix)-src $(pastix)-unpack $(pastix)-patch $(pastix)-build $(pastix)-check $(pastix)-install $(pastix)-modulefile
