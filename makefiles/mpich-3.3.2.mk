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
# mpich-3.3.2

mpich-version = 3.3.2
mpich = mpich-$(mpich-version)
$(mpich)-description = High-Performance Portable Message Passing Library
$(mpich)-url = https://www.mpich.org
$(mpich)-srcurl = http://www.mpich.org/static/downloads/$(mpich-version)/mpich-$(mpich-version).tar.gz
$(mpich)-builddeps = $(knem) $(libfabric) $(slurm)
$(mpich)-prereqs = $(knem) $(libfabric) $(slurm)
$(mpich)-src = $(pkgsrcdir)/$(notdir $($(mpich)-srcurl))
$(mpich)-srcdir = $(pkgsrcdir)/$(mpich)
$(mpich)-builddir = $($(mpich)-srcdir)
$(mpich)-modulefile = $(modulefilesdir)/$(mpich)
$(mpich)-prefix = $(pkgdir)/$(mpich)

$($(mpich)-src): $(dir $($(mpich)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mpich)-srcurl)

$($(mpich)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mpich)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mpich)-prefix)/.pkgunpack: $($(mpich)-src) $($(mpich)-srcdir)/.markerfile $($(mpich)-prefix)/.markerfile
	tar -C $($(mpich)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mpich)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpich)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(mpich)-builddir),$($(mpich)-srcdir))
$($(mpich)-builddir)/.markerfile: $($(mpich)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(mpich)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpich)-builddir)/.markerfile $($(mpich)-prefix)/.pkgpatch
	cd $($(mpich)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpich)-builddeps) && \
		./configure --prefix=$($(mpich)-prefix) \
			--with-libfabric=$${LIBFABRIC_ROOT} \
			--with-knem=$${KNEM_ROOT} \
			--with-device=ch4:ofi:verbs \
			--with-pm=none \
			$$([ ! -z "$(SLURM_ROOT)" ] && echo --with-pmi=slurm --with-slurm="$(SLURM_ROOT)" --with-slurm-include="$(SLURM_ROOT)/include/slurm") \
			--enable-g=all \
			--enable-fortran=all \
			--enable-fast=O3,ndebug --without-timing --without-mpit-pvars && \
			$(MAKE)
	@touch $@

$($(mpich)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpich)-builddir)/.markerfile $($(mpich)-prefix)/.pkgbuild
	cd $($(mpich)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpich)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(mpich)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpich)-builddir)/.markerfile $($(mpich)-prefix)/.pkgcheck
	cd $($(mpich)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpich)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(mpich)-modulefile): $(modulefilesdir)/.markerfile $($(mpich)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mpich)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mpich)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mpich)-description)\"" >>$@
	echo "module-whatis \"$($(mpich)-url)\"" >>$@
	printf "$(foreach prereq,$($(mpich)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MPICH_ROOT $($(mpich)-prefix)" >>$@
	echo "setenv MPICH_INCDIR $($(mpich)-prefix)/include" >>$@
	echo "setenv MPICH_INCLUDEDIR $($(mpich)-prefix)/include" >>$@
	echo "setenv MPICH_LIBDIR $($(mpich)-prefix)/lib" >>$@
	echo "setenv MPICH_LIBRARYDIR $($(mpich)-prefix)/lib" >>$@
	echo "setenv MPI_HOME $($(mpich)-prefix)" >>$@
	echo "setenv MPI_RUN $($(mpich)-prefix)/bin/mpirun" >>$@
	echo "setenv MPICC $($(mpich)-prefix)/bin/mpicc" >>$@
	echo "setenv MPICXX $($(mpich)-prefix)/bin/mpicxx" >>$@
	echo "setenv MPIEXEC $($(mpich)-prefix)/bin/mpiexec" >>$@
	echo "setenv MPIF77 $($(mpich)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIF90 $($(mpich)-prefix)/bin/mpif77" >>$@
	echo "setenv MPIFORT $($(mpich)-prefix)/bin/mpifort" >>$@
	echo "setenv MPIRUN $($(mpich)-prefix)/bin/mpirun" >>$@
	echo "prepend-path PATH $($(mpich)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mpich)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mpich)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mpich)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mpich)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mpich)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(mpich)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(mpich)-prefix)/share/info" >>$@
	echo "set MSG \"$(mpich)\"" >>$@

$(mpich)-src: $($(mpich)-src)
$(mpich)-unpack: $($(mpich)-prefix)/.pkgunpack
$(mpich)-patch: $($(mpich)-prefix)/.pkgpatch
$(mpich)-build: $($(mpich)-prefix)/.pkgbuild
$(mpich)-check: $($(mpich)-prefix)/.pkgcheck
$(mpich)-install: $($(mpich)-prefix)/.pkginstall
$(mpich)-modulefile: $($(mpich)-modulefile)
$(mpich)-clean:
	rm -rf $($(mpich)-modulefile)
	rm -rf $($(mpich)-prefix)
	rm -rf $($(mpich)-srcdir)
	rm -rf $($(mpich)-src)
$(mpich): $(mpich)-src $(mpich)-unpack $(mpich)-patch $(mpich)-build $(mpich)-check $(mpich)-install $(mpich)-modulefile
