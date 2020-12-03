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
# slurm-19.05.2

slurm-19.05-version = 19.05.2
slurm-19.05 = slurm-$(slurm-19.05-version)
$(slurm-19.05)-description = Highly configurable open-source workload manager
$(slurm-19.05)-url = https://www.schedmd.com/
$(slurm-19.05)-srcurl = https://download.schedmd.com/slurm/slurm-$(slurm-19.05-version).tar.bz2
$(slurm-19.05)-builddeps = $(pmix) $(ucx) $(numactl) $(hwloc) $(munge)
$(slurm-19.05)-prereqs = $(pmix) $(ucx) $(numactl) $(hwloc) $(munge)
$(slurm-19.05)-src = $(pkgsrcdir)/$(notdir $($(slurm-19.05)-srcurl))
$(slurm-19.05)-srcdir = $(pkgsrcdir)/$(slurm-19.05)
$(slurm-19.05)-builddir = $($(slurm-19.05)-srcdir)
$(slurm-19.05)-modulefile = $(modulefilesdir)/$(slurm-19.05)
$(slurm-19.05)-prefix = $(pkgdir)/$(slurm-19.05)

$($(slurm-19.05)-src): $(dir $($(slurm-19.05)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(slurm-19.05)-srcurl)

$($(slurm-19.05)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(slurm-19.05)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(slurm-19.05)-prefix)/.pkgunpack: $($(slurm-19.05)-src) $($(slurm-19.05)-srcdir)/.markerfile $($(slurm-19.05)-prefix)/.markerfile
	tar -C $($(slurm-19.05)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(slurm-19.05)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-19.05)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-19.05)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(slurm-19.05)-builddir),$($(slurm-19.05)-srcdir))
$($(slurm-19.05)-builddir)/.markerfile: $($(slurm-19.05)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(slurm-19.05)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-19.05)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-19.05)-builddir)/.markerfile $($(slurm-19.05)-prefix)/.pkgpatch
	cd $($(slurm-19.05)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-19.05)-builddeps) && \
		./configure --prefix=$($(slurm-19.05)-prefix) \
			--with-pmix=$${PMIX_ROOT} \
			--with-hwloc=$${HWLOC_ROOT} \
			--with-ucx=$${UCX_ROOT} && \
		$(MAKE)
	@touch $@

$($(slurm-19.05)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-19.05)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-19.05)-builddir)/.markerfile $($(slurm-19.05)-prefix)/.pkgbuild
	cd $($(slurm-19.05)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-19.05)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(slurm-19.05)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-19.05)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-19.05)-builddir)/.markerfile $($(slurm-19.05)-prefix)/.pkgcheck
	cd $($(slurm-19.05)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-19.05)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(slurm-19.05)-modulefile): $(modulefilesdir)/.markerfile $($(slurm-19.05)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(slurm-19.05)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(slurm-19.05)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(slurm-19.05)-description)\"" >>$@
	echo "module-whatis \"$($(slurm-19.05)-url)\"" >>$@
	printf "$(foreach prereq,$($(slurm-19.05)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SLURM_ROOT $($(slurm-19.05)-prefix)" >>$@
	echo "setenv SLURM_INCDIR $($(slurm-19.05)-prefix)/include" >>$@
	echo "setenv SLURM_INCLUDEDIR $($(slurm-19.05)-prefix)/include" >>$@
	echo "setenv SLURM_LIBDIR $($(slurm-19.05)-prefix)/lib" >>$@
	echo "setenv SLURM_LIBRARYDIR $($(slurm-19.05)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(slurm-19.05)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(slurm-19.05)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(slurm-19.05)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(slurm-19.05)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(slurm-19.05)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(slurm-19.05)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(slurm-19.05)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(slurm-19.05)-prefix)/share/info" >>$@
	echo "set MSG \"$(slurm-19.05)\"" >>$@

$(slurm-19.05)-src: $($(slurm-19.05)-src)
$(slurm-19.05)-unpack: $($(slurm-19.05)-prefix)/.pkgunpack
$(slurm-19.05)-patch: $($(slurm-19.05)-prefix)/.pkgpatch
$(slurm-19.05)-build: $($(slurm-19.05)-prefix)/.pkgbuild
$(slurm-19.05)-check: $($(slurm-19.05)-prefix)/.pkgcheck
$(slurm-19.05)-install: $($(slurm-19.05)-prefix)/.pkginstall
$(slurm-19.05)-modulefile: $($(slurm-19.05)-modulefile)
$(slurm-19.05)-clean:
	rm -rf $($(slurm-19.05)-modulefile)
	rm -rf $($(slurm-19.05)-prefix)
	rm -rf $($(slurm-19.05)-srcdir)
	rm -rf $($(slurm-19.05)-src)
$(slurm-19.05): $(slurm-19.05)-src $(slurm-19.05)-unpack $(slurm-19.05)-patch $(slurm-19.05)-build $(slurm-19.05)-check $(slurm-19.05)-install $(slurm-19.05)-modulefile
