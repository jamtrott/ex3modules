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
# slurm-20.02.6

slurm-20.02.6-version = 20.02.6
slurm-20.02.6 = slurm-$(slurm-20.02.6-version)
$(slurm-20.02.6)-description = Highly configurable open-source workload manager
$(slurm-20.02.6)-url = https://www.schedmd.com/
$(slurm-20.02.6)-srcurl = https://download.schedmd.com/slurm/slurm-$(slurm-20.02.6-version).tar.bz2
$(slurm-20.02.6)-builddeps = $(ucx) $(numactl) $(hwloc) $(freeipmi) $(munge) $(openssl) $(curl) $(readline) $(pmix)
$(slurm-20.02.6)-prereqs = $(ucx) $(numactl) $(hwloc) $(freeipmi) $(munge) $(openssl) $(curl) $(readline) $(pmix)
$(slurm-20.02.6)-src = $(pkgsrcdir)/$(notdir $($(slurm-20.02.6)-srcurl))
$(slurm-20.02.6)-srcdir = $(pkgsrcdir)/$(slurm-20.02.6)
$(slurm-20.02.6)-builddir = $($(slurm-20.02.6)-srcdir)
$(slurm-20.02.6)-modulefile = $(modulefilesdir)/$(slurm-20.02.6)
$(slurm-20.02.6)-prefix = $(pkgdir)/$(slurm-20.02.6)

$($(slurm-20.02.6)-src): $(dir $($(slurm-20.02.6)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(slurm-20.02.6)-srcurl)

$($(slurm-20.02.6)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(slurm-20.02.6)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(slurm-20.02.6)-prefix)/.pkgunpack: $($(slurm-20.02.6)-src) $($(slurm-20.02.6)-srcdir)/.markerfile $($(slurm-20.02.6)-prefix)/.markerfile $$(foreach dep,$$($(slurm-20.02.6)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(slurm-20.02.6)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(slurm-20.02.6)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-20.02.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-20.02.6)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(slurm-20.02.6)-builddir),$($(slurm-20.02.6)-srcdir))
$($(slurm-20.02.6)-builddir)/.markerfile: $($(slurm-20.02.6)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(slurm-20.02.6)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-20.02.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-20.02.6)-builddir)/.markerfile $($(slurm-20.02.6)-prefix)/.pkgpatch
	cd $($(slurm-20.02.6)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-20.02.6)-builddeps) && \
		./configure --prefix=$($(slurm-20.02.6)-prefix) \
			--sysconfdir=/etc/slurm \
			--with-hwloc=$${HWLOC_ROOT} \
			--with-freeipmi=$${FREEIPMI_ROOT} \
			--with-ucx=$${UCX_ROOT} \
			--with-ssl=$${OPENSSL_ROOT} \
			--with-munge=$${MUNGE_ROOT} \
			--with-pmix=$${PMIX_ROOT} \
			--with-libcurl=$${CURL_ROOT} && \
		$(MAKE)
	@touch $@

$($(slurm-20.02.6)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-20.02.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-20.02.6)-builddir)/.markerfile $($(slurm-20.02.6)-prefix)/.pkgbuild
	cd $($(slurm-20.02.6)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-20.02.6)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(slurm-20.02.6)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-20.02.6)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-20.02.6)-builddir)/.markerfile $($(slurm-20.02.6)-prefix)/.pkgcheck
	cd $($(slurm-20.02.6)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-20.02.6)-builddeps) && \
		$(MAKE) install && \
		$(MAKE) -C contribs/pmi install && \
		$(MAKE) -C contribs/pmi2 install
	@touch $@

$($(slurm-20.02.6)-modulefile): $(modulefilesdir)/.markerfile $($(slurm-20.02.6)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(slurm-20.02.6)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(slurm-20.02.6)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(slurm-20.02.6)-description)\"" >>$@
	echo "module-whatis \"$($(slurm-20.02.6)-url)\"" >>$@
	printf "$(foreach prereq,$($(slurm-20.02.6)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SLURM_ROOT $($(slurm-20.02.6)-prefix)" >>$@
	echo "setenv SLURM_INCDIR $($(slurm-20.02.6)-prefix)/include" >>$@
	echo "setenv SLURM_INCLUDEDIR $($(slurm-20.02.6)-prefix)/include" >>$@
	echo "setenv SLURM_LIBDIR $($(slurm-20.02.6)-prefix)/lib" >>$@
	echo "setenv SLURM_LIBRARYDIR $($(slurm-20.02.6)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(slurm-20.02.6)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(slurm-20.02.6)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(slurm-20.02.6)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(slurm-20.02.6)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(slurm-20.02.6)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(slurm-20.02.6)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(slurm-20.02.6)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(slurm-20.02.6)-prefix)/share/info" >>$@
	echo "set MSG \"$(slurm-20.02.6)\"" >>$@

$(slurm-20.02.6)-src: $($(slurm-20.02.6)-src)
$(slurm-20.02.6)-unpack: $($(slurm-20.02.6)-prefix)/.pkgunpack
$(slurm-20.02.6)-patch: $($(slurm-20.02.6)-prefix)/.pkgpatch
$(slurm-20.02.6)-build: $($(slurm-20.02.6)-prefix)/.pkgbuild
$(slurm-20.02.6)-check: $($(slurm-20.02.6)-prefix)/.pkgcheck
$(slurm-20.02.6)-install: $($(slurm-20.02.6)-prefix)/.pkginstall
$(slurm-20.02.6)-modulefile: $($(slurm-20.02.6)-modulefile)
$(slurm-20.02.6)-clean:
	rm -rf $($(slurm-20.02.6)-modulefile)
	rm -rf $($(slurm-20.02.6)-prefix)
	rm -rf $($(slurm-20.02.6)-srcdir)
	rm -rf $($(slurm-20.02.6)-src)
$(slurm-20.02.6): $(slurm-20.02.6)-src $(slurm-20.02.6)-unpack $(slurm-20.02.6)-patch $(slurm-20.02.6)-build $(slurm-20.02.6)-check $(slurm-20.02.6)-install $(slurm-20.02.6)-modulefile
